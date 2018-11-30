#include <amxmodx>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <zp50_class_zombie>
#include <zp50_class_human>
#include <zp50_class_survivor>
#include <zp50_class_sniper>
#include <zp50_class_lowca>
#include <zp50_ammopacks>
#include <zombieplague>
#include <zp50_core>

new const humanclass6_name[] = "Grenadier"
new const humanclass6_info[] = "=VIP Only= (dostaje po 4 granaty)"
new const humanclass6_models[][] = { "csfifkaczlo" }
const humanclass6_health = 250
const Float:humanclass6_speed = 1.15
const Float:humanclass6_gravity = 0.8
const humanclass6_armor = 40

new g_HumanClassID

public plugin_precache()
{
	register_plugin("[ZP] Class: Human: Grenadier", ZP_VERSION_STRING, "AntiChrist")
	register_logevent("Poczatek_Rundy", 2, "1=Round_Start")
	g_HumanClassID = zp_class_human_register(humanclass6_name, humanclass6_info, humanclass6_health, humanclass6_speed, humanclass6_gravity, humanclass6_armor)
	new index
	for (index = 0; index < sizeof humanclass6_models; index++)
	zp_class_human_register_model(g_HumanClassID, humanclass6_models[index])
}

public zp_fw_class_human_select_pre(id, classid)
{
 	if(!(get_user_flags(id) & ADMIN_LEVEL_H) && classid == g_HumanClassID)
	{
		return ZP_CLASS_NOT_AVAILABLE
	}
	return ZP_CLASS_AVAILABLE
	
}

public Poczatek_Rundy(id)
{
	for (new id = 1 ; id<33;id++)
	{
		if(zp_class_human_get_current(id) == g_HumanClassID && is_user_alive(id) && !zp_core_is_zombie(id)  && !zp_class_survivor_get(id) && !zp_class_sniper_get(id) && !zp_class_lowca_get(id))
	{
		cs_set_user_bpammo(id, CSW_FLASHBANG, cs_get_user_bpammo(id, CSW_FLASHBANG)+3)
		cs_set_user_bpammo(id, CSW_SMOKEGRENADE, cs_get_user_bpammo(id, CSW_SMOKEGRENADE)+3)
		cs_set_user_bpammo(id, CSW_HEGRENADE, cs_get_user_bpammo(id, CSW_HEGRENADE)+3)
	}	
	}
}
