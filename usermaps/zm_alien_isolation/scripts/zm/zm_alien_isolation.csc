#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\system_shared;

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

//Usermap
#using scripts\zm\zm_usermap;


function main()
{
	zm_usermap::main();

	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_alien_isolation.csv", 1);
	
	//Load blackscreen on connect (for cryopod transition hide)
	LuiLoad("ui.uieditor.menus.hud.blackscreen");
	//LuiLoad("ui.uieditor.menus.hud.alien_objective");
	//LuiLoad("ui.uieditor.menus.hud.audiolog");
	callback::on_localclient_connect(&on_local_client_connect);
	
	//Wait for client to load & perform FOV changes in cryopod cutscene
	util::waitforclient(0);
	clientFov = GetDvarFloat("cg_fov_default");
	SetDvar("cg_fov_default", "91");
	level waittill("out_of_cryopod", localClientNum);
	SetDvar("cg_fov_default", clientFov);

	//Show audiolog UI when required
	level waittill("show_objective", localClientNum);
}


function on_local_client_connect(localClientNum)
{	
	//hud = CreateLUIMenu(localClientNum, "ui.uieditor.menus.hud.audiolog");
	//OpenLUIMenu(localClientNum, hud);
	//CloseLUIMenu(localClientNum, hud);

	//hud2 = CreateLUIMenu(localClientNum, "ui.uieditor.menus.hud.alien_objective");
	//OpenLUIMenu(localClientNum, hud2);
	//CloseLUIMenu(localClientNum, hud2);
}