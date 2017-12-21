///////////////////////////////////////
//////  ALIEN ISOLATION ZOMBIES  //////
//////     SERVER-SIDE SCRIPT    //////
///////////////////////////////////////
//////        The Torrens        //////
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

//Define some stuff
#define		AYZ_DOORPROMPT_LOCKDOWN_UNFINISHED		"Door is disabled, please wait!" 	//Shown on doors pre-lockdown in SFT
#define		AYZ_CUTSCENE_ID_01						"zm_alien_isolation_cs01" 			//Story intro
#define		AYZ_CUTSCENE_ID_02						"zm_alien_isolation_cs02" 			//Transition - Torrens to Sevastopol
#define		AYZ_CUTSCENE_ID_03						"zm_alien_isolation_cs03"			//Endgame

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

//Precache UI
#precache("lui_menu", "T7Hud_zm_alien_isolation");
//#precache("lui_menu", "popup_zm_alien_isolation");
#precache("lui_menu_data", "T7Hud_zm_alien_isolation.AlienIsolationObjectivePopup");

//Precache FX
#precache("fx", "zm_alien_isolation/TowPlatform_WarningLight"); //Our warning light to spin
#precache("fx", "zm_alien_isolation/Elevator_Light"); //Elevator lights
#precache("fx", "zm_alien_isolation/TowPlatform_FlashingEvac"); //Flashing evac lights

//*****************************************************************************
// MAIN
//*****************************************************************************
function main()
{
	zm_usermap::main();
	
	//FX names
	level._effect["towplat_warninglight"] = "zm_alien_isolation/TowPlatform_WarningLight";
	level._effect["elevator_light"] = "zm_alien_isolation/Elevator_Light";
	
	//Torrens intro
	thread torrens_intro_sequence(true); //Set param to true to skip cutscenes (false otherwise)
	
	//Light states and animations/sounds for spawn
	thread isolation_spawn_scripts(); 
	
	//Light states and audio for power activation
	thread init_power(); 
	
	//Bespoke location based ambient sounds for the gameroom machines.
	//Other location based ambient sounds are handled in our CSC.
	thread gameroom_ambient_sounds_bespoke();
	
	//The buyable ending door scripts
	thread open_ending_area_door(); 
	
	//Sliding Door Script - GAMEROOM
	thread ayz_slidingdoor_gameroom();
	
	//Sliding Door Script - PERKROOM
	thread ayz_slidingdoor_perkroom();
	
	//Spaceflight Terminal Objective Popups
	thread spaceflight_terminal_objectives();
	thread keycard_objective();
	
	//The buyable ending scripts
	thread buyable_ending();
	
	//Run all nodding bird animations
	thread play_nodding_bird(); 
	
	//Start our random background sounds (helps with the "worldbuilding")
	thread random_background_sounds();
	thread random_background_sounds_towPlatform();
	
	//Start ADVERTS fan anims
	thread adverts_fan_anims();
	
	//ADVERTS right side buyable door
	thread adverts_right_door();
	
	//ADVERTS left side buyable door
	thread adverts_left_door();
	
	//NEW KEYCARD SCRIPT for endgame door
	thread keycard_setup();
	
	//Handle alarms at the tow platform. This won't do anything until prompted though.
	thread play_alarm_loop_towPlatform1();
	thread play_alarm_loop_towPlatform2();
	thread play_alarm_loop_towPlatform3();
	
	//Handle elevator FX (only playing fx - stopping fx is done in the csc)
	thread handle_elevator_fx();
	
	//DEBUG: Skip right to the tow platform (don't enable on ship)
	//thread ayz_tow_platform_challenge(true); //set param to true to skip to airlock section
	
	//DEBUG: Set round number
	//thread dbgSetRoundNum(20);
	
	//DEBUG: Set loads of points for testing (don't enable on ship)
	//level.player_starting_points = 500000;
	
	//DEBUG: Disable AI Spawn (don't enable on ship)
	//SetDvar("ai_disableSpawn", "1");
	
	//DEBUG: Enable a bot player (don't enable on ship) - 07/17 THIS MAY CAUSE ISSUES DUE TO TORRENS INTRO
	//SetDvar("scr_zm_enable_bots", "1");
	
	//Set this in mod tool launch options for splitscreen
	//+set splitscreen 1 +set splitscreen_playerCount 2
	
	//Init the flag for the spawn and endgame door
	level flag::init("spawn_door_opened");
	level flag::init("endgame_opened");
	
	//Core stuff
	level._zombie_custom_add_weapons =&custom_add_weapons;
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;
	init_zones[0] = "bsp_torrens"; //The Torrens
	init_zones[1] = "sft_spawn_zone"; //Spawn room zone
	init_zones[2] = "main_zone"; //Main area zone
	init_zones[3] = "perkroom_zone"; //Fast Cash zone
	init_zones[4] = "endgame_zone"; //Buyable ending zone
	init_zones[5] = "noodlebar_zone"; //Noodle Bar zone
	init_zones[6] = "noodlebar_zone_main"; //Noodle Bar zone 2
	init_zones[7] = "collection_zone"; //Temp Baggage Collection and Advert Coridoor zone
	init_zones[8] = "comms_volume"; //Tow Platform
	level thread zm_zonemgr::manage_zones( init_zones );

	level.pathdist_type = PATHDIST_ORIGINAL;
	
	//Change perk limit
	level.perk_purchase_limit = 100;
}

function usermap_test_zone_init()
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
	
	level flag::init( "always_on" );
	level flag::set( "always_on" );
}	

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_alien_isolation.csv", 1);
}

//Play a sound locally to all players once
function play_sound_locally(soundName) {
	//iprintlnbold("DEBUG: Playing specified music to all players once.");
	players = GetPlayers();
	for (i = 0; i < players.size; i++) {
		players[i] PlayLocalSound(soundName);
	}
}


//Stop a local sound
function stop_sound_locally(soundName) {
	//iprintlnbold("DEBUG: STOPPING SOUND " + soundName);
	players = GetPlayers();
	for (i = 0; i < players.size; i++) {
		players[i] StopLocalSound(soundName);
	}
}


//Stop round start music
function stop_round_start_music() {
	//Find a better way pls...
	//stop_sound_locally("mus_roundstart_first_intro");
	//stop_sound_locally("mus_roundstart1_intro");
	//stop_sound_locally("mus_roundstart2_intro");
	//stop_sound_locally("mus_roundstart3_intro");
	//stop_sound_locally("mus_roundstart4_intro");
	//stop_sound_locally("mus_roundstart_short1_intro");
	//stop_sound_locally("mus_roundstart_short2_intro");
	//stop_sound_locally("mus_roundstart_short3_intro");
	//stop_sound_locally("mus_roundstart_short4_intro");
}


//Show new objective
function show_new_objective(objectiveText) {
	//play_sound_locally("zm_alien_isolation__objective_updated");
	//iprintlnbold("OBJECTIVE UPDATED:");
	//iprintlnbold(objectiveText);
	
	
	
	
	play_sound_locally("zm_alien_isolation__objective_updated");
	foreach	(player in level.players) {		
		//dialog = player OpenLUIMenu("popup_zm_alien_isolation");
		player SetControllerUIModelValue("T7Hud_zm_alien_isolation.AlienIsolationObjectivePopup", RandomIntRange(6,21));
		iprintlnbold(player GetControllerUIModelValue("T7Hud_zm_alien_isolation.AlienIsolationObjectivePopup"));
		//wait(5);
		//player CloseLUIMenu(dialog);
	}
}


//Completed an objective
function completed_old_objective() {
	//play_sound_locally("zm_alien_isolation__objective_updated");
	//iprintlnbold("OBJECTIVE COMPLETE.");
	//////////////////////////////
	///////// DEPRECIATED! ///////
	//////////////////////////////
}


//Nodding Bird Animations
function play_nodding_bird() {
	all_noddingbird_ents = GetEntArray("noddingbird", "targetname");
	foreach(noddingbird in all_noddingbird_ents) {
		thread single_nodding_bird(noddingbird);
	}
}
function single_nodding_bird(bird) {
	//We got to thread out each bird to this function so they can run at the same time
	while(true) {
		bird RotatePitch(-90, 2, 1, 1);
		wait(2);
		bird RotatePitch(90, 2, 1, 1);
		wait(2);
	}
}


//Give the player all perks and max ammo
function give_perks_and_ammo() {
	all_players = GetPlayers();
	foreach (player in all_players) {
		//SFX
		play_sound_locally("zm_alien_isolation__tow_custom_perk");
		
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