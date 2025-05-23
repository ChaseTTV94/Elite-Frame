-- [ Namespace and global setup ]
local addonName,addon = ...
addon.NAME = addonName
addon.SHORT_NAME = "EPF"
addon.VERSION = 1.6
addon.REVISION = 10
addon.BRANCH = WOW_PROJECT_ID
addon.CHILDREN = {}
addon.MIXINS = {}
addon.HOOKS = {}
-- [ Localisation ]
addon.LOCALE = GetLocale()
addon.LOCALISATION = setmetatable({},{
	__index = function (t,k)
		rawset(t,k,k)
		return k
	end,
	__newindex = function(t,k,v)
		if (v == true) then rawset(t,k,k) else rawset(t,k,v) end
	end
})
local L = addon.LOCALISATION
-- [ Customisation ]
addon.CUSTOM_FRAMES = {}
-- [ Constants ]
--- [ Debug levels ]
addon.CRITICAL_ERROR_LEVEL = 0
addon.ERROR_LEVEL = 1
addon.WARNING_LEVEL = 2
addon.NOTICE_LEVEL = 3
addon.DEBUG_LEVEL = 4
--- [ Observed frames ]
addon.PLAYER_FRAME = "PlayerFrame"
addon.PLAYER_TEXTURE_FRAME = addon.PLAYER_FRAME.."Texture"
addon.PLAYER_LEVEL_TEXT_FRAME = "PlayerLevelText"
addon.PLAYER_REST_ICON_FRAME = "PlayerRestIcon"
addon.PLAYER_PET_FRAME = "PetFrame"
addon.PLAYER_TOTEM_FRAME = "TotemFrame"
addon.PLAYER_GROUP_FRAME = "PlayerFrameGroupIndicator"
addon.PLAYER_RESOURCE_BAR_FRAMES = {
	"ComboPoint"..addon.PLAYER_FRAME,
	"MageArcaneChargesFrame",
	"InsanityBarFrame",
	"MonkHarmonyBarFrame",
	"MonkStaggerBar",
	"PaladinPowerBarFrame",
	addon.PLAYER_FRAME.."AlternateManaBar",
	"RuneFrame",
	"WarlockPowerFrame"
}
--- [ Expansions ]
addon.INTRO_MAX_LEVEL = 10	-- Hardcoded level cap for starting experience
--- [ Settings ]
addon.SETTINGS_NAME = addonName.."_Settings"
---- [ Characters ]
addon.CHAR_SETTINGS_STRUCTURE = {
	["version"] = "string",
	["debug"] = "number",
	["mode"] = "number",
	["classMode"] = "number",
	["factionMode"] = "number",
}
addon.CHAR_SETTINGS_DEFAULTS = {
	["version"] = addon.VERSION.."."..addon.REVISION.."-"..addon.BRANCH,
	["debug"] = addon.WARNING_LEVEL,
	["mode"] = 1,
	["classMode"] = 1,
	["factionMode"] = 0,
}
-- [ Addon initialisation ]
--- [ Initialisation stages ]
addon.isInitialised = false
addon.initialisationStages = {{["state"] = false},{["state"]  = false},{["state"]  = false}}
function addon:InitialiseStage(stage,value)
	if (not stage) then return end
	if (value == nil) then
		value = true
	end
	local tailcalls = {}
	if (value and not self.initialisationStages[stage].state) then	-- Initialising an uninitialised stage
		if (stage == 1) then
			-- [ Localisation ]
			self.RunOnce("InitialiseStage1Localisation",function ()
				--- [ Constants ]
				---- [ Debug levels ]
				self.DEBUG_LEVELS = {}
				self:AddDebugLevel(self.CRITICAL_ERROR_LEVEL,L["Critical Errors"],L["Critical Error"],"FFFF6666")
				self:AddDebugLevel(self.ERROR_LEVEL,L["Errors"],L["Error"],"FFFF6666")
				self:AddDebugLevel(self.WARNING_LEVEL,L["Warnings"],L["Warning"],"FFFFFF66")
				self:AddDebugLevel(self.NOTICE_LEVEL,L["Notices"],L["Notice"],"FF6666FF")
				self:AddDebugLevel(self.DEBUG_LEVEL,L["Debug messages"],L["Debug"],"FF999999")
				---- [ Branches ]
				self.BRANCHES = {}
				if WOW_PROJECT_MAINLINE then self:AddBranch(WOW_PROJECT_MAINLINE,L["Retail"]) end
				if WOW_PROJECT_CLASSIC then self:AddBranch(WOW_PROJECT_CLASSIC,L["Classic"]) end
				if WOW_PROJECT_BURNING_CRUSADE_CLASSIC then self:AddBranch(WOW_PROJECT_BURNING_CRUSADE_CLASSIC,L["Burning Crusade Classic"]) end
				if WOW_PROJECT_WRATH_CLASSIC then self:AddBranch(WOW_PROJECT_WRATH_CLASSIC,L["Wrath of the Lich King Classic"]) end
				---- [ Slash commands ]
				for i,v in ipairs(self.SLASHCMD_INDEX) do
					self.SLASHCMDS[L[v]] = {
						["id"] = i,
						["name"] = v,
						["localisedName"] = L[v],
						["handler"] = self.SLASHCMD_HANDLERS[v],
						["helpHandler"] = self.SLASHCMD_HELP_HANDLERS[v],
					}
					self.L_SLASHCMD_INDEX[i] = L[v]
					----- [ Arguments ]
					if (self.SLASHCMD_ARG_INDEX[v]) then
						self.SLASHCMDS[L[v]].arguments = {}
						self.L_SLASHCMD_ARG_INDEX[L[v]] = {}
						for ii,vv in ipairs(self.SLASHCMD_ARG_INDEX[v]) do
							self.SLASHCMDS[L[v]].arguments[L[vv]] = {
								["id"] = ii,
								["name"] = vv,
								["localisedName"] = L[vv],
							}
							self.L_SLASHCMD_ARG_INDEX[L[v]][ii] = L[vv]
						end
					end
				end
				---- [ Genders ]
				self.GENDERS = {}
				self:AddGender(UNKNOWN,"FF999999")
				self:AddGender(MALE,"FF6699FF")
				self:AddGender(FEMALE,"FFFF6699")
				---- [ Classes ]
				self.CLASSES = {}
				local maleClasses = {}
				FillLocalizedClassList(maleClasses,false)
				local femaleClasses = {}
				FillLocalizedClassList(femaleClasses,true)
				for k,v in pairs(maleClasses) do
					local c
					if C_ClassColor then
						-- #Bug: default class colour conversion for rgb to hex is missing rounding
						c = C_ClassColor.GetClassColor(k)
					else
						c = RAID_CLASS_COLORS[k]
					end
					self:AddClass(k,{k,maleClasses[k],femaleClasses[k]},self.GetHexColor(c))	-- #WorkAround: Convert rgb to hex with rounding ourselves
				end
				---- [ Expansions ]
				self.EXPANSIONS = {}
				if LE_EXPANSION_CLASSIC then self:AddExpansion(LE_EXPANSION_CLASSIC,"FFFFDD33") end
				if LE_EXPANSION_BURNING_CRUSADE then self:AddExpansion(LE_EXPANSION_BURNING_CRUSADE,"FF33FF33") end
				if LE_EXPANSION_WRATH_OF_THE_LICH_KING then self:AddExpansion(LE_EXPANSION_WRATH_OF_THE_LICH_KING,"FF3399FF") end
				if LE_EXPANSION_CATACLYSM then self:AddExpansion(LE_EXPANSION_CATACLYSM,"FFFF3333") end
				if LE_EXPANSION_MISTS_OF_PANDARIA then self:AddExpansion(LE_EXPANSION_MISTS_OF_PANDARIA,"FF33CC99") end
				if LE_EXPANSION_WARLORDS_OF_DRAENOR then self:AddExpansion(LE_EXPANSION_WARLORDS_OF_DRAENOR,"FFCC3300") end
				if LE_EXPANSION_LEGION then self:AddExpansion(LE_EXPANSION_LEGION,"FF33FF33") end
				if LE_EXPANSION_BATTLE_FOR_AZEROTH then self:AddExpansion(LE_EXPANSION_BATTLE_FOR_AZEROTH,"FF6666FF") end
				if LE_EXPANSION_SHADOWLANDS then self:AddExpansion(LE_EXPANSION_SHADOWLANDS,"FFFFDDAA") end
				if LE_EXPANSION_DRAGONFLIGHT or LE_EXPANSION_10_0 then self:AddExpansion(LE_EXPANSION_DRAGONFLIGHT or LE_EXPANSION_10_0,"FFDDDDDD") end
				---- [ Factions ]
				self.FACTIONS = {}
				self:AddFaction("Other",FACTION_OTHER,"FF999999")
				self:AddFaction("Alliance",FACTION_ALLIANCE,"FF3366FF")
				self:AddFaction("Horde",FACTION_HORDE,"FFFF3333")
				self:AddFaction("Neutral",FACTION_NEUTRAL,"FFFFFF33")
				---- [ Factions Modes ]
				self.FACTION_MODES = {}
				self:AddFactionMode(L["Auto"],"FF33FF33")
				self:AddFactionMode(FACTION_ALLIANCE,"FF3366FF")
				self:AddFactionMode(FACTION_HORDE,"FFFF3333")
				self:AddFactionMode(FACTION_NEUTRAL,"FFFFFF33")
				---- [ Class Modes ]
				self.CLASS_MODES = {}
				self:AddClassMode(L["Off"],"FFFF3333")
				self:AddClassMode(L["On"],"FF33FF33")
				---- [ Modes ]
				self.MODES = {}
				self:AddMode(L["Off"],"FFFF3333")
				self:AddMode(L["Auto"],"FF33FF33")
				self:AddMode(L["Rare"],"FF999999")
				self:AddMode(L["Rare-Elite"],"FFFFDD99")
				self:AddMode(L["Elite"],"FFFFDD33")
				local ml = #self.MODES
				---- [ Textures ]
				self.TEXTURES = {}
				self:AddTexture(L["Standard (Off)"],"Interface\\TargetingFrame\\UI-TargetingFrame.blp",{1,0.09375,0,0.78125})
				self:AddTexture(L["Standard"],"Interface\\TargetingFrame\\UI-TargetingFrame.blp",{1,0.09375,0,0.78125},nil,(self.BRANCH ~= WOW_PROJECT_MAINLINE) and {self.SetPointOffset(0,-0.5)} or {self.SetPointOffset(0,0.5)})
				self:AddTexture(nil,"Interface\\TargetingFrame\\UI-TargetingFrame-Rare.blp",{1,0.09375,0,0.78125},nil,(self.BRANCH ~= WOW_PROJECT_MAINLINE) and {self.SetPointOffset(0,-0.5)} or {self.SetPointOffset(0,0.5)})
				self:AddTexture(nil,"Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite.blp",{1,0.09375,0,0.78125},nil,(self.BRANCH == WOW_PROJECT_BURNING_CRUSADE_CLASSIC or self.BRANCH == WOW_PROJECT_WRATH_CLASSIC) and {self.SetPointOffset(0,-0.5)} or (self.BRANCH == WOW_PROJECT_CLASSIC and {self.SetPointOffset(2,-0.5)} or {self.SetPointOffset(0,0.5)}),self.BRANCH == WOW_PROJECT_CLASSIC and {self.SetPointOffset(1.5,0)})
				self:AddTexture(nil,"Interface\\TargetingFrame\\UI-TargetingFrame-Elite.blp",{1,0.09375,0,0.78125},nil,(self.BRANCH ~= WOW_PROJECT_MAINLINE) and {self.SetPointOffset(0,-0.5)} or {self.SetPointOffset(0,0.5)})
				local tl = #self.MODES-1
				---- [ Custom Frames ]
				for i,v in ipairs(addon.CUSTOM_FRAMES) do self:AddCustomFrame(v) end
				--- [ Variables ]
				---- [ States ]
				self.initialisationStages[1].name = L["1 - Frame"]
				self.initialisationStages[2].name = L["2 - Addon"]
				self.initialisationStages[3].name = L["3 - Player"]
			end)
			-- [ Hooks ]
			self.FRAME:RegisterEvent("ADDON_LOADED")
			self.FRAME:RegisterEvent("PLAYER_ENTERING_WORLD")
			self.FRAME:RegisterEvent("PLAYER_LEVEL_UP")
			self.FRAME:RegisterEvent("UPDATE_EXPANSION_LEVEL")
			self.FRAME:RegisterEvent("MIN_EXPANSION_LEVEL_UPDATED")
			self.FRAME:RegisterEvent("MAX_EXPANSION_LEVEL_UPDATED")
			if self.BRANCH == WOW_PROJECT_MAINLINE then
				self.FRAME:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT")
				self.FRAME:RegisterEvent("BARBER_SHOP_APPEARANCE_APPLIED")
			end
			if self.BRANCH ~= WOW_PROJECT_CLASSIC then
				self.FRAME:RegisterUnitEvent("UNIT_EXITED_VEHICLE","player")
			end
			-- [ Manage state ]
			self.initialisationStages[stage].state = true
		elseif (stage == 2 and self.initialisationStages[1].state) then
			-- [ Settings ]
			local newDatabase = false
			local newVersion = false
			local fixed = 0
			--- [ Get/Set ]
			if (not _G[self.SETTINGS_NAME]) then
				newDatabase = true
				_G[self.SETTINGS_NAME] = self.SetSettings({},self.CHAR_SETTINGS_STRUCTURE,self.CHAR_SETTINGS_DEFAULTS)
				self:Msg(format(L["Used default settings for new %s."],tostring(settingsType),L["character"]),self.NOTICE_LEVEL)
			end
			self.database = _G[self.SETTINGS_NAME]
			if (not newDatabase) then
				--- [ Fix ]
				if (self.database.version == nil or self.database.version ~= self.CHAR_SETTINGS_DEFAULTS.version) then
					newVersion = true
				end
				fixed = fixed + self.FixSettings(self.database,self.CHAR_SETTINGS_STRUCTURE,self.CHAR_SETTINGS_DEFAULTS)
			end
			--- [ Output ]
			self.settings = self.database
			if (not newDatabase and not newVersion and fixed > 0) then
				self:Msg(format(L["Fixed %s settings."],fixed),newVersion and self.DEBUG_LEVEL or self.WARNING_LEVEL)
			elseif (newVersion) then
				self:Msg(format(L["Updated settings for version %s.%s on branch %s."],tostring(self.VERSION),tostring(self.REVISION),tostring(self.BRANCH)),self.NOTICE_LEVEL)
			end
			-- [ Information ]
			self:SetInfo()
			-- [ Manage state ]
			self.initialisationStages[stage].state = true
		elseif (stage == 3 and self.initialisationStages[1].state and self.initialisationStages[2].state) then
			-- [ Information ]
			if (not self.info.player) then
				self:SetPlayerInfo()
			end
			-- [ GUI ]
			self:FixFrameLevels()
			self:SetTextureDefaultFramePoints()
			self:SetLevelTextDefaultFramePoints()
			self:SetRestIconDefaultFramePoints()
			-- [ Hooks ]
			self.RunOnce("InitialiseStage3Hooks",function ()
				hooksecurefunc(self.PLAYER_FRAME.."_Update",self.HOOKS.PlayerFrame_Updated)
				hooksecurefunc(self.PLAYER_FRAME.."_UpdateLevelTextAnchor",self.HOOKS.LevelText_Updated)
			end)
			-- [ Manage state ]
			self.initialisationStages[stage].state = true
		end
		if (self.initialisationStages[stage].state) then
			value = #self.initialisationStages
			for k,v in pairs(self.initialisationStages) do
				if (not v.state) then value = value - 1 end
			end
			addon:Msg(format(L["Initialised stage %s (%s/%s)."],tostring(self.initialisationStages[stage].name),tostring(value),tostring(#self.initialisationStages)),self.NOTICE_LEVEL)
			-- [ Manage proceeding initialisation ]
			--- [ Stage 2 ]
			if (stage == 1) then
				if (self.initialisationStages[2].state) then
					addon:InitialiseStage(2,false)
				end
				if (self.hasLoaded) then
					addon:InitialiseStage(2)
				end
			end
			--- [ Stage 3 ]
			if (stage == 1 or stage == 2) then
				if (self.initialisationStages[3].state) then
					addon:InitialiseStage(3,false)
				end
				if (self.hasPlayerLoaded) then
					addon:InitialiseStage(3)
				end
			end
			-- [ Manage overall state ]
			if (not self.isInitialised) then
				if (value == #self.initialisationStages) then
					-- [ GUI ]
					self:Update(true)
					-- [ Slash commands ]
					_G["SLASH_"..addon.NAME.."1"] = addon.SLASHCMD
					_G["SLASH_"..addon.NAME.."2"] = addon.SLASHCMD2
					SlashCmdList[addon.NAME] = addon.HOOKS.SlashCmd_Received
					-- [ Manage state ]
					self.isInitialised = true
					addon:Msg(L["Initialised."],self.NOTICE_LEVEL)
					self.FRAME:Initialised()
				end
			end
		end
	elseif (not value and self.initialisationStages[stage].state) then	-- Uninitialising an initialised stage
		self.initialisationStages[stage].state = false
		value = #self.initialisationStages
		for k,v in pairs(self.initialisationStages) do
			if (not v.state) then value = value - 1 end
		end
		addon:Msg(format(L["Uninitialised stage %s (%s/%s)."],tostring(self.initialisationStages[stage].name),tostring(value),tostring(#self.initialisationStages)),self.NOTICE_LEVEL)
		-- [ Manage proceeding initialisation ]
		--- [ Stage 2 ]
		if (stage == 1) then
			if (self.initialisationStages[2].state) then
				addon:InitialiseStage(2,false)
			end
		end
		--- [ Stage 3 ]
		if (stage == 1 or stage == 2) then
			if (self.initialisationStages[3].state) then
				addon:InitialiseStage(3,false)
			end
		end
		-- [ Manage overall state ]
		if (self.isInitialised) then
			self.isInitialised = false
			addon:Msg(L["Uninitialised."],self.NOTICE_LEVEL)
		end
	end
	-- [ Process tail calls ]
	for i,c in pairs(tailcalls) do
		c()
	end
	return self.isInitialised,self.initialisationStages
end
_G[addon.NAME.."Mixin"] = {}
addon.MIXINS.FRAME = _G[addon.NAME.."Mixin"]
function addon.MIXINS.FRAME:Initialised()
	return addon.isInitialised
end
addon.MIXINS.FRAME.VERSION = addon.VERSION
addon.MIXINS.FRAME.REVISION = addon.REVISION
addon.MIXINS.FRAME.BRANCH = addon.BRANCH
function addon.MIXINS.FRAME:AddCustomFrame(definition)
	if not addon.isInitialised then return end
	local i, n = addon:AddCustomFrame(definition)
	if i then addon:Msg(format(L["Added mode and texture for custom frame (%s: %s)"],i,n),addon.DEBUG_LEVEL) end
	return i, n
end
--- [ RunOnce ]
local ran = {}
function addon.RunOnce(id,f,t)
	if (not t) then t = ran end
	if (not t[id]) then
		t[id] = true
		return f()
	end
end
--- [ Frame loaded handler ]
addon.hasFrameLoaded = false
function addon.MIXINS.FRAME:Loaded()
	addon.hasFrameLoaded = true
	addon.FRAME = self
	if (addon.initialisationStages[1].state and reload) then
		addon:InitialiseStage(1,false)
	end
	addon:InitialiseStage(1) 
end
--- [ Event received handler ]
function addon.MIXINS.FRAME:Event_Received(event,...)
	addon:Msg(event,addon.DEBUG_LEVEL)
	if (event == "ADDON_LOADED") then
		if (select(1,...) == addon.NAME) then
			addon:Loaded()
		end
	elseif (event == "PLAYER_ENTERING_WORLD") then
		addon:Player_Loaded()
	elseif (addon.isInitialised) then
		if (event == "UPDATE_EXPANSION_LEVEL" or event == "MIN_EXPANSION_LEVEL_UPDATED" or event == "MAX_EXPANSION_LEVEL_UPDATED") then	-- The expansion info may have changed
			addon:Update()
		elseif (event == "PLAYER_LEVEL_UP" or event == "NEUTRAL_FACTION_SELECT_RESULT" or event == "BARBER_SHOP_APPEARANCE_APPLIED") then	-- The player level, faction, or gender may have changed
			addon:Update()
		elseif (event == "UNIT_EXITED_VEHICLE") then	-- The player frame was reset
			addon:Update(true)
		end
	end
end
--- [ Loaded handler ]
addon.hasLoaded = false
function addon:Loaded(reload)
	self.hasLoaded = true
	self.FRAME:UnregisterEvent("ADDON_LOADED")
	if (self.initialisationStages[2].state and reload) then
		self:InitialiseStage(2,false)
	end
	self:InitialiseStage(2)
end
--- [ Player loaded handler ]
addon.hasPlayerLoaded = false
function addon:Player_Loaded(reload)
	self.hasPlayerLoaded = true
	if (self.initialisationStages[3].state and reload) then
		self:InitialiseStage(3,false)
	end
	self:InitialiseStage(3)
end
-- [ Addon reset ]
function addon:Reset()
	-- [ Manage initialisation ]
	self:InitialiseStage(2,false)
	-- [ Settings ]
	_G[addon.SETTINGS_NAME] = nil
	self.settings = nil
	-- [ Manage initialisation ]
	self:InitialiseStage(2)
	self:Msg(format(L["%s settings were reset."],L["Character"]))
end
-- [ Settings ]
--- [ Set ]
function addon.SetSettings(settings,structure,defaults)
	local set = 0
	for k,v in pairs(structure) do
		settings[k] = type(v) == "table" and {} or defaults[k]
		addon:Msg(format(L["Setting %s set to default."],tostring(k)),addon.DEBUG_LEVEL)
		set = set + 1
		if (type(settings[k]) == "table" and type(defaults[k]) == "table" and #defaults[k] > 0) then
			set = set + addon.SetSettings(settings[k],structure[k],defaults[k])
		end
	end
	return settings, set
end
--- [ Fix ]
function addon.FixSettings(settings,structure,defaults)
	local fixed = 0
	for k,v in pairs(structure) do
		if settings[k] == nil and defaults[k] then
			settings[k] = defaults[k]
			addon:Msg(format(L["Missing setting %s set to default."],tostring(k)),addon.DEBUG_LEVEL)
			fixed = fixed + 1
		end
	end
	for k,v in pairs(settings) do
		if structure[k] == nil then
			settings[k] = nil
			addon:Msg(format(L["Unused setting %s removed."],tostring(k)),addon.DEBUG_LEVEL)
			fixed = fixed + 1
		else
			local multiValid = false
			if (type(structure[k]) == "string" and structure[k]:find(",")) then
				for i,t in ipairs({strsplit(",",structure[k])}) do
					if (type(v) == t) then
						multiValid = true
						break
					end
				end
			end
			if (not multiValid and (type(v) ~= "table" and type(v) ~= structure[k]) or (type(v) == "table" and type(structure[k]) ~= "table")) then
				settings[k] = type(structure[k]) == "table" and {} or defaults[k]
				if settings[k] == nil then
					addon:Msg(format(L["Invalid setting %s removed."],tostring(k)),addon.DEBUG_LEVEL)
				else
					addon:Msg(format(L["Invalid setting %s set to default."],tostring(k)),addon.DEBUG_LEVEL)
				end
				fixed = fixed + 1
			end
		end
		if type(settings[k]) == "table" and type(structure[k]) == "table" and next(structure[k]) ~= nil then
			fixed = fixed + addon.FixSettings(settings[k],structure[k],defaults[k] or {})
		end
	end
	if (defaults.version) then
		settings.version = defaults.version
	end
	return fixed
end
-- [ Table building ]
function addon.SetTableData(d,i,n,c)
	d.id = i
	d.name = n
	d.color = c
	return d
end
function addon.AddDataToTable(t,n,c)
	local i = t[0] and #t + 1 or 0	-- Index from 0
	t[i] = {}
	return addon.SetTableData(t[i],i,n,c)
end
function addon:AddDebugLevel(i,n,p,c)
	self.DEBUG_LEVELS[i] = {}
	self.DEBUG_LEVELS[i].prefix = p
	return self.SetTableData(self.DEBUG_LEVELS[i],i,n,c)
end
function addon:AddBranch(i,n)
	self.BRANCHES[i] = n
	return self.BRANCHES[i]
end
function addon:AddGender(n,c)
	local i = #self.GENDERS + 1
	self.GENDERS[i] = {}
	return self.SetTableData(self.GENDERS[i],i,n,c)
end
function addon:AddClass(i,n,c)
	self.CLASSES[i] = {}
	return self.SetTableData(self.CLASSES[i],i,n,c)
end
function addon.GetHexColor(c)
	return format("FF%02X%02X%02X",Round(c.r * 255),Round(c.g * 255),Round(c.b * 255))
end
function addon:AddExpansion(i,c)
	self.EXPANSIONS[i] = {}
	self.EXPANSIONS[i].maxLevel = GetMaxLevelForExpansionLevel(i)
	self.EXPANSIONS[i].minLevel = i > 0 and GetMaxLevelForExpansionLevel(i - 1) or (self.BRANCH == WOW_PROJECT_MAINLINE and self.INTRO_MAX_LEVEL or 0)
	return self.SetTableData(self.EXPANSIONS[i],i,_G["EXPANSION_NAME"..tostring(i)] or UNKNOWN,c)
end
function addon:AddFaction(i,n,c)
	self.FACTIONS[i] = {}
	return self.SetTableData(self.FACTIONS[i],i,n,c)
end
function addon:AddFactionMode(n,c)
	return self.AddDataToTable(self.FACTION_MODES,n,c)
end
function addon:AddMode(n,c)
	return self.AddDataToTable(self.MODES,n,c)
end
function addon:AddClassMode(n,c)
	return self.AddDataToTable(self.CLASS_MODES,n,c)
end
function addon:AddTexture(n,tx,tc,p,ltp,rip,ac)
	local i = self.TEXTURES[0] and #self.TEXTURES + 1 or 0	-- Index from 0
	self.TEXTURES[i] = {}
	self.TEXTURES[i].file = tx
	self.TEXTURES[i].coords = tc or {}
	self.TEXTURES[i].points = p or {}
	self.TEXTURES[i].levelTextPoints = ltp or {}
	self.TEXTURES[i].restIconPoints = rip or {}
	self.TEXTURES[i].autoCondition = ac or false
	return self.SetTableData(self.TEXTURES[i],i,n or self.MODES[i].name,self.MODES[i].color)
end
function addon.SetPointOffset(x,y)
	return {
		["offsetX"] = x,
		["offsetY"] = y
	}
end
-- [ Message output ]
addon.PREFIX = "[|cFFFFDD33"..tostring(addon.SHORT_NAME).."|r]"
function addon:Msg(msg,dbg,custom)
	local prefix = self.PREFIX
	if (custom and custom.prefix) then
		prefix = custom.prefix
	end
	local colon = ":"
	if (self.initialisationStages[1].state) then
		colon = L[":"]
	end
	if (custom and custom.type and custom.lang and custom.to) then
		SendChatMessage(tostring(prefix)..colon.." "..tostring(msg),custom.type,custom.lang,custom.to)
	else
		if (DEFAULT_CHAT_FRAME and (dbg == nil or (self.initialisationStages[2].state and self.settings.debug >= dbg) or (not self.initialisationStages[2].state and self.CHAR_SETTINGS_DEFAULTS.debug >= dbg))) then
			if (self.initialisationStages[1].state and dbg ~= nil) then
				msg = self.ColorMsg(tostring(self.DEBUG_LEVELS[dbg].prefix),self.DEBUG_LEVELS[dbg].color)..colon.." "..msg
			end
			DEFAULT_CHAT_FRAME:AddMessage(tostring(prefix)..colon.." "..tostring(msg))
		end
	end
end
--- [ Message color ]
function addon.ColorMsg(s,c)
	if (s and c) then
		s = "|c"..tostring(c)..tostring(s).."|r"
	end
	return s
end
-- [ Information ]
function addon:SetInfo()
	self.info = {}
	self:SetAddonInfo()
	self:SetExpansionInfo()
	if (self.hasPlayerLoaded) then
		self:SetPlayerInfo()
	end
	return self.info
end
--- [ Addon ]
function addon:SetAddonInfo()
	self.info.shortName = self.SHORT_NAME
	self.info.name, self.info.title, self.info.description = GetAddOnInfo(self.NAME)
	self.info.version = GetAddOnMetadata(self.NAME, "Version")
	self.info.author = GetAddOnMetadata(self.NAME, "Author")
	self.info.url = GetAddOnMetadata(self.NAME, "X-Website")
	self.info.email = GetAddOnMetadata(self.NAME, "X-eMail")
	self:Msg(L["Addon information updated."],self.NOTICE_LEVEL)
end
--- [ Expansions ]
function addon:GetExpansionLevel()
	if self.BRANCH == WOW_PROJECT_MAINLINE then
		return math.min(GetExpansionLevel(),GetAccountExpansionLevel())	-- #ToDo: Can the level part be reliably changed to just GetMaxLevelForPlayerExpansion()? Need to test with non-shadowlands account
	elseif self.BRANCH ~= WOW_PROJECT_CLASSIC then
		--return math.min(GetClassicExpansionLevel(),GetExpansionLevel(),GetAccountExpansionLevel())	-- #ToDo: Do we need to use the classic version too/only? Need to test in future expansion #Bug: Blizzard decided to ignore the GetAccountExpansionLevel API for Classic expansions, and GetExpansionLevel() updating was wonky for launch
		return GetExpansionLevel()	-- #WorkAround: Just use GetExpansionLevel() directly until Blizzard improve the API and we can retest a launch
	end
	return 0
end
function addon:SetExpansionInfo()
	local i = self:GetExpansionLevel()
	if (not self.EXPANSIONS[i]) then
		self:AddExpansion(i,"FFFFFFFF")
	end
	self.info.expansion = self.EXPANSIONS[i]
	if self.BRANCH == WOW_PROJECT_MAINLINE then
		self:Msg(L["Expansion levels:"]..strchar(13)..format(L["Player: %s"],tostring(GetMaxLevelForPlayerExpansion()))..strchar(13)..format(L["Account: %s (%s)"],tostring(GetMaxLevelForExpansionLevel(GetAccountExpansionLevel())),tostring(GetAccountExpansionLevel()))..strchar(13)..format(L["Server: %s (%s)"],tostring(GetMaxLevelForExpansionLevel(GetServerExpansionLevel())),tostring(GetServerExpansionLevel()))..strchar(13)..format(L["Client: %s-%s:%s ~%s (%s-%s:%s #%s)"],tostring(GetMaxLevelForExpansionLevel(GetMinimumExpansionLevel())),tostring(GetMaxLevelForExpansionLevel(GetMaximumExpansionLevel())),tostring(GetMaxLevelForExpansionLevel(GetExpansionLevel())),tostring(GetMaxLevelForLatestExpansion()),tostring(GetMinimumExpansionLevel()),tostring(GetMaximumExpansionLevel()),tostring(GetExpansionLevel()),tostring(GetNumExpansions()))..strchar(13)..format(L["Calculated: %s-%s (%s)"],tostring(self.info.expansion.minLevel),tostring(self.info.expansion.maxLevel),tostring(self.info.expansion.id)),self.DEBUG_LEVEL)
	elseif self.BRANCH ~= WOW_PROJECT_CLASSIC then
		self:Msg(L["Expansion levels:"]..strchar(13)..format(L["Account: %s (%s)"],tostring(GetMaxLevelForExpansionLevel(GetAccountExpansionLevel())),tostring(GetAccountExpansionLevel()))..strchar(13)..format(L["Server: %s (%s)"],tostring(GetMaxLevelForExpansionLevel(GetServerExpansionLevel())),tostring(GetServerExpansionLevel()))..strchar(13)..format(L["Client: %s-%s:%s (%s-%s:%s #%s)"],tostring(GetMaxLevelForExpansionLevel(GetMinimumExpansionLevel())),tostring(GetMaxLevelForExpansionLevel(GetMaximumExpansionLevel())),tostring(GetMaxLevelForExpansionLevel(GetExpansionLevel())),tostring(GetMinimumExpansionLevel()),tostring(GetMaximumExpansionLevel()),tostring(GetExpansionLevel()),tostring(GetNumExpansions()))..strchar(13)..format(L["Calculated: %s-%s (%s)"],tostring(self.info.expansion.minLevel),tostring(self.info.expansion.maxLevel),tostring(self.info.expansion.id)),self.DEBUG_LEVEL)
	else
		
	end
	self:Msg(L["Expansion information updated."],self.DEBUG_LEVEL)
	return self.info.expansion
end
--- [ Player ]
function addon:SetPlayerInfo()
	if (UnitExists("player")) then
		self.info.player = {}
		self.info.player.name = UnitName("player")
		self.info.player.level = UnitLevel("player")
		self.info.player.gender = UnitSex("player")
		self.info.player.race = UnitRace("player")
		self.info.player.class = UnitClassBase("player")
		self.info.player.faction = UnitFactionGroup("player")
		self:Msg(L["Player information updated."],self.NOTICE_LEVEL)
	else
		self:Msg(L["Unable to update player information; player not loaded yet."],self.WARNING_LEVEL)
	end
	return self.info.player
end
-- [ Custom Frames ]
function addon:AddCustomFrame(definition)
	if type(definition) == "function" then
		local i, f = #self.MODES, definition(self)
		if f then
			local i, n = i+1, f[1]
			self:AddMode(n,f[2])
			self:AddTexture(nil,unpack(f[3]))
			return i, n
		end
	end
end
-- [ GUI ]
--- [ Fix frame levels ]
function addon:FixFrameLevels()
	if (UnitExists("player")) then
		local l = _G[self.PLAYER_TEXTURE_FRAME]:GetParent():GetFrameLevel()
		self:Msg(format(L["%s frame level is %s."],self.PLAYER_TEXTURE_FRAME,tostring(l)),self.DEBUG_LEVEL)
		for i,v in ipairs(self.PLAYER_RESOURCE_BAR_FRAMES) do
			if _G[v] then
				local rbfl = _G[v]:GetFrameLevel()
				_G[v]:SetFrameLevel(l + 1)
				self:Msg(format(L["%s frame level was %s, now %s."],v,tostring(rbfl),tostring(_G[v]:GetFrameLevel())),self.DEBUG_LEVEL)
			end
		end
		local gfl = _G[self.PLAYER_GROUP_FRAME]:GetFrameLevel()
		_G[self.PLAYER_GROUP_FRAME]:SetFrameLevel(l + 1)
		self:Msg(format(L["%s frame level was %s, now %s."],self.PLAYER_GROUP_FRAME,tostring(gfl),tostring(_G[self.PLAYER_GROUP_FRAME]:GetFrameLevel())),self.DEBUG_LEVEL)
		local pfl = _G[self.PLAYER_PET_FRAME]:GetFrameLevel()
		_G[self.PLAYER_PET_FRAME]:SetFrameLevel(l + 2)
		self:Msg(format(L["%s frame level was %s, now %s."],self.PLAYER_PET_FRAME,tostring(pfl),tostring(_G[self.PLAYER_PET_FRAME]:GetFrameLevel())),self.DEBUG_LEVEL)
		if _G[self.PLAYER_TOTEM_FRAME] then
			local tfl = _G[self.PLAYER_TOTEM_FRAME]:GetFrameLevel()
			_G[self.PLAYER_TOTEM_FRAME]:SetFrameLevel(l + 3)
			self:Msg(format(L["%s frame level was %s, now %s."],self.PLAYER_TOTEM_FRAME,tostring(tfl),tostring(_G[self.PLAYER_TOTEM_FRAME]:GetFrameLevel())),self.DEBUG_LEVEL)
		end
	else
		self:Msg(L["Unable to fix frame levels; player not loaded yet."],self.WARNING_LEVEL)
	end
end
--- [ Get frame points ]
function addon.GetFramePoints(frame)
	if type(frame) == "string" then
		frame = _G[frame]
	end
	local points = {}
	for i = 1,frame:GetNumPoints() do
		local anchor,relativeFrame,relativeAnchor,x,y = frame:GetPoint(i)
		addon:Msg(format(L["%s point %s/%s is %s,%s,%s,%s,%s."],tostring(frame:GetName()),tostring(i),tostring(frame:GetNumPoints()),tostring(anchor),tostring(relativeFrame:GetName()),tostring(relativeAnchor),tostring(x),tostring(y)),addon.DEBUG_LEVEL)
		tinsert(points,{
			["anchor"] = anchor,
			["relativeFrame"] = relativeFrame,
			["relativeAnchor"] = relativeAnchor,
			["offsetX"] = x,
			["offsetY"] = y
		})
		i = i + 1
	end
	return points
end
--- [ Set default frame points ]
addon.defaultFramePoints = {}
function addon:SetDefaultFramePoints(frame,reset)
	if reset or not self.defaultFramePoints[frame] then
		if frame then
			self.defaultFramePoints[frame] = {}
			if frame == self.PLAYER_LEVEL_TEXT_FRAME then
				_G[frame]:SetWordWrap(false)	-- #Bug: vertical alignment of levels 100+ will not match between login and UI reloads - #Fix: Disabling word wrap fixes this discrepancy
			end
			self.defaultFramePoints[frame] = self.GetFramePoints(frame)
			self:Msg(format(L["Set default points for %s."],tostring(_G[frame]:GetName())),self.DEBUG_LEVEL)
		else
			self:Msg(format(L["Unable to set default points for %s; frame does not exist yet."],tostring(_G[frame]:GetName())),self.WARNING_LEVEL)
		end
	end
end
function addon:SetTextureDefaultFramePoints(reset)
	return addon:SetDefaultFramePoints(addon.PLAYER_TEXTURE_FRAME,reset)
end
function addon:SetLevelTextDefaultFramePoints(reset)
	return addon:SetDefaultFramePoints(addon.PLAYER_LEVEL_TEXT_FRAME,reset)
end
function addon:SetRestIconDefaultFramePoints(reset)
	return addon:SetDefaultFramePoints(addon.PLAYER_REST_ICON_FRAME,reset)
end
--- [ Update display ]
function addon:Update(force)
	local changed = false
	if not self.info.player or self.info.player.level ~= UnitLevel("player") or self.info.player.faction ~= UnitFactionGroup("player") or self.info.player.gender ~= UnitSex("player") or self.info.player.class ~= UnitClassBase("player") then
		self:SetPlayerInfo()
		changed = true
	else
		self:Msg(L["Player info has not changed since the last display update."],self.DEBUG_LEVEL)
	end
	if not self.info.expansion or self.info.expansion.maxLevel ~= GetMaxLevelForExpansionLevel(self:GetExpansionLevel()) then
		self:SetExpansionInfo()
		changed = true
	else
		self:Msg(L["Expansion info has not changed since the last display update."],self.DEBUG_LEVEL)
	end
	if force then
		self:Msg(L["Forced display update."],self.DEBUG_LEVEL)
	end
	if force or changed then
		changed = self:UpdateTexture() or false
		changed = self:UpdateLevelText() or changed
		changed = self:UpdateRestIcon() or changed
		if _G[self.PLAYER_FRAME]:IsClampedToScreen() == false then
			_G[self.PLAYER_FRAME]:SetClampedToScreen(true)
			changed = true
		end
		if changed then
			-- [ Hooks ]
			self.FRAME:Updated()
		end
	end
end
function addon.MIXINS.FRAME:Updated()
	return
end
function addon.HOOKS.PlayerFrame_Updated(...)
	return addon:Update(...)
end
--- [ Texture ]
---- [ Update ]
function addon:UpdateTexture(reset)
	if _G[self.PLAYER_TEXTURE_FRAME] then
		self:SetTextureDefaultFramePoints(reset)
		if #self.defaultFramePoints[self.PLAYER_TEXTURE_FRAME] >= 1 then
			local texture = self.GetTexture()
			_G[self.PLAYER_TEXTURE_FRAME]:SetTexture(texture.file)
			_G[self.PLAYER_TEXTURE_FRAME]:ClearAllPoints()
			for i,v in ipairs(self.defaultFramePoints[self.PLAYER_TEXTURE_FRAME]) do
				_G[self.PLAYER_TEXTURE_FRAME]:SetPoint(v.anchor, v.relativeFrame, v.relativeAnchor, texture.points[i] and v.offsetX + texture.points[i].offsetX or v.offsetX, texture.points[i] and v.offsetY + texture.points[i].offsetY or v.offsetY)
			end
			_G[self.PLAYER_TEXTURE_FRAME]:SetTexCoord(texture.coords[1], texture.coords[2], texture.coords[3], texture.coords[4])
			self:Msg(format(L["Updated to %s texture."],self.ColorMsg(tostring(texture.name),texture.color)),self.DEBUG_LEVEL)
			if self.settings.debug >= self.DEBUG_LEVEL then
				self.GetFramePoints(self.PLAYER_TEXTURE_FRAME)
			end
			return true
		else
			self:Msg(L["Unable to update texture position; default points not set yet."],self.WARNING_LEVEL)
		end
	else
		self:Msg(L["Unable to update texture position; frame not loaded yet."],self.DEBUG_LEVEL)
	end
	return false
end
function addon.HOOKS.Texture_Updated(...)	-- Unused hook
	return addon:UpdateTexture(...)	-- If an argument is provided, it causes a default points reset
end
---- [ Get ]
function addon.GetTexture()
	if addon.info.player and addon.settings.mode == 1 then
		for i,v in ipairs(addon.TEXTURES) do
			if type(v.autoCondition) == "function" and v.autoCondition(addon) then
				return addon.TEXTURES[i]
			end
		end
		if addon.info.player.level == addon.info.expansion.maxLevel then
			return addon.TEXTURES[4]
		elseif addon.info.player.level >= addon.INTRO_MAX_LEVEL then
			if addon.info.player.level >= addon.info.expansion.minLevel then
				return addon.TEXTURES[3]
			else
				return addon.TEXTURES[2]
			end
		else
			return addon.TEXTURES[1]
		end
	end
	return addon.TEXTURES[addon.settings.mode] or addon.TEXTURES[1]
end
--- [ Update level text ]
function addon:UpdateLevelText(reset)
	if _G[self.PLAYER_LEVEL_TEXT_FRAME] then
		self:SetLevelTextDefaultFramePoints(reset)
		if #self.defaultFramePoints[self.PLAYER_LEVEL_TEXT_FRAME] >= 1 then
			_G[self.PLAYER_LEVEL_TEXT_FRAME]:ClearAllPoints()
			local texture = self.GetTexture()
			for i,v in ipairs(self.defaultFramePoints[self.PLAYER_LEVEL_TEXT_FRAME]) do
				_G[self.PLAYER_LEVEL_TEXT_FRAME]:SetPoint(v.anchor, v.relativeFrame, v.relativeAnchor, texture.levelTextPoints[i] and v.offsetX + texture.levelTextPoints[i].offsetX or v.offsetX, texture.levelTextPoints[i] and v.offsetY + texture.levelTextPoints[i].offsetY or v.offsetY)
			end
			if self.settings.debug >= self.DEBUG_LEVEL then
				self.GetFramePoints(self.PLAYER_LEVEL_TEXT_FRAME)
			end
			self:Msg(L["Updated level text position."],self.DEBUG_LEVEL)
			return true
		else
			self:Msg(L["Unable to update level text position; default points not set yet."],self.WARNING_LEVEL)
		end
	else
		self:Msg(L["Unable to update level text position; frame not loaded yet."],self.DEBUG_LEVEL)
	end
	return false
end
function addon.HOOKS.LevelText_Updated(...)
	return addon:UpdateLevelText(...)	-- If an argument is provided, it causes a default points reset (e.g. PlayerFrame_UpdateLevelTextAnchor provides a level argument)
end
--- [ Update rest icon ]
function addon:UpdateRestIcon(reset)
	if _G[self.PLAYER_REST_ICON_FRAME] then
		self:SetLevelTextDefaultFramePoints(reset)
		if #self.defaultFramePoints[self.PLAYER_REST_ICON_FRAME] >= 1 then
			local texture = self.GetTexture()
			for i,v in ipairs(self.defaultFramePoints[self.PLAYER_REST_ICON_FRAME]) do
				_G[self.PLAYER_REST_ICON_FRAME]:SetPoint(v.anchor, v.relativeFrame, v.relativeAnchor, texture.restIconPoints[i] and v.offsetX + texture.restIconPoints[i].offsetX or v.offsetX, texture.restIconPoints[i] and v.offsetY + texture.restIconPoints[i].offsetY or v.offsetY)
			end
			if self.settings.debug >= self.DEBUG_LEVEL then
				self.GetFramePoints(self.PLAYER_REST_ICON_FRAME)
			end
			self:Msg(L["Updated rest icon position."],self.DEBUG_LEVEL)
			return true
		else
			self:Msg(L["Unable to update rest icon position; default points not set yet."],self.WARNING_LEVEL)
		end
	else
		self:Msg(L["Unable to update rest icon position; frame not loaded yet."],self.DEBUG_LEVEL)
	end
	return false
end
function addon.HOOKS.RestIcon_Updated(...)	-- Unused hook
	return addon:UpdateRestIcon(...)	-- If an argument is provided, it causes a default points reset
end
-- [ Slash command handlers ]
addon.SLASHCMD = "/"..tostring(addon.SHORT_NAME):lower()
addon.SLASHCMD2 = "/"..tostring(addon.NAME):lower()
addon.SLASHCMDS = {}
addon.SLASHCMD_INDEX = {}	-- Index of slash commands by name
addon.SLASHCMD_ARG_INDEX = {}	-- Index of slash command arguments by command name and argument name
addon.L_SLASHCMD_INDEX = {}	-- Index of slash commands by localised name
addon.L_SLASHCMD_ARG_INDEX = {}	-- Index of slash command arguments by localised command name and localised argument name
addon.SLASHCMD_HANDLERS = {}
addon.SLASHCMD_HELP_HANDLERS = {}
--- [ Root command handler ]
function addon.HOOKS.SlashCmd_Received(s,...)
	local cmd = {
		["string"] = nil,
		["args"] = nil,
		["cmd"] = nil,
	}
	local c
	cmd.string = s
	if s and s ~= "" then
		cmd.args = addon.ExplodeArguments(cmd.string)
		cmd.cmd = tostring(cmd.args[1])
		if not addon.SLASHCMDS[cmd.cmd] or type(addon.SLASHCMDS[cmd.cmd].handler) ~= "function" then
			cmd.cmd = L["help"]
			c = addon.SLASHCMDS[L["help"]].handler
			addon:Msg(format(L["%s is an invalid command."],tostring(cmd.string)),addon.ERROR_LEVEL)
		else
			c = addon.SLASHCMDS[cmd.cmd].handler
		end
	else
		cmd.cmd = L["help"]
		c = addon.SLASHCMDS[L["help"]].handler
	end
	c(cmd)
	cmd = nil	-- GC
end
--- [ Argument parsing ]
function addon.ExplodeArguments(s)
	local t = {}
	local i = 0
	while (type(s) == "string") do
		local _, ri, ra = string.find(s,'^ *"([^"]*)" *',i+1)	-- Find double quote enclosed arguments
		if not ra then
			_, ri, ra = string.find(s,'^ *([^%s]+) *',i+1)	-- Find space delimited arguments
		end
		if not ra then
			return t
		end
		i = ri
		tinsert(t,ra)
	end
end
--- [ Help command handler ]
tinsert(addon.SLASHCMD_INDEX,"help")
function addon.SLASHCMD_HANDLERS.help(cmd)
	local c
	if cmd.args and cmd.args[2] ~= nil then
		cmd.cmd = tostring(cmd.args[2])
		if addon.SLASHCMDS[cmd.cmd] and type(addon.SLASHCMDS[cmd.cmd].handler) == "function" then
			addon.SLASHCMDS[cmd.cmd].handler(cmd)
			return
		else
			addon:Msg(format(L["%s is an invalid argument for %s."],tostring(cmd.args[2]),L["help"]),addon.ERROR_LEVEL)
		end
	else
		addon:Msg(L["Help"]..L[":"].." ".."|cFFFFDD33"..addon.SLASHCMD.."|r"..L[","].." ".."|cFFFFDD33"..addon.SLASHCMD2.."|r")
	end
	for i,v in ipairs(addon.L_SLASHCMD_INDEX) do
		if v ~= L["help"] then
			c = addon.SLASHCMDS[v].helpHandler
			if v ~= L["update"] or addon.settings.debug >= addon.DEBUG_LEVEL then
				if type(c) == "function" then
					cmd.cmd = v
					c(cmd)
				end
			end
		end
	end
end
--- [ Info command handler ]
tinsert(addon.SLASHCMD_INDEX,"info")
addon.SLASHCMD_ARG_INDEX.info = {}
tinsert(addon.SLASHCMD_ARG_INDEX.info,"addon")
tinsert(addon.SLASHCMD_ARG_INDEX.info,"expansion")
tinsert(addon.SLASHCMD_ARG_INDEX.info,"player")
function addon.SLASHCMD_HANDLERS.info(cmd)
	if cmd.args and cmd.args[2] ~= nil then
		if cmd.args[2] == L["help"] or cmd.args[1] == L["help"] then
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
		elseif cmd.args[2] == L["addon"] then
			addon:Msg(L["Addon"]..L[":"].." "..format(L["%s v%s (%s), by %s."],tostring(addon.info.title),tostring(addon.info.version),tostring(addon.BRANCHES[addon.BRANCH] or UNKNOWN),tostring(addon.info.author))..strchar(13)..tostring(addon.info.description)..strchar(13)..tostring(addon.info.url)..strchar(13)..tostring(addon.info.email))
		elseif cmd.args[2] == L["expansion"] then
			addon:Msg(L["Expansion"]..L[":"].." "..format(L["%s (#%s), a %s max level."],addon.ColorMsg(tostring(addon.info.expansion.name),addon.EXPANSIONS[addon.info.expansion.id].color),tostring(addon.info.expansion.id),tostring(addon.info.expansion.maxLevel)))
		elseif cmd.args[2] == L["player"] then
			addon:Msg(L["Player"]..L[":"].." "..format(L["%s, a level %s %s %s %s %s."],tostring(addon.info.player.name),tostring(addon.info.player.level),tostring(addon.ColorMsg(addon.FACTIONS[addon.info.player.faction].name,addon.FACTIONS[addon.info.player.faction].color)),tostring(addon.ColorMsg(addon.GENDERS[addon.info.player.gender].name,addon.GENDERS[addon.info.player.gender].color)),tostring(addon.info.player.race),addon.ColorMsg(tostring(addon.CLASSES[addon.info.player.class].name[addon.info.player.gender]),addon.CLASSES[addon.info.player.class].color)))
		else
			addon:Msg(format(L["%s is an invalid argument for %s."],tostring(cmd.args[2]),L["info"]),addon.ERROR_LEVEL)
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
		end
	else
		-- [ Call cmd with each argument ]
		for i,v in ipairs(addon.L_SLASHCMD_ARG_INDEX[cmd.cmd]) do
			cmd.args[2] = addon.SLASHCMDS[cmd.cmd].arguments[v].localisedName
			addon.SLASHCMDS[cmd.cmd].handler(cmd)
		end
	end
end
---- [ Info command help handler ]
function addon.SLASHCMD_HELP_HANDLERS.info(cmd)
	local args = ""
	for i,v in ipairs(addon.L_SLASHCMD_ARG_INDEX[L["info"]]) do
		if args ~= "" then
			args = args.."|"
		end
		args = args..v
	end
	addon:Msg(L["Help"]..L[":"].." "..format(L["%s [%s] - Reports information about the optional subject."],L["info"],args))
end
--- [ Mode command handler ]
tinsert(addon.SLASHCMD_INDEX,"mode")
function addon.SLASHCMD_HANDLERS.mode(cmd)
	if cmd.args and cmd.args[2] ~= nil then
		if cmd.args[2] == L["help"] or cmd.args[1] == L["help"] then
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		elseif tonumber(cmd.args[2]) == nil or (tonumber(cmd.args[2]) > #addon.MODES or tonumber(cmd.args[2]) < 0) then
			addon:Msg(format(L["%s is an invalid argument for %s."],tostring(cmd.args[2]),L["mode"]),addon.ERROR_LEVEL)
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		else
			addon.settings.mode = tonumber(cmd.args[2])
			addon:Update(true)
		end
	end
	addon:Msg(L["Mode"]..L[":"].." "..format(L["%s (%s)."],addon.ColorMsg(tostring(addon.settings.mode),addon.MODES[addon.settings.mode].color),addon.ColorMsg(tostring(addon.MODES[addon.settings.mode].name),addon.MODES[addon.settings.mode].color)))
end
--- [ Mode command help handler ]
function addon.SLASHCMD_HELP_HANDLERS.mode(cmd)
	local modes = ""
	for i,v in ipairs(addon.MODES) do
		modes = modes ~= "" and modes..L[","].." " or modes
		modes = modes..format(L["%s = %s"],addon.ColorMsg(i,v.color),addon.ColorMsg(tostring(v.name),v.color))
	end
	addon:Msg(L["Help"]..L[":"].." "..format(L["%s [0-%s] - Reports or sets the display mode (%s)."],L["mode"],tostring(#addon.MODES),modes))
end
--- [ Class mode command handler ]
tinsert(addon.SLASHCMD_INDEX,"class")
function addon.SLASHCMD_HANDLERS.class(cmd)
	if cmd.args and cmd.args[2] ~= nil then
		if cmd.args[2] == L["help"] or cmd.args[1] == L["help"] then
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		elseif tonumber(cmd.args[2]) == nil or (tonumber(cmd.args[2]) > #addon.CLASS_MODES or tonumber(cmd.args[2]) < 0) then
			addon:Msg(format(L["%s is an invalid argument for %s."],tostring(cmd.args[2]),L["class"]),addon.ERROR_LEVEL)
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		else
			addon.settings.classMode = tonumber(cmd.args[2])
			addon:Update(true)
		end
	end
	addon:Msg(L["Class mode"]..L[":"].." "..format(L["%s (%s)."],addon.ColorMsg(tostring(addon.settings.classMode),addon.CLASS_MODES[addon.settings.classMode].color),addon.ColorMsg(tostring(addon.CLASS_MODES[addon.settings.classMode].name),addon.CLASS_MODES[addon.settings.classMode].color)))
end
--- [ Class mode command help handler ]
function addon.SLASHCMD_HELP_HANDLERS.class(cmd)
	local modes = ""
	for i,v in ipairs(addon.CLASS_MODES) do
		modes = modes ~= "" and modes..L[","].." " or modes
		modes = modes..format(L["%s = %s"],addon.ColorMsg(i,v.color),addon.ColorMsg(tostring(v.name),v.color))
	end
	addon:Msg(L["Help"]..L[":"].." "..format(L["%s [0-%s] - Reports or sets the display mode for class frames in auto mode (%s)."],L["class"],tostring(#addon.CLASS_MODES),modes))
end
--- [ Faction mode command handler ]
tinsert(addon.SLASHCMD_INDEX,"faction")
function addon.SLASHCMD_HANDLERS.faction(cmd)
	if cmd.args and cmd.args[2] ~= nil then
		if cmd.args[2] == L["help"] or cmd.args[1] == L["help"] then
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		elseif tonumber(cmd.args[2]) == nil or (tonumber(cmd.args[2]) > #addon.FACTION_MODES or tonumber(cmd.args[2]) < 0) then
			addon:Msg(format(L["%s is an invalid argument for %s."],tostring(cmd.args[2]),L["faction"]),addon.ERROR_LEVEL)
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		else
			addon.settings.factionMode = tonumber(cmd.args[2])
			addon:Update(true)
		end
	end
	addon:Msg(L["Faction mode"]..L[":"].." "..format(L["%s (%s)."],addon.ColorMsg(tostring(addon.settings.factionMode),addon.FACTION_MODES[addon.settings.factionMode].color),addon.ColorMsg(tostring(addon.FACTION_MODES[addon.settings.factionMode].name),addon.FACTION_MODES[addon.settings.factionMode].color)))
end
--- [ Faction mode command help handler ]
function addon.SLASHCMD_HELP_HANDLERS.faction(cmd)
	local modes = ""
	for i,v in ipairs(addon.FACTION_MODES) do
		modes = modes ~= "" and modes..L[","].." " or modes
		modes = modes..format(L["%s = %s"],addon.ColorMsg(i,v.color),addon.ColorMsg(tostring(v.name),v.color))
	end
	addon:Msg(L["Help"]..L[":"].." "..format(L["%s [0-%s] - Reports or sets the faction modifier mode for class frames in auto mode (%s)."],L["faction"],tostring(#addon.FACTION_MODES),modes))
end
--- [ Debug command handler ]
tinsert(addon.SLASHCMD_INDEX,"debug")
function addon.SLASHCMD_HANDLERS.debug(cmd)
	if cmd.args and cmd.args[2] ~= nil then
		if cmd.args[2] == L["help"] or cmd.args[1] == L["help"] then
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		elseif tonumber(cmd.args[2]) == nil or (tonumber(cmd.args[2]) > #addon.DEBUG_LEVELS or tonumber(cmd.args[2]) < 0) then
			addon:Msg(format(L["%s is an invalid argument for %s."],tostring(cmd.args[2]),L["debug"]),addon.ERROR_LEVEL)
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		else
			addon.settings.debug = tonumber(cmd.args[2])
		end
	end
	addon:Msg(L["Debug"]..L[":"].." "..format(L["%s (%s)."],addon.ColorMsg(tostring(addon.settings.debug),addon.DEBUG_LEVELS[addon.settings.debug].color),addon.ColorMsg(tostring(addon.DEBUG_LEVELS[addon.settings.debug].name),addon.DEBUG_LEVELS[addon.settings.debug].color)))
end
--- [ Debug command help handler ]
function addon.SLASHCMD_HELP_HANDLERS.debug(cmd)
	local debugLevels = ""
	for i,v in ipairs(addon.DEBUG_LEVELS) do
		debugLevels = debugLevels ~= "" and debugLevels..L[","].." " or debugLevels
		debugLevels = debugLevels..format(L["%s = %s"],addon.ColorMsg(i,v.color),addon.ColorMsg(tostring(v.name),v.color))
	end
	addon:Msg(L["Help"]..L[":"].." "..format(L["%s [0-%s] - Reports or sets the debug output setting (%s)."],L["debug"],tostring(#addon.DEBUG_LEVELS),debugLevels))
end
--- [ Update command handler ]
tinsert(addon.SLASHCMD_INDEX,"update")
function addon.SLASHCMD_HANDLERS.update(cmd)
	if cmd.args and cmd.args[2] ~= nil then
		if cmd.args[2] == L["help"] or cmd.args[1] == L["help"] then
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		else
			addon:Msg(format(L["%s is an invalid argument for %s."],tostring(cmd.args[2]),L["update"]),addon.ERROR_LEVEL)
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		end
	else
		addon:Update(true)
	end
end
--- [ Update command help handler ]
function addon.SLASHCMD_HELP_HANDLERS.update(cmd)
	addon:Msg(L["Help"]..L[":"].." "..format(L["%s - Manually updates the display."],L["update"]))
end
--- [ Reset command handler ]
tinsert(addon.SLASHCMD_INDEX,"reset")
function addon.SLASHCMD_HANDLERS.reset(cmd)
	if cmd.args and cmd.args[2] ~= nil then
		if cmd.args[2] == L["help"] or cmd.args[1] == L["help"] then
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		else
			addon:Msg(format(L["%s is an invalid argument for %s."],tostring(cmd.args[2]),L["reset"]),addon.ERROR_LEVEL)
			addon.SLASHCMDS[cmd.cmd].helpHandler(cmd)
			return
		end
	else
		addon:Reset()
	end
end
--- [ Reset command help handler ]
function addon.SLASHCMD_HELP_HANDLERS.reset(cmd)
	addon:Msg(L["Help"]..L[":"].." "..format(L["%s - Resets your settings to default."],L["reset"]))
end