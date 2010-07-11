--[[
	iBuffDebuffU Options
	--Code adapted from Tuller's OmniCC Options Panel, (Thanks Tuller)
--]]

local Options = CreateFrame('Frame', 'iBuffDebuffUOptionsFrame', InterfaceOptionsFramePanelContainer)

function Options:Load(title)
	self.name = title
	
	local text = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	text:SetPoint('TOPLEFT', 16, -16)
	text:SetText(title)

	self:AddDisplayPanel()

	InterfaceOptions_AddCategory(self) 
end

--[[ Panels ]]--

--Display
function Options:AddDisplayPanel()

	--hide blizzard buff frames
	local hideBlizzBuff = self:CreateCheckButton(L_IBDU_OPT8, self)
	hideBlizzBuff:SetScript('OnShow', function(self) self:SetChecked(IBDU_DB.Opts.hideblizzbuffs) end)
	hideBlizzBuff:SetScript('OnClick', function(self)
		IBDU_DB.Opts.hideblizzbuffs = self:GetChecked() or false
		if IBDU_DB.Opts.hideblizzbuffs then
			BuffFrame:UnregisterAllEvents()
			BuffFrame:Hide()
			BuffFrame.Show = function() end
			TemporaryEnchantFrame:UnregisterAllEvents()
			TemporaryEnchantFrame:Hide()
			TemporaryEnchantFrame.Show = BuffFrame.Show
		else
			ReloadUI()
		end
	end)
	hideBlizzBuff:SetPoint('TOPLEFT', 10, -50)
	
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

	function Options:CreateSlider(text, parent, low, high, step, func)
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
function Options:CreatePanel(frame, name, parent)
	local panel = CreateFrame('Frame', frame:GetName() .. name, parent, 'OptionsBoxTemplate')
	panel:SetBackdropBorderColor(0.4, 0.4, 0.4)
	panel:SetBackdropColor(0.15, 0.15, 0.15, 0.5)
	getglobal(panel:GetName() .. 'Title'):SetText(name)

	return panel
end

--create formatSlider
function Options:formatSlider(name, key, parent, low, high, step, func, target)

	local slider = self:CreateSlider(name, parent, low, high, step, func)
	slider:SetScript('OnShow', function(self)
		self.onShow = true
		self:SetValue(IBDU_DB.Opts[target][key])
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
			IBDU_DB.Opts[target][self.iKey] = tonumber(value)
			if self.tFunc and self.tFunc >= 1 then
				iBuffDebuffU:UNIT_AURA('UNIT_AURA', target)
			else
				iBuffDebuffU:ModifyApperance_All()
			end
		end
	end)
	
	return slider
end

--color selector
do
	local colorSelectors, colorCopier

	--color copier: we use this to transfer color from one color selector to another
	local function ColorCopier_Create()
		local copier = CreateFrame('Frame')
		copier:SetWidth(24); copier:SetHeight(24)
		copier:Hide()

		copier:EnableMouse(true)
		copier:SetToplevel(true)
		copier:SetMovable(true)
		copier:RegisterForDrag('LeftButton')
		copier:SetFrameStrata('TOOLTIP')

		copier:SetScript('OnUpdate', function(self)
			local x, y = GetCursorPosition()
			self:SetPoint('TOPLEFT', UIParent, 'BOTTOMLEFT', x - 8, y + 8)
		end)

		copier:SetScript('OnReceiveDrag', function(self)
			for _,selector in pairs(colorSelectors) do
				if MouseIsOver(selector, 8, -8, -8, 8) then
					selector:PasteColor()
					break
				end
			end
			self:Hide()
		end)

		copier:SetScript('OnMouseUp', copier.Hide)

		copier.bg = copier:CreateTexture()
		copier.bg:SetTexture('Interface/ChatFrame/ChatFrameColorSwatch')
		copier.bg:SetAllPoints(copier)

		return copier
	end

	local function ColorSelect_CopyColor(self)
		colorCopier = colorCopier or ColorCopier_Create()
		colorCopier.bg:SetVertexColor(self:GetNormalTexture():GetVertexColor())
		colorCopier:Show()
	end

	local function ColorSelect_PasteColor(self)
		self:SetColor(colorCopier.bg:GetVertexColor())
		colorCopier:Hide()
	end

	local function ColorSelect_SetColor(self, ...)
		self:GetNormalTexture():SetVertexColor(...)
		self:OnSetColor(...)
	end

	local function ColorSelect_OnClick(self)
		if ColorPickerFrame:IsShown() then
			ColorPickerFrame:Hide()
		else
			self.r, self.g, self.b, self.opacity = self:GetColor()
			self.opacity = 1 - (self.opacity or 1) --correction, since the color menu is crazy

			OpenColorPicker(self)
			ColorPickerFrame:SetFrameStrata('TOOLTIP')
			ColorPickerFrame:Raise()
		end
	end

	local function ColorSelect_OnEnter(self)
		local color = NORMAL_FONT_COLOR
		self.bg:SetVertexColor(color.r, color.g, color.b)
	end

	local function ColorSelect_OnLeave(self)
		local color = HIGHLIGHT_FONT_COLOR
		self.bg:SetVertexColor(color.r, color.g, color.b)
	end

	local function ColorSelect_OnShow(self)
		local r, g, b = self:GetColor()
		self:GetNormalTexture():SetVertexColor(r, g, b)
	end

	function Options:CreateColorSelector(name, parent)
		local frame = CreateFrame('Button', parent:GetName() .. name, parent)
		frame:SetWidth(16); frame:SetHeight(16)
		frame:SetNormalTexture('Interface/ChatFrame/ChatFrameColorSwatch')

		local bg = frame:CreateTexture(nil, 'BACKGROUND')
		bg:SetWidth(14); bg:SetHeight(14)
		bg:SetTexture(1, 1, 1)
		bg:SetPoint('CENTER')
		frame.bg = bg
		
		local text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		text:SetPoint('LEFT', frame, 'RIGHT', 4, 0)
		text:SetText("")
		frame.text = text
	
		frame.SetColor = ColorSelect_SetColor
		frame.PasteColor = ColorSelect_PasteColor
		frame.swatchFunc = function() frame:SetColor(ColorPickerFrame:GetColorRGB()) end
		frame.cancelFunc = function() frame:SetColor(frame.r, frame.g, frame.b) end

		frame.OnSetColor = function(r, g, b, a) assert(false, 'No OnSetColor for ' .. self:GetName()) end
		frame.GetColor = function(r, g, b, a) assert(false, 'No OnSetColor for ' .. self:GetName()) end
		
		frame:RegisterForDrag('LeftButton')
		frame:SetScript('OnDragStart', ColorSelect_CopyColor)
		frame:SetScript('OnClick', ColorSelect_OnClick)
		frame:SetScript('OnEnter', ColorSelect_OnEnter)
		frame:SetScript('OnLeave', ColorSelect_OnLeave)
		frame:SetScript('OnShow', ColorSelect_OnShow)
		
		--register the color selector, and create the copier if needed
		if colorSelectors then
			table.insert(colorSelectors, frame)
		else
			colorSelectors = {frame}
		end

		return frame
	end
end

--check button
function Options:CreateCheckButton(name, parent)
	local button = CreateFrame('CheckButton', parent:GetName() .. name, parent, 'InterfaceOptionsCheckButtonTemplate')
	getglobal(button:GetName() .. 'Text'):SetText(name)

	return button
end

Options:Load(select(2, GetAddOnInfo('iBuffDebuffU')))
LibStub("tekKonfig-AboutPanel").new("iBuffDebuffU", "iBuffDebuffU")