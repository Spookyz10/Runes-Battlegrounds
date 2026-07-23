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

local COLOR_COOLDOWN = Color3.new(0, 0, 0)
local COLOR_READY = Color3.new(1, 1, 1)

local function getMain(slot)
	return slot:FindFirstChild("Main")
end

local function getIcon(slot)
	local main = getMain(slot)
	return main and main:FindFirstChild("Icon")
end

local function getSlot(name: string)
	local slot = Main:FindFirstChild(name)
	if slot and slot:IsA("ImageLabel") then
		return slot
	end
	return nil
end

local function cancelTween(icon: GuiObject)
	if activeTweens[icon] then
		activeTweens[icon]:Cancel()
		activeTweens[icon] = nil
	end
end

local function StartCooldown(name: string, duration: number)
	local slot = getSlot(name)
	if not slot then
		return
	end

	local icon = getIcon(slot)
	if not icon then
		return
	end

	slot.Visible = true
	cancelTween(icon)
	icon.ImageColor3 = COLOR_COOLDOWN

	if duration <= 0 then
		icon.ImageColor3 = COLOR_READY
		return
	end

	local tween = TS:Create(icon, TweenInfo.new(duration, Enum.EasingStyle.Linear), { ImageColor3 = COLOR_READY })
	activeTweens[icon] = tween
	tween.Completed:Once(function(state)
		if activeTweens[icon] == tween then
			activeTweens[icon] = nil
			slot.Visible = false
		end
	end)
	tween:Play()
end

local function resetAllSlots()
	for _, slot in Main:GetChildren() do
		if slot:IsA("ImageLabel") then
			slot.Visible = false
			local icon = getIcon(slot)
			if icon then
				cancelTween(icon)
				icon.ImageColor3 = COLOR_READY
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
