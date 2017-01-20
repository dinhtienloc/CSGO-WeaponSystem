#pragma semicolon 1

#define PLUGIN_AUTHOR "locdt"
#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>
#include <hiddenmode>
#include <weaponsystem>

#pragma newdecls required

#define charsmax(%1) sizeof(%1)-1
#define TRANSLATION_FILE "weaponsystem.phrases"

#define CS_TEAM_T 2
#define CS_TEAM_CT 3

/**
 * FORWARDS
 **/
Handle fwdWeaponBought;
Handle fwdWeaponRemove;
Handle fwdWeaponAddAmmo;
Handle fwdSpecBought;
Handle fwdSpecRemove;

/**
 * DATA ARRAYS
 **/

// Weapon arrays
ArrayList ArrWeaponName;
ArrayList ArrReqWeaponName;
ArrayList ArrWeaponType;
ArrayList ArrWeaponBaseOn;
ArrayList ArrWeaponCost;

// Special Items Arrays
ArrayList ArrSpecName;
ArrayList ArrReqSpecName;
ArrayList ArrSpecType;
ArrayList ArrSpecCost;

/**
 * COUNTING VARIABLES
 **/

// Total items count
int gTotalWeaponCount;
int gWeaponCount[view_as<int>(WeaponType)];

int gTotalSpecItemCount;
int gSpecCount[view_as<int>(SpecType)];


/**
 * WEAPON'S INDEX ARRAYS
 **/
ArrayList gWeaponArr;
ArrayList gSpecArr;

ArrayList gPriArr;
ArrayList gSecArr;
ArrayList gMeleeArr;
ArrayList gSpecTArr;
ArrayList gSpecCTArr;

/**
 * BOOLEAN VARIABLES
 **/
bool bHasWeapon[MAXPLAYERS+1];

/**
 * PLAYER VARIABLES
 **/
int gFirstWeapon[MAXPLAYERS+1][view_as<int>(WeaponType)];
int gPreWeapon[MAXPLAYERS+1][view_as<int>(WeaponType)];

/**
 * PCVAR VARIABLES
 **/
Handle pCvarUnlockEnabled;
Handle pCvarSpecItemEnabled;
 

public Plugin myinfo = 
{
	name = "[CSGO] The Hidden: Weapon System", 
	author = PLUGIN_AUTHOR, 
	description = "Weapon system for the hidden mode of CSGO", 
	version = PLUGIN_VERSION, 
	url = ""
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	CreateNative("WS_RegisterWeapon", Native_RegisterWeapon);
	CreateNative("WS_RegisterSpecialItem", Native_RegisterSpecialItem);
	CreateNative("WS_GetWeaponBasedOn", Native_GetWeaponBasedOn);
	
	// Register  library
	RegPluginLibrary("weaponsystem");
	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations(TRANSLATION_FILE);
	pCvarUnlockEnabled = CreateConVar("ws_unlock_enabled", "1");
	pCvarSpecItemEnabled = CreateConVar("ws_special_enabled", "1");
	
	// Just for testing
	RegConsoleCmd("ws_weapon_count", GetTotalWeaponCount);
	RegConsoleCmd("ws_weapon_menu", ShowWeaponMainMenu);
	
	fwdWeaponBought = CreateGlobalForward("WS_OnWeaponBought", ET_Hook, Param_Cell, Param_Cell);
	fwdWeaponRemove = CreateGlobalForward("WS_OnWeaponRemove", ET_Hook, Param_Cell, Param_Cell);
	fwdWeaponAddAmmo = CreateGlobalForward("WS_OnWeaponAddAmmo", ET_Hook, Param_Cell, Param_Cell);
	fwdSpecBought = CreateGlobalForward("WS_OnSpecBought", ET_Hook, Param_Cell, Param_Cell);
	fwdSpecRemove = CreateGlobalForward("WS_OnSpecRemove", ET_Hook, Param_Cell, Param_Cell);
	
	InitVariables();
}

public int Native_RegisterWeapon(Handle plugin, int numParams) {
	char wpnName[PLATFORM_MAX_PATH];
	char reqWpnName[PLATFORM_MAX_PATH];
	
	GetNativeString(1, wpnName, sizeof(wpnName));
	GetNativeString(2, reqWpnName, sizeof(reqWpnName));
	WeaponType type = GetNativeCell(3);
	CSWeaponId basedOn = GetNativeCell(4);
	int cost = GetNativeCell(5);
	
	
	ArrWeaponName.PushString(wpnName);
	ArrReqWeaponName.PushString(reqWpnName);
	ArrWeaponType.Push(type);
	ArrWeaponBaseOn.Push(basedOn);
	ArrWeaponCost.Push(cost);
	
	gTotalWeaponCount++;
	gWeaponCount[type]++;
	
	PrintToServer("[WeaponSystem] Registry_Success: Weapon %s", wpnName);
	
	return gTotalWeaponCount - 1;
}

public int Native_RegisterSpecialItem(Handle plugin, int numParams) {
	char specName[PLATFORM_MAX_PATH];
	char reqSpecName[PLATFORM_MAX_PATH];
	
	GetNativeString(1, specName, charsmax(specName));
	GetNativeString(2, reqSpecName, charsmax(reqSpecName));
	SpecType type = GetNativeCell(3);
	int cost = GetNativeCell(4);
	
	ArrSpecName.PushString(specName);
	ArrReqSpecName.PushString(reqSpecName);
	ArrSpecType.Push(type);
	ArrSpecCost.Push(cost);
	
	gTotalSpecItemCount++;
	gSpecCount[type]++;
	
	return gTotalSpecItemCount - 1;
}

public int Native_GetWeaponBasedOn(Handle plugin, int numParams) {
	int itemId = GetNativeCell(2);
	
	if (itemId >= gTotalWeaponCount) return 0;
	return ArrWeaponBaseOn.Get(itemId);
}

void InitVariables() {
	int stringSize = ByteCountToCells(PLATFORM_MAX_PATH);
	
	// Initialize Weapon Arrays
	ArrWeaponName = new ArrayList(stringSize);
	ArrReqWeaponName = new ArrayList(stringSize);
	ArrWeaponType = new ArrayList(1);
	ArrWeaponBaseOn = new ArrayList(1);
	ArrWeaponCost = new ArrayList(1);
	
	// Initialize Special Item Arrays
	ArrSpecName = new ArrayList(stringSize);
	ArrReqSpecName = new ArrayList(stringSize);
	ArrSpecType = new ArrayList(1);
	ArrSpecCost = new ArrayList(1);
	
	// Initialize Weapon's id Arrays
	gWeaponArr = new ArrayList(1);
	gSpecArr = new ArrayList(1);
	
	gPriArr = new ArrayList(1);
	gSecArr = new ArrayList(1);
	gMeleeArr = new ArrayList(1);
	gSpecTArr = new ArrayList(1);
	gSpecCTArr = new ArrayList(1);
}

void ResetData() {
	gWeaponCount[WPN_PRIMARY] = 0;
	gWeaponCount[WPN_SECONDARY] = 0;
	gWeaponCount[WPN_MELEE] = 0;
	
	gSpecCount[SPEC_T] = 0;
	gSpecCount[SPEC_CT] = 0;
	
	gSecArr.Clear();
	gPriArr.Clear();
	gSecArr.Clear();
	gMeleeArr.Clear();
	gSpecCTArr.Clear();
}

public void OnMapStart() {
	// Reset data
	ResetData();
	
	// Load weapon list
	static WeaponType wpnType;
	static SpecType specType;
	
	for (int i = 0; i < gTotalWeaponCount; i++) {
		wpnType = ArrWeaponType.Get(i);
		switch (wpnType) {
			case WPN_PRIMARY: {
				gPriArr.Push(i);
			}
			case WPN_SECONDARY: {
				gSecArr.Push(i);
			}
			case WPN_MELEE: {
				gMeleeArr.Push(i);
			}
		}
		gWeaponCount[wpnType]++;
	}
	
	for (int i = 0; i < gTotalSpecItemCount; i++) {
		specType = ArrSpecType.Get(i);
		switch (specType) {
			case SPEC_T: {
				gSpecTArr.Push(i);
				break;
			}
			case SPEC_CT: {
				gSpecCTArr.Push(i);
				break;
			}
		}
		gSpecCount[specType]++;
	}
}

public void OnClientPutInServer(int client) {
	ResetPlayerWeapon(client);
}

public void OnClientDisconnect(int client) {
	ResetPlayerWeapon(client);
}

void ResetPlayerWeapon(int client) {
	gPreWeapon[client][WPN_PRIMARY] = -1;
	gPreWeapon[client][WPN_SECONDARY] = -1;
	gPreWeapon[client][WPN_MELEE] = -1;
}
/**
 * MENU FUNCTIONS
 **/
public Action ShowWeaponMainMenu(int client, int args) {
	if (bHasWeapon[client]) return Plugin_Handled;
	
	char szBuffer[PLATFORM_MAX_PATH];
	Menu mainMenu = new Menu(WeaponMenuHandler);
	Format(szBuffer, sizeof(szBuffer), "%T", "WM_TITLE", LANG_SERVER);
	mainMenu.SetTitle(szBuffer);
	
	if (IsPlayerAlive(client)) {
		char szWpnType[PLATFORM_MAX_PATH];
		
		int clientTeam = GetClientTeam(client);
		if (clientTeam == CS_TEAM_CT) {
			IntToString(view_as<int>(WPN_PRIMARY), szWpnType, sizeof(szWpnType));
			Format(szBuffer, sizeof(szBuffer), "%T", "WM_PRIMARY", LANG_SERVER);
			mainMenu.AddItem(szWpnType, szBuffer);
			
			IntToString(view_as<int>(WPN_SECONDARY), szWpnType, sizeof(szWpnType));
			Format(szBuffer, sizeof(szBuffer), "%T", "WM_SECONDARY", LANG_SERVER);
			mainMenu.AddItem(szWpnType, szBuffer);
		}
		else if (clientTeam == CS_TEAM_T) {
			// TODO: Melee menu...
			PrintToChat(client, "%t", "SHOP_T_DISABLED");
			return Plugin_Handled;
		}
		
		mainMenu.ExitButton = true;
		mainMenu.Display(client, MENU_TIME_FOREVER);
	}
	else PrintToChat(client, "%t", "SHOP_DEAD_DISABLED");
	return Plugin_Handled;
}

public int WeaponMenuHandler(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_End) {
		if (menu != INVALID_HANDLE)
			delete menu;
	}
	
	if (action == MenuAction_Select) {
		if (!IsPlayerAlive(client)) {
			PrintToChat(client, "%t", "SHOP_DEAD_DISABLED");
			delete menu;
		}
		
		char szInfo[PLATFORM_MAX_PATH];
		char szSubMenuTitle[PLATFORM_MAX_PATH];
		GetMenuItem(menu, item, szInfo, sizeof(szInfo));
		
		static char szBuffer[PLATFORM_MAX_PATH];
		static char wpnName[PLATFORM_MAX_PATH];
		static char wpnReqName[PLATFORM_MAX_PATH];
		static WeaponType chosenWpnType;
		static int wpnBaseOn;
		static int wpnCost;
		static int playerMoney;
		
		playerMoney	= GetEntProp(client, Prop_Send, "m_iAccount");
		chosenWpnType = view_as<WeaponType>(StringToInt(szInfo));
		
		if (chosenWpnType == WPN_PRIMARY)
			Format(szSubMenuTitle, sizeof(szSubMenuTitle), "%T", "WM_PRIMARY", LANG_SERVER);
		else if (chosenWpnType == WPN_SECONDARY)
			Format(szSubMenuTitle, sizeof(szSubMenuTitle), "%T", "WM_SECONDARY", LANG_SERVER);
		
		Menu subWeaponMenu = new Menu(WeaponSubMenuHandler);
		subWeaponMenu.SetTitle(szSubMenuTitle);
		
		static WeaponType wpnType;
		static char	szWpnId[PLATFORM_MAX_PATH];
		
		for (int i = 0; i < gTotalWeaponCount; i++) {
			wpnType = ArrWeaponType.Get(i);
			if (wpnType != chosenWpnType) continue;
			
			ArrWeaponName.GetString(i, wpnName, sizeof(wpnName));
			wpnBaseOn = ArrWeaponBaseOn.Get(i);
			wpnCost = ArrWeaponCost.Get(i);
			
			Format(szBuffer, sizeof(szBuffer), "%s [$%d]", wpnName, wpnCost);
			IntToString(i, szWpnId, sizeof(szWpnId));
			
			if (playerMoney >= wpnCost || wpnCost <= 0)
				subWeaponMenu.AddItem(szWpnId, szBuffer, ITEMDRAW_DEFAULT);
			else
				subWeaponMenu.AddItem(szWpnId, szBuffer, ITEMDRAW_DISABLED);
		}
		
		subWeaponMenu.ExitButton = true;
		subWeaponMenu.Display(client, MENU_TIME_FOREVER);
	}
	
}

public int WeaponSubMenuHandler(Menu menu, MenuAction action, int client, int item) {
	if (action == MenuAction_End) {
		if (menu != INVALID_HANDLE)
			delete menu;
	}
	
	if (action == MenuAction_Select) {
		if (!IsPlayerAlive(client)) {
			PrintToChat(client, "%t", "SHOP_DEAD_DISABLED");
			delete menu;
		}
		PrintToChat(client, "Tadaa!!!");
	}
}

/**
 * Wrapped function to call WS_OnWeaponBought forward.
 * @param id		The client's id.
 * @param itemId	The id of chosen weapon.
 *
 * @return			Plugin_Handled or Plugin_Stop to block buying. Or Plugin_Continue to continue.
 **/
void CallEventWeaponBought(int id, int itemId) {
	Action result;
	
	/* Start function call */
	Call_StartForward(fwdWeaponBought);
	
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
 **/
void CallEventWeaponRemove(int id, int itemId) {
	Action result;
	
	/* Start function call */
	Call_StartForward(fwdWeaponRemove);
	
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
 **/
void CallEventWeaponAddAmmo(int id, int itemId) {
	Action result;
	
	/* Start function call */
	Call_StartForward(fwdWeaponAddAmmo);
	
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
 **/
void CallEventSpecialBought(int id, int itemId) {
	Action result;
	
	/* Start function call */
	Call_StartForward(fwdSpecBought);
	
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
 **/
void CallEventSpecialRemove(int id, int itemId) {
	Action result;
	
	/* Start function call */
	Call_StartForward(fwdSpecRemove);
	
	/* Push parameters */
	Call_PushCell(id);
	Call_PushCell(itemId);
	
	/* Finish the call, get the result */
	Call_Finish(result);
	
	return result;
}

/**
 * TEST FUNCTION
 **/
public Action GetTotalWeaponCount(int client, int args) {
	PrintToConsole(client, "Total Weapon Count: %d", gTotalWeaponCount);
	char wpnName[PLATFORM_MAX_PATH];
	
	PrintToConsole(client, "Total Weapons: gTotalWeaponCount = %d", gTotalWeaponCount);
	
	PrintToConsole(client, "Primary Weapons: gWeaponCount[WPN_PRIMARY] = %d", gPriArr.Length);
	for (int i = 0; i < gPriArr.Length; i++) {
		int wpnId = gPriArr.Get(i);
		
		ArrWeaponName.GetString(wpnId, wpnName, sizeof(wpnName));
		PrintToConsole(client, "***************");
		PrintToConsole(client, "ID: %d", wpnId);
		PrintToConsole(client, "Name: %s", wpnName);
		PrintToConsole(client, "Type: %d", ArrWeaponType.Get(wpnId));
		PrintToConsole(client, "Based: %d", ArrWeaponBaseOn.Get(wpnId));
		PrintToConsole(client, "Cost: %d", ArrWeaponCost.Get(wpnId));
	}
	
	PrintToConsole(client, "Secondary Weapons: gWeaponCount[WPN_SECONDARY] = %d", gWeaponCount[WPN_SECONDARY]);
	for (int i = 0; i < gSecArr.Length; i++) {
		int wpnId = gSecArr.Get(i);
		
		ArrWeaponName.GetString(wpnId, wpnName, sizeof(wpnName));
		PrintToConsole(client, "***************");
		PrintToConsole(client, "ID: %d", wpnId);
		PrintToConsole(client, "Name: %s", wpnName);
		PrintToConsole(client, "Type: %d", ArrWeaponType.Get(wpnId));
		PrintToConsole(client, "Based: %d", ArrWeaponBaseOn.Get(wpnId));
		PrintToConsole(client, "Cost: %d", ArrWeaponCost.Get(wpnId));
	}
}