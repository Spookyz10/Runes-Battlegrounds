local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local GUI = PlayerGui:WaitForChild("ExtraCds")
local Main = GUI:WaitForChild("Main")

local ExtraCdsSet = RS.Remotes.ExtraCds.Set
local SpecialsSet = RS.Remotes.Specials.Set

local activeTweens: { [GuiObject]: Tween } = {}

local function getMain(slot)
	return slot:FindFirstChild("Main")
end

local function getCooldownFrame(slot)
	local main = getMain(slot)
	return main and main:FindFirstChild("CooldownFrame")
end

local function getSlot(name: string)
	local slot = Main:FindFirstChild(name)
	if slot and slot:IsA("ImageLabel") then
		return slot
	end
	return nil
end

local function cancelTween(cdFrame: GuiObject)
	if activeTweens[cdFrame] then
		activeTweens[cdFrame]:Cancel()
		activeTweens[cdFrame] = nil
	end
end

local FULL_SIZE = UDim2.fromScale(1, 0.75)
local EMPTY_SIZE = UDim2.fromScale(1, 0.25)

local function StartCooldown(name: string, duration: number)
	local slot = getSlot(name)
	if not slot then
		return
	end

	local cdFrame = getCooldownFrame(slot)
	if not cdFrame then
		return
	end

	slot.Visible = true
	cancelTween(cdFrame)
	cdFrame.Size = FULL_SIZE

	if duration <= 0 then
		slot.Visible = false
		return
	end

	local tween = TS:Create(cdFrame, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = EMPTY_SIZE })
	activeTweens[cdFrame] = tween
	tween.Completed:Once(function(state)
		if activeTweens[cdFrame] == tween then
			activeTweens[cdFrame] = nil
		end
		if state == Enum.PlaybackState.Completed then
			slot.Visible = false
		end
	end)
	tween:Play()
end

local function resetAllSlots()
	for _, slot in Main:GetChildren() do
		if slot:IsA("ImageLabel") then
			slot.Visible = false
			local cdFrame = getCooldownFrame(slot)
			if cdFrame then
				cancelTween(cdFrame)
			end
		end
	end
end

ExtraCdsSet.OnClientEvent:Connect(function(name: string, duration: number)
	StartCooldown(name, duration)
end)

SpecialsSet.OnClientEvent:Connect(function(action, params)
	if action == "Activated" and not params.IsUlt then
		StartCooldown("Special", params.Cooldown)
	end
end)

Player.CharacterAdded:Connect(resetAllSlots)
