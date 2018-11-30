#include <amxmodx>
#include <zombieplague>
#include <fun> 
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <zp50_class_zombie>
#include <zp50_class_human>
#include <zp50_class_assassin>
#include <zp50_class_nemesis>
#include <zp50_class_lowca>
#include <zp50_class_survivor>
#include <zp50_items>

#define COST 30
   
new g_iBuy

new V_KATANA[] = "models/v_katana.mdl" 
new P_KATANA[]        = "models/p_katana.mdl"
new W_KATANA[]    = "models/w_katana.mdl"

new bool:g_katana[33]
new g_currentweapon[33]
new g_iMaxPlayers
new g_mgcur

// Cvar pointer
new cvar_oneround, cvar_explobody, cvar_katanaenabled


public plugin_init()
{
	register_plugin("[ZP] Extra Item: Katana", "1.0", "AntiChrist") 
	g_iBuy = zp_register_extra_item("Katana 1/8 na zabicie (PPM)",COST, ZP_TEAM_HUMAN)

	// Event
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_event("CurWeapon", "Event_CurWeapon", "be","1=1")
	
	// Forwards
	register_forward(FM_SetModel, "fw_SetModel")
	
	// Ham 
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn", 1)
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	
	// Cvars 
	cvar_katanaenabled = register_cvar("zp_katana_enabled", "1")
	cvar_oneround = register_cvar("zp_katana_oneround", "0")
	cvar_explobody = register_cvar("zp_katana_explobody", "1")
	
	// Others 
	register_touch("katana", "player", "PlayerTouchKatana")
	g_mgcur = get_user_msgid("CurWeapon")
}

public plugin_precache()
{
	precache_model(V_KATANA)
	precache_model(P_KATANA)
	precache_model(W_KATANA)
}

// Item Selected forward
public zp_extra_item_selected(id, itemid)
{	
	if (get_pcvar_num(cvar_katanaenabled))
	{
		if (itemid == g_iBuy)
		{
			g_katana[id] = true
			give_item (id, "weapon_knife")
			client_print(id, print_chat, "Masz 1/8 szans na natychmiastowe zabicie z noza")
		}
	}
}
public zp_extra_item_selected_pre(id, itemid)
{
	if (itemid == g_iBuy)
	{
		if(g_katana[id])
			return ZP_ITEM_DONT_SHOW

		return ZP_ITEM_AVAILABLE
	}
	return PLUGIN_CONTINUE
}
public event_round_start()
{
	for(new i = 1; i <= g_iMaxPlayers; i++)
	{
		if (!is_user_connected(i))
		continue
		
		if (g_katana[i])
		{
			g_katana[i] = false
		}
		give_item(i, "weapon_knife")
		remove_entity_name("katana")
	}
}

public Event_CurWeapon(id) 
{     
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE
	
	g_currentweapon[id] = read_data(2) 
	
	if(!g_katana[id] || g_currentweapon[id] != CSW_KNIFE)
		return PLUGIN_CONTINUE
	
	entity_set_string(id, EV_SZ_viewmodel, V_KATANA)
	entity_set_string(id, EV_SZ_weaponmodel, P_KATANA)
	
	return PLUGIN_CONTINUE 
}

public fw_SetModel(entity, model[])
{
	if(!is_valid_ent(entity)) 
		return FMRES_IGNORED
	
	if(!equali(model, "models/w_knife.mdl")) 
		return FMRES_IGNORED;
	
	new className[33]
	entity_get_string(entity, EV_SZ_classname, className, 32)
	
	if(equal(className, "weaponbox") || equal(className, "armoury_entity") || equal(className, "grenade"))
	{
		entity_set_model(entity, W_KATANA)
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}  

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_bits)
{	
	new plrWeapId, plrClip, plrAmmo
	plrWeapId = get_user_weapon(attacker, plrClip, plrAmmo)
	if(!is_user_connected(attacker) || !is_user_connected(victim) || zp_get_user_nemesis(victim) || attacker == victim || !attacker )
        return HAM_IGNORED
	if((zp_get_user_last_zombie(victim) || zp_get_user_first_zombie(victim) || !zp_core_is_zombie(victim) || zp_class_nemesis_get(victim) || zp_class_assassin_get(victim)) && g_currentweapon[attacker] == CSW_KNIFE && get_user_button(attacker) & IN_ATTACK2)
    {
        client_print(attacker, print_center, "Bossy, Pierwszy i ostatni zombie sa odporni")
        return HAM_IGNORED
    }
	
	if(g_katana[attacker] && plrWeapId == CSW_KNIFE && get_user_button(attacker) & IN_ATTACK2 &&random_num(1,8) == 1 && !zp_class_lowca_get(attacker) && !zp_class_survivor_get(attacker))
	{
		SetHamParamFloat(4, damage += get_user_health(victim))
		client_print(attacker, print_center, "Wrog pocwiartowany!")
	}

	return HAM_IGNORED; 
}


public fw_PlayerKilled(victim, attacker, shouldgib)
{
	if(!is_user_connected(attacker) || !is_user_connected(victim) || attacker == victim || !attacker)
		return HAM_IGNORED
	
	if(g_katana[attacker] && g_currentweapon[attacker] == CSW_KNIFE && get_pcvar_num(cvar_explobody) && get_user_button(attacker) &IN_ATTACK2)
	{
		SetHamParamInteger(3, 2)
		static iOrigin[3]
		get_user_origin(victim, iOrigin)
		implosion_efect(iOrigin)
	}
	
	if(g_katana[victim])
	{
		g_katana[victim] = false
	}
	return HAM_IGNORED
}

implosion_efect(iOrigin[3])
{
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_IMPLOSION)
	write_coord(iOrigin[0])
	write_coord(iOrigin[1])
	write_coord(iOrigin[2])
	write_byte(200)
	write_byte(40)
	write_byte(45)
	message_end()
}

public zp_user_infected_post(infected, infector)
{
	
	if (g_katana[infected])
	{
		g_katana[infected] = false
	}
}

public client_putinserver(id)
{
	g_katana[id] = false
}

public client_disconnect(id)
{
	g_katana[id] = false
}

public fw_PlayerSpawn(id)
{
	if(get_pcvar_num(cvar_oneround))
	{
		g_katana[id] = false
		give_item(id, "weapon_knife")
	}
}


public reset_knifeModel(id)
{
	if(user_has_weapon(id, CSW_KNIFE))
	ExecuteHamB(Ham_Item_Deploy, find_ent_by_owner(-1, "weapon_knife", id))
	
	engclient_cmd(id, "weapon_knife")
	emessage_begin(MSG_ONE, g_mgcur, _, id)
	ewrite_byte(1)
	ewrite_byte(CSW_KNIFE)
	ewrite_byte(-1)
	emessage_end()
}

public PlayerTouchKatana(Has, player)
{
	if(!is_valid_ent(Has) || !is_valid_ent(player))
	return PLUGIN_CONTINUE
	
	if(!is_user_connected(player))
	return PLUGIN_CONTINUE
	
	if(!is_user_alive(player) || zp_get_user_zombie(player) || zp_get_user_survivor(player) || g_katana[player])
	return PLUGIN_CONTINUE
	
	g_katana[player] = true
	
	reset_knifeModel(player)
	
	remove_entity(Has)
	
	return PLUGIN_CONTINUE
}
