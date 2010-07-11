--[[
	iBuffDebuffU Focus Options
	--Code adapted from Tuller's OmniCC Options Panel, (Thanks Tuller)
--]]

local OptionsFocus = CreateFrame('Frame', 'iBuffDebuffUFocusOptionsFrame', InterfaceOptionsFramePanelContainer)
local Options = _G["iBuffDebuffUOptionsFrame"]

function OptionsFocus:Load(parent, addonname)

	self.name, self.parent, self.addonname = addonname, parent, addonname
	self:Hide()
	self:AddDisplayPanel()
	InterfaceOptions_AddCategory(self)
	
end

--[[ Panels ]]--

--Display
function OptionsFocus:AddDisplayPanel()

	local tab1Frame = self:CreateTab1(self)
	local tab2Frame = self:CreateTab2(self)

	local tektab = LibStub("tekKonfig-TopTab")
	local tab1 = tektab.new(self, L_IBDU_TAB_1, "BOTTOMLEFT", self, "TOPLEFT", 190, -4)
	local tab2 = tektab.new(self, L_IBDU_TAB_2, "LEFT", tab1, "RIGHT", -15, 0)
	
	tab2:Deactivate()
	tab1:SetScript("OnClick", function(self)
		self:Activate()
		tab2:Deactivate()
		tab1Frame:Show()
		tab2Frame:Hide()
	end)
	tab2:SetScript("OnClick", function(self)
		self:Activate()
		tab1:Deactivate()
		tab1Frame:Hide()
		tab2Frame:Show()
	end)
	
	tab1Frame:Show()
	tab2Frame:Hide()
	
end

function OptionsFocus:CreateTab1(parent)

	local tabFrame = CreateFrame('Frame', parent:GetName().."Tab1", parent)
	tabFrame:SetAllPoints(parent)

	--Bars grow UP/DOWN
	local growBars = Options:CreateCheckButton(L_IBDU_OPT1, tabFrame)
	growBars:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts["focus"].grow) end)
	growBars:SetScript('OnClick', function(self)
		IBDU_DB.Opts["focus"].grow = self:GetChecked() or false
		iBuffDebuffU:ProcessGrowth_All()
	end)
	growBars:SetPoint('TOPLEFT', 10, -20)

	--use hhmmss format
	local useHHMMSS = Options:CreateCheckButton(L_IBDU_OPT2, tabFrame)
	useHHMMSS:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts["focus"].hhmmss) end)
	useHHMMSS:SetScript('OnClick', function(self)
		IBDU_DB.Opts["focus"].hhmmss = self:GetChecked() or false
	end)
	useHHMMSS:SetPoint('TOP', growBars, 'BOTTOM', 0, -1)
	
	--show rank
	local showRank = Options:CreateCheckButton(L_IBDU_OPT3, tabFrame)
	showRank:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts["focus"].rank) end)
	showRank:SetScript('OnClick', function(self)
		IBDU_DB.Opts["focus"].rank = self:GetChecked() or false
	end)
	showRank:SetPoint('TOP', useHHMMSS, 'BOTTOM', 0, -1)

	--show stacks
	local showStacks = Options:CreateCheckButton(L_IBDU_OPT4, tabFrame)
	showStacks:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts["focus"].stack) end)
	showStacks:SetScript('OnClick', function(self)
		IBDU_DB.Opts["focus"].stack = self:GetChecked() or false
	end)
	showStacks:SetPoint('TOP', showRank, 'BOTTOM', 0, -1)
	
	--show focus buffs
	local showFocusB = Options:CreateCheckButton(L_IBDU_OPT13, tabFrame)
	showFocusB:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts.showfocusBuffs) end)
	showFocusB:SetScript('OnClick', function(self)
		IBDU_DB.Opts.showfocusBuffs = self:GetChecked() or false
		iBuffDebuffU:UNIT_AURA('UNIT_AURA', 'focus')
	end)
	showFocusB:SetPoint('TOP', showStacks, 'BOTTOM', 0, -1)
	
	--show focus debuffs
	local showFocusD = Options:CreateCheckButton(L_IBDU_OPT14, tabFrame)
	showFocusD:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts.showfocusDebuffs) end)
	showFocusD:SetScript('OnClick', function(self)
		IBDU_DB.Opts.showfocusDebuffs = self:GetChecked() or false
		iBuffDebuffU:UNIT_AURA('UNIT_AURA', 'focus')
	end)
	showFocusD:SetPoint('TOP', showFocusB, 'BOTTOM', 0, -1)
	
	return tabFrame
	
end

function OptionsFocus:CreateTab2(parent)

	local tabFrame = CreateFrame('Frame', parent:GetName().."Tab2", parent)
	tabFrame:SetAllPoints(parent)

	local panel = Options:CreatePanel(self, L_IBDU_OPT9, tabFrame)
	panel:SetWidth(392); panel:SetHeight(148)
	panel:SetPoint('TOPLEFT', 10, -30)
	
	local fs_scale = Options:formatSlider(L_IBDU_OPT_SLIDER1, "scale", panel, 1, 5, 0.1, nil, "focus")
	fs_scale:SetPoint('TOPLEFT', 10, -22)

	local fs_width = Options:formatSlider(L_IBDU_OPT_SLIDER2, "width", panel, 200, 600, 1, nil, "focus")
	fs_width:SetPoint('TOPLEFT', fs_scale, 'BOTTOMLEFT', 0, -17)

	local fs_height = Options:formatSlider(L_IBDU_OPT_SLIDER3, "height", panel, 16, 100, 1, nil, "focus")
	fs_height:SetPoint('TOPLEFT', fs_width, 'BOTTOMLEFT', 0, -17)

	local fs_fontsize = Options:formatSlider(L_IBDU_OPT_SLIDER4, "fontSize", panel, 1, 30, 1, nil, "focus")
	fs_fontsize:SetPoint('TOPLEFT', fs_height, 'BOTTOMLEFT', 0, -17)
	
	local fs_alpha = Options:formatSlider(L_IBDU_OPT_SLIDER5, "alpha", panel, 0, 1, 0.099, nil, "focus")
	fs_alpha:SetPoint('TOPRIGHT', -42, -22)

	local fs_bgalpha = Options:formatSlider(L_IBDU_OPT_SLIDER6, "alpha_bg", panel, 0, 1, 0.099, nil, "focus")
	fs_bgalpha:SetPoint('TOPLEFT', fs_alpha, 'BOTTOMLEFT', 0, -17)
	
	local fs_fontalpha = Options:formatSlider(L_IBDU_OPT_SLIDER7, "alpha_font", panel, 0, 1, 0.099, nil, "focus")
	fs_fontalpha:SetPoint('TOPLEFT', fs_bgalpha, 'BOTTOMLEFT', 0, -17)
	
	local fs_bdistance = Options:formatSlider(L_IBDU_OPT_SLIDER8, "bufferdist", panel, 0, 20, 1, nil, "focus")
	fs_bdistance:SetPoint('TOPLEFT', fs_fontalpha, 'BOTTOMLEFT', 0, -17)
	
	--panel two
	local panel2 = Options:CreatePanel(self, L_IBDU_OPT17, tabFrame)
	panel2:SetWidth(392); panel2:SetHeight(75)
	panel2:SetPoint('TOPLEFT', panel, 'BOTTOMLEFT', 0, -17)
	
	local colorUnit = "focus"
	
	--[BUFF COLOR]
	local color1 = Options:CreateColorSelector("Color1", panel2)
	color1.OnSetColor = function(self, r, g, b)
		if IBDU_DB.Opts[colorUnit.."BuffColor"] then
			local sf = IBDU_DB.Opts[colorUnit.."BuffColor"]
			sf.r, sf.g, sf.b = r, g, b
		end
	end
	color1.GetColor = function(self)
		if IBDU_DB.Opts[colorUnit.."BuffColor"] then
			local sf = IBDU_DB.Opts[colorUnit.."BuffColor"]
			return sf.r, sf.g, sf.b
		else
			return 0,0,0
		end
	end
	color1.text:SetText(L_IBDU_OPT_COLOR5)
	color1:SetPoint('TOPLEFT', 10, -15)

	--[DEBUFF COLOR]
	local color2 = Options:CreateColorSelector("Color2", panel2)
	color2.OnSetColor = function(self, r, g, b)
		if IBDU_DB.Opts[colorUnit.."DebuffColor"] then
			local sf = IBDU_DB.Opts[colorUnit.."DebuffColor"]
			sf.r, sf.g, sf.b = r, g, b
		end
	end
	color2.GetColor = function(self)
		if IBDU_DB.Opts[colorUnit.."DebuffColor"] then
			local sf = IBDU_DB.Opts[colorUnit.."DebuffColor"]
			return sf.r, sf.g, sf.b
		else
			return 0,0,0
		end
	end
	color2.text:SetText(L_IBDU_OPT_COLOR6)
	color2:SetPoint('TOPLEFT', color1, 'BOTTOMLEFT', 0, -15)
	
	return tabFrame
	
end

OptionsFocus:Load('iBuffDebuffU', L_IBDU_PANEL_3)