#pragma semicolon 1

#define PLUGIN_AUTHOR ""
#define PLUGIN_VERSION "0.00"

#include <sourcemod>
#include <sdktools>
#include <weaponsystem>

#pragma newdecls required

int gWeaponSample[CSWEAPON];

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
	gWeaponSample[0] = WS_RegisterWeapon("Glock-18", "", WPN_SECONDARY, CSW_GLOCK, 200);
	gWeaponSample[1] = WS_RegisterWeapon("P2000", "", WPN_SECONDARY, CSW_P2000, 200);
	gWeaponSample[2] = WS_RegisterWeapon("USP-S", "", WPN_SECONDARY, CSW_USP, 200);
	gWeaponSample[3] = WS_RegisterWeapon("P250", "", WPN_SECONDARY, CSW_P250, 300);
	gWeaponSample[4] = WS_RegisterWeapon("CZ75-Auto", "", WPN_SECONDARY, CSW_CZ75, 500);
	gWeaponSample[5] = WS_RegisterWeapon("Dual Berettas", "", WPN_SECONDARY, CSW_ELITE, 500);
	gWeaponSample[6] = WS_RegisterWeapon("Five-Seven", "", WPN_SECONDARY, CSW_FIVESEVEN, 500);
	gWeaponSample[7] = WS_RegisterWeapon("Tec-9", "", WPN_SECONDARY, CSW_TEC9, 500);
	gWeaponSample[8] = WS_RegisterWeapon("Desert Eagle", "", WPN_SECONDARY, CSW_DEAGLE, 700);
	gWeaponSample[9] = WS_RegisterWeapon("R8 Revolver", "", WPN_SECONDARY, CSW_REVOLVER, 850);
	gWeaponSample[10] = WS_RegisterWeapon("MAC-10", "", WPN_PRIMARY, CSW_MAC10, 1050);
	gWeaponSample[11] = WS_RegisterWeapon("Nova", "", WPN_PRIMARY, CSW_NOVA, 1200);
	gWeaponSample[12] = WS_RegisterWeapon("Sawed-Off", "", WPN_PRIMARY, CSW_SAWEDOFF, 1200);
	gWeaponSample[13] = WS_RegisterWeapon("UMP-45", "", WPN_PRIMARY, CSW_UMP45, 1200);
	gWeaponSample[14] = WS_RegisterWeapon("MP9", "", WPN_PRIMARY, CSW_MP9, 1250);
	gWeaponSample[15] = WS_RegisterWeapon("PP-Bizon", "", WPN_PRIMARY, CSW_BIZON, 1400);
	gWeaponSample[16] = WS_RegisterWeapon("MP7", "", WPN_PRIMARY, CSW_MP7, 1700);
	gWeaponSample[17] = WS_RegisterWeapon("SSG 08", "", WPN_PRIMARY, CSW_SSG08, 1700);
	gWeaponSample[18] = WS_RegisterWeapon("MAG-7", "", WPN_PRIMARY, CSW_MAG7, 1800);
	gWeaponSample[19] = WS_RegisterWeapon("Galil AR", "", WPN_PRIMARY, CSW_GALIL, 2000);
	gWeaponSample[20] = WS_RegisterWeapon("XM1014", "", WPN_PRIMARY, CSW_XM1014, 2000);
	gWeaponSample[21] = WS_RegisterWeapon("Famas", "", WPN_PRIMARY, CSW_FAMAS, 2250);
	gWeaponSample[22] = WS_RegisterWeapon("P90", "", WPN_PRIMARY, CSW_P90, 2350);
	gWeaponSample[23] = WS_RegisterWeapon("AK47", "", WPN_PRIMARY, CSW_AK47, 2700);
	gWeaponSample[24] = WS_RegisterWeapon("SG 556", "", WPN_PRIMARY, CSW_SG556, 3000);
	gWeaponSample[25] = WS_RegisterWeapon("M4A1-S", "", WPN_PRIMARY, CSW_M4A1S, 3100);
	gWeaponSample[26] = WS_RegisterWeapon("M4A4", "", WPN_PRIMARY, CSW_M4A4, 3100);
	gWeaponSample[27] = WS_RegisterWeapon("AUG", "", WPN_PRIMARY, CSW_AUG, 3300);
	gWeaponSample[28] = WS_RegisterWeapon("AWP", "", WPN_PRIMARY, CSW_AWP, 4750);
	gWeaponSample[29] = WS_RegisterWeapon("G3SG1", "", WPN_PRIMARY, CSW_G3SG1, 5000);
	gWeaponSample[30] = WS_RegisterWeapon("SCAR-20", "", WPN_PRIMARY, CSW_SCAR20, 5000);
	gWeaponSample[31] = WS_RegisterWeapon("M249", "", WPN_PRIMARY, CSW_M249, 5200);
	gWeaponSample[32] = WS_RegisterWeapon("Negev", "", WPN_PRIMARY, CSW_NEGEV, 5700);
}

public Action WS_OnWeaponBought(int client, int itemId, char[] itemCode) {	
	GivePlayerItem(client, itemCode);
	PrintToChat(client, "Gave player item %s with id %d", itemCode, itemId);
	return Plugin_Handled;
}
