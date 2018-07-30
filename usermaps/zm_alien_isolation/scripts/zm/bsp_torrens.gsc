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
	
	//Make clips non-solid
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
	//Disable zombies
	SetDvar("cg_draw2d", 0);
	SetDvar("ai_disableSpawn", "1");

	level flag::wait_till("all_players_connected");

	//Prime our cutscene
	level thread lui::prime_movie(AYZ_CUTSCENE_ID_01);

	//Freeze controls and show blackscreen to hide game
	foreach	(player in level.players) {		
		player FreezeControls(true);
		thread BSP_TORRENS_BLACKSCREEN(player);
		thread OVERRIDE_CONTROL_UNFREEZE(player); 
	}

	level flag::wait_till("initial_blackscreen_passed");
	lui::screen_fade_out(0);

	foreach (player in level.players) {
		player FreezeControls(true); //paranoia is setting in...
	}

	BSP_TORRENS_GET_BED_LOCATIONS_AND_SETUP_MONITORS();

	//Set stance, disable grenades, hide view model, set walk speed, etc...
	foreach (player in level.players) {
		thread BSP_TORRENS_SETUP_PLAYER(player);
	}
	
	//Play cutscene
	PLAY_LOCAL_SOUND("zm_alien_isolation__cs_torrensintro");
	level thread lui::play_movie(AYZ_CUTSCENE_ID_01, "fullscreen");

	//Wait for cutscene to end and continue
	wait(23.4); //+2 to smooth transition a bit
}

//Setup player for the Torrens "level"
function BSP_TORRENS_SETUP_PLAYER(player) {
	player FreezeControls(false);
	WAIT_SERVER_FRAME; 
	WAIT_SERVER_FRAME; 
	player DisableWeaponFire();
	player DisableOffhandSpecial();
	//player SetPlayerCollision(false);
	player AllowStand(false);
	player AllowCrouch(false);
	player AllowProne(true);
	WAIT_SERVER_FRAME; 
	player SetStance("prone");
	WAIT_SERVER_FRAME; 
	player HideViewModel();
	player SetMoveSpeedScale(0.7);
	WAIT_SERVER_FRAME;
	WAIT_SERVER_FRAME; 
	player FreezeControls(true);
	player.allowdeath = false; 
}

//Blackscreen for each player (closed on wakeup start)
function BSP_TORRENS_BLACKSCREEN(player) {
	alien_black_screen = player OpenLUIMenu("blackscreen");
	level waittill("starting_torrens_wakeup");
	player CloseLUIMenu(alien_black_screen);
}

//Initiate login screens
function BSP_TORRENS_GET_BED_LOCATIONS_AND_SETUP_MONITORS() {	
	level.dempseybedlocation = 0;
	level.nikolaibedlocation = 0;
	level.richtofenbedlocation = 0;
	level.takeobedlocation = 0;
	
	foreach(player in level.players) {	
		if (player.origin[0] == -26101.1 && player.origin[1] == -12729.1) {
			CURRENT_BED = 2;
		}
		else if (player.origin[0] == -26067.2 && player.origin[1] == -12742.8) {
			CURRENT_BED = 3;
		}
		else if (player.origin[0] == -26066.9 && player.origin[1] == -12810.7) {
			CURRENT_BED = 4;
		}
		else if (player.origin[0] == -26101.1 && player.origin[1] == -12825) {
			CURRENT_BED = 5;
		}

		if (player.characterIndex == 0) {
			level.dempseybedlocation = CURRENT_BED;
		}
		if (player.characterIndex == 1) {
			level.nikolaibedlocation = CURRENT_BED;
		}
		if (player.characterIndex == 2) {
			level.richtofenbedlocation = CURRENT_BED;
		}
		if (player.characterIndex == 3) {
			level.takeobedlocation = CURRENT_BED;
		}
    }

    level.signedInPlayerCount = 0;
	
	//Trigger resets
	signInTrigger1 = getEnt("signintrigger_bed2", "targetname");
	signInTrigger2 = getEnt("signintrigger_bed3", "targetname");
	signInTrigger3 = getEnt("signintrigger_bed4", "targetname");
	signInTrigger4 = getEnt("signintrigger_bed5", "targetname");

	HIDE_TRIGGER(signInTrigger1);
	HIDE_TRIGGER(signInTrigger2);
	HIDE_TRIGGER(signInTrigger3);
	HIDE_TRIGGER(signInTrigger4);
	
	//Setup monitors
	if (level.dempseybedlocation != 0) {
		thread BSP_TORRENS_HANDLE_SIGNIN_MONITORS(level.dempseybedlocation, "Dempsey");
	}
	if (level.nikolaibedlocation != 0) {
		thread BSP_TORRENS_HANDLE_SIGNIN_MONITORS(level.nikolaibedlocation, "Nikolai");
	}
	if (level.richtofenbedlocation != 0) {
		thread BSP_TORRENS_HANDLE_SIGNIN_MONITORS(level.richtofenbedlocation, "Richtofen");
	} 
	if (level.takeobedlocation != 0) {
		thread BSP_TORRENS_HANDLE_SIGNIN_MONITORS(level.takeobedlocation, "Takeo");
	} 
}

//Handle login screen character
function BSP_TORRENS_HANDLE_SIGNIN_MONITORS(bedNum, charName) {
	//Update trigger
	signInTrigger = getEnt("signintrigger_bed" + bedNum, "targetname");
	UPDATE_TRIGGER("Press ^3[{+activate}]^7 to Sign In as " + charName, signInTrigger);
	
	//Update Monitor
	bedMonitor = getEnt("torrens_signinmonitor_0" + bedNum, "targetname");
	bedMonitor SetModel("monitor_torrens_signin"); 
	
	//Wait for correct player to trigger
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
	foreach(player in level.players) {
		player_counter = player_counter + 1;
	}
	
	//All signed in, alert our script
	if (level.signedInPlayerCount == player_counter) {
		self notify("torrens_all_players_signedin");
	}
}

//Put all players in cryopods
function BSP_TORRENS_PUT_PLAYERS_IN_CRYOPODS() {
	WAIT_SERVER_FRAME;
	foreach (player in level.players) {
		player FreezeControls(true);

		//Look Up
		player SetPlayerAngles((-45,0,0));

		//Make sure to be in right bed (after control unfreeze)
		if (player.characterIndex == 0) {
			BED_LOCATION = level.dempseybedlocation;
		}
		else if (player.characterIndex == 1) {
			BED_LOCATION = level.nikolaibedlocation;
		}
		else if (player.characterIndex == 2) {
			BED_LOCATION = level.richtofenbedlocation;
		}
		else if (player.characterIndex == 3) {
			BED_LOCATION = level.takeobedlocation;
		}
		BedLocationStruct = struct::get("SPAWN_BED_" + BED_LOCATION, "targetname");
		player SetOrigin(BedLocationStruct.origin);
		player SetStance("prone"); //shouldn't need this again, but just in case

		//Hide weapon hud
		player setClientUIVisibilityFlag("weapon_hud_visible", 0);
	}
}

//Play scripted wakeup sequence
function BSP_TORRENS_WAKEUP_SEQUENCE() {
	//Start SFX
	PLAY_LOCAL_SOUND("zm_alien_isolation__cs_wakeup");

	//Start wakeup sequence
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

	wait(1);
	cryoSmokeSpot = struct::get("cryo_smoke_spot", "targetname");
	PlayFX(level._effect["torrens_cryo_smoke"], cryoSmokeSpot.origin);
}

//Get players out of cryopods
function BSP_TORRENS_GET_OUT_OF_CYROPODS() {
	//Get out of the pod
	foreach (player in level.players) {
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
		playerLocation = (0,0,0);
		if (bedLocation == 2) {
			playerLocation = (-26101.1, -12731.1, 11778);
		}
		if (bedLocation == 3) {
			playerLocation = (-26067.2, -12742.8, 11778);
		}
		if (bedLocation == 4) {
			playerLocation = (-26066.9, -12810.7, 11778);
		}
		if (bedLocation == 5) {
			playerLocation = (-26101.1, -12822, 11778);
		}
		
		player SetPlayerAngles((0,0,0));
		player SetOrigin(playerLocation);
		player AllowProne(false);
		player AllowCrouch(false);
		player AllowStand(true);
		player SetStance("stand");
		player AllowSprint(false);
		player AllowJump(false);
		player AllowMelee(false);
		util::setClientSysState("levelNotify", "out_of_cryopod", player);
	}

	level notify("torrens_enable_cryo_collision");

	wait(4);

	foreach (player in level.players) {
		player FreezeControls(false);
	}
	
	//Fade back in
	lui::screen_fade_in(1);

	//Update objective
	thread UPDATE_OBJECTIVE(&"AYZ_OBJECTIVE_SIGN_IN_TO_TORRENS");
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
	spawnDoorLight = getEnt("torrensSpawnDoor_Light", "targetname");
	spawnDoorClip = getEnt("torrensSpawnDoor_clip", "targetname");
	
	spawnDoor MoveTo(spawnDoor.origin + (0,0,76), 2, 1, 1);
	spawnDoorLight MoveTo(spawnDoorLight.origin + (0,0,76), 2, 1, 1);
	spawnDoorLight SetModel("ayz_new_door_lights_open");
	spawnDoor PlaySound("zm_alien_isolation__smalldoor_open");
	spawnDoorClip MoveTo(spawnDoorClip.origin + (0,0,76), 2, 1, 1);
	PlayFX(level._effect["torrens_door_dust"], spawnDoor.origin + (0,0,23));
	wait(1);
	
	//Update objective
	thread UPDATE_OBJECTIVE(&"AYZ_OBJECTIVE_EXPLORE_TORRENS");
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
			doorLightEntity = getEnt("torrens_door_light_bridge", "targetname");
			UPDATE_TRIGGER(&"AYZ_DOORPROMPT_LOCKED", doorTrigger);
			self waittill("torrens_enable_bridge_door");
			HIDE_TRIGGER(doorTrigger);
			doorLightEntity SetModel("ayz_new_door_lights_open");
		}
		
		if (doorID == "spawntoairlockjunction") {
			doorTrigger = getEnt("junction_door_trigger_lowpower", "targetname");
			doorLightEntity = getEnt("torrens_door_light_spawntoairlockjunction", "targetname");
			UPDATE_TRIGGER(&"AYZ_DOORPROMPT_LOW_POWER", doorTrigger);
			self waittill("torrens_brokendoor_fixed");
			HIDE_TRIGGER(doorTrigger);
			doorLightEntity SetModel("ayz_new_door_lights_open");
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
						door_open_time = 1.2;
					}
					else if (doorType == 2) {
						door_open_time = 1.7;
					}

					if (doorType != 3) {
						doorEntity = getEnt("torrens_door_" + doorID, "targetname");
						doorLightEntity = getEnt("torrens_door_light_" + doorID, "targetname");
						doorClip = getEnt("torrens_door_" + doorID + "_clip", "targetname");
						
						doorEntity MoveTo(doorEntity.origin + (0,0,76), door_open_time, 0.5, 0.5);
						doorEntity PlaySound("zm_alien_isolation__smalldoor_open");

						doorLightEntity MoveTo(doorLightEntity.origin + (0,0,76), door_open_time, 0.5, 0.5);
						
						doorClip MoveTo(doorClip.origin + (0,0,76), door_open_time, 0.5, 0.5);

						PlayFX(level._effect["torrens_door_dust"], doorEntity.origin + (0,0,23));
						
						wait(door_open_time); //wait for anim to finish
					} else {
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
						doorLightEntity = getEnt("torrens_door_light_" + doorID, "targetname");
						doorClip = getEnt("torrens_door_" + doorID + "_clip", "targetname");
						
						doorEntity MoveTo(doorEntity.origin - (0,0,76), 1.7, 0.5, 0.5);
						doorEntity PlaySound("zm_alien_isolation_torrens_door_close");

						doorLightEntity MoveTo(doorLightEntity.origin - (0,0,76), 1.7, 0.5, 0.5);
						
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
	//HIDE_TRIGGER(trigger_reroute_power);
	thread BSP_TORRENS_BROKEN_DOOR_WAIT_FOR_APPROACH();
	//level waittill("torrens_brokendoor_notified");
	//thread UPDATE_OBJECTIVE(&"AYZ_OBJECTIVE_REROUTE_POWER_FOR_DOOR");
	
	//Wait for player to fix the door
	UPDATE_TRIGGER("Hold ^3[{+activate}]^7 to reroute power", trigger_reroute_power);
	trigger_reroute_power waittill("trigger", player);
	access_rewire = getEnt("torrens_access_rewire", "targetname");
	access_rewire RotateTo((0,90,180), 1, 0.5, 0.5);
	access_rewire PlaySound("zm_alien_isolation__tow_monitor_changed"); //sfx
	HIDE_TRIGGER(trigger_reroute_power);
	level notify("torrens_brokendoor_fixed");
	wait(1.5);
	thread UPDATE_OBJECTIVE(&"AYZ_OBJECTIVE_EXPLORE_TORRENS");
}

//handle broken door on Torrens
function BSP_TORRENS_BROKEN_DOOR_WAIT_FOR_APPROACH() {
	level endon("torrens_brokendoor_fixed");

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
			//level notify("torrens_brokendoor_notified");
			break;
		}
		wait 0.1;
	}
	thread UPDATE_OBJECTIVE(&"AYZ_OBJECTIVE_REROUTE_POWER_FOR_DOOR");
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
	thread UPDATE_OBJECTIVE(&"AYZ_OBJECTIVE_COLLECT_WEAPONS");
	
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
	//Setup up all triggers
	for (i=0; i<4;i++) {
		bridge_weapon_trigger = getEnt("trigger_torrens_transition_to_sevastopol_"+(i+1), "targetname");
		UPDATE_TRIGGER("Hold ^3[{+activate}]^7 to pick up weapon", bridge_weapon_trigger);
		HIDE_TRIGGER(bridge_weapon_trigger, false);
		if (i==0) {
			SHOW_TRIGGER(bridge_weapon_trigger);
		}
	}
	
	//Count up our players
	player_count = 0;
	foreach (player in level.players) {
		player_count = player_count + 1;
	}
	WAIT_SERVER_FRAME;

	//Wait for all players to trigger (pick up a weapon)
	level.playersWhoHavePickedUpWeapons = array();
	for (i=0;i<player_count;i++) {
		//Get trigger and show to people that haven't triggered yet
		bridge_weapon_trigger = getEnt("trigger_torrens_transition_to_sevastopol_"+(i+1), "targetname");
		foreach (player in level.players) {
			foreach (activatedPlayer in level.playersWhoHavePickedUpWeapons) {
				if (player != activatedPlayer) {
					bridge_weapon_trigger SetVisibleToPlayer(player);
				}
			}
		}
		//Wait for it to be activated, and remember who did it
		bridge_weapon_trigger waittill("trigger", player);
		ArrayInsert(level.playersWhoHavePickedUpWeapons, player, level.playersWhoHavePickedUpWeapons.size);
		//Show view model, give weapon, hide trigger
		player ShowViewModel();
		player zm_weapons::weapon_give(GetWeapon("pistol_standard"), false, false, true, true);
		player DisableWeaponFire();
		player DisableWeapons();
		HIDE_TRIGGER(bridge_weapon_trigger);
	}

	//Freeze and fade out to cutscene
	wait(1);
	foreach (player in level.players) {
		player FreezeControls(true);
	}
	wait(0.5);
}

//Transition over to the spaceflight terminal.
function BSP_TORRENS_WEAPON_PICKUP_CUTSCENE() {
	//Pre-define some stuff
	transition_cutscene_length = 63; //THIS WILL NEED CHANGING TO THE ACTUAL LENGTH
	
	//Prime our cutscene (might want to do this a bit earlier)
	level thread lui::prime_movie(AYZ_CUTSCENE_ID_02);

	//Freeze players and start transition cutscene
	foreach(player in level.players) {
		player AllowJump(true);
		player AllowMelee(true);
		player EnableOffhandSpecial();
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
		currentSpawner.angles = spawnerStructNew.angles;
	}
	
	//Grab original and new respawn struct
    respawnOrigStruct = struct::get("player_respawn_point", "targetname");
    respawnMoveStruct = struct::get("sft_spawners_9", "targetname");
	
	//Move original to new
	respawnOrigStruct.origin = respawnMoveStruct.origin;
	respawnOrigStruct.angles = respawnMoveStruct.angles;
	
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
		player SetPlayerAngles(destination.angles);
	}
	
	//Wait for cutscene to end - fade back in and allow players to move again
	wait(transition_cutscene_length + 0.5); //adding 0.5 to allow for any issues
	lui::screen_fade_in(1);
	wait(1);
	
	//Unfreeze controls
	foreach(player in level.players) {
		player FreezeControls(false);
		player AllowProne(true);
		player AllowCrouch(true);
		player AllowStand(true);
		player SetMoveSpeedScale(1);
		//player SetPlayerCollision(true); //re-enable player collision to allow zombie damage
		player.allowdeath = true; 
	}
	
	//Let the game know we're on Sevastopol
	self notify("players_on_sevastopol");
}