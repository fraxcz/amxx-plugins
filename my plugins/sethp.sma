#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <hamsandwich>
#include <cstrike>
#define PLUGIN "sethp"
#define VERSION "1.0"
#define AUTHOR "frax"

new g_pcHpT
new g_pcHpCT

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	g_pcHpT = create_cvar( "amx_hp_t", "100.0", FCVAR_NONE, "Sets starting amount of HP for Ts.", true, 1.0, false )
	g_pcHpCT = create_cvar( "amx_hp_ct", "100.0", FCVAR_NONE, "Sets starting amount of HP for CTs.", true, 1.0, false )
	register_concmd( "amx_hp", "cmd_hp", ADMIN_SLAY, "amx_hp <target> <hpamount>" )
	RegisterHamPlayer( Ham_Spawn, "fw_hamSpawn", 1 )
}

public cmd_hp(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
		
	new targetArg[24]
	new hpamount[10]
	new players[32]
	new numOfPlayers = 0

	read_argv(1, targetArg, 24)
	read_argv(2, hpamount, 10)
	
	if(equali(targetArg, "@", 1))
	{
		if(equali(targetArg, "@T"))
		{
			get_players_ex(players, numOfPlayers, GetPlayers_ExcludeDead | GetPlayers_MatchTeam, "TERRORIST")
		}
		else if(equali(targetArg, "@CT"))
		{
			get_players_ex(players, numOfPlayers, GetPlayers_ExcludeDead | GetPlayers_MatchTeam, "CT")
		}
		else
		{
			return PLUGIN_HANDLED
		}
		for(new i = 0; i < numOfPlayers; i++)
		{
			set_user_health(players[i], str_to_num(hpamount))
		}

		return PLUGIN_HANDLED
	}

	new playertarget = cmd_target(id, targetArg, 1)
	
	if(!playertarget)
	{
		console_print(id, "%s could not be targeted", targetArg)

		return PLUGIN_HANDLED
	}
		
	new health = str_to_num(hpamount)
	
	set_user_health(playertarget, health)

	return PLUGIN_HANDLED
}

public fw_hamSpawn(id)
{
	if(!is_user_alive(id))
		return PLUGIN_HANDLED

	switch(cs_get_user_team(id)){

		case 1:
		{
			set_user_health(id, get_pcvar_num(g_pcHpT))

			return PLUGIN_HANDLED
		}
		case 2:
		{
			set_user_health(id, get_pcvar_num(g_pcHpCT))

			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

