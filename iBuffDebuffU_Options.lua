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

--check button
function Options:CreateCheckButton(name, parent)
	local button = CreateFrame('CheckButton', parent:GetName() .. name, parent, 'InterfaceOptionsCheckButtonTemplate')
	getglobal(button:GetName() .. 'Text'):SetText(name)

	return button
end

Options:Load(select(2, GetAddOnInfo('iBuffDebuffU')))
LibStub("tekKonfig-AboutPanel").new("iBuffDebuffU", "iBuffDebuffU")