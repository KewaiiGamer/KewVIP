/* Copyright © Miguel Viegas - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */
 
#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <sdkhooks>
#include <csgocolors>

#define DMG_FALL   (1 << 5)

ConVar g_Cvar_NoFallDamageEnabled;
ConVar g_Cvar_NoFallSoundEnabled;

public Action SoundHook(clients[64], &numClients, String:sound[PLATFORM_MAX_PATH], &Ent, &channel, &Float:volume, &level, &pitch, &flags)
{
	if (GetConVarBool(g_Cvar_NoFallSoundEnabled))
	{
	    if (StrEqual(sound, "player/damage1.wav", false)) return Plugin_Stop;
	    if (StrEqual(sound, "player/damage2.wav", false)) return Plugin_Stop;
	    if (StrEqual(sound, "player/damage3.wav", false)) return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action OnTakeDamage(int client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if ((damagetype & DMG_FALL) && GetConVarBool(g_Cvar_NoFallDamageEnabled))
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_NAME 			"VipMenu"
#define PLUGIN_AUTHOR 			"Kewaii"
#define PLUGIN_DESCRIPTION		"General VipMenu"
#define PLUGIN_VERSION 			"1.7.7"
#define PLUGIN_TAG 				"{pink}[VipMenu by Kewaii]{green}"

public Plugin myinfo =
{
    name				=    PLUGIN_NAME,
    author				=    PLUGIN_AUTHOR,
    description			=    PLUGIN_DESCRIPTION,
    version				=    PLUGIN_VERSION,
    url					= 	   "http://steamcommunity.com/id/KewaiiGamer/"
};

int revived[MAXPLAYERS+1] = 0;
bool isUsingUnlimitedAmmo[MAXPLAYERS + 1] = false;

int BenefitsChosen[MAXPLAYERS + 1] = 0;
int extrasChosen[MAXPLAYERS + 1] = 0;
int weaponsChosen[MAXPLAYERS + 1] = 0;

int MaxBenefits;
int MaxExtras;
int MaxWeapons;

ConVar g_Cvar_BenefitsMax;
ConVar g_Cvar_WeaponsEnabled;
ConVar g_Cvar_WeaponsMax;
ConVar g_Cvar_BuffsEnabled;
ConVar g_Cvar_BuffsMax;
ConVar g_Cvar_WeaponAWPEnabled;
ConVar g_Cvar_WeaponAK47Enabled;
ConVar g_Cvar_WeaponM4A1Enabled;
ConVar g_Cvar_WeaponM4A1_SilencerEnabled;
ConVar g_Cvar_BuffWHEnabled;
ConVar g_Cvar_BuffMedicKitEnabled;
ConVar g_Cvar_BuffUnlimitedAmmoEnabled;

ConVar g_Cvar_AutoHelmetEnabled;
ConVar g_Cvar_AutoArmorEnabled;
ConVar g_Cvar_AutoArmorQuantity;

ConVar g_Cvar_VIPSpawnEnabled;
ConVar g_Cvar_VIPSpawnQuantity;

ConVar g_Cvar_HealthRegenEnabled;
ConVar g_Cvar_MaxHealthQuantity;
ConVar g_Cvar_HealthRegenedQuantity;

bool g_bAutoHelmetEnabled, g_bAutoArmorEnabled, g_bBuffUnlimitedAmmoEnabled;
int g_iAutoArmorQuantity;
int g_iMaxHealth, g_iHealthRegenedQuantity;
int g_iVIPSpawnQuantity;
bool g_bWeaponsEnabled, g_bBuffsEnabled, g_bWeaponAWPEnabled, g_bWeaponAK47Enabled, g_bWeaponM4A1Enabled, g_bWeaponM4A1_SilencerEnabled, g_bBuffMedicKitEnabled, g_bBuffWHEnabled;

public void OnPluginStart()
{
	LoadTranslations("kewaii_vipmenu.phrases");
	g_Cvar_BenefitsMax = CreateConVar("kewaii_vipmenu_benefits_max", "3", "Maximum allowed amount of benefits per round");
	
	g_Cvar_WeaponsEnabled = CreateConVar("kewaii_vipmenu_weapons", "1", "Enables/Disables Weapons", _, true, 0.0, true, 1.0);
	g_Cvar_WeaponsMax = CreateConVar("kewaii_vipmenu_weapons_max", "2", "Maximum allowed amount of weapons per round");
	
	g_Cvar_BuffsEnabled = CreateConVar("kewaii_vipmenu_buffs", "1", "Enables/Disables Buffs", _, true, 0.0, true, 1.0);
	g_Cvar_BuffsMax = CreateConVar("kewaii_vipmenu_buffs_max", "2", "Maximum allowed amount of buffs per round");
	
	g_Cvar_WeaponAWPEnabled = CreateConVar("kewaii_vipmenu_weapon_awp", "1", "Enables/Disables AWP", _, true, 0.0, true, 1.0);
	g_Cvar_WeaponAK47Enabled = CreateConVar("kewaii_vipmenu_weapon_ak47", "1", "Enables/Disables AK47", _, true, 0.0, true, 1.0);
	g_Cvar_WeaponM4A1Enabled = CreateConVar("kewaii_vipmenu_weapon_m4a1", "1", "Enables/Disables M4A4", _, true, 0.0, true, 1.0);
	g_Cvar_WeaponM4A1_SilencerEnabled = CreateConVar("kewaii_vipmenu_weapon_m4a1_silencer", "1", "Enables/Disables M4A1-S", _, true, 0.0, true, 1.0);
	
	g_Cvar_BuffWHEnabled = CreateConVar("kewaii_vipmenu_buff_wh", "1", "Enables/Disables WH Grenade", _, true, 0.0, true, 1.0);
	g_Cvar_BuffMedicKitEnabled = CreateConVar("kewaii_vipmenu_buff_medickit", "1", "Enables/Disables Medic Kit", _, true, 0.0, true, 1.0);
	
	g_Cvar_BuffUnlimitedAmmoEnabled = CreateConVar("kewaii_vipmenu_buff_unlimitedammo", "1", "Enables/Disables Unlimited Ammo", _, true, 0.0, true, 1.0);
	
	g_Cvar_AutoHelmetEnabled = CreateConVar("kewaii_vipmenu_auto_helmet", "1", "Enables/Disables Helmet on Spawn", _, true, 0.0, true, 1.0);
	g_Cvar_AutoArmorEnabled = CreateConVar("kewaii_vipmenu_auto_armor", "1", "Enables/Disables Armor on Spawn", _, true, 0.0, true, 1.0);
	g_Cvar_AutoArmorQuantity = CreateConVar("kewaii_vipmenu_auto_armorquantity", "100", "Defines Armor Quantity", _, true, 1.0, true, 500.0);
	
	g_Cvar_VIPSpawnEnabled = CreateConVar("kewaii_vipmenu_vipspawn", "1", "Enables/Disables VIPSpawn", _, true, 0.0, true, 1.0);
	g_Cvar_VIPSpawnQuantity = CreateConVar("kewaii_vipmenu_vipspawn_quantity", "1", "Maximum amount of vipspawns per round", _, true, 0.0);
	
	g_Cvar_HealthRegenEnabled = CreateConVar("kewaii_vipmenu_healthregen", "1", "Enables/Disables Health Regen", _, true, 0.0, true, 1.0);
	g_Cvar_HealthRegenedQuantity = CreateConVar("kewaii_vipmenu_healthregened", "10", "Defines Quantity of Health Regened per kill", _, true, 1.0, true, 50.0);
	g_Cvar_MaxHealthQuantity = CreateConVar("kewaii_vipmenu_maxhealth", "150", "Defines Max Health that a player can get", _, true, 101.0, true, 500.0);
	
	g_Cvar_NoFallSoundEnabled = CreateConVar("kewaii_nofallsound", "1", "Enables/Disables No Fall Sound, 1 = No Sound / 0 = Sound", _, true, 0.0, true, 1.0);
	g_Cvar_NoFallDamageEnabled = CreateConVar("kewaii_nofalldamage", "1", "Enables/Disables No Fall Damage, 1 = No Damage / 0 = Damage", _, true, 0.0, true, 1.0);
	
	HookEvent("round_start", Event_RoundStart);
	HookEvent("weapon_fire", ClientWeaponReload);
	HookEvent("player_death", OnPlayerDeath);
	RegConsoleCmd("sm_vipspawn", Command_VIPSpawn);
	RegConsoleCmd("sm_vipmenu", VipMenu, "Opens VIPMenu");
	
	AutoExecConfig(true, "kewaii_vipmenu");
	AddNormalSoundHook(SoundHook);
}

public Action OnPlayerDeath(Handle event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "attacker"));
	int dead = GetClientOfUserId(GetEventInt(event, "userid"));
	if (GetConVarBool(g_Cvar_HealthRegenEnabled))
	{
		if (HasClientFlag(client, ADMFLAG_RESERVATION))
		{
			int OldHealth = GetEntProp(client, Prop_Send, "m_iHealth", 4, 0);
			if (dead != client)
			{
				if (GetClientTeam(client) > 1)
				{				
					g_iHealthRegenedQuantity = GetConVarInt(g_Cvar_HealthRegenedQuantity);
					g_iMaxHealth = GetConVarInt(g_Cvar_MaxHealthQuantity);
					if (g_iHealthRegenedQuantity + OldHealth > g_iMaxHealth)
					{	
						SetEntProp(client, Prop_Send, "m_iHealth", g_iMaxHealth, 4, 0);
					}
					else
					{
						SetEntProp(client, Prop_Send, "m_iHealth", OldHealth + g_iHealthRegenedQuantity, 4, 0);
					}
				}
			}
		}
	}
}
public Action VipMenu(int client, int args)
{
	if (HasClientFlag(client, ADMFLAG_RESERVATION))
	{
		if (GetClientTeam(client) > 1)
		{
			if (weaponsChosen[client] < MaxWeapons || extrasChosen[client] < MaxExtras)
			{
				CreateMainMenu(client).Display(client, MENU_TIME_FOREVER);
			}
			else
			{
				CPrintToChat(client, "%s %t", PLUGIN_TAG, "All Benefits Chosen");
			}
		}
	}
	return Plugin_Handled;
}

public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	MaxBenefits = GetConVarInt(g_Cvar_BenefitsMax);
	MaxWeapons = GetConVarInt(g_Cvar_WeaponsMax);
	MaxExtras = GetConVarInt(g_Cvar_BuffsMax);
	g_iAutoArmorQuantity = GetConVarInt(g_Cvar_AutoArmorQuantity);
	g_bAutoArmorEnabled = GetConVarBool(g_Cvar_AutoArmorEnabled);
	g_bAutoHelmetEnabled = GetConVarBool(g_Cvar_AutoHelmetEnabled);
	g_iVIPSpawnQuantity = GetConVarInt(g_Cvar_VIPSpawnQuantity);
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i)) 
		{
			if (HasClientFlag(i, ADMFLAG_RESERVATION))
			{
				if (GetClientTeam(i) > 1)
				{
					CreateMainMenu(i).Display(i, MENU_TIME_FOREVER);		
					if (g_bAutoArmorEnabled)
					{
						SetEntProp(i, Prop_Send, "m_ArmorValue", g_iAutoArmorQuantity);
					}
					if (g_bAutoHelmetEnabled)
					{
						SetEntProp(i, Prop_Send, "m_bHasHelmet", 1);
					}		
				}			
				BenefitsChosen[i] = 0;
				extrasChosen[i] = 0;
				weaponsChosen[i] = 0;
				revived[i] = 0;
								
			}
			isUsingUnlimitedAmmo[i] = false;
        }
    }
 
}

Menu CreateBuffsMenu(int client)
{
	Menu menu = new Menu(BuffsMenuHandler);
	char title[64];
	Format(title, sizeof(title), "%T by Kewaii", "BuffsMenu Title", client);
	menu.SetTitle(title);	
	g_bBuffWHEnabled = GetConVarBool(g_Cvar_BuffWHEnabled);
	g_bBuffMedicKitEnabled = GetConVarBool(g_Cvar_BuffMedicKitEnabled);
	g_bBuffUnlimitedAmmoEnabled = GetConVarBool(g_Cvar_BuffUnlimitedAmmoEnabled);
	char menuItem[64];
	if (g_bBuffWHEnabled) { 
		Format(menuItem, sizeof(menuItem), "%T", "WallHack Grenade", client);
		menu.AddItem("WH", menuItem);
	}
	if (g_bBuffMedicKitEnabled) { 
		Format(menuItem, sizeof(menuItem), "%T", "Medic Kit", client);
		menu.AddItem("Medkit", menuItem);	
	}
	if (g_bBuffUnlimitedAmmoEnabled) { 
		Format(menuItem, sizeof(menuItem), "%T", "Unlimited Bullets", client);
		menu.AddItem("UnlimitedAmmo", menuItem);
	}
	char lastItem[32];
	Format(lastItem, sizeof(lastItem), "%T", "Menu Go Back", client);
	menu.AddItem("Back", lastItem);
	return menu;
}

Menu CreateWeaponsMenu(int client)
{
	Menu menu = new Menu(WeaponsMenuHandler);
	char title[64];
	Format(title, sizeof(title), "%T by Kewaii", "WeaponsMenu Title", client);
	menu.SetTitle(title);
	g_bWeaponAWPEnabled = GetConVarBool(g_Cvar_WeaponAWPEnabled);
	g_bWeaponAK47Enabled = GetConVarBool(g_Cvar_WeaponAK47Enabled);
	g_bWeaponM4A1Enabled = GetConVarBool(g_Cvar_WeaponM4A1Enabled);
	g_bWeaponM4A1_SilencerEnabled = GetConVarBool(g_Cvar_WeaponM4A1_SilencerEnabled);
	if (g_bWeaponAWPEnabled) {
		char menuItem[64];
		Format(menuItem, sizeof(menuItem), "%T", "AWP Deagle", client);
		menu.AddItem("AWP_Deagle", menuItem);
	}	
	if (g_bWeaponAK47Enabled) {
		char menuItem[64];
		Format(menuItem, sizeof(menuItem), "%T", "AK47 Deagle", client);
		menu.AddItem("AK47_Deagle", menuItem);
	}
	if (g_bWeaponM4A1Enabled) {
		char menuItem[64];
		Format(menuItem, sizeof(menuItem), "%T", "M4A4 Deagle", client);
		menu.AddItem("M4A4_Deagle", menuItem);
	}
	if (g_bWeaponM4A1_SilencerEnabled) {
		char menuItem[64];
		Format(menuItem, sizeof(menuItem), "%T", "M4A1-S Deagle", client);
		menu.AddItem("M4A1S_Deagle", menuItem);
	}
	char lastItem[32];
	Format(lastItem, sizeof(lastItem), "%T", "Menu Go Back", client);
	menu.AddItem("Back", lastItem);
	return menu;
}

Menu CreateMainMenu(int client)
{
	Menu menu;
	g_bWeaponsEnabled = GetConVarBool(g_Cvar_WeaponsEnabled);
	g_bWeaponAWPEnabled = GetConVarBool(g_Cvar_WeaponAWPEnabled);
	g_bWeaponAK47Enabled = GetConVarBool(g_Cvar_WeaponAK47Enabled);
	g_bWeaponM4A1Enabled = GetConVarBool(g_Cvar_WeaponM4A1Enabled);
	g_bWeaponM4A1_SilencerEnabled = GetConVarBool(g_Cvar_WeaponM4A1_SilencerEnabled);
	g_bWeaponsEnabled = GetConVarBool(g_Cvar_WeaponsEnabled);
	g_bBuffsEnabled = GetConVarBool(g_Cvar_BuffsEnabled);
	g_bBuffWHEnabled = GetConVarBool(g_Cvar_BuffWHEnabled);
	g_bBuffMedicKitEnabled = GetConVarBool(g_Cvar_BuffMedicKitEnabled);
	char title[64], menuItem[64];
	Format(title, sizeof(title), "%T by Kewaii", "VIPMenu Title", client);
	if (g_bWeaponsEnabled && g_bBuffsEnabled) {
		menu = new Menu(MainMenuHandler);
		menu.SetTitle(title);	
		char weaponsItem[32], buffsItem[32];
		Format(weaponsItem, sizeof(weaponsItem), "%T", "Weapons Item", client);
		Format(buffsItem, sizeof(buffsItem), "%T", "Buffs Item", client);
		menu.AddItem("Weapons", weaponsItem);
		menu.AddItem("Buffs", buffsItem);
	}
	else if (g_bWeaponsEnabled) {
		menu = new Menu(WeaponsMenuHandler);
		menu.SetTitle(title);
		if (g_bWeaponAWPEnabled) {
			Format(menuItem, sizeof(menuItem), "%T", "AWP Deagle", client);
			menu.AddItem("AWP_Deagle", menuItem);
		}	
		if (g_bWeaponAK47Enabled) {
			Format(menuItem, sizeof(menuItem), "%T", "AK47 Deagle", client);
			menu.AddItem("AK47_Deagle", menuItem);
		}
		if (g_bWeaponM4A1Enabled) {
			Format(menuItem, sizeof(menuItem), "%T", "M4A4 Deagle", client);
			menu.AddItem("M4A4_Deagle", menuItem);
		}
		if (g_bWeaponM4A1_SilencerEnabled) {
			Format(menuItem, sizeof(menuItem), "%T", "M4A1-S Deagle", client);
			menu.AddItem("M4A1S_Deagle", menuItem);
		}
	}
	else if (g_bBuffsEnabled) {
		menu = new Menu(BuffsMenuHandler);
		menu.SetTitle(title);
		if (g_bBuffWHEnabled) { 
			Format(menuItem, sizeof(menuItem), "%T", "WallHack Grenade", client);
			menu.AddItem("WH", menuItem);
		}
		if (g_bBuffMedicKitEnabled) { 
			Format(menuItem, sizeof(menuItem), "%T", "Medic Kit", client);
			menu.AddItem("Medkit", menuItem);	
		}
		if (g_bBuffUnlimitedAmmoEnabled) { 
			Format(menuItem, sizeof(menuItem), "%T", "Unlimited Bullets", client);
			menu.AddItem("UnlimitedAmmo", menuItem);
		}
	}
	char lastItem[32];
	Format(lastItem, sizeof(lastItem), "%T", "Menu Leave", client);
	menu.AddItem("Leave", lastItem);
	menu.ExitButton = false;
	return menu;
}

public int BuffsMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				bool hasSelectedBonus = false;
				char menuIdStr[32];
				menu.GetItem(selection, menuIdStr, sizeof(menuIdStr));
				char msg[128];
				Format(msg, sizeof(msg), "%s %T", PLUGIN_TAG, "Buff Selected", client);
				if (StrEqual(menuIdStr, "Back"))
				{
					CreateMainMenu(client).Display(client, 15);							
				}	
				else if (extrasChosen[client] < MaxExtras && BenefitsChosen[client] < MaxBenefits)
				{				
					if (StrEqual(menuIdStr, "Medkit"))
					{		
						Format(msg, sizeof(msg), "%s{red}%T", msg, "Medic Kit", client);
						GivePlayerItem(client, "weapon_healthshot");
						extrasChosen[client]++;
						BenefitsChosen[client]++;
						hasSelectedBonus = true;
					}
					else if (StrEqual(menuIdStr, "WH"))
					{	
						Format(msg, sizeof(msg), "%s{red}%T", msg, "WallHack Grenade", client);
						GivePlayerItem(client, "weapon_tagrenade");
						extrasChosen[client]++;
						BenefitsChosen[client]++;
						hasSelectedBonus = true;
					}
					else if (StrEqual(menuIdStr, "UnlimitedAmmo"))
					{	
						Format(msg, sizeof(msg), "%s{red}%T", msg, "Unlimited Bullets", client);
						isUsingUnlimitedAmmo[client] = true;
						extrasChosen[client]++;
						BenefitsChosen[client]++;
						hasSelectedBonus = true;					
					}			
					if (hasSelectedBonus)
					{						
						CPrintToChat(client, msg);
						hasSelectedBonus = false;	
					}
				}
				else
				{	
					Format(msg, sizeof(msg), "%s %T", PLUGIN_TAG, "Reached Buffs Limit", client);					
					CPrintToChat(client, msg);
				}	
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public int WeaponsMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				bool hasSelectedBonus = false;
				char menuIdStr[32];
				menu.GetItem(selection, menuIdStr, sizeof(menuIdStr));
				char msg[128];
				Format(msg, sizeof(msg), "%s %T", PLUGIN_TAG, "Weapon Selected", client);
				if (StrEqual(menuIdStr, "Back"))
				{
					CreateMainMenu(client).Display(client, 15);							
				}	
				else if (weaponsChosen[client] < MaxWeapons && BenefitsChosen[client] < MaxBenefits)
				{		
					if (StrEqual(menuIdStr, "AWP_Deagle"))
					{
						Format(msg, sizeof(msg), "%s{red}%T", msg, "AWP Deagle", client);
						int wep = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
						if(wep != -1) 
							AcceptEntityInput(wep, "Kill");
						int newWep = GivePlayerItem(client, "weapon_awp");
						SetEntPropEnt(newWep, Prop_Data, "m_hOwnerEntity", client);
						EquipPlayerWeapon(client, newWep);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", newWep);
						hasSelectedBonus = true;
					}
					else if (StrEqual(menuIdStr, "AK47_Deagle"))
					{
						Format(msg, sizeof(msg), "%s{red}%T", msg, "AK47 Deagle", client);
						int wep = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
						if(wep != -1) 
							AcceptEntityInput(wep, "Kill");
						int newWep = GivePlayerItem(client, "weapon_ak47");
						SetEntPropEnt(newWep, Prop_Data, "m_hOwnerEntity", client);
						EquipPlayerWeapon(client, newWep);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", newWep);
						hasSelectedBonus = true;
					}
					else if (StrEqual(menuIdStr, "M4A4_Deagle"))
					{
						Format(msg, sizeof(msg), "%s{red}%T", msg, "M4A4 Deagle", client);
						int wep = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
						if(wep != -1) 
							AcceptEntityInput(wep, "Kill");
						int newWep = GivePlayerItem(client, "weapon_m4a1");
						SetEntPropEnt(newWep, Prop_Data, "m_hOwnerEntity", client);
						EquipPlayerWeapon(client, newWep);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", newWep);
						hasSelectedBonus = true;
					}
					else if (StrEqual(menuIdStr, "M4A1S_Deagle"))
					{
						Format(msg, sizeof(msg), "%s{red}%T", msg, "M4A1-S Deagle", client);
						int wep = GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY);
						if(wep != -1) 
							AcceptEntityInput(wep, "Kill");
						int newWep = GivePlayerItem(client, "weapon_m4a1_silencer");
						SetEntPropEnt(newWep, Prop_Data, "m_hOwnerEntity", client);
						EquipPlayerWeapon(client, newWep);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", newWep);
						hasSelectedBonus = true;
					}
					if(hasSelectedBonus)
					{
						CPrintToChat(client, msg);
						weaponsChosen[client]++;
						BenefitsChosen[client]++;
						int wep = GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY);
						if(wep != -1)
							AcceptEntityInput(wep, "Kill");
						int newWep = GivePlayerItem(client, "weapon_deagle");
						SetEntPropEnt(newWep, Prop_Data, "m_hOwnerEntity", client);
						EquipPlayerWeapon(client, newWep);
						SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", newWep);
						hasSelectedBonus = false;
					}
				}
				else
				{	
					Format(msg, sizeof(msg), "%s %T", PLUGIN_TAG, "Reached Weapons Limit", client);					
					CPrintToChat(client, msg);
				}	
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public int MainMenuHandler(Menu menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			if(IsClientInGame(client))
			{
				char menuIdStr[32];
				menu.GetItem(selection, menuIdStr, sizeof(menuIdStr));
				if (StrEqual(menuIdStr, "Weapons"))
				{
					CreateWeaponsMenu(client).Display(client, MENU_TIME_FOREVER);
				}
				else if (StrEqual(menuIdStr, "Buffs"))
				{
					CreateBuffsMenu(client).Display(client, MENU_TIME_FOREVER);
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public Action Command_VIPSpawn(int client, int args)
{
	if(client == 0)
	{
		PrintToServer("%t","Command is in-game only");
		return Plugin_Handled;
	}
	char msg[128];
	if (GetConVarBool(g_Cvar_VIPSpawnEnabled))
	{
		if (!IsPlayerAlive(client))
		{
			if (HasClientFlag(client, ADMFLAG_RESERVATION))
			{
				if (revived[client] < g_iVIPSpawnQuantity) 
				{	
					CS_RespawnPlayer(client);
					CPrintToChatAll("%s %t", PLUGIN_TAG, "Player Revived", client);
					revived[client]++;
				}
				else
				{
					Format(msg, sizeof(msg), "%s %T", PLUGIN_TAG, "Player Used Max VIPSpawns", client);
					CPrintToChat(client, msg);					
				}
			}
			else
			{
				Format(msg, sizeof(msg), "%s %T", PLUGIN_TAG, "VIPSpawn Not Allowed", client);
				CPrintToChat(client, msg);
			}
		}
		else
		{
			Format(msg, sizeof(msg), "%s %T", PLUGIN_TAG, "Player Not Dead", client);
			CPrintToChat(client, msg);
		}
	}
	return Plugin_Handled;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_WeaponEquipPost, EventItemPickup2);
}

public void ClientWeaponReload(Handle event, const char [] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event,  "userid"));
    SetUnlimitedAmmo(client);
}

void SetUnlimitedAmmo(int client)
{
	if (GetConVarBool(g_Cvar_BuffUnlimitedAmmoEnabled))
	{
		if(IsPlayerAlive(client))
		{
			if (HasClientFlag(client, ADMFLAG_RESERVATION))
			{
				if (isUsingUnlimitedAmmo[client])
				{
					SetPrimaryAmmo(client, 201);
				}
			}
		}
	}
}

int SetPrimaryAmmo(int client, int ammo)
{
	int iWeapon = GetEntDataEnt2(client, FindSendPropInfo("CCSPlayer", "m_hActiveWeapon"));
	return SetEntData(iWeapon, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), ammo);
}

public Action EventItemPickup2(int client, int weapon)
{
	if (GetConVarBool(g_Cvar_BuffUnlimitedAmmoEnabled))
	{
		if (HasClientFlag(client, ADMFLAG_RESERVATION)) 
		{
			if (isUsingUnlimitedAmmo[client])
			{
				SetPrimaryAmmo(client, 201);
			}
		}
	}
}

public bool HasClientFlag(int client, int flag)
{
	return CheckCommandAccess(client, "", flag, true);
}
