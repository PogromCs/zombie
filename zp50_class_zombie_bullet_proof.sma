#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <zombieplague>
#include <zp50_class_zombie>
#include <colorchat>
#include <zp50_class_human>
#include <zp50_class_nemesis>
#include <zp50_class_assassin>

const Weapons = (1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)

// Bullet Proof Zombie
new const zombieclass11_name[] = { "Zombie Bullet Proof" }
new const zombieclass11_info[] = { "=VIP Only= Da sie go zranic tylko za pomoca pistoletu" }
new const zombieclass11_model[] = { "Bullet_Proof" }
new const zombieclass11_clawmodel[] = { "v_bulletproof_claws.mdl" }
const zombieclass11_health = 1000
const zombieclass11_speed = 350
const Float:zombieclass11_gravity = 0.80
const Float:zombieclass11_knockback = 1.0

new gBulletProof

public plugin_init()
{ 
	register_plugin("[ZP] ZP Class: Bullet Proof", "0.2", "DJHD!") 
	
	RegisterHam(Ham_TraceAttack, "player", "fw_Player_TraceAttack")
}

public plugin_precache(){
	gBulletProof = zp_register_zombie_class(zombieclass11_name, zombieclass11_info,  zombieclass11_model,  zombieclass11_clawmodel,  zombieclass11_health,  zombieclass11_speed,  zombieclass11_gravity,  zombieclass11_knockback)
}
public zp_user_infected_post(id, infector)
{
	if (zp_get_user_zombie_class(id) == gBulletProof)
	{
		if(!zp_core_is_zombie(id)  && zp_class_nemesis_get(id) && zp_class_assassin_get(id))
			return
		
		print_chatColor(id, "\g[ZP]\n Mozesz byc zraniony tylko z pistoletu.") 
	}
}

public fw_Player_TraceAttack(iVictim, iAttacker, Float:flDamage, Float:vecDirection[3], iTr, iDamageType)
{
	if(!is_user_alive(iVictim) || !is_user_alive(iAttacker))
		return HAM_IGNORED;
	
	if(zp_get_user_nemesis(iVictim))
		return HAM_IGNORED;
	
	if(zp_get_user_survivor(iAttacker))
		return HAM_IGNORED;
	
	if(zp_get_user_zombie_class(iVictim) == gBulletProof)
	{				
		if(entity_get_int(iAttacker, EV_INT_weapons) & Weapons)
		{			
			new Float:vecEndPos[3]
			get_tr2(iTr, TR_vecEndPos, vecEndPos)
			
			engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecEndPos, 0)
			write_byte(TE_SPARKS) // TE iId
			engfunc(EngFunc_WriteCoord, vecEndPos[0]) // x
			engfunc(EngFunc_WriteCoord, vecEndPos[1]) // y
			engfunc(EngFunc_WriteCoord, vecEndPos[2]) // z
			message_end()
			
			return HAM_SUPERCEDE;
		}
	}
	return HAM_HANDLED;
}

stock print_chatColor(const id, const input[], any:...)
{
	new msg[191], players[32], count = 1;
	vformat(msg,190,input,3);
	replace_all(msg,190,"\g","^4");// green
	replace_all(msg,190,"\n","^1");// normal
	replace_all(msg,190,"\t","^3");// team
	
	if (id) players[0] = id; else get_players(players,count,"ch");
	for (new i=0;i<count;i++)
		if (is_user_connected(players[i]))
	{
		message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("SayText"),_,players[i]);
		write_byte(players[i]);
		write_string(msg);
		message_end();
	}
}
