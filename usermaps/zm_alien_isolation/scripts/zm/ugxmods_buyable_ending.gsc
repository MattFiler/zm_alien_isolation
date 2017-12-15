/*
	Created by Andy King (treminaor) for UGX-Mods.com. © UGX-Mods 2016
	Please include credit if you use this script and do not distribute edited versions of it without my permission.

	Instructions: https://confluence.ugx-mods.com/display/UGXMODS/BO3+%7C+Adding+Buyable+Ending+to+Zombiemode

	Version 1.0 10/15/2016 12:55PM
*/


#using scripts\shared\flag_shared;
#using scripts\zm\_zm_score;

#define ENDGAME_WAIT_FOR_FLAG			"" //if you want the ending to require a flag to be set from another script you have, enter the flag here.
#define ENDGAME_WAIT_FOR_NOTIFY			"" //if you want the ending to require a level notify to be sent from another script you have, enter the notify string here.
#define ENDGAME_COST					30000 //Cost to end the game

function autoexec endgame()
{
	if(ENDGAME_WAIT_FOR_NOTIFY != "")
		level.custom_game_over_hud_elem = &buyable_game_over;

	ending = getEnt("ending", "targetname");
	ending setCursorHint("HINT_NOICON");

	if(ENDGAME_WAIT_FOR_FLAG != "")
	{
		level flag::wait_till(ENDGAME_WAIT_FOR_FLAG);
	}
	else if(ENDGAME_WAIT_FOR_NOTIFY != "")
	{
		level waittill(ENDGAME_WAIT_FOR_NOTIFY);
	}
	else
	{
		ending setHintString("TO TOW PLATFORM [&&1] - cost: " + ENDGAME_COST);
	}

    while(1)
	{
		
		ending waittill("trigger", player);
		if(player.score < ENDGAME_COST)
		{
			wait 0.1;
			player playsound("zmb_no_cha_ching");
			continue;
		}
		player zm_score::minus_to_player_score(ENDGAME_COST); 
		player playsound("zmb_cha_ching");
		break;
	}

	ending SetInvisibleToAll(); //little fix to hide the prompt after purchase.
	level notify("end_game");
}

function buyable_game_over(player, game_over, survived)
{
	game_over.alignX = "center";
	game_over.alignY = "middle";
	game_over.horzAlign = "center";
	game_over.vertAlign = "middle";
	game_over.y -= 130;
	game_over.foreground = true;
	game_over.fontScale = 3;
	game_over.alpha = 0;
	game_over.color = ( 1.0, 1.0, 1.0 );
	game_over.hidewheninmenu = true;
	game_over SetText("You escaped Sevastopol!");

	game_over FadeOverTime( 1 );
	game_over.alpha = 1;
	if ( player isSplitScreen() )
	{
		game_over.fontScale = 2;
		game_over.y += 40;
	}
}