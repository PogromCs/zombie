#include <amxmodx>
#include <amxmisc>
#include <nvault>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <zp50_core>
#include <zp50_class_human>
#include <zp50_class_zombie>
#include <zp50_class_nemesis>
#include <zp50_class_survivor>
#include <zp50_class_assassin>
#include <zp50_class_sniper>
#include <zp50_class_lowca>
#include <zp50_gamemodes>
#include <zp50_ammopacks>
#include <dhudmessage>
#include <engine>

native get_user_level(id);
native get_user_xp(id);
native set_user_xp(id, amount);
native daj_bazooke(id);
native daj_miny(id, ile);
native nat_wczytalo(id);
native daj_pkt_rank(id, ile);

new vault_questy;
new vault_questy2;

new quest_gracza[33];
new ile_juz[33];
new ile_wykonano[33] = 0;
new questy_akt[33];
new zadanie_do_wykonania[33];
new Float:dodatkowa_redukcja[33];
new Float:dodatkowe_obrazenia[33];

//say hud
new gmsgStatusText;

new g_pointer

new ilosc_graczy
new g_min_graczy
new wczytalo[33];


enum { brak = 0, //0
zabic_zm = 1, //1
zabic_hm, //2
zarazic_hm, //3
zabic_nemki, //4
zabic_survy, //5
zabic_snipery, //6
zabic_assassiny, //7
zadac_dmg, //8
zadac_dmg_nemkom,//9 
zadac_dmg_survom, //10
zadac_dmg_assassinom, //11
zadac_dmg_sniperom, //12
zabic_hs, //13
przetrwac_rundy_hm, //14
przetrwac_rundy_pz_hm, //15
wygrac_rundy_jako_nemesis, //16
wygrac_rundy_jako_surv, //17
wygrac_rundy_jako_assassin, //18
wygrac_rundy_jako_sniper, //19
zebrac_ap, //20
zabic_nemki_jako_survy, //21
zabic_survy_jako_nemki, //22
zabic_bosa, //23
zabic_zombie_nozem,//24 
zdobyc_nemka, //25
zdobyc_surva, //26
zdobyc_assassina,//27
zdobyc_snipera, //28
zabic_matki, //29
zabic_ostatnich_ludzi, //30
rozegrac_rundy, //31
zarazic_w_jednej_rundzie, //32
wygrac_rundy_zm, //33
zabic_jako_surv, //34
zabic_jako_nemek, //35
zabic_jako_assassin, //36
zabic_jako_sniper, //37
zabic_mina, //38
zabic_bazooka, //39
zabic_pipa, //40
zarazic_bomba, //41
uleczyc_bomba, //42
zniszczyc_laserminy, //43
wygrac_swarm_jako_hm, //44
wygrac_swarm_jako_zm, //45
wygrac_plage_jako_hm,//46
wygrac_plage_jako_zm, //47
wygrac_armagedon_jako_hm, //48
wygrac_armagedon_jako_zm, //49
wygrac_starcie_z_nemesisem, //50
wygrac_starcie_z_survivorem,//51
wygrac_starcie_ze_sniperem, //52
wygrac_starcie_z_assassynem, //53
zdobyc_info, //54
zabic_w_jednej_rundzie, //55
zabic_ostatnich_zombi,   //56
zabic_lowce //57
}; 

//			tytul									opis																				opis dodatkowy									nagorda								hud
new const q_info[55][5][]={
    //Akt I
   
    { "Witaj",                          		"Witaj Lowco! Na poczatek rozegraj z nami 5 rund",          	"Rozegraj 5 rund aby ukonczyc zadanie",                   	 											"150 Expa",                     			"Rozegraj Rundy"},
    { "Zapasy",                         		"Zdobadz 15 AP",                                             	"AP zdobywasz atakujac/zabijajac wrogow",                   											"+10 HP dla Humana",            			"Zdobadz AP"},
    { "Trening Strzelecki",            			"Pocwicz celnosc. Zadaj 10000 DMG",                         	"",                                                         											"25 AP",                        			"Zadaj DMG"},
    { "Pierwsze Polowanie",             		"Zabij 25 Zombi z broni palnej",                              	"Zabij Zombi, Nemesis lub Assassyna aby zakonczyc zadanie", 											"+1 AP na start",               			"Zabij Zombi"},
    { "Najlepsi",                       		"Aby ukonczyc ten akt Zabij gracza z min. 10 poziomem",       	"",                                                         											"500 Expa, 20 AP",              			"Zabij min. 10 Poziom"},
    
	//Akt II
   
    { "Potrzebujemy Wiecej Mozgow",    			"Powieksz nasza armie do niewyobrazalnych rozmiarow",        	"Zaraz 35 ludzi",                                           											"+50 HP dla Zombi",             			"Zaraz Ludzi"},
    { "Opanowac Swiat",                 		"Zniszcz rase ludzka",                                       	"Wygraj jako Zombi 25 rund",                                											"400 Expa, 25 AP",             		 		"Wygraj Rundy jako ZM"},
    { "Przez Okopy",                    		"Zniszcz 20 LM'ow",               								"Zniszczysz LM'a gdy bedziesz go bil",                      											"3% redukcji obrazen dla Zombi",			"Zniszcz LM'y"},
    { "Zabic Wszystkich",               		"Zabij 20 Ludzi",                                      			"Zabic, nie zarazic!",                                      											"+5 do predkosci dla Zombi",    			"Zabij Ludzi"},
    { "Ludzka Potega",                  		"Aby ukonczyc ten Akt zadaj 1000 DMG Survivorowi",        		"Survivor to ten niebieski z Krowa",                        											"2000 Expa, 30 AP",             			"Zadaj DMG Survivorowi"},
    
	//Akt III
    
	{ "Wytrwac!!!",                     		"Przetrwac 30 rund jako czlowiek",                     			"",                                                         											"+1 dodatkowa Flara",           			"Przetrwaj jako Czlowiek"},
    { "Prototyp Min",                   		"Zabij 20 Zombie za pomoca min.",                   			"Miny stawiasz za pomoca klawisz C lub bind 'klawisz' '+mina'",											"+5 Armoru dla Humana",      				"Zabij za pomoca Min"},
    { "Zaawansowany Trening",           		"Zabij 80 Zombi strzalem w glowe",                   			"Teraz bedzie troche trudniej...",                         												"3000 Expa, 50 AP",             			"Zabij za pomoca HS"},
    { "Zniszczyc Gniazdo I",            		"Znajdz 5 fragmentow mapy do kryjowki Zombi Rodzicielek",		"Masz 5% szans na znalezienie fragmentu przy wrogu",        											"+3% wiecej obrazen dla Humana",			"Znajdz fragmenty mapy"},
    { "Zniszczyc Gniazdo II",           		"Aby ukonczyc ten Akt musisz zabic 20 Matek Zombi",       		"Matka Zombi to pierwszy Zombi w rundzie",                  											"+7000 Expa",                   			"Zabij Matki Zombi"},
   
    //Akt IV
   
    { "Wiecej niz PENTA!",              		"Zaraz 7 Ludzi w jednej rundzie",                            	"Postep misji jest resetowany co runde",                    											"+100 Hp dla Zombi",            			"Zaraz Ludzi w jednej rundzie"},
    { "Ostatki I",                      		"Znajdz 5 fragmentow mapy do kryjowki Ostatnich Ludzi",      	"Masz 4% szans na znalezienie fragmentu przy wrogu",        											"5000 Expa, 70 AP",             			"Znajdz fragmenty mapy"},
    { "Ostatki II",                     		"Zabij 15 ostatnich Ludzi",         							"Ostatni czlowiek jest trudniejszy do zabicia",             											"5% szans na dodatkowy bonus co runde",		"Zabij ostatnich ludzi"},
    { "Protptyp Bomby",                 		"Zaraz bomba infekcyjna 25 Ludzi",                    			"",                                                        												"+150 AP",                      			"Zaraz za pomoca Bomby"},
    { "Mutacja",                        		"Aby ukonczyc ten Akt zdobadz Nemesisa",               			"",                                                         											"+15000 Expa",                  			"Zdobadz Nemesis'a"},
   
    //Akt V
   
    { "Ewolucja",                       		"Zdobadz Survivora",       										"Stan sie niebieska flara z poteznym DMG",                  											"+3% wiecej obrazen dla Humana",			"Zdobadz Survivora"},
    { "Nie wszystko stracone",          		"Ulecz 40 Zombi bomba antidotum",             					"Przetestuj nasze najnowsze antidotum na T-VIRUS",          											"7000 Expa, 100 AP",                		"Ulecz Bomba Antidotum"},
    { "Prototyp RPG",                  			"Ta Bazooka ladnie sieka. Zabij z niej 200 Zombi",    			"Na co nam kaliber 9mm skoro mamy 40mm?",                   											"+5 Armoru dla Humana",         			"Zabij Bazooka"},
    { "Odeprzec Atak MegaMutanta I",    		"Zdobadz 5 czesci planu ataku Nemesisa na nasza baze",    		"Masz 3% szans na zlalezienie czesci planu przy martwym wrogu",											"Lepsze bonusy do wylosowania co runde",	"Znajdz Plany"},
    { "Odeprzec Atak MegaMutanta II",   		"Wygraj Runde Nemesis Mode",         							"Aby zadanie zostalo zaliczone musisz byc zywy w momencie^nzabicia Nemka",								"25000 Expa",     							"Wygraj Nemesis Mode"},
   
    //Akt VI
  
    { "Ewolucja II",                    		"Jako Survivor zabij 20 Zombi",           						"Pokaz im kto tu rzadzi!",                                  											"+5 Armoru dla Humana",         			"Zabij Zombi jako Surv"},
    { "Atak Hordy I",                   		"Przetrwaj atak Hordy. Zabij 500 Zombi z broni palnej", 		"Tak duzej hordy jeszcze nie widziano",                     											"+1 dodatkowy Napalm",          			"Zabij Zombie"},
    { "Atak Hordy II",     						"Odeprzyj atak hordy. Przetrwaj 6 Rund pod rzad", 				"Aby ukonczyc to zadanie nie mozesz zostac^nzarazony/zabity jako czlowiek",								"+1 Armoru za zabojstwo",					"Przetrwaj rundy pod rzad"},
    { "Bron masowej zaglady",  					"Zabij 50 Zombi za pomoca PipeBomby", 							"Antidotum dziala na wybranych Zombie^nCalej reszcie pomoze PipeBomba :D",								"+1 AP co runde", 							"Zabij za pomoca PipeBomby"},
    { "Combo Mistrzow",                 		"Zabij 15 Zombi w jednej rundzie",             					"Poziom misji jest resetowany co runde",                    											"40000 Expa",                   			"Zabij Zombi w jednej rundzie"},
   
    //Akt VII

    { "Przez Okopy II",                 		"Zniszcz 50 LM'ow",            									"Za duzo zwlekalismy i teraz ludzie znow sie okopali",     	 											"+150 HP dla Zombi",            			"Zniszcz LM'y"},
    { "Wiecej Mozgow II",               		"Zaraz 100 Ludzi",                                              "Ostatni atak uszczuplil nasze sily. Powieksz nasza armie!",											"3% redukcji obrazen dla Zombi",			"Zaraz Ludzi"},
    { "Atak Hordy",                     		"Zniszcz 5 umocnionych obozow ludzkich",                        "Wygraj tryb Swarm Mode 5 razy jako Zombi",                 											"20000 Expa, 150 AP",           			"Wygraj SwarmMode"},
    { "Potega Mutacji I",               		"Wygraj jako Zombi 50 rund",                                    "Poprowadz nasza armie do zwyciestwa i udowodnij^n ze jestes gotowy na najwyzsza mutacje",				"+5 do predkosci dla Zombi, 200 AP",  		"Wygraj Rundy jako Zombi"},
    { "Potega Mutacji II",             			"Zdobadz Assasina 3 razy",                                      "W tej formie juz nikt cie nie pokana!",                    											"30000 Expa",                   			"Zdobadz Assasina"},
    
	//Akt VIII

    { "Bronic cywilow",                 		"Obron 5 naszym placowek przez Zombie",        					"Wygraj tryb Swarm Mode 5 razy jako Czlowiek",             												"+5 Armoru dla Humana",         			"Wygraj SwarmMode"},
    { "Minowanko",                      		"Zabij 50 Zombi za pomoca min",                					"Zabezpiecz Placowki przed atakiem Zombi",                  											"+1 dodatkowy FrostNade",       			"Zabij Mina"},
    { "Starcie Tytanow",                		"Zabij 5 Nemesis jako Survivor",               	 				"Najlepsi na najlepszych",                                  											"30000 Expa, 150 AP",           			"Wygraj SwarmMode"},
    { "Legowisko MegaMutanta I",        		"Znajdz 5 poszlak wiodace do kryjowki Nemesisa",      			"Informacje maja pomniejsze Zombi^nMasz 2% szans na znalezienie informacji przy martwym wrogu",			"+1 AP co runde",							"Odkryj Szlaki"},
    { "Legowisko MegaMutanta II",       		"Zabij Nemesis",                                                "To nie bedzie latwe^nNemesis to kawal skurwiela",          											"100000 Expa",                  			"Zabij Nemesis"},
    
	//Akt IX

    { "Przemarsz",                      		"Musimy przedrzec sie do lokalizacji docelowej",                "Przetrwaj 70 rund jako czlowiek",                         												"+5 Armoru dla Humana",         			"Przytrwaj jako Czlowiek"},
    { "Czystki I",                      		"Wytrop 5 ostatnich Zombi w docelowym obszarze",                "Masz 2% szansy na znalezienie informacji przy nartwym wrogu",											"50000 Expa, 200 AP",         				"Wytrop Zombi"},
    { "Czystki II",                     		"Zabij 20 ostatnich Zombi w docelowym obszarze",                "Ostatnie Zombie to takze Namesis oraz Assassin",           											"10% szans na dodatkowy bonus co runde",	"Zabij Ostatnich Zombi"},
    { "Ludzka Ewolucja I",              		"Przetrwaj 5 ataki najnowszego SuperMutanta Zombi",    			"Przetrwaj Starcie z Assasynem 5 razy",                     											"+20 HP dla Humana",            			"Wygraj starcie z Assasinem"},
    { "Ludzka Ewolucja II",             		"Udowodniles ze jestes najlepszy^nTeraz posiadz najwieksza moc","Zdobadz Snajpera 3 razy",                                  											"200000 Expa",                  			"Zdobadz Snajpera"},
	
	//Akt X

	{ "Rozsiej zaraze.",                        "Rozsiej zaraze w najlatwiejszy sposob rzucajec bombami.", 		"Zaraz 10 osob w jednej rundzie przy pomocy bomb",                           "200 hp", "Zarazaj bomba w jednej rundzie"},
	{ "Dobij ostatnich ocalencow.",             "Wykończ ostatnich Survivorow ktorzy oparli sie naszej zarazie.","Zabij 3x survivor",                                                                                        "50k xp i 100 ap" , "Zabij survivora"},
	{ "Pokonaj Lowcow",                     	"Zabij tych cao poluja na twoich towarzyszy",		"Zabij 3x lowce",                                                                                        "1 ap co runde" , "Zabij Lowce"},
	{ "Pokaz potege nieumarlych.",              "Pokaz ze jesteśmy trudni do zabicia i zasiej w ludziach strach przed toba.","Wygraj 3 rund jako zombie pod rzed",                                                      "+3% ABS (odporność)" , "Wygraj rundy z rzedu jako zombie "},
	{ "Pokaz swoja prawdziwa sile nieumarlych.","Pokaz nieposkromiona sile nieumarlych wyniszczajac tych marnych ludzi.",       "Zdobedź nemka 5 razy i wygraj runde",                                "", "Wygraj runde jako nemek"},

	//Akt XI
	
	{ "Pokaz sile swojego karabinu snajperskiego.","Wyposazony w karabin snajperski musisz sie obronić przed hordami zombie.","Zabij jako sniper 20 zm",                                                                             "100k xp", "Zabij zombie jako sniper"},
	{ "Odnow ludzkie krolestwo.",               "Ulecz pozostalych z zarazy by odbudować to co utracone.",		"Ulecz 100 ludzi",                                                                                           "200ap i darmowa mina co runde","Ulecz ludzi"},
	{ "Wytep nieumarle matki.",                 "Wyniszcz zaraze tam gdzie sie to zaczelo, wyniszczajac matki zombie.","zabij 50 matek",                                                                                            "30 hp", "zabij matki"},
	{ "Pokaz swoje umiejetności.",              "Pokaz ze sie ich nie boisz i jesteś wstanie bez broni palnej ich pokonać.","Zabij z noza 15 zombie",                                                                              "+3% DMG"   , "Zabij zombie za pomoca noza"},
	{ "Udowodnij ze nie czujesz strachu.",      "Pokaz prawdziwa potege ludzi ktorzy nawet bez broni zniszcza ich potezne plugastwa.","Zabij z noza 2x nemesisa", "",                                                                     "Zabij nemesisa za pomoca noza"}
/*
    { "Legowisko Smoka I",   "Znajdz 5 szlakow wiodace do kryjowki Nemesisa",  "Informacje maja pomniejsze Zombi^nMasz 2% szans na znalezienie informacji przy martwym wrogu","",          "Znajdz Informacje"},
    { "Legowisko Smoka II",             "Zabij Nemesisa z noza" Aby zakonczyc to zadanie musisz wlasnorecznie ukatrupic Nemka","",     "Zabij Nemesis"},
   
   
    */
};

new q_ile[][]={
	{1,5},
	{1,15},
	{1,10000},
	{1,25},
	{1,1},
	
	{2,35},
	{2,25},
	{2,20},
	{2,20},
	{2,1000},
	
	{3,30},
	{3,20},
	{3,80},
	{3,5},
	{3,20},
	
	{4,7},
	{4,5},
	{4,15},
	{4,25},
	{4,1},
	
	{5,1},
	{5,40},
	{5,200},
	{5,5},
	{5,1},
	
	{6,20},
	{6,500},
	{6,6},
	{6,50},
	{6,15},
	
	{7,50},
	{7,100},
	{7,5},
	{7,50},
	{7,3},
	
	{8,5},
	{8,50},
	{8,5},
	{8,5},
	{8,1},
	
	{9,70},
	{9,5},
	{9,20},
	{9,5},
	{9,3},

	{10,10},
	{10,3},
	{10,3},
	{10,3},
	{10,5},

	{11,20},
	{11,100},
	{11,30},
	{11,15},
	{11,2},
} 
/* TESTY
new q_ile[][]={
	{1,1},
	{1,1},
	{1,1},
	{1,1},
	{1,1},
	
	{2,1},
	{2,1},
	{2,1},
	{2,1},
	{2,1},
	
	{3,1},
	{3,1},
	{3,1},
	{3,1},
	{3,1},
	
	{4,1},
	{4,1},
	{4,1},
	{4,1},
	{4,1},
	
	{5,1},
	{5,1},
	{5,1},
	{5,1},
	{5,1},
	
	{6,1},
	{6,1},
	{6,1},
	{6,1},
	{6,1},
	
	{7,1},
	{7,1},
	{7,1},
	{7,1},
	{7,1},
	
	{8,1},
	{8,1},
	{8,1},
	{8,1},
	{8,1},
	
	{9,1},
	{9,1},
	{9,1},
	{9,1},
	{9,1},

	{10,2},
	{10,1},
	{10,1},
	{10,2},
	{10,1},

	{11,1},
	{11,1},
	{11,1},
	{11,1},
	{11,1},
}*/
new const przydzielone_zadanie[]={
	//akt I
	31,
	20,
	8,
	1,
	23,
	//akt II
	3,
	33,
	43,
	2,
	10,
	//akt III
	14,
	38,
	13,
	54,
	29,
	//akt IV
	32,
	54,
	30,
	41,
	25,
	//akt V
	26,
	42,
	39,
	54,
	50,
	//akt VI
	34,
	1,
	15,
	40,
	55,
	//akt VII
	43,
	3,
	45,
	33,
	27,
	//akt VIII
	44,
	38,
	21,
	54,
	4,
	//akt IX
	14,
	54,
	56,
	53,
	28,

	//akt X
	41,
	5,
	57,
	33,
	16,


	//akt XI
	37,
	42,
	29,
	24,
	4
}

new prze[][]={
	{"\wAkt I    \y[Humans]"},
	{"\wAkt II   \r[Zombies]"},
	{"\wAkt III  \y[Humans]"},
	{"\wAkt IV   \r[Zombies]"},
	{"\wAkt V  	 \y[Humans]"},
	{"\wAkt VI   \y[Humans]"},
	{"\wAkt VII  \r[Zombies]"},
	{"\wAkt VIII \y[Humans]"},
	{"\wAkt IX   \y[Humans]"},
	{"\wAkt X    \r[Zombies]"},
	{"\wAkt XI   \y[Humans]"}
}
new prze_wybrany[33]



public plugin_init() 
{
/*	new ip[40];
	get_user_ip(0, ip, 39); //Jesli id = 0 pobiera ip serwera	register_plugin(PLUGIN, VERSION, AUTHOR);
	if(!equal(ip, sIP)) //Jesli ip jest inne pod podanego	register_cvar("gxm_version", VERSION, FCVAR_SPONLY|FCVAR_SERVER)
	{
		set_fail_state("Fatal Error : Segmentation fault"); //Ustaw pluginowi status Fail/Error i przed tym wydrukuj wiadomosc w konsoli serwera	set_cvar_string("gxm_version", VERSION)
		remove_entity(32);
		message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("ScreenShake"),{0,0,0},32); 
		write_short(7<<14);
		write_short(1<<13);
		write_short(1<<14);
		message_end();
	}*/
	
	register_plugin("[ZP] Misje", "1.0 dla ZP 5.0.8", "Sniper Elite")
	
//	vault_questy = nvault_open("Questy");
//	vault_questy2 = nvault_open("Questy2");
	
	register_clcmd("say /misje","menu_questow")
	register_clcmd("say /misja","menu_questow")
	register_clcmd("say /m","menu_questow")
	//register_clcmd("say z","zwroc_all")
	
	register_event("DeathMsg", "event_deathmsg", "a");
	
	RegisterHam(Ham_Spawn, "player", "Odrodzenie", 1);
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	
	register_logevent("EventRoundEnd", 2, "1=Round_End");
	register_logevent("PoczatekRundy", 2, "1=Round_Start"); 
	
	register_event("Damage", "Damage", "b", "2!=0");
	
	gmsgStatusText = get_user_msgid("StatusText")
	register_concmd("zm_zad", "cmd_zad", ADMIN_IMMUNITY, "<name> <misja>");
	
	set_task(1.0, "say_hud", 0, _, _, "b");
	
	g_pointer = get_cvar_pointer( "min_liczba_graczy" );
	g_min_graczy = get_pcvar_num(g_pointer)
	
}

public plugin_natives()
{
					// Player natives //
	register_native("sprawdz_misje", "native_sprawdz_misje", 1);
	register_native("dodaj_ile_juz", "native_dodaj_ile_juz", 1);
	register_native("sprawdz_ile_wykonano", "native_sprawdz_ile_wykonano", 1);
	//do zapisu sql
	register_native("sprawdz_misje_sql", "native_sprawdz_misje_sql", 1);
	register_native("nadaj_misje_sql", "native_nadaj_misje_sql", 1);
	register_native("nadaj_ile_wykonano_sql", "native_nadaj_ile_wykonano_sql", 1);
	register_native("sprawdz_ile_juz_sql", "native_sprawdz_ile_juz_sql", 1);
	register_native("nadaj_ile_juz_sql", "native_nadaj_ile_juz_sql", 1);
	
	register_native("nat_menu_questow", "native_menu_questow", 1);
}

public native_sprawdz_misje(id)
{
	if(quest_gracza[id] != -1)
	{
		return przydzielone_zadanie[quest_gracza[id]]
	}
	return PLUGIN_CONTINUE;
}
public native_dodaj_ile_juz(id, ile)
{
	//if(g_min_graczy <= players_num())
	//{
		ile_juz[id] += ile
		
		if(quest_gracza[id] != -1 && ile_juz[id] >= q_ile[quest_gracza[id]][1])
			questy_nagrody(id)
	//}
	
	return PLUGIN_CONTINUE;
}
public native_sprawdz_ile_wykonano(id)
{
	return ile_wykonano[id]
}
public native_nadaj_ile_wykonano_sql(id, ile)
{
	ile_wykonano[id] = ile
	
	return PLUGIN_CONTINUE;
}
public native_sprawdz_ile_juz_sql(id)
{
	return ile_juz[id]
}
public native_nadaj_ile_juz_sql(id, ile)
{
	ile_juz[id] = ile
	
	return PLUGIN_CONTINUE;
}

public native_sprawdz_misje_sql(id)
{
	return quest_gracza[id]
}

public native_nadaj_misje_sql(id, ile)
{
	quest_gracza[id] = ile
	
	if(quest_gracza[id] > -1)
		zadanie_do_wykonania[id] = przydzielone_zadanie[quest_gracza[id]]
	
	return PLUGIN_CONTINUE;
}

public native_menu_questow(id)
{
	if(quest_gracza[id] < 0)
		menu_questow(id)
}

public say_hud(){
	new tpstring[272]
	for (new id=1; id < 33; id++) {
		if (!is_user_connected(id))
			continue;
		if(quest_gracza[id] >= 0)
			format(tpstring,271,"Misja: %s | Postep [%i/%i] [Wyk: %i]", q_info[quest_gracza[id]][4], ile_juz[id], q_ile[quest_gracza[id]][1], ile_wykonano[id])
		else format(tpstring,271,"Wpisz /m lub /misja aby podjac sie zadania!")
		
		message_begin(MSG_ONE,gmsgStatusText,{0,0,0}, id) 
		write_byte(0) 
		write_string(tpstring) 
		message_end()
		
	}
}

public questy_nagrody(id){
//	graj_zadanie_wykonane_sound(id)
	ile_wykonano[id]++;
	switch(quest_gracza[id]){
	//Akt I
		case 0:
		{
			new exp = get_user_xp(id) + 150
			set_user_xp(id, exp)
		}
		case 2:
		{
			zp_ammopacks_set(id, zp_ammopacks_get(id) + 25)
		}
		case 4:
		{
			set_user_xp(id, get_user_xp(id) + 500)
			zp_ammopacks_set(id, zp_ammopacks_get(id) + 20)
		}
		case 6:
		{
			set_user_xp(id, get_user_xp(id) + 400)
			zp_ammopacks_set(id, zp_ammopacks_get(id) + 25)
		}
		case 9:
		{
			set_user_xp(id, get_user_xp(id) + 2000)
			zp_ammopacks_set(id, zp_ammopacks_get(id) + 30)
		}
		case 12:
		{
			set_user_xp(id, get_user_xp(id) + 3000)
			zp_ammopacks_set(id, zp_ammopacks_get(id) + 50)
		}
		case 14:
		{
			set_user_xp(id, get_user_xp(id) + 7000)
		}
		case 16:
		{
			set_user_xp(id, get_user_xp(id) + 5000)
			zp_ammopacks_set(id, zp_ammopacks_get(id) + 70)
		}
		case 18:
		{
			zp_ammopacks_set(id, zp_ammopacks_get(id) + 150)
		}
		case 19:
		{
			set_user_xp(id, get_user_xp(id) + 15000)
		}
		case 21:
		{
			set_user_xp(id, get_user_xp(id) + 7000)
			zp_ammopacks_set(id, zp_ammopacks_get(id) + 100)
		}
		case 24:
		{
			set_user_xp(id, get_user_xp(id) + 25000)
		}
		case 29:
		{
			set_user_xp(id, get_user_xp(id) + 40000)
		}
		case 32:
		{
			set_user_xp(id, get_user_xp(id) + 20000)
			zp_ammopacks_set(id, zp_ammopacks_get(id) + 150)
		}
		case 33:
		{
			zp_ammopacks_set(id, zp_ammopacks_get(id) + 200)
		}
		case 34:
		{
			set_user_xp(id, get_user_xp(id) + 30000)
		}
		case 37:
		{
			set_user_xp(id, get_user_xp(id) + 30000)
			zp_ammopacks_set(id, zp_ammopacks_get(id) + 150)
		}
		case 39:
		{
			set_user_xp(id, get_user_xp(id) + 100000)
		}
		case 41:
		{
			set_user_xp(id, get_user_xp(id) + 50000)
			zp_ammopacks_set(id, zp_ammopacks_get(id) + 200)
		}
		case 44:
		{
			set_user_xp(id, get_user_xp(id) + 200000)
		}
		case 46:
		{
			set_user_xp(id,get_user_xp(id)+50000)
			zp_ammopacks_set(id, zp_ammopacks_get(id) + 100)
		}
		case 50:
		{
			set_user_xp(id,get_user_xp(id)+100000)
		
		}
		case 51:
		{
			
			zp_ammopacks_set(id, zp_ammopacks_get(id) + 200)
		}
		
	}
	zadanie_do_wykonania[id] = 0
	set_dhudmessage( 0, 250, 50, -1.0, 0.4, 0, 6.0, 10.0, 0.1, 1.5, false )
	
	new message[129]
	formatex(message, 128, "Wykonales zadanie: %s^nW nagrode otrzymujesz: %s!",q_info[quest_gracza[id]][0],q_info[quest_gracza[id]][3])
	
	show_dhudmessage( id, message)
	
	new name[48], ip[32], sid[32]
			
	get_user_name(id, name, 47)
	get_user_ip(id, ip, 31, 1)
	get_user_authid(id, sid, 31)
	log_to_file("1_misje_logi.log", "*** %s wykonal misje: %d . [%s] | IP: %s | SID: %s ***", name, quest_gracza[id],q_info[quest_gracza[id]][0], ip, sid)
	
	quest_gracza[id] = -1
	ile_juz[id] = 0;
//	zapisz_aktualny_quest(id)
//	zapisz_questa(id)

	daj_pkt_rank(id, 20)

	return PLUGIN_CONTINUE
}

public menu_questow(id){
	
	if(!nat_wczytalo(id))
	{
		client_print(id, print_chat, "Ladowanie bazy danych, sprobuj za chwile");
		return PLUGIN_HANDLED;
	}
	if(ile_wykonano[id] == 45)
		client_print(id,print_chat,"Gratulacje! Wykonales wszystkie zadania! Wiecej misji wkrotce.");
	else
	{
		if(quest_gracza[id] == -1 || quest_gracza[id] == -2)
		{
			new menu = menu_create("Menu Misji Glownych","menu_questow_handle")
			new menu_fun =menu_makecallback("mcbmenu_questow");
			new formats[128]
			for(new i = 0;i<sizeof prze;i++)
			{
				formatex(formats,127,"%s", prze[i][0]);
				menu_additem(menu,formats,"",0,menu_fun);
			}
			menu_display(id,menu,0)
		}
		else
		{
			new formats2[300]
			formatex(formats2,300,"^n[ \r%s \y]^n^n\wCel zadania: \y%s^n\wNagroda: \r%s^n^n\d%s^n^n\r0.\yWyjscie", q_info[quest_gracza[id]][0], q_info[quest_gracza[id]][1], q_info[quest_gracza[id]][3], q_info[quest_gracza[id]][2]);
			show_menu(id, MENU_KEY_0, formats2, -1, "quest_info")
		}
	}
}

public mcbmenu_questow(id, menu, item){
	if(item==1 && !(ile_wykonano[id] >= 5))
		return ITEM_DISABLED
	if(item==2 && !(ile_wykonano[id] >= 10))
		return ITEM_DISABLED
	if(item==3 && !(ile_wykonano[id] >= 15))
		return ITEM_DISABLED
	if(item==4 && !(ile_wykonano[id] >= 20))
		return ITEM_DISABLED
	if(item==5 && !(ile_wykonano[id] >= 25))
		return ITEM_DISABLED
	if(item==6 && !(ile_wykonano[id] >= 30))
		return ITEM_DISABLED
	if(item==7 && !(ile_wykonano[id] >= 35))
		return ITEM_DISABLED
	if(item==8 && !(ile_wykonano[id] >= 40))
		return ITEM_DISABLED
	if(item==9 && !(ile_wykonano[id] >= 45))
		return ITEM_DISABLED
	if(item==10 && !(ile_wykonano[id] >= 50))
		return ITEM_DISABLED
	if(item==11 && !(ile_wykonano[id] >= 55))
		return ITEM_DISABLED
	return ITEM_ENABLED;
}

public menu_questow_handle(id,menu,item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	new formats[128]
	formatex(formats,127,"%s",prze[item][0]);
	questy_akt[id]= item;
	new menu2 = menu_create(formats,"menu_questow_handle2")
	new menu2_fun=menu_makecallback("mcbmenu_questow_handle2");
	
	for(new i = 0;i<sizeof(q_ile);i++){
		if(q_ile[i][0] == item+1){
			if(i>ile_wykonano[id])
				formatex(formats,127,"\y%s \d[ ukryte ]", q_info[i][0], q_info[i][1]);
			else formatex(formats,127,"\y%s \d[ %s ]", q_info[i][0], q_info[i][1]);
			menu_additem(menu2,formats,"",0, menu2_fun)
		}
	}
	
	menu_setprop(menu2, MPROP_EXITNAME, "Wyjdz");
	menu_setprop(menu2, MPROP_BACKNAME, "Poprzednia strona");
	menu_setprop(menu2, MPROP_NEXTNAME, "Nastepna strona");
	prze_wybrany[id] = item+1;
	menu_display(id,menu2)
	return PLUGIN_CONTINUE;
}
public menu_questow_handle2(id,menu,item){
	if(item == MENU_EXIT){
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	new ile2 = 0;
	for(new i = 0;i<sizeof(q_ile);i++){
		if(q_ile[i][0] != prze_wybrany[id]){
			continue;
		}
		if(ile2 == item){
			item = i;
			break;
		}
		ile2++;
	}
	
	if(item<ile_wykonano[id]) {
		client_print(id,print_chat,"Wykonales juz to zadanie!");
		menu_questow(id)
		menu_destroy(menu);
		return PLUGIN_CONTINUE;
	}
	quest_gracza[id] = item
	ile_juz[id] = 0
	zadanie_do_wykonania[id] = przydzielone_zadanie[quest_gracza[id]]
//	zapisz_aktualny_quest(id)
//	zapisz_questa(id)
	new formats[301]
	
	formatex(formats,300,"^n[ \r%s \y]^n^n\wCel zadania: \y%s^n\wNagroda: \r%s^n^n\d%s^n^n\r0.\yWyjscie", q_info[item][0], q_info[item][1], q_info[item][3], q_info[item][2]);

	show_menu(id, MENU_KEY_0, formats, -1, "quest_info")
//	graj_zadanie_przyjete_sound(id)
	
	menu_destroy(menu);
	return PLUGIN_CONTINUE;
}

public mcbmenu_questow_handle2(id, menu, item){
	if(item<=(ile_wykonano[id] - questy_akt[id]*5))
		return ITEM_ENABLED;
	return ITEM_DISABLED
}

public zapisz_questa(id){
	new name[64];
	get_user_name(id,name,63)
	strtolower(name)
	new key[256];
	format(key,255,"questy-%s",name);
	new data[32]
	formatex(data,charsmax(data),"#%d",ile_wykonano[id]);
	nvault_set(vault_questy,key,data);
	
	return PLUGIN_CONTINUE;
}

public zapisz_aktualny_quest(id){
	
	new name[64];
	get_user_name(id,name,63)
	strtolower(name)
	new key[256];
	format(key,255,"questy-%s",name);
	new data[32]
	formatex(data,charsmax(data),"#%d#%d",quest_gracza[id]+1,ile_juz[id]);
	nvault_set(vault_questy2,key,data);
	
	return PLUGIN_CONTINUE;
}

public wczytaj_aktualny_quest(id){
	new name[64];
	get_user_name(id,name,63)
	strtolower(name)
	new key[256];
	format(key,255,"questy-%s", name);
	new data[32];
	nvault_get(vault_questy2,key,data,31);
	replace_all(data,31,"#"," ");
	new questt[32],ile[32]
	parse(data,questt,31,ile,31)
	quest_gracza[id] = str_to_num(questt)-1
	ile_juz[id] = str_to_num(ile)
	if(quest_gracza[id] >= 0)
		zadanie_do_wykonania[id] = przydzielone_zadanie[quest_gracza[id]]
		
	return str_to_num(questt)-1
}

public wczytaj_questa(id){
	new name[64];
	get_user_name(id,name,63)
	strtolower(name)
	new key[256];
	format(key,255,"questy-%s", name);
	new data[32];
	nvault_get(vault_questy,key,data,31);
	replace_all(data,31,"#"," ");
	new wykonano[32]
	parse(data,wykonano,31)
	ile_wykonano[id] = str_to_num(wykonano)
		
	return PLUGIN_CONTINUE;
}

public Odrodzenie(id)
{
	if(!is_user_alive(id) || !is_user_connected(id))
		return PLUGIN_CONTINUE;

	ilosc_graczy = players_num()

	return PLUGIN_CONTINUE;
}

public event_deathmsg()
{
	new killer = read_data(1);
	new victim = read_data(2);
	new hitplace = read_data(3);
	new weapon[64]		 
	read_data(4,weapon,63)
	trim(weapon)
	
	if(!is_user_alive(killer) || !is_user_connected(killer))
		return PLUGIN_CONTINUE;
	
	if(players_num() >= g_min_graczy && get_user_team(victim) != get_user_team(killer) && quest_gracza[killer] != -1  && quest_gracza[killer] != -2)
	{
		switch(zadanie_do_wykonania[killer])
		{
			case zabic_zm:
			{
				if(quest_gracza[killer]==53 && zp_core_is_zombie(victim))
				{	
					if(equali(weapon,"knife"))
						ile_juz[killer]++
				}
				else if(zp_core_is_zombie(victim))
				{
					ile_juz[killer]++
				}
			}
			case zabic_hm:
			{
				if(!zp_core_is_zombie(victim))
					ile_juz[killer]++
			}
			case zabic_nemki:
			{	
				if(quest_gracza[killer]==54 && zp_class_nemesis_get(victim))
				{	
					if(equali(weapon,"knife"))
						ile_juz[killer]++
				}
				else if(zp_class_nemesis_get(victim))
				{
					ile_juz[killer]++
				}
				
			}
			case zabic_survy:
			{
				if(zp_class_survivor_get(victim))
					ile_juz[killer]++
			}
			case zabic_assassiny:
			{
				if(zp_class_assassin_get(victim))
					ile_juz[killer]++
			}
			case zabic_snipery:
			{
				if(zp_class_sniper_get(victim))
					ile_juz[killer]++
			}
			case zabic_hs:
			{
				if(hitplace == HIT_HEAD)
					ile_juz[killer]++
			}
			case zabic_nemki_jako_survy:
			{
				if(zp_class_survivor_get(killer) && zp_class_nemesis_get(victim))
					ile_juz[killer]++
			}
			case zabic_survy_jako_nemki:
			{
				if(zp_class_nemesis_get(killer) && zp_class_survivor_get(victim))
					ile_juz[killer]++
			}
			case zabic_bosa:
			{
					if(get_user_level(victim) >= 10)
						ile_juz[killer]++
			}
			case zabic_zombie_nozem:
			{
				if(get_user_weapon(killer) == CSW_KNIFE && zp_core_is_zombie(victim))
					ile_juz[killer]++
			}
			case zabic_matki:
			{
				if(zp_core_is_first_zombie(victim))
					ile_juz[killer]++
			}
			case zabic_ostatnich_ludzi:
			{
				if(zp_core_is_last_human(victim) || zp_core_get_human_count() <= 0)
					ile_juz[killer]++
			}
			case zabic_jako_surv:
			{
				if(zp_class_survivor_get(killer))
					ile_juz[killer]++
			}
			case zabic_jako_nemek:
			{
				if(zp_class_nemesis_get(killer))
					ile_juz[killer]++
			}
			case zabic_jako_sniper:
			{
				if(zp_class_sniper_get(killer))
					ile_juz[killer]++
			}
			case zabic_jako_assassin:
			{
				if(zp_class_assassin_get(killer))
					ile_juz[killer]++
			}
			case zabic_w_jednej_rundzie:
			{
				if(zp_core_is_zombie(victim))
					ile_juz[killer]++
			}
			case zabic_ostatnich_zombi:
			{
				if(zp_core_is_last_zombie(victim))
					ile_juz[killer]++
			}
			case zabic_lowce:
			{
				if(zp_class_lowca_get(victim))
					ile_juz[killer]++
			}
			case zdobyc_info:
			{
				switch(quest_gracza[killer])
				{
					case 13:
					{
						if(random_num(1,100) <= 5 && zp_core_is_zombie(victim))
							ile_juz[killer]++
					}
					case 16:
					{
						if(random_num(1,100) <= 4 && !zp_core_is_zombie(victim))
							ile_juz[killer]++
					}
					case 23:
					{
						if(random_num(1,100) <= 3 && zp_core_is_zombie(victim))
							ile_juz[killer]++
					}
					case 38:
					{
						if(random_num(1,100) <= 2 && zp_core_is_zombie(victim))
							ile_juz[killer]++
					}
					case 41:
					{
						if(random_num(1,100) <= 2 && zp_core_is_zombie(victim))
							ile_juz[killer]++
					}
					
				}
			}
		}
		if(quest_gracza[killer] != -1 && ile_juz[killer] >= q_ile[quest_gracza[killer]][1])
			questy_nagrody(killer)
	}
	if(players_num() >= g_min_graczy && quest_gracza[killer] != -1  && quest_gracza[killer] != -2)
	{
		switch(zadanie_do_wykonania[victim])
		{
			case przetrwac_rundy_pz_hm:
			{
				if(!zp_core_is_zombie(victim))
					ile_juz[victim] = 0
			}
		}
	}
	if(ile_wykonano[killer] >= 28 && !zp_core_is_zombie(killer) && !zp_class_sniper_get(killer) && !zp_class_survivor_get(killer)&& !zp_class_lowca_get(killer))
	{
		new armor = get_user_armor(killer)
		
		if(armor < 100 && !zp_class_lowca_get(killer))
			set_user_armor(killer, get_user_armor(killer) + 1)
	}
	return PLUGIN_CONTINUE;
}

public Damage(id, Float:damage)
{
	new attacker = get_user_attacker(id)
	new damage = read_data(2);
	
	if(!is_user_connected(id) || !is_user_connected(attacker) || get_user_team(id) == get_user_team(attacker))
		return PLUGIN_CONTINUE;
		
	if(players_num() >= g_min_graczy)
	{
		switch(zadanie_do_wykonania[attacker])
		{
			case zadac_dmg:
			{
				ile_juz[attacker] += damage
			}
			case zadac_dmg_nemkom:
			{
				if(zp_class_nemesis_get(id))
					ile_juz[attacker] += damage
			}
			case zadac_dmg_survom:
			{
				if(zp_class_survivor_get(id))
					ile_juz[attacker] += damage
			}
			case zadac_dmg_sniperom:
			{
				if(zp_class_sniper_get(id))
					ile_juz[attacker] += damage
			}
			case zadac_dmg_assassinom:
			{
				if(zp_class_assassin_get(id))
					ile_juz[attacker] += damage
			}
		}
		if(quest_gracza[attacker] != -1 && ile_juz[attacker] >= q_ile[quest_gracza[attacker]][1])
			questy_nagrody(attacker)
	}
	
	return PLUGIN_CONTINUE;
}

public EventRoundEnd()
{
	for (new id=0; id < 33; id++) {
		if(!is_user_connected(id) || !is_user_alive(id) || players_num() < g_min_graczy)
			continue;

		if(!zp_core_is_zombie(id) && (zadanie_do_wykonania[id] == przetrwac_rundy_pz_hm || zadanie_do_wykonania[id] == przetrwac_rundy_hm))
		{
			ile_juz[id]++
			
			if(quest_gracza[id] != -1 && ile_juz[id] >= q_ile[quest_gracza[id]][1])
					questy_nagrody(id)
		}
		
		czy_wygral_runde(id)
	}
}

public czy_wygral_runde(id)
{
	
	if(zadanie_do_wykonania[id] == wygrac_rundy_zm && quest_gracza[id] == 48){
		if(zp_core_get_human_count() <= 0 && zp_core_is_zombie(id) ){
		
			ile_juz[id]++
			
		}
		else if(zp_core_is_zombie(id) && zp_core_get_human_count() > 0) {
			ile_juz[id]=0
		}
		else{
			ile_juz[id]=0
		}
	}
	else if(zadanie_do_wykonania[id] == wygrac_rundy_zm)
		if(zp_core_get_human_count() <= 0 && zp_core_is_zombie(id))
			ile_juz[id]++
		
	if(zadanie_do_wykonania[id] == wygrac_rundy_jako_nemesis)
		if(zp_core_get_human_count() <= 0 && zp_class_nemesis_get(id))
			ile_juz[id]++	

	if(zadanie_do_wykonania[id] == wygrac_rundy_jako_surv)
		if(zp_core_get_zombie_count() <= 0 && zp_class_survivor_get(id))
			ile_juz[id]++			
			
	if(zadanie_do_wykonania[id] == wygrac_rundy_jako_assassin)
		if(zp_core_get_human_count() <= 0 && zp_class_assassin_get(id))
			ile_juz[id]++	
			
	if(zadanie_do_wykonania[id] == wygrac_rundy_jako_sniper)
		if(zp_core_get_zombie_count() <= 0 && zp_class_sniper_get(id))
			ile_juz[id]++
			
	new const Swarm[] = "Swarm Mode" 
	new SwarmID = zp_gamemodes_get_id(Swarm)
	
	if(zp_gamemodes_get_current() == SwarmID)
	{
		if(zadanie_do_wykonania[id] == wygrac_swarm_jako_hm && !zp_core_is_zombie(id) && zp_core_get_zombie_count() <= 0)
			ile_juz[id]++
			
		if(zadanie_do_wykonania[id] == wygrac_swarm_jako_zm && zp_core_is_zombie(id) && zp_core_get_human_count() <= 0)
			ile_juz[id]++
	}
	
	new const Plague[] = "Plague Mode" 
	new PlagueID = zp_gamemodes_get_id(Plague)
	
	if(zp_gamemodes_get_current() == PlagueID)
	{
		if(zadanie_do_wykonania[id] == wygrac_plage_jako_hm && !zp_core_is_zombie(id) && zp_core_get_zombie_count() <= 0)
			ile_juz[id]++
			
		if(zadanie_do_wykonania[id] == wygrac_plage_jako_zm && zp_core_is_zombie(id) && zp_core_get_human_count() <= 0)
			ile_juz[id]++
	}
	
	new const Armageddon[] = "Armageddon Mode" 
	new ArmageddonID = zp_gamemodes_get_id(Armageddon)
	
	if(zp_gamemodes_get_current() == ArmageddonID)
	{
		if(zadanie_do_wykonania[id] == wygrac_armagedon_jako_hm && !zp_core_is_zombie(id) && zp_core_get_zombie_count() <= 0)
			ile_juz[id]++
			
		if(zadanie_do_wykonania[id] == wygrac_armagedon_jako_zm && zp_core_is_zombie(id) && zp_core_get_human_count() <= 0)
			ile_juz[id]++
	}
	
	new const Nemesis[] = "Nemesis Mode" 
	new NemesisID = zp_gamemodes_get_id(Nemesis)
	
	if(zp_gamemodes_get_current() == NemesisID)
	{
		if(zadanie_do_wykonania[id] == wygrac_starcie_z_nemesisem && !zp_core_is_zombie(id) && zp_core_get_zombie_count() <= 0)
			ile_juz[id]++
	}
	
	new const Survivor[] = "Survivor Mode" 
	new SurvivorID = zp_gamemodes_get_id(Survivor)
	
	if(zp_gamemodes_get_current() == SurvivorID)
	{
		if(zadanie_do_wykonania[id] == wygrac_starcie_z_survivorem && zp_core_is_zombie(id) && zp_core_get_human_count() <= 0)
			ile_juz[id]++
	}
	
	new const Assassin[] = "Assassin Mode"
	new AssassinID = zp_gamemodes_get_id(Assassin)
	
	if(zp_gamemodes_get_current() == AssassinID)
	{
		if(zadanie_do_wykonania[id] == wygrac_starcie_z_assassynem && !zp_core_is_zombie(id) && zp_core_get_zombie_count() <= 0)
			ile_juz[id]++
	}
	
	new const Sniper[] = "Sniper Mode"
	new SniperID = zp_gamemodes_get_id(Sniper)
	
	if(zp_gamemodes_get_current() == SniperID)
	{
		if(zadanie_do_wykonania[id] == wygrac_starcie_ze_sniperem && zp_core_is_zombie(id) && zp_core_get_human_count() <= 0)
			ile_juz[id]++
	}
	
	if(quest_gracza[id] != -1 && ile_juz[id] >= q_ile[quest_gracza[id]][1])
		questy_nagrody(id)
}

public zp_fw_gamemodes_start(mode_id)
{
	set_task ( 2.0, "Sprawdz_mutacje")
}

public Sprawdz_mutacje()
{
	for (new id=0; id < 33; id++)
	{
		if(players_num() >= g_min_graczy)
		{
			if(quest_gracza[id] != -1)
			{
				switch(zadanie_do_wykonania[id])
				{
					case zdobyc_nemka:
					{
						if(zp_class_nemesis_get(id))
							ile_juz[id]++;
					}
					case zdobyc_surva:
					{
						if(zp_class_survivor_get(id))
							ile_juz[id]++;
					}
					case zdobyc_assassina:
					{
						if(zp_class_assassin_get(id))
							ile_juz[id]++;
					}
					case zdobyc_snipera:
					{
						if(zp_class_sniper_get(id))
							ile_juz[id]++;
					}
				}
				if(ile_juz[id] >= q_ile[quest_gracza[id]][1])
					questy_nagrody(id)
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public zp_fw_core_infect(id, attacker)
{
	if(players_num() >= g_min_graczy && is_user_connected(id) && is_user_connected(attacker) && get_user_team(id) != get_user_team(attacker)){
		if(quest_gracza[attacker] != -1) {
			switch(zadanie_do_wykonania[attacker])
			{
				case zarazic_hm, zarazic_w_jednej_rundzie:
				{
					if(zp_core_is_zombie(attacker))
					{
						ile_juz[attacker]++
					}
				}
				case zdobyc_info:
				{
					switch(quest_gracza[attacker])
					{
						case 16:
						{
							if(random_num(1,100) <= 4)
								ile_juz[attacker]++
						}
					}
				}
			}
			if(quest_gracza[attacker] != -1 && ile_juz[attacker] >= q_ile[quest_gracza[attacker]][1])
				questy_nagrody(attacker)
		}
	}
	
	return PLUGIN_CONTINUE;
}

public cmd_zad(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3))
	return PLUGIN_HANDLED;
	new arg1[33];
	new arg2[10];
	read_argv(1,arg1,32);
	read_argv(2,arg2,9);
	new player = cmd_target(id, arg1, 0);
	remove_quotes(arg2);
	new quest = str_to_num(arg2);
	quest_gracza[player] = quest;
	ile_wykonano[id] = quest_gracza[player]
	zadanie_do_wykonania[player] = przydzielone_zadanie[quest_gracza[player]]
	ile_juz[player] = 0;
//	zapisz_questa(id)
//	zapisz_aktualny_quest(id)
	return PLUGIN_HANDLED;
}
public PoczatekRundy()	
{	
	
	for(new id=0;id<=32;id++)
	{	
		client_print(id,print_chat,"%i",quest_gracza[id])
		if(zadanie_do_wykonania[id] == rozegrac_rundy && players_num() >= g_min_graczy)
		{
			ile_juz[id]++
			
			if(quest_gracza[id] != -1 && ile_juz[id] >= q_ile[quest_gracza[id]][1])
				questy_nagrody(id)
		}
		if((zadanie_do_wykonania[id] == zarazic_w_jednej_rundzie || zadanie_do_wykonania[id] == zabic_w_jednej_rundzie || (zadanie_do_wykonania[id] == zarazic_bomba && quest_gracza[id] == 45 )) && players_num() >= g_min_graczy)
		{
			ile_juz[id] = 0
		}
		if(ile_wykonano[id]>=48)
			zp_ammopacks_set(id, zp_ammopacks_get(id) + 3)
		else if(ile_wykonano[id] >= 38)
			zp_ammopacks_set(id, zp_ammopacks_get(id) + 2)
		else if(ile_wykonano[id] >= 29)
			zp_ammopacks_set(id, zp_ammopacks_get(id) + 1)
		
		if(ile_wykonano[id] >= 42)
		{
			if(random_num(1,100) <= 10)
			{
				set_hudmessage( 200, 0, 0, 0.05, 0.69, 2, 0.02, 6.0, 0.01, 0.1, 3);
				if(ile_wykonano[id] >= 24)
				{
					switch(random_num(1,5))
					{
						case 1:
						{
							zp_ammopacks_set(id, zp_ammopacks_get(id) + 5)
							show_dhudmessage(id, "Premia rundy: +5 AP")
						}
						case 2:
						{
							set_user_armor(id, get_user_armor(id) + 100)
							show_dhudmessage(id, "Premia rundy: +100 Armoru")
						}
						case 3:
						{
							cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
							cs_set_user_bpammo(id, CSW_HEGRENADE, 2)
							cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 2)
							show_dhudmessage(id, "Premia rundy: Dodatkowy Pakiet Granatow")
						}
						case 4:
						{
							daj_bazooke(id)
							show_dhudmessage(id, "Premia rundy: Darmowa Bazooka")
						}
						case 5:
						{
							daj_miny(id, 3)
							show_dhudmessage(id, "Premia rundy: +3 Miny")
						}
					}
				}
				else
				{
					switch(random_num(1,3))
					{
						case 1:
						{
							zp_ammopacks_set(id, zp_ammopacks_get(id) + 5)
							show_dhudmessage(id, "Premia rundy: +5 AP")
						}
						case 2:
						{
							set_user_armor(id, get_user_armor(id) + 100)
							show_dhudmessage(id, "Premia rundy: +100 Armoru")
						}
						case 3:
						{
							cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
							cs_set_user_bpammo(id, CSW_HEGRENADE, 2)
							cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 2)
							show_dhudmessage(id, "Premia rundy: Dodatkowy Pakiet Granatow")
						}
					}
				}
			}
		}	
		else if(ile_wykonano[id] >= 18)
		{
			if(random_num(1,100) <= 5)
			{
				set_hudmessage( 200, 0, 0, 0.05, 0.69, 2, 0.02, 6.0, 0.01, 0.1, 3);
				if(ile_wykonano[id] >= 24)
				{
					switch(random_num(1,5))
					{
						case 1:
						{
							zp_ammopacks_set(id, zp_ammopacks_get(id) + 5)
							show_dhudmessage(id, "Premia rundy: +5 AP")
						}
						case 2:
						{
							set_user_armor(id, get_user_armor(id) + 100)
							show_dhudmessage(id, "Premia rundy: +100 Armoru")
						}
						case 3:
						{
							cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
							cs_set_user_bpammo(id, CSW_HEGRENADE, 2)
							cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 2)
							show_dhudmessage(id, "Premia rundy: Dodatkowy Pakiet Granatow")
						}
						case 4:
						{
							daj_bazooke(id)
							show_dhudmessage(id, "Premia rundy: Darmowa Bazooka")
						}
						case 5:
						{
							daj_miny(id, 3)
							show_dhudmessage(id, "Premia rundy: +3 Miny")
						}
					}
				}
				else
				{
					switch(random_num(1,3))
					{
						case 1:
						{
							zp_ammopacks_set(id, zp_ammopacks_get(id) + 5)
							show_dhudmessage(id, "Premia rundy: +5 AP")
						}
						case 2:
						{
							set_user_armor(id, get_user_armor(id) + 100)
							show_dhudmessage(id, "Premia rundy: +100 Armoru")
						}
						case 3:
						{
							cs_set_user_bpammo(id, CSW_FLASHBANG, 2)
							cs_set_user_bpammo(id, CSW_HEGRENADE, 2)
							cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 2)
							show_dhudmessage(id, "Premia rundy: Dodatkowy Pakiet Granatow")
						}
					}
				}
			}
		}
//		if(quest_gracza[id] == -1 || quest_gracza[id] == -2)
//			menu_questow(id)
	}
}

public plugin_end()
{
	//Close the vault when the plugin ends (map change\server shutdown\restart)
//	for(new id; id <= 32; id++) {
//		zapisz_questa(id)
//		zapisz_aktualny_quest(id)
//	}
//	nvault_close(vault_questy)
//	nvault_close(vault_questy2)
}

public client_connect(id)
{
	quest_gracza[id] = -1
/*	wczytaj_aktualny_quest(id)
	wczytaj_questa(id)
	quest_gracza[id] = wczytaj_aktualny_quest(id)*/
	wczytalo[id] = 0
}

public client_putinserver(id)
{
//	wczytaj_aktualny_quest(id)
//	wczytaj_questa(id)
//	quest_gracza[id] = wczytaj_aktualny_quest(id)
	wczytalo[id] = 1
}

public client_disconnect(id)
{
//	if(wczytalo[id] == 1)
//	{
//		zapisz_aktualny_quest(id)
//		zapisz_questa(id)
//	}
}

public zwroc_all(id)
{
	client_print(id, print_chat, "quest_gracza = %i, zadanie_do_wykonania = %i, wartosc_elementu_tablicy = %i", quest_gracza[id], zadanie_do_wykonania[id], przydzielone_zadanie[quest_gracza[id]])
	client_print(id, print_chat, "Nemek %i, Surv %i, Assassin %i, Sniper %i", zp_class_nemesis_get(id), zp_class_survivor_get(id), zp_class_assassin_get(id), zp_class_sniper_get(id))
}

public zp_fw_core_spawn_post(id)
{
	set_task(1.0, "Bonusy", id);
}

public Bonusy(id)
{
	new dodatkowe_hp = 0
	dodatkowa_redukcja[id] = 0.0
	dodatkowe_obrazenia[id] = 0.0
	if(zp_core_is_zombie(id))
	{
		new dodatkowa_predkosc
		
		if(ile_wykonano[id] >= 6)
			dodatkowe_hp += 50
		
		if(ile_wykonano[id] >= 16)
			dodatkowe_hp += 100
		
		if(ile_wykonano[id] >= 30)
			dodatkowe_hp += 150
		if(ile_wykonano[id] >= 46)
			dodatkowe_hp += 200
		if(ile_wykonano[id] >= 9)
			dodatkowa_predkosc += 5
			
		if(ile_wykonano[id] >= 8)
			dodatkowa_redukcja[id] += 0.03
			
		if(ile_wykonano[id] >= 31)
			dodatkowa_redukcja[id] += 0.03
		if(ile_wykonano[id] >= 49)
			dodatkowa_redukcja[id] += 0.03	
		if(dodatkowa_predkosc > 0)
			set_user_maxspeed(id, get_user_maxspeed(id) + dodatkowa_predkosc)
	}
	
	else
	{
		new dodatkowy_armor = 0;
		
		if(ile_wykonano[id] >= 2)
			dodatkowe_hp += 10
			
		if(ile_wykonano[id] >= 43)
			dodatkowe_hp += 20
		if(ile_wykonano[id] >= 53)
			dodatkowe_hp += 30	
		if(ile_wykonano[id] >= 12)
			dodatkowy_armor += 5
			
		if(ile_wykonano[id] >= 23)
			dodatkowy_armor += 5
			
		if(ile_wykonano[id] >= 26)
			dodatkowy_armor += 5
			
		if(ile_wykonano[id] >= 33)
			dodatkowy_armor += 5
			
		if(ile_wykonano[id] >= 35)
			dodatkowy_armor += 5
			
		if(ile_wykonano[id] >= 40)
			dodatkowy_armor += 5
			
		if(ile_wykonano[id] >= 14)
			dodatkowe_obrazenia[id] += 0.03
			
		if(ile_wykonano[id] >= 21)
			dodatkowe_obrazenia[id] += 0.03
		if(ile_wykonano[id] >= 54)
			dodatkowe_obrazenia[id] += 0.03	
		if(dodatkowy_armor > 0 &&!zp_class_lowca_get(id))
			set_user_armor(id, get_user_armor(id) + dodatkowy_armor)
		if(ile_wykonano[id] >=51)
		{
			daj_miny(id,1)
		}
	}
	if(dodatkowe_hp > 0)
		set_user_health(id, get_user_health(id) + dodatkowe_hp)
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_alive(this) || !is_user_connected(this) || !is_user_connected(idattacker) || get_user_team(this) == get_user_team(idattacker))
		return HAM_IGNORED;
	
	if(zp_core_is_zombie(this) && dodatkowa_redukcja[this] > 0)
		damage -= damage * dodatkowa_redukcja[this]
		
	if(!zp_core_is_zombie(this) && dodatkowe_obrazenia[idattacker] > 0)
		damage += damage * dodatkowe_obrazenia[idattacker]
		
	SetHamParamFloat(4, damage);
	return HAM_IGNORED;	
		
}
public players_num(){
    new liczba= 0;
    for(new i=1; i < 33; i++)
    {

        if(is_user_bot(i) || is_user_hltv(i) || !is_user_connected(i))
            continue;
        new CsTeams:team = cs_get_user_team(i)
        if(team == CS_TEAM_SPECTATOR && team == CS_TEAM_UNASSIGNED)
            continue
        liczba++;
    }
    return 16
}