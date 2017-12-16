#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_pack_a_punch;
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

//Traps
#using scripts\zm\_zm_trap_electric;

//Required for emissive colour change
//#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;

//Usermap
#using scripts\zm\zm_usermap;

//Precache UI

function main()
{
	zm_usermap::main();

	include_weapons();
	
	//Load new UI
	callback::on_localclient_connect(&on_local_client_connect);
    LuiLoad("ui.uieditor.menus.hud.T7Hud_zm_alien_isolation");
	
	//Wait for client to load
	//util::waitforclient( 0 );
	
	//Location based ambient sounds for the level - gameroom machines are handled in GSC
	//thread ambient_sounds(); 
}

function include_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

function on_local_client_connect( localClientNum )
{
    hud = CreateLUIMenu(localClientNum, "T7Hud_zm_alien_isolation");
    OpenLUIMenu(localClientNum, hud);
}


//Play all ambient sounds in the level
function ambient_sounds() {
	//CCTV Room
	play_ambient_sound_at_point("ambientsound_cctvroom", "zm_alien_isolation_ambient_cctvroom");
	
	//Endgame Elevator 
	play_ambient_sound_at_point("ambientsound_endgame", "zm_alien_isolation_ambience_lift");
	
	//Baggage Reclaim End Door 
	play_ambient_sound_at_point("ambientsound_baggagereclaim", "zm_alien_isolation_ambience_workshop");
	
	//Noodlebar 
	play_ambient_sound_at_point("ambientsound_noodlebar", "zm_alien_isolation_ambience_prison");
	
	//Spawn 
	play_ambient_sound_at_point("ambientsound_spawnroom", "zm_alien_isolation_ambience_mediumroom");
}
function play_ambient_sound_at_point(locationToGet, soundToPlay) {
	areaToPlaySound = struct::get(locationToGet, "targetname");
	SoundLoopEmitter(soundToPlay, areaToPlaySound.origin);
}