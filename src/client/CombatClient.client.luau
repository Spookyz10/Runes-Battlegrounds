-- CombatClient (LocalScript em StarterPlayer > StarterPlayerScripts > Client)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local CombatRemotes = ReplicatedStorage.Remotes.Combat

local function getHumanoid()
	local char = player.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function isInAir()
	local hum = getHumanoid()
	return hum and hum.FloorMaterial == Enum.Material.Air
end

local function isHoldingJump()
	return UserInputService:IsKeyDown(Enum.KeyCode.Space)
end

-- M1
mouse.Button1Down:Connect(function()
	local air = isInAir()
	local uppercut = (not air) and isHoldingJump()
	CombatRemotes.M1:FireServer(air, uppercut)
end)

-- Block
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		CombatRemotes.BlockStart:FireServer()
	elseif input.KeyCode == Enum.KeyCode.Q then
		CombatRemotes.Skill:FireServer("RapidPunches")
	end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
	if gpe then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		CombatRemotes.BlockEnd:FireServer()
	end
end)
