local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)

local Player = UIConstants.Player
local PlayerGui = UIConstants.PlayerGui

local GUI = PlayerGui:WaitForChild("ExtraCds")
local Main = GUI:WaitForChild("Main")

local Remotes = ReplicatedStorage.Remotes
local ExtraCdsSet = Remotes.ExtraCds.Set
local SpecialsSet = Remotes.Specials.Set
local EvasiveSet = Remotes.Evasive.Set
local EvasiveGet = Remotes.Evasive.Get

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

local function StartCooldown(name: string, duration: number)
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

local function setEvasiveMeter(Progress: number, Threshold: number, Charges: number)
	local slot = getSlot("Evasive")
	if not slot then
		return
	end

	slot.Visible = true

	local darkIcon = getDarkIcon(slot)
	if not darkIcon then
		return
	end

	UIFunctions.ResetCooldownIcon(darkIcon)

	if Charges > 0 then
		darkIcon.ImageTransparency = 1
		return
	end

	local percent = 0
	if Threshold > 0 then
		percent = math.clamp(Progress / Threshold, 0, 1)
	end

	UIFunctions.PlayCooldownFill(darkIcon, 0)
	darkIcon.ImageTransparency = 0

	local grad = darkIcon:FindFirstChildOfClass("UIGradient")
	if grad then
		grad.Offset = Vector2.new(0, -0.4):Lerp(Vector2.new(0, 0.4), percent)
	end
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
	ExtraCdsSet.OnClientEvent:Connect(function(name: string, duration: number)
		StartCooldown(name, duration)
	end)

	SpecialsSet.OnClientEvent:Connect(function(action, params)
		if action == "Activated" and not params.IsUlt then
			StartCooldown("Special", params.Cooldown)
		end
	end)

	EvasiveSet.OnClientEvent:Connect(function(Progress: number, Threshold: number, Charges: number)
		setEvasiveMeter(Progress, Threshold, Charges)
	end)

	Player.CharacterAdded:Connect(function()
		resetAllSlots()

		local ok, Progress, Threshold, Charges = pcall(function()
			return EvasiveGet:InvokeServer()
		end)

		if ok and Progress and Threshold then
			setEvasiveMeter(Progress, Threshold, Charges or 0)
		end
	end)
end

return ExtraCds
