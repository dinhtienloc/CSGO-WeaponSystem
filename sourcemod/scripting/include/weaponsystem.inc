/*
**
*/
#include <sourcemod>

#if defined _weaponsystem_included
 #endinput
#endif
#define _weaponsystem_included

#define MAX_WEAPON 46
#define MAX_EQUIP 15
#define MAX_TYPE 3
#define MAX_FORWARD 5

enum ForwardName {
	WPN_BOUGHT = 0,
	WPN_REMOVE,
	WPN_ADDAMMO,
	SPEC_BOUGHT,
	SPEC_REMOVE
}

enum WeaponType {
	WPN_PRIMARY = 0,
	WPN_SECONDARY,
	WPN_MELEE
}

enum SpecType {
	SPEC_T = 0,
	SPEC_CT
}

/**
 * Register a weapon to the weapon menu.
 * @param wpnName				The name of registed weapon.
 * @param requiredWpnName		The name of required weapon which need unlocking first in order to buy the 
 *								registed weapon.
 * @param type					Type of weapon.
 * @param baseOn				Id of the weapon that registed weapon based on.
 * @param cost					Weapon's cost.
 *
 * @return						Weapon id if or -1 if failure.
 */
native int WS_RegisterWeapon(char[] wpnName, char[] requiredWpnName, WeaponType type, int baseOn, int cost);


/**
 * Register a special item to the special menu.
 * @param specName				The name of special item.
 * @param requiredSpecName		The name of item which need unlocking first in order to buy this item.
 * @param type					Type of item.
 * @param cost					Item's cost.
 *
 * @return						Special item's id or -1 if failure.
 */
native int WS_RegisterSpecialItem(char[] specName, char[] requiredSpecName, SpecType type, int cost);

/**
 * Get based weapon of the registed weapon.  
 * @param id					Player's id.
 * @param itemId				The id of weapon want to get.
 *
 * @return						Based weapon name.
 */
native int WS_GetWeaponBasedOn(int id, int itemId);

/**
 * Called after player select weapon in the weapon menu.
 * @param id		The client's id.
 * @param itemId	The id of chosen weapon.
 *
 * @return			Plugin_Handled or Plugin_Stop to block buying. Or Plugin_Continue to continue.
 */
forward Action WS_OnWeaponBought(int id, int itemId);

/**
 * Called after player remove weapon in the weapon menu.
 * @param id		The client's id.
 * @param itemId	The id of removed weapon.
 *
 * @return			Plugin_Handled or Plugin_Stop to block removing. Or Plugin_Continue to continue.
 */
forward Action WS_OnWeaponRemove(int id, int itemId);

/**
 * Called after adding player weapon's ammo
 * @param id		The client's id.
 * @param itemId	The id of weapon.
 *
 * @return			Plugin_Handled or Plugin_Stop to block adding ammo. Or Plugin_Continue to continue.
 */
forward Action WS_OnWeaponAddAmmo(int id, int itemId);

/**
 * Called after player select special item in the special menu.
 * @param id		The client's id.
 * @param itemId	The id of chosen item.
 *
 * @return			Plugin_Handled or Plugin_Stop to block buying. Or Plugin_Continue to continue.
 */
forward Action WS_OnSpecBought(int id, int itemId);

/**
 * Called after player remove special item in the special menu.
 * @param id		The client's id.
 * @param itemId	The id of chosen item.
 *
 * @return			Plugin_Handled or Plugin_Stop to block removing. Or Plugin_Continue to continue.
 */
forward Action WS_OnSpecRemove(int id, int itemId);