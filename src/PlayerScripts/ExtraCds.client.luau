local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local GUI = PlayerGui:WaitForChild("ExtraCds")
local Main = GUI:WaitForChild("Main")

local Remotes = RS.Remotes
local ExtraCdsSet = Remotes.ExtraCds.Set
local SpecialsSet = Remotes.Specials.Set
local EvasiveSet = Remotes.Evasive.Set
local EvasiveGet = Remotes.Evasive.Get

local DARK_OFFSET_START = Vector2.new(0, -0.4)
local DARK_OFFSET_END = Vector2.new(0, 0.4)
local DARK_ROTATION = -90

local DARK_GRADIENT_TRANSPARENCY = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.49, 0),
	NumberSequenceKeypoint.new(0.51, 1),
	NumberSequenceKeypoint.new(1, 1),
})

local function getMain(slot)
	return slot:FindFirstChild("Main")
end

local function getDarkIcon(slot)
	local main = getMain(slot)
	return main and main:FindFirstChild("DarkIcon")
end

local function getDarkGradient(darkIcon)
	return darkIcon and darkIcon:FindFirstChildOfClass("UIGradient")
end

local function getSlot(name: string)
	local slot = Main:FindFirstChild(name)
	if slot and slot:IsA("ImageLabel") then
		return slot
	end
	return nil
end

local activeDarkTweens: { [GuiObject]: Tween } = {}

local function cancelDarkTween(darkIcon: GuiObject)
	if activeDarkTweens[darkIcon] then
		activeDarkTweens[darkIcon]:Cancel()
		activeDarkTweens[darkIcon] = nil
	end
end

local function resetDarkIcon(slot)
	local darkIcon = getDarkIcon(slot)
	if not darkIcon then
		return
	end
	cancelDarkTween(darkIcon)
	darkIcon.ImageTransparency = 1
	local grad = getDarkGradient(darkIcon)
	if grad then
		grad.Transparency = DARK_GRADIENT_TRANSPARENCY
		grad.Rotation = DARK_ROTATION
		grad.Offset = DARK_OFFSET_START
	end
end

local function playDarkCooldown(slot, duration, onComplete: (() -> ())?)
	local darkIcon = getDarkIcon(slot)
	if not darkIcon then
		if onComplete then
			onComplete()
		end
		return
	end

	cancelDarkTween(darkIcon)
	local grad = getDarkGradient(darkIcon)

	if duration <= 0 or not grad then
		darkIcon.ImageTransparency = 1
		if onComplete then
			onComplete()
		end
		return
	end

	darkIcon.ImageTransparency = 0
	grad.Transparency = DARK_GRADIENT_TRANSPARENCY
	grad.Rotation = DARK_ROTATION
	grad.Offset = DARK_OFFSET_START

	local darkTween = TS:Create(grad, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Offset = DARK_OFFSET_END })
	activeDarkTweens[darkIcon] = darkTween
	darkTween.Completed:Once(function(state)
		if activeDarkTweens[darkIcon] == darkTween then
			activeDarkTweens[darkIcon] = nil
		end
		if state == Enum.PlaybackState.Completed then
			darkIcon.ImageTransparency = 1
			if onComplete then
				onComplete()
			end
		end
	end)
	darkTween:Play()
end

local function StartCooldown(name: string, duration: number)
	local slot = getSlot(name)
	if not slot then
		return
	end

	slot.Visible = true

	if duration <= 0 then
		resetDarkIcon(slot)
		slot.Visible = false
		return
	end

	playDarkCooldown(slot, duration, function()
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

	cancelDarkTween(darkIcon)

	if Charges > 0 then
		darkIcon.ImageTransparency = 1
		return
	end

	local grad = getDarkGradient(darkIcon)
	if not grad then
		return
	end

	local percent = 0
	if Threshold > 0 then
		percent = math.clamp(Progress / Threshold, 0, 1)
	end

	darkIcon.ImageTransparency = 0
	grad.Transparency = DARK_GRADIENT_TRANSPARENCY
	grad.Rotation = DARK_ROTATION
	grad.Offset = DARK_OFFSET_START:Lerp(DARK_OFFSET_END, percent)
end

local function resetAllSlots()
	for _, slot in Main:GetChildren() do
		if slot:IsA("ImageLabel") then
			slot.Visible = false
			resetDarkIcon(slot)
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
