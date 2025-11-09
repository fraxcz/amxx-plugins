#include <amxmodx>
#include <amxmisc>
#include <json>
#include <fakemeta>
#include <fun>
#include <hamsandwich>

#define PLUGIN "weaponmenu enhanced"
#define VERSION "1.1"
#define AUTHOR "frax"

#define ARRAYLEN 35
 enum _:e_Weapons
 {
    WeaponName[ARRAYLEN],
    WeaponAmxxFile[ARRAYLEN],
    WeaponCallbackFunc[ARRAYLEN],
 }

 enum e_WeapSlots
 {
    Primary = 1,
    Secondary
 }

new Array:g_primaryWeapons
new Array:g_secondaryWeapons
new g_filepath[256]
new g_players[33]

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_clcmd("amx_show_loadout", "primaryMenu")
    register_concmd("amx_weaponmenu_reload", "readJSON", ADMIN_RCON)
    RegisterHam(Ham_Spawn, "player", "fw_playerSpawn", 1)
    register_forward(FM_ChangeLevel, "level_end", 1)

    //Creating a dummy for getting a sizeof
    new dummy[e_Weapons] 

    g_primaryWeapons = ArrayCreate(sizeof(dummy))
    g_secondaryWeapons = ArrayCreate(sizeof(dummy))

    //config path
    get_configsdir(g_filepath, charsmax(g_filepath))
    formatex(g_filepath, charsmax(g_filepath),"%s/weaponmenu.json", g_filepath)
    readJSON(0)

}

public fw_playerSpawn(id)
{
    g_players[id] = 0

    if(!is_user_alive(id))
        return PLUGIN_HANDLED

    strip_user_weapons(id) 
    give_item(id, "weapon_knife")
    if(get_user_team(id) == 1)
        return HAM_IGNORED

    g_players[id] = 1

    primaryMenu(id)
    
    return HAM_IGNORED
}

public readJSON(id)
{
    readConfig(Primary)
    readConfig(Secondary)

    if(id)
        console_print(id, "[%s] Reload complete. Check server console if some weapons didn't load", PLUGIN)
}

public readConfig(e_WeapSlots:slot)
{
    new JSON:json_handler = json_parse(g_filepath, true)

    if(json_handler == Invalid_JSON)
    {
        server_print("[%s] Failed to open %s. File not found or has invalid syntax.", PLUGIN, g_filepath)
        return 0
    }

    new JSON:slot_array_handler
    
    switch(slot)
    {
        case Primary:
        {
            slot_array_handler = json_object_get_value(json_handler, "primary")
        }
        case Secondary:
        {
            slot_array_handler = json_object_get_value(json_handler, "secondary")
        }
    }

    for(new i = 0; i < json_array_get_count(slot_array_handler); i++)
    {
        new JSON:slot_array_object_handler = json_array_get_value(slot_array_handler, i)

        new weaponName[ARRAYLEN], weaponAmxxFile[ARRAYLEN], weaponCallbackFunc[ARRAYLEN]

        json_object_get_string(slot_array_object_handler, "WeaponName", weaponName, charsmax(weaponName))
        json_object_get_string(slot_array_object_handler, "WeaponAmxxFile", weaponAmxxFile, charsmax(weaponAmxxFile))
        json_object_get_string(slot_array_object_handler, "WeaponCallbackFunc", weaponCallbackFunc, charsmax(weaponCallbackFunc))


        switch(check_weapon(weaponName, weaponAmxxFile, weaponCallbackFunc))
        {
            case -2:
            {
                server_print("[%s] Weapon '%s' (amxx file '%s') doesn't have a callback function named %s. This weapon will not show in the menu.", PLUGIN, weaponName, weaponAmxxFile, weaponCallbackFunc)
            }
            case -1:
            {
                server_print("[%s] Weapon '%s' doesn't have a plugin file named '%s'. This weapon will not show in the menu.", PLUGIN, weaponName, weaponAmxxFile)
            }
            case 0:
            {
                weaponCallbackFunc = ""
                add_weapon(weaponName, weaponAmxxFile, weaponCallbackFunc, slot)
            }
            case 1:
            {
                add_weapon(weaponName, weaponAmxxFile, weaponCallbackFunc, slot)
            }
        }
        json_free(slot_array_object_handler)

    }

    json_free(slot_array_handler)
    json_free(json_handler)

    return PLUGIN_HANDLED
}

public check_weapon(const weaponName[], const pluginName[], const functionName[])
{
    new weaponClassName[20]
    formatex(weaponClassName, charsmax(weaponClassName), "weapon_%s", weaponName)

    if(get_weaponid(weaponClassName) && equali(pluginName, "default", 7))
        return 0

    new pluginId = find_plugin_byfile(pluginName)

    if(find_plugin_byfile(pluginName) == -1)
        return -1
    
    if(get_func_id(functionName, pluginId) == -1)
        return -2 
    
    return 1
}

public add_weapon(weaponName[ARRAYLEN], pluginName[ARRAYLEN], functionName[ARRAYLEN], e_WeapSlots:slot)
{
    new weapon[e_Weapons]

    weapon[WeaponName] = weaponName
    weapon[WeaponAmxxFile] = pluginName
    weapon[WeaponCallbackFunc] = functionName

    switch(slot)
    {
        case Primary:
        {
            ArrayPushArray(g_primaryWeapons, weapon)
        }

        case Secondary:
        {
            ArrayPushArray(g_secondaryWeapons, weapon)
        }
    }

}

public primaryMenu(id)
{
    if(!is_user_alive(id) || !g_players[id])
        return PLUGIN_HANDLED

    new menu = menu_create("Primary weapon menu", "menu_handler")

    for(new i = 0; i < ArraySize(g_primaryWeapons); i++)
    {
        new weapon[e_Weapons]
        new menuItemStr[ARRAYLEN + 5]

        ArrayGetArray(g_primaryWeapons, i, weapon)

        formatex(menuItemStr, charsmax(menuItemStr), "\w %s", weapon[WeaponName])

        menu_additem(menu, menuItemStr, "P", 0)
    }
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL) //this is redundant, but we can actually set this to not be able to exit the menu
    menu_display(id, menu, 0)

    return PLUGIN_HANDLED
}

public secondaryMenu(id)
{
    new menu = menu_create("Secondary weapon menu", "menu_handler")

    for(new i = 0; i < ArraySize(g_secondaryWeapons); i++)
    {
        new weapon[e_Weapons]
        new menuItemStr[ARRAYLEN + 5]

        ArrayGetArray(g_secondaryWeapons, i, weapon)

        formatex(menuItemStr, charsmax(menuItemStr), "\w %s", weapon[WeaponName])

        menu_additem(menu, menuItemStr, "S", 0)
    }
    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL) //this is redundant, but we can actually set this to not be able to exit the menu
    menu_display(id, menu, 0)

    return PLUGIN_HANDLED
}

public menu_handler(id, menu, item)
{
    if (item == MENU_EXIT || !is_user_alive(id))
    {
        menu_destroy(menu)

        return PLUGIN_HANDLED
    }

    new data[6], name[64]
    new item_access, item_callback
    new weapon[e_Weapons]
    new weaponName[20]

    menu_item_getinfo(menu, item, item_access, data, charsmax(data), name, charsmax(name), item_callback)

    switch(data[0])
    {
        case 'P':
        {
            ArrayGetArray(g_primaryWeapons, item, weapon)
            if(equali(weapon[WeaponAmxxFile], "default", 7))
            {
                formatex(weaponName, charsmax(weaponName), "weapon_%s", weapon[WeaponName])
                give_item(id, weaponName)

            }
            g_players[id] = 0
            secondaryMenu(id)
        }

        case 'S':
        {
            ArrayGetArray(g_secondaryWeapons, item, weapon)
            if(equali(weapon[WeaponAmxxFile], "default", 7))
                {
                    formatex(weaponName, charsmax(weaponName), "weapon_%s", weapon[WeaponName])
                    give_item(id, weaponName)

                }
        }

    }

    if(callfunc_begin(weapon[WeaponCallbackFunc], weapon[WeaponAmxxFile]) > 0)
    {
        callfunc_push_int(id)
        callfunc_end()
    }

    menu_destroy(menu)
    return PLUGIN_HANDLED
}



public level_end()
{
    ArrayDestroy(g_primaryWeapons)
    ArrayDestroy(g_secondaryWeapons)
}