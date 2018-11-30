/* Plugin generated by AMXX-Studio */
#include "osiagniecia.cfg"
#include <amxmodx>
#include <fun>
#include <hamsandwich>
#include <amxmisc>
#include <colorchat>
#include <zp50_ammopacks>

#define PLUGIN "Give Away"
#define VERSION "1.0.1 - beta"
#define AUTHOR "Pogrom"

new const FILE[] = "_giveaway.txt"
native set_user_xp(id,amount);
native get_user_xp(id);
native get_user_level(id);
native set_user_level(id,level);
native get_user_max_level(id);
native load_stat(id,nr);
native add_achieve(id,nr);
native daj_knockbomb(id);
native daj_miny(id,ilosc);
native daj_bazooke(id);
native powieksz_bank(id);
native zp_bonus_set(id,amount);
native zp_bonus_get(id);
new callback
new data[6]
new dostep;
new name[32]
new bool:osc[33] = false
new bool:dmg[33] = false
new const PREFIX[] = "GIVEWAY"
new const FORUM[] = "cskatowice.com"
new const OPIEKUNOWIE [] = "Pogrom , Behind yOu oraz Antichrist"
new const commands[][]={
	"say",
	"say_team"
	}

enum {
	TASK_LOSUJ,
	TASK_WYSWIETL,
	TASK_NAGRODA
}
new liczba_losowan = 5
new bool:giveaway = false
///new ZNAKI[62][] = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","1","2","3","4","5","6","7","8","9"};
new text[33]

enum CVARS{
	enable,
	min_graczy,
	czas_wyswietlania,
	czas_na_wpisanie
};

new const percent[]= {
5, //pominiecie lvl
10, //vip 7dni
20, //vip 3dni
60, //puste losy
140, //exp min 1k - 2k
140, //ap min 100-200
50, //puste losy
80, //exp med 2k-4k
80, //ap med 300-600
20, //puste losy
40, //pominiecie osiagniecia	
40, //zwiekszenie banku  o 100
40, //puste losy
40, //max exp  4k - 6k
40, //max ap 600 - 900
25, //puste losy
40, // 5% dmg 
40, // bonusy 100-150
30, // pustelosy
60 //bonusy 50-100
};


new g_cvars[CVARS]
new wylosowanych = 0;
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	g_cvars[enable] =register_cvar("ga_enable","1")
	g_cvars[min_graczy] = register_cvar("ga_min_players", "1")
	g_cvars[czas_wyswietlania] = register_cvar("ga_time_show","20")
	g_cvars[czas_na_wpisanie] = register_cvar("ga_time_check","20.0")
	register_menucmd(register_menuid("Main Menu"), 1023, "main_menu_info")

	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	for(new i = 0;i<sizeof commands;i++){
		register_clcmd(commands[i],"handlesay")
		}
	
	if (get_pcvar_num(g_cvars[enable]) == 1){
		set_task(180.0,"advert",200,_,_,"b");
		set_task(5.0,"zacznij",1000)
	}
	//register_menucmd(register_menuid("Main Menu"), 1023, "menu_osiagniecia_handle2")
}





public advert(id){
	ColorChat(0, GREEN,"[%s] ^x01Kilka razy na mape wyswietla sie kod ktory trzeba przepisac na say. Wiecej info /giveaway",PREFIX)
}

public zacznij(id)
{	
	if(wylosowanych >= liczba_losowan)
	{
		set_hudmessage(255, 255, 255, 0.57, 0.51, 0, 6.0, 8.0,0.0,0.0,2)
		show_hudmessage(0,"To byl ostatni kod!.Na nastepnej mapie nowe kody!")
		return PLUGIN_HANDLED
	}
	set_task(random_float(25.0,35.0),"losuj",1337+TASK_LOSUJ)
	//server_print("%s %s",VIP3D,VIP7D)
	return PLUGIN_CONTINUE
	
}

public losuj(id)
{	
	
	if (get_pcvar_num(g_cvars[enable]) != 1)
		return PLUGIN_HANDLED
	if(get_pcvar_num(g_cvars[min_graczy]) > players_num()){
		ColorChat(0,GREEN,"[%s] ^x01Za mala liczba graczy. Musi byc min ^x04%d ^x01graczy. Losowanie przepada ",PREFIX,get_pcvar_num(g_cvars[min_graczy]))
		wylosowanych++
		zacznij(id)
	}
	else {	
		new temp;
		text[0] = 47
		//new iLen=0, iMax=sizeof(text) - 1
		for(new i = 1 ; i<= random_num(8,10);){
			temp = random_num(48,122)
			if ((temp <= 57) || (temp >= 65 && temp <= 90 )||(temp >= 97 && temp <= 121))
			{
				text[i] = temp
				i++;
			}
			
		}
		//log_amx("udalo sie pierwsza petle przejsc")
		set_task(1.0,"wyswietl",555,_,_,"a",get_pcvar_num(g_cvars[czas_wyswietlania]))
		log_amx("%s",text)
		giveaway = true;
		wylosowanych++
		set_task(get_pcvar_float(g_cvars[czas_na_wpisanie]),"spr_gw",1337+TASK_WYSWIETL)
	}
	return PLUGIN_CONTINUE
}
public wyswietl(id)
{
	for (new g = 1 ; g <=32;g++){
			if(!is_user_connected(g)) 
				continue
			
			set_hudmessage(255, 255, 255, 0.57, 0.51, 0, 6.0, 1.0,0.0,0.0,2)
			show_hudmessage(g,"^tGIVEWAY!^n PRZEPISZ KOD NA SAY :^n %s",text)
		}
}
public handlesay (id,level,cid)
{	
	
	
	new msg[192]
	read_args(msg,191)
	remove_quotes(msg)
	if(equali("/giveaway",msg))
	{
		show_main_menu_info(id)
		return PLUGIN_CONTINUE
			
	}
	if(equali("/los",msg) && osc[id])
	{
		osiagniecie(id)
		return PLUGIN_CONTINUE
			
	}
	if (equali(msg,"/",1) && giveaway && !equali(msg,"/konto") && !equali(msg,"/daj",4) && !equali(msg,"/lm")&& !equali(msg,"/bank") && !equali(msg,"/permute") && !equali(msg,"/mute") )
	{	
		if (equal(msg,text))
		{ 	
			
			get_user_name(id,name,sizeof(name))
			ColorChat(0,GREEN,"[%s] ^x03%s ^x01jako pierwszy poprawnie wpisal kod. ^x04Gratulacje",PREFIX,name)
			giveaway = false 
			ColorChat(0,GREEN,"[%s] ^x01Za chwile zostanie wylosowana nagroda dla zwyciezcy:)",PREFIX)
			if(task_exists(1337+TASK_WYSWIETL))
				remove_task(1337+TASK_WYSWIETL)
			if(task_exists(555))
				remove_task(555)
			set_hudmessage(255, 255, 255, 0.57, 0.51, 0, 6.0, 1.0,0.0,0.0,2)
			show_hudmessage(0," ")
			set_task(2.0, "Losuj_nagrode",id+TASK_NAGRODA)
			zacznij(id)
		}
		else ColorChat(id, GREEN,"[%s] ^x01 Zle wpisales kod",PREFIX)
		
	}
	return PLUGIN_CONTINUE
}

public spr_gw(id){
	giveaway = false 
	
	set_hudmessage(255, 200, 255, -1.0, 0.45, 0, 6.0, 4.0)
	show_hudmessage(0, "Kod przepada! ^n Nie udalo sie ^n wam przepisac kodu ^n Sprobujcie nastepnym razem")
	zacznij(id)
}




// LOSOWANIE NAGRODY
public Losuj_nagrode(id)
{
	
	
	id -= TASK_NAGRODA
	new Los = random_num(1,1000)
	new amount
	for (new i=0; i < sizeof(percent);i++){
		amount +=  percent[i]
		if(Los <= amount)
		{
			wygrana(id,i)
			return PLUGIN_CONTINUE
		}
	}
	return PLUGIN_CONTINUE

}
public wygrana(id,numer)
{
	switch(numer)
	{
		case 0: {
			lvl(id)
		}

		case 1:
		{
			new czas = 7
			vip(id,czas)
		}

		case 2: 
		{
			new czas = 3
			vip(id,czas)
		}

		case 4:	
		{
			exp(id, 1000,2000)
		}

		case 5:	
		{
			ap(id, 100,300)
		}

		case 7:	
		{
			exp(id, 2000,4000)
		}

		case 8:	
		{
			ap(id, 300,600)
		}

		case 10:
		{
			ColorChat(id,GREEN,"[%s] ^x01 Wylosowales pominiecie wybranego osiagniecia o 1 stopien.",PREFIX)
			ColorChat(0,GREEN,"[%s] ^x01  %s Wylosowal pominiecie wybranego osiagniecia o 1 stopien.",PREFIX,name)
			ColorChat(id,GREEN,"[%s] ^x01 Wpisz /los aby wybrac ktore osiagniecie pominac. Mozesz to zrobic tylko na tej mapie, wiec sie spiesz!",PREFIX)
			osc[id] = true		
		}

		case 11:
		{
			powieksz_bank(id)
			ColorChat(id,GREEN,"[%s] ^x01  Wylosowales powiekszenie banku o 100AP",PREFIX)
			ColorChat(0,GREEN,"[%s] ^x01  %s Wylosowales powiekszenie banku o 100AP",PREFIX,name)
		}

		case 13:
		{
			exp(id, 4000,6000)
		}

		case 14:
		{
			ap(id, 600,900)
		}

		case 16:
		{
			ColorChat(id,GREEN,"[%s] ^x01 Wylosowales 5%% dmg wiecej!",PREFIX)
			ColorChat(id,GREEN,"[%s] ^x01  %s Wylosowal 5%% dmg wiecej!",PREFIX,name)
			dmg[id] = true
		}		
		case 17:
		{
			bonus(id,100,150)
		}
		case 19:
		{
			bonus(id,50,100)
		}
		case 3,6,9,12,15,18:
		{
			ColorChat(id,GREEN,"[%s] ^x01 Oj przykro nam lecz twoj los byl pusty :C Sprobuj nastepnym razem :)",PREFIX)
			ColorChat(0,GREEN,"[%s] ^x01 %s wylosowal pusty los :C ",PREFIX, name)
			
		}
	}

}

public osiagniecie(id)
{	
	new menu = menu_create("\yMenu \rOsiagniec","menu_osiagniec_handle")
	new formats[192]
	new data2[15]
	
	for(new i = 0;i<LICZBA_OSIAGNIEC;i++)
	{
		if(load_stat(id,i) < 5)
			formatex(formats,sizeof formats,"\w%s (%d/5)", osiagniecia[i],load_stat(id,i));
		else {
			continue
		}
		num_to_str(i,data2,sizeof(data2))
		menu_additem(menu,formats,data2,0);
	}
	menu_display(id,menu)
}

public menu_osiagniec_handle(id,menu,item)
{		
	
	
	menu_item_getinfo(menu, item, dostep, data, 15, name, 31, callback);
	if (item == MENU_EXIT)
		return;
	
	new item_id ;
	item_id = str_to_num(data)
	server_print("%i",item_id)
	add_achieve(id,item_id)
	osc[id] = false
	
}
public lvl(id)
{
	new level = get_user_level(id)
	if(level >=95) 
		return
	set_user_xp(id, get_user_max_level(id))
	set_user_level(id,level+1)
	
	ColorChat(id, GREEN,"[%s] ^x01 Gratulacje wygrales pominiecie lvl przez co wbijasz nastepny poziom!",PREFIX)
	ColorChat(0, GREEN,"[%s] ^x01 %s Wygral pominiecie lvl przez co wbija nastepny poziom!",PREFIX,name)		
	new name[33],ip[33],steamid[33]
	get_user_name(id,name,32)
	get_user_ip(id,ip,32)
	get_user_authid(id,steamid,32)
	log_to_file(FILE,"Gracz %s <%s> <%s> wylosowal pominiecie lvl. Stary lvl : %i Nowy lvl %i",name,ip,steamid,level,level+1)
	
}
public bonus(id,minap,maxap)
{
	
	new temp = random_num(minap, maxap)
	ColorChat(id, GREEN,"[%s] ^x01 Gratulacje wygrales losowa ilosc bonusow z przedzialu (%d-%d) :  %d bonusow",PREFIX,minap,maxap,temp)
	ColorChat(0, GREEN,"[%s] ^x01 %s Wygral %d bonusow",PREFIX,name,temp)
	zp_bonus_set(id,zp_bonus_get(id) + temp)
	new name[33]
	get_user_name(id,name,32)
	
	log_to_file(FILE,"Gracz %s wylosowal %i bonusow",name,temp)
}
public ap(id,minap,maxap)
{
	
	new temp = random_num(minap, maxap)
	ColorChat(id, GREEN,"[%s] ^x01 Gratulacje wygrales losowa ilosc ap z przedzialu (%d-%d) :  %d ap",PREFIX,minap,maxap,temp)
	
	zp_ammopacks_set(id,zp_ammopacks_get(id) + temp)
	new name[33]
	get_user_name(id,name,32)
	ColorChat(0, GREEN,"[%s] ^x01 %s Wygral %d ap",PREFIX,name,temp)
	log_to_file(FILE,"Gracz %s wylosowal %i ap",name,temp)
}
public exp(id,minexp,maxexp)
{
	
	new temp = random_num(minexp, maxexp)
	ColorChat(id, GREEN,"[%s] ^x01 Gratulacje wygrales losowa ilosc exp z przedzialu (%d-%d) :  %d expa",PREFIX,minexp,maxexp,temp)
	set_user_xp(id,get_user_xp(id) + temp)
	new name[33]
	get_user_name(id,name,32)
	ColorChat(0, GREEN,"[%s] ^x01 %s Wygral %d exp",PREFIX,name,temp)
	log_to_file(FILE,"Gracz %s wylosowal %i exp",name,temp)
}
public show_main_menu_info(id)
{
	static menu[510], iLen;
	iLen = 0;
    
	new xKeys3 = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2;

    
	iLen += formatex(menu[iLen], sizeof menu - 1 - iLen, "\yGIVE AWAY \wMenu ^n^n")
	iLen += formatex(menu[iLen], sizeof menu - 1 - iLen, "\r1. \wInformacje ^n")
	iLen += formatex(menu[iLen], sizeof menu - 1 - iLen, "\r2. \wNagrody ")
	iLen += formatex(menu[iLen], sizeof menu - 1 - iLen, "^n^n\r0. \wWyjscie")
	
	show_menu(id, xKeys3, menu, -1, "Main Menu")
}
public main_menu_info(id, key)
{
	switch (key)
	{
		case 0:
		{	
			show_motd(id,"aaaaaaa","GiveAway - OPIS")
			show_main_menu_info(id)
			
			
		}
		case 1:
		{
			show_motd(id,"aaaaaa","GiveAway - Nagrody")	
			show_main_menu_info(id)
			
		}
		
		case 9:
		{	
			
			return PLUGIN_HANDLED;
		}
	}

	return PLUGIN_HANDLED;
}


public players_num(){
	new liczba= 0;
	for(new i=1; i < 33; i++)
	{
		
		if(is_user_bot(i) || is_user_hltv(i) || !is_user_connected(i))
			continue;	
		liczba++;
	}
	return liczba
}

public losuj_kod()
{
	new temp;
	new temp_text[8]
	for(new i = 0 ; i<8;){
		temp = random_num(48,122)
		if ((temp <= 57) || (temp >= 65 && temp <= 90 )||(temp >= 97 && temp <= 121))
		{
			temp_text[i] = temp
			i++;
		}
	}
	return temp_text
}
public vip (id,czas)
{
		new kod[8]
		new name[33],ip[33],steamid[33]
		get_user_name(id,name,32)
		get_user_ip(id,ip,32)
		get_user_authid(id,steamid,32)
		formatex(kod,sizeof(kod),"%s",losuj_kod())
		ColorChat(0, GREEN,"[%s] ^x01 %s wygral vipa na %d dni!",PREFIX,name,czas)
		ColorChat(id, GREEN,"[%s] ^x01 Gratulacje wygrales vipa na %d dni!",PREFIX,czas)
		ColorChat(id, GREEN,"[%s] ^x01 Zglos sie na forum %s do opiekunow serwera z tym kodem : %s",PREFIX,FORUM,kod)
		ColorChat(id, GREEN,"[%s] ^x01 Opiekunami serwara sa %s (Skopiuj kod z konsoli i wyslij go opiekunom serwera na pw)",PREFIX,OPIEKUNOWIE)
		set_hudmessage(255, 255, 255, -1.0, 0.45, 0, 6.0, 7.0)
		show_hudmessage(id, "Wygrales vip na %d dni.^n Zglos sie z tym kodem %s na forum do opiekuna.^n Kod masz wygenerowany na say oraz w konsoli ^n",czas,kod)
		console_print(id, "=====================================")
		console_print(id, " [%s]  Gratulacje wygrales vipa na %d dni!",PREFIX,czas)
		console_print(id, " [%s]  Zglos sie na forum %s do opiekunow serwera z tym kodem : %s",PREFIX,FORUM,kod)
		console_print(id, " [%s]  Opiekunami serwara sa %s (Skopiuj kod i wyslij go opiekunom serwera na pw)",PREFIX,OPIEKUNOWIE)
		console_print(id, "=====================================")
		

		log_to_file(FILE,"Gracz %s <%s> <%s> wyloswal vipa na %d dni. Kod : %s",name,ip,steamid,czas,kod)

}
public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_alive(this) || !is_user_connected(this) || !is_user_connected(idattacker) || get_user_team(this) == get_user_team(idattacker))
		return HAM_IGNORED;
	
	if(dmg[idattacker])
	{
		damage *= 1.05
	}
		
	SetHamParamFloat(4, damage);
	return HAM_IGNORED;	
		
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ ansicpg1250\\ deff0\\ deflang1045{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ f0\\ fs16 \n\\ par }
*/