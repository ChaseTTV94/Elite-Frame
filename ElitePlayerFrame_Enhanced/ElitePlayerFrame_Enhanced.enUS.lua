local addonName,addon = ...
local L = addon.LOCALISATION
if (addon.LOCALE == "enUS") then
	-- [ Loading/initialisation/resetting ]
	L["Initialised stage %s (%s/%s)."] = true	-- Formatted with stage name, number of initialised stages, and number of total stages
	L["Uninitialised stage %s (%s/%s)."] = true	-- Formatted with stage name, number of initialised stages, and number of total stages
	L["1 - Frame"] = true	-- Initialisation stage name
	L["2 - Addon"] = true	-- Initialisation stage name
	L["3 - Player"] = true	-- Initialisation stage name
	L["Initialised."] = true
	L["Uninitialised."] = true
	--- [ Settings ]
	L["Used default settings for new %s."] = true	-- Formatted with settings type
	L["Fixed %s settings."] = true	-- Formatted with number of settings fixed
	L["Updated settings for version %s.%s on branch %s."] = true	-- Formatted with version, revision, and branch numbers
	L["%s settings were reset."] = true	-- Formatted with settings type
	L["Setting %s set to default."] = true	-- Formatted with setting identifier
	L["Missing setting %s set to default."] = true	-- Formatted with setting identifier
	L["Unused setting %s removed."] = true	-- Formatted with setting identifier
	L["Invalid setting %s removed."] = true	-- Formatted with setting identifier
	L["Invalid setting %s set to default."] = true	-- Formatted with setting identifier
	---- [ Setting types ]
	L["character"] = true
	L["Character"] = true
	--- [ Branches ]
	L["Retail"] = true	-- Retail
	L["Classic"] = true	-- Classic
	L["Burning Crusade Classic"] = true	-- Burning Crusade Classic
	L["Wrath of the Lich King Classic"] = true	-- Wrath of the Lich King Classic
	-- [ Settings ]
	--- [ Debug levels ]
	L["Critical Errors"] = true	-- Debug level label
	L["Critical Error"] = true	-- Debug level prefix
	L["Errors"] = true	-- Debug level label
	L["Error"] = true	-- Debug level prefix
	L["Notices"] = true	-- Debug level label
	L["Notice"] = true	-- Debug level prefix
	L["Warnings"] = true	-- Debug level label
	L["Warning"] = true	-- Debug level prefix
	L["Debug messages"] = true	-- Debug level label
	L["Debug"] = true	-- Debug level prefix
	--- [ Modes ]
	L["Off"] = true
	L["On"] = true
	L["Auto"] = true
	L["Rare"] = true
	L["Rare-Elite"] = true
	L["Elite"] = true
	-- [ Textures ]
	L["Standard (Off)"] = true
	L["Standard"] = true
	-- [ Customisation ]
	L["%s - %s"] = true	-- Formatted with class name and faction name
	L["Death Knight"] = true
	L["Demon Hunter"] = true
	L["Added mode and texture for custom frame (%s: %s)"] = true	-- Formatted with custom frame name and ID
	-- [ Information ]
	L["Addon information updated."] = true
	L["Expansion levels:"] = true
	L["Player: %s"] = true	-- Formatted with player max level
	L["Account: %s (%s)"] = true	-- Formatted with account max level and account expansion level identifier
	L["Server: %s (%s)"] = true	-- Formatted with server max level and server expansion level identifier
	L["Client: %s-%s:%s ~%s (%s-%s:%s #%s)"] = true	-- Formatted with min max level, max max level, current max level, latest max level, min expansion level identifier, max expansion level identifier, current expansion level identifier, and number of expansion levels
	L["Calculated: %s-%s (%s)"] = true	-- Formatted with calculated min level, calculated max level, and calculated expansion identifier
	L["Expansion information updated."] = true
	L["Player information updated."] = true
	L["Unable to update player information; player not loaded yet."] = true
	-- [ GUI ]
	--- [ Frame levels ]
	L["%s frame level is %s."] = true	-- Formatted with frame name and frame level
	L["%s frame level was %s, now %s."] = true	-- Formatted with frame name, old frame level, and new frame level
	L["Unable to fix frame levels; player not loaded yet."] = true
	--- [ Frame points ]
	L["%s point %s/%s is %s,%s,%s,%s,%s."] = true	-- Formatted with frame name, point index, total points, anchor, relative frame name, relative anchor, x offset, and y offset
	L["Set default points for %s."] = true	-- Formatted with frame name
	L["Unable to set %s default points; frame does not exist yet."] = true	-- Formatted with frame name
	--- [ Display updates ]
	L["Player info has not changed since the last display update."] = true
	L["Expansion info has not changed since the last display update."] = true
	L["Forced display update."] = true
	--- [ Texture updates ]
	L["Updated to %s texture."] = true	-- Formatted with texture name
	L["Unable to update texture position; default points not set yet."] = true
	L["Unable to update texture position; frame not loaded yet."] = true
	--- [ Level text updates ]
	L["Updated level text position."] = true
	L["Unable to update level text position; default points not set yet."] = true
	L["Unable to update level text position; frame not loaded yet."] = true
	--- [ Rest icon updates ]
	L["Updated rest icon position."] = true
	L["Unable to update rest icon position; default points not set yet."] = true
	L["Unable to update rest icon position; frame not loaded yet."] = true
	-- [ Slash command handlers ]
	L["%s is an invalid command."] = true	-- Formatted with input command
	L["%s is an invalid argument for %s."] = true	-- Formatted with input argument and command
	--- [ Help ]
	L["help"] = true
	L["Help"] = true
	--- [ Information ]
	L["info"] = true
	L["Info"] = true
	L["%s [%s] - Reports information about the optional subject."] = true	-- Formatted with command and optional arguments
	---- [ Addon ]
	L["addon"] = true
	L["Addon"] = true
	L["%s v%s (%s), by %s."] = true	-- Formatted with addon title, version number, branch, and author
	---- [ Expansion ]
	L["expansion"] = true
	L["Expansion"] = true
	L["%s (#%s), a %s max level."] = true	-- Formatted with expansion name and expansion level identifier, and max level
	---- [ Player ]
	L["player"] = true
	L["Player"] = true
	L["%s, a level %s %s %s %s %s."] = true	-- Formatted with player name, level, faction name, gender name, race name, and class name
	--- [ Settings ]
	L["%s (%s)."] = true	-- Formatted with setting value and label
	L["%s = %s"] = true	-- Formatted with setting value and label
	---- [ Mode ]
	L["mode"] = true
	L["Mode"] = true
	L["%s [0-%s] - Reports or sets the display mode (%s)."] = true	-- Formatted with command, max mode value, and a delimited mode list
	---- [ Class mode ]
	L["class"] = true
	L["Class mode"] = true
	L["%s [0-%s] - Reports or sets the display mode for class frames in auto mode (%s)."] = true	-- Formatted with command, max class mode value, and a delimited class mode list
	---- [ Faction mode ]
	L["faction"] = true
	L["Faction mode"] = true
	L["%s [0-%s] - Reports or sets the faction modifier mode for class frames in auto mode (%s)."] = true	-- Formatted with command, max faction mode value, and a delimited faction mode list
	---- [ Debug level ] 
	L["debug"] = true
	L["%s [0-%s] - Reports or sets the debug output setting (%s)."] = true	-- Formatted with command, max debug level value, and a delimited debug level list
	--- [ Update ]
	L["update"] = true
	L["%s - Manually updates the display."] = true	-- Formatted with command
	--- [ Reset ]
	L["reset"] = true
	L["%s - Resets your settings to default."] = true	-- Formatted with command
	-- [ Miscellaneous ]
	L[":"] = true	-- Colon for message prefixes
	L[","] = true	-- Comma for list delimiter
end