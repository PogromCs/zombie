/*================================================================================
	
	----------------------------------
	-*- [ZP] Game Mode: Armageddon -*-
	----------------------------------
	
	This plugin is part of Zombie Plague Mod and is distributed under the
	terms of the GNU General Public License. Check ZP_ReadMe.txt for details.
	
================================================================================*/

#include <amxmodx>
#include <fun>
#include <amxmisc>
#include <amx_settings_api>
#include <cs_teams_api>
#include <zp50_gamemodes>
#include <zp50_class_nemesis>
#include <zp50_class_survivor>
#include <zp50_deathmatch>

// Settings file
new const ZP_SETTINGS_FILE[] = "zombieplague.ini"

// Default sounds
new const sound_armageddon[][] = { "zombie_plague/nemesis1.wav" , "zombie_plague/survivor1.wav" }

#define SOUND_MAX_LENGTH 64

new Array:g_sound_armageddon

// HUD messages
#define HUD_EVENT_X -1.0
#define HUD_EVENT_Y 0.17
#define HUD_EVENT_R 0
#define HUD_EVENT_G 50
#define HUD_EVENT_B 200

new g_MaxPlayers
new g_HudSync

new cvar_avsp_chance, cvar_avsp_min_players,cvar_avsp_min_admins

new cvar_avsp_nem_hp_multi, cvar_avsp_surv_hp_multi
new cvar_avsp_show_hud, cvar_avsp_sounds
new cvar_avsp_allow_respawn

public plugin_precache()
{
	// Register game mode at precache (plugin gets paused after this)
	register_plugin("[ZP] Game Mode: Admini Vs Gracze Mode", ZP_VERSION_STRING, "ZP Dev Team")
	zp_gamemodes_register("Admini Vs Gracze Mode")
	
	// Create the HUD Sync Objects
	g_HudSync = CreateHudSyncObj()
	
	g_MaxPlayers = get_maxplayers()
	
	cvar_avsp_chance = register_cvar("zp_avsp_chance", "20")
	cvar_avsp_min_admins = register_cvar("zp_avsp_min_admins", "3")
	cvar_avsp_min_players = register_cvar("zp_avsp_min_players", "8")
	cvar_avsp_nem_hp_multi = register_cvar("zp_avsp_nem_hp_multi", "2.0")
	cvar_avsp_surv_hp_multi = register_cvar("zp_avsp_surv_hp_multi", "0.25")
	cvar_avsp_show_hud = register_cvar("zp_avsp_show_hud", "1")
	cvar_avsp_sounds = register_cvar("zp_avsp_sounds", "1")
	cvar_avsp_allow_respawn = register_cvar("zp_avsp_allow_respawn", "0")
	
	// Initialize arrays
	g_sound_armageddon = ArrayCreate(SOUND_MAX_LENGTH, 1)
	
	// Load from external file
	amx_load_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ROUND ARMAGEDDON", g_sound_armageddon)
	
	// If we couldn't load custom sounds from file, use and save default ones
	new index
	if (ArraySize(g_sound_armageddon) == 0)
	{
		for (index = 0; index < sizeof sound_armageddon; index++)
			ArrayPushString(g_sound_armageddon, sound_armageddon[index])
		
		// Save to external file
		amx_save_setting_string_arr(ZP_SETTINGS_FILE, "Sounds", "ROUND ARMAGEDDON", g_sound_armageddon)
	}
	
	// Precache sounds
	new sound[SOUND_MAX_LENGTH]
	for (index = 0; index < ArraySize(g_sound_armageddon); index++)
	{
		ArrayGetString(g_sound_armageddon, index, sound, charsmax(sound))
		if (equal(sound[strlen(sound)-4], ".mp3"))
		{
			format(sound, charsmax(sound), "sound/%s", sound)
			precache_generic(sound)
		}
		else
			precache_sound(sound)
	}
}

// Deathmatch module's player respawn forward
public zp_fw_deathmatch_respawn_pre(id)
{
	// Respawning allowed?
	if (!get_pcvar_num(cvar_avsp_allow_respawn))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

public zp_fw_gamemodes_choose_pre(game_mode_id, skipchecks)
{
	if (!skipchecks)
	{
		// Random chance
		if (random_num(1, get_pcvar_num(cvar_avsp_chance)) != 1)
			return PLUGIN_HANDLED;
		
		// Min players
		if ((GetAliveAdmin() < get_pcvar_num(cvar_avsp_min_admins)) || (GetAlivePlayer() < get_pcvar_num(cvar_avsp_min_players)))
			return PLUGIN_HANDLED;
	}
	
	// Game mode allowed
	return PLUGIN_CONTINUE;
}

public zp_fw_gamemodes_start()
{
	// Calculate player counts
	new id
	new iNemesis, iMaxNemesis = GetAliveAdmin()

	while (iNemesis < iMaxNemesis)
	{
		
		for (id = 1; id <= g_MaxPlayers; id++)
		{
			if (!is_user_alive(id) || !is_user_connected(id))
				continue;
			
			
			if (zp_class_survivor_get(id) || zp_class_nemesis_get(id))
				continue;
			if(get_user_flags(id) & ADMIN_BAN){
				// If not, turn him into one
				zp_class_nemesis_set(id)
				iNemesis++
				
				// Apply nemesis health multiplier
				set_user_health(id, floatround(get_user_health(id) * get_pcvar_float(cvar_avsp_nem_hp_multi)))
			}
		}
	}
	
	// Turn specified amount of players into Survivors
	new iSurvivors, iMaxSurvivors = GetAliveCount() - GetAliveAdmin()
	while (iSurvivors < iMaxSurvivors)
	{
		
		for (id = 1; id <= g_MaxPlayers; id++)
		{
			if (!is_user_alive(id) || !is_user_connected(id))
				continue;
			// Already a survivor?
			if (zp_class_survivor_get(id) || get_user_flags(id) & ADMIN_BAN)
				continue;
			
			// If not, turn him into one
			zp_class_survivor_set(id)
			iSurvivors++
			
			// Apply survivor health multiplier
			set_user_health(id, floatround(get_user_health(id) * get_pcvar_float(cvar_avsp_surv_hp_multi)))
		}
	}
	
	// Turn specified amount of players into Nemesis
	
	
	// Play Armageddon sound
	if (get_pcvar_num(cvar_avsp_sounds))
	{
		new sound[SOUND_MAX_LENGTH]
		ArrayGetString(g_sound_armageddon, random_num(0, ArraySize(g_sound_armageddon) - 1), sound, charsmax(sound))
		PlaySoundToClients(sound)
	}
	
	if (get_pcvar_num(cvar_avsp_show_hud))
	{
		// Show Armageddon HUD notice
		set_hudmessage(HUD_EVENT_R, HUD_EVENT_G, HUD_EVENT_B, HUD_EVENT_X, HUD_EVENT_Y, 1, 0.0, 5.0, 1.0, 1.0, -1)
		ShowSyncHudMsg(0, g_HudSync, "%L", LANG_PLAYER, "NOTICE_ARMAGEDDON")
	}
}

// Plays a sound on clients
PlaySoundToClients(const sound[])
{
	if (equal(sound[strlen(sound)-4], ".mp3"))
		client_cmd(0, "mp3 play ^"sound/%s^"", sound)
	else
		client_cmd(0, "spk ^"%s^"", sound)
}

// Get Alive Count -returns alive players number-
GetAliveAdmin()
{
	new iAlive, id
	
	for (id = 1; id <= g_MaxPlayers; id++)
	{
		if (is_user_alive(id) && access(id, ADMIN_BAN))
			iAlive++
	}
	
	return iAlive;
}
GetAliveCount()
{
	new iAlive, id
	
	for (id = 1; id <= g_MaxPlayers; id++)
	{
		if (is_user_alive(id))
			iAlive++
	}
	
	return iAlive;
}
GetAlivePlayer()
{
	new iAlive, id
	
	for (id = 1; id <= g_MaxPlayers; id++)
	{
		if (is_user_alive(id) && !access(id,ADMIN_BAN))
			iAlive++
	}
	
	return iAlive;
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1045\\ f0\\ fs16 \n\\ par }
*/
