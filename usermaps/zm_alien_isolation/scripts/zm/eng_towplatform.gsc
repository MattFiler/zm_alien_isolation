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


//Override for round waiting time
function round_wait_override()
{
	level endon("restart_round");
	level endon("kill_round");

	wait(1);

	while(1)
	{
		if(!(level.zombie_total > 0 || level.intermission))
		{
			return;
		}			
		if(level flag::get("end_round_wait"))
		{
			return;
		}
		wait(1);
	}
}


//Tow Platform "Challenge"
function ENG_TOWPLATFORM_SPAWN() {
	self waittill("ayz_elevator_arrived");
	thread ENG_TOWPLATFORM_WARNING_LIGHTS();

	self waittill("arrived_at_tow_platform");
	thread ENG_TOWPLATFORM_AMBIENCES();
	thread ENG_TOWPLATFORM_ZOMBIE_CONFIG();

	//Scripted sequences (linear)
	ENG_TOWPLAFORM_DOCK_CLAMP_SEQUENCE();
	ENG_TOWPLATFORM_AIRLOCK_SEQUENCE();
	
	//Play ending cutscene when sequences are finished
	ENG_TOWPLATFORM_ENDING_CUTSCENE();
}


//Docking clamp sequence
function ENG_TOWPLAFORM_DOCK_CLAMP_SEQUENCE() {
	//Get triggers
	dockingClampTrigger1 = getEnt("dockingClampTrigger1", "targetname");
	dockingClampTrigger2 = getEnt("dockingClampTrigger2", "targetname");
	airlockPressureTrigger = getEnt("airlockPressureTrigger", "targetname");
	HIDE_TRIGGER(dockingClampTrigger1);
	HIDE_TRIGGER(dockingClampTrigger2);
	HIDE_TRIGGER(airlockPressureTrigger);
	
	//Play intro
	level thread zm_audio::sndMusicSystem_PlayState("tpf_intro_theme");
	wait(18);
	PLAY_LOCAL_SOUND("zm_alien_isolation__verlaine_activate_clamps");
	wait(13);
	self notify("ayz_should_enable_zombies");
	GIVE_ALL_PERKS_AND_AMMO();
	
	//First docking clamp
	thread UPDATE_OBJECTIVE("Activate the first Docking Clamp terminal.");
	ENG_TOWPLATFORM_CLAMP_TERMINAL_ACTIVATION("One", 1, dockingClampTrigger1);
	
	//Start alarms
	wait(0.5);
	self notify("start_alarms_at_towplatform");
	level util::set_lighting_state(3);
	wait(4);
		
	//Second docking clamp
	thread UPDATE_OBJECTIVE("Activate the second Docking Clamp terminal.");
	ENG_TOWPLATFORM_CLAMP_TERMINAL_ACTIVATION("Two", 2, dockingClampTrigger2);

	//Move the clamp
	ENG_TOWPLATFORM_DOCKING_CLAMP();

	//Done, stop alarms
	level notify("stop_alarms_at_towplatform");
	level util::set_lighting_state(2);
}


//Airlock sequence
function ENG_TOWPLATFORM_AIRLOCK_SEQUENCE() {
	//Get triggers
	airlockPressureTrigger = getEnt("airlockPressureTrigger", "targetname");
	airlockZone = getEnt("tow_airlock_zone", "targetname");
	airlockZone NotSolid();

	//Play airlock intro
	PLAY_LOCAL_SOUND("zm_alien_isolation__airlock_intro");
	wait(5);
	PLAY_LOCAL_SOUND("zm_alien_isolation__verlaine_get_to_airlock");
	wait(8);
	thread UPDATE_OBJECTIVE("Pressurise the airlock.");
	
	//Set our trigger properties
	UPDATE_TRIGGER("Press ^3[{+activate}]^7 to Pressurise the Airlock", airlockPressureTrigger);
	
	//Wait until airlock pressurisation is triggered...
	airlockPressureTrigger waittill("trigger", player);
	HIDE_TRIGGER(airlockPressureTrigger);
	
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
	GIVE_ALL_PERKS_AND_AMMO();
	
	//Start counting... this lasts two minutes.
	PLAY_LOCAL_SOUND("zm_alien_isolation__airlock_0percent");
	thread ENG_TOWPLATFORM_AIRLOCK_HUD_COUNTER();
	wait(5);
	thread UPDATE_OBJECTIVE("Survive while the airlock pressurises.");
	wait(5);
	self notify("ayz_airlock_started");
	level thread zm_audio::sndMusicSystem_PlayState("tpf_airlock_pressurising_theme");
	wait(20);
	PLAY_LOCAL_SOUND("zm_alien_isolation__airlock_25percent"); //25%
	wait(30);
	PLAY_LOCAL_SOUND("zm_alien_isolation__airlock_50percent"); //50%
	wait(30);
	PLAY_LOCAL_SOUND("zm_alien_isolation__airlock_75percent"); //75%
	wait(30);
	PLAY_LOCAL_SOUND("zm_alien_isolation__airlock_complete"); //100%
	
	//Update monitor & wait 3 secs for sound to finish
	towAirlockMonitor SetModel("monitor_50cm_airlock_state03");
	wait(3);
	
	//Get airlock door
	airlock_door = getEnt("tow_airlock_door", "targetname");
	airlock_door_clip = getEnt("tow_airlock_door_clip", "targetname");
    airlock_door_moveto = struct::get("tow_airlock_door_move", "targetname");
	
	//Open door
	PLAY_LOCAL_SOUND("zm_alien_isolation__airlock_standclear");
	airlock_door_original_origin = airlock_door.origin;
	airlock_door MoveTo(airlock_door_moveto.origin, 2, 1, 1);
	airlock_door PlaySound("zm_alien_isolation__smalldoor_open");
	wait(2);
	airlock_door_clip NotSolid();
	
	//We're ready to leave!
	thread UPDATE_OBJECTIVE("Everybody get to the airlock!");
	PLAY_LOCAL_SOUND("zm_alien_isolation__final_action_ost");
	
	//Wait for everyone to get in the airlock...
	while(1) {
		all_players = GetPlayers();
		total_players = 0;
		players_in_zone = 0;
		foreach (player in all_players) {
			if (player IsTouching(airlockZone) == true) {
				players_in_zone += 1;
			}
			if(!(player.sessionstate == "spectator")) {
				total_players += 1; //only add up ALIVE players. DEAD players can't get in!
			}
		}
		if (players_in_zone != total_players) {
			wait 0.1;
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
	
	//Close door
	airlock_door_clip Solid();
	airlock_door MoveTo(airlock_door_original_origin, 2, 1, 1);
	airlock_door PlaySound("zm_alien_isolation__smalldoor_open");
	wait(2);
	
	//Play a sting as we finish - don't forget the final ending theme is still going
	PLAY_LOCAL_SOUND("zm_alien_isolation__endgame_sting");
	wait(3);
}


//Final ending cutscene (& ending of game)
function ENG_TOWPLATFORM_ENDING_CUTSCENE() {
	level thread lui::prime_movie(AYZ_CUTSCENE_ID_03);
	
	//Freeze players and play endgame cutscene
	foreach(player in level.players) {
        player FreezeControls(true);
    }
	lui::screen_fade_out(1); //make it a smooth transition
	wait(1);
	PLAY_LOCAL_SOUND("zm_alien_isolation__alt_final_action_cut");
	level thread lui::play_movie_with_timeout(AYZ_CUTSCENE_ID_03, "fullscreen", 36, true);
	
	//Sort out cutscene audio - this should be handled by zm_audio, but just in case
	STOP_LOCAL_SOUND("zm_alien_isolation__final_action_ost"); //stop our previous music
	STOP_LOCAL_SOUND("zm_alien_isolation__bg_tow_xeno"); //stop specifically our xeno track
	level notify("kill_towplatform_ambience"); //also don't forget to stop our ambience (zm_audio might not do this)
	
	//Kill all zombies and mute them
	zombies = GetAiTeamArray("axis");
	foreach (zombie in zombies) {
		zombie StopSounds();
		zombie dodamage(zombie.health + 666, zombie.origin);
	}
	
	//Wait for the cutscene to finish (-5 seconds of cutscene time) 
	wait(30);

	//End the game
	level notify("end_game");
}


//Handle player activation of clamp terminals 1 and 2
function ENG_TOWPLATFORM_CLAMP_TERMINAL_ACTIVATION(terminal_name, terminal_number, trigger) {
	//Set our trigger properties
	UPDATE_TRIGGER("Press ^3[{+activate}]^7 to activate Docking Clamp Terminal "+terminal_name, trigger);
	
	//Wait until terminal is triggered...
	trigger waittill("trigger", player);
	HIDE_TRIGGER(trigger);
	
	//Grab our monitors
	monitor_1 = GetEnt("tow_activate_"+terminal_number+"_monitor1", "targetname");
	monitor_2 = GetEnt("tow_activate_"+terminal_number+"_monitor2", "targetname");
	
	//Update monitors
	monitor_1 PlaySound("zm_alien_isolation__tow_monitor_change"); //sfx
	monitor_1 SetModel("monitor_static_trace_orange"); //orange
	monitor_2 SetModel("monitor_static_trace_orange"); //orange
	wait(2.5);
	monitor_1 PlaySound("zm_alien_isolation__tow_monitor_changed"); //sfx
	monitor_1 SetModel("monitor_static_trace"); //green
	monitor_2 SetModel("monitor_static_trace"); //green
	wait(0.5);
}


//Zombie configurations for the Tow Platform
function ENG_TOWPLATFORM_ZOMBIE_CONFIG() {
	//Turn off zombie failsafe and "disable" dog rounds
	zombie_utility::set_zombie_var("zombie_use_failsafe", false);
	level.next_dog_round = 9999; 

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

	//Re-enable zombies when requested
	self waittill("ayz_should_enable_zombies");
	SetDvar("ai_disableSpawn", "0");

	//Change the zombie limit again when airlock sequence starts
	self waittill("ayz_airlock_started");
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
}


//Tow Platform warning light anims
function ENG_TOWPLATFORM_WARNING_LIGHTS() {
	rotationSpeed = 250;
	
	//Models
	lightEnts = getEntArray("tow_warning_light_inner", "targetname");
	foreach (lightEnt in lightEnts) {
		lightEnt Rotate((0,rotationSpeed,0));
	}

	//Lights
	for(i=0; i<28; i++) {
		tpfWarningLight = getEnt("tow_warning_light_bulb_"+i, "targetname");
		tpfWarningLight Rotate((0,rotationSpeed,0));
	}
}


//Tow platform ambiences
function ENG_TOWPLATFORM_AMBIENCES() {
	thread ENG_TOWPLATFORM_ALIEN_SCREECHES();
	thread ENG_TOWPLATFORM_ALARM_LOOP(1,1.97);
	thread ENG_TOWPLATFORM_ALARM_LOOP(2,4.724);
	thread ENG_TOWPLATFORM_ALARM_LOOP(3,2.438);
}


//Alien screeches
function ENG_TOWPLATFORM_ALIEN_SCREECHES() {
	self waittill("arrived_at_tow_platform");
	self endon("kill_towplatform_ambience");

	while (true) {
		PLAY_LOCAL_SOUND("zm_alien_isolation__bg_tow_xeno");
		wait(110);
	}
}


//Generic alarm sound player (must be threaded)
function ENG_TOWPLATFORM_ALARM_LOOP(loop_version, time) {
	self waittill("start_alarms_at_towplatform");
	self endon("stop_alarms_at_towplatform");

	tow_speaker = getEnt("tow_speaker_"+loop_version, "targetname");
	while (true) {
		PlaySoundAtPosition("zm_alien_isolation__alarm_"+loop_version, tow_speaker.origin);
		wait(time);
	}
}


//Animate the docking clamp and also handle audio.
function ENG_TOWPLATFORM_DOCKING_CLAMP() {
	//Play sfx
	PLAY_LOCAL_SOUND("zm_alien_isolation__dockingclamp_amb"); //might want to play at position of docking clamp?
	
	//Get clamp and struct
	dockingClamp = getEnt("towplat_dockingclamp", "targetname");
    dockingClampStruct = struct::get("dockingclamp_finalmove", "targetname");
	
	//Move
	wait(6.59);
	dockingClamp MoveTo(dockingClampStruct.origin, 35.87, 10, 25.87);
	
	//Play rumble
    rumbleStruct = struct::get("tow_rumble_origin", "targetname");
	Earthquake( 0.08, 35, rumbleStruct.origin, 99999 ); 
	
	//Time ending
	wait(35);
	PLAY_LOCAL_SOUND("zm_alien_isolation__dockingclamp_done");
	wait(3);
}

//HUD ELEMENT FOR TOW PLATFORM AIRLOCK PRESSURISER
function ENG_TOWPLATFORM_AIRLOCK_HUD_COUNTER()
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