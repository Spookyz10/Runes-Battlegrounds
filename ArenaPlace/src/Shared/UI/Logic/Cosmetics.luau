local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).client
local CosmeticsInfo = require(ReplicatedStorage.Shared.Info.Cosmetics)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local Player = UIConstants.Player
local PlayerGui = UIConstants.PlayerGui

local GUI = PlayerGui:WaitForChild("Cosmetics")
local Main = GUI:WaitForChild("Main")
local Tabs = Main:WaitForChild("Tabs")
local Content = Main:WaitForChild("Content")

local Template = ReplicatedStorage.Resources.UI.Templates.CosmeticTemplate

local ValidTabs = {
	Auras = true,
	RuneCosmetics = true,
}

local OwnedGetters = {
	Auras = function()
		return Data.OwnedAuras()
	end,
	RuneCosmetics = function()
		return Data.OwnedRuneCosmetics()
	end,
}

local AttributeNames = {
	Auras = "EquippedAura",
	RuneCosmetics = "EquippedRuneCosmetic",
}

local activeButtons = {
	Auras = {},
	RuneCosmetics = {},
}

local CosmeticsUI = {}

local function isOwned(cosmeticType, name)
	local owned = OwnedGetters[cosmeticType]()
	return table.find(owned, name) ~= nil
end

local function refreshButton(cosmeticType, name, button)
	local equipped = Player:GetAttribute(AttributeNames[cosmeticType])
	local owned = isOwned(cosmeticType, name)

	if not owned then
		button.Text = "LOCKED"
	elseif equipped == name then
		button.Text = "UNEQUIP"
	else
		button.Text = "EQUIP"
	end
end

local function refreshAll(cosmeticType)
	for name, button in activeButtons[cosmeticType] do
		refreshButton(cosmeticType, name, button)
	end
end

local function onEquipPressed(cosmeticType, name)
	if not isOwned(cosmeticType, name) then
		return
	end

	local equipped = Player:GetAttribute(AttributeNames[cosmeticType])

	if equipped == name then
		RemoteManager.FireServer("Cosmetics", "Unequip", { Type = cosmeticType })
	else
		RemoteManager.FireServer("Cosmetics", "Equip", { Type = cosmeticType, Name = name })
	end
end

local function populateType(cosmeticType)
	local Container = Content:WaitForChild(cosmeticType)

	for _, button in activeButtons[cosmeticType] do
		if button.Parent then
			button.Parent:Destroy()
		end
	end
	table.clear(activeButtons[cosmeticType])

	local catalog = CosmeticsInfo[cosmeticType]
	for name, info in catalog do
		local clone = Template:Clone()
		clone.ItemName.Text = info.DisplayName or name
		clone.Parent = Container

		activeButtons[cosmeticType][name] = clone.Equip

		clone.Equip.Activated:Connect(function()
			onEquipPressed(cosmeticType, name)
		end)

		refreshButton(cosmeticType, name, clone.Equip)
	end
end

local function showTab(tabName)
	for _, frame in Content:GetChildren() do
		if frame:IsA("GuiObject") and ValidTabs[frame.Name] then
			frame.Visible = frame.Name == tabName
		end
	end

	for _, button in Tabs:GetChildren() do
		if button:IsA("TextButton") and ValidTabs[button.Name] then
			button.BackgroundTransparency = (button.Name == tabName) and 0.75 or 1
		end
	end
end

function CosmeticsUI.Init()
	for _, button in Tabs:GetChildren() do
		if button:IsA("TextButton") and ValidTabs[button.Name] then
			button.Activated:Connect(function()
				showTab(button.Name)
			end)
		end
	end

	populateType("Auras")
	populateType("RuneCosmetics")
	showTab("Auras")

	Player:GetAttributeChangedSignal("EquippedAura"):Connect(function()
		refreshAll("Auras")
	end)

	Player:GetAttributeChangedSignal("EquippedRuneCosmetic"):Connect(function()
		refreshAll("RuneCosmetics")
	end)

	Data.OwnedAuras.Changed(function()
		refreshAll("Auras")
	end)

	Data.OwnedRuneCosmetics.Changed(function()
		refreshAll("RuneCosmetics")
	end)
end

return CosmeticsUI
