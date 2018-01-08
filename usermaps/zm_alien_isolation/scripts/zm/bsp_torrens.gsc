///////////////////////////////////////
//////  ALIEN ISOLATION ZOMBIES  //////
//////     SERVER-SIDE SCRIPT    //////
///////////////////////////////////////
//////        The Torrens        //////
///////////////////////////////////////

//Core scripts
#insert scripts\zm\zm_alien_isolation.gsc;

//Alien Isolation Zombies namespace
#namespace alien_isolation_zombies;

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
	
	//Start script to handle coridoor light effects
	//thread coridoorLightHandler();
	
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
	
	//Disallow sprint, jump and melee for Torrens
	allPlayersOnTorrensThree = GetPlayers();
	foreach (torrensPlayerThree in allPlayersOnTorrensThree) {
		torrensPlayerThree FreezeControls(false);
		torrensPlayerThree AllowSprint(false);
		torrensPlayerThree AllowJump(false);
		torrensPlayerThree AllowMelee(false);
		//torrensPlayerThree setClientUIVisibilityFlag("hud_visible", 1);
		//torrensPlayerThree setClientUIVisibilityFlag("weapon_hud_visible", 1);
	}
	
	//Fade back in
	lui::screen_fade_in(1);
	
	//Update objective
	thread show_new_objective("Sign in to the Torrens.");
	
	//DEBUG ONLY
	//thread DEBUG_TORRENS_LIGHT();
	
	//Wait for ALL players to "sign in"
	self waittill("torrens_all_players_signedin");
	
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
	
	//Open spawnroom door
	wait(1);
	spawnDoor = getEnt("torrensSpawnDoor", "targetname");
	spawnDoorClip = getEnt("torrensSpawnDoor_clip", "targetname");
	
	spawnDoor MoveTo(spawnDoor.origin + (0,0,76), 2, 1, 1);
	spawnDoor PlaySound("zm_alien_isolation__smalldoor_open");
	spawnDoorClip MoveTo(spawnDoorClip.origin + (0,0,76), 2, 1, 1);
	wait(1);
	
	//Update objective
	thread show_new_objective("Explore the Torrens.");
	
	//Wait for player to approach the locked door and update objective
	trigger_reroute_power = getEnt("trigger_reroute_power_torrens", "targetname");
	trigger_reroute_power SetHintString(""); //Set hint string of power reroute first
	trigger_reroute_power setCursorHint("HINT_NOICON");
	thread torrens_broken_door();
	level waittill("torrens_brokendoor_notified");
	thread show_new_objective("Reroute power to open the door.");
	
	//Wait for player to fix the door
	trigger_reroute_power SetHintString("Hold ^3[{+activate}]^7 to reroute power"); //Update hint string
	trigger_reroute_power waittill("trigger", player);
	access_rewire = getEnt("torrens_access_rewire", "targetname");
	access_rewire RotateTo((0,90,180), 1, 0.5, 0.5);
	access_rewire PlaySound("zm_alien_isolation__tow_monitor_changed"); //sfx
	trigger_reroute_power SetHintString(""); //Update hint string
	level notify("torrens_brokendoor_fixed");
	wait(1.5);
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
	
	//Push players towards the bridge (play verlaine broadcast)
	play_sound_locally("zm_alien_isolation__torrens_get_to_bridge");
	
	//Wait a bit and update objective
	wait(5);
	thread show_new_objective("Collect your weapons.");
	
	//Open bridge door
	self notify("torrens_enable_bridge_door");
	
	//Wait for transition trigger to be pushed
	trigger_transition_to_sevastopol = getEnt("trigger_torrens_transition_to_sevastopol", "targetname");
	trigger_transition_to_sevastopol SetHintString("Hold ^3[{+activate}]^7 to pick up weapon");
	trigger_transition_to_sevastopol setCursorHint("HINT_NOICON");
	trigger_transition_to_sevastopol waittill("trigger", player);
	//WAIT FOR ALL PLAYERS TO DO THIS (TODO)
	if (should_skip_cutscenes) {
		TRANSITION_Torrens_to_SpaceflightTerminal(false);
	} else {
		TRANSITION_Torrens_to_SpaceflightTerminal(true);
	}
}


//handle broken door on Torrens
function torrens_broken_door() {
	brokendoorZone = getEnt("torrens_brokendoor_zone", "targetname");
	brokendoorZone NotSolid();
	while(1) {
		all_players_aboard_torrens = GetPlayers();
		player_by_door = false;
		foreach (a_torrens_player in all_players_aboard_torrens) {
			if (a_torrens_player IsTouching(brokendoorZone) == true) {
				player_by_door = true;
			} else {
				continue;
			}
		}
		if (player_by_door == true) {
			level notify("torrens_brokendoor_notified");
			break;
		}
		wait 0.1;
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


//DEBUG ONLY - REMOVE WHEN TESTED
//DEBUGONLY DEBUGONLY DEBUGONLY DEBUGONLY DEBUGONLY DEBUGONLY DEBUGONLY DEBUGONLY - TODO: REMOVE!
function DEBUG_TORRENS_LIGHT() {
	lightzone = getEnt("torrens_debuglighttrigger", "targetname"); //grab our trigger zone
	lightzone NotSolid();
	hidden = false;
	
	while(1) {
		players = GetPlayers();
		player_in_zone = false;
		
		foreach (player in players) {
			if (player IsTouching(lightzone) == true) {
				player_in_zone = true;
			} else {
				continue;
			}
		}
		
		//I really can't be fucked to rebuild all the lighting - using server-side lights that already exist in TPF.
		
		if (player_in_zone == true) {
			wait(0.1);
			if (hidden == false) {
				hidden = true;
				//TESTLIGHT_TORRENS_1 = getEnt("TESTLIGHT_TORRENS_1", "targetname");
				//TESTLIGHT_TORRENS_2 = getEnt("TESTLIGHT_TORRENS_2", "targetname");
				//TESTLIGHT_TORRENS_1 hide();
				//TESTLIGHT_TORRENS_2 hide();
				iprintlnbold("DEBUGONLY: entered zone");
				for (i=0; i < 28; i++) {
					iprintlnbold("DEBUGONLY: HIDING LIGHT " + i);
					test_ent = getEnt("tow_warning_light_bulb_" + i, "targetname");
					test_ent.origin = (0,0,0); //This is how it will work - Grab origin of model, assign to array, set to 0, then when the light is needed, pull from array and move to the original origin.
				}
				wait(5);
			} else {
				hidden = false;
				//TESTLIGHT_TORRENS_1 = getEnt("TESTLIGHT_TORRENS_1", "targetname");
				//TESTLIGHT_TORRENS_2 = getEnt("TESTLIGHT_TORRENS_2", "targetname");
				//TESTLIGHT_TORRENS_1 show();
				//TESTLIGHT_TORRENS_2 show();
				iprintlnbold("DEBUGONLY: entered zone");
				for (i=0; i < 28; i++) {
					iprintlnbold("DEBUGONLY: SHOWING LIGHT " + i);
					test_ent = getEnt("tow_warning_light_bulb_" + i, "targetname");
					test_ent show();
				}
				wait(5);
			}
		}
		
		wait(0.1);
	}
}


//Auto door open script
function primeTorrensAutomaticDoor(doorID, doorType) {
	self endon("players_on_sevastopol"); //players are off the torrens, can stop this script.
	
	doorTriggerZone = getEnt("torrens_doortrigger_" + doorID, "targetname"); //grab our trigger zone
	doorTriggerZone NotSolid();
	
	//Only run door script if not canteencoridoor - that has been depreciated.
	if (doorID != "canteencoridoor") {
		if (doorID == "bridge") {
			doorEntity = getEnt("torrens_door_bridge", "targetname");
			doorEntity SetHintString(AYZ_DOORPROMPT_LOCKDOWN_UNFINISHED); //TODO: FIX THIS
			doorEntity setCursorHint("HINT_NOICON");
			self waittill("torrens_enable_bridge_door");
			doorEntity SetHintString("");
			//TODO: swap door lights here
		}
		
		if (doorID == "spawntoairlockjunction") {
			doorEntity = getEnt("torrens_door_spawntoairlockjunction", "targetname");
			doorEntity SetHintString("Low power"); //TODO: FIX THIS
			doorEntity setCursorHint("HINT_NOICON");
			level waittill("torrens_brokendoor_fixed");
			doorEntity SetHintString("");
			//TODO: swap door lights here
		}
		
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
						doorClip = getEnt("torrens_door_" + doorID + "_clip", "targetname");
						
						doorEntity MoveTo(doorEntity.origin + (0,0,76), 1.2, 0.5, 0.5);
						doorEntity PlaySound("zm_alien_isolation_torrens_door_open");
						
						doorClip MoveTo(doorClip.origin + (0,0,76), 1.2, 0.5, 0.5);
						
						wait(1.2); //wait for anim to finish
					}
					if (doorType == 2) {
						doorEntity = getEnt("torrens_door_" + doorID, "targetname");
						doorClip = getEnt("torrens_door_" + doorID + "_clip", "targetname");
						
						doorEntity MoveTo(doorEntity.origin + (0,0,76), 1.7, 0.5, 0.5);
						doorEntity PlaySound("zm_alien_isolation__smalldoor_open");
						
						doorClip MoveTo(doorClip.origin + (0,0,76), 1.7, 0.5, 0.5);
						
						wait(1.7); //wait for anim to finish
					}
					if (doorType == 3) {
						doorEntity1 = getEnt("torrens_door_" + doorID + "1", "targetname");
						doorClip1 = getEnt("torrens_door_" + doorID + "1_clip", "targetname");
						doorEntity2 = getEnt("torrens_door_" + doorID + "2", "targetname");
						doorClip2 = getEnt("torrens_door_" + doorID + "2_clip", "targetname");
						
						doorEntity1 MoveTo(doorEntity1.origin - (39.2,39.2,0), 1.1, 0.5, 0.5);
						doorEntity1 PlaySound("zm_alien_isolation_torrens_medbay_open");
						doorEntity2 MoveTo(doorEntity2.origin + (39.2,39.2,0), 1.2, 0.5, 0.5);
						
						doorClip1 MoveTo(doorClip1.origin - (39.2,39.2,0), 1.1, 0.5, 0.5);
						doorClip2 MoveTo(doorClip2.origin + (39.2,39.2,0), 1.2, 0.5, 0.5);
						
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
						doorClip = getEnt("torrens_door_" + doorID + "_clip", "targetname");
						
						doorEntity MoveTo(doorEntity.origin - (0,0,76), 1.7, 0.5, 0.5);
						doorEntity PlaySound("zm_alien_isolation_torrens_door_close");
						
						doorClip MoveTo(doorClip.origin - (0,0,76), 1.7, 0.5, 0.5);
						
						wait(1.7); //wait for anim to finish
					} else {
						doorEntity1 = getEnt("torrens_door_" + doorID + "1", "targetname");
						doorClip1 = getEnt("torrens_door_" + doorID + "1_clip", "targetname");
						doorEntity2 = getEnt("torrens_door_" + doorID + "2", "targetname");
						doorClip2 = getEnt("torrens_door_" + doorID + "2_clip", "targetname");
						
						doorEntity1 MoveTo(doorEntity1.origin + (39.2,39.2,0), 1.2, 0.5, 0.5);
						doorEntity1 PlaySound("zm_alien_isolation_torrens_medbay_close");
						doorEntity2 MoveTo(doorEntity2.origin - (39.2,39.2,0), 1.1, 0.5, 0.5);
						
						doorClip1 MoveTo(doorClip1.origin + (39.2,39.2,0), 1.2, 0.5, 0.5);
						doorClip2 MoveTo(doorClip2.origin - (39.2,39.2,0), 1.1, 0.5, 0.5);
						
						wait(1.2); //wait for anim to finish
					}
				
					ArrayRemoveValue(level.currentlyOpenDoors, doorID); //remove from open array
				}
			}
			
			wait 0.1;
		}
	}
}


//Coridoor Light Script
function coridoorLightHandler() {	
	//Get all HAB lights (zone 1)
	level.habLightOrigins = array();
	level.habLightRotations = array();
	for (i=1;i<7;i++) {
		habLight = GetEnt("TORRENS_CORIDOOR_LIGHT_LONG_"+i, "targetname");
		ArrayInsert(level.habLightOrigins, habLight.origin, level.habLightOrigins.size); 
		ArrayInsert(level.habLightRotations, habLight.angles, level.habLightRotations.size); 
		habLight.origin = (-26428 , -13031 , 11752.5);
	}
	
	//Get all SCI lights (zone 2+3 - zone 2 up to 6)
	level.sciLightTopOrigins = array();
	level.sciLightTopRotations = array();
	level.sciLightBottomOrigins = array();
	level.sciLightBottomRotations = array();
	for (i=1;i<15;i++) {
		sciLight = GetEnt("TORRENS_CORIDOOR_LIGHT_TOP_"+i, "targetname");
		ArrayInsert(level.sciLightTopOrigins, sciLight.origin, level.sciLightTopOrigins.size); 
		ArrayInsert(level.sciLightTopRotations, sciLight.angles, level.sciLightTopRotations.size); 
		sciLight.origin = (-26428 , -13031 , 11752.5);
		
		sciLight2 = GetEnt("TORRENS_CORIDOOR_LIGHT_BOTTOM_"+i, "targetname");
		ArrayInsert(level.sciLightBottomOrigins, sciLight2.origin, level.sciLightBottomOrigins.size); 
		ArrayInsert(level.sciLightBottomRotations, sciLight2.angles, level.sciLightBottomRotations.size); 
		sciLight2.origin = (-26428 , -13031 , 11752.5);
	}
	
	
	//Light zone 2 - coridoor from junction past medbay
	lightTriggerTwo = getEnt("torrens_lightzone_2", "targetname");
	lightTriggerTwo SetHintString("");
	lightTriggerTwo setCursorHint("HINT_NOICON");
	lightTriggerTwo NotSolid();
	
	//Light zone 3 - coridoor from past medbay to coridoor to canteen
	lightTriggerThree = getEnt("torrens_lightzone_3", "targetname"); 
	lightTriggerThree SetHintString("");
	lightTriggerThree setCursorHint("HINT_NOICON");
	lightTriggerThree NotSolid();
	
	
	//Instead of waiting for players to enter light zone 1, just wait for the spawn door to open
	self waittill("torrens_all_players_signedin");
	
	//Move lights to new location (light zone 1)
	for (i=1;i<7;i++) {
		if (i == 3 ||
			i == 4 ||
			i == 5) {
			wait (0.5); //delay between light groups
		}
		habLight = GetEnt("TORRENS_CORIDOOR_LIGHT_LONG_"+i, "targetname");
		habLight.origin = level.habLightOrigins[i];
		habLight.angles = level.habLightRotations[i];
		
		if (i==6) {
			iprintlnbold("correctedangleoflight");
			iprintlnbold("shouldbe 0,270,0 - actually - " + level.habLightRotations[i]);
			habLight.angles = (0, 270, 0);
		}
		
		iprintlnbold("DEBUG: MOVED HAB LIGHT " + i);
	}
	
	
	//Wait for player to enter light zone 2
	while(1) {
		all_players_aboard_torrens = GetPlayers();
		in_light_trigger_two = false;
		foreach (a_torrens_player in all_players_aboard_torrens) {
			if (a_torrens_player IsTouching(lightTriggerTwo) == true) {
				in_light_trigger_two = true;
				break;
			} else {
				continue;
			}
		}
		if (in_light_trigger_two) {
			break;
		}
		wait(0.1);
	}	
	
	//Move lights to new location (light zone 2)
	for (i=1;i<7;i++) {
		if (i == 5 ||
			i == 6) {
			wait (0.5); //delay between light groups
		}
		habLight = GetEnt("TORRENS_CORIDOOR_LIGHT_TOP_"+i, "targetname");
		habLight.origin = level.sciLightTopOrigins[i];
		habLight.angles = level.sciLightTopRotations[i];
		
		habLight2 = GetEnt("TORRENS_CORIDOOR_LIGHT_BOTTOM_"+i, "targetname");
		habLight2.origin = level.sciLightBottomOrigins[i];
		habLight2.angles = level.sciLightBottomRotations[i];
		
		iprintlnbold("DEBUG: MOVED SCI LIGHT " + i);
	}
	
	
	//Wait for player to enter light zone 3
	while(1) {
		all_players_aboard_torrens = GetPlayers();
		in_light_trigger_three = false;
		foreach (a_torrens_player in all_players_aboard_torrens) {
			if (a_torrens_player IsTouching(lightTriggerThree) == true) {
				in_light_trigger_three = true;
				break;
			} else {
				continue;
			}
		}
		if (in_light_trigger_three) {
			break;
		}
		wait(0.1);
	}
	
	//Move lights to new location (light zone 3)
	for (i=7;i<15;i++) {
		if (i == 9 ||
			i == 11||
			i == 13) {
			wait (1); //delay between light groups
		}
		habLight = GetEnt("TORRENS_CORIDOOR_LIGHT_TOP_"+i, "targetname");
		habLight.origin = level.sciLightTopOrigins[i];
		habLight.angles = level.sciLightTopRotations[i];
		
		habLight2 = GetEnt("TORRENS_CORIDOOR_LIGHT_BOTTOM_"+i, "targetname");
		habLight2.origin = level.sciLightBottomOrigins[i];
		habLight2.angles = level.sciLightBottomRotations[i];
		
		iprintlnbold("DEBUG: MOVED SCI LIGHT " + i);
		iprintlnbold("DEBUG: ANGLE " + habLight2.angles);
		iprintlnbold("DEBUG: ANGLE " + level.sciLightBottomRotations[i]);
		iprintlnbold("DEBUG: ORIGIN " + habLight2.origin);
		iprintlnbold("DEBUG: ORIGIN " + level.sciLightBottomOrigins[i]);
	}
}