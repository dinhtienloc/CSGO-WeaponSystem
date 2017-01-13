#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "locdt"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>
#include <hiddenmode>
#include <weaponsystem>

#pragma newdecls required


Handle gForwards[MAX_FORWARD];

// Weapon Arrays
Handle ArrWeaponName;
Handle ArrReqWeaponName;
Handle ArrWeaponType;
Handle ArrWeaponBaseOn;
Handle ArrWeaponCost;

// Special Items Arrays
Handle ArrSpecName;
Handle ArrSpecType;
Handle ArrSpecCost;

// Initialize Variables
int gTotalWeaponCount;
int gTotalSpecialItemCount;

public Plugin myinfo = 
{
	name = "[CSGO] The Hidden: Weapon System",
	author = PLUGIN_AUTHOR,
	description = "Weapon system for the hidden mode of CSGO",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	gForwards[WPN_BOUGHT] = CreateGlobalForward("WS_OnWeaponBought", ET_Hook, Param_Cell, Param_Cell);
	gForwards[WPN_REMOVE] = CreateGlobalForward("WS_OnWeaponRemove", ET_Hook, Param_Cell, Param_Cell);
	gForwards[WPN_ADDAMMO] = CreateGlobalForward("WS_OnWeaponAddAmmo", ET_Hook, Param_Cell, Param_Cell);
	gForwards[SPEC_BOUGHT] = CreateGlobalForward("WS_OnSpecBought", ET_Hook, Param_Cell, Param_Cell);
	gForwards[WPN_ADDAMMO] = CreateGlobalForward("WS_OnSpecRemove", ET_Hook, Param_Cell, Param_Cell);
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	CreateNative("WS_RegisterWeapon", Native_RegisterWeapon);
	CreateNative("WS_RegisterSpecialItem", Native_RegisterSpecialItem);
	CreateNative("WS_GetWeaponBasedOn", Native_GetWeaponBasedOn);
	
	// Register  library
	RegPluginLibrary("weaponsystem");
	return APLRes_Success;
}

public int Native_RegisterWeapon(Handle plugin, int numParams) {
	char wpnName[] = GetNativeString(1);
	char reqWpnName[] = GetNativeString(2);
	WeaponType type = GetNativeCell(3);
	int basedOn = GetNativeCell(4);
	int cost = GetNativeCell(5);
	
	return -1;
}

public int Native_RegisterSpecialItem(Handle plugin, int numParams) {
	char specName[] = GetNativeString(1);
	char reqSpecName[] = GetNativeString(2);
	SpecType type = GetNativeCell(3);
	int cost = GetNativeCell(4);
	
	return -1;
}

public int Native_GetWeaponBasedOn(Handle plugin, int numParams) {
	int id = GetNativeCell(1);
	int itemId = GetNativeCell(2);
	
	return -1;
}

public OnMapStart() {
	
}

/**
 * Wrapped function to call WS_OnWeaponBought forward.
 * @param id		The client's id.
 * @param itemId	The id of chosen weapon.
 *
 * @return			Plugin_Handled or Plugin_Stop to block buying. Or Plugin_Continue to continue.
 */
void CallEventWeaponBought(int id, int itemId) {
	Action result;
	
	/* Start function call */
   	Call_StartForward(gForwards[WPN_BOUGHT]);
   	
   	/* Push parameters */
   	Call_PushCell(id);
	Call_PushCell(itemId);
	
	/* Finish the call, get the result */
   	Call_Finish(result);
   	
   	return result;
}

/**
 * Wrapped function to call WS_OnWeaponRemove forward.
 * @param id		The client's id.
 * @param itemId	The id of removed weapon.
 *
 * @return			Plugin_Handled or Plugin_Stop to block removing. Or Plugin_Continue to continue.
 */
void CallEventWeaponRemove(int id, int itemId) {
	Action result;
	
	/* Start function call */
   	Call_StartForward(gForwards[WPN_REMOVE]);
   	
   	/* Push parameters */
   	Call_PushCell(id);
	Call_PushCell(itemId);
	
	/* Finish the call, get the result */
   	Call_Finish(result);
   	
   	return result;
}

/**
 * Wrapped function to call WS_OnWeaponAddAmmo forward.
 * @param id		The client's id.
 * @param itemId	The id of weapon.
 *
 * @return			Plugin_Handled or Plugin_Stop to block adding ammo. Or Plugin_Continue to continue.
 */
void CallEventWeaponAddAmmo(int id, int itemId) {
	Action result;
	
	/* Start function call */
   	Call_StartForward(gForwards[WPN_ADDAMMO]);
   	
   	/* Push parameters */
   	Call_PushCell(id);
	Call_PushCell(itemId);
	
	/* Finish the call, get the result */
   	Call_Finish(result);
   	
   	return result;
}

/**
 * Wrapped function to call WS_OnSpecBought forward.
 * @param id		The client's id.
 * @param itemId	The id of chosen item.
 *
 * @return			Plugin_Handled or Plugin_Stop to block buying. Or Plugin_Continue to continue.
 */
void CallEventSpecialBought(int id, int itemId) {
	Action result;
	
	/* Start function call */
   	Call_StartForward(gForwards[SPEC_BOUGHT]);
   	
   	/* Push parameters */
   	Call_PushCell(id);
	Call_PushCell(itemId);
	
	/* Finish the call, get the result */
   	Call_Finish(result);
   	
   	return result;
}

/**
 * Wrapped function to call WS_OnSpecRemove forward.
 * @param id		The client's id.
 * @param itemId	The id of chosen item.
 *
 * @return			Plugin_Handled or Plugin_Stop to block removing. Or Plugin_Continue to continue.
 */
void CallEventSpecialRemove(int id, int itemId) {
	Action result;
	
	/* Start function call */
   	Call_StartForward(gForwards[SPEC_REMOVE]);
   	
   	/* Push parameters */
   	Call_PushCell(id);
	Call_PushCell(itemId);
	
	/* Finish the call, get the result */
   	Call_Finish(result);
   	
   	return result;
}