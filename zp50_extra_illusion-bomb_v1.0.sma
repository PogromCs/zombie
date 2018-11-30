#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <cstrike>
#include <hamsandwich>
#include <xs>
#include <zombieplague>
#include <fun>

#define PLUGIN "[ZP] Extra Item: Illusion Bomb"
#define VERSION "1.0"
#define AUTHOR "Dias"

// Define
#define MAX_ZOMBIE_ENT 4
#define ZOMBIE_ENT_CLASSNAME "illusion_zombie"
#define CLASSNAME_FAKE_PLAYER "fake_zombie"

#define TASK_REMOVE_ILLUSION 24001
#define COST 30

new const confused_model[4][] = 
{
	"models/zombie_plague/v_zombibomb.mdl",
	"models/zombie_plague/p_zombibomb.mdl",
	"models/zombie_plague/w_zombibomb.mdl",
	"sprites/zombie_plague/zb_confuse.spr"
}

new const exp_spr[] = "sprites/zombie_plague/zombiebomb_exp.spr"

#define pev_nade_type        pev_flTimeStepSound
#define NADE_TYPE_ILLUSION    121315
new has_illusion_bomb[33]
new g_exploSpr

new g_illusion_bomb

// Hard Code
const pev_type = pev_iuser1
new g_zombie_ent[33][MAX_ZOMBIE_ENT], g_illusing[33]

new g_fake_player[33], g_random_model[128], g_confused_icon[33], g_stop_frame[33]
// Cvarr
new cvar_illusion_time, cvar_radius

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_event("CurWeapon", "EV_CurWeapon", "be", "1=1", "2=9")
	register_event("HLTV", "event_newround", "a", "1=0", "2=0")
	
	register_forward(FM_SetModel, "fw_SetModel")
	RegisterHam(Ham_Think, "grenade", "fw_GrenadeThink")
	RegisterHam(Ham_Touch, "grenade", "fw_GrenadeTouch")	
	
	register_event("DeathMsg", "event_death", "a")
	RegisterHam(Ham_Spawn, "player", "fw_spaw_post", 1)
	
	register_think(ZOMBIE_ENT_CLASSNAME, "fw_ent_think")
	register_forward(FM_AddToFullPack, "fw_addtofullpack_post", 1)
	
	cvar_illusion_time = register_cvar("zp_illusion_time", "10.0")
	cvar_radius = register_cvar("zp_illusion_radius", "250.0")

	g_illusion_bomb = zp_register_extra_item("Illusion Bomb", COST, ZP_TEAM_ZOMBIE)

	// This thing will make the bot throw bomb ^^!
	//register_clcmd("switch_to_smoke", "switch_to_smoke") // Make the bot switch to smokegrenade
	//register_clcmd("set_weapon_shoot", "set_weapon_shoot") // Make the bot throw bomb
}

/*
new g_id[33]

public switch_to_smoke(id)
{
	static body, target
	get_user_aiming(id, target, body, 999999)
	
	if(is_user_alive(target))
	{
		g_id[id] = target
	}
}

public set_weapon_shoot(id)
{
	if(is_user_alive(g_id[id]))
	{
		illusion_bomb_exp(g_id[id], g_id[id])
	}
}*/

public plugin_precache()
{
	new i
	
	for(i = 0; i < sizeof(confused_model); i++)
		precache_model(confused_model[i])
	
	g_exploSpr = engfunc(EngFunc_PrecacheModel, exp_spr)
}

public client_disconnect(id)
{
	remove_fake_player(id)
}

public event_newround()
{
	for(new i = 0; i < get_maxplayers(); i++)
	{
		if(is_user_alive(i))
		{
			remove_illusion(i)
		}
	}
}

public zp_extra_item_selected(id, item)
{
	if(item == g_illusion_bomb)
	{
		has_illusion_bomb[id] = true
		give_item(id, "weapon_smokegrenade")
		
		client_print(id, print_chat, "[ZP] Kupiles Illusion Bomb. Mozesz wywolac u graczy halucynacje !!!")
	}
}

public EV_CurWeapon(id)
{
	if (!is_user_alive ( id ) || !zp_get_user_zombie(id))
		return PLUGIN_CONTINUE
	
	if (has_illusion_bomb[id] && get_user_weapon(id) == CSW_SMOKEGRENADE)
	{
		set_pev(id, pev_viewmodel2, confused_model[0])
		set_pev(id, pev_weaponmodel2, confused_model[1])
	}
	
	return PLUGIN_CONTINUE
}

public fw_SetModel(ent, const Model[])
{
	if (ent < 0)
		return FMRES_IGNORED
	
	if (pev(ent, pev_dmgtime) == 0.0)
		return FMRES_IGNORED
	
	new iOwner = pev(ent, pev_owner)
	
	if (has_illusion_bomb[iOwner] && equal(Model[7], "w_sm", 4))
	{
		entity_set_model(ent, confused_model[2])
		
		// Reset any other nade
		set_pev(ent, pev_nade_type, 0)
		set_pev(ent, pev_nade_type, NADE_TYPE_ILLUSION)
	
		return FMRES_SUPERCEDE
	}
	return FMRES_IGNORED
}

public fw_GrenadeThink(ent)
{
	if(!pev_valid(ent))
		return HAM_IGNORED
	
	static Float:dmg_time
	pev(ent, pev_dmgtime, dmg_time)
	
	if(dmg_time > get_gametime())
		return HAM_IGNORED
	
	static id
	id = pev(ent, pev_owner)
	
	if(pev(ent, pev_nade_type) == NADE_TYPE_ILLUSION)
	{ 
		if(has_illusion_bomb[id])
		{
			has_illusion_bomb[id] = false
			illusion_bomb_exp(ent, id)
			
			engfunc(EngFunc_RemoveEntity, ent)
			
			return HAM_SUPERCEDE
		}
	}

	return HAM_HANDLED
}

public fw_GrenadeTouch(bomb)
{
	if(!pev_valid(bomb))
		return HAM_IGNORED
	
	static id
	id = pev(bomb, pev_owner)
	
	if(zp_get_user_zombie(id) && pev(bomb, pev_nade_type) == NADE_TYPE_ILLUSION)
	{ 
		if(has_illusion_bomb[id])
		{
			set_pev(bomb, pev_dmgtime, 0.0)
		}
	}

	return HAM_HANDLED	
}

public illusion_bomb_exp(ent, id)
{
	static Float:Origin[3]
	pev(ent, pev_origin, Origin)
    
	engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, Origin, 0)
	write_byte(TE_EXPLOSION); // TE_EXPLOSION
	engfunc(EngFunc_WriteCoord, Origin[0]); // origin x
	engfunc(EngFunc_WriteCoord, Origin[1]); // origin y
	engfunc(EngFunc_WriteCoord, Origin[2]); // origin z
	write_short(g_exploSpr); // sprites
	write_byte(40); // scale in 0.1's
	write_byte(30); // framerate
	write_byte(14); // flags 
	message_end(); // message end
	
	
	// Make Hit Human
	static victim = -1
	while ((victim = engfunc(EngFunc_FindEntityInSphere, victim, Origin, get_pcvar_float(cvar_radius))) != 0)
	{
		if(!is_user_alive(victim) || g_illusing[victim] || zp_get_user_zombie(victim))
			continue
		
		client_print(victim, print_center, "Jestes w stanie halucynajci!!!")
		make_illusion(victim, id)
	}	
}

public make_illusion(id, attacker)
{
	// Remove Old Illusion
	remove_illusion(id)	
	
	// Set Player to Illusion Dimenson
	g_illusing[id] = 1
	
	
	static ModelName2[128]
	
	// Make Fake Zombie if not
	for(new i = 0; i < MAX_ZOMBIE_ENT; i++)
	{
		if(!pev_valid(g_zombie_ent[id][i]))
		{
			g_zombie_ent[id][i] = create_entity("info_target")
		}
		
		static Float:Origin[3], ent, Float:VicOrigin[3]
		ent = g_zombie_ent[id][i]
		
		if(i == 0)
		{
			get_position(id, 100.0, 0.0, 0.0, Origin)
		} else if(i == 1) {
			get_position(id, 50.0, 100.0, 0.0, Origin)
		} else if(i == 2) {
			get_position(id, -100.0, 0.0, 0.0, Origin)
		} else if(i == 3) {
			get_position(id, -50.0, -100.0, 0.0, Origin)
		}
		
		entity_set_origin(ent, Origin)
		
		pev(id, pev_origin, VicOrigin)
		npc_turntotarget(ent, Origin, VicOrigin)
		
		static ModelName[128]
		cs_get_user_model(attacker, ModelName, sizeof(ModelName))
		
		formatex(ModelName2, sizeof(ModelName2), "models/player/%s/%s.mdl", ModelName, ModelName)
		formatex(g_random_model, sizeof(g_random_model), "models/player/%s/%s.mdl", ModelName, ModelName)
		
		entity_set_string(ent, EV_SZ_classname, ZOMBIE_ENT_CLASSNAME)
		entity_set_model(ent, ModelName2)
		entity_set_int(ent, EV_INT_solid, SOLID_NOT)
		entity_set_int(ent, EV_INT_movetype, MOVETYPE_PUSHSTEP)
		
		static Float:mins[3], Float:maxs[3]
		
		mins[0] = -16.0
		mins[1] = -16.0
		mins[2] = -36.0
		
		maxs[0] = 16.0
		maxs[1] = 16.0
		maxs[2] = 36.0
		
		set_pev(ent, pev_mins, mins)
		set_pev(ent, pev_maxs, maxs)
		
		set_pev(ent, pev_renderfx, kRenderFxGlowShell)
		set_pev(ent, pev_rendermode, kRenderTransAlpha)
		set_pev(ent, pev_renderamt, 0.0)
		
		set_pev(ent, pev_owner, id)
		set_pev(ent, pev_type, i)
		
		set_entity_anim(ent, 4)
		
		drop_to_floor(ent)
		
		set_pev(ent, pev_nextthink, halflife_time() + 0.01)
	}
	
	// Make Crazy Screen
	static Float:PunchAngles[3]
	
	PunchAngles[0] = random_float(-25.0, 25.0)
	PunchAngles[1] = random_float(-25.0, 25.0)
	PunchAngles[2] = random_float(-25.0, 25.0)
	
	set_pev(id, pev_punchangle, PunchAngles)
	
	// Make ScreenFade
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, id)
	write_short(10)
	write_short(10)
	write_short(0x0000)
	write_byte(100)
	write_byte(100)
	write_byte(100)
	write_byte(255)
	message_end()	

	// Make Illusion Icon
	make_confused_icon(id)
	
	// Remove Illusion
	remove_task(id+TASK_REMOVE_ILLUSION)
	set_task(get_pcvar_float(cvar_illusion_time), "do_remove_illusion", id+TASK_REMOVE_ILLUSION)
}

public make_confused_icon(id)
{
	// Already haves a sprite on his hud
	if (g_confused_icon[id])
	{
		// Invalid entity ?
		if (!pev_valid(g_confused_icon[id]))
			return PLUGIN_HANDLED	
		
		// Set the rendering on the entity
		set_pev(g_confused_icon[id], pev_rendermode, kRenderTransAdd)
		set_pev(g_confused_icon[id], pev_renderamt, 255.0)
		
		return PLUGIN_HANDLED
	}

	// Create an entity for the player
	g_confused_icon[id] = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_sprite"))
	
	// Invalid entity ?
	if (!pev_valid(g_confused_icon[id]))
		return PLUGIN_HANDLED
	
	// Set some basic properties
	set_pev(g_confused_icon[id], pev_takedamage, 0.0)
	set_pev(g_confused_icon[id], pev_solid, SOLID_NOT)
	set_pev(g_confused_icon[id], pev_movetype, MOVETYPE_NONE)
	set_pev(g_confused_icon[id], pev_classname, "confusing")
	
	// Set the sprite model
	engfunc(EngFunc_SetModel, g_confused_icon[id], confused_model[3])
	
	// Set the rendering on the entity
	set_pev(g_confused_icon[id], pev_rendermode, kRenderTransAdd)
	set_pev(g_confused_icon[id], pev_renderamt, 255.0)
	
	// Set the sprite size
	set_pev(g_confused_icon[id], pev_scale, 1.0)
	set_pev(g_confused_icon[id], pev_owner, id)
	
	// Update sprite's stopping frame
	g_stop_frame[id] = 6
	
	// Allow animation of sprite ?
	if (g_stop_frame[id] && 1.0 > 0.0)
	{
		// Set the sprites animation time, framerate and stop frame
		set_pev(g_confused_icon[id], pev_animtime, get_gametime())
		set_pev(g_confused_icon[id], pev_framerate, 10.0)
		
		// Spawn the sprite entity (necessary to play the sprite animations)
		set_pev(g_confused_icon[id], pev_spawnflags, SF_SPRITE_STARTON)
		dllfunc(DLLFunc_Spawn, g_confused_icon[id])
	}

	return g_confused_icon[id]
}	

public client_PostThink(id)
{
	if(!is_user_alive(id))
		return
		
	if(!g_illusing[id])
		return
		
	if(!pev_valid(g_confused_icon[id]))
		return
		
	static Float:Origin[3]
	
	// Retrieve player's origin
	pev(id, pev_origin, Origin)
	
	Origin[2] += 40.0
	
	engfunc(EngFunc_SetOrigin, g_confused_icon[id], Origin)
	
	// Stop the animation at the desired frame
	if (pev(g_confused_icon[id], pev_frame) == g_stop_frame[id])
	{
		set_pev(g_confused_icon[id], pev_framerate, 2.0)
		set_pev(g_confused_icon[id], pev_frame, 0.1)
		
		g_stop_frame[id] = 6
	}
}

public do_remove_illusion(id)
{
	id -= TASK_REMOVE_ILLUSION
	
	if(is_user_alive(id))
		remove_illusion(id)
}

public remove_illusion(id)
{
	g_illusing[id] = 0
	remove_task(id+TASK_REMOVE_ILLUSION)
	
	for(new ent = 0; ent < MAX_ZOMBIE_ENT; ent++)
	{
		if(pev_valid(g_zombie_ent[id][ent]))
		{
			set_pev(g_zombie_ent[id][ent], pev_rendermode, kRenderTransAdd)
			set_pev(g_zombie_ent[id][ent], pev_renderamt, 0.0)
		}
	}	
	
	if(pev_valid(g_confused_icon[id]))
	{
		set_pev(g_confused_icon[id], pev_rendermode, kRenderTransAdd)
		set_pev(g_confused_icon[id], pev_renderamt, 0.0)
	}
}

public event_death()
{
	static victim
	victim = read_data(2)
	
	remove_illusion(victim)
}

public zp_user_infected_post(id)
{
	remove_illusion(id)
}

public fw_spaw_post(id)
{
	remove_illusion(id)
}

public fw_ent_think(ent)
{
	if(!pev_valid(ent))
		return
	static id
	id = pev(ent, pev_owner)
	
	if(!is_user_alive(id) || !g_illusing[id])
		return

	hook_ent(ent, id, 150.0)
		
	set_pev(ent, pev_nextthink, halflife_time() + 0.01)
}

public fw_addtofullpack_post(es_handle, e, ent, host, hostflags, player, pset)
{
	if(!is_user_alive(host) || !pev_valid(ent))
		return FMRES_IGNORED
	if(!g_illusing[host] || zp_get_user_zombie(host))
		return FMRES_IGNORED
		
	static Classname[32]
	pev(ent, pev_classname, Classname, sizeof(Classname))
	
	// Fake Zombie
	if(equal(Classname, ZOMBIE_ENT_CLASSNAME) && pev(ent, pev_owner) == host)
	{
		set_es(es_handle, ES_RenderAmt, 255.0)
		
		/*
		static id, type, Float:Origin[3]
		
		id = pev(ent, pev_owner)
		type = pev(ent, pev_type)
		
		if(type == 0)
		{
			get_position(id, 100.0, 0.0, 0.0, Origin)
		} else if(type == 1) {
			get_position(id, 75.0, 35.0, 0.0, Origin)
		} else if(type == 2) {
			get_position(id, 75.0, -35.0, 0.0, Origin)
		}
		
		set_es(es_handle, ES_Origin, Origin)*/
		
		static Float:newAngle[3], Float:VicOrigin[3], Float:EntOrigin[3]
		
		entity_get_vector(ent, EV_VEC_angles, newAngle)
		pev(host, pev_origin, VicOrigin)
		pev(ent, pev_origin, EntOrigin)
		
		new Float:x = VicOrigin[0] - EntOrigin[0]
		new Float:z = VicOrigin[1] - EntOrigin[1]
	
		new Float:radians = floatatan(z/x, radian)
		newAngle[1] = radians * (180 / 3.14)
		if (VicOrigin[0] < EntOrigin[0])
			newAngle[1] -= 180.0	
			
		set_es(es_handle, ES_Angles, newAngle)
	} else if(equal(Classname, CLASSNAME_FAKE_PLAYER)) {
		static ent_owner
		ent_owner = pev(ent, pev_owner)
		
		if(is_user_alive(ent_owner) && !zp_get_user_zombie(ent_owner))
		{
			set_es(es_handle, ES_RenderMode, kRenderNormal)
			set_es(es_handle, ES_RenderAmt, 255.0)
			
			engfunc(EngFunc_SetModel, ent, g_random_model)
		}
	}
	
	if(is_user_alive(ent) && !zp_get_user_zombie(ent)) 
	{
		set_es(es_handle, ES_RenderMode, kRenderTransAlpha)
		set_es(es_handle, ES_RenderAmt, 0.0)
		
		new iEntFake = find_ent_by_owner(-1, CLASSNAME_FAKE_PLAYER, ent)
		if(!iEntFake || !pev_valid(ent))
		{
			iEntFake = create_fake_player(ent)
		}
		
		g_fake_player[ent] = iEntFake	
	}
	
	return FMRES_HANDLED
}

stock get_position(ent, Float:forw, Float:right, Float:up, Float:vStart[])
{
	new Float:vOrigin[3], Float:vAngle[3], Float:vForward[3], Float:vRight[3], Float:vUp[3]
	
	pev(ent, pev_origin, vOrigin)
	pev(ent, pev_view_ofs,vUp) //for player
	xs_vec_add(vOrigin,vUp,vOrigin)
	pev(ent, pev_v_angle, vAngle) // if normal entity ,use pev_angles
	
	vAngle[0] = 0.0
	
	angle_vector(vAngle,ANGLEVECTOR_FORWARD,vForward) //or use EngFunc_AngleVectors
	angle_vector(vAngle,ANGLEVECTOR_RIGHT,vRight)
	angle_vector(vAngle,ANGLEVECTOR_UP,vUp)
	
	vStart[0] = vOrigin[0] + vForward[0] * forw + vRight[0] * right + vUp[0] * up
	vStart[1] = vOrigin[1] + vForward[1] * forw + vRight[1] * right + vUp[1] * up
	vStart[2] = vOrigin[2] + vForward[2] * forw + vRight[2] * right + vUp[2] * up
}

stock set_entity_anim(ent, anim)
{
	entity_set_float(ent, EV_FL_animtime, get_gametime())
	entity_set_float(ent, EV_FL_framerate, 1.0)
	entity_set_float(ent, EV_FL_frame, 0.0)
	entity_set_int(ent, EV_INT_sequence, anim)	
}

public npc_turntotarget(ent, Float:Ent_Origin[3], Float:Vic_Origin[3]) 
{
	if(!pev_valid(ent))
		return
	
	new Float:newAngle[3]
	entity_get_vector(ent, EV_VEC_angles, newAngle)
	new Float:x = Vic_Origin[0] - Ent_Origin[0]
	new Float:z = Vic_Origin[1] - Ent_Origin[1]

	new Float:radians = floatatan(z/x, radian)
	newAngle[1] = radians * (180 / 3.14)
	if (Vic_Origin[0] < Ent_Origin[0])
		newAngle[1] -= 180.0

	entity_set_vector(ent, EV_VEC_v_angle, newAngle)
	entity_set_vector(ent, EV_VEC_angles, newAngle)
}

public hook_ent(ent, victim, Float:speed)
{
	static Float:fl_Velocity[3]
	static Float:VicOrigin[3], Float:EntOrigin[3]

	pev(ent, pev_origin, EntOrigin)
	pev(victim, pev_origin, VicOrigin)
	
	static Float:distance_f
	distance_f = get_distance_f(EntOrigin, VicOrigin)

	if (distance_f > 60.0)
	{
		new Float:fl_Time = distance_f / speed

		fl_Velocity[0] = (VicOrigin[0] - EntOrigin[0]) / fl_Time
		fl_Velocity[1] = (VicOrigin[1] - EntOrigin[1]) / fl_Time
		fl_Velocity[2] = (VicOrigin[2] - EntOrigin[2]) / fl_Time
	} else
	{
		fl_Velocity[0] = 0.0
		fl_Velocity[1] = 0.0
		fl_Velocity[2] = 0.0
	}

	entity_set_vector(ent, EV_VEC_velocity, fl_Velocity)
}

public create_fake_player(id)
{
	new iEntFake = create_entity("info_target")
	
	set_pev(iEntFake, pev_classname, CLASSNAME_FAKE_PLAYER)
	//set_pev(iEntFake, pev_modelindex, pev(id, pev_modelindex))
	set_pev(iEntFake, pev_movetype, MOVETYPE_FOLLOW)
	set_pev(iEntFake, pev_solid, SOLID_NOT)
	set_pev(iEntFake, pev_aiment, id)
	set_pev(iEntFake, pev_owner, id)

	set_pev(iEntFake, pev_renderfx, kRenderFxGlowShell)
	set_pev(iEntFake, pev_rendermode, kRenderTransAlpha)
	set_pev(iEntFake, pev_renderamt, 255.0)

	return iEntFake
} 

public remove_fake_player(id)
{
	if(pev_valid(g_fake_player[id]))
		remove_entity(g_fake_player[id])
}
