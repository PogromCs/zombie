/*
Multijump addon by twistedeuphoria
Plagued by Dabbi
Classed by B!gBud

CVARS:
	zp_tight_jump 2 (Default)

*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <zp50_class_zombie>
#include <zp50_class_nemesis>
#include <zp50_class_assassin>
#include <fun>
#include <colorchat>

#define TASK_USUN 300
#define TASK_UZYC 200
new cvar_cooldown, cvar_cooldown_vip,cvar_time,cvar_time_vip
new g_zclass_tight

// Tight Zombie Atributes
new const zombieclass5_name[] = "Ninja zombie"
new const zombieclass5_info[] = "Moze byc niewidzialny(klawisz e)55"
new const zombieclass5_models[][] = { "zombie_source" }
new const zombieclass5_clawmodels[][] = { "models/zombie_plague/v_knife_zombie.mdl" }
const zombieclass5_health = 1400
const Float:zombieclass5_speed = 1.05
const Float:zombieclass5_gravity = 1.2
const Float:zombieclass5_knockback = 1.0
new Float:g_lastuse[33]
public plugin_init()
{
    cvar_cooldown = register_cvar("zp_ninja_cooldown","12.0")	
    cvar_cooldown_vip = register_cvar("zp_ninja_cooldown_vip","7.0")
    cvar_time = register_cvar("zp_ninja_time","3.0")
    cvar_time_vip = register_cvar("zp_ninja_time_vip","5.0")
}

public plugin_precache()
{
	register_plugin("[ZP] Class: Zombie: NINJA", ZP_VERSION_STRING, "Pogrom")
	new index
	
	g_zclass_tight = zp_class_zombie_register(zombieclass5_name, zombieclass5_info, zombieclass5_health, zombieclass5_speed, zombieclass5_gravity)
	zp_class_zombie_register_kb(g_zclass_tight, zombieclass5_knockback)
	for (index = 0; index < sizeof zombieclass5_models; index++)
		zp_class_zombie_register_model(g_zclass_tight, zombieclass5_models[index])
	for (index = 0; index < sizeof zombieclass5_clawmodels; index++)
		zp_class_zombie_register_claw(g_zclass_tight, zombieclass5_clawmodels[index])
}
public client_PreThink(id)
{
	if(!is_user_alive(id)) return PLUGIN_CONTINUE
	if(!zp_core_is_zombie(id) || zp_class_zombie_get_current(id) != g_zclass_tight || zp_class_nemesis_get(id) || zp_class_assassin_get(id)) return PLUGIN_CONTINUE
	
	if(get_user_button(id) & IN_USE)
	{   
        
	    new cooldown;
        if(access(id,ADMIN_LEVEL_H)){
            cooldown = get_pcvar_num(cvar_cooldown_vip)
        }
        else 
        {
            cooldown = get_pcvar_num(cvar_cooldown)
        }

        if(halflife_time()-g_lastuse[id] <= cooldown)
        {
            return PLUGIN_HANDLED
        }
        new Float:time 
        if(access(id,ADMIN_LEVEL_H)){
           
            time = get_pcvar_float(cvar_time_vip)
            set_task(get_pcvar_float(cvar_cooldown_vip)+time,"moze_uzyc",id+TASK_UZYC)
            set_user_rendering(id, kRenderFxNone, 0,0,0, kRenderTransAlpha, 1)
            set_task(time,"usun_niewidzialnosc",id+TASK_USUN)
        }
           
        else {
           
            time = get_pcvar_float(cvar_time)
            set_task(get_pcvar_float(cvar_cooldown)+time,"moze_uzyc",id+TASK_UZYC)
            set_user_rendering(id, kRenderFxNone, 0,0,0, kRenderTransAlpha, 5)
            set_task(time,"usun_niewidzialnosc",id+TASK_USUN)
        }
        g_lastuse[id] = halflife_time() 
       
       
	return PLUGIN_CONTINUE
    }
    return PLUGIN_CONTINUE
}

public usun_niewidzialnosc(id)
{
    id -= TASK_USUN
    set_user_rendering(id, kRenderFxNone, 0,0,0, kRenderTransAlpha,255)
    ColorChat(id, GREEN, "[Ninja]^x03Jestes juz widzialny!");
}
public moze_uzyc(id)
{   
    id-=TASK_UZYC
	ColorChat(id, GREEN, "[Ninja]^x03Niewidzialnosc gotowa do uzycia!");

	return PLUGIN_CONTINUE;
}