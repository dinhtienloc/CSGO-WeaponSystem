/*
**
*/
#include <sourcemod>

#if defined _weaponsystem_included
#endinput
#endif
#define _weaponsystem_included



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

#define CSWEAPON 34

#define CSW_NONE ""
#define CSW_GLOCK "weapon_glock" 
#define CSW_USP "weapon_usp_silencer" 
#define CSW_P250 "weapon_p250" 
#define CSW_FIVESEVEN "weapon_fiveseven" 
#define CSW_DEAGLE "weapon_deagle" 
#define CSW_ELITE "weapon_elite" 
#define CSW_P2000 "weapon_hkp2000" 
#define CSW_TEC9 "weapon_tec9" 
#define CSW_CZ75 "weapon_cz75a" 
#define CSW_REVOLVER "weapon_revolver" 
#define CSW_NOVA "weapon_nova" 
#define CSW_XM1014 "weapon_xm1014" 
#define CSW_MAG7 "weapon_mag7" 
#define CSW_SAWEDOFF "weapon_sawedoff" 
#define CSW_M249 "weapon_m249" 
#define CSW_NEGEV "weapon_negev" 
#define CSW_MP9 "weapon_mp9" 
#define CSW_MAC10 "weapon_mac10" 
#define CSW_MP7 "weapon_mp7" 
#define CSW_UMP45 "weapon_ump45" 
#define CSW_P90 "weapon_p90" 
#define CSW_BIZON "weapon_bizon" 
#define CSW_FAMAS "weapon_famas" 
#define CSW_M4A4 "weapon_m4a1" 
#define CSW_M4A1S "weapon_m4a1_silencer" 
#define CSW_GALIL "weapon_galilar" 
#define CSW_AK47 "weapon_ak47" 
#define CSW_SSG08 "weapon_ssg08" 
#define CSW_AUG "weapon_aug" 
#define CSW_SG556 "weapon_sg556" 
#define CSW_AWP "weapon_awp" 
#define CSW_SCAR20 "weapon_scar20" 
#define CSW_G3SG1 "weapon_g3sg1"

enum CSGrenadeId {
	CSW_HEGRENADE = 0,
	CSW_FLASHBANG,
	CSW_SMOKEGRENADE,
	CSW_MOLOTOV,
	CSW_INCENDIARY,
	CSW_DECOY
}

/**
 * Register a weapon to the weapon menu.
 * @param wpnName				The name of registed weapon.
 * @param requiredWpnName		The name of required weapon which need unlocking first in order to buy the 
 *								registed weapon.
 * @param type					Type of weapon.
 * @param baseOn				Id of the weapon that registed weapon based on.
 * @weaponCode					Code to get weapon ingame (weapon_...)
 * @param cost					Weapon's cost.
 *
 * @return						Weapon id if or -1 if failure.
 */
native int WS_RegisterWeapon(char[] wpnName, char[] requiredWpnName, WeaponType type, char[] baseOn, int cost);


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
native int WS_GetWeaponClassname(int id, int itemId);

/**
 * Called after player select weapon in the weapon menu.
 * @param id		The client's id.
 * @param itemId	The id of chosen weapon.
 *
 * @return			Plugin_Handled or Plugin_Stop to block buying. Or Plugin_Continue to continue.
 */
forward Action WS_OnWeaponBought(int id, int itemId, char[] itemCode);

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