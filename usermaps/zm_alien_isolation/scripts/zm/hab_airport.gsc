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