--[[
	iBuffDebuffU Player Options
	--Code adapted from Tuller's OmniCC Options Panel, (Thanks Tuller)
--]]

local OptionsPlayer = CreateFrame('Frame', 'iBuffDebuffUPlayerOptionsFrame', InterfaceOptionsFramePanelContainer)

function OptionsPlayer:Load(parent, addonname)

	self.name, self.parent, self.addonname = addonname, parent, addonname
	self:Hide()
	self:AddDisplayPanel()
	InterfaceOptions_AddCategory(self)
	
end

function OptionsPlayer:AddDisplayPanel()
	
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

function OptionsPlayer:CreateTab1(parent)

	local tabFrame = CreateFrame('Frame', parent:GetName().."Tab1", parent)
	tabFrame:SetAllPoints(parent)

	--Bars grow UP/DOWN
	local growBars = self:CreateCheckButton(L_IBDU_OPT1, tabFrame)
	growBars:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts["player"].grow) end)
	growBars:SetScript('OnClick', function(self)
		IBDU_DB.Opts["player"].grow = self:GetChecked() or false
		iBuffDebuffU:ProcessGrowth_All()
	end)
	growBars:SetPoint('TOPLEFT', 10, -20)

	--use hhmmss format
	local useHHMMSS = self:CreateCheckButton(L_IBDU_OPT2, tabFrame)
	useHHMMSS:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts["player"].hhmmss) end)
	useHHMMSS:SetScript('OnClick', function(self)
		IBDU_DB.Opts["player"].hhmmss = self:GetChecked() or false
	end)
	useHHMMSS:SetPoint('TOP', growBars, 'BOTTOM', 0, -1)
	
	--show rank
	local showRank = self:CreateCheckButton(L_IBDU_OPT3, tabFrame)
	showRank:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts["player"].rank) end)
	showRank:SetScript('OnClick', function(self)
		IBDU_DB.Opts["player"].rank = self:GetChecked() or false
	end)
	showRank:SetPoint('TOP', useHHMMSS, 'BOTTOM', 0, -1)

	--show stacks
	local showStacks = self:CreateCheckButton(L_IBDU_OPT4, tabFrame)
	showStacks:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts["player"].stack) end)
	showStacks:SetScript('OnClick', function(self)
		IBDU_DB.Opts["player"].stack = self:GetChecked() or false
	end)
	showStacks:SetPoint('TOP', showRank, 'BOTTOM', 0, -1)
	
	--show tooltips
	local showTooltips = self:CreateCheckButton(L_IBDU_OPT5, tabFrame)
	showTooltips:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts["player"].tooltips) end)
	showTooltips:SetScript('OnClick', function(self)
		IBDU_DB.Opts["player"].tooltips = self:GetChecked() or false
	end)
	showTooltips:SetPoint('TOP', showStacks, 'BOTTOM', 0, -1)
	
	--show player buffs
	local showplayerB = self:CreateCheckButton(L_IBDU_OPT6, tabFrame)
	showplayerB:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts.showplayerBuffs) end)
	showplayerB:SetScript('OnClick', function(self)
		IBDU_DB.Opts.showplayerBuffs = self:GetChecked() or false
		iBuffDebuffU:UNIT_AURA('UNIT_AURA', 'player')
	end)
	showplayerB:SetPoint('TOP', showTooltips, 'BOTTOM', 0, -1)
	
	--show player debuffs
	local showPlayerD = self:CreateCheckButton(L_IBDU_OPT7, tabFrame)
	showPlayerD:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts.showplayerDebuffs) end)
	showPlayerD:SetScript('OnClick', function(self)
		IBDU_DB.Opts.showplayerDebuffs = self:GetChecked() or false
		iBuffDebuffU:UNIT_AURA('UNIT_AURA', 'player')
	end)
	showPlayerD:SetPoint('TOP', showplayerB, 'BOTTOM', 0, -1)

	--show player debuffs
	local showPlayerDColor = self:CreateCheckButton(L_IBDU_OPT10, tabFrame)
	showPlayerDColor:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts.playerDebuffColoring) end)
	showPlayerDColor:SetScript('OnClick', function(self)
		IBDU_DB.Opts.playerDebuffColoring = self:GetChecked() or false
		iBuffDebuffU:UNIT_AURA('UNIT_AURA', 'player')
	end)
	showPlayerDColor:SetPoint('TOP', showPlayerD, 'BOTTOM', 0, -1)
	
	return tabFrame
	
end

function OptionsPlayer:CreateTab2(parent)

	local tabFrame = CreateFrame('Frame', parent:GetName().."Tab2", parent)
	tabFrame:SetAllPoints(parent)

	local panel = self:CreatePanel(L_IBDU_OPT9, tabFrame)
	panel:SetWidth(392); panel:SetHeight(148)
	panel:SetPoint('TOPLEFT', 10, -30)
	
	local fs_scale = self:formatSlider(L_IBDU_OPT_SLIDER1, "scale", panel, 1, 5, 0.1)
	fs_scale:SetPoint('TOPLEFT', 10, -22)

	local fs_width = self:formatSlider(L_IBDU_OPT_SLIDER2, "width", panel, 200, 600, 1)
	fs_width:SetPoint('TOPLEFT', fs_scale, 'BOTTOMLEFT', 0, -17)

	local fs_height = self:formatSlider(L_IBDU_OPT_SLIDER3, "height", panel, 16, 100, 1)
	fs_height:SetPoint('TOPLEFT', fs_width, 'BOTTOMLEFT', 0, -17)

	local fs_fontsize = self:formatSlider(L_IBDU_OPT_SLIDER4, "fontSize", panel, 1, 30, 1)
	fs_fontsize:SetPoint('TOPLEFT', fs_height, 'BOTTOMLEFT', 0, -17)
	
	local fs_alpha = self:formatSlider(L_IBDU_OPT_SLIDER5, "alpha", panel, 0, 1, 0.099)
	fs_alpha:SetPoint('TOPRIGHT', -42, -22)

	local fs_bgalpha = self:formatSlider(L_IBDU_OPT_SLIDER6, "alpha_bg", panel, 0, 1, 0.099)
	fs_bgalpha:SetPoint('TOPLEFT', fs_alpha, 'BOTTOMLEFT', 0, -17)
	
	local fs_fontalpha = self:formatSlider(L_IBDU_OPT_SLIDER7, "alpha_font", panel, 0, 1, 0.099)
	fs_fontalpha:SetPoint('TOPLEFT', fs_bgalpha, 'BOTTOMLEFT', 0, -17)
	
	local fs_bdistance = self:formatSlider(L_IBDU_OPT_SLIDER8, "bufferdist", panel, 0, 20, 1)
	fs_bdistance:SetPoint('TOPLEFT', fs_fontalpha, 'BOTTOMLEFT', 0, -17)
	
	--panel two
	local panel2 = self:CreatePanel(L_IBDU_OPT15, tabFrame)
	panel2:SetWidth(392); panel2:SetHeight(130)
	panel2:SetPoint('TOPLEFT', panel, 'BOTTOMLEFT', 0, -17)
	
	local fs_filtertime = self:formatSlider(L_IBDU_OPT_SLIDER9, "limitTime", panel2, 0, 18000, 60, 1)
	fs_filtertime:SetPoint('TOPLEFT', 10, -22)
	
	local fs_totalBuff = self:formatSlider(L_IBDU_OPT_SLIDER10, "totalBuffCount", panel2, 1, 40, 1, 2)
	fs_totalBuff:SetPoint('TOPLEFT', fs_filtertime, 'BOTTOMLEFT', 0, -20)
	
	local fs_totalDebuff = self:formatSlider(L_IBDU_OPT_SLIDER11, "totalDebuffCount", panel2, 1, 40, 1, 2)
	fs_totalDebuff:SetPoint('TOPLEFT', fs_totalBuff, 'BOTTOMLEFT', 0, -20)

	return tabFrame
	
end

--[[
	Widget Templates
--]]

--basic slider
do
	local function Slider_OnMouseWheel(self, arg1)
		local step = self:GetValueStep() * arg1
		local value = self:GetValue()
		local minVal, maxVal = self:GetMinMaxValues()
		
		value = format('%.1f', value) --round it off
		
		if step > 0 then
			self:SetValue(min(value+step, maxVal))
		else
			self:SetValue(max(value+step, minVal))
		end
	end

	function OptionsPlayer:CreateSlider(text, parent, low, high, step, func)
		local name = parent:GetName() .. text
		local slider = CreateFrame('Slider', name, parent, 'OptionsSliderTemplate')
		slider.tFunc = func or nil
		slider:SetScript('OnMouseWheel', Slider_OnMouseWheel)
		slider:SetMinMaxValues(low, high)
		slider:SetValueStep(step)
		slider:EnableMouseWheel(true)
		BlizzardOptionsPanel_Slider_Enable(slider) --colors the slider properly

		getglobal(name .. 'Text'):SetText(text)
		getglobal(name .. 'Low'):SetText('')
		getglobal(name .. 'High'):SetText('')

		local text = slider:CreateFontString(nil, 'BACKGROUND')
		text:SetFontObject('GameFontHighlightSmall')
		text:SetPoint('LEFT', slider, 'RIGHT', 7, 0)
		slider.valText = text

		return slider
	end
end

--create panel
function OptionsPlayer:CreatePanel(name, parent)
	local panel = CreateFrame('Frame', self:GetName() .. name, parent, 'OptionsBoxTemplate')
	panel:SetBackdropBorderColor(0.4, 0.4, 0.4)
	panel:SetBackdropColor(0.15, 0.15, 0.15, 0.5)
	getglobal(panel:GetName() .. 'Title'):SetText(name)

	return panel
end

--create formatSlider
function OptionsPlayer:formatSlider(name, key, parent, low, high, step, func)

	local slider = self:CreateSlider(name, parent, low, high, step, func)
	slider:SetScript('OnShow', function(self)
		self.onShow = true
		self:SetValue(IBDU_DB.Opts["player"][key])
		self.onShow = nil
		self.iKey = key
	end)
	slider:SetScript('OnValueChanged', function(self, value)
		if self.tFunc and self.tFunc == 1 then
			local flip = iBuffDebuffU:GetTimeText(true, value) or 'Off'
			self.valText:SetText(flip)
		else
			self.valText:SetText(format('%.1f', value))
			value = format('%.1f', value) --round it off
		end
		if not self.onShow then
			IBDU_DB.Opts["player"][self.iKey] = tonumber(value)
			if self.tFunc and self.tFunc >= 1 then
				iBuffDebuffU:UNIT_AURA('UNIT_AURA', 'player')
			else
				iBuffDebuffU:ModifyApperance_All()
			end
		end
	end)
	
	return slider
end

--check button
function OptionsPlayer:CreateCheckButton(name, parent)
	local button = CreateFrame('CheckButton', parent:GetName() .. name, parent, 'InterfaceOptionsCheckButtonTemplate')
	getglobal(button:GetName() .. 'Text'):SetText(name)

	return button
end

OptionsPlayer:Load('iBuffDebuffU', L_IBDU_PANEL_1)