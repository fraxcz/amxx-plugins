#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>

#define PLUGIN "t knife dmg"
#define VERSION "1.0"
#define AUTHOR "frax"

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    RegisterHam(Ham_TraceAttack, "player", "fw_TraceAttack")
}

public fw_TraceAttack(victim, attacker, Float:damage)
{
    if(get_user_team(attacker) == 2)
        return HAM_IGNORED

    new weaponid = get_user_weapon(attacker)
    new weaponName[13]
    get_weaponname(weaponid, weaponName, 13)

    if(!equali("weapon_knife", weaponName, 12))
        return HAM_IGNORED
    
    SetHamParamFloat(3, damage * 4.5)

    return HAM_HANDLED
}