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
//#using scripts\zm\_zm_powerup_weapon_minigun;

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

//Define some stuff
#define		AYZ_DOORPROMPT_LOCKDOWN_UNFINISHED		"Door is disabled, please wait!" //Shown on doors pre-lockdown in SFT
#define		AYZ_CUTSCENE_ID_01						"zm_alien_isolation_cs01" //Story intro
#define		AYZ_CUTSCENE_ID_02						"zm_alien_isolation_cs02" //Transition - Torrens to Sevastopol
#define		AYZ_CUTSCENE_ID_03						"zm_alien_isolation_cs03" //Endgame


//Precache models
#precache("model", "ayz_new_door_lights_open"); //door lights when door is open
#precache("model", "monitor_50cm_gameroom"); //gameroom monitor turned on
#precache("model", "monitor_static_trace"); //tow monitor state 1
#precache("model", "monitor_static_trace_orange"); //tow monitor state 2
#precache("model", "monitor_static_trace_red"); //tow monitor state 3
#precache("model", "monitor_50cm_airlock_state01"); //airlock monitor 1
#precache("model", "monitor_50cm_airlock_state02"); //airlock monitor 2
#precache("model", "monitor_50cm_airlock_state03"); //airlock monitor 3
#precache("model", "monitor_torrens_signin_dempsey"); //sign in monitor 1
#precache("model", "monitor_torrens_signin_nikolai"); //sign in monitor 2
#precache("model", "monitor_torrens_signin_richtofen"); //sign in monitor 3
#precache("model", "monitor_torrens_signin_takeo"); //sign in monitor 4
#precache("model", "monitor_torrens_signin"); //sign in monitor default

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
	
	////////////////////////
    // ZM_ALIEN_ISOLATION //
    ////////////////////////
	
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


//On spawn, activate LS2, wait 5 seconds, close windows and activate LS1
function isolation_spawn_scripts() {
	//Activate LS1 - lights on
	level util::set_lighting_state(0);
	
	//Wait for blackscreen to pass before starting any scripting
	level flag::wait_till( "initial_blackscreen_passed" );
	
	//Wait for player to open the spawn room door
	spawn_room_door_wait();

	//Play new Spaceflight Terminal theme and wait for it to finish before doing lockdown
	play_sound_locally("zm_alien_isolation__sft_theme");
	stop_round_start_music();
	wait(39);
	
	//Check there aren't any players over 1000 points before running the delayed lockdown.
	players_got_scores = 0;
	players = GetPlayers();
	foreach(player in players) {
		if (player.score > 1000) {
			//iprintlnbold("DEBUG: Found a player with over 1000 points. Not delaying lockdown.");
			players_got_scores = 1;
		}
	}
	
	//Delay the lockdown if points are all below 1000.
	if (players_got_scores == 0) {
		//wait(5); - GOT RID OF THIS
	}
	
	//Force walk before the lockdown
	foreach(player in players) {
		//player AllowSprint(false); - GOT RID OF THIS
	}
	
	//Play lockdown sound effect - pause for 5 seconds before doing anything else to hit the right cue
	play_sound_locally("zm_alien_isolation__lockdown");
	wait(5);
	
	//Perform animation of shutters
	//iprintlnbold("DEBUG: Performing animation of windows.");
	animate_window_shutters();
	
	//Wait 9 seconds
	//iprintlnbold("DEBUG: Waiting 9 seconds before turning out lights.");
	wait(9);
	
	//Activate LS2 - lights out
	level util::set_lighting_state(1);
	
	//Notify that lights are now off. This can be used to call scripts in our CSC.
	level util::clientnotify ("ayz_power_off");
	
	//Allow sprinting again.
	foreach(player in players) {
		//player AllowSprint(true); - GOT RID OF THIS!
	}
	
	//Play new post-lockdown theme (short sting)
	play_sound_locally("zm_alien_isolation__post_lockdown_theme");
	
	//Let everyone know we're done with the lockdown
	self notify("ayz_lockdown_completed");
}


//Spaceflight Terminal Objectives
function spaceflight_terminal_objectives() {
	//Wait for intro lockdown to finish and then show objective a bit later
	self waittill("ayz_lockdown_completed");
	wait(5);
	thread show_new_objective("Restore power to the Spaceflight Terminal.");
	
	//Wait for power to be restored, play verlaine's message, then show objective.
	level flag::wait_till("power_on");
	wait(15);
	play_sound_locally("zm_alien_isolation__verlainebroadcast");
	wait(10.5);
	thread show_new_objective("Get to the Tow Platform and escape on the Torrens.");
	
	//Keycard objective is handled in another function (look below).
}
function keycard_objective() {
	//Get zone
	keycardZoneArray = GetEntArray("zombie_door_custom", "targetname");
	loopcount = 0;
	foreach(trigger in keycardZoneArray) {
		loopcount += 1;
		if (loopcount == 1) {
			keycardZone = trigger;
		}
	}
	
	//Can't do anything if the door's shut
	self waittill("ayz_lockdown_completed");
	
	//Wait for someone to get in the zone
	all_players = GetPlayers();
	while(1) {
		touched = false;
		if (level.key_obtained != true) {
			foreach (player in all_players) {
				if (player IsTouching(keycardZone) == true) {
					//Someone's in the keycard zone
					wait(1.5);
					thread show_new_objective("Find a keycard to open the door."); //show objective
					touched = true;
					break; 
				}
			}
			if (touched == true) {
				break; //done
			}
		} else {
			break; //got the keycard already
		}
		wait 0.5; //delay a bit so we dont kill the game
	}
}


//Handle spawn room door
function spawn_room_door_wait() {
	//Get all entities
	//TODO: Tidy this script (and the other EntArray) to be just GetEnt. Much better.
	ent_parts_spawndoor_trigger = GetEntArray("zombie_door_custom", "targetname");
	ent_parts_spawndoor_door1 = GetEntArray("spawn_room_buyable_door_side1", "targetname");
	ent_parts_spawndoor_door2 = GetEntArray("spawn_room_buyable_door_side2", "targetname");
	ent_parts_spawndoor_door1_move = struct::get_array("spawn_room_buyable_door_side1_move", "targetname");
	ent_parts_spawndoor_door2_move = struct::get_array("spawn_room_buyable_door_side2_move", "targetname");
	ent_parts_spawndoor_clip1_move = struct::get_array("spawn_room_buyable_clip_side1_move", "targetname");
	ent_parts_spawndoor_clip2_move = struct::get_array("spawn_room_buyable_clip_side2_move", "targetname");
	ent_parts_spawndoor_door1_clip = GetEntArray("spawn_room_buyable_door_side1_clip", "targetname");
	ent_parts_spawndoor_door2_clip = GetEntArray("spawn_room_buyable_door_side2_clip", "targetname");
	spawndoor_loop = 0;
	foreach(ent_spawndoor_trigger in ent_parts_spawndoor_trigger) {
		spawndoor_loop = spawndoor_loop + 1;
		/*
			Loop 1 = Buyable Ending Door
			Loop 2 = Spawnroom Door
		*/
		if (spawndoor_loop == 2) {
			spawn_door_trigger = ent_spawndoor_trigger;
			//iprintlnbold("DEBUG: Found spawndoor trigger.");
		}
	}
	foreach(ent_spawndoor_trigger_door1 in ent_parts_spawndoor_door1) {
		spawn_door_door1 = ent_spawndoor_trigger_door1;
		//iprintlnbold("DEBUG: Found spawndoor door 1.");
	}
	foreach(ent_spawndoor_trigger_door2 in ent_parts_spawndoor_door2) {
		spawn_door_door2 = ent_spawndoor_trigger_door2;
		//iprintlnbold("DEBUG: Found spawndoor door 2.");
	}
	foreach(ent_spawndoor_trigger_door1_move in ent_parts_spawndoor_door1_move) {
		spawn_door_door1_move = ent_spawndoor_trigger_door1_move;
		//iprintlnbold("DEBUG: Found spawndoor door 1 move.");
	}
	foreach(ent_spawndoor_trigger_door2_move in ent_parts_spawndoor_door2_move) {
		spawn_door_door2_move = ent_spawndoor_trigger_door2_move;
		//iprintlnbold("DEBUG: Found spawndoor door 2 move.");
	}
	foreach(ent_spawndoor_trigger_clip1_move in ent_parts_spawndoor_clip1_move) {
		spawn_door_clip1_move = ent_spawndoor_trigger_clip1_move;
		//iprintlnbold("DEBUG: Found spawndoor clip 1 move.");
	}
	foreach(ent_spawndoor_trigger_clip2_move in ent_parts_spawndoor_clip2_move) {
		spawn_door_clip2_move = ent_spawndoor_trigger_clip2_move;
		//iprintlnbold("DEBUG: Found spawndoor clip 2 move.");
	}
	foreach(ent_spawndoor_trigger_door1_clip in ent_parts_spawndoor_door1_clip) {
		spawn_door_door1_clip = ent_spawndoor_trigger_door1_clip;
		//iprintlnbold("DEBUG: Found spawndoor door 1 clip.");
		//spawn_door_door1_clip NotSolid();
	}
	foreach(ent_spawndoor_trigger_door2_clip in ent_parts_spawndoor_door2_clip) {
		spawn_door_door2_clip = ent_spawndoor_trigger_door2_clip;
		//iprintlnbold("DEBUG: Found spawndoor door 2 clip.");
		//spawn_door_door2_clip NotSolid();
	}
	
	//Set our trigger properties
	spawn_door_trigger setCursorHint("HINT_NOICON");
	spawn_door_trigger setHintString(&"ZOMBIE_BUTTON_BUY_OPEN_DOOR_COST", 1000);
	spawn_door_trigger SetVisibleToAll();
	
	//Wait for the door to be purchased before starting anything
	while(1) {
		spawn_door_trigger waittill("trigger", player);
		if(player.score < 1000)
		{
			wait 0.1;
			player playsound("zmb_no_cha_ching");
			continue;
		}
		player zm_score::minus_to_player_score(1000); 
		player playsound("zmb_cha_ching");
		break; //We've got enough money!
	}
	
	//Hide trigger
	spawn_door_trigger setCursorHint("HINT_NOICON");
	spawn_door_trigger setHintString("");
	spawn_door_trigger SetInvisibleToAll();
	
	//iprintlnbold("Opening door");
	
	//Move door 1 and clip
	spawn_door_door1 MoveTo(spawn_door_door1_move.origin, 2, 1, 1);
	spawn_door_door1_clip MoveTo(spawn_door_clip1_move.origin, 2, 1, 1);
	
	//Move door 2 and clip
	spawn_door_door2 MoveTo(spawn_door_door2_move.origin, 2, 1, 1);
	spawn_door_door2_clip MoveTo(spawn_door_clip2_move.origin, 2, 1, 1);
	
	//NEW! CHANGE DOOR FLASHER AND MOVE ON VECTOR
	door_flasher = GetEnt("spawndoor_flasher", "targetname");
	door_flasher SetModel("ayz_new_door_lights_open");
	door_flasher MoveTo((door_flasher.origin + (-63.501, -32.46, 1)), 2, 1, 1);
	
	//Play door sound at location
	spawn_door_door1 PlaySound("zm_alien_isolation__largedoor_open");
	
	//Set the flag to let our program know the door is open
	level flag::set("spawn_door_opened");
	
	//Wait 1 second before doing anything
	wait(1);
}


//Gameroom sliding door
function ayz_slidingdoor_gameroom() {
	//Pre-define our cost
	door_cost = 1500;

	//Get our trigger
	gameroom_trigger = getEnt("gameroom_trigger", "targetname"); //our trigger
	
	//Set our trigger properties
	gameroom_trigger setCursorHint("HINT_NOICON");
	gameroom_trigger setHintString(AYZ_DOORPROMPT_LOCKDOWN_UNFINISHED);
	gameroom_trigger SetVisibleToAll();

	//Wait for the lockdown to finish
	self waittill("ayz_lockdown_completed");
	
	//Re-set our trigger properties
	gameroom_trigger setHintString(&"ZOMBIE_BUTTON_BUY_OPEN_DOOR_COST", door_cost);

	//Get ents
	gameroom_door = getEnt("gameroom_door", "targetname"); //our door
	gameroom_door_clip = getEnt("gameroom_door_clip", "targetname"); //our clipping
	gameroom_door_graffiti = getEnt("gameroom_door_graffiti", "targetname"); //our graffiti
	
	//Wait for door purchase to finish
	while(1) {
		gameroom_trigger waittill("trigger", player);
		if(player.score < door_cost)
		{
			wait 0.1;
			player playsound("zmb_no_cha_ching");
			continue;
		}
		player zm_score::minus_to_player_score(door_cost); 
		player playsound("zmb_cha_ching");
		break; //We've got enough money!
	}
	
	//Hide trigger
	gameroom_trigger setHintString(""); //just in case
	gameroom_trigger SetInvisibleToAll();
	
	//Play door sound
	gameroom_door PlaySound("zm_alien_isolation__shutter_opening");
	
	//Move stuff
	gameroom_door MoveTo((gameroom_door.origin + (0,0,80)), 1.5, 0.75, 0.75); //move door
	gameroom_door_clip MoveTo((gameroom_door_clip.origin + (0,0,80)), 1.5, 0.75, 0.75); //move clipping
	gameroom_door_graffiti MoveTo((gameroom_door_graffiti.origin + (0,0,80)), 1.5, 0.75, 0.75); //move graffiti
}


//Perkroom sliding door
function ayz_slidingdoor_perkroom() {
	//Pre-define our cost
	door_cost = 1500;

	//Get our trigger
	perkroom_trigger = getEnt("perkroom_trigger", "targetname"); //our trigger
	
	//Set our trigger properties
	perkroom_trigger setCursorHint("HINT_NOICON");
	perkroom_trigger setHintString(AYZ_DOORPROMPT_LOCKDOWN_UNFINISHED);
	perkroom_trigger SetVisibleToAll();

	//Wait for the lockdown to finish
	self waittill("ayz_lockdown_completed");
	
	//Re-set our trigger properties
	perkroom_trigger setHintString(&"ZOMBIE_BUTTON_BUY_OPEN_DOOR_COST", door_cost);

	//Get ents
	perkroom_door = getEnt("perkroom_door", "targetname"); //our door
	perkroom_door_clip = getEnt("perkroom_door_clip", "targetname"); //our clipping
	perkroom_door_shadow = getEnt("perkroom_shadow", "targetname"); //our graffiti
	
	//Wait for door purchase to finish
	while(1) {
		perkroom_trigger waittill("trigger", player);
		if(player.score < door_cost)
		{
			wait 0.1;
			player playsound("zmb_no_cha_ching");
			continue;
		}
		player zm_score::minus_to_player_score(door_cost); 
		player playsound("zmb_cha_ching");
		break; //We've got enough money!
	}
	
	//Hide trigger
	perkroom_trigger setHintString(""); //just in case
	perkroom_trigger SetInvisibleToAll();
	
	//Play door sound
	perkroom_door PlaySound("zm_alien_isolation__shutter_opening");
	
	//Move stuff
	perkroom_door MoveTo((perkroom_door.origin + (0,0,80)), 1.5, 0.75, 0.75); //move door
	perkroom_door_clip MoveTo((perkroom_door_clip.origin + (0,0,80)), 1.5, 0.75, 0.75); //move clipping
	perkroom_door_shadow MoveTo((perkroom_door_shadow.origin + (0,0,80)), 1.5, 0.75, 0.75); //move graffiti
}


//Switch light state when power is turned on and play sound
function init_power() {
	//Set hint on noodle door before power is turned on
	noodledoor_trigger = GetEntArray("noodledoor_hint", "targetname");
	foreach(noodledoor in noodledoor_trigger) {
		noodledoor_hint = noodledoor;
	}
	noodledoor_hint SetHintString(&"ZOMBIE_NEED_POWER");
	noodledoor_hint SetVisibleToAll();

	//Wait until the power is activated
	level flag::wait_till("power_on");
	
	//Perform generator handle animation
	generator_handle = getEnt("generator_handle_effect", "targetname");
	generator_handle RotatePitch(45, 0.5, 0.25, 0.25);
	wait(0.5);
	generator_handle RotatePitch(-45, 0.5, 0.25, 0.25);
	
	//Activate LS3 - lights back on
	//iprintlnbold("DEBUG: Power on.");
	level util::set_lighting_state(2);
	
	//Notify that lights are now ON again. This can be used to call scripts in our CSC.
	level util::clientnotify ("ayz_power_on");
	
	//Hide noodle door power hint
	noodledoor_hint SetInvisibleToAll();
	
	//Play activated sound (this overrides the default 3d sound)
	play_sound_locally("zm_alien_isolation__poweron");
	
	//Wait 2 seconds before opening
	wait(2);
	
	//Open noodlebar door
	open_noodle_door();
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


//Extra ambient sound stuff - needed for game room as it involves delays
function gameroom_ambient_sounds_bespoke() {
	//Wait for power to activate
	level flag::wait_till("power_on");
	
	//First, change TV screens to be on
	gameroom_monitor_1 = getEnt("gameroom_monitor_1", "targetname"); 
	gameroom_monitor_2 = getEnt("gameroom_monitor_2", "targetname");
	gameroom_monitor_1 SetModel("monitor_50cm_gameroom");
	gameroom_monitor_2 SetModel("monitor_50cm_gameroom");
	
	//Play initial sound before loop
	gameroom_monitor_1 PlaySound("zm_alien_isolation_ambient_gametheme_4");
	gameroom_monitor_2 PlaySound("zm_alien_isolation_ambient_gametheme_4");

	//Loop forever, get random sound at random machine and wait a random amount of time
	while (true) {
		structName = "gameroom_monitor_"+RandomIntRange(1,3); //generate struct name
		soundName = "zm_alien_isolation_ambient_gametheme_"+RandomIntRange(1,6); //generate sound name
		waitTime = RandomIntRange(6,21); //generate wait time
		
		wait(waitTime); //wait 6 secs to 20 secs before going
		
		structToPlayAt = getEnt(structName, "targetname"); //not struct anymore, we're using script_model. still either 1 or 2 and gonna keep the same name because I'm lazy.
		structToPlayAt PlaySound(soundName); //we have 5 themes on 2 structs
	}
}


//Animate window shutters
function animate_window_shutters() {
	//Loop for every window set
	for (i = 0; i < 4; i++) {
		ent_parts = GetEntArray("window_close_script_" + i, "targetname");
		struct_parts = struct::get_array("window_close_script_" + i, "targetname");
		foreach(ent in ent_parts) {
			if(IsDefined(ent.script_noteworthy) && ent.script_noteworthy == "window_to_move_" + i) {
				window_shutter = ent;	
				//iprintlnbold("DEBUG: Found shutter " + i);
				//window_shutter NotSolid();
			}
		}
		foreach(struct in struct_parts) {
			if(IsDefined(struct.script_noteworthy) && struct.script_noteworthy == "window_shutter_finish_" + i) {
				window_shutter_destination = struct;
				//iprintlnbold("DEBUG: Found move struct " + i);
			}
		}
		window_shutter MoveTo(window_shutter_destination.origin, 9, 1, 1);
	}
}


//Noodle door script
function open_noodle_door() {
	//Move noodle door
	ent_parts = GetEntArray("noodlebar_door_script", "targetname");
	ent_parts_two = GetEntArray("noodlebar_door_script_clip", "targetname");
	struct_parts = struct::get_array("noodlebar_door_script", "targetname");
	foreach(ent in ent_parts) {
		if(IsDefined(ent.script_noteworthy) && ent.script_noteworthy == "noodlebar_door") {
			noodle_door = ent;	
			//iprintlnbold("DEBUG: Found noodlebar door.");
			noodle_door NotSolid();
		}
	}
	foreach(ent_two in ent_parts_two) {
		if(IsDefined(ent_two.script_noteworthy) && ent_two.script_noteworthy == "noodlebar_door_clip") {
			noodle_door_clip = ent_two;	
			//iprintlnbold("DEBUG: Found noodlebar door CLIP.");
			noodle_door_clip NotSolid();
		}
	}
	foreach(struct in struct_parts) {
		if(IsDefined(struct.script_noteworthy) && struct.script_noteworthy == "noodlebar_door_finish") {
			noodle_door_destination = struct;
			//iprintlnbold("DEBUG: Found move struct for noodlebar door.");
		}
	}
	noodle_door MoveTo(noodle_door_destination.origin, 2, 1, 1);
	noodle_door_clip MoveTo(noodle_door_destination.origin, 2, 1, 1);
	
	//Play door sound at location
	noodle_door PlaySound("zm_alien_isolation__smalldoor_open");
}


//Open buyable ending area door
function open_ending_area_door() {
	//Get all entities
	ent_parts_endgame_trigger = GetEntArray("zombie_door_custom", "targetname");
	ent_parts_endgame_door1 = GetEntArray("endgame_buyable_door_side1", "targetname");
	ent_parts_endgame_door2 = GetEntArray("endgame_buyable_door_side2", "targetname");
	ent_parts_endgame_door1_move = struct::get_array("endgame_buyable_door_side1_move", "targetname");
	ent_parts_endgame_door2_move = struct::get_array("endgame_buyable_door_side2_move", "targetname");
	ent_parts_endgame_clip1_move = struct::get_array("endgame_buyable_clip_side1_move", "targetname");
	ent_parts_endgame_clip2_move = struct::get_array("endgame_buyable_clip_side2_move", "targetname");
	ent_parts_endgame_door1_clip = GetEntArray("endgame_buyable_door_side1_clip", "targetname");
	ent_parts_endgame_door2_clip = GetEntArray("endgame_buyable_door_side2_clip", "targetname");
	endgamedoor_loop = 0;
	foreach(ent_endgame_trigger in ent_parts_endgame_trigger) {
		endgamedoor_loop = endgamedoor_loop + 1;
		/*
			Loop 1 = Buyable Ending Door
			Loop 2 = Spawnroom Door
		*/
		if (endgamedoor_loop == 1) {
			endgame_trigger = ent_endgame_trigger;
			//iprintlnbold("DEBUG: Found endgame DOOR trigger.");
		}
	}
	foreach(ent_endgame_trigger_door1 in ent_parts_endgame_door1) {
		endgame_door1 = ent_endgame_trigger_door1;
		//iprintlnbold("DEBUG: Found endgame door 1.");
	}
	foreach(ent_endgame_trigger_door2 in ent_parts_endgame_door2) {
		endgame_door2 = ent_endgame_trigger_door2;
		//iprintlnbold("DEBUG: Found endgame door 2.");
	}
	foreach(ent_endgame_trigger_door1_move in ent_parts_endgame_door1_move) {
		endgame_door1_move = ent_endgame_trigger_door1_move;
		//iprintlnbold("DEBUG: Found endgame door 1 move.");
	}
	foreach(ent_endgame_trigger_door2_move in ent_parts_endgame_door2_move) {
		endgame_door2_move = ent_endgame_trigger_door2_move;
		//iprintlnbold("DEBUG: Found endgame door 2 move.");
	}
	foreach(ent_endgame_trigger_clip1_move in ent_parts_endgame_clip1_move) {
		endgame_clip1_move = ent_endgame_trigger_clip1_move;
		//iprintlnbold("DEBUG: Found endgame clip 1 move.");
	}
	foreach(ent_endgame_trigger_clip2_move in ent_parts_endgame_clip2_move) {
		endgame_clip2_move = ent_endgame_trigger_clip2_move;
		//iprintlnbold("DEBUG: Found endgame clip 2 move.");
	}
	foreach(ent_endgame_trigger_door1_clip in ent_parts_endgame_door1_clip) {
		endgame_door1_clip = ent_endgame_trigger_door1_clip;
		//iprintlnbold("DEBUG: Found endgame door 1 clip.");
		//endgame_door1_clip NotSolid();
	}
	foreach(ent_endgame_trigger_door2_clip in ent_parts_endgame_door2_clip) {
		endgame_door2_clip = ent_endgame_trigger_door2_clip;
		//iprintlnbold("DEBUG: Found endgame door 2 clip.");
		//endgame_door2_clip NotSolid();
	}
	
	//Set our trigger properties
	endgame_trigger setCursorHint("HINT_NOICON");
	endgame_trigger setHintString(AYZ_DOORPROMPT_LOCKDOWN_UNFINISHED);
	endgame_trigger SetVisibleToAll();
	
	//Wait for the lockdown to finish
	self waittill("ayz_lockdown_completed");
	
	//Re-set our trigger properties
	endgame_trigger setHintString("A keycard is required to open this door.");
	
	//Wait for the door to be activated
	while(1) {
		endgame_trigger waittill("trigger", player);
		if(!level.key_obtained)
		{
			wait 0.1;
			player playsound("zmb_no_cha_ching");
			continue; //No keycard found on player. Not gonna let them past.
		}
		player playsound("zmb_cha_ching");
		break; //Keycard has been used! Proceed...
	}
	
	//Move door 1 and clip
	endgame_door1 MoveTo(endgame_door1_move.origin, 2, 1, 1);
	endgame_door1_clip MoveTo(endgame_clip1_move.origin, 2, 1, 1);
	
	//Move door 2 and clip
	endgame_door2 MoveTo(endgame_door2_move.origin, 2, 1, 1);
	endgame_door2_clip MoveTo(endgame_clip2_move.origin, 2, 1, 1);
	
	//NEW! CHANGE DOOR FLASHER AND MOVE ON VECTOR
	door_flasher = GetEnt("endgame_door_flasher", "targetname");
	door_flasher SetModel("ayz_new_door_lights_open");
	door_flasher MoveTo((door_flasher.origin + (59.862, -38.763, 1)), 2, 1, 1);
	
	//Play door sound at location
	endgame_door1 PlaySound("zm_alien_isolation__largedoor_open");
	
	//Set the flag to let our program know the door is open
	level flag::set("endgame_opened");
	
	//Hide trigger
	endgame_trigger setCursorHint("HINT_NOICON");
	endgame_trigger setHintString("");
	endgame_trigger SetInvisibleToAll();
	
	//Moved verlaine's initial broadcast to the objective function. Now happens when power is on.
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


//Random background sounds function, doesn't need to be provoked it will just randomly fire every now and again
function random_background_sounds() {
	//Wait for players to arrive at Sevastopol first. No xeno on Torrens ON SPAWN...
	self waittill("players_on_sevastopol");
	
	//End on arrival at tow platform - we start up new ambient sounds there.
	self endon("arrived_at_tow_platform");

	//Loop forever, when we reach the end of the 23 sounds we want to start all over again so it's not too quiet
	//The loop will cycle through two different "playlist" orders to make it seem more random (slightly different times too)
	while (true) {
		if (randomintrange(1,100) > 50) {
			//Loop through all 23 sounds FORWARDS
			loopcount = 0;
			while (loopcount < 23) {
				loopcount = loopcount + 1;
				
				//Wait anywhere from 100 to 250 secs between sound clips
				wait(randomintrange(100,250));
				
				//Play background sound
				play_sound_locally("zm_alien_isolation__bg_"+loopcount);
			}
		} else {
			//Loop through all 23 sounds BACKWARDS
			loopcount = 23;
			while (loopcount > 0) {
				//Wait anywhere from 150 to 300 secs between sound clips
				wait(randomintrange(150,300));
					
				//Play background sound
				play_sound_locally("zm_alien_isolation__bg_"+loopcount);
				
				loopcount = loopcount - 1;
			}
		}
	}
}


//ADVERTS ceiling fan anims
function adverts_fan_anims() {
	//Pre-define rotation speed for easy modding
	ranRotationSpeed = 85;

	//Fan one - GONE!
	//fan_one = getEnt("adverts_anim_fan_one", "targetname");
	//fan_one Rotate((0,ranRotationSpeed,0));
	
	//Fan two
	fan_two = getEnt("adverts_anim_fan_two", "targetname");
	fan_two Rotate((0,ranRotationSpeed,0));
	
	//Fan three
	fan_three = getEnt("adverts_anim_fan_three", "targetname");
	fan_three Rotate((0,ranRotationSpeed,0));
	
	//Fan four
	fan_four = getEnt("adverts_anim_fan_four", "targetname");
	fan_four Rotate((0,ranRotationSpeed,0));
	
	//Fan five
	fan_five = getEnt("adverts_anim_fan_five", "targetname");
	fan_five Rotate((0,ranRotationSpeed,0));
	
	//Fan six
	fan_six = getEnt("adverts_anim_fan_six", "targetname");
	fan_six Rotate((0,ranRotationSpeed,0));
}


//ADVERTS right door
function adverts_right_door() {
	//Get trigger
	getTrigger = getEnt("zombie_door_adverts_right", "targetname");
	
	//Get door parts
	doorSide1 = getEnt("adverts_right_buyable_door_side1", "targetname");
	doorSide2 = getEnt("adverts_right_buyable_door_side2", "targetname");
	
	//Get clip parts
	clipSide1 = getEnt("adverts_right_buyable_door_side1_clip", "targetname");
	clipSide2 = getEnt("adverts_right_buyable_door_side2_clip", "targetname");
	
	//Get 42 to move and struct
	rightSide42 = getEnt("42_right_door", "targetname");
	rightSide42StructPre = struct::get_array("adverts_door_right_42", "targetname");
	
	//Get door move structs
	doorSide1MovePre = struct::get_array("adverts_right_buyable_door_side1_move", "targetname");
	clipSide1MovePre = struct::get_array("adverts_right_buyable_clip_side1_move", "targetname");
	doorSide2MovePre = struct::get_array("adverts_right_buyable_door_side2_move", "targetname");
	clipSide2MovePre = struct::get_array("adverts_right_buyable_clip_side2_move", "targetname");
	
	//Process door move structs
	foreach(ent in doorSide1MovePre) {
		doorSide1Move = ent;
	}
	foreach(ent in clipSide1MovePre) {
		clipSide1Move = ent;
	}
	foreach(ent in doorSide2MovePre) {
		doorSide2Move = ent;
	}
	foreach(ent in clipSide2MovePre) {
		clipSide2Move = ent;
	}
	
	//Process our 42 struct
	foreach(ent in rightSide42StructPre) {
		rightSide42Struct = ent;
	}
	
	//Set our trigger properties
	getTrigger setCursorHint("HINT_NOICON");
	getTrigger setHintString(&"ZOMBIE_NEED_POWER");
	getTrigger SetVisibleToAll();
	
	//Wait until power is activated
	level flag::wait_till("power_on");
	
	//Re-set our trigger properties
	getTrigger setCursorHint("HINT_NOICON");
	getTrigger setHintString(&"ZOMBIE_BUTTON_BUY_OPEN_DOOR_COST", 2500); //update this
	getTrigger SetVisibleToAll();
	
	//Wait for the door to be purchased before starting anything
	while(1) {
		getTrigger waittill("trigger", player);
		if(player.score < 2500)
		{
			wait 0.1;
			player playsound("zmb_no_cha_ching");
			continue;
		}
		player zm_score::minus_to_player_score(2500); 
		player playsound("zmb_cha_ching");
		break; //We've got enough money!
	}
	
	//Hide trigger
	getTrigger setCursorHint("HINT_NOICON");
	getTrigger setHintString("");
	getTrigger SetInvisibleToAll();
	
	//Move door 1 and clip
	doorSide1 MoveTo(doorSide1Move.origin, 2, 1, 1);
	clipSide1 MoveTo(clipSide1Move.origin, 2, 1, 1);
	
	//Move door 2 and clip
	doorSide2 MoveTo(doorSide2Move.origin, 2, 1, 1);
	clipSide2 MoveTo(clipSide2Move.origin, 2, 1, 1);
	
	//NEW! CHANGE DOOR FLASHER AND MOVE ON VECTOR
	door_flasher = GetEnt("right_door_flasher", "targetname");
	door_flasher SetModel("ayz_new_door_lights_open");
    door_flasher_move = struct::get("adverts_right_toggle_move", "targetname");
	door_flasher MoveTo(door_flasher_move.origin, 2, 1, 1); //Changed to struct from pre-set vector
	
	//Move the 42
	rightSide42 MoveTo(rightSide42Struct.origin, 2, 1, 1);
	
	//Play door sound at location
	doorSide1 PlaySound("zm_alien_isolation__largedoor_open");
	
	//Wait for everything to finish
	wait(2);
	
	//Play ADVERTS theme (if not already played)
	if (level.adverts_theme_played != true) {
		play_sound_locally("zm_alien_isolation__open_adverts");
		level.adverts_theme_played = true;
	}
}


//ADVERTS left door
function adverts_left_door() {
	//Get trigger
	getTrigger = getEnt("zombie_door_adverts_left", "targetname");
	
	//Get door parts
	doorSide1 = getEnt("adverts_left_buyable_door_side1", "targetname");
	doorSide2 = getEnt("adverts_left_buyable_door_side2", "targetname");
	
	//Get clip parts
	clipSide1 = getEnt("adverts_left_buyable_door_side1_clip", "targetname");
	clipSide2 = getEnt("adverts_left_buyable_door_side2_clip", "targetname");
	
	//Get 42 to move and struct
	leftSide42 = getEnt("42_left_door", "targetname");
	leftSide42StructPre = struct::get_array("adverts_door_left_42", "targetname");
	
	//Get door move structs
	doorSide1MovePre = struct::get_array("adverts_left_buyable_door_side1_move", "targetname");
	clipSide1MovePre = struct::get_array("adverts_left_buyable_clip_side1_move", "targetname");
	doorSide2MovePre = struct::get_array("adverts_left_buyable_door_side2_move", "targetname");
	clipSide2MovePre = struct::get_array("adverts_left_buyable_clip_side2_move", "targetname");
	
	//Process door move structs
	foreach(ent in doorSide1MovePre) {
		doorSide1Move = ent;
	}
	foreach(ent in clipSide1MovePre) {
		clipSide1Move = ent;
	}
	foreach(ent in doorSide2MovePre) {
		doorSide2Move = ent;
	}
	foreach(ent in clipSide2MovePre) {
		clipSide2Move = ent;
	}
	
	//Process our 42 struct
	foreach(ent in leftSide42StructPre) {
		leftSide42Struct = ent;
	}
	
	//Set our trigger properties
	getTrigger setCursorHint("HINT_NOICON");
	getTrigger setHintString(&"ZOMBIE_NEED_POWER");
	getTrigger SetVisibleToAll();
	
	//Wait until power is activated
	level flag::wait_till("power_on");
	
	//Re-set our trigger properties
	getTrigger setCursorHint("HINT_NOICON");
	getTrigger setHintString(&"ZOMBIE_BUTTON_BUY_OPEN_DOOR_COST", 2500); //update this
	getTrigger SetVisibleToAll();
	
	//Wait for the door to be purchased before starting anything
	while(1) {
		getTrigger waittill("trigger", player);
		if(player.score < 2500)
		{
			wait 0.1;
			player playsound("zmb_no_cha_ching");
			continue;
		}
		player zm_score::minus_to_player_score(2500); 
		player playsound("zmb_cha_ching");
		break; //We've got enough money!
	}
	
	//Hide trigger
	getTrigger setCursorHint("HINT_NOICON");
	getTrigger setHintString("");
	getTrigger SetInvisibleToAll();
	
	//Move door 1 and clip
	doorSide1 MoveTo(doorSide1Move.origin, 2, 1, 1);
	clipSide1 MoveTo(clipSide1Move.origin, 2, 1, 1);
	
	//Move door 2 and clip
	doorSide2 MoveTo(doorSide2Move.origin, 2, 1, 1);
	clipSide2 MoveTo(clipSide2Move.origin, 2, 1, 1);
	
	//NEW! CHANGE DOOR FLASHER AND MOVE ON VECTOR
	door_flasher = GetEnt("left_door_flasher", "targetname");
	door_flasher SetModel("ayz_new_door_lights_open");
	door_flasher MoveTo((door_flasher.origin + (71.236, -4, 1)), 2, 1, 1); //-4 was originally -3.394
	
	//Move the 42
	leftSide42 MoveTo(leftSide42Struct.origin, 2, 1, 1);
	
	//Play door sound at location
	doorSide1 PlaySound("zm_alien_isolation__largedoor_open");
	
	//Wait for everything to finish
	wait(2);
	
	//Play ADVERTS theme (if not already played)
	if (level.adverts_theme_played != true) {
		play_sound_locally("zm_alien_isolation__open_adverts");
		level.adverts_theme_played = true;
	}
}


//Keycard Scripts (sets our key_obtained value and also hides when triggered)
function keycard_setup() {
	//Make sure to set our key as being NOT obtained so we can't open the ending
    level.key_obtained = false;
	
	//Set prompt on trigger
    key = GetEnt("keycard_trigger", "targetname");
    key SetCursorHint("HINT_NOICON");
    key SetHintString("Hold ^3[{+activate}]^7 to pick up keycard");
	
	//Wait for the trigger to be activated, then hide keycard and prompt
    key waittill("trigger", player);
    model = GetEnt(key.target, "targetname"); //Will grab the target of our trigger (the keycard)
    model delete(); //Gone
	key SetVisibleToAll();
    key delete(); //Just to be sure
	
	//We've obtained the keycard! Set our variable and update the door prompt. Also play a sound to confirm.
	play_sound_locally("zm_alien_isolation_keycard");
    level.key_obtained = true;
	iprintlnbold("Keycard acquired."); //Looks messy, but whatever. No HUD editing tools = this.
	
	//But first, grab our door trigger ent (really messy way of doing it, but whatever)
	ent_parts_endgame_trigger = GetEntArray("zombie_door_custom", "targetname");
	endgamedoor_loop = 0;
	foreach(ent_endgame_trigger in ent_parts_endgame_trigger) {
		endgamedoor_loop = endgamedoor_loop + 1;
		/*
			Loop 1 = Buyable Ending Door
			Loop 2 = Spawnroom Door
		*/
		if (endgamedoor_loop == 1) {
			endgame_trigger = ent_endgame_trigger;
		}
	}
	
	//Update our door prompt
	endgame_trigger setCursorHint("HINT_NOICON");
	endgame_trigger setHintString("Hold ^3[{+activate}]^7 to use keycard");
	endgame_trigger SetVisibleToAll();
}


//Buyable ending script - modified from the original UGX one
function buyable_ending() {
	//Get Spaceflight Terminal elevator clip and remove the collision
	elevatorClip_SpaceflightTerminal = getEnt("sft_clip", "targetname");
	elevatorClip_SpaceflightTerminal NotSolid();
	
	//Get elevator area and make it able to be walked in
	elevator_area = getEnt("ayz_elevator_area", "targetname");
	elevator_area NotSolid();

	//Get our buyable ending trigger
	ending = getEnt("ending", "targetname");
	
	//Set our trigger properties
	ending setCursorHint("HINT_NOICON");
	ending setHintString(&"ZOMBIE_NEED_POWER");
	
	//Wait until power is activated
	level flag::wait_till("power_on");
	
	//Depending on the number of players, calculate the endgame cost
	player_counter = 0;
	players = GetPlayers();
	foreach(player in players) {
		player_counter = player_counter + 1;
	}
	if (player_counter == 1) {
		endgameCost = 50000;
	}
	if (player_counter == 2) {
		endgameCost = 45000;
	}
	if (player_counter == 3) {
		endgameCost = 40000;
	}
	if (player_counter == 4) {
		endgameCost = 40000;
	}
	
	//Re-set our trigger properties
	ending setCursorHint("HINT_NOICON");
	//ending setHintString("TO TOW PLATFORM [&&1] - " + endgameCost + " points");
	ending setHintString("Hold ^3[{+activate}]^7 to activate Elevator [Cost: " + endgameCost + "]");
	
	//Handle the activation of the trigger. It might be that we don't have enough money.
	while(1) {
		ending waittill("trigger", player);
		
		//Make sure we've got enough money
		if(player.score < endgameCost)
		{
			wait 0.1;
			player playsound("zmb_no_cha_ching");
			continue;
		}
		
		//Make sure all players are in the zone
		all_players = GetPlayers();
		total_players = 0;
		players_in_zone = 0;
		foreach (player_checker in all_players) {
			if (player_checker IsTouching(elevator_area) == true) {
				players_in_zone += 1;
			}
			//if(!(player_checker laststand::player_is_in_laststand()) && !(player_checker.sessionstate == "spectator")) { - INCLUDES DOWNED PLAYERS
			if(!(player_checker.sessionstate == "spectator")) {
				total_players += 1; //only add up ALIVE players. DEAD players can't get in the elevator!
			}
		}
		if (players_in_zone != total_players) {
			wait 0.1;
			player playsound("zmb_no_cha_ching");
			iprintlnbold("All players must be inside the elevator!");
			//iprintlnbold("IN_ZONE: " + players_in_zone + " - TOTAL: " + total_players);
			continue;
		}
		
		//We're alright to proceed! Take the money and break out.
		player zm_score::minus_to_player_score(endgameCost); 
		player playsound("zmb_cha_ching");
		break; 
	}

	//Endgame purchased - hide the trigger and call "handle_ayz_elevator()" to process the elevator functions
	ending SetInvisibleToAll();
	handle_ayz_elevator();
}


//Elevator Script
function handle_ayz_elevator() {
	//Play elevator sound effects - TOTAL OF 19.56 SECONDS
	play_sound_locally("zm_alien_isolation_sfx_elevator");
	
	
	//Get Spaceflight Terminal elevator clip and remove the collision
	elevatorClip_SpaceflightTerminal = getEnt("sft_clip", "targetname");
	elevatorClip_SpaceflightTerminal Solid();
	
	
	//Pause zombie spawns
	SetDvar("ai_disableSpawn", "1");
	
	
	//Grab our door models
	elevatorDoor_SpaceflightTerminal_SideOne = getEnt("sft_elevator_sideone", "targetname");
	elevatorDoor_SpaceflightTerminal_SideTwo = getEnt("sft_elevator_sidetwo", "targetname");
	
	//Grab our door struct
    elevatorStruct_SpaceflightTerminal = struct::get("sft_elevator_struct", "targetname");
	
	//Move our door models to door structs
	elevatorDoor_SpaceflightTerminal_SideOne MoveTo(elevatorStruct_SpaceflightTerminal.origin, 3.23, 1.5, 1.5);
	elevatorDoor_SpaceflightTerminal_SideTwo MoveTo(elevatorStruct_SpaceflightTerminal.origin, 3.23, 1.5, 1.5);
	
	//Wait for MOST OF door animation to finish
	wait(2.79);
	
	//Make sure door is dynamicly blocked to zombies & bullets (needs more testing, but i think it works)
    elevator_sft_zombie_blocker_moveto = struct::get("sft_elevator_zombo_blocker", "targetname");
	elevator_sft_zombie_blocker_clip = getEnt("sft_elevator_zombo_blocker_clip", "targetname");
	elevator_sft_zombie_blocker_bulletclip = getEnt("sft_elevator_zombo_blocker_bullet", "targetname");
	elevator_sft_zombie_blocker_clip MoveTo(elevator_sft_zombie_blocker_moveto.origin, 0.001); //gotta be super quick with this one.
	elevator_sft_zombie_blocker_bulletclip MoveTo(elevator_sft_zombie_blocker_moveto.origin, 0.001); //gotta be super quick with this one.
	
	//Give all zombies a POI now that the players are off limits (this is our failsafe)
    newPoiSft = struct::get("sft_zombie_poi", "targetname");
	newPoiSft zm_utility::create_zombie_point_of_interest(5000, 500, 10000); //5000 dist, 500 zombs
	newPoiSft.attract_to_origin = true;
	
	//Wait for THE REST OF door animation to finish
	wait(0.8);
	
	
	//Let our scripts know we're moving! We can start our FX.
	level notify("ayz_elevator_moving");
	

	//Wait until we're half way through the transition
	wait(5.11);
	
	//Fade screen to black to hide transition
	lui::screen_fade_out(1);
	
	//Get all players
	players = GetPlayers();
	
	//Move every player
	loopCounter = 0;
	foreach (player in players) {
		//Iterate loop
		loopCounter = loopCounter + 1;
		
		//Get destination struct (we have 1,2,3,4)
		destination = struct::get("ayz_elevator_destination_" + loopCounter, "targetname");
		
		//Only move if player is alive.
		//if(!(player laststand::player_is_in_laststand()) && !(player.sessionstate == "spectator")) { - FOR DOWNED AND DEAD
		//if(!(player.sessionstate == "spectator")) { - FOR DEAD ONLY
			//Move player
			player setorigin(destination.origin);
			
			//Correct elevator rotation during teleport (NEEDS FIXING)
			player setplayerangles(player.angles + (0,-60,0));
		//}
	}
	
	//Wait a bit
	wait(0.5);
	
	//Fade screen in from black to finish hiding transition
	lui::screen_fade_in(1);
	
	
	//DEBUG TEXT
	//iprintlnbold("DEBUG: MOVED " + loopCounter + " PLAYER(S)");
	
	
	//Wait for transition sound to finish.
	wait(5.11);
	
	
	//Let our scripts know we've arrived! We can stop our FX.
	level notify("ayz_elevator_arrived");
	
	
	//Get all spawners
	allSpawners = struct::get_array("initial_spawn_points", "targetname");
	
	//Loop through all spawners
	loopCounter = 0;
	foreach (currentSpawner in allSpawners) {
		loopCounter = loopCounter + 1;
		
		//Grab our new position
		spawnerStructNew = struct::get("tpf_spawners_" + loopCounter, "targetname");
		
		//Move to new position
		currentSpawner.origin = spawnerStructNew.origin;
	}
	
	//Grab original and new respawn struct
    respawnOrigStruct = struct::get("player_respawn_point", "targetname");
    respawnMoveStruct = struct::get("tpf_spawners_9", "targetname");
	
	//Move original to new
	respawnOrigStruct.origin = respawnMoveStruct.origin;
	
	
	//Get all zombies currently spawned (should now be a stable number)
	zombies = GetAiTeamArray("axis"); //Changed to "axis" from "level.zombie_team"
	
	//Kill all spawned zombies
	debug_count = 0;
	foreach (zombie in zombies) {
		zombie dodamage( zombie.health + 666, zombie.origin );
		debug_count = debug_count + 1;
	}
	
	
	//Start warning lights in tow platform
	start_warning_lights_TowPlatform();
	
	
	//Grab our door models
	elevatorDoor_TowPlatform_SideOne = getEnt("tpf_elevator_sideone", "targetname");
	elevatorDoor_TowPlatform_SideTwo = getEnt("tpf_elevator_sidetwo", "targetname");
	
	//Grab our door structs
    elevatorStruct_TowPlatform_SideOne = struct::get("tpf_elevator_sideone_struct", "targetname");
    elevatorStruct_TowPlatform_SideTwo = struct::get("tpf_elevator_sidetwo_struct", "targetname");
	
	//Move our door models to door structs
	elevatorDoor_TowPlatform_SideOne MoveTo(elevatorStruct_TowPlatform_SideOne.origin, 3.59, 1.5, 1.5);
	elevatorDoor_TowPlatform_SideTwo MoveTo(elevatorStruct_TowPlatform_SideTwo.origin, 3.59, 1.5, 1.5);
	
	//Get Tow Platform elevator clips
	elevatorClip_TowPlatform1 = getEnt("tpf_clip_side1", "targetname");
	elevatorClip_TowPlatform2 = getEnt("tpf_clip_side2", "targetname");
	
	//Grab Tow Platform elevator clip structs
    elevatorStruct_TowPlatform_SideOne_Struct = struct::get("tpf_clip_side1_moveto", "targetname");
    elevatorStruct_TowPlatform_SideTwo_Struct = struct::get("tpf_clip_side2_moveto", "targetname");
	
	//Move clips
	elevatorClip_TowPlatform1 MoveTo(elevatorStruct_TowPlatform_SideOne_Struct.origin, 3.59, 1.5, 1.5);
	elevatorClip_TowPlatform2 MoveTo(elevatorStruct_TowPlatform_SideTwo_Struct.origin, 3.59, 1.5, 1.5);
	
	//Wait for door animation to finish
	wait(3.59);
	
	
	//Kill our zombie POI over in SFT just in case
	newPoiSft zm_utility::deactivate_zombie_point_of_interest();
	
	
	//We're all done! Move on to the Tow Platform scripts. Don't forget zombie spawns are still disabled.
	ayz_tow_platform_challenge();
}


//Override for round waiting time (TPF ONLY!!)
function round_wait_override()
{
	level endon("restart_round");
	level endon( "kill_round" );

	wait( 1 );

	while( 1 )
	{
		should_wait = ( level.zombie_total > 0 || level.intermission );	
		if( !should_wait )
		{
			return;
		}			
			
		if( level flag::get( "end_round_wait" ) )
		{
			return;
		}
		wait( 1.0 );
	}
}


//Tow Platform "Challenge" Script
function ayz_tow_platform_challenge(skipTerminals) {
	//Turn off all zones in the Spaceflight Terminal to kill any remaining entities up there.
	//Shouldnt be any left, but just in case.
	
	
	//Alert any other scripts that we've arrived - specifically ambient sounds in spaceflight terminal, etc
	self notify("arrived_at_tow_platform");
	
	
	//Turn off zombie failsafe to stop zombies dying
	zombie_utility::set_zombie_var("zombie_use_failsafe", false);
	
	
	//Before we re-enable zombies, make sure we get rid of dogs. Hopefully this doesn't impact current dog rounds.
	//I've put dog spawners in the new area because of this.
	level.next_dog_round = 9999; 
	
	
	//GET ALL TRIGGERS NOW
	dockingClampTrigger1 = getEnt("dockingClampTrigger1", "targetname");
	dockingClampTrigger2 = getEnt("dockingClampTrigger2", "targetname");
	airlockPressureTrigger = getEnt("airlockPressureTrigger", "targetname");
	airlockZone = getEnt("tow_airlock_zone", "targetname");
	airlockZone NotSolid();
	
	//PRE-SET ALL HINT STRINGS NOW
	dockingClampTrigger1 setCursorHint("HINT_NOICON");
	dockingClampTrigger1 setHintString("");
	dockingClampTrigger2 setCursorHint("HINT_NOICON");
	dockingClampTrigger2 setHintString("");
	airlockPressureTrigger setCursorHint("HINT_NOICON");
	airlockPressureTrigger setHintString("");
	
	if (!skipTerminals) {
		//Play the "Tow Platform Theme" and wait for it to finish
		play_sound_locally("zm_alien_isolation__enter_towplatform");
		wait(18);
		
		//Play a new verlaine broadcast as a prompt to start working on the clamps.
		play_sound_locally("zm_alien_isolation__verlaine_activate_clamps");
		wait(13);
		
		
		//Limit the number of zombies that can spawn based on the number of players
		player_counter = 0;
		players = GetPlayers();
		foreach(player in players) {
			player_counter = player_counter + 1;
		}
		if (player_counter == 1) {
			level.zombie_ai_limit = 9; //Only one player. 
		}
		if (player_counter == 2) {
			level.zombie_ai_limit = 9; //Two players. 
		}
		if (player_counter == 3) {
			level.zombie_ai_limit = 8; //Three players. 
		}
		if (player_counter == 4) {
			level.zombie_ai_limit = 7; //Four players. 
		}
		//Might seem drastic since default is 24, but this area is small and more players makes it harder.
		
		
		//Change delay between zombie rounds and spawns
		level.round_wait_func = &round_wait_override; //remove rounds, new for 3+
		level.zombie_vars["zombie_between_round_time"] = 0;  
		level.zombie_round_start_delay = 0; //default = 2, custom WAS 4 - new for 3+ 0
		
		
		//Restart zombie spawning 
		SetDvar("ai_disableSpawn", "0");
		
		
		//Give all perks and max ammo
		give_perks_and_ammo();
		
		
		//We're ready to start the docking clamp! ... Show objective and enable trigger.
		thread show_new_objective("Activate the first Docking Clamp terminal.");
		
		//Set our trigger properties
		dockingClampTrigger1 setHintString("Press ^3[{+activate}]^7 to activate Docking Clamp Terminal One");
		
		//Wait until DOCKING CLAMP 1 is triggered...
		dockingClampTrigger1 waittill("trigger", player);
		dockingClampTrigger1 SetInvisibleToAll();
		
		//Grab our monitors
		dock_clamp_terminal_1_monitor_1 = GetEnt("tow_activate_1_monitor1", "targetname");
		dock_clamp_terminal_1_monitor_2 = GetEnt("tow_activate_1_monitor2", "targetname");
		
		//Change Dock Clamp Terminal 1 Monitors
		dock_clamp_terminal_1_monitor_1 PlaySound("zm_alien_isolation__tow_monitor_change"); //sfx
		dock_clamp_terminal_1_monitor_1 SetModel("monitor_static_trace_orange"); //orange
		dock_clamp_terminal_1_monitor_2 SetModel("monitor_static_trace_orange"); //orange
		wait(2.5);
		dock_clamp_terminal_1_monitor_1 PlaySound("zm_alien_isolation__tow_monitor_changed"); //sfx
		dock_clamp_terminal_1_monitor_1 SetModel("monitor_static_trace"); //green
		dock_clamp_terminal_1_monitor_2 SetModel("monitor_static_trace"); //green
		
		//Objective complete
		wait(0.5);
		completed_old_objective();
		
		//Wait
		wait(0.5);
		
		//Play SFX
		self notify("start_alarms_at_towplatform");
		
		//Start flashing lights
		level util::set_lighting_state(3);
		
		//Wait a bit
		wait(4);
			
			
		//We're ready to start the SECOND docking clamp! ... Show objective and enable trigger.
		thread show_new_objective("Activate the second Docking Clamp terminal.");
		
		//Set our trigger properties
		dockingClampTrigger2 setHintString("Press ^3[{+activate}]^7 to activate Docking Clamp Terminal Two");
		
		//Wait until DOCKING CLAMP 2 is triggered...
		dockingClampTrigger2 waittill("trigger", player);
		dockingClampTrigger2 SetInvisibleToAll();
		
		//Grab our monitors
		dock_clamp_terminal_2_monitor_1 = GetEnt("tow_activate_2_monitor1", "targetname");
		dock_clamp_terminal_2_monitor_2 = GetEnt("tow_activate_2_monitor2", "targetname");
		
		//Change Dock Clamp Terminal 2 Monitors
		dock_clamp_terminal_2_monitor_1 PlaySound("zm_alien_isolation__tow_monitor_change"); //sfx
		dock_clamp_terminal_2_monitor_1 SetModel("monitor_static_trace_orange"); //orange
		dock_clamp_terminal_2_monitor_2 SetModel("monitor_static_trace_orange"); //orange
		wait(2.5);
		dock_clamp_terminal_2_monitor_1 PlaySound("zm_alien_isolation__tow_monitor_changed"); //sfx
		dock_clamp_terminal_2_monitor_1 SetModel("monitor_static_trace"); //green
		dock_clamp_terminal_2_monitor_2 SetModel("monitor_static_trace"); //green
		
		//Objective complete
		wait(0.5);
		completed_old_objective();
		
		
		//We're all done with the docking clamps. Play some sounds and animate the clamp moving.
		towPlatform_AnimateDockingClamp();
		
		//Stop all alarm sounds, we're done
		level notify("stop_alarms_at_towplatform");
		
		//Stop flashing lights
		level util::set_lighting_state(2);
	}
	
	//Play airlock intro.
	play_sound_locally("zm_alien_isolation__airlock_intro");
	wait(5);
	
	
	//We're done with docking clamp terminals! Get verlaine to tell us to go to the airlock.
	play_sound_locally("zm_alien_isolation__verlaine_get_to_airlock");
	wait(8);
	
	
	//We're ready to pressurise the airlock. Show the objective.
	thread show_new_objective("Pressurise the airlock.");
	
	//Set our trigger properties
	airlockPressureTrigger setHintString("Press ^3[{+activate}]^7 to Pressurise the Airlock");
	
	//Wait until airlock pressurisation is triggered...
	airlockPressureTrigger waittill("trigger", player);
	airlockPressureTrigger SetInvisibleToAll();
	
	
	//Animate button
	towAirlockButton = getEnt("tow_button_scripted", "targetname");
	towAirlockButton PlaySound("zm_alien_isolation__transit_button");
	towAirlockButton MoveTo(towAirlockButton.origin + (0.25, 0, 0), 0.5, 0.25, 0.25);
	wait(0.5); //button in
	towAirlockButton MoveTo(towAirlockButton.origin - (0.25, 0, 0), 0.5, 0.25, 0.25);
	wait(0.5); //button out
	
	//Update monitor
	towAirlockMonitor = getEnt("tow_airlock_monitor", "targetname");
	towAirlockMonitor SetModel("monitor_50cm_airlock_state02");
	
	//Give all perks again just in-case someone has died
	a_str_perks = GetArrayKeys(level._custom_perks);
	foreach(str_perk in a_str_perks)
	{
		if(!player HasPerk(str_perk))
		{
			player zm_perks::give_perk(str_perk, false);
		}
	}
	
	//Now we begin the waiting game. The airlock has to pressurise over TWO MINUTES.
	//0 seconds - 0% complete
	play_sound_locally("zm_alien_isolation__airlock_0percent");
	
	//HUD counter pls
	thread airlock_pressure_counter();
	
	wait(5);
	
	//Show objective in the middle of this... (have updated wait time on each side)
	thread show_new_objective("Survive while the airlock pressurises.");
	
	wait(5);
	
	
	//Change the zombie limit again
	player_counter = 0;
	players = GetPlayers();
	foreach(player in players) {
		player_counter = player_counter + 1;
	}
	if (player_counter == 1) {
		level.zombie_ai_limit = 12; //Only one player. 
	}
	if (player_counter == 2) {
		level.zombie_ai_limit = 11; //Two players. 
	}
	if (player_counter == 3) {
		level.zombie_ai_limit = 10; //Three players. 
	}
	if (player_counter == 4) {
		level.zombie_ai_limit = 9; //Four players. 
	}
	
	
	//Start to play airlock music during this.. (again wait times are updated)
	play_sound_locally("zm_alien_isolation__alt_final_action_cut");
	
	wait(20);
	
	//30 seconds - 25% complete
	play_sound_locally("zm_alien_isolation__airlock_25percent");
	
	wait(30);
	
	//60 seconds - 50% complete
	play_sound_locally("zm_alien_isolation__airlock_50percent");
	
	wait(30);
	
	//90 seconds - 75% complete
	play_sound_locally("zm_alien_isolation__airlock_75percent");
	
	wait(30);
	
	//180 seconds - 100% complete
	play_sound_locally("zm_alien_isolation__airlock_complete");
	
	//Update monitor & wait 3 secs for sound to finish
	towAirlockMonitor SetModel("monitor_50cm_airlock_state03");
	wait(3);
	
	
	//Door is gonna open! Play VO.
	play_sound_locally("zm_alien_isolation__airlock_standclear");
	
	//Get airlock door, clip and struct
	airlock_door = getEnt("tow_airlock_door", "targetname");
	airlock_door_clip = getEnt("tow_airlock_door_clip", "targetname");
    airlock_door_moveto = struct::get("tow_airlock_door_move", "targetname");
	
	//Grab current airlock door origin for using later when we close it (saves us another struct!)
	airlock_door_original_origin = airlock_door.origin;
	
	//Open airlock door
	airlock_door MoveTo(airlock_door_moveto.origin, 2, 1, 1);
	
	//Play door sound at location
	airlock_door PlaySound("zm_alien_isolation__smalldoor_open");
	
	//Remove clipping
	wait(2);
	airlock_door_clip NotSolid();
	
	
	//We're ready to leave! Show the objective and play music.
	thread show_new_objective("Everybody get to the airlock!");
	play_sound_locally("zm_alien_isolation__final_action_ost");
	
	
	//Wait for everyone to get in the airlock...
	while(1) {
		all_players = GetPlayers();
		total_players = 0;
		players_in_zone = 0;
		foreach (player in all_players) {
			if (player IsTouching(airlockZone) == true) {
				players_in_zone += 1;
			}
			//if(!(player laststand::player_is_in_laststand()) && !(player.sessionstate == "spectator")) { - INCLUDES DOWNED PLAYERS
			if(!(player.sessionstate == "spectator")) {
				total_players += 1; //only add up ALIVE players. DEAD players can't get in!
			}
		}
		if (players_in_zone != total_players) {
			wait 0.1;
			//iprintlnbold("IN_ZONE: " + players_in_zone + " - TOTAL: " + total_players);
			continue;
		}
		
		//We're getting off this ship!
		break; 
	}
	
	
	//Stop zombies spawning
	SetDvar("ai_disableSpawn", "1");
	
	
	//Give all zombies a POI as door is about to close
    newPoiTpf = struct::get("tpf_poi_onending", "targetname");
	newPoiTpf zm_utility::create_zombie_point_of_interest(5000, 500, 10000); //5000 dist, 500 zombs
	newPoiTpf.attract_to_origin = true;
	
	
	//Add clipping back straight away to stop people getting out
	airlock_door_clip Solid();
	
	//Close door
	airlock_door MoveTo(airlock_door_original_origin, 2, 1, 1);
	
	//Play door sound at location
	airlock_door PlaySound("zm_alien_isolation__smalldoor_open");
	
	//Wait for door to close
	wait(2);
	
	//Play a sting as we finish - don't forget the final ending theme is still going
	play_sound_locally("zm_alien_isolation__endgame_sting");
	
	//Wait a little while so players can see airlock
	wait(3);
	
	//Pre-load cutscene pls for those with old pcs
	level thread lui::prime_movie(AYZ_CUTSCENE_ID_03);
	
	//Freeze players and play endgame cutscene
	foreach(player in level.players) {
        player FreezeControls(true);
    }
	lui::screen_fade_out(1); //make it a smooth transition
	wait(1);
	level thread lui::play_movie_with_timeout(AYZ_CUTSCENE_ID_03, "fullscreen", 36, true);
	
	
	//Sort out cutscene audio
	play_sound_locally("zm_alien_isolation__cs_ripsev"); //play cutscene music
	stop_sound_locally("zm_alien_isolation__final_action_ost"); //stop our previous music
	stop_sound_locally("zm_alien_isolation__bg_tow_xeno"); //stop specifically our xeno track
	stop_round_start_music(); //just in case
	level notify("kill_towplatform_ambience"); //also don't forget to stop our ambience
	
	//Kill all zombies and MUTE!
	zombies = GetAiTeamArray("axis");
	foreach (zombie in zombies) {
		zombie StopSounds();
		zombie dodamage( zombie.health + 666, zombie.origin );
	}
	
	
	//Wait for the cutscene to finish (-5 seconds for endgame stuff) 
	wait(30); //credits here? or nah
	
	//END THE GAME
	level notify("end_game");
}


//Elevator FX handler
function handle_elevator_fx() {
	//Wait for elevator to start moving
	self waittill("ayz_elevator_moving");
	
	//
	//Grab all our FX structs
	//
	
	//Tow Platform
	elevator_fx1 = struct::get("elevator_fx1", "targetname");
	elevator_fx2 = struct::get("elevator_fx2", "targetname");
	elevator_fx3 = struct::get("elevator_fx3", "targetname");
	elevator_fx4 = struct::get("elevator_fx4", "targetname");
	
	//Spaceflight Terminal
	elevator_fx5 = struct::get("elevator_fx1_tpf", "targetname");
	elevator_fx6 = struct::get("elevator_fx2_tpf", "targetname");
	elevator_fx7 = struct::get("elevator_fx3_tpf", "targetname");
	elevator_fx8 = struct::get("elevator_fx4_tpf", "targetname");
	
	//
	//Play our FX
	//
	
	//Tow Platform
	PlayFX(level._effect["elevator_light"], elevator_fx1.origin);
	PlayFX(level._effect["elevator_light"], elevator_fx2.origin);
	PlayFX(level._effect["elevator_light"], elevator_fx3.origin);
	PlayFX(level._effect["elevator_light"], elevator_fx4.origin);
	
	//Spaceflight Terminal
	PlayFX(level._effect["elevator_light"], elevator_fx5.origin);
	PlayFX(level._effect["elevator_light"], elevator_fx6.origin);
	PlayFX(level._effect["elevator_light"], elevator_fx7.origin);
	PlayFX(level._effect["elevator_light"], elevator_fx8.origin);
	
	//Wait for us to arrive
	self waittill("ayz_elevator_arrived");
}


//Tow Platform warning light anims
function start_warning_lights_TowPlatform() {
	rotationSpeed = 250;
	
	
	lightEnts = getEntArray("tow_warning_light_inner", "targetname");
	foreach (lightEnt in lightEnts) {
		lightEnt Rotate((0,rotationSpeed,0));
	}
	
	
	//This is a real bad way to handle the warning lights, but aparently using foreach makes it buggy - so RIP prefabs and RIP smart code.
	tpfWarningLight0 = getEnt("tow_warning_light_bulb_0", "targetname");
	tpfWarningLight0 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight1 = getEnt("tow_warning_light_bulb_1", "targetname");
	tpfWarningLight1 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight2 = getEnt("tow_warning_light_bulb_2", "targetname");
	tpfWarningLight2 Rotate((0,rotationSpeed,0));
	
	//tpfWarningLight3 = getEnt("tow_warning_light_bulb_3", "targetname");
	//tpfWarningLight3 Rotate((0,rotationSpeed,0));
	
	//tpfWarningLight4 = getEnt("tow_warning_light_bulb_4", "targetname");
	//tpfWarningLight4 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight5 = getEnt("tow_warning_light_bulb_5", "targetname");
	tpfWarningLight5 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight6 = getEnt("tow_warning_light_bulb_6", "targetname");
	tpfWarningLight6 Rotate((0,rotationSpeed,0));
	
	//tpfWarningLight7 = getEnt("tow_warning_light_bulb_7", "targetname");
	//tpfWarningLight7 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight8 = getEnt("tow_warning_light_bulb_8", "targetname");
	tpfWarningLight8 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight9 = getEnt("tow_warning_light_bulb_9", "targetname");
	tpfWarningLight9 Rotate((0,rotationSpeed,0));
	
	//tpfWarningLight10 = getEnt("tow_warning_light_bulb_10", "targetname");
	//tpfWarningLight10 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight11 = getEnt("tow_warning_light_bulb_11", "targetname");
	tpfWarningLight11 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight12 = getEnt("tow_warning_light_bulb_12", "targetname");
	tpfWarningLight12 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight13 = getEnt("tow_warning_light_bulb_13", "targetname");
	tpfWarningLight13 Rotate((0,rotationSpeed,0));
	
	//tpfWarningLight14 = getEnt("tow_warning_light_bulb_14", "targetname");
	//tpfWarningLight14 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight15 = getEnt("tow_warning_light_bulb_15", "targetname");
	tpfWarningLight15 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight16 = getEnt("tow_warning_light_bulb_16", "targetname");
	tpfWarningLight16 Rotate((0,rotationSpeed,0));
	
	//tpfWarningLight17 = getEnt("tow_warning_light_bulb_17", "targetname");
	//tpfWarningLight17 Rotate((0,rotationSpeed,0));
	
	//tpfWarningLight18 = getEnt("tow_warning_light_bulb_18", "targetname");
	//tpfWarningLight18 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight19 = getEnt("tow_warning_light_bulb_19", "targetname");
	tpfWarningLight19 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight20 = getEnt("tow_warning_light_bulb_20", "targetname");
	tpfWarningLight20 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight21 = getEnt("tow_warning_light_bulb_21", "targetname");
	tpfWarningLight21 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight22 = getEnt("tow_warning_light_bulb_22", "targetname");
	tpfWarningLight22 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight23 = getEnt("tow_warning_light_bulb_23", "targetname");
	tpfWarningLight23 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight24 = getEnt("tow_warning_light_bulb_24", "targetname");
	tpfWarningLight24 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight25 = getEnt("tow_warning_light_bulb_25", "targetname");
	tpfWarningLight25 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight26 = getEnt("tow_warning_light_bulb_26", "targetname");
	tpfWarningLight26 Rotate((0,rotationSpeed,0));
	
	tpfWarningLight27 = getEnt("tow_warning_light_bulb_27", "targetname");
	tpfWarningLight27 Rotate((0,rotationSpeed,0));
}


//New Tow Platform ambience - called on map load, but waits for arrival at tow platform.
function random_background_sounds_towPlatform() {
	self waittill("arrived_at_tow_platform");
	self endon("kill_towplatform_ambience");
	
	while (true) {
		play_sound_locally("zm_alien_isolation__bg_tow_xeno");
		wait(110);
	}
}


//This is an awful way to handle these alarm sounds, but it works so whatever.
function play_alarm_loop_towPlatform1() {
	self waittill("start_alarms_at_towplatform");
	self endon("stop_alarms_at_towplatform");
	tow_speaker_1 = getEnt("tow_speaker_1", "targetname");
	while (true) {
		PlaySoundAtPosition("zm_alien_isolation__alarm_full", tow_speaker_1.origin);
		wait(1.97);
	}
}
function play_alarm_loop_towPlatform2() {
	self waittill("start_alarms_at_towplatform");
	self endon("stop_alarms_at_towplatform");
	tow_speaker_2 = getEnt("tow_speaker_2", "targetname");
	while (true) {
		PlaySoundAtPosition("zm_alien_isolation__alarm_alt", tow_speaker_2.origin);
		wait(4.724);
	}
}
function play_alarm_loop_towPlatform3() {
	self waittill("start_alarms_at_towplatform");
	self endon("stop_alarms_at_towplatform");
	tow_speaker_3 = getEnt("tow_speaker_3", "targetname");
	while (true) {
		PlaySoundAtPosition("zm_alien_isolation__alarm_alt2", tow_speaker_3.origin);
		wait(2.438);
	}
}


//Animate the docking clamp and also handle audio.
function towPlatform_AnimateDockingClamp() {
	//Play sfx
	play_sound_locally("zm_alien_isolation__dockingclamp_amb"); //might want to play at position of docking clamp?
	
	//Get clamp and struct
	dockingClamp = getEnt("towplat_dockingclamp", "targetname");
    dockingClampStruct = struct::get("dockingclamp_finalmove", "targetname");
	
	//Move
	wait(6.59);
	dockingClamp MoveTo(dockingClampStruct.origin, 35.87, 10, 25.87);
	
	//Play rumble
    rumbleStruct = struct::get("tow_rumble_origin", "targetname");
	Earthquake( 0.08, 35, rumbleStruct.origin, 99999 ); 
	
	//Wait for sounds and animations to finish (sort of)
	wait(35);
	
	//Done!
	play_sound_locally("zm_alien_isolation__dockingclamp_done");
	wait(3);
}


//End credits script
function ayz_end_credits() {
	thread drawOnHud(" Alien Isolation Zombies ", 100, 100, 3, 18.5, 2);
	
    thread drawOnHud(" Created By ", 100, 75, 1, 5, 1);
    thread drawOnHud(" Matt Filer ", 100, 50, 2, 5, 1);
	wait(5);
	
	wait(0.5);
	
    thread drawOnHud(" Special Thanks ", 100, 75, 1, 4, 1);
    thread drawOnHud(" The Creative Assembly ", 100, 50, 2, 2, 0.5);
	wait(2);
    thread drawOnHud(" 20th Century Fox ", 100, 50, 2, 2, 0.5);
	wait(2);
	
	wait(0.5);
	
    thread drawOnHud(" Extra Special Thanks ", 100, 75, 1, 8, 1);
    thread drawOnHud(" Ridley Scott ", 100, 50, 2, 2, 0.5);
	wait(2);
    thread drawOnHud(" H. R. Giger ", 100, 50, 2, 2, 0.5);
	wait(2);
    thread drawOnHud(" Dan O'Bannon ", 100, 50, 2, 2, 0.5);
	wait(2);
    thread drawOnHud(" Ronald Shusett ", 100, 50, 2, 2, 0.5);
	wait(2);
}


//HUD drawer for End Credits.
function drawOnHud( text, align_x, align_y, font_scale, exist_time, fade_time )
{
    hud = NewHudElem();
    hud.foreground = true;
    hud.fontScale = font_scale;
    hud.sort = 1;
    hud.hidewheninmenu = false;
    hud.alignX = "left";
    hud.alignY = "bottom";
    hud.horzAlign = "left";
    hud.vertAlign = "bottom";
    hud.x = align_x;
    hud.y = hud.y - align_y;
    hud.alpha = 1;
    hud SetText( text );
    wait( exist_time );
    hud fadeOverTime( fade_time );
    hud.alpha = 0;
    wait( fade_time );
    hud Destroy();
}


//HUD ELEMENT FOR TOW PLATFORM AIRLOCK PRESSURISER
function airlock_pressure_counter()
{
	hud = NewHudElem();
    hud.foreground = true;
    hud.fontScale = 2;
    hud.sort = 1;
    hud.hidewheninmenu = false;
    hud.alignX = "left";
    hud.alignY = "bottom";
    hud.horzAlign = "left";
    hud.vertAlign = "bottom";
    hud.x = 80;
    hud.y = hud.y - 50;
    hud.alpha = 1;
	
	percent = 0;
	counter = 0;
	while (counter != 120) {
		hud SetText("Airlock pressurisation " + int(percent) + " percent complete.");
		percent += 0.834;
		counter += 1;
		wait(1);
	}
	
	hud SetText("Airlock pressurisation 100 percent complete.");
	
	wait(5);
    hud fadeOverTime( 5 );
    hud.alpha = 0;
    wait( 5 );
    hud Destroy();
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


//Torrens spawn script
function torrens_intro_sequence(should_skip_cutscenes) {
	//Get all dynamic clips in spawn
	spawnClip1 = getEnt("torrens_spawn_clip_1", "targetname");
	spawnClip2 = getEnt("torrens_spawn_clip_2", "targetname");
	spawnClip3 = getEnt("torrens_spawn_clip_3", "targetname");
	spawnClip4 = getEnt("torrens_spawn_clip_4", "targetname");
	
	//Make clips non-solid - might need to do this earlier
	spawnClip1 NotSolid();
	spawnClip2 NotSolid();
	spawnClip3 NotSolid();
	spawnClip4 NotSolid();

	//Handle control lock
	if (!should_skip_cutscenes) {
		thread spawn_control_lock_override();
	}

	//Disable start-of-game fade-in
	level flag::wait_till("all_players_connected");
	wait(4.999);
	lui::screen_fade_out(0);
	wait(0.001);
	lui::screen_fade_out(0);
	wait(0.001);
	lui::screen_fade_out(0);
	wait(0.001);
	lui::screen_fade_out(0);
	wait(0.001);
	lui::screen_fade_out(0);
	wait(0.001);
	lui::screen_fade_out(0);
	
	//Stop zombies spawning
	SetDvar("ai_disableSpawn", "1");
	
	//Take stuff you'd normally get on spawn
	level.start_weapon = level.weaponNone;
	allPlayersTakeGuns = GetPlayers();
	foreach (playerTakeGuns in allPlayersTakeGuns) {
		starting_pistol = GetWeapon("pistol_standard");
		if(playerTakeGuns HasWeapon(starting_pistol))
		{
			playerTakeGuns TakeWeapon(starting_pistol);	
		}
		
		lethal_grenade = playerTakeGuns zm_utility::get_player_lethal_grenade();
		if(playerTakeGuns HasWeapon(lethal_grenade))
		{
			playerTakeGuns TakeWeapon(lethal_grenade);	
		}
		
		playerTakeGuns SetPlayerCollision(false); //Remove player collision
		
		//playerTakeGuns SetClientUIVisibilityFlag("weapon_hud_visible", 0);
	}
	
	//Setup login screens
	setup_login_screens_torrens();

	//Pre-define cutscene info
	intro_cutscene_length = 19.9; //THIS WILL NEED CHANGING TO THE ACTUAL LENGTH

	//Wait a little then play the cutscene
	if (!should_skip_cutscenes) {
		//Prime our cutscene
		level thread lui::prime_movie(AYZ_CUTSCENE_ID_01);
		
		wait(2);
		play_sound_locally("zm_alien_isolation__cs_torrensintro");
		level thread lui::play_movie_with_timeout(AYZ_CUTSCENE_ID_01, "fullscreen", intro_cutscene_length, true);

		//Wait for cutscene to end and continue
		wait(intro_cutscene_length + 2); //+2 to smooth transition a bit
	}
	
	//Force players to look UP
	allPlayersOnTorrens = GetPlayers();
	foreach (torrensPlayer in allPlayersOnTorrens) {
		torrensPlayer FreezeControls(false);
		torrensPlayer SetStance("prone");
		torrensPlayer FreezeControls(true);
		
		bedLocation = 0;
		if (torrensPlayer.characterIndex == 0) {
			bedLocation = level.dempseybedlocation;
		}
		if (torrensPlayer.characterIndex == 1) {
			bedLocation = level.nikolaibedlocation;
		}
		if (torrensPlayer.characterIndex == 2) {
			bedLocation = level.richtofenbedlocation;
		}
		if (torrensPlayer.characterIndex == 3) {
			bedLocation = level.takeobedlocation;
		}
		
		//these bedLocation vals will need to be modified if spawns are moved
		playerAngle = (0,0,0);
		playerLocation = (0,0,0);
		if (bedLocation == 2) {
			playerAngle = (-45, 90, 0);
			playerLocation = (-26101.1, -12731.1, 11778);
		}
		if (bedLocation == 3) {
			playerAngle = (-45, 45, 0);
			playerLocation = (-26067.2, -12742.8, 11778);
		}
		if (bedLocation == 4) {
			playerAngle = (-45, -45, 0);
			playerLocation = (-26066.9, -12810.7, 11778);
		}
		if (bedLocation == 5) {
			playerAngle = (-45, -90, 0);
			playerLocation = (-26101.1, -12822, 11778);
		}
		
		torrensPlayer setorigin(playerLocation);
		torrensPlayer SetPlayerAngles(playerAngle);
		
		//torrensPlayer setClientUIVisibilityFlag("hud_visible", 0);
		//torrensPlayer setClientUIVisibilityFlag("weapon_hud_visible", 0);
	}
	
	if (!should_skip_cutscenes) {
		//Start SFX
		play_sound_locally("zm_alien_isolation__cs_wakeup");
		
		//Wake em up! (this will all need to be retimed ideally)
		lui::screen_fade_out(0);
		wait(4);
		lui::screen_fade_in(1);
		wait(1);
		lui::screen_fade_out(1);
		wait(3);
		lui::screen_fade_in(1);
		wait(1);
		thread open_cryro_beds();
		wait(6);
		lui::screen_fade_out(1);
		play_sound_locally("zm_alien_isolation__torrens_theme_wakeup"); //play wakeup theme
		wait(4);
	
		//Get out of the pod
		allPlayersOnTorrensTwo = GetPlayers();
		foreach (torrensPlayerTwo in allPlayersOnTorrensTwo) {
			bedLocation = 0;
			if (torrensPlayerTwo.characterIndex == 0) {
				bedLocation = level.dempseybedlocation;
			}
			if (torrensPlayerTwo.characterIndex == 1) {
				bedLocation = level.nikolaibedlocation;
			}
			if (torrensPlayerTwo.characterIndex == 2) {
				bedLocation = level.richtofenbedlocation;
			}
			if (torrensPlayerTwo.characterIndex == 3) {
				bedLocation = level.takeobedlocation;
			}
			
			//these bedLocation vals will need to be modified if spawns are moved
			playerAngle = (0,0,0);
			playerLocation = (0,0,0);
			if (bedLocation == 2) {
				playerAngle = (-45, 90, 0);
				playerLocation = (-26101.1, -12731.1, 11778);
			}
			if (bedLocation == 3) {
				playerAngle = (-45, 45, 0);
				playerLocation = (-26067.2, -12742.8, 11778);
			}
			if (bedLocation == 4) {
				playerAngle = (-45, -45, 0);
				playerLocation = (-26066.9, -12810.7, 11778);
			}
			if (bedLocation == 5) {
				playerAngle = (-45, -90, 0);
				playerLocation = (-26101.1, -12822, 11778);
			}
			
			torrensPlayerTwo SetPlayerAngles(playerAngle);
			torrensPlayerTwo setorigin(playerLocation);
			torrensPlayerTwo SetStance("stand");
		}

		//Make clips solid
		spawnClip1 Solid();
		spawnClip2 Solid();
		spawnClip3 Solid();
		spawnClip4 Solid();

		wait(4);
	}
	
	allPlayersOnTorrensThree = GetPlayers();
	foreach (torrensPlayerThree in allPlayersOnTorrensThree) {
		torrensPlayerThree FreezeControls(false);
		torrensPlayerThree AllowSprint(false);
		torrensPlayerThree AllowJump(false);
		torrensPlayerThree AllowMelee(false);
		//torrensPlayerThree setClientUIVisibilityFlag("hud_visible", 1);
		//torrensPlayerThree setClientUIVisibilityFlag("weapon_hud_visible", 1);
	}
	
	//Set the jump height and no running?
	//SetJumpHeight
	
	//Fade back in
	lui::screen_fade_in(1);
	
	//Update objective
	thread show_new_objective("Sign in to the Torrens.");
	
	//Handle all doors on the Torrens (doortype 1 = small, doortype 2 = medium, 3 = medbay)
	level.currentlyOpenDoors = array();
	thread primeTorrensAutomaticDoor("crewcoridoor", 1); //Door to coridoor to crew quarters
	thread primeTorrensAutomaticDoor("crewroom", 2); //Door to crew quarters
	thread primeTorrensAutomaticDoor("spawntoairlockjunction", 2); //Door to airlock junction from spawn
	thread primeTorrensAutomaticDoor("canteencoridoor", 1); //Door to coridoor to canteen
	thread primeTorrensAutomaticDoor("canteen", 1); //Door to canteen
	thread primeTorrensAutomaticDoor("bridge", 1); //Door to the bridge
	thread primeTorrensAutomaticDoor("medbaycoridoor", 2); //Door to coridoor to medbay from junction
	thread primeTorrensAutomaticDoor("medbay", 3); //Door to medbay
	
	//Wait for ALL players to "sign in"
	self waittill("torrens_all_players_signedin");
	
	//Open spawnroom door
	wait(1);
	spawnDoor = getEnt("torrensSpawnDoor", "targetname");
	spawnDoor MoveTo(spawnDoor.origin + (0,0,76), 2, 1, 1);
	spawnDoor PlaySound("zm_alien_isolation__smalldoor_open");
	wait(1);
	
	//Update objective
	thread show_new_objective("Explore the Torrens.");
	
	//Give perks and ammo if debug is enabled
	if (should_skip_cutscenes) {
		give_perks_and_ammo();
	}
	
	//Wait for a player to enter the canteen
	canteenZone = getEnt("torrens_canteen_zone", "targetname");
	canteenZone NotSolid();
	while(1) {
		all_players_aboard_torrens = GetPlayers();
		player_in_canteen = false;
		foreach (a_torrens_player in all_players_aboard_torrens) {
			if (a_torrens_player IsTouching(canteenZone) == true) {
				player_in_canteen = true;
			} else {
				continue;
			}
		}
		if (player_in_canteen == true) {
			break; //need to break here OR ELSE!
		}
		wait 0.1;
	}
	wait(3);
	
	//Push players towards the bridge
	//Play verlaine's message to get to the bridge
	//Wait a bit
	thread show_new_objective("Collect your briefing documents.");
	//Open bridge door
	
	//Wait for debug trigger to be pushed
	DEBUG_TRIGGER_TORRENS = getEnt("TorrensDebugTrigger", "targetname");
	DEBUG_TRIGGER_TORRENS SetHintString("TRIGGER TORRENS TRANSMISSION");
	DEBUG_TRIGGER_TORRENS waittill("trigger", player);
	if (should_skip_cutscenes) {
		TRANSITION_Torrens_to_SpaceflightTerminal(false);
	} else {
		TRANSITION_Torrens_to_SpaceflightTerminal(true);
	}
}


//Try and stop auto control unfreeze
function spawn_control_lock_override() {
	level flag::wait_till("all_players_connected");
	foreach (player in level.players) {
		player FreezeControls(false);
		player SetStance("prone");
		player FreezeControls(true);
	}
	level flag::wait_till( "initial_blackscreen_passed" );
	foreach (player in level.players) {
		player FreezeControls(false);
		player SetStance("prone");
		player FreezeControls(true);
	}
	wait(0.1);
	foreach (player in level.players) {
		player FreezeControls(false);
		player SetStance("prone");
		player FreezeControls(true);
	}
	wait(0.1);
	foreach (player in level.players) {
		player FreezeControls(false);
		player SetStance("prone");
		player FreezeControls(true);
	}
	wait(0.1);
	foreach (player in level.players) {
		player FreezeControls(false);
		player SetStance("prone");
		player FreezeControls(true);
	}
	wait(0.1);
	foreach (player in level.players) {
		player FreezeControls(false);
		player SetStance("prone");
		player FreezeControls(true);
	}
	wait(0.1);
	foreach (player in level.players) {
		player FreezeControls(false);
		player SetStance("prone");
		player FreezeControls(true);
	}
}


//Open all lids to cryro beds
function open_cryro_beds() {
	transitiontime = 5;

	cryroBedLid1 = getEnt("torrens_cryrobed_lid_01", "targetname");
	cryroBedLid2 = getEnt("torrens_cryrobed_lid_02", "targetname");
	cryroBedLid3 = getEnt("torrens_cryrobed_lid_03", "targetname");
	cryroBedLid4 = getEnt("torrens_cryrobed_lid_04", "targetname");
	cryroBedLid5 = getEnt("torrens_cryrobed_lid_05", "targetname");
	cryroBedLid6 = getEnt("torrens_cryrobed_lid_06", "targetname");
	
	cryroBedLid1 RotatePitch(50, transitiontime, (transitiontime/2), (transitiontime/2));
	cryroBedLid2 RotatePitch(50, transitiontime, (transitiontime/2), (transitiontime/2));
	cryroBedLid3 RotatePitch(50, transitiontime, (transitiontime/2), (transitiontime/2));
	cryroBedLid4 RotatePitch(50, transitiontime, (transitiontime/2), (transitiontime/2));
	cryroBedLid5 RotatePitch(50, transitiontime, (transitiontime/2), (transitiontime/2));
	cryroBedLid6 RotatePitch(50, transitiontime, (transitiontime/2), (transitiontime/2));
}


//Initiate login screens
function setup_login_screens_torrens() {	
	dempseyInBed = 0;
	nikolaiInBed = 0;
	richtofenInBed = 0;
	takeoInBed = 0;
	
	//if these vals are changed they will need to be modified in our above player location/view control script
	cryoBedOne = 2;
	cryoBedTwo = 3;
	cryoBedThree = 4;
	cryoBedFour = 5;
	
	foreach(player in level.players) {	
		if (player.origin[1] == -12731.1) {
			if (player.characterIndex == 0) {
				dempseyInBed = cryoBedOne;
			}
			if (player.characterIndex == 1) {
				nikolaiInBed = cryoBedOne;
			}
			if (player.characterIndex == 2) {
				richtofenInBed = cryoBedOne;
			}
			if (player.characterIndex == 3) {
				takeoInBed = cryoBedOne;
			}
		}
		if (player.origin[1] == -12742.8) {
			if (player.characterIndex == 0) {
				dempseyInBed = cryoBedTwo;
			}
			if (player.characterIndex == 1) {
				nikolaiInBed = cryoBedTwo;
			}
			if (player.characterIndex == 2) {
				richtofenInBed = cryoBedTwo;
			}
			if (player.characterIndex == 3) {
				takeoInBed = cryoBedTwo;
			}
		}
		if (player.origin[1] == -12810.7) {
			if (player.characterIndex == 0) {
				dempseyInBed = cryoBedThree;
			}
			if (player.characterIndex == 1) {
				nikolaiInBed = cryoBedThree;
			}
			if (player.characterIndex == 2) {
				richtofenInBed = cryoBedThree;
			}
			if (player.characterIndex == 3) {
				takeoInBed = cryoBedThree;
			}
		}
		if (player.origin[1] == -12822) {
			if (player.characterIndex == 0) {
				dempseyInBed = cryoBedFour;
			}
			if (player.characterIndex == 1) {
				nikolaiInBed = cryoBedFour;
			}
			if (player.characterIndex == 2) {
				richtofenInBed = cryoBedFour;
			}
			if (player.characterIndex == 3) {
				takeoInBed = cryoBedFour;
			}
		}
    }
	
	//Count players
	level.signedInPlayerCount = 0;
	
	//Share bed nums with everyone
	level.dempseybedlocation = dempseyInBed;
	level.nikolaibedlocation = nikolaiInBed;
	level.richtofenbedlocation = richtofenInBed;
	level.takeobedlocation = takeoInBed;
	
	//Trigger resets
	signInTrigger1 = getEnt("signintrigger_bed2", "targetname");
	signInTrigger1 SetHintString("");
	signInTrigger1 setCursorHint("HINT_NOICON");
	signInTrigger2 = getEnt("signintrigger_bed3", "targetname");
	signInTrigger2 SetHintString("");
	signInTrigger2 setCursorHint("HINT_NOICON");
	signInTrigger3 = getEnt("signintrigger_bed4", "targetname");
	signInTrigger3 SetHintString("");
	signInTrigger3 setCursorHint("HINT_NOICON");
	signInTrigger4 = getEnt("signintrigger_bed5", "targetname");
	signInTrigger4 SetHintString("");
	signInTrigger4 setCursorHint("HINT_NOICON");
	
	if (dempseyInBed != 0) {
		thread handleMonitorSwap(dempseyInBed, "Dempsey");
	}
	if (nikolaiInBed != 0) {
		thread handleMonitorSwap(nikolaiInBed, "Nikolai");
	}
	if (richtofenInBed != 0) {
		thread handleMonitorSwap(richtofenInBed, "Richtofen");
	} 
	if (takeoInBed != 0) {
		thread handleMonitorSwap(takeoInBed, "Takeo");
	} 
}
function handleMonitorSwap(bedNum, charName) {
	signInTrigger = getEnt("signintrigger_bed" + bedNum, "targetname");
	signInTrigger SetHintString("Press ^3[{+activate}]^7 to Sign In as " + charName);
	
	charNum = 4;
	if (charName == "Dempsey") {
		charNum = 0;
	}
	if (charName == "Nikolai") {
		charNum = 1;
	}
	if (charName == "Richtofen") {
		charNum = 2;
	}
	if (charName == "Takeo") {
		charNum = 3;
	}
	
	bedMonitor = getEnt("torrens_signinmonitor_0" + bedNum, "targetname");
	bedMonitor SetModel("monitor_torrens_signin"); //swapped from default monitor_50cm_blank
	
	while(1) {
		signInTrigger waittill("trigger", player);
		
		//Make sure we're the right player
		if(player.characterIndex == charNum)
		{
			break; //right char
		} else {
			wait 0.1;
			continue;  //not right char
		}
	}
	
	signInTrigger SetInvisibleToAll();
	level.signedInPlayerCount = level.signedInPlayerCount + 1;
	
	bedMonitor PlaySound("zm_alien_isolation__torrens_signin");
	wait(2);
	bedMonitor SetModel("monitor_torrens_signin_" + ToLower(charName));
	
	player_counter = 0;
	players = GetPlayers();
	foreach(player in players) {
		player_counter = player_counter + 1;
	}
	
	//All signed in, alert our script
	if (level.signedInPlayerCount == player_counter) {
		self notify("torrens_all_players_signedin");
	}
}


//Transition over to the spaceflight terminal.
function TRANSITION_Torrens_to_SpaceflightTerminal(should_play_cutscene) {
	//Pre-define some stuff
	transition_cutscene_length = 63; //THIS WILL NEED CHANGING TO THE ACTUAL LENGTH
	
	//transition_from_torrens script_flag
	
	//Prime our cutscene (might want to do this a bit earlier)
	level thread lui::prime_movie(AYZ_CUTSCENE_ID_02);

	//Freeze players and start transition cutscene
	foreach(player in level.players) {
		player FreezeControls(true);
		player AllowSprint(true);
		player AllowJump(true);
		player AllowMelee(true);
	}
	
	if (should_play_cutscene) {
		lui::screen_fade_out(1);
		wait(1);
		level thread lui::play_movie_with_timeout(AYZ_CUTSCENE_ID_02, "fullscreen", transition_cutscene_length, true);
		play_sound_locally("zm_alien_isolation__cs_torrens2sev");
	}
	
	//Get all spawners
	allSpawners = struct::get_array("initial_spawn_points", "targetname");
	
	//Loop through all spawners
	loopCounter = 0;
	foreach (currentSpawner in allSpawners) {
		loopCounter = loopCounter + 1;
		
		//Grab our new position
		spawnerStructNew = struct::get("sft_spawners_" + loopCounter, "targetname");
		
		//Move to new position
		currentSpawner.origin = spawnerStructNew.origin;
	}
	
	//Grab original and new respawn struct
    respawnOrigStruct = struct::get("player_respawn_point", "targetname");
    respawnMoveStruct = struct::get("sft_spawners_9", "targetname");
	
	//Move original to new
	respawnOrigStruct.origin = respawnMoveStruct.origin;
	
	//Get all players
	allPlayersToTeleport = GetPlayers();
	
	//Move every player
	loopCounter = 0;
	foreach (currPlayer in allPlayersToTeleport) {
		//Iterate loop
		loopCounter = loopCounter + 1;
		
		if (loopCounter == 1) {
			destinationNum = 7;
		}
		if (loopCounter == 2) {
			destinationNum = 5;
		}
		if (loopCounter == 3) {
			destinationNum = 4;
		}
		if (loopCounter == 4) {
			destinationNum = 2;
		}
		
		//Get destination struct (defined num above as using sft_spawners)
		destination = struct::get("sft_spawners_" + destinationNum, "targetname");
		
		//Move player
		currPlayer setorigin(destination.origin); 
		
		//will also probably want to do some angle stuff here.
		//e.g. struct angle = player angle (+-90 if we're off)
	}
	
	//Give stuff you'd normally get on spawn
	allPlayersGiveGuns = GetPlayers();
	foreach (playerGiveGuns in allPlayersGiveGuns) {
		playerGiveGuns zm_weapons::weapon_give(GetWeapon("pistol_standard"), false, false, true, true);
		lethal_grenade = playerGiveGuns zm_utility::get_player_lethal_grenade();
		if(!playerGiveGuns HasWeapon(lethal_grenade))
		{
			playerGiveGuns GiveWeapon(lethal_grenade);	
			playerGiveGuns SetWeaponAmmoClip(lethal_grenade, 0);
		}
		playerGiveGuns SetClientUIVisibilityFlag("weapon_hud_visible", 1);
	}
	
	if (should_play_cutscene) {
		//Wait for cutscene to end - fade back in and allow players to move again
		wait(transition_cutscene_length + 0.5); //adding 0.5 to allow for any issues
		lui::screen_fade_in(1);
		wait(1);
	}
	
	//Unfreeze controls
	foreach(player in level.players) {
		player FreezeControls(false);
	}
	
	//Let the game know we're on Sevastopol
	self notify("players_on_sevastopol");
	
	//Play "Welcome To Sevastopol" theme?
	play_sound_locally("zm_alien_isolation__arrive_on_sevastopol"); //currently playing the old intro theme, but might want to change to M2 power on theme or something along the same lines
	
	//Start zombie spawning
	SetDvar("ai_disableSpawn", "0");
}


//Auto door open script
function primeTorrensAutomaticDoor(doorID, doorType) {
	self endon("players_on_sevastopol"); //players are off the torrens, can stop this script.
	
	doorTriggerZone = getEnt("torrens_doortrigger_" + doorID, "targetname"); //grab our trigger zone
	doorTriggerZone NotSolid();
	
	while(1) {
		all_players_aboard_torrens = GetPlayers();
		player_in_door_zone = false;
		foreach (a_torrens_player in all_players_aboard_torrens) {
			if (a_torrens_player IsTouching(doorTriggerZone) == true) {
				player_in_door_zone = true; //player is in door zone, we should open or be open
			} else {
				continue;
			}
		}
		
		//check if door is open or not
		doorIsOpen = false;
		foreach (openDoor in level.currentlyOpenDoors) {
			if (doorID == openDoor) {
				doorIsOpen = true;
			}
		}
		
		if (player_in_door_zone == true) {
			//At least one player is in the zone. We should open the door if it's not already open.
			if (doorIsOpen == false) {
				wait(0.1); //delay a bit
			
				if (doorType == 1) {
					doorEntity = getEnt("torrens_door_" + doorID, "targetname");
					
					doorEntity MoveTo(doorEntity.origin + (0,0,76), 1.2, 0.5, 0.5);
					doorEntity PlaySound("zm_alien_isolation_torrens_door_open");
					
					wait(1.2); //wait for anim to finish
				}
				if (doorType == 2) {
					doorEntity = getEnt("torrens_door_" + doorID, "targetname");
					
					doorEntity MoveTo(doorEntity.origin + (0,0,76), 1.7, 0.5, 0.5);
					doorEntity PlaySound("zm_alien_isolation__smalldoor_open");
					
					wait(1.7); //wait for anim to finish
				}
				if (doorType == 3) {
					doorEntity1 = getEnt("torrens_door_" + doorID + "1", "targetname");
					doorEntity2 = getEnt("torrens_door_" + doorID + "2", "targetname");
					
					doorEntity1 MoveTo(doorEntity1.origin - (39.2,39.2,0), 1.1, 0.5, 0.5);
					doorEntity1 PlaySound("zm_alien_isolation_torrens_medbay_open");
					doorEntity2 MoveTo(doorEntity2.origin + (39.2,39.2,0), 1.2, 0.5, 0.5);
					
					wait(1.2); //wait for anim to finish
				}
				
				wait(2); //wait a bit
				
				ArrayInsert(level.currentlyOpenDoors, doorID, level.currentlyOpenDoors.size); //remember that the door is open
			}
		} else {
			//No players are in the zone, we should close (if open).
			if (doorIsOpen == true) {
				if (doorType != 3) {
					doorEntity = getEnt("torrens_door_" + doorID, "targetname");
					
					doorEntity MoveTo(doorEntity.origin - (0,0,76), 1.7, 0.5, 0.5);
					doorEntity PlaySound("zm_alien_isolation_torrens_door_close");
					
					wait(1.7); //wait for anim to finish
				} else {
					doorEntity1 = getEnt("torrens_door_" + doorID + "1", "targetname");
					doorEntity2 = getEnt("torrens_door_" + doorID + "2", "targetname");
					
					doorEntity1 MoveTo(doorEntity1.origin + (39.2,39.2,0), 1.2, 0.5, 0.5);
					doorEntity1 PlaySound("zm_alien_isolation_torrens_medbay_close");
					doorEntity2 MoveTo(doorEntity2.origin - (39.2,39.2,0), 1.1, 0.5, 0.5);
					
					wait(1.2); //wait for anim to finish
				}
			
				ArrayRemoveValue(level.currentlyOpenDoors, doorID); //remove from open array
			}
		}
		
		wait 0.1;
	}
}




//dbg
function dbgSetRoundNum(number) {
	SetRoundsPlayed(number);
	level.round_number = number + 1;
}

function dbg_getangles() {
	while(1) {
		foreach (player in level.players) {
			iprintlnbold(player GetPlayerAngles());
		}
		wait(1);
	}
}