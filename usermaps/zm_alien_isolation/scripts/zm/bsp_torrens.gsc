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

//Models
#precache("xanim", "alien_isolation_verlaine_anim_idle");
#precache("xanim", "alien_isolation_connor_anim_idle");
#using_animtree("alien_isolation_zombies");


//Torrens spawn script
function BSP_TORRENS_SPAWN() {
	level util::set_lighting_state(1); 

	BSP_TORRENS_SCRIPTED_SEQUENCE_INTRODUCTION();
	BSP_TORRENS_BROKEN_DOOR_POWER_REROUTE();
	BSP_TORRENS_SETUP_BRIDGE_WHEN_CANTEEN_ENTERED();
	BSP_TORRENS_ALL_PLAYERS_PICK_UP_WEAPONS();
	BSP_TORRENS_WEAPON_PICKUP_CUTSCENE();
}

//Torrens intro (cutscene, wakeup script, signin to ship)
function BSP_TORRENS_SCRIPTED_SEQUENCE_INTRODUCTION() {
	thread BSP_TORRENS_CRYOPOD_COLLISION();
	BSP_TORRENS_INTRO_CUTSCENE();
	BSP_TORRENS_LOGIN_SCREENS();	
	BSP_TORRENS_PUT_PLAYERS_IN_CRYOPODS();
	BSP_TORRENS_WAKEUP_SEQUENCE();
	BSP_TORRENS_GET_OUT_OF_CYROPODS();
	BSP_TORRENS_OPEN_SPAWN_DOOR_WHEN_ALL_SIGNED_IN();
}

//Handle cryopod collision (enable/disable when needed)
function BSP_TORRENS_CRYOPOD_COLLISION() {
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

	level waittill("torrens_enable_cryo_collision");

	//Make clips solid
	spawnClip1 Solid();
	spawnClip2 Solid();
	spawnClip3 Solid();
	spawnClip4 Solid();
}

//Play intro cutscene
function BSP_TORRENS_INTRO_CUTSCENE() {
	//Hide crosshairs (as precaution) and disable zombies
	SetDvar("cg_draw2d", "0");
	SetDvar("ai_disableSpawn", "1");

	foreach	(player in level.players) {		
		thread OVERRIDE_CONTROL_UNFREEZE(player); 
	}

	level flag::wait_till("all_players_connected");

	//Prime our cutscene
	level thread lui::prime_movie(AYZ_CUTSCENE_ID_01);

	//Freeze controls and show blackscreen to hide game
	foreach	(player in level.players) {		
		thread BSP_TORRENS_BLACKSCREEN(player);
		thread OVERRIDE_CONTROL_UNFREEZE(player); 
	}

	level flag::wait_till("initial_blackscreen_passed");
	lui::screen_fade_out(0);

	foreach	(player in level.players) {		
		thread OVERRIDE_CONTROL_UNFREEZE(player); 
	}

	//Pre-define cutscene info
	intro_cutscene_length = 19.9; //THIS WILL NEED CHANGING TO THE ACTUAL LENGTH
	
	//Play cutscene
	wait(0.5);
	PLAY_LOCAL_SOUND("zm_alien_isolation__cs_torrensintro");
	level thread lui::play_movie_with_timeout(AYZ_CUTSCENE_ID_01, "fullscreen", intro_cutscene_length, true);

	//Wait for cutscene to end and continue
	wait(intro_cutscene_length + 2); //+2 to smooth transition a bit
}

//Blackscreen for each player (closed on wakeup start)
function BSP_TORRENS_BLACKSCREEN(player) {
	alien_black_screen = player OpenLUIMenu("blackscreen");
	level waittill("starting_torrens_wakeup");
	player CloseLUIMenu(alien_black_screen);
}

//Initiate login screens
function BSP_TORRENS_LOGIN_SCREENS() {	
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
	signInTrigger2 = getEnt("signintrigger_bed3", "targetname");
	signInTrigger3 = getEnt("signintrigger_bed4", "targetname");
	signInTrigger4 = getEnt("signintrigger_bed5", "targetname");

	HIDE_TRIGGER(signInTrigger1);
	HIDE_TRIGGER(signInTrigger2);
	HIDE_TRIGGER(signInTrigger3);
	HIDE_TRIGGER(signInTrigger4);
	
	if (dempseyInBed != 0) {
		thread BSP_TORRENS_HANDLE_SIGNIN_MONITORS(dempseyInBed, "Dempsey");
	}
	if (nikolaiInBed != 0) {
		thread BSP_TORRENS_HANDLE_SIGNIN_MONITORS(nikolaiInBed, "Nikolai");
	}
	if (richtofenInBed != 0) {
		thread BSP_TORRENS_HANDLE_SIGNIN_MONITORS(richtofenInBed, "Richtofen");
	} 
	if (takeoInBed != 0) {
		thread BSP_TORRENS_HANDLE_SIGNIN_MONITORS(takeoInBed, "Takeo");
	} 
}

//Handle login screen character
function BSP_TORRENS_HANDLE_SIGNIN_MONITORS(bedNum, charName) {
	signInTrigger = getEnt("signintrigger_bed" + bedNum, "targetname");
	UPDATE_TRIGGER("Press ^3[{+activate}]^7 to Sign In as " + charName, signInTrigger);
	
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
	
	HIDE_TRIGGER(signInTrigger);
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

//Put all players in cryopods
function BSP_TORRENS_PUT_PLAYERS_IN_CRYOPODS() {
	foreach (player in level.players) {		
		//Force players to look UP
		bedLocation = 0;
		if (player.characterIndex == 0) {
			bedLocation = level.dempseybedlocation;
		}
		if (player.characterIndex == 1) {
			bedLocation = level.nikolaibedlocation;
		}
		if (player.characterIndex == 2) {
			bedLocation = level.richtofenbedlocation;
		}
		if (player.characterIndex == 3) {
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
		
		//Place player in pod
		player SetOrigin(playerLocation);
		player SetPlayerAngles(playerAngle);

		//Hide weapon hud
		player setClientUIVisibilityFlag("weapon_hud_visible", 0);
	}
}

//Play scripted wakeup sequence
function BSP_TORRENS_WAKEUP_SEQUENCE() {
	//Start SFX
	PLAY_LOCAL_SOUND("zm_alien_isolation__cs_wakeup");

	//Take weapons again (just in case) and set stance
	foreach (player in level.players) {
		weapons = player GetWeaponsList(true);
		foreach (weapon in weapons)
		{
			player TakeWeapon(weapon);
		}

		//Set player stance (and re-freeze controls)
		player SetStance("prone");
		player FreezeControls(true);
	}
	
	//Run wakeup sequence
	lui::screen_fade_out(0);
	level notify("starting_torrens_wakeup");
	wait(4);
	lui::screen_fade_in(1);
	wait(1);
	lui::screen_fade_out(1);
	wait(3);
	lui::screen_fade_in(1);
	wait(1);
	thread BSP_TORRENS_CRYOPOD_OPEN_SEQUENCE();
	wait(3);
	level util::set_lighting_state(0); 
	wait(3);
	lui::screen_fade_out(1);
	level thread zm_audio::sndMusicSystem_PlayState("torrens_intro_theme");
	wait(4);
}

//Open all lids to cryro beds
function BSP_TORRENS_CRYOPOD_OPEN_SEQUENCE() {
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

//Get players out of cryopods
function BSP_TORRENS_GET_OUT_OF_CYROPODS() {
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
		
		torrensPlayerTwo AllowCrouch(false);
		torrensPlayerTwo SetPlayerAngles(playerAngle);
		torrensPlayerTwo SetOrigin(playerLocation);
		torrensPlayerTwo SetStance("stand");
	}

	level notify("torrens_enable_cryo_collision");

	wait(4);
	
	//Disallow sprint, jump and melee for Torrens
	foreach (player in level.players) {	
		player FreezeControls(false);
		player AllowSprint(false);
		player AllowJump(false);
		player AllowMelee(false);
		player AllowCrouch(true);
	}
	
	//Fade back in
	lui::screen_fade_in(1);

	//Update objective
	thread UPDATE_OBJECTIVE("Sign in to the Torrens.");
}

//Open spawn door once players have signed in (and also enable all other doors)
function BSP_TORRENS_OPEN_SPAWN_DOOR_WHEN_ALL_SIGNED_IN() {
	//Wait for ALL players to "sign in"
	self waittill("torrens_all_players_signedin");
	
	//Handle all doors on the Torrens (doortype 1 = small, doortype 2 = medium, 3 = medbay)
	level.currentlyOpenDoors = array();
	thread BSP_TORRENS_AUTOMATIC_DOOR("crewcoridoor", 1); //Door to coridoor to crew quarters
	thread BSP_TORRENS_AUTOMATIC_DOOR("crewroom", 2); //Door to crew quarters
	thread BSP_TORRENS_AUTOMATIC_DOOR("spawntoairlockjunction", 2); //Door to airlock junction from spawn
	thread BSP_TORRENS_AUTOMATIC_DOOR("canteencoridoor", 1); //Door to coridoor to canteen
	thread BSP_TORRENS_AUTOMATIC_DOOR("canteen", 1); //Door to canteen
	thread BSP_TORRENS_AUTOMATIC_DOOR("bridge", 1); //Door to the bridge
	thread BSP_TORRENS_AUTOMATIC_DOOR("medbaycoridoor", 2); //Door to coridoor to medbay from junction
	thread BSP_TORRENS_AUTOMATIC_DOOR("medbay", 3); //Door to medbay
	
	//Open spawnroom door
	wait(1);
	spawnDoor = getEnt("torrensSpawnDoor", "targetname");
	spawnDoorClip = getEnt("torrensSpawnDoor_clip", "targetname");
	
	spawnDoor MoveTo(spawnDoor.origin + (0,0,76), 2, 1, 1);
	spawnDoor PlaySound("zm_alien_isolation__smalldoor_open");
	spawnDoorClip MoveTo(spawnDoorClip.origin + (0,0,76), 2, 1, 1);
	wait(1);
	
	//Update objective
	thread UPDATE_OBJECTIVE("Explore the Torrens.");
}

//Auto door open script
function BSP_TORRENS_AUTOMATIC_DOOR(doorID, doorType) {
	self endon("players_on_sevastopol"); //players are off the torrens, can stop this script.
	
	doorTriggerZone = getEnt("torrens_doortrigger_" + doorID, "targetname"); //grab our trigger zone
	doorTriggerZone NotSolid();
	
	//Only run door script if not canteencoridoor - that has been depreciated.
	if (doorID != "canteencoridoor") {
		if (doorID == "bridge") {
			doorTrigger = getEnt("torrens_bridge_door_trigger", "targetname");
			UPDATE_TRIGGER(AYZ_DOORPROMPT_LOCKED, doorTrigger);
			self waittill("torrens_enable_bridge_door");
			HIDE_TRIGGER(doorTrigger);
			//TODO swap door lights here
		}
		
		if (doorID == "spawntoairlockjunction") {
			doorTrigger = getEnt("junction_door_trigger_lowpower", "targetname");
			UPDATE_TRIGGER(AYZ_DOORPROMPT_LOW_POWER, doorTrigger);
			self waittill("torrens_brokendoor_fixed");
			HIDE_TRIGGER(doorTrigger);
			//TODO swap door lights here
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

//Handle power rerouting for the broken door (and objective update)
function BSP_TORRENS_BROKEN_DOOR_POWER_REROUTE() {
	//Wait for player to approach the locked door and update objective
	trigger_reroute_power = getEnt("trigger_reroute_power_torrens", "targetname");
	HIDE_TRIGGER(trigger_reroute_power);
	thread BSP_TORRENS_BROKEN_DOOR_WAIT_FOR_APPROACH();
	level waittill("torrens_brokendoor_notified");
	thread UPDATE_OBJECTIVE("Reroute power to open the door.");
	
	//Wait for player to fix the door
	UPDATE_TRIGGER("Hold ^3[{+activate}]^7 to reroute power", trigger_reroute_power);
	trigger_reroute_power waittill("trigger", player);
	access_rewire = getEnt("torrens_access_rewire", "targetname");
	access_rewire RotateTo((0,90,180), 1, 0.5, 0.5);
	access_rewire PlaySound("zm_alien_isolation__tow_monitor_changed"); //sfx
	HIDE_TRIGGER(trigger_reroute_power);
	level notify("torrens_brokendoor_fixed");
	wait(1.5);
	thread UPDATE_OBJECTIVE("Explore the Torrens.");
}

//handle broken door on Torrens
function BSP_TORRENS_BROKEN_DOOR_WAIT_FOR_APPROACH() {
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

//Setup the bridge once the player enters the canteen (and objective update)
function BSP_TORRENS_SETUP_BRIDGE_WHEN_CANTEEN_ENTERED() {
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
	PLAY_LOCAL_SOUND("zm_alien_isolation__torrens_get_to_bridge");
	
	//Wait a bit and update objective
	wait(5);
	thread UPDATE_OBJECTIVE("Collect your weapons.");
	
	//Open bridge door
	self notify("torrens_enable_bridge_door");
	
	//Start character animations	
	verlaine = getEnt("verlaine_model", "targetname");
	connor = getEnt("connor_model", "targetname");
    verlaine useanimtree(#animtree);
    connor useanimtree(#animtree);
	wait(1);
    verlaine AnimScripted("animations_on_torrens_verlaine", verlaine.origin , verlaine.angles, %alien_isolation_verlaine_anim_idle);
    connor AnimScripted("animations_on_torrens_connor", connor.origin , connor.angles, %alien_isolation_connor_anim_idle);
}

//Wait for all players to pick up their weapons from the bridge
function BSP_TORRENS_ALL_PLAYERS_PICK_UP_WEAPONS() {
	//Wait for transition trigger to be pushed
	bridge_weapon_trigger = getEnt("trigger_torrens_transition_to_sevastopol", "targetname");
	UPDATE_TRIGGER("Hold ^3[{+activate}]^7 to pick up weapon", bridge_weapon_trigger);
	bridge_weapon_trigger waittill("trigger", player);	
}

//Transition over to the spaceflight terminal.
function BSP_TORRENS_WEAPON_PICKUP_CUTSCENE() {
	//Pre-define some stuff
	transition_cutscene_length = 63; //THIS WILL NEED CHANGING TO THE ACTUAL LENGTH
	
	//transition_from_torrens script_flag
	
	//Prime our cutscene (might want to do this a bit earlier)
	level thread lui::prime_movie(AYZ_CUTSCENE_ID_02);

	//Freeze players and start transition cutscene
	foreach(player in level.players) {
		player FreezeControls(true);
		//player AllowSprint(true);
		player AllowJump(true);
		player AllowMelee(true);
	}
	
	lui::screen_fade_out(1);
	wait(1);
	PLAY_LOCAL_SOUND("zm_alien_isolation__cs_torrens2sev");
	level thread lui::play_movie_with_timeout(AYZ_CUTSCENE_ID_02, "fullscreen", transition_cutscene_length, true);
	
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
	
	//Move every player
	loopCounter = 0;
	foreach (player in level.players) {
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
		player SetOrigin(destination.origin); 
		player SetPlayerAngles((0,-150,0));
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
	}
	
	//Wait for cutscene to end - fade back in and allow players to move again
	wait(transition_cutscene_length + 0.5); //adding 0.5 to allow for any issues
	lui::screen_fade_in(1);
	wait(1);
	
	//Unfreeze controls
	foreach(player in level.players) {
		player FreezeControls(false);
		player SetPlayerCollision(true); //re-enable player collision to allow zombie damage
	}
	
	//Let the game know we're on Sevastopol
	self notify("players_on_sevastopol");
}