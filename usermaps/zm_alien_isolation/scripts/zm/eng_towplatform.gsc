///////////////////////////////////////
//////  ALIEN ISOLATION ZOMBIES  //////
//////     SERVER-SIDE SCRIPT    //////
///////////////////////////////////////
//////    Sevastopol Station     //////
//////       Tow Platform        //////
///////////////////////////////////////

//Core scripts
#insert scripts\zm\zm_alien_isolation.gsc;

//Alien Isolation Zombies namespace
#namespace alien_isolation_zombies;

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