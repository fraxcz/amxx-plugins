/*	Copyright � 2009, ConnorMcLeod

	Pain Shock Free is free software;
	you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with Pain Shock Free; if not, write to the
	Free Software Foundation, Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.
*/

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "Pain Shock Free"
#define AUTHOR "ConnorMcLeod"
#define VERSION "0.0.1"

const m_flVelocityModifier = 108;

new g_pCvarPainShockFree;

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_pCvarPainShockFree = register_cvar("amx_painshockfree", "1", FCVAR_SERVER);

	RegisterHam(Ham_TakeDamage, "player", "OnCBasePlayer_TakeDamage_P", true);
}

public OnCBasePlayer_TakeDamage_P(id)
{
	if( get_pcvar_num(g_pCvarPainShockFree) )
	{
		set_pdata_float(id, m_flVelocityModifier, 1.0);
	}
}