// taken from https://forums.alliedmods.net/showthread.php?p=88160
#include <amxmodx>
#include <amxmisc>
#include <engine>

#define PLUGIN "Multijump"
#define VERSION "1.0"
#define AUTHOR "frax"
new g_iPlayersJumps[33] = 0
new bool:g_iDoJump[33] = false
new g_maxJumps

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	g_maxJumps = create_cvar("amx_maxjumps", "3.0", FCVAR_NONE, "maximum jumps", true, 0.0, false)

}

public client_putinserver(id)
{
	g_iPlayersJumps[id] = 0
	g_iDoJump[id] = false
}

public client_disconnected(id)
{
	g_iPlayersJumps[id] = 0
	g_iDoJump[id] = false
}

public client_PreThink(id)
{
	if(!is_user_alive(id) || get_user_team(id) == 1) 
		return PLUGIN_CONTINUE

	new nbut = get_user_button(id)
	new obut = get_user_oldbutton(id)

	if((nbut & IN_JUMP) && !(get_entity_flags(id) & FL_ONGROUND) && !(obut & IN_JUMP))
	{
		if(g_iPlayersJumps[id] < get_pcvar_num(g_maxJumps) - 1)
		{
			g_iDoJump[id] = true

			g_iPlayersJumps[id]++

			return PLUGIN_CONTINUE
		}
	}
	if((nbut & IN_JUMP) && (get_entity_flags(id) & FL_ONGROUND))
	{
		g_iPlayersJumps[id] = 0

		return PLUGIN_CONTINUE
	}

	return PLUGIN_CONTINUE
}

public client_PostThink(id)
{
	if(!is_user_alive(id) || get_user_team(id) == 1) 
		return PLUGIN_CONTINUE


	if(g_iDoJump[id] == true)
	{
		new Float:velocity[3]	
		entity_get_vector(id,EV_VEC_velocity,velocity)

		velocity[2] = 270.0

		entity_set_vector(id,EV_VEC_velocity,velocity)

		g_iDoJump[id] = false

		return PLUGIN_CONTINUE
	}

	return PLUGIN_CONTINUE
}	