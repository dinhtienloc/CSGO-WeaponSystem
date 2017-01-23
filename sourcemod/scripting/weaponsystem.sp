#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <hiddenmode>
#include <weaponsystem>
#include <cstrike>

#pragma newdecls required

#define charsmax(%1) sizeof(%1)-1
#define TRANSLATION_FILE "weaponsystem.phrases"

#define CS_TEAM_T 2
#define CS_TEAM_CT 3

#define GET_WPN_MENU_INDEX "GET_WPN"

/*-------------------
 FORWARD HANDLES
-------------------*/
Handle fwdWeaponBought;
Handle fwdWeaponRemove;
Handle fwdWeaponAddAmmo;
Handle fwdSpecBought;
Handle fwdSpecRemove;

/*-------------------
 SYSTEM DATA ARRAYS
-------------------*/
// Weapon arrays
ArrayList ArrWeaponName;
ArrayList ArrReqWeaponName;
ArrayList ArrWeaponType;
ArrayList ArrWeaponCode;
ArrayList ArrWeaponCost;

// Special Items Arrays
ArrayList ArrSpecName;
ArrayList ArrReqSpecName;
ArrayList ArrSpecType;
ArrayList ArrSpecCost;

/*-------------------
 COUNTING VARIABLES
-------------------*/
// Total items count
int gTotalWeaponCount;
int gWeaponCount[view_as<int>(WeaponType)];

int gTotalSpecItemCount;
int gSpecCount[view_as<int>(SpecType)];


/*-------------------
 WEAPON'S INDEX ARRAYS
-------------------*/
ArrayList gPriArr;
ArrayList gSecArr;
ArrayList gMeleeArr;
ArrayList gSpecTArr;
ArrayList gSpecCTArr;

/*-------------------
 PLAYER VARIABLES
-------------------*/
int gBuyTimes[MAXPLAYERS+1];
int gFirstWeapon[MAXPLAYERS+1][view_as<int>(WeaponType)];
int gPreWeapon[MAXPLAYERS+1][view_as<int>(WeaponType)];

/*-------------------
 PCVAR VARIABLES
-------------------*/
Handle pCvarUnlockEnabled;
Handle pCvarSpecItemEnabled;
Handle pCvarBuyTimes;
Handle pCvarTeamDisabled;

public Plugin myinfo = 
{
	name = "[CSGO] Weapon System", 
	author = "locdt", 
	description = "Custom Weapon System for CSGO", 
	version = "1.0", 
	url = ""
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	CreateNative("WS_RegisterWeapon", Native_RegisterWeapon);
	CreateNative("WS_RegisterSpecialItem", Native_RegisterSpecialItem);
	CreateNative("WS_GetWeaponClassname", Native_GetWeaponClassname);
	CreateNative("WS_FindWeaponIdByCode", Native_FindWeaponIdByCode);
	
	// Register  library
	RegPluginLibrary("weaponsystem");
	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations(TRANSLATION_FILE);
	HookEvent("round_start", OnRoundStart);
	
	pCvarUnlockEnabled = CreateConVar("ws_unlock_enabled", "1");
	pCvarSpecItemEnabled = CreateConVar("ws_special_enabled", "1");
	pCvarBuyTimes = CreateConVar("ws_buy_times", "0", "Number of times player can buy. If set to 0, no times limit");
	pCvarTeamDisabled = CreateConVar("ws_team_disabled", "0", "Disable weapon menu for specific team: 0 (Default)-No team | 1-T | 2-CT | 3-All");
	
	// Just for testing
	RegConsoleCmd("ws_weapon_count", GetTotalWeaponCount);
	RegConsoleCmd("ws_weapon_menu", ShowWeaponMainMenu);
	
	fwdWeaponBought = CreateGlobalForward("WS_OnWeaponBought", ET_Hook, Param_Cell, Param_Cell, Param_String);
	fwdWeaponRemove = CreateGlobalForward("WS_OnWeaponRemove", ET_Hook, Param_Cell, Param_Cell);
	fwdWeaponAddAmmo = CreateGlobalForward("WS_OnWeaponAddAmmo", ET_Hook, Param_Cell, Param_Cell);
	fwdSpecBought = CreateGlobalForward("WS_OnSpecBought", ET_Hook, Param_Cell, Param_Cell);
	fwdSpecRemove = CreateGlobalForward("WS_OnSpecRemove", ET_Hook, Param_Cell, Param_Cell);
	
	InitVariables();
}

/*-------------------
 NATIVE FUNCTIONS
-------------------*/
public int Native_RegisterWeapon(Handle plugin, int numParams) {
	char wpnName[PLATFORM_MAX_PATH];
	char reqWpnName[PLATFORM_MAX_PATH];
	char wpnCode[PLATFORM_MAX_PATH];
	
	GetNativeString(1, wpnName, sizeof(wpnName));
	GetNativeString(2, reqWpnName, sizeof(reqWpnName));
	WeaponType type = GetNativeCell(3);
	GetNativeString(4, wpnCode, sizeof(wpnCode));
	int cost = GetNativeCell(5);
	
	ArrWeaponName.PushString(wpnName);
	ArrReqWeaponName.PushString(reqWpnName);
	ArrWeaponType.Push(type);
	ArrWeaponCode.PushString(wpnCode);
	ArrWeaponCost.Push(cost);
	
	gTotalWeaponCount++;
	gWeaponCount[type]++;
	
	PrintToServer("[WeaponSystem] Registry_Success: Weapon Number: %d | %s, %d", gTotalWeaponCount - 1, wpnName, cost);
	
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

public int Native_GetWeaponClassname(Handle plugin, int numParams) {
	int itemId = GetNativeCell(2);
	
	if (itemId >= gTotalWeaponCount) return 0;
	return ArrWeaponCode.Get(itemId);
}

/*-------------------
 ON-EVENT FUNCTIONS
-------------------*/
public void OnMapStart() {
	// Reset data
	ResetData();
	
	// Load weapon list
	static WeaponType wpnType;
	static SpecType specType;
	
	for (int i = 0; i < gTotalWeaponCount; i++) {
		wpnType = ArrWeaponType.Get(i);
		switch (wpnType) {
			case WPN_PRIMARY: gPriArr.Push(i);
			case WPN_SECONDARY: gSecArr.Push(i);
			case WPN_MELEE: gMeleeArr.Push(i);
		}
		gWeaponCount[wpnType]++;
	}
	
	for (int i = 0; i < gTotalSpecItemCount; i++) {
		specType = ArrSpecType.Get(i);
		switch (specType) {
			case SPEC_T: gSpecTArr.Push(i);
			case SPEC_CT: gSpecCTArr.Push(i);
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

public Action OnRoundStart(Handle event, const char[] name, bool dontBroadcast) {
	for (int i = 0; i < MaxClients; i++) {
		gBuyTimes[i] = 0;
	}
}

/*-------------------
 MENU FUNCTIONS
-------------------*/
public Action ShowWeaponMainMenu(int client, int args) {
	int disabledTeam = GetConVarInt(pCvarTeamDisabled);
	int times = GetConVarInt(pCvarBuyTimes);
	
	if (disabledTeam == 3) return Plugin_Handled;
	
	if (times > 0) {
		if (gBuyTimes[client] == times) {
			// TODO: Show error to player
			// Show for testing..
			PrintToChat(client, "Khong the mua sung duoc nua.");
			return Plugin_Handled;
		}
		else gBuyTimes[client]++;
	}
	
	char szBuffer[PLATFORM_MAX_PATH];
	Menu mainMenu = new Menu(WeaponMenuHandler);
	Format(szBuffer, sizeof(szBuffer), "%T", "WM_TITLE", LANG_SERVER);
	mainMenu.SetTitle(szBuffer);
	
	if (IsPlayerAlive(client)) {
		char szWpnType[PLATFORM_MAX_PATH];
		
		int clientTeam = GetClientTeam(client);
		if (clientTeam == CS_TEAM_CT && disabledTeam != 2) {
			char preWpnName[PLATFORM_MAX_PATH];
			
			if (gPreWeapon[client][WPN_PRIMARY] != -1)
				ArrWeaponName.GetString(gPreWeapon[client][WPN_PRIMARY], preWpnName, sizeof(preWpnName));
			else
				Format(preWpnName, sizeof(preWpnName), "");
				
			Format(szBuffer, sizeof(szBuffer), "%T [%s]", "WM_PRIMARY", LANG_SERVER, preWpnName);
			IntToString(view_as<int>(WPN_PRIMARY), szWpnType, sizeof(szWpnType));
			mainMenu.AddItem(szWpnType, szBuffer);
			
			if (gPreWeapon[client][WPN_SECONDARY] != -1)
				ArrWeaponName.GetString(gPreWeapon[client][WPN_SECONDARY], preWpnName, sizeof(preWpnName));
			else
				Format(preWpnName, sizeof(preWpnName), "");
			
			Format(szBuffer, sizeof(szBuffer), "%T [%s]", "WM_SECONDARY", LANG_SERVER, preWpnName);
			IntToString(view_as<int>(WPN_SECONDARY), szWpnType, sizeof(szWpnType));
			mainMenu.AddItem(szWpnType, szBuffer);
			
			Format(szBuffer, sizeof(szBuffer), "%T", "WM_TAKEWPN", LANG_SERVER);
			mainMenu.AddItem(GET_WPN_MENU_INDEX, szBuffer);
		}
		else if (clientTeam == CS_TEAM_T && disabledTeam != 3) {
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
	else if (action == MenuAction_Select) {
		if (!IsPlayerAlive(client)) {
			PrintToChat(client, "%t", "SHOP_DEAD_DISABLED");
			delete menu;
		}
		static char szBuffer[PLATFORM_MAX_PATH];
		static char wpnName[PLATFORM_MAX_PATH];
		static char wpnReqName[PLATFORM_MAX_PATH];
		static WeaponType chosenWpnType;
		static int wpnCost;
		static int playerMoney;
		
		char szInfo[PLATFORM_MAX_PATH];
		char szSubMenuTitle[PLATFORM_MAX_PATH];
		GetMenuItem(menu, item, szInfo, sizeof(szInfo));
		
		Menu subWeaponMenu = new Menu(WeaponSubMenuHandler);
		subWeaponMenu.SetTitle(szSubMenuTitle);
		
		if (StrEqual(szInfo, GET_WPN_MENU_INDEX)) {
			if (gPreWeapon[client][WPN_PRIMARY] == -1 || gPreWeapon[client][WPN_SECONDARY] == -1)
				// TODO: Show error to player
				// Show for testing..
				PrintToChat(client, "Chưa chọn súng");
			else
				EquipWeaponsToPlayer(client);
		}
		else {
			playerMoney	= GetEntProp(client, Prop_Send, "m_iAccount");
			chosenWpnType = view_as<WeaponType>(StringToInt(szInfo));
			
			if (chosenWpnType == WPN_PRIMARY)
				Format(szSubMenuTitle, sizeof(szSubMenuTitle), "%T", "WM_PRIMARY", LANG_SERVER);
			else if (chosenWpnType == WPN_SECONDARY)
				Format(szSubMenuTitle, sizeof(szSubMenuTitle), "%T", "WM_SECONDARY", LANG_SERVER);
			
			static WeaponType wpnType;
			static char	szWpnId[PLATFORM_MAX_PATH];
			
			for (int i = 0; i < gTotalWeaponCount; i++) {
				wpnType = ArrWeaponType.Get(i);
				if (wpnType != chosenWpnType) continue;
				
				ArrWeaponName.GetString(i, wpnName, sizeof(wpnName));
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
		
		char szInfo[PLATFORM_MAX_PATH];
		
		GetMenuItem(menu, item, szInfo, sizeof(szInfo));
		
		int wpnId = StringToInt(szInfo);
		int wpnType = ArrWeaponType.Get(wpnId);
		
		gPreWeapon[client][wpnType] = wpnId;
		ShowWeaponMainMenu(client, 0);
	}
}
/*-------------------
 PRIVATE FUNCTIONS
-------------------*/
 
/**
 * Initialize Weapon System's variables when plugin is started.
 *
 * @return					No return.
 **/
void InitVariables() {
	int stringSize = ByteCountToCells(PLATFORM_MAX_PATH);
	
	// Initialize Weapon Arrays
	ArrWeaponName = new ArrayList(stringSize);
	ArrReqWeaponName = new ArrayList(stringSize);
	ArrWeaponType = new ArrayList(1);
	ArrWeaponCode = new ArrayList(stringSize);
	ArrWeaponCost = new ArrayList(1);
	
	// Initialize Special Item Arrays
	ArrSpecName = new ArrayList(stringSize);
	ArrReqSpecName = new ArrayList(stringSize);
	ArrSpecType = new ArrayList(1);
	ArrSpecCost = new ArrayList(1);
	
	// Initialize Weapon's id Arrays
	gPriArr = new ArrayList(1);
	gSecArr = new ArrayList(1);
	gMeleeArr = new ArrayList(1);
	gSpecTArr = new ArrayList(1);
	gSpecCTArr = new ArrayList(1);
}

/**
 * Clear data of all Weapon System's variables.
 *
 * @return					No return.
 **/
void ResetData() {
	gWeaponCount[WPN_PRIMARY] = 0;
	gWeaponCount[WPN_SECONDARY] = 0;
	gWeaponCount[WPN_MELEE] = 0;
	
	gSpecCount[SPEC_T] = 0;
	gSpecCount[SPEC_CT] = 0;
	
	gPriArr.Clear();
	gSecArr.Clear();
	gMeleeArr.Clear();
	gSpecCTArr.Clear();
}

/**
 * Reset weapon's index value for chosen weapon array of player
 * @param client			The player's id.
 *
 * @return					No return.
 **/
void ResetPlayerWeapon(int client) {
	gBuyTimes[client] = 0;
	gPreWeapon[client][WPN_PRIMARY] = -1;
	gPreWeapon[client][WPN_SECONDARY] = -1;
	gPreWeapon[client][WPN_MELEE] = -1;
}

/**
 * Equip chosen weapon to player
 * @param client			The player's id.
 *
 * @return					No return.
 **/
void EquipWeaponsToPlayer(int client) {
	if (gPreWeapon[client][WPN_PRIMARY] == -1 && gPreWeapon[client][WPN_SECONDARY] == -1) {
		// TODO: Show error to player
		// Show for testing..
		PrintToChat(client, "Chua chon sung");
	}
	
	int priWeapon = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
	int secWeapon = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
	
	if (priWeapon == -1) {
		char szWpnCode[PLATFORM_MAX_PATH];
		ArrWeaponCode.GetString(gPreWeapon[client][WPN_PRIMARY], szWpnCode, sizeof(szWpnCode));
		CallEventWeaponBought(client, gPreWeapon[client][WPN_PRIMARY], szWpnCode);
	} else {
		StripAndEquipWeapon(client, priWeapon, gPreWeapon[client][WPN_PRIMARY]);
	}
	
	if (secWeapon == -1) {
		char szWpnCode[PLATFORM_MAX_PATH];
		ArrWeaponCode.GetString(gPreWeapon[client][WPN_SECONDARY], szWpnCode, sizeof(szWpnCode));
		CallEventWeaponBought(client, gPreWeapon[client][WPN_SECONDARY], szWpnCode);
	} else {
		StripAndEquipWeapon(client, secWeapon, gPreWeapon[client][WPN_SECONDARY]);
	}
}

/**
 * Strip player's weapon and equip the new weapon to player
 * @param client			The player's id.
 * @param weaponIndex		The entity's index of current player's weapon.
 * @param sysNewWpnIndex	The index of weapon in Weapon System.
 *
 * @return					No return.
 **/
void StripAndEquipWeapon(int client, int weaponIndex, int sysNewWpnIndex) {
	char wpnClassname[PLATFORM_MAX_PATH];
	GetEdictClassname(weaponIndex, wpnClassname, sizeof(wpnClassname));
	int sysOldWpnIndex = ArrWeaponCode.FindString(wpnClassname);

	if (sysNewWpnIndex != sysOldWpnIndex) {
		CS_DropWeapon(client, weaponIndex, true, false);
		//SDKHooks_DropWeapon(client, weaponIndex, NULL_VECTOR, NULL_VECTOR);
		ArrWeaponCode.GetString(sysNewWpnIndex, wpnClassname, sizeof(wpnClassname));
		CallEventWeaponBought(client, sysNewWpnIndex, wpnClassname);
	}
}

/**
 * Wrapped function to call WS_OnWeaponBought forward.
 * @param id				The client's id.
 * @param itemId			The id of chosen weapon.
 *
 * @return					Plugin_Handled or Plugin_Stop to block buying. Or Plugin_Continue to continue.
 **/
Action CallEventWeaponBought(int id, int itemId, char[] itemCode) {
	
	Action result;
	
	/* Start function call */
	Call_StartForward(fwdWeaponBought);
	
	/* Push parameters */
	Call_PushCell(id);
	Call_PushCell(itemId);
	Call_PushString(itemCode);
	
	/* Finish the call, get the result */
	Call_Finish(result);
	
	int playerMoney = GetEntProp(id, Prop_Send, "m_iAccount");
	int wpnCost = ArrWeaponCost.Get(itemId);
	SetEntProp(id, Prop_Send, "m_iAccount", playerMoney - wpnCost);
	
	return result;
}

/**
 * Wrapped function to call WS_OnWeaponRemove forward.
 * @param id				The client's id.
 * @param itemId			The id of removed weapon.
 *
 * @return					Plugin_Handled or Plugin_Stop to block removing. Or Plugin_Continue to continue.
 **/
Action CallEventWeaponRemove(int id, int itemId) {
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
 * @param id				The client's id.
 * @param itemId			The id of weapon.
 *
 * @return					Plugin_Handled or Plugin_Stop to block adding ammo. Or Plugin_Continue to continue.
 **/
Action CallEventWeaponAddAmmo(int id, int itemId) {
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
 * @param id				The client's id.
 * @param itemId			The id of chosen item.
 *
 * @return					Plugin_Handled or Plugin_Stop to block buying. Or Plugin_Continue to continue.
 **/
Action CallEventSpecialBought(int id, int itemId) {
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
 * @param id				The client's id.
 * @param itemId			The id of chosen item.
 *
 * @return					Plugin_Handled or Plugin_Stop to block removing. Or Plugin_Continue to continue.
 **/
Action CallEventSpecialRemove(int id, int itemId) {
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

/*-------------------
 TESTING FUNCTIONS
-------------------*/
public Action GetTotalWeaponCount(int client, int args) {
	PrintToConsole(client, "Total Weapon Count: %d", gTotalWeaponCount);
	char wpnName[PLATFORM_MAX_PATH];
	char wpnCode[PLATFORM_MAX_PATH];
	
	PrintToConsole(client, "Total Weapons: gTotalWeaponCount = %d", gTotalWeaponCount);
	
	PrintToConsole(client, "Primary Weapons: gWeaponCount[WPN_PRIMARY] = %d", gPriArr.Length);
	for (int i = 0; i < gPriArr.Length; i++) {
		int wpnId = gPriArr.Get(i);
		
		ArrWeaponName.GetString(wpnId, wpnName, sizeof(wpnName));
		ArrWeaponCode.GetString(wpnId, wpnCode, sizeof(wpnCode));
		PrintToConsole(client, "***************");
		PrintToConsole(client, "ID: %d", wpnId);
		PrintToConsole(client, "Name: %s", wpnName);
		PrintToConsole(client, "Type: %d", ArrWeaponType.Get(wpnId));
		PrintToConsole(client, "Code: %s", wpnCode);
		PrintToConsole(client, "Cost: %d", ArrWeaponCost.Get(wpnId));
	}
	
	PrintToConsole(client, "Secondary Weapons: gWeaponCount[WPN_SECONDARY] = %d", gWeaponCount[WPN_SECONDARY]);
	for (int i = 0; i < gSecArr.Length; i++) {
		int wpnId = gSecArr.Get(i);
		
		ArrWeaponName.GetString(wpnId, wpnName, sizeof(wpnName));
		ArrWeaponCode.GetString(wpnId, wpnCode, sizeof(wpnCode));
		PrintToConsole(client, "***************");
		PrintToConsole(client, "ID: %d", wpnId);
		PrintToConsole(client, "Name: %s", wpnName);
		PrintToConsole(client, "Type: %d", ArrWeaponType.Get(wpnId));
		PrintToConsole(client, "Code: %s", wpnCode);
		PrintToConsole(client, "Cost: %d", ArrWeaponCost.Get(wpnId));
	}
}