local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)

local Player = UIConstants.Player
local PlayerGui = UIConstants.PlayerGui

local GUI = PlayerGui:WaitForChild("ExtraCds")
local Main = GUI:WaitForChild("Main")

local Remotes = ReplicatedStorage.Remotes
local SpecialsSet = Remotes.Specials.Set
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local ExtraCds = {}

local function getMain(slot)
	return slot:FindFirstChild("Main")
end

local function getDarkIcon(slot)
	local main = getMain(slot)
	return main and main:FindFirstChild("DarkIcon")
end

local function getSlot(name: string)
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

function ExtraCds.Init()
	SpecialsSet.OnClientEvent:Connect(function(action, params)
		if action == "Activated" and not params.IsUlt then
			ExtraCds.StartCooldown("Special", params.Cooldown)
		end
	end)

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
