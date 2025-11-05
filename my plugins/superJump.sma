#include <amxmodx>
#include <cstrike>
#include <engine>
#include <hamsandwich>
#include <fakemeta>

#define PLUGIN "super Jump"
#define VERSION "1.0"
#define AUTHOR "frax"

new g_pcForwardForce
new g_pcUpForce
new g_iCooldown
new Float:g_iPlayers[33];
new bool:g_bSoundEmitted[33]
new JUMP_SOUND[] = "thebestserver/superjump_charged.wav"

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    g_pcForwardForce = create_cvar("amx_superjump_forward_force", "500.0", FCVAR_NONE, "Sets forward force boost.", false, 0.0, false)
    g_pcUpForce = create_cvar("amx_superjump_up_force", "270.0", FCVAR_NONE, "Sets up force boost.", false, 0.0, false)
    g_iCooldown = create_cvar("amx_superjump_cooldown", "1.0", FCVAR_NONE, "A cooldown for superjump", true, 0.0, false)
    
    RegisterHam(Ham_Player_Jump, "player", "fw_PlayerJump", 1)
    RegisterHam(Ham_Player_PreThink, "player", "fw_PlayerPreThink")
}

public plugin_precache()
{
    precache_sound(JUMP_SOUND)
}

public client_disconnected(id)
{
    g_iPlayers[id] = 0.0
}

public client_putinserver(id)
{
    g_iPlayers[id] = get_gametime()

    g_bSoundEmitted[id] = true
}

public fw_PlayerJump(id)
{
    new player_flags = pev(id, pev_flags)

    if(g_iPlayers[id] > get_gametime() || cs_get_user_team(id) == CS_TEAM_CT || (player_flags & FL_ONGROUND) == 0 || (player_flags & FL_DUCKING) == 0)
    {
        return PLUGIN_CONTINUE
    }

    new Float:faUserAiming[3]

    new Float:fg_pcForwardForce = get_pcvar_float(g_pcForwardForce)

    velocity_by_aim(id, 1, faUserAiming)

    faUserAiming[0] *= fg_pcForwardForce
    faUserAiming[1] *= fg_pcForwardForce
    faUserAiming[2] = get_pcvar_float(g_pcUpForce)

    set_user_velocity(id, faUserAiming)

    g_iPlayers[id] = get_gametime() + get_pcvar_float(g_iCooldown)

    g_bSoundEmitted[id] = false

    return PLUGIN_HANDLED
}

public fw_PlayerPreThink(id)
{
    if(g_iPlayers[id] > get_gametime() || cs_get_user_team(id) == CS_TEAM_CT || g_bSoundEmitted[id])
        return PLUGIN_CONTINUE

    client_cmd(id, "spk sound/thebestserver/superjump_charged.wav")

    g_bSoundEmitted[id] = true

    return PLUGIN_CONTINUE
}