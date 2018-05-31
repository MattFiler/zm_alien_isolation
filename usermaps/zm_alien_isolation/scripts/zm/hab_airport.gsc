///////////////////////////////////////
//////  ALIEN ISOLATION ZOMBIES  //////
//////     SERVER-SIDE SCRIPT    //////
///////////////////////////////////////
//////    Sevastopol Station     //////
//////   Spaceflight Terminal    //////
///////////////////////////////////////

//Core scripts
#insert scripts\zm\zm_alien_isolation.gsc;

//Alien Isolation Zombies namespace
#namespace alien_isolation_zombies;


/*

ToDo: Move ADVERTS doors to new HAB_AIRPORT_DOOR() function.

*/


//On spawn, activate LS2, wait 5 seconds, close windows and activate LS1
function HAB_AIRPORT_SPAWN() {
	self waittill("players_on_sevastopol");
	
	//Play "Welcome To Sevastopol" theme
	PLAY_LOCAL_SOUND("zm_alien_isolation__arrive_on_sevastopol"); //currently playing the old intro theme, but might want to change to M2 power on theme or something along the same lines

	thread HAB_AIRPORT_EVENT_DRIVEN_OBJECTIVES();
	thread HAB_AIRPORT_AMBIENCES();
	thread HAB_AIRPORT_POWER();
	thread HAB_AIRPORT_LOBBY_TO_SPAWNROOM_DOOR();
	
	//Enable zombies from lobby
	HAB_AIRPORT_PRE_TERMINAL_SEQUENCE();

	thread HAB_AIRPORT_SHUTTER_DOOR("gameroom", 1500);
	thread HAB_AIRPORT_SHUTTER_DOOR("perkroom", 1500);
	thread HAB_AIRPORT_ADVERTS_DOOR("left");
	thread HAB_AIRPORT_ADVERTS_DOOR("right");
	thread HAB_AIRPORT_ENDGAME_DOOR();
	thread HAB_AIRPORT_KEYCARD();
	thread HAB_AIRPORT_ELEVATOR_PURCHASE();

	//Play lockdown sequence
	HAB_AIRPORT_LOCKDOWN_SEQUENCE();
}


//Spaceflight terminal ambiences
function HAB_AIRPORT_AMBIENCES() {
	//Ambiences
	thread HAB_AIRPORT_ALIEN_VENT_RUMBLES();
	thread HAB_AIRPORT_GAMEROOM_BESPOKE();
	thread HAB_AIRPORT_TOUR_AUDIO();

	//Animations
	thread HAB_AIRPORT_CEILING_FANS();
}


//Lockdown sequence
function HAB_AIRPORT_LOCKDOWN_SEQUENCE() {
	level thread zm_audio::sndMusicSystem_PlayState("sft_intro_theme");
	wait(39);
	PLAY_LOCAL_SOUND("zm_alien_isolation__lockdown");
	wait(5);
	for (i = 0; i < 4; i++) {
		window_shutter = GetEnt("window_close_script_" + i, "targetname");
		window_shutter_destination = struct::get("window_close_script_" + i, "targetname");
		window_shutter MoveTo(window_shutter_destination.origin, 9, 1, 1);
	}
	wait(9);
	level util::set_lighting_state(1);
	level util::clientnotify ("ayz_power_off");
	PLAY_LOCAL_SOUND("zm_alien_isolation__post_lockdown_theme");
	self notify("ayz_lockdown_completed");
}


//Spaceflight Terminal Objectives
function HAB_AIRPORT_EVENT_DRIVEN_OBJECTIVES() {
	//Wait for intro lockdown to finish and then show objective a bit later
	self waittill("ayz_lockdown_completed");
	thread keycard_objective();
	wait(5);
	thread UPDATE_OBJECTIVE("Restore power to the Spaceflight Terminal.");
	
	//Wait for power to be restored, play verlaine's message, then show objective.
	level flag::wait_till("power_on");
	wait(15);
	PLAY_LOCAL_SOUND("zm_alien_isolation__verlainebroadcast");
	wait(10.5);
	thread UPDATE_OBJECTIVE("Get to the Tow Platform and escape on the Torrens.");
	
	//Keycard objective is handled in another function (look below).
}
function keycard_objective() {
	self waittill("ayz_lockdown_completed");
	
	//Wait for someone to get in the zone
	keycardZone = GetEnt("endgame_door_trigger", "targetname");
	all_players = GetPlayers();
	while(1) {
		touched = false;
		if (level.key_obtained != true) {
			foreach (player in all_players) {
				if (player IsTouching(keycardZone) == true) {
					//Someone's in the keycard zone
					wait(1.5);
					thread UPDATE_OBJECTIVE("Find a keycard to open the door."); //show objective
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


//SFT Lobby zombie intro
function HAB_AIRPORT_PRE_TERMINAL_SEQUENCE() {
	SetDvar("cg_draw2d", "1");
	level.PauseSevastopolTourAudio = false;

	lobby_zombie_trigger = GetEnt("sft_lobby_activate_zombies", "targetname");
	UPDATE_TRIGGER("Hold ^3[{+activate}]^7 to retrieve message", lobby_zombie_trigger);
	lobby_zombie_trigger waittill("trigger", player);
	HIDE_TRIGGER(lobby_zombie_trigger);

	level.PauseSevastopolTourAudio = true;
	tour_audio_emitter = GetEnt("sft_lobby_audio_source", "targetname");
	tour_audio_emitter StopSound(level.CurrentSevastopolTourAudio);

	sevastolink_monitor = GetEnt("lobby_sevastolink_monitor", "targetname");
	sevastolink_monitor SetModel("monitor_50cm_sevastolink_message_playing");

	PLAY_LOCAL_SOUND("zm_alien_isolation__audiolog");
	wait(2.4);
	level thread zm_audio::sndMusicSystem_PlayState("sft_audiolog_theme");
	wait(43.5);
	PLAY_LOCAL_SOUND("zm_alien_isolation_power_out");
	wait(1);
	sevastolink_spark = struct::get("sevastolink_broken_spark", "targetname");
	PlayFX(level._effect["sevastolink_spark"], sevastolink_spark.origin);
	level util::set_lighting_state(1); 
	sevastolink_monitor SetModel("monitor_50cm_sevastolink_message_played");
	wait(3);
	SetDvar("ai_disableSpawn", "0");
	foreach(player in level.players) {
		player AllowSprint(true);
		player setClientUIVisibilityFlag("weapon_hud_visible", 1);
	}
	wait(5);
	thread UPDATE_OBJECTIVE("Survive until power is restored to the lobby.");
	wait(20); 

	PLAY_LOCAL_SOUND("zm_alien_isolation_power_restored");
	level notify("lobby_power_restored");
	level util::set_lighting_state(0); 

	level.PauseSevastopolTourAudio = false;

	wait(2);
	thread UPDATE_OBJECTIVE("Enter the Spaceflight Terminal.");

	HAB_AIRPORT_SPAWNROOM_TO_TERMINAL_DOOR();
}


//Pre-airport lobby tour audio
function HAB_AIRPORT_TOUR_AUDIO() {
	previous_track = 0;
	current_track = 1;
	audio_source = GetEnt("sft_lobby_audio_source", "targetname");
	while (true) {
		if (level.PauseSevastopolTourAudio != true) {
			while (current_track == previous_track) {
				current_track = randomintrange(1,9);
			}

			level.CurrentSevastopolTourAudio = "zm_alien_isolation_sev_tour_"+current_track;
			audio_source PlaySound("zm_alien_isolation_sev_tour_"+current_track);
		}

   		if (current_track == 1) {
   			wait(75);
   		}
   		else if (current_track == 2) {
   			wait(62);
   		}
   		else if (current_track == 3) {
   			wait(50);
   		}
   		else if (current_track == 4) {
   			wait(65);
   		}
   		else if (current_track == 5) {
   			wait(45);
   		}
   		else if (current_track == 6) {
   			wait(50);
   		}
   		else if (current_track == 7) {
   			wait(67);
   		}
   		else if (current_track == 8) {
   			wait(85);
   		}
   		else if (current_track == 8) {
   			wait(63);
   		}
   		else {
   			wait(0.5);
   		}

   		previous_track = current_track;
	}
}


//Airport doors
function HAB_AIRPORT_DOOR(DOOR_NAME, DOOR_PRICE) {
	airport_door_trigger = GetEnt("airportdoor_" + DOOR_NAME + "_trigger", "targetname");
	airport_door1 = GetEnt("airportdoor_" + DOOR_NAME + "_side1_door", "targetname");
	airport_door2 = GetEnt("airportdoor_" + DOOR_NAME + "_side2_door", "targetname");
	airport_door1_clip = GetEnt("airportdoor_" + DOOR_NAME + "_side1_clip", "targetname");
	airport_door2_clip = GetEnt("airportdoor_" + DOOR_NAME + "_side2_clip", "targetname");
	door_flasher = GetEnt("" + DOOR_NAME + "_flasher", "targetname");
	
	//Get movement positions
	airport_door1_move = struct::get("airportdoor_" + DOOR_NAME + "_side1_door_move", "targetname");
	airport_door2_move = struct::get("airportdoor_" + DOOR_NAME + "_side2_door_move", "targetname");
	airport_door_clip1_move = struct::get("airportdoor_" + DOOR_NAME + "_side1_clip_move", "targetname");
	airport_door_clip2_move = struct::get("airportdoor_" + DOOR_NAME + "_side2_clip_move", "targetname");
	
	//Set door price
	UPDATE_BUYABLE_TRIGGER(DOOR_PRICE, airport_door_trigger);
	
	//Wait for the door to be purchased before starting anything
	while(1) {
		airport_door_trigger waittill("trigger", player);
		if(player.score < DOOR_PRICE)
		{
			wait 0.1;
			player playsound("zmb_no_cha_ching");
			continue;
		}
		player zm_score::minus_to_player_score(DOOR_PRICE); 
		player playsound("zmb_cha_ching");
		break;
	}
	
	//Hide trigger
	HIDE_TRIGGER(airport_door_trigger);
	
	//Move door 1 and clip
	airport_door1 MoveTo(airport_door1_move.origin, 2, 1, 1);
	airport_door1_clip MoveTo(airport_door_clip1_move.origin, 2, 1, 1);
	
	//Move door 2 and clip
	airport_door2 MoveTo(airport_door2_move.origin, 2, 1, 1);
	airport_door2_clip MoveTo(airport_door_clip2_move.origin, 2, 1, 1);
	
	//Update status light and move
	door_flasher SetModel("ayz_new_door_lights_open");
	door_flasher MoveTo((door_flasher.origin + (airport_door2.origin - airport_door2_move.origin)), 2, 1, 1); 
	//door_flasher MoveTo((door_flasher.origin + (-63.501, -32.46, 1)), 2, 1, 1); //wrong location - struct'd be easier for moving to generic function
	
	//Play door sfx
	airport_door1 PlaySound("zm_alien_isolation__largedoor_open");
}


//Shutter doors
function HAB_AIRPORT_SHUTTER_DOOR(room_name, door_cost) {
	//Get door parts
	trigger = getEnt(room_name + "_trigger", "targetname"); 
	shutter = getEnt(room_name + "_door", "targetname"); 
	shutter_collision = getEnt(room_name + "_door_clip", "targetname");
	shutter_extra = getEnt(room_name + "_door_extra", "targetname"); //Generic extra, probs either graffiti or a shadow brush
	
	//Set trigger depending on lockdown state
	UPDATE_TRIGGER(AYZ_DOORPROMPT_LOCKDOWN_UNFINISHED, trigger);
	self waittill("ayz_lockdown_completed");
	UPDATE_BUYABLE_TRIGGER(door_cost, trigger);
	
	//Wait for door to be purchased
	while(1) {
		trigger waittill("trigger", player);
		if(player.score < door_cost)
		{
			wait 0.1;
			player playsound("zmb_no_cha_ching");
			continue;
		}
		player zm_score::minus_to_player_score(door_cost); 
		player playsound("zmb_cha_ching");
		break;
	}
	
	//Hide trigger
	HIDE_TRIGGER(trigger);
	
	//Move and play sfx
	shutter MoveTo((shutter.origin + (0,0,80)), 1.5, 0.75, 0.75); 
	shutter_collision MoveTo((shutter_collision.origin + (0,0,80)), 1.5, 0.75, 0.75); 
	shutter_extra MoveTo((shutter_extra.origin + (0,0,80)), 1.5, 0.75, 0.75);
	shutter PlaySound("zm_alien_isolation__shutter_opening");
}


//Handle spawn room door
function HAB_AIRPORT_LOBBY_TO_SPAWNROOM_DOOR() {
	//Low power initially
	lobby_door_trigger = GetEnt("airportdoor_lobby_to_spawn_trigger", "targetname");
	UPDATE_TRIGGER(AYZ_DOORPROMPT_LOW_POWER, lobby_door_trigger);
	level waittill("lobby_power_restored");

	//Setup door and wait for it to be purchased
	HAB_AIRPORT_DOOR("lobby_to_spawn", 750);
}


//Handle spawn room door
function HAB_AIRPORT_SPAWNROOM_TO_TERMINAL_DOOR() {
	//Setup door and wait for it to be purchased
	HAB_AIRPORT_DOOR("spawn_to_terminal", 1000);
	wait(1);
}


//Switch light state when power is turned on and play sound
function HAB_AIRPORT_POWER() {
	//Set hint on noodle door before power is turned on
	noodledoor_trigger = GetEnt("noodledoor_hint", "targetname");
	UPDATE_TRIGGER(&"ZOMBIE_NEED_POWER", noodledoor_trigger);

	//Wait until the power is activated
	level flag::wait_till("power_on");
	
	//Perform generator handle animation
	generator_handle = getEnt("generator_handle_effect", "targetname");
	generator_handle RotatePitch(45, 0.5, 0.25, 0.25);
	wait(0.5);
	generator_handle RotatePitch(-45, 0.5, 0.25, 0.25);

	//Visibly turn on power
	level util::set_lighting_state(2);
	level util::clientnotify ("ayz_power_on");
	HIDE_TRIGGER(noodledoor_trigger);
	PLAY_LOCAL_SOUND("zm_alien_isolation__poweron");
	
	//Open noodlebar door
	wait(2);
	noodle_door = GetEnt("noodlebar_door_script", "targetname");
	noodle_door_clip = GetEnt("noodlebar_door_script_clip", "targetname");
	noodle_door_destination = struct::get("noodlebar_door_script_openpos", "targetname");
	noodle_door MoveTo(noodle_door_destination.origin, 2, 1, 1);
	noodle_door_clip MoveTo(noodle_door_destination.origin, 2, 1, 1);
	noodle_door_clip NotSolid();
	noodle_door PlaySound("zm_alien_isolation__smalldoor_open");
}


//Extra ambient sound stuff - needed for game room as it involves delays
function HAB_AIRPORT_GAMEROOM_BESPOKE() {
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


//Open buyable ending area door
function HAB_AIRPORT_ENDGAME_DOOR() {
	//Door parts
	endgame_trigger = GetEnt("endgame_door_trigger", "targetname");
	endgame_door1 = GetEnt("endgame_buyable_door_side1", "targetname");
	endgame_door2 = GetEnt("endgame_buyable_door_side2", "targetname");
	endgame_door1_clip = GetEnt("endgame_buyable_door_side1_clip", "targetname");
	endgame_door2_clip = GetEnt("endgame_buyable_door_side2_clip", "targetname");
	door_flasher = GetEnt("endgame_door_flasher", "targetname");

	//Destinations
	endgame_door1_move = struct::get("endgame_buyable_door_side1_move", "targetname");
	endgame_door2_move = struct::get("endgame_buyable_door_side2_move", "targetname");
	endgame_clip1_move = struct::get("endgame_buyable_clip_side1_move", "targetname");
	endgame_clip2_move = struct::get("endgame_buyable_clip_side2_move", "targetname");
	
	//Set our trigger properties
	UPDATE_TRIGGER(AYZ_DOORPROMPT_LOCKDOWN_UNFINISHED, endgame_trigger);
	
	//Wait for the lockdown to finish
	self waittill("ayz_lockdown_completed");
	
	//Re-set our trigger properties
	UPDATE_TRIGGER("A keycard is required to open this door.", endgame_trigger);
	
	//Wait for the door to be activated
	while(1) {
		endgame_trigger waittill("trigger", player);
		if(!level.key_obtained)
		{
			wait 0.1;
			player playsound("zmb_no_cha_ching");
			continue; 
		}
		player playsound("zmb_cha_ching");
		break; 
	}
	
	//Move door 1 and clip
	endgame_door1 MoveTo(endgame_door1_move.origin, 2, 1, 1);
	endgame_door1_clip MoveTo(endgame_clip1_move.origin, 2, 1, 1);
	
	//Move door 2 and clip
	endgame_door2 MoveTo(endgame_door2_move.origin, 2, 1, 1);
	endgame_door2_clip MoveTo(endgame_clip2_move.origin, 2, 1, 1);
	
	//Update and move status light
	door_flasher SetModel("ayz_new_door_lights_open");
	door_flasher MoveTo((door_flasher.origin + (59.862, -38.763, 1)), 2, 1, 1);
	
	//Play door sound at location
	endgame_door1 PlaySound("zm_alien_isolation__largedoor_open");
	
	//Hide trigger
	HIDE_TRIGGER(endgame_trigger);
}


//Random background sounds function, doesn't need to be provoked it will just randomly fire every now and again
function HAB_AIRPORT_ALIEN_VENT_RUMBLES() {
	self waittill("players_on_sevastopol");
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
				PLAY_LOCAL_SOUND("zm_alien_isolation__bg_"+loopcount);
			}
		} else {
			//Loop through all 23 sounds BACKWARDS
			loopcount = 23;
			while (loopcount > 0) {
				//Wait anywhere from 150 to 300 secs between sound clips
				wait(randomintrange(150,300));
					
				//Play background sound
				PLAY_LOCAL_SOUND("zm_alien_isolation__bg_"+loopcount);
				
				loopcount = loopcount - 1;
			}
		}
	}
}


//ADVERTS ceiling fan anims
function HAB_AIRPORT_CEILING_FANS() {
	for (i=0;i<5;i++) {
		fan = getEnt("adverts_anim_fan_"+i, "targetname");
		fan Rotate((0,85,0));
	}
}


//ADVERTS right door
function HAB_AIRPORT_ADVERTS_DOOR(door_location) {
	//Get trigger
	getTrigger = getEnt("zombie_door_adverts_"+door_location, "targetname");
	
	//Get door parts
	doorSide1 = getEnt("adverts_"+door_location+"_buyable_door_side1", "targetname");
	doorSide2 = getEnt("adverts_"+door_location+"_buyable_door_side2", "targetname");
	clipSide1 = getEnt("adverts_"+door_location+"_buyable_door_side1_clip", "targetname");
	clipSide2 = getEnt("adverts_"+door_location+"_buyable_door_side2_clip", "targetname");
	rightSide42 = getEnt("42_"+door_location+"_door", "targetname");
	door_flasher = GetEnt(door_location+"_door_flasher", "targetname");
	
	//Get opening positions
	doorSide1Move = struct::get("adverts_"+door_location+"_buyable_door_side1_move", "targetname");
	clipSide1Move = struct::get("adverts_"+door_location+"_buyable_clip_side1_move", "targetname");
	doorSide2Move = struct::get("adverts_"+door_location+"_buyable_door_side2_move", "targetname");
	clipSide2Move = struct::get("adverts_"+door_location+"_buyable_clip_side2_move", "targetname");
	rightSide42Struct = struct::get("adverts_door_"+door_location+"_42", "targetname");
    door_flasher_move = struct::get("adverts_"+door_location+"_toggle_move", "targetname");
	
	//Set trigger before and after power
	UPDATE_TRIGGER(&"ZOMBIE_NEED_POWER", getTrigger);
	level flag::wait_till("power_on");
	UPDATE_BUYABLE_TRIGGER(2500, getTrigger);
	
	//Wait for the door to be purchased
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
		break;
	}
	
	HIDE_TRIGGER(getTrigger);
	
	//Move doors and clips
	doorSide1 MoveTo(doorSide1Move.origin, 2, 1, 1);
	clipSide1 MoveTo(clipSide1Move.origin, 2, 1, 1);
	doorSide2 MoveTo(doorSide2Move.origin, 2, 1, 1);
	clipSide2 MoveTo(clipSide2Move.origin, 2, 1, 1);
	rightSide42 MoveTo(rightSide42Struct.origin, 2, 1, 1);
	
	//Update status light and move
	door_flasher SetModel("ayz_new_door_lights_open");
	door_flasher MoveTo(door_flasher_move.origin, 2, 1, 1); 
	
	//Play door sound at location
	doorSide1 PlaySound("zm_alien_isolation__largedoor_open");
	wait(2);
	
	//Play ADVERTS theme (if not already played)
	if (level.adverts_theme_played != true) {
		PLAY_LOCAL_SOUND("zm_alien_isolation__open_adverts");
		level.adverts_theme_played = true;
	}
}


//Keycard Scripts (sets our key_obtained value and also hides when triggered)
function HAB_AIRPORT_KEYCARD() {
    level.key_obtained = false;
	
	//Set prompt on trigger
    key = GetEnt("keycard_trigger", "targetname");
    UPDATE_TRIGGER("Hold ^3[{+activate}]^7 to pick up keycard", key);
	
	//Wait for pickup
    key waittill("trigger", player);

    //Hide keycard and trigger
    model = GetEnt(key.target, "targetname"); 
    model delete(); 
	key SetVisibleToAll();
    key delete(); 
	
	//Inform user and update scripts
	PLAY_LOCAL_SOUND("zm_alien_isolation_keycard");
    level.key_obtained = true;
	iprintlnbold("Keycard acquired.");
	
	//Update prompt
	endgame_trigger = GetEnt("endgame_door_trigger", "targetname");
	UPDATE_TRIGGER("Hold ^3[{+activate}]^7 to use keycard", endgame_trigger);
}


//Buyable ending script
function HAB_AIRPORT_ELEVATOR_PURCHASE() {
	//Remove collision on trigger and door clip
	elevatorClip_SFT = getEnt("sft_clip", "targetname");
	elevatorClip_SFT NotSolid();
	elevator_area = getEnt("ayz_elevator_area", "targetname");
	elevator_area NotSolid();

	//Get our buyable ending trigger
	ending = getEnt("ending", "targetname");
	UPDATE_TRIGGER(&"ZOMBIE_NEED_POWER", ending);
	
	//Wait until power is activated
	level flag::wait_till("power_on");
	
	//Modify elevator cost for number of players
	player_counter = 0;
	players = GetPlayers();
	foreach(player in players) {
		player_counter = player_counter + 1;
	}
	switch (player_counter) {
		case 1:
			endgameCost = 50000;
		case 2:
			endgameCost = 45000;
		default:
			endgameCost = 40000;
	}
	
	//Re-set our trigger properties
	UPDATE_TRIGGER("Hold ^3[{+activate}]^7 to activate Elevator [Cost: " + endgameCost + "]", ending);
	
	//Handle elevator purchase
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
			if(!(player_checker.sessionstate == "spectator")) {
				total_players += 1; //only add up ALIVE players. DEAD players can't get in the elevator!
			}
		}
		if (players_in_zone != total_players) {
			wait 0.1;
			player playsound("zmb_no_cha_ching");
			iprintlnbold("All players must be inside the elevator!");
			continue;
		}
		
		//We're alright to proceed! Take the money and break out.
		player zm_score::minus_to_player_score(endgameCost); 
		player playsound("zmb_cha_ching");
		break; 
	}

	//Elevator purchased, perform sequence
	HIDE_TRIGGER(ending);
	elevatorClip_SFT Solid();
	HAB_AIRPORT_ELEVATOR_SEQUENCE();
}


//Elevator Script
function HAB_AIRPORT_ELEVATOR_SEQUENCE() {
	SetDvar("ai_disableSpawn", "1");
	PLAY_LOCAL_SOUND("zm_alien_isolation_sfx_elevator");
	level.PauseSevastopolTourAudio = true;

	//Door parts
	elevatorDoor1_SFT = getEnt("sft_elevator_sideone", "targetname");
	elevatorDoor2_SFT = getEnt("sft_elevator_sidetwo", "targetname");
    elevatorDoorClosedPos_SFT = struct::get("sft_elevator_struct", "targetname");
	
	//Move doors
	elevatorDoor1_SFT MoveTo(elevatorDoorClosedPos_SFT.origin, 3.23, 1.5, 1.5);
	elevatorDoor2_SFT MoveTo(elevatorDoorClosedPos_SFT.origin, 3.23, 1.5, 1.5);
	wait(2.79);
	
	//Make sure door is dynamicly blocked to zombies & bullets
	elevatorZombieBlock_SFT = getEnt("sft_elevator_zombo_blocker_clip", "targetname");
	elevatorBulletBlock_SFT = getEnt("sft_elevator_zombo_blocker_bullet", "targetname");
    elevatorZombieBlockPos_SFT = struct::get("sft_elevator_zombo_blocker", "targetname");
	elevatorZombieBlock_SFT MoveTo(elevatorZombieBlockPos_SFT.origin, 0.001); 
	elevatorBulletBlock_SFT MoveTo(elevatorZombieBlockPos_SFT.origin, 0.001); 
	
	//Give all zombies a POI now that the players are off limits (this is our failsafe)
    newPoiSft = struct::get("sft_zombie_poi", "targetname");
	newPoiSft zm_utility::create_zombie_point_of_interest(5000, 500, 10000); //5000 dist, 500 zombs
	newPoiSft.attract_to_origin = true;
	
	//Goodbye Spaceflight Terminal!
	wait(0.8);
	level notify("ayz_elevator_moving");
	wait(5.11);
	lui::screen_fade_out(1);
		
	//Move every player
	players = GetPlayers();
	loopCounter = 0;
	foreach (player in players) {
		loopCounter = loopCounter + 1;
		
		destination = struct::get("ayz_elevator_destination_" + loopCounter, "targetname");
		player setorigin(destination.origin);
		player setplayerangles(player.angles + (0,-60,0));
	}
	
	//Hello Tow Platform!
	wait(0.5);
	lui::screen_fade_in(1);
	wait(5.11);
	level notify("ayz_elevator_arrived");
	
	//Move all respawn structs
	allSpawners = struct::get_array("initial_spawn_points", "targetname");
	loopCounter = 0;
	foreach (currentSpawner in allSpawners) {
		loopCounter = loopCounter + 1;
		
		//Grab our new position
		spawnerStructNew = struct::get("tpf_spawners_" + loopCounter, "targetname");
		
		//Move to new position
		currentSpawner.origin = spawnerStructNew.origin;
	}
    respawnOrigStruct = struct::get("player_respawn_point", "targetname");
    respawnMoveStruct = struct::get("tpf_spawners_9", "targetname");
	respawnOrigStruct.origin = respawnMoveStruct.origin;
	
	//Kill all spawned zombies
	zombies = GetAiTeamArray("axis"); 
	foreach (zombie in zombies) {
		zombie dodamage( zombie.health + 666, zombie.origin );
	}
	
	//Grab our door parts
	elevatorDoor1_TPF = getEnt("tpf_elevator_sideone", "targetname");
	elevatorDoor2_TPF = getEnt("tpf_elevator_sidetwo", "targetname");
    elevatorDoorOpenPos1_TPF = struct::get("tpf_elevator_sideone_struct", "targetname");
    elevatorDoorOpenPos2_TPF = struct::get("tpf_elevator_sidetwo_struct", "targetname");
	
	//Move our door models to door structs
	elevatorDoor1_TPF MoveTo(elevatorDoorOpenPos1_TPF.origin, 3.59, 1.5, 1.5);
	elevatorDoor2_TPF MoveTo(elevatorDoorOpenPos2_TPF.origin, 3.59, 1.5, 1.5);
	
	//Get Tow Platform elevator clips
	elevatorClipDoor1_TPF = getEnt("tpf_clip_side1", "targetname");
	elevatorClipDoor2_TPF = getEnt("tpf_clip_side2", "targetname");
    elevatorClipOpenPos1_TPF = struct::get("tpf_clip_side1_moveto", "targetname");
    elevatorClipOpenPos2_TPF = struct::get("tpf_clip_side2_moveto", "targetname");
	
	//Move clips
	elevatorClipDoor1_TPF MoveTo(elevatorClipOpenPos1_TPF.origin, 3.59, 1.5, 1.5);
	elevatorClipDoor2_TPF MoveTo(elevatorClipOpenPos2_TPF.origin, 3.59, 1.5, 1.5);
	
	//Wait for door animation to finish
	wait(3.59);
	
	//Kill our zombie POI over in SFT
	newPoiSft zm_utility::deactivate_zombie_point_of_interest();
	
	//Hand everything over to eng_towplatform.gsc
	level notify("arrived_at_tow_platform");
}