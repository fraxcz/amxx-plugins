#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>

#define PLUGIN "no t pickup"
#define VERSION "1.0"
#define AUTHOR "fraX"


public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    RegisterHam(Ham_Touch, "weaponbox", "fw_weaponboxTouch")
}

public fw_weaponboxTouch(weapon, id)
{
    if(get_user_team(id) == 1)
        return HAM_SUPERCEDE

    return HAM_IGNORED
}