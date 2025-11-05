#include <amxmodx>
#include <fun>
#include <amxmisc>
#include <hamsandwich>

#define PLUGIN "give weapons to bots"
#define VERSION "1.0"
#define AUTHOR "frax"

new g_pcGiveWeaponsToBots;
new g_weaponPrimaryClassnames[][] = {"ak47", "m4a1", "famas", "galil", "aug", "sg552", "m249", "awp", "scout", "g3sg1", "sg550", "xm1014", "m3", "mp5navy", "p90", "ump45", "tmp", "mac10"}

new g_weaponSecondaryClassnames[][] = {"glock18" ,"usp", "p228", "deagle", "fiveseven", "elite"}

new g_specialWeaponClassnames[][] = {"weapon_rapidak"}

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    g_pcGiveWeaponsToBots = create_cvar("amx_give_weapons_to_bots", "1.0", FCVAR_NONE, "Gives weapons to bots.", true, 0.0, true, 1.0)
    RegisterHamPlayer(Ham_Spawn, "give_weapon_to_bots", 1)
    register_concmd("amx_give_weapon_ct", "give_weapon_ct", ADMIN_SLAY, "gives weapon to all bots")
}

public give_weapon_ct(id, level, cid)
{
    if(!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
    
    new weapon_name[20];
    read_argv(1, weapon_name, 20)

    new players[32]
    new players_count;
    get_players(players, players_count, "ade", "CT")

    if(!get_weaponid(weapon_name))
    {
        for(new i = 0; i < 1 ; i++)
        {
            if(equali("weapon_rapidak", weapon_name, 20))
            {
                for(new i = 0; i < players_count; i++)
                {
                    strip_user_weapons(players[i])
                    give_item(players[i], "weapon_knife")
                    callfunc_begin("give_player_rapidak", "rapidak.amxx")
                    callfunc_push_int(players[i])
                    callfunc_end()
                }
            }
        }
        return PLUGIN_HANDLED
    }

    for(new i = 0; i < players_count; i++)
    {
        strip_user_weapons(players[i])
        give_item(players[i], "weapon_knife")
        give_item(players[i], weapon_name)
    }

    return PLUGIN_HANDLED
}

public give_specific_weapon_to_bots(id)
{
    
}

public give_weapon_to_bots(id)
{
    if(is_user_bot(id))
    {
        strip_user_weapons(id)
        give_item(id, "weapon_knife")
    }

    if(get_pcvar_num(g_pcGiveWeaponsToBots) == 0 || !is_user_bot(id) || get_user_team(id) == 1)
        return HAM_IGNORED

    strip_user_weapons(id)
    new primWeapon[20]
    new secWeapon[20]
    new primWeaponRandom = random_num(0, 20)
    if(primWeaponRandom <= 17)
    {
        formatex(primWeapon, 20, "weapon_%s", g_weaponPrimaryClassnames[primWeaponRandom])
        give_item(id, primWeapon)
    }

    else
    {
        callfunc_begin("give_player_rapidak", "rapidak.amxx")
        callfunc_push_int(id)
        callfunc_end()
    }

    formatex(secWeapon, 20, "weapon_%s", g_weaponSecondaryClassnames[random_num(0, 5)])
    give_item(id, secWeapon)

    return HAM_IGNORED
}