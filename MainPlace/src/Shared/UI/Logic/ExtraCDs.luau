local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local Player: Player = UIConstants.Player
local PlayerGui: PlayerGui = UIConstants.PlayerGui

local GUI: ScreenGui = PlayerGui:WaitForChild("ExtraCds")
local Main: GuiObject = GUI:WaitForChild("Main")

local ExtraCds = {}

local function getMain(slot: GuiObject): GuiObject?
	return slot:FindFirstChild("Main")
end

local function getDarkIcon(slot: GuiObject): GuiObject?
	local main = getMain(slot)
	return main and main:FindFirstChild("DarkIcon")
end

local function getSlot(name: string): ImageLabel?
	local slot = Main:FindFirstChild(name)
	if slot and slot:IsA("ImageLabel") then
		return slot
	end
	return nil
end

function ExtraCds.StartCooldown(name: string, duration: number)
	local slot = getSlot(name)
	if not slot then
		return
	end

	slot.Visible = true

	if duration <= 0 then
		UIFunctions.ResetCooldownIcon(getDarkIcon(slot))
		slot.Visible = false
		return
	end

	UIFunctions.PlayCooldownFill(getDarkIcon(slot), duration, function()
		slot.Visible = false
	end)
end

local function resetAllSlots()
	for _, slot in Main:GetChildren() do
		if slot:IsA("ImageLabel") then
			slot.Visible = false
			UIFunctions.ResetCooldownIcon(getDarkIcon(slot))
		end
	end
end

function ExtraCds.SetEvasiveMeter(Progress: number, Threshold: number, Charges: number)
	local slot = getSlot("Evasive")
	if not slot then
		return
	end

	local darkIcon = getDarkIcon(slot)

	if Charges > 0 then
		slot.Visible = false
		if darkIcon then
			UIFunctions.ResetCooldownIcon(darkIcon)
		end
		return
	end

	slot.Visible = true

	if not darkIcon then
		return
	end

	local Alpha: number = Threshold > 0 and (Progress / Threshold) or 0
	UIFunctions.SetCooldownProgress(darkIcon, Alpha)
end

function ExtraCds.Init()
	Player.CharacterAdded:Connect(function()
		resetAllSlots()

		local ok, Progress, Threshold, Charges = pcall(function()
			return RemoteManager.InvokeServer("Evasive")
		end)

		if ok and Progress and Threshold then
			ExtraCds.SetEvasiveMeter(Progress, Threshold, Charges or 0)
		end
	end)
end

return ExtraCds
