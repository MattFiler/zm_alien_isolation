#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;

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


function main()
{
	zm_usermap::main();

	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
	
	//Load new UI
	callback::on_localclient_connect(&on_local_client_connect);
	LuiLoad("ui.uieditor.menus.hud.T7Hud_zm_alien_isolation");
	LuiLoad("ui.uieditor.menus.hud.popup_zm_alien_isolation");
	
	//Wait for client to load
	//util::waitforclient( 0 );
}


//Load UI on connect & handle objectives
function on_local_client_connect(localClientNum)
{
	hud = CreateLUIMenu(localClientNum, "T7Hud_zm_alien_isolation");
	OpenLUIMenu(localClientNum, hud);
	
	hud2 = CreateLUIMenu(localClientNum, "popup_zm_alien_isolation");
	OpenLUIMenu(localClientNum, hud2);
}