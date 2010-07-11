--IBUFFDEBUFFU: Created by Xruptor

local timersTarget = {}
local timersPlayer = {}
local timersFocus = {}
local targetGUID = 0
local focusGUID = 0
local playerGUID = 0
local timerCount = 0
local UnitAura = _G.UnitAura
local UnitIsUnit = _G.UnitIsUnit
local UnitName = _G.UnitName
local gratuity = LibStub("LibGratuity-3.0")
local sharedMedia = LibStub("LibSharedMedia-3.0")

local f = CreateFrame("frame","iBuffDebuffU",UIParent)
f:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

f:SetScript("OnUpdate", function(self, elapsed)
	timerCount = timerCount + elapsed
	if timerCount > 0.1 then
		self:SortBarsAll()
		timerCount = 0
	end
end)

----------------------
--      Enable      --
----------------------

local barDefaults = {
		["scale"] = 1,
		["grow"] = true,
		["width"] = 200,
		["height"] = 16,
		["fontSize"] = 12,
		["alpha"] = 1,
		["alpha_bg"] = 0.5,
		["alpha_font"] = 1,
		["tooltips"] = false,
		["rank"] = false,
		["stack"] = true,
		["bufferdist"] = 4, --distance between bars
		["hhmmss"] = false,
		['totalBuffCount'] = 40,
		['totalDebuffCount'] = 40,
		['limitTime'] = 0,
}

local defaults = {
	["Opts"] = {
		["hideblizzbuffs"] = true,
		["showplayerBuffs"] = true,
		["showplayerDebuffs"] = true,
		["showtargetBuffs"] = true,
		["showtargetDebuffs"] = true,
		["showfocusBuffs"] = true,
		["showfocusDebuffs"] = true,
		['playerDebuffColoring'] = false,
		['playerCastBuffOnly'] = false,
		["enable"] = true,
		["player"] = barDefaults,
		["target"] = barDefaults,
		["focus"] = barDefaults,
		["playerBuffColor"] = {r=0, g=183/255, b=239/255},
		["playerDebuffColor"] = {r=1, g=0, b=0},
		["targetBuffColor"] = {r=0, g=1, b=0},
		["targetDebuffColor"] = {r=1, g=0, b=0},
		["focusBuffColor"] = {r=0, g=1, b=0},
		["focusDebuffColor"] = {r=1, g=0, b=0},
		["statusbar"] = "Minimalist",
		["font"] = "Friz Quadrata TT",
	},
}
	
function f:PLAYER_LOGIN()
	
	local ver = tonumber(GetAddOnMetadata("iBuffDebuffU","Version")) or 'Unknown'
	
	IBDU_DB = IBDU_DB or defaults

	--update the database
	for k, v in pairs(defaults.Opts) do
		if IBDU_DB.Opts[k] == nil then
			IBDU_DB.Opts[k] = v
		elseif type(v) == 'table' and IBDU_DB.Opts[k] then
			for x, y in pairs(v) do
				if IBDU_DB.Opts[k][x] == nil then
					IBDU_DB.Opts[k][x] = y
				end
			end
		end
	end
	--fix a stupid old font glitch from previous versions
	if IBDU_DB.Opts.font == "Fonts\\FRIZQT__.TTF" then IBDU_DB.Opts.font = "Friz Quadrata TT" end
	
	playerGUID = UnitGUID("player")
	
	--register events appropriately
	f:ToggleMod_ON_OFF()
	
	--do SharedMedia Stuff and setup the dropdown
	sharedMedia:Register(sharedMedia.MediaType.STATUSBAR, "Minimalist", "Interface\\Addons\\iBuffDebuffU\\media\\Minimalist")
	sharedMedia.RegisterCallback(f, "LibSharedMedia_Registered", "SharedMediaRegister")
	f:SetupDropDown()
	
	--create our anchors
	f:CreateAnchor("IBDU_TargetAnchor", UIParent, "target")
	f:CreateAnchor("IBDU_FocusAnchor", UIParent, "focus")
	f:CreateAnchor("IBDU_PlayerAnchor", UIParent, "player")
	
	--process our stuff the moment we login
	f:ProcessAuras("player", timersPlayer)

	--hide blizzard debuffs if user selected it, to turn this back on a reload is required
	if IBDU_DB.Opts.hideblizzbuffs then
		BuffFrame:UnregisterAllEvents()
		BuffFrame:Hide()
		BuffFrame.Show = function() end
		TemporaryEnchantFrame:UnregisterAllEvents()
		TemporaryEnchantFrame:Hide()
		TemporaryEnchantFrame.Show = BuffFrame.Show
	end
	
	SLASH_IBUFFDEBUFFU1 = "/ibuffdebuffu"
	SLASH_IBUFFDEBUFFU2 = "/ibdu"
	SlashCmdList["IBUFFDEBUFFU"] = function(msg)
	
		local a,b,c=strfind(msg, "(%S+)"); --contiguous string of non-space characters
		
		if a then
			if c and c:lower() == L_IBDU_SLASHOPT1 then
				f:ToggleAnchors()
				return true
			elseif c and c:lower() == L_IBDU_SLASHOPT2 then
				InterfaceOptionsFrame_OpenToCategory("iBuffDebuffU")
				return true
			elseif c and c:lower() == L_IBDU_SLASHOPT3 then
				IBDU_DB.Opts.enable = true
				f:ToggleMod_ON_OFF()
				f:ProcessAuras("player", timersPlayer)
				DEFAULT_CHAT_FRAME:AddMessage("|cFF99CC33iBuffDebuffU|r: [|cFF00CC00"..L_IBDU_SLASHOPT3.."|r]")
				return true
			elseif c and c:lower() == L_IBDU_SLASHOPT4 then
				IBDU_DB.Opts.enable = false
				f:ToggleMod_ON_OFF()
				f:ClearBuffs(timersTarget)
				f:ClearBuffs(timersFocus)
				f:ClearBuffs(timersPlayer)
				DEFAULT_CHAT_FRAME:AddMessage("|cFF99CC33iBuffDebuffU|r: [|cFFFF0000"..L_IBDU_SLASHOPT4.."|r]")
				return true
			end
		end

		DEFAULT_CHAT_FRAME:AddMessage("iBuffDebuffU")
		DEFAULT_CHAT_FRAME:AddMessage(L_IBDU_SLASH1)
		DEFAULT_CHAT_FRAME:AddMessage(L_IBDU_SLASH2)
		DEFAULT_CHAT_FRAME:AddMessage(L_IBDU_SLASH3)
		DEFAULT_CHAT_FRAME:AddMessage(L_IBDU_SLASH4)
	end
	
	DEFAULT_CHAT_FRAME:AddMessage("|cFF99CC33iBuffDebuffU|r [v|cFFDF2B2B"..ver.."|r] loaded:   /ibdu")
	
	f:UnregisterEvent("PLAYER_LOGIN")
	f.PLAYER_LOGIN = nil
end

function f:ToggleMod_ON_OFF()
	if IBDU_DB.Opts.enable then
		f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		f:RegisterEvent("PLAYER_TARGET_CHANGED")
		f:RegisterEvent("PLAYER_FOCUS_CHANGED")
		f:RegisterEvent("UNIT_AURA")
	else
		f:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		f:UnregisterEvent("PLAYER_TARGET_CHANGED")
		f:UnregisterEvent("PLAYER_FOCUS_CHANGED")
		f:UnregisterEvent("UNIT_AURA")
	end
end

function f:UNIT_AURA(event, unit)
	if not unit then return end
	if unit == "target" and UnitGUID(unit) and UnitGUID(unit) == targetGUID then
		f:ProcessAuras("target", timersTarget)
	elseif unit == "focus" and UnitGUID(unit) and UnitGUID(unit) == focusGUID then
		f:ProcessAuras("focus", timersFocus)
	elseif unit == "player" and UnitGUID(unit) and UnitGUID(unit) == playerGUID then
		f:ProcessAuras("player", timersPlayer)
	end
end
	
function f:PLAYER_TARGET_CHANGED()
	--check if were targetting ourself, if not then display
	if UnitName("target") and UnitGUID("target") and UnitGUID("target") ~= playerGUID then
		targetGUID = UnitGUID("target")
		f:ProcessAuras("target", timersTarget)
	else
		f:ClearBuffs(timersTarget)
		targetGUID = 0
	end
end

function f:PLAYER_FOCUS_CHANGED()
	--check to see if we made ourself the focus, if so then ignore it
	if UnitName("focus") and UnitGUID("focus") and UnitGUID("focus") ~= playerGUID then
		focusGUID = UnitGUID("focus")
		f:ProcessAuras("focus", timersFocus)
	else
		f:ClearBuffs(timersFocus)
		focusGUID = 0
	end
end

function f:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellName, spellID, spellSchool, auraType, amount)

	if eventType == "UNIT_DIED" or eventType == "UNIT_DESTROYED" then
		if dstGUID == targetGUID then
			f:ClearBuffs(timersTarget)
			targetGUID = 0
		end
		if dstGUID == focusGUID then
			f:ClearBuffs(timersFocus)
			focusGUID = 0
		end
    end
end

----------------------
-- DropDown Creation -
----------------------

function f:SharedMediaRegister(event, mediaType, key)
	if( mediaType == sharedMedia.MediaType.STATUSBAR or mediaType == sharedMedia.MediaType.FONT ) then
		--update the dropdown for newly registered media types
		f:SetupDropDown()
	end
end

function f:SetupDropDown()

	--close the dropdown menu if shown
	if f.DD and f.DD:IsShown() then
		CloseDropDownMenus()
	end

	local dd1 = LibStub('LibXMenu-1.0'):New("iBuffDebuffU_DD", IBDU_DB.Opts)
	dd1.initialize = function(self, lvl)
		if lvl == 1 then
			self:AddList(lvl, L_IBDU_OPT19, "font")
			self:AddList(lvl, L_IBDU_OPT20, "statusbar")
			self:AddCloseButton(lvl,  L_IBDU_OPT21)
		elseif lvl and lvl > 1 then
			local sub = UIDROPDOWNMENU_MENU_VALUE
			if sub == sharedMedia.MediaType.STATUSBAR or sub == sharedMedia.MediaType.FONT then
				local t = sharedMedia:List(sub)
				local starti = 20 * (lvl - 2) + 1
				local endi = 20 * (lvl - 1)
				for i = starti, endi, 1 do
					if not t[i] then break end
					self:AddSelect(lvl, t[i], t[i], sub)
					if i == endi and t[i + 1] then
						self:AddList(lvl, L_IBDU_OPT22, sub)
					end	
				end
			end	
		end
	end
	dd1.doUpdate = function(bOpt)
		f:ModifyApperance_All()
	end
	
	f.DD = dd1
end

----------------------
--  Frame Creation  --
----------------------

function f:CreateAnchor(name, parent, unit)

	--create the anchor
	local frameAnchor = CreateFrame("Frame", name, parent)
	
	frameAnchor:SetWidth(IBDU_DB.Opts[unit].width + 10)
	frameAnchor:SetHeight(IBDU_DB.Opts[unit].height + 10)
	frameAnchor:SetMovable(true)
	frameAnchor:SetClampedToScreen(true)
	frameAnchor:EnableMouse(true)
	
	frameAnchor:ClearAllPoints()
	frameAnchor:SetPoint("CENTER", parent, "CENTER", 0, 0)
	frameAnchor:SetFrameStrata("DIALOG")
	
	frameAnchor:SetBackdrop({
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	
	frameAnchor:SetBackdropColor(0.75,0,0,1)
	frameAnchor:SetBackdropBorderColor(0.75,0,0,1)
	
	local stringT = frameAnchor:CreateFontString()
	stringT:SetAllPoints(frameAnchor)
	stringT:SetFontObject("GameFontNormalSmall")
	stringT:SetText(unit..L_IBDU_ANCHOR)
	
	frameAnchor:SetScript("OnMouseDown", function(frame, button)
		if button == "RightButton" then
			frame.isMoving = nil
			frame:StopMovingOrSizing()
			f:SaveLayout(frame:GetName())
			f:ToggleAnchors(frame)
		else
			frame:IsMovable()
			frame.isMoving = true
			frame:StartMoving()
		end
	end)

	frameAnchor:SetScript("OnMouseUp", function(frame, button)
		frame.isMoving = nil
		frame:StopMovingOrSizing()
		f:SaveLayout(frame:GetName())
	end)

	frameAnchor:Hide() -- hide it by default
	
	f:RestoreLayout(name)
end
			
local TimerOnUpdate = function(self, time)

	if self.active then
		local beforeEnd = (self.expTime or 0) - GetTime()

		if self.duration > 0 and beforeEnd <= 0 then
			self.active = false
			self:Hide()
			return               
		end
		
		--set the bar value, check for non-terminating auras
		if self.duration > 0 then
			self:SetValue(beforeEnd)
		else
			--it's an aura or permenate buff, set it as a transparent value, do it doesn't get confused
			--with other buffs
			self:SetValue(0)
		end
		
		--set the bar text, lets check the width first and fix it if necessary so that text doesn't overlap
		local wChk = ceil(IBDU_DB.Opts[self.id].width - (self.timer:GetStringWidth() + 10))
		if ceil(self.text:GetWidth()) > wChk then
			self.text:SetWidth(wChk)
		end
		
		self.text:SetText(f:SetBarText(self.id, self.spellName, self.rank, self.stacks))
		self.timer:SetText(f:GetTimeText(self.id, beforeEnd))
	end
	
end

function f:CreateTimers(unit)
	
	local textureSML = sharedMedia:Fetch(sharedMedia.MediaType.STATUSBAR, IBDU_DB.Opts.statusbar)
	local fontSML = sharedMedia:Fetch(sharedMedia.MediaType.FONT, IBDU_DB.Opts.font)
	
	local Frm = CreateFrame("StatusBar", nil, UIParent)
	Frm:SetClampedToScreen(true)
	Frm:SetMovable(false)
	Frm:SetWidth(IBDU_DB.Opts[unit].width)
	Frm:SetHeight(IBDU_DB.Opts[unit].height)
	Frm:SetStatusBarTexture(textureSML)
	Frm:SetStatusBarColor(1, 1, 1, IBDU_DB.Opts[unit].alpha)
	Frm:SetAlpha(IBDU_DB.Opts[unit].alpha)
	Frm:EnableMouse(true)

	Frm.bg = CreateFrame("StatusBar", nil, Frm)
	Frm.bg:SetMinMaxValues(0, 1)
	Frm.bg:SetValue(1)
	Frm.bg:SetAllPoints(Frm)
	Frm.bg:SetFrameLevel(0)
	Frm.bg:SetStatusBarTexture(textureSML)
	Frm.bg:SetStatusBarColor(1, 1, 1, IBDU_DB.Opts[unit].alpha_bg)
	Frm.bg:SetAlpha(IBDU_DB.Opts[unit].alpha_bg)
	Frm.bg:EnableMouse(true)

	--icon
	Frm.icon = Frm:CreateTexture(nil, "ARTWORK")
	Frm.icon:SetPoint("TOPLEFT", Frm, "TOPLEFT", -IBDU_DB.Opts[unit].height, 0)
	Frm.icon:SetHeight(IBDU_DB.Opts[unit].height)
	Frm.icon:SetWidth(IBDU_DB.Opts[unit].height)
	Frm.icon:SetTexture("Interface\\Icons\\Spell_Shadow_Shadowbolt")
	Frm.icon:SetVertexColor(1, 1, 1, IBDU_DB.Opts[unit].alpha)
	Frm.icon:Show()
	
	Frm.iconBorder = Frm:CreateTexture(nil, "OVERLAY")
	Frm.iconBorder:SetPoint("TOPLEFT", Frm.icon)
	Frm.iconBorder:SetPoint("BOTTOMRIGHT", Frm.icon)
	Frm.iconBorder:SetVertexColor(1, 1, 1, IBDU_DB.Opts[unit].alpha)
	Frm.iconBorder:Show()
	
	--name
	Frm.text = Frm:CreateFontString(nil, "OVERLAY")
	Frm.text:SetJustifyH("LEFT")
	Frm.text:SetJustifyV("CENTER")
	Frm.text:SetPoint("TOPLEFT", Frm, "TOPLEFT", 2, 0)
	Frm.text:SetHeight(IBDU_DB.Opts[unit].height)
	Frm.text:SetWidth(IBDU_DB.Opts[unit].width)
	Frm.text:SetFont(fontSML, IBDU_DB.Opts[unit].fontSize)
	Frm.text:SetShadowOffset(1, -1)
	Frm.text:SetShadowColor(0, 0, 0, 1)
	Frm.text:SetAlpha(IBDU_DB.Opts[unit].alpha_font)
	
	--timer
	Frm.timer = Frm:CreateFontString(nil, "OVERLAY")
	Frm.timer:SetJustifyH("RIGHT")
	Frm.timer:SetJustifyV("CENTER")
	Frm.timer:SetPoint("TOPRIGHT", Frm, "TOPRIGHT", -1, 0)
	Frm.timer:SetHeight(IBDU_DB.Opts[unit].height)
	Frm.timer:SetFont(fontSML, IBDU_DB.Opts[unit].fontSize)
	Frm.timer:SetShadowOffset(1, -1)
	Frm.timer:SetShadowColor(0, 0, 0, 1)
	Frm.timer:SetAlpha(IBDU_DB.Opts[unit].alpha_font)
	
	--this is to allow tooltips on the statusbar
	Frm:SetScript("OnEnter", function(self)
		if self.id and self.id == "player" then
			if self.auraType and self.auraID and IBDU_DB.Opts[self.id].tooltips then
				GameTooltip:SetOwner(self, "ANCHOR_LEFT")
				if( self.auraType == "buff" ) then
					if self.itemLink then
						--enchant
						GameTooltip:SetInventoryItem("player", self.auraID)
					else
						GameTooltip:SetUnitBuff(self.id, self.auraID)
					end
				elseif( self.auraType == "debuff") then
					GameTooltip:SetUnitDebuff(self.id, self.auraID)
				end
				GameTooltip:Show()
			end
		end
	end)
	Frm:SetScript("OnLeave",function(self)
		GameTooltip:Hide()
	end)
	
	--this will allow right click canceling of buffs, obviously ignore debuffs
	--weapon enchants are different and require a seperate function to remove it
	Frm:SetScript("OnMouseUp", function(self, button)
		if self.id == "player" and self.active and button == "RightButton" then
			if not self.enchant and self.auraID and self.auraType == "buff" then
				self.active = false
				self:Hide()
				CancelUnitBuff("player", self.auraID)
			elseif self.enchant and self.spellId and self.auraType == "buff" then
				if self.spellId == 1 then f.enhMH = true end
				if self.spellId == 2 then f.enhOH = true end
				self.active = false
				self:Hide()
				CancelItemTempEnchantment(self.spellId)
			end
		end
	end)
	
	Frm:SetScale(tonumber(IBDU_DB.Opts[unit].scale))
    Frm:SetScript("OnUpdate", TimerOnUpdate)
	Frm:Hide()
    
	return Frm
end

----------------------
-- Buff Functions --
----------------------

function f:PassChk(auraType, unit, index, unitCaster, duration)
	local passNow = false
	
	if auraType == "buff" then
	
		--set true
		if unit == "player" then
			if not IBDU_DB.Opts.playerCastBuffOnly then
				passNow = true
			elseif IBDU_DB.Opts.playerCastBuffOnly and unitCaster and unitCaster == "player" then
				passNow = true
			end
		end
		
		--set false
		if unit == "player" and (index + 1) > IBDU_DB.Opts[unit].totalBuffCount then passNow = false end
		if unit == "player" and IBDU_DB.Opts[unit].limitTime > 0 then
			--check for never-ending buffs
			if duration < 1 then
				passNow = false
			elseif duration > IBDU_DB.Opts[unit].limitTime then
				passNow = false
			end
		end
		
		--if target and focus then check for unitcaster, if it's the player then allow
		if unit ~= "player" and unitCaster and unitCaster == "player" then passNow = true end
		
	elseif auraType == "debuff" then
	
		if unit == "player" then passNow = true end
		if unit == "player" and (index + 1) > IBDU_DB.Opts[unit].totalDebuffCount then passNow = false end
		--if target and focus then check for unitcaster, if it's the player then allow
		if unit ~= "player" and unitCaster and unitCaster == "player" then passNow = true end	
		
	end
	
	return passNow
end

function f:ProcessAuras(unit, sdTimer)
	if not IBDU_DB.Opts.enable then return end
	
	local bData = {}
	local index = 0
	local filter
	local pass = false
	local passD = false
		
	--BUFFS
	filter = 'HELPFUL'
	if unit == "player" and IBDU_DB.Opts.showplayerBuffs then pass = true end
	if unit == "target" and IBDU_DB.Opts.showtargetBuffs then pass = true end
	if unit == "focus" and IBDU_DB.Opts.showfocusBuffs then pass = true end

	if pass then
		for i=1, 40 do
			local name, rank, icon, count, dType, duration, expTime, unitCaster, _, _, spellId = UnitAura(unit, i, filter)
			if name then
				
				local passNow = f:PassChk("buff", unit, index, unitCaster, duration)

				if passNow then
					index = index + 1
					bData[index] = {}
					bData[index].auraType = "buff"
					bData[index].dType = dType
					bData[index].id = unit
					bData[index].auraID = i
					bData[index].spellName = name
					bData[index].rank = rank
					bData[index].iconTex = icon
					bData[index].stacks = count or 0
					bData[index].duration = duration or 0
					bData[index].expTime = expTime
					bData[index].startTime = expTime and duration and max(0, expTime - duration) or 0
					bData[index].timeleft = expTime and max(0, expTime - GetTime()) or 0
					bData[index].lastUpdate = GetTime()
					bData[index].unitCaster = unitCaster
					bData[index].spellId = spellId
					bData[index].active = true
				end
			else
				break
			end
		end
	end
	
	--DEBUFFS
	filter = 'HARMFUL'
	if unit == "player" and IBDU_DB.Opts.showplayerDebuffs then passD = true end
	if unit == "target" and IBDU_DB.Opts.showtargetDebuffs then passD = true end
	if unit == "focus" and IBDU_DB.Opts.showfocusDebuffs then passD = true end

	if passD then
		for i=1, 40 do
			local name, _, icon, count, dType, duration, expTime, unitCaster, _, _, spellId = UnitAura(unit, i, filter)
			if name then
				
				local passNow = f:PassChk("debuff", unit, index, unitCaster, duration)

				if passNow then
					index = index + 1
					bData[index] = {}
					bData[index].auraType = "debuff"
					bData[index].dType = dType
					bData[index].id = unit
					bData[index].auraID = i
					bData[index].spellName = name
					bData[index].rank = rank
					bData[index].iconTex = icon
					bData[index].stacks = count or 0
					bData[index].duration = duration or 0
					bData[index].expTime = expTime
					bData[index].startTime = expTime and duration and max(0, expTime - duration) or 0
					bData[index].timeleft = expTime and max(0, expTime - GetTime()) or 0
					bData[index].lastUpdate = GetTime()
					bData[index].unitCaster = unitCaster
					bData[index].spellId = spellId
					bData[index].active = true
				end
			else
				break
			end
		end
	end
	
	--process enchants
	if pass and unit == "player" then
		local hasMHEnh, MHExpry, MHCharges, hasOHEnh, OHExpry, OHCharges = GetWeaponEnchantInfo()
		if hasMHEnh or hasOHEnh then
			f:ProcessEnchants(unit, sdTimer, bData, index)
		else
			f.enhMH = nil
			f.enhOH = nil
		end
	end

	--load our data into aura bars
	f:LoadAuraBars(unit, sdTimer, bData)
end

function f:ProcessEnchants(unit, sdTimer, bData, index)

	local hasMHEnh, MHExpry, MHCharges, hasOHEnh, OHExpry, OHCharges = GetWeaponEnchantInfo()
	
	--CancelItemTempEnchantment(slot)
	--1 = Main Hand
	--2 = Off Hand 
	--will use spellID

	if ( hasMHEnh and not f.enhMH) then
		local INVSLOT_MAINHAND = GetInventorySlotInfo("MainHandSlot")
		local totalExp = MHExpry / 1000
		local duration = totalExp
		local expTime = totalExp + GetTime()
		
		local itemLink = GetInventoryItemLink('player', INVSLOT_MAINHAND)
		local mainHandName, mainHandRank = f:GetTempBuffName(INVSLOT_MAINHAND)
		local name = mainHandName or GetItemInfo(itemLink) or 'Unknown'
		local icon = GetInventoryItemTexture("player", INVSLOT_MAINHAND) or "Interface\\Icons\\INV_Misc_QuestionMark"
		
		local passNow = f:PassChk("buff", unit, index, "player", duration)
				
		if passNow then
			index = index + 1
			bData[index] = {}
			bData[index].auraType = "buff"
			bData[index].itemLink = itemLink
			bData[index].enchant = true
			bData[index].id = unit
			bData[index].auraID = INVSLOT_MAINHAND
			bData[index].spellName = name
			bData[index].rank = mainHandRank or '*'
			bData[index].iconTex = icon
			bData[index].stacks = MHCharges or 0
			bData[index].duration = duration or 0
			bData[index].expTime = expTime
			bData[index].startTime = expTime and duration and max(0, expTime - duration) or 0
			bData[index].timeleft = expTime and max(0, expTime - GetTime()) or 0
			bData[index].lastUpdate = GetTime()
			bData[index].unitCaster = 'player'
			bData[index].spellId = 1
			bData[index].active = true
		end
	end

	if ( hasOHEnh and not f.enhOH) then
		local INVSLOT_SECONDHAND = GetInventorySlotInfo("SecondaryHandSlot")
		local totalExp = OHExpry / 1000
		local duration = totalExp
		local expTime = totalExp + GetTime()
		
		local itemLink = GetInventoryItemLink('player', INVSLOT_SECONDHAND)
		local offHandName, offHandRank = f:GetTempBuffName(INVSLOT_SECONDHAND)
		local name = offHandName or GetItemInfo(itemLink) or 'Unknown'
		local icon = GetInventoryItemTexture("player", INVSLOT_SECONDHAND) or "Interface\\Icons\\INV_Misc_QuestionMark"
		
		local passNow = f:PassChk("buff", unit, index, "player", duration)
		
		if passNow then
			index = index + 1
			bData[index] = {}
			bData[index].auraType = "buff"
			bData[index].itemLink = itemLink
			bData[index].enchant = true
			bData[index].id = unit
			bData[index].auraID = INVSLOT_SECONDHAND
			bData[index].spellName = name
			bData[index].rank = offHandRank or '*'
			bData[index].iconTex = icon
			bData[index].stacks = OHCharges or 0
			bData[index].duration = duration or 0
			bData[index].expTime = expTime
			bData[index].startTime = expTime and duration and max(0, expTime - duration) or 0
			bData[index].timeleft = expTime and max(0, expTime - GetTime()) or 0
			bData[index].lastUpdate = GetTime()
			bData[index].unitCaster = 'player'
			bData[index].spellId = 2
			bData[index].active = true
		end
	end
	
	f.enhMH = nil
	f.enhOH = nil
end

function f:LoadAuraBars(unit, sdTimer, bData)
	--boolean to prevent errors in sorting
	f.LoadingBars = true
	
	--if we need more timers then add them
	if #sdTimer < #bData then
		for x = (#sdTimer + 1), #bData do
			sdTimer[x] = f:CreateTimers(unit)
		end
	elseif #sdTimer > #bData then
		--remove bars in reverse
		for i = #sdTimer, (#bData + 1), -1 do
			if sdTimer[i] then
				sdTimer[i].active = false
				sdTimer[i]:Hide()
				table.remove(sdTimer, i)
			end
		end
	end

	--sort by auratype then by exptime (percent of bar rather then time remaining)
    table.sort(bData, function(a, b)
		if a.auraType > b.auraType then
			return true;
		elseif a.auraType == b.auraType then
			if( a.duration < 1 and b.duration < 1 ) then
				return a.spellName < b.spellName;
			elseif( b.duration < 1 ) then
				return true;
			end
			return ((max(0, a.expTime - GetTime()) / a.duration) * 100) < ((max(0, b.expTime - GetTime()) / b.duration) * 100);
		end
	end)
	
	--add the information to the timers, turn off inactive ones
	for i=1, #sdTimer do
		if bData[i] and bData[i].active then
			sdTimer[i].auraType = bData[i].auraType
			sdTimer[i].dType = bData[i].dType or nil
			sdTimer[i].itemLink = bData[i].itemLink or nil
			sdTimer[i].enchant = bData[i].enchant or nil
			sdTimer[i].id = bData[i].id
			sdTimer[i].auraID = bData[i].auraID
			sdTimer[i].spellName = bData[i].spellName
			sdTimer[i].rank = bData[i].rank
			sdTimer[i].iconTex = bData[i].iconTex
			sdTimer[i].stacks = bData[i].stacks
			sdTimer[i].duration = bData[i].duration
			sdTimer[i].expTime = bData[i].expTime
			sdTimer[i].startTime = bData[i].startTime
			sdTimer[i].timeleft = bData[i].timeleft
			sdTimer[i].lastUpdate = bData[i].lastUpdate
			sdTimer[i].unitCaster = bData[i].unitCaster
			sdTimer[i].spellId = bData[i].spellId
			sdTimer[i].active = bData[i].active
			sdTimer[i].icon:SetTexture(bData[i].iconTex)

			--set the values for the bar
			if bData[i].duration > 0 then
				sdTimer[i]:SetMinMaxValues(0, bData[i].duration)
			else
				--it's an aura or permenate buff, put it from 0 to 1.
				sdTimer[i]:SetMinMaxValues(0, 1)
			end
			
			--set the bar text
			sdTimer[i].text:SetText(f:SetBarText(unit, bData[i].spellName, bData[i].rank, bData[i].stacks))
			sdTimer[i].timer:SetText(f:GetTimeText(unit, bData[i].duration))

			local color = {}
			if unit == "player" and IBDU_DB.Opts.playerDebuffColoring and bData[i].dType and DebuffTypeColor[bData[i].dType] and bData[i].auraType == "debuff" then
				color = DebuffTypeColor[bData[i].dType]
			elseif bData[i].auraType == "buff" then
				color = IBDU_DB.Opts[unit.."BuffColor"]
			else
				color = IBDU_DB.Opts[unit.."DebuffColor"]
			end

			sdTimer[i].icon:SetTexture(bData[i].iconTex)
			sdTimer[i].icon:SetVertexColor(1, 1, 1, IBDU_DB.Opts[unit].alpha)
			sdTimer[i].iconBorder:SetVertexColor(color.r, color.g, color.b, IBDU_DB.Opts[unit].alpha)

			sdTimer[i]:SetStatusBarColor(color.r, color.g, color.b, IBDU_DB.Opts[unit].alpha)
			sdTimer[i].bg:SetStatusBarColor(color.r, color.g, color.b, IBDU_DB.Opts[unit].alpha_bg or 0)
			
			--before we display make sure the clickables are set only for the player
			if unit == "player" then
				sdTimer[i]:EnableMouse(true)
				sdTimer[i].bg:EnableMouse(true)
			else
				sdTimer[i]:EnableMouse(false)
				sdTimer[i].bg:EnableMouse(false)
			end
			if not sdTimer[i]:IsVisible() then sdTimer[i]:Show() end
		end
	end
	
	f.LoadingBars = nil
end

function f:ClearBuffs(sdTimer)
	for i=1, #sdTimer do
		sdTimer[i].active = false
		sdTimer[i].timer:SetText('')
		sdTimer[i].text:SetText('')
		sdTimer[i].icon:SetTexture(nil)
		if sdTimer[i]:IsVisible() then sdTimer[i]:Hide() end
	end
end

----------------------
-- Local Functions  --
----------------------

local roman_to_arabic = setmetatable({I = 1, V = 5, X = 10, L = 50, C = 100, D = 500, M = 1000}, {__index=function(self, roman)
	local arabic = 0
	local maxval = 0
	for i = roman:len(), 1, -1 do
		local digitval = self[roman:sub(i,i)]
		if digitval < maxval then
			arabic = arabic - digitval
		else
			arabic = arabic + digitval
			maxval = digitval
		end
	end
	self[roman] = arabic
	return arabic
end})

function f:GetTempBuffName(slot)
	local rank
	gratuity:SetInventoryItem("player", slot)
	local _, _, buffname = gratuity:Find("^(.+) %(%d+ [^%)]+%)$")
	if buffname then
		buffname = string.gsub(buffname, " %(%d+ [^%)]+%)", "") -- remove 2nd brackets for buffs with charges
		local tname, trank = strmatch(buffname, "(.*) (%d*)$")
		if tname then
			buffname = tname
			rank = trank
		else
			local tname, trank = strmatch(buffname, "(.*) ([CDILMVX]*)$")
			if tname then
				buffname = tname
				rank = roman_to_arabic[trank]
			end
		end
		return buffname, rank
	end
	local itemlink = GetInventoryItemLink("player", slot)
	if itemlink then
		local name = GetItemInfo(itemlink)
		return name or "Weapon "..slot
	end
	return "Weapon "..slot
end

function f:ToggleAnchors(frame)

	if not frame then
		if IBDU_TargetAnchor:IsVisible() then
			IBDU_TargetAnchor:Hide()
			IBDU_FocusAnchor:Hide()
			IBDU_PlayerAnchor:Hide()
		else
			IBDU_TargetAnchor:Show()
			IBDU_FocusAnchor:Show()
			IBDU_PlayerAnchor:Show()
		end
	else
		if frame:IsVisible() then
			frame:Hide()
		else
			frame:Show()
		end
	end
end

function f:ProcessGrowth_All()
	f:ProcessGrowth("target", timersTarget)
	f:ProcessGrowth("focus", timersFocus)
	f:ProcessGrowth("player", timersPlayer)
end

function f:ProcessGrowth(unit, sdTimer)
	local anchor
	if unit == "target" then anchor = "IBDU_TargetAnchor" end
	if unit == "focus" then anchor = "IBDU_FocusAnchor" end
	if unit == "player" then anchor = "IBDU_PlayerAnchor" end
	if not anchor then return end
	
	for i=1, #sdTimer do
		if IBDU_DB.Opts[unit].grow then
			--grow upwards
			sdTimer[i]:ClearAllPoints()
			
			if( i > 1 ) then
				sdTimer[i]:SetPoint("BOTTOMLEFT", sdTimer[i - 1], "TOPLEFT", 0, IBDU_DB.Opts[unit].bufferdist)
			else
				sdTimer[i]:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, IBDU_DB.Opts[unit].bufferdist)
			end
		else
			--grow downwards
			sdTimer[i]:ClearAllPoints()

			if( i > 1 ) then
				sdTimer[i]:SetPoint("TOPLEFT", sdTimer[i - 1], "BOTTOMLEFT", 0, -IBDU_DB.Opts[unit].bufferdist)
			else
				sdTimer[i]:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -IBDU_DB.Opts[unit].bufferdist)
			end
		end
	end
end

function f:ModifyApperance_All()
	f:ModifyApperance("target", timersTarget)
	f:ModifyApperance("focus", timersFocus)
	f:ModifyApperance("player", timersPlayer)
	f:ProcessGrowth_All()
end

function f:ModifyApperance(unit, sdTimer)
	
	local textureSML = sharedMedia:Fetch(sharedMedia.MediaType.STATUSBAR, IBDU_DB.Opts.statusbar)
	local fontSML = sharedMedia:Fetch(sharedMedia.MediaType.FONT, IBDU_DB.Opts.font)
	
	for i=1, #sdTimer do
		
		--set normal bars
		sdTimer[i]:SetWidth(IBDU_DB.Opts[unit].width)
		sdTimer[i]:SetHeight(IBDU_DB.Opts[unit].height)
		sdTimer[i]:SetAlpha(IBDU_DB.Opts[unit].alpha)
		sdTimer[i]:SetStatusBarTexture(textureSML)
		
		--set bg alpha
		sdTimer[i].bg:SetAlpha(IBDU_DB.Opts[unit].alpha_bg)
		sdTimer[i].bg:SetStatusBarTexture(textureSML)
		
		--icon
		sdTimer[i].icon:ClearAllPoints()
		sdTimer[i].icon:SetPoint("TOPLEFT", sdTimer[i], "TOPLEFT", -IBDU_DB.Opts[unit].height, 0)
		sdTimer[i].icon:SetHeight(IBDU_DB.Opts[unit].height)
		sdTimer[i].icon:SetWidth(IBDU_DB.Opts[unit].height)
		
		sdTimer[i].iconBorder:ClearAllPoints()
		sdTimer[i].iconBorder:SetPoint("TOPLEFT", sdTimer[i].icon)
		sdTimer[i].iconBorder:SetPoint("BOTTOMRIGHT", sdTimer[i].icon)

		--name
		sdTimer[i].text:ClearAllPoints()
		sdTimer[i].text:SetPoint("TOPLEFT", sdTimer[i], "TOPLEFT", 2, 0)
		sdTimer[i].text:SetHeight(IBDU_DB.Opts[unit].height)
		sdTimer[i].text:SetWidth(IBDU_DB.Opts[unit].width)
		sdTimer[i].text:SetFont(fontSML, IBDU_DB.Opts[unit].fontSize)
		sdTimer[i].text:SetAlpha(IBDU_DB.Opts[unit].alpha_font)
		
		--timer
		sdTimer[i].timer:ClearAllPoints()
		sdTimer[i].timer:SetPoint("TOPRIGHT", sdTimer[i], "TOPRIGHT", -1, 0)
		sdTimer[i].timer:SetHeight(IBDU_DB.Opts[unit].height)
		sdTimer[i].timer:SetFont(fontSML, IBDU_DB.Opts[unit].fontSize)
		sdTimer[i].timer:SetAlpha(IBDU_DB.Opts[unit].alpha_font)
		
		sdTimer[i]:SetScale(tonumber(IBDU_DB.Opts[unit].scale))
		
	end
	
end

function f:SortBars(unit, sdTimer)
	if f.LoadingBars then return end
	
	--sort by auratype then by exptime (percent of bar rather then time remaining)
    table.sort(sdTimer, function(a, b)
		if a.auraType > b.auraType then
			return true;
		elseif a.auraType == b.auraType then
			if( a.duration < 1 and b.duration < 1 ) then
				return a.spellName < b.spellName;
			elseif( b.duration < 1 ) then
				return true;
			end
			return ((max(0, a.expTime - GetTime()) / a.duration) * 100) < ((max(0, b.expTime - GetTime()) / b.duration) * 100);
		end
	end)
	
	f:ProcessGrowth(unit, sdTimer) --now rearrange them
end

function f:SortBarsAll()
	f:SortBars("target", timersTarget)
	f:SortBars("focus", timersFocus)
	f:SortBars("player", timersPlayer)
end

function f:SaveLayout(frame)

	if not IBDU_DB then IBDU_DB = {} end

	local opt = IBDU_DB[frame] or nil;

	if opt == nil then
		IBDU_DB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["PosX"] = 0,
			["PosY"] = 0,
		}
		opt = IBDU_DB[frame];
	end

	local f = getglobal(frame);
	local scale = f:GetEffectiveScale();
	opt.PosX = f:GetLeft() * scale;
	opt.PosY = f:GetTop() * scale;
end

function f:RestoreLayout(frame)

	if not IBDU_DB then IBDU_DB = {} end
	
	local f = getglobal(frame);
	local opt = IBDU_DB[frame] or nil;

	if opt == nil then
		IBDU_DB[frame] = {
			["point"] = "CENTER",
			["relativePoint"] = "CENTER",
			["PosX"] = 0,
			["PosY"] = 0,
		}
		opt = IBDU_DB[frame];
	end

	local x = opt.PosX;
	local y = opt.PosY;
	local s = f:GetEffectiveScale();

	if (not x or not y) or (x==0 and y==0) then
		f:ClearAllPoints();
		f:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
		return 
	end

	--calculate the scale
	x,y = x/s,y/s;

	--set the location
	f:ClearAllPoints();
	f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y);

end

function f:GetTimeText(unit, timeLeft)
	local hours, minutes, seconds = 0, 0, 0
	if( timeLeft >= 3600 ) then
		hours = ceil(timeLeft / 3600)
		timeLeft = mod(timeLeft, 3600)
	end

	if( timeLeft >= 60 ) then
		minutes = ceil(timeLeft / 60)
		timeLeft = mod(timeLeft, 60)
	end

	seconds = timeLeft > 0 and timeLeft or 0
	
	if not unit or (IBDU_DB.Opts[unit] and not IBDU_DB.Opts[unit].hhmmss) then
		if hours > 0 then
			return string.format("%dh",hours)
		elseif minutes > 0 then
			return string.format("%dm",minutes)
		elseif seconds > 0 then
			if seconds < 10 then
				return string.format("%.1fs",seconds)
			else
				return string.format("%ds",seconds)
			end
		else
			return nil
		end
	else
		if( hours > 0 ) then
			return string.format("%d:%02d:%02d", hours, minutes, seconds)
		elseif minutes > 0 or seconds > 0 then
			return string.format("%02d:%02d", minutes > 0 and minutes or 0, seconds)
		else
			return nil
		end
	end
	
	return nil
end

function f:SetBarText(unit, name, rank, stack)
	if rank and stack and stack > 0 and IBDU_DB.Opts[unit].rank and IBDU_DB.Opts[unit].stack then
		return string.format("[%s] %s %s", stack, name, rank)
	elseif stack and stack > 0 and IBDU_DB.Opts[unit].stack then
		return string.format("[%s] %s", stack, name)
	elseif rank and IBDU_DB.Opts[unit].rank then
		return string.format("%s %s", name, rank)
	else
		return name
	end
end

function f:round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
	
if IsLoggedIn() then f:PLAYER_LOGIN() else f:RegisterEvent("PLAYER_LOGIN") end
