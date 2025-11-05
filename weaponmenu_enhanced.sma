#include <amxmodx>
#include <amxmisc>
#include <json>
#include <fakemeta>

#define PLUGIN "weaponmenu enhanced"
#define VERSION "1.0"
#define AUTHOR "frax"

#define ARRAYLEN 35
 enum _:e_Weapons
 {
    WeaponName[ARRAYLEN],
    WeaponAmxxFile[ARRAYLEN],
    WeaponCallbackFunction[ARRAYLEN],
 }

 enum _:e_WeapSlots
 {
    Primary = 1,
    Secondary
 }

new Array:g_primaryWeapons
new Array:g_secondaryWeapons
new g_filepath[256]

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_concmd("amx_show_weapons", "print_array")
    register_concmd("amx_fileread", "fileread")
    register_forward(FM_ChangeLevel, "level_end", 1)

    //Dynamic array init
    new dummy[e_Weapons]

    g_primaryWeapons = ArrayCreate(sizeof(dummy))
    g_secondaryWeapons = ArrayCreate(sizeof(dummy))

    //config path
    get_configsdir(g_filepath, charsmax(g_filepath))
    formatex(g_filepath, charsmax(g_filepath),"%s/weaponmenu.json", g_filepath)
}

public print_array(id)
{
    new weapon[e_Weapons]

    console_print(id, "-----------------------------")
    console_print(id, "")
    console_print(id, "Number of weapons: %d", ArraySize(g_primaryWeapons))

    for(new i = 0; i < ArraySize(g_primaryWeapons); i++)
    {
        ArrayGetArray(g_primaryWeapons, i, weapon)

        console_print(id, "Weapon Classname: %s, weapon amxx file: %s, weapon's give function: %s.", weapon[WeaponName], weapon[WeaponAmxxFile], weapon[WeaponCallbackFunction])
    }
    console_print(id, "")
    console_print(id, "-----------------------------")
    return PLUGIN_HANDLED
}


public fileread(id, e_Weapons:slot)
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

    server_print("%d", slot_array_handler)

    for(new i = 0; i < json_array_get_count(slot_array_handler); i++)
    {
        new JSON:slot_array_object_handler = json_array_get_value(slot_array_handler, i)

        new weaponName[ARRAYLEN], weaponAmxxFile[ARRAYLEN], weaponCallbackFunction[ARRAYLEN]

        json_object_get_string(slot_array_object_handler, "WeaponName", weaponName, ARRAYLEN - 1)
        json_object_get_string(slot_array_object_handler, "WeaponAmxxFile", weaponAmxxFile, ARRAYLEN - 1)
        json_object_get_string(slot_array_object_handler, "WeaponCallbackFunction", weaponCallbackFunction, ARRAYLEN - 1)

        switch(check_weapon(weaponName, weaponAmxxFile, weaponCallbackFunction))
        {
            case -2:
            {
                server_print("[%s] Primary weapon %s, amxx file %s, doesn't have a callback function named %s. This weapon will not show in the menu.", PLUGIN, weaponName, weaponAmxxFile, weaponCallbackFunction)
            }
            case -1:
            {
                server_print("[%s] Primary weapon %s, doesn't have a plugin file named %s. This weapon will not show in the menu.", PLUGIN, weaponName, weaponAmxxFile)
            }
            case 0:
            {
                add_weapon(weaponName, "default", "", slot)
            }
            case 1:
            {
                add_weapon(weaponName, weaponAmxxFile, weaponCallbackFunction, slot)
            }
        }
        json_free(slot_array_object_handler)
    
        console_print(id, "weapon classname: %s", weaponName)
        console_print(id, "weapon amxx file: %s", weaponAmxxFile)
        console_print(id, "weapon callback function: %s", weaponCallbackFunction)
    }
    json_free(slot_array_handler)
    json_free(json_handler)
    return PLUGIN_HANDLED
}

public check_weapon(const weaponName[], const pluginName[], const functionName[])
{
    if(get_weaponid(weaponName))
        return 0

    new pluginId = find_plugin_byfile(pluginName)

    if(find_plugin_byfile(pluginName) == -1)
        return -1
    
    if(get_func_id(functionName, pluginId) == -1)
        return -2 
    
    return 1
}

add_weapon(const weaponName[ARRAYLEN], const pluginName[ARRAYLEN], const functionName[ARRAYLEN], e_Weapons:slot)
{
    new weapon[e_Weapons]

    weapon[WeaponName] = weaponName
    weapon[WeaponAmxxFile] = pluginName
    weapon[WeaponCallbackFunction] = functionName

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

public level_end()
{
    ArrayDestroy(g_primaryWeapons)
    ArrayDestroy(g_secondaryWeapons)
}