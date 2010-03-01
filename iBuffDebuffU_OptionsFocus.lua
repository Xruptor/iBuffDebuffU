--[[
	iBuffDebuffU Focus Options
	--Code adapted from Tuller's OmniCC Options Panel, (Thanks Tuller)
--]]

local OptionsFocus = CreateFrame('Frame', 'iBuffDebuffUFocusOptionsFrame', InterfaceOptionsFramePanelContainer)

function OptionsFocus:Load(parent, addonname)

	self.name, self.parent, self.addonname = addonname, parent, addonname
	self:Hide()
	self:AddDisplayPanel()
	InterfaceOptions_AddCategory(self)
	
end

--[[ Panels ]]--

--Display
function OptionsFocus:AddDisplayPanel()

	--Bars grow UP/DOWN
	local growBars = self:CreateCheckButton(L_IBDU_OPT1, self)
	growBars:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts["focus"].grow) end)
	growBars:SetScript('OnClick', function(self)
		IBDU_DB.Opts["focus"].grow = self:GetChecked() or false
		iBuffDebuffU:ProcessGrowth_All()
	end)
	growBars:SetPoint('TOPLEFT', 10, -20)

	--use hhmmss format
	local useHHMMSS = self:CreateCheckButton(L_IBDU_OPT2, self)
	useHHMMSS:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts["focus"].hhmmss) end)
	useHHMMSS:SetScript('OnClick', function(self)
		IBDU_DB.Opts["focus"].hhmmss = self:GetChecked() or false
	end)
	useHHMMSS:SetPoint('TOP', growBars, 'BOTTOM', 0, -1)
	
	--show rank
	local showRank = self:CreateCheckButton(L_IBDU_OPT3, self)
	showRank:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts["focus"].rank) end)
	showRank:SetScript('OnClick', function(self)
		IBDU_DB.Opts["focus"].rank = self:GetChecked() or false
	end)
	showRank:SetPoint('TOP', useHHMMSS, 'BOTTOM', 0, -1)

	--show stacks
	local showStacks = self:CreateCheckButton(L_IBDU_OPT4, self)
	showStacks:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts["focus"].stack) end)
	showStacks:SetScript('OnClick', function(self)
		IBDU_DB.Opts["focus"].stack = self:GetChecked() or false
	end)
	showStacks:SetPoint('TOP', showRank, 'BOTTOM', 0, -1)
	
	--show focus buffs
	local showFocusB = self:CreateCheckButton(L_IBDU_OPT13, self)
	showFocusB:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts.showfocusBuffs) end)
	showFocusB:SetScript('OnClick', function(self)
		IBDU_DB.Opts.showfocusBuffs = self:GetChecked() or false
		iBuffDebuffU:UNIT_AURA('UNIT_AURA', 'focus')
	end)
	showFocusB:SetPoint('TOP', showStacks, 'BOTTOM', 0, -1)
	
	--show focus debuffs
	local showFocusD = self:CreateCheckButton(L_IBDU_OPT14, self)
	showFocusD:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts.showfocusDebuffs) end)
	showFocusD:SetScript('OnClick', function(self)
		IBDU_DB.Opts.showfocusDebuffs = self:GetChecked() or false
		iBuffDebuffU:UNIT_AURA('UNIT_AURA', 'focus')
	end)
	showFocusD:SetPoint('TOP', showFocusB, 'BOTTOM', 0, -1)
	
	local panel = self:CreatePanel(L_IBDU_OPT9)
	panel:SetWidth(392); panel:SetHeight(148)
	panel:SetPoint('BOTTOMLEFT', 10, 10)
	
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

	function OptionsFocus:CreateSlider(text, parent, low, high, step)
		local name = parent:GetName() .. text
		local slider = CreateFrame('Slider', name, parent, 'OptionsSliderTemplate')
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
function OptionsFocus:CreatePanel(name)
	local panel = CreateFrame('Frame', self:GetName() .. name, self, 'OptionsBoxTemplate')
	panel:SetBackdropBorderColor(0.4, 0.4, 0.4)
	panel:SetBackdropColor(0.15, 0.15, 0.15, 0.5)
	getglobal(panel:GetName() .. 'Title'):SetText(name)

	return panel
end

--create formatSlider
function OptionsFocus:formatSlider(name, key, parent, low, high, step)

	local slider = self:CreateSlider(name, parent, low, high, step)
	slider:SetScript('OnShow', function(self)
		self.onShow = true
		self:SetValue(IBDU_DB.Opts["focus"][key])
		self.onShow = nil
		self.iKey = key
	end)
	slider:SetScript('OnValueChanged', function(self, value)
		self.valText:SetText(format('%.1f', value))
		if not self.onShow then
			value = format('%.1f', value) --round it off
			IBDU_DB.Opts["focus"][self.iKey] = value
			iBuffDebuffU:ModifyApperance_All()
		end
	end)
	
	return slider
end

--check button
function OptionsFocus:CreateCheckButton(name, parent)
	local button = CreateFrame('CheckButton', parent:GetName() .. name, parent, 'InterfaceOptionsCheckButtonTemplate')
	getglobal(button:GetName() .. 'Text'):SetText(name)

	return button
end

OptionsFocus:Load('iBuffDebuffU', L_IBDU_PANEL_3)