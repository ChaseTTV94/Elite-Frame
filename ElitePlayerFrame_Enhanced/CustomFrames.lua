local addonName,addon = ...
local L = addon.LOCALISATION
local C = addon.CUSTOM_FRAMES
table.insert(C,function (addon)	-- Death Knight - Alliance	-- Function called with addon during initialisation
	return {	-- Custom frame object returned to addon for registration
		format(L["%s - %s"],tostring(addon.CLASSES["DEATHKNIGHT"] and addon.CLASSES["DEATHKNIGHT"].name[2] or L["Death Knight"]),tostring(FACTION_ALLIANCE)),	-- Name when displayed in text output
		"FF33FFFF",	-- Color when displayed in text output
		{
			"Interface\\AddOns\\ElitePlayerFrame_Enhanced\\Textures\\UI-PlayerFrame-Deathknight-Alliance.tga",	-- File for SetTexture()
			{0,1,0,1},	-- Coords for SetTexCoords()
			{addon.SetPointOffset(9,6),addon.SetPointOffset(33,-20)},	-- Texture x,y offsets for SetPoint(), per point (i.e. TOPLEFT, BOTTOMRIGHT))
			{(addon.BRANCH ~= WOW_PROJECT_MAINLINE) and addon.SetPointOffset(-22,6) or addon.SetPointOffset(-23.5,7.5)},	-- Level text x,y offsets for SetPoint()
			{(addon.BRANCH ~= WOW_PROJECT_MAINLINE) and addon.SetPointOffset(-1,0) or addon.SetPointOffset(-3,0)},	-- Rest icon x,y offsets for SetPoint()
			function (addon)	-- Function called to determine if this texture should be selected in Auto (1) mode (called in the order added)
				return addon.settings.classMode == 1 and addon.info.player.class == "DEATHKNIGHT" and ((addon.settings.factionMode == 0 and addon.info.player.faction == "Alliance") or addon.settings.factionMode == 1)
			end
		}
	}
end)
table.insert(C,function (addon)	-- Death Knight - Horde
	return {
		format(L["%s - %s"],tostring(addon.CLASSES["DEATHKNIGHT"] and addon.CLASSES["DEATHKNIGHT"].name[2] or L["Death Knight"]),tostring(FACTION_HORDE)),
		"FF33FFFF",
		{
			"Interface\\AddOns\\ElitePlayerFrame_Enhanced\\Textures\\UI-PlayerFrame-Deathknight-Horde.tga",
			{0,1,0,1},
			{addon.SetPointOffset(11,13),addon.SetPointOffset(35,-15)},
			{(addon.BRANCH ~= WOW_PROJECT_MAINLINE) and addon.SetPointOffset(-24,0) or addon.SetPointOffset(-26,1.5)},
			{(addon.BRANCH ~= WOW_PROJECT_MAINLINE) and addon.SetPointOffset(-1,0) or addon.SetPointOffset(-3,0)},
			function (addon)
				return addon.settings.classMode == 1 and addon.info.player.class == "DEATHKNIGHT" and ((addon.settings.factionMode == 0 and addon.info.player.faction == "Horde") or addon.settings.factionMode == 2)
			end
		}
	}
end)
table.insert(C,function (addon)	-- Demon Hunter
	return {
		addon.CLASSES["DEMONHUNTER"] and addon.CLASSES["DEMONHUNTER"].name[2] or L["Demon Hunter"],
		"FF99FF33",
		{
			"Interface\\AddOns\\ElitePlayerFrame_Enhanced\\Textures\\UI-TargetingFrame-DemonHunter.blp",
			{1,0,0,1},
			{addon.SetPointOffset(0,0),addon.SetPointOffset(24,-28)},
			{(addon.BRANCH ~= WOW_PROJECT_MAINLINE) and addon.SetPointOffset(-10,13.5) or addon.SetPointOffset(-12,14.5)},
			{(addon.BRANCH ~= WOW_PROJECT_MAINLINE) and addon.SetPointOffset(1.5,0)},
			function (addon)
				return addon.settings.classMode == 1 and addon.info.player.class == "DEMONHUNTER"
			end
		}
	}
end)