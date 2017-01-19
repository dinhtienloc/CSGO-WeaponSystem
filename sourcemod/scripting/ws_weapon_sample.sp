#pragma semicolon 1

#define PLUGIN_AUTHOR ""
#define PLUGIN_VERSION "0.00"

#include <sourcemod>
#include <sdktools>
#include <weaponsystem>
#include <cstrike>

#pragma newdecls required

int gWeaponSample;

public Plugin myinfo = 
{
	name = "",
	author = PLUGIN_AUTHOR,
	description = "",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	gWeaponSample = WS_RegisterWeapon("AK47", "", WPN_PRIMARY, CSW_AK47, 100);
}
