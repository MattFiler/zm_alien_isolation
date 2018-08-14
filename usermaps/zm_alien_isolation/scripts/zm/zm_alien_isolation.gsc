///////////////////////////////////////
//////  ALIEN ISOLATION ZOMBIES  //////
//////     SERVER-SIDE SCRIPT    //////
///////////////////////////////////////

//Core scripts & resources
#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;
#using scripts\shared\ai\zombie_utility;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;

//Extras from error file
#using scripts\zm\gametypes\_zm_gametype;
#using scripts\zm\gametypes\_globallogic_spawn;
#using scripts\zm\gametypes\_globallogic_ui;
#using scripts\zm\gametypes\_globallogic_player;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\audio_shared;

//Traps
#using scripts\zm\_zm_trap_electric;

//Gotta buy stuff
#using scripts\zm\_zm_score;

//Usermap
#using scripts\zm\zm_usermap;

//Extras
#using scripts\shared\ai\zombie_death;
#using scripts\shared\lui_shared;
#using scripts\zm\_zm_perks;

//Area-specific scripts
#using scripts\zm\bsp_torrens;
#using scripts\zm\eng_towplatform;
#using scripts\zm\hab_airport;

//Alien Isolation Zombies Namespace
#namespace alien_isolation_zombies;

//Define cutscene names
#define		AYZ_CUTSCENE_ID_01						"zm_alien_isolation_cs01" 			//Story intro
#define		AYZ_CUTSCENE_ID_02						"zm_alien_isolation_cs02" 			//Transition - Torrens to Sevastopol
#define		AYZ_CUTSCENE_ID_03						"zm_alien_isolation_cs03"			//Endgame

//Define playtypes for zm_audio
#define PLAYTYPE_REJECT 1
#define PLAYTYPE_QUEUE 2
#define PLAYTYPE_ROUND 3
#define PLAYTYPE_SPECIAL 4
#define PLAYTYPE_GAMEEND 5

//Precache localised ui strings
#precache("string", "AYZ_UI_OBJECTIVE_UPDATED");

//Precache localised door prompt strings
#precache("string", "AYZ_DOORPROMPT_LOCKDOWN_UNFINISHED");
#precache("string", "AYZ_DOORPROMPT_LOW_POWER");
#precache("string", "AYZ_DOORPROMPT_LOCKED");

//Precache localised objective strings - Torrens
#precache("string", "AYZ_OBJECTIVE_SIGN_IN_TO_TORRENS");
#precache("string", "AYZ_OBJECTIVE_EXPLORE_TORRENS");
#precache("string", "AYZ_OBJECTIVE_REROUTE_POWER_FOR_DOOR");
#precache("string", "AYZ_OBJECTIVE_COLLECT_WEAPONS");

//Precache localised objective strings - Spaceflight Terminal
#precache("string", "AYZ_OBJECTIVE_SURVIVE_POWER_OUTAGE");
#precache("string", "AYZ_OBJECTIVE_GET_TO_TERMINAL");
#precache("string", "AYZ_OBJECTIVE_RESTORE_POWER_TO_TERMINAL");
#precache("string", "AYZ_OBJECTIVE_FIND_KEYCARD");

//Precache localised objective strings - Tow Platform
#precache("string", "AYZ_OBJECTIVE_ACTIVATE_TERMINAL_ONE");
#precache("string", "AYZ_OBJECTIVE_ACTIVATE_TERMINAL_TWO");
#precache("string", "AYZ_OBJECTIVE_PRESSURISE_AIRLOCK");
#precache("string", "AYZ_OBJECTIVE_WAIT_FOR_PRESSURISE");
#precache("string", "AYZ_OBJECTIVE_GET_TO_AIRLOCK");

//Precache models
#precache("model", "ayz_new_door_lights_open"); 										//door lights when door is open
#precache("model", "monitor_50cm_gameroom"); 											//gameroom monitor turned on
#precache("model", "monitor_static_trace"); 											//tow monitor state 1
#precache("model", "monitor_static_trace_orange"); 										//tow monitor state 2
#precache("model", "monitor_static_trace_red"); 										//tow monitor state 3
#precache("model", "monitor_50cm_airlock_state01"); 									//airlock monitor 1
#precache("model", "monitor_50cm_airlock_state02"); 									//airlock monitor 2
#precache("model", "monitor_50cm_airlock_state03"); 									//airlock monitor 3
#precache("model", "monitor_torrens_signin_dempsey"); 									//sign in monitor 1
#precache("model", "monitor_torrens_signin_nikolai"); 									//sign in monitor 2
#precache("model", "monitor_torrens_signin_richtofen"); 								//sign in monitor 3
#precache("model", "monitor_torrens_signin_takeo"); 									//sign in monitor 4
#precache("model", "monitor_torrens_signin"); 											//sign in monitor default
#precache("model", "monitor_50cm_sevastolink_message_playing"); 						//sevastolink monitor playing message
#precache("model", "monitor_50cm_sevastolink_message_played"); 							//sevastolink monitor played message

//Precache UI
#precache("lui_menu", "blackscreen");
#precache("lui_menu", "audiolog");
//#precache("lui_menu", "popup_zm_alien_isolation");
//#precache("lui_menu_data", "AlienIsolationObjectivePopup");
//#precache("eventstring", "AlienIsolationObjectivePopup");

//Precache FX
#precache("fx", "electric/fx_elec_sparks_bounce_lg_orange"); //Sevastolink broken spark
#precache("fx", "zm_alien_isolation/Elevator_Light"); //Elevator lights
#precache("fx", "lensflares/fx_lensflare_light_cool_xlg"); //Lensflare for lobby lights
#precache("fx", "player/fx_plyr_jump_dust"); //Torrens door dust
#precache("fx", "zm_alien_isolation/TORRENS_ONBOARD_CryoOpen"); //Torrens cryo open smoke

//*****************************************************************************
// MAIN
//*****************************************************************************
function main()
{
	zm_usermap::main();

	//Clear starting weapon
	level.ORIGINAL_start_weapon = level.start_weapon;
	level.start_weapon = (getWeapon("knife"));
	
	//level.player_starting_points = 500000; //Debug only!
	level._effect["elevator_light"] = "zm_alien_isolation/Elevator_Light";
	level._effect["sevastolink_spark"] = "electric/fx_elec_sparks_bounce_lg_orange";
	level._effect["big_lensflare"] = "lensflares/fx_lensflare_light_cool_xlg";
	level._effect["torrens_door_dust"] = "player/fx_plyr_jump_dust";
	level._effect["torrens_cryo_smoke"] = "zm_alien_isolation/TORRENS_ONBOARD_CryoOpen";

	level.key_obtained = false;
	level.adverts_theme_played = false;
	level.PauseSevastopolTourAudio = false;
	level.CurrentSevastopolTourAudio = "zm_alien_isolation_sev_tour_1";
	level.dempseybedlocation = 0;
	level.nikolaibedlocation = 0;
	level.richtofenbedlocation = 0;
	level.takeobedlocation = 0;
	level.signedInPlayerCount = 0;
	level.currentlyOpenDoors = array();
	level.playersWhoHavePickedUpWeapons = array();
	
	thread BSP_TORRENS_SPAWN();
	thread HAB_AIRPORT_SPAWN(); 
	thread ENG_TOWPLATFORM_SPAWN();

	thread GLOBAL_BESPOKE_ANIMATIONS();
	thread GLOBAL_MUSIC_SETUP();
	
	level._zombie_custom_add_weapons =&ZM_ALIEN_ISOLATION_WEAPONS;
	
	level.zones = [];
	level.zone_manager_init_func =&ZM_ALIEN_ISOLATION_ZONES;
	init_zones[0] = "bsp_torrens"; //The Torrens
	init_zones[1] = "sft_lobby"; //Sevastopol lobby
	init_zones[2] = "sft_spawn_zone"; //Old spawn room zone
	init_zones[3] = "main_zone"; //Main area zone
	init_zones[4] = "perkroom_zone"; //Fast Cash zone
	init_zones[5] = "endgame_zone"; //Buyable ending zone
	init_zones[6] = "noodlebar_zone"; //Noodle Bar zone
	init_zones[7] = "noodlebar_zone_main"; //Noodle Bar zone 2
	init_zones[8] = "collection_zone"; //Temp Baggage Collection and Advert Coridoor zone
	init_zones[9] = "comms_volume"; //Tow Platform
	level thread zm_zonemgr::manage_zones(init_zones);

	level.pathdist_type = PATHDIST_ORIGINAL;
	
	level.perk_purchase_limit = 100;
}

function ZM_ALIEN_ISOLATION_ZONES()
{
	//Add connecting zones
	zm_zonemgr::add_adjacent_zone("bsp_torrens", "sft_spawn_zone", "transition_from_torrens");
	zm_zonemgr::add_adjacent_zone("sft_spawn_zone", "main_zone", "enter_main_zone");
	zm_zonemgr::add_adjacent_zone("main_zone", "perkroom_zone", "enter_perkroom_zone");
	zm_zonemgr::add_adjacent_zone("main_zone", "noodlebar_zone", "enter_noodlebar_zone");
	zm_zonemgr::add_adjacent_zone("main_zone", "noodlebar_zone_main", "enter_noodlebar_zone");
	zm_zonemgr::add_adjacent_zone("main_zone", "endgame_zone", "enter_end_zone");
	zm_zonemgr::add_adjacent_zone("main_zone", "collection_zone", "enter_adverts_zone");
	zm_zonemgr::add_adjacent_zone("endgame_zone", "comms_volume", "ayz_elevator_zoneswap");
	
	level flag::init("always_on");
	level flag::set("always_on");
}	

function ZM_ALIEN_ISOLATION_WEAPONS()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_alien_isolation.csv", 1);
}


//Play a sound locally to all players once
function PLAY_LOCAL_SOUND(soundName) {
	players = GetPlayers();
	for (i = 0; i < players.size; i++) {
		players[i] PlayLocalSound(soundName);
	}
}

//Stop a local sound
function STOP_LOCAL_SOUND(soundName) {
	players = GetPlayers();
	for (i = 0; i < players.size; i++) {
		players[i] StopLocalSound(soundName);
	}
}


//Stop round start music
function stop_round_start_music() {
	//Depreciated...
}


//Show new objective
function UPDATE_OBJECTIVE(objectiveText) {
	PLAY_LOCAL_SOUND("zm_alien_isolation__objective_updated");
	IPrintLnBold(&"AYZ_UI_OBJECTIVE_UPDATED");
	IPrintLnBold(objectiveText);

	//TODO, fix up new UI and use the popup here.
	//PLAY_LOCAL_SOUND("zm_alien_isolation__objective_updated");
	//foreach	(player in level.players) {		
	//	dialog = player OpenLUIMenu("popup_zm_alien_isolation");
	//	player LUINotifyEvent(&"AlienIsolationObjectivePopup", 1, objectiveText);
	//	wait(5);
	//	player CloseLUIMenu(dialog);
	//}
}

//Completed an objective
function completed_old_objective() {
	//Depreciated...
}


//Easy trigger updaters
function UPDATE_BUYABLE_TRIGGER(price, trigger) {
	trigger setCursorHint("HINT_NOICON");
	trigger setHintString(&"ZOMBIE_BUTTON_BUY_OPEN_DOOR_COST", price);
	trigger SetVisibleToAll();
}
function UPDATE_TRIGGER(string, trigger) {
	trigger setCursorHint("HINT_NOICON");
	trigger setHintString(string);
	trigger SetVisibleToAll();
}
function HIDE_TRIGGER(trigger, clearText=true) {
	trigger setCursorHint("HINT_NOICON");
	if (clearText) {
		trigger setHintString("");
	}
	trigger SetInvisibleToAll();
}
function SHOW_TRIGGER(trigger) {
	trigger SetVisibleToAll();
}


//Set up zm_audio music tracks and cutscene audio
function GLOBAL_MUSIC_SETUP() {
    zm_audio::musicState_Create("torrens_intro_theme", PLAYTYPE_SPECIAL, "zod_gameover");
    zm_audio::musicState_Create("sft_audiolog_theme", PLAYTYPE_SPECIAL, "zod_parasite_start");
    zm_audio::musicState_Create("sft_intro_theme", PLAYTYPE_GAMEEND, "zod_egg_coldhardcash");
    zm_audio::musicState_Create("tpf_intro_theme", PLAYTYPE_GAMEEND, "zod_endigc_lullaby");
    zm_audio::musicState_Create("tpf_airlock_pressurising_theme", PLAYTYPE_GAMEEND, "zod_meatball_end");
}


//All animated things
function GLOBAL_BESPOKE_ANIMATIONS() {
	thread ANIMATED_NODDING_BIRD();
	thread ANIMATED_BOBBLEHEAD();
	thread ANIMATED_FAN_PROP();
	thread ANIMATED_ROBOT_TOY();
	thread ANIMATED_ELEVATOR_LIGHTS();
}

//Nodding Bird Animations
function ANIMATED_NODDING_BIRD() {
	allNoddingBirds = GetEntArray("noddingbird", "targetname");
	foreach(noddingBird in allNoddingBirds) {
		thread play_bird_anim(noddingBird);
	}
}
function play_bird_anim(bird) {
	while(true) {
		bird RotatePitch(-90, 2, 1, 1);
		wait(2);
		bird RotatePitch(90, 2, 1, 1);
		wait(2);
	}
}

//Bobblehead Animations
function ANIMATED_BOBBLEHEAD() {
	allBobbleheads = GetEntArray("bobblehead", "targetname");
	foreach(bobblehead in allBobbleheads) {
		thread play_bobblehead_anim(bobblehead);
	}
}
function play_bobblehead_anim(bobblehead) {
	while(true) {
		bobblehead MoveTo(bobblehead.origin + (0,0,1.5), 0.5, 0.2, 0.2);
		wait(0.5);
		bobblehead MoveTo(bobblehead.origin - (0,0,1.5), 0.5, 0.2, 0.2);
		wait(0.5);
	}
}

//Fan Prop Animations
function ANIMATED_FAN_PROP() {
	allFanProps = GetEntArray("fan_blade_ayz", "targetname");
	foreach(fan in allFanProps) {
		fan Rotate((180,0,0));
	}
}

//Mini Robot SFX
function ANIMATED_ROBOT_TOY() {
	allRobotToys = GetEntArray("robotoy", "targetname");
	foreach(robotToy in allRobotToys) {
		thread play_robotoy_sfx(robotToy);
	}
}
function play_robotoy_sfx(robotoy) {
	while(true) {
		if (randomintrange(1,100) > 50) {
			//Loop through all 8 sounds FORWARDS
			loopcount = 0;
			while (loopcount < 8) {
				loopcount = loopcount + 1;
				wait(randomintrange(10,20));
				robotoy PlaySound("zm_alien_isolation_robotoy_"+loopcount);
			}
		} else {
			//Loop through all 8 sounds BACKWARDS
			loopcount = 8;
			while (loopcount > 0) {
				wait(randomintrange(10,20));
				robotoy PlaySound("zm_alien_isolation_robotoy_"+loopcount);
				loopcount = loopcount - 1;
			}
		}
	}
}

//Elevator FX handler
function ANIMATED_ELEVATOR_LIGHTS() {
	//Wait for elevator to start moving
	self waittill("ayz_elevator_moving");

	//Place all FX
	for (i=1;i<5;i++) {
		fx_tpf = struct::get("elevator_fx"+i, "targetname");
		fx_sft = struct::get("elevator_fx"+i+"_tpf", "targetname");

		elevator_fx[i] = PlayFX(level._effect["elevator_light"], fx_tpf.origin);
		elevator_fx2[i] = PlayFX(level._effect["elevator_light"], fx_sft.origin);
	}

	//Wait for elevator to stop moving
	self waittill("arrived_at_tow_platform");

	//Stop FX
	foreach (player in level.players) {
		for (i=1;i<5;i++) {
			//StopFX(player, elevator_fx[i]);
			//StopFX(player, elevator_fx2[i]);
		}
	}
}


//Give the player all perks and max ammo
function GIVE_ALL_PERKS_AND_AMMO() {
	all_players = GetPlayers();
	foreach (player in all_players) {
		PLAY_LOCAL_SOUND("zm_alien_isolation__tow_custom_perk");
		
		//GIVE ALL PERKS
		a_str_perks = GetArrayKeys(level._custom_perks);
		foreach(str_perk in a_str_perks)
		{
			if(!player HasPerk(str_perk))
			{
				player zm_perks::give_perk(str_perk, false);
			}
		}
		
		//GIVE MAX AMMO
		primary_weapons = player GetWeaponsList(true); 
		foreach(primary_weapon in primary_weapons) {
			if (player HasWeapon(primary_weapon)) {
				player GiveMaxAmmo(primary_weapon);
			}
		}
	}
}


//Override the next control unfreeze
function OVERRIDE_CONTROL_UNFREEZE(player) {
	player FreezeControls(true);
	while (player AreControlsFrozen() == true) {
		wait(0.1);
	}
	player FreezeControls(true);
}