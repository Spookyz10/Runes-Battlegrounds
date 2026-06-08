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

local function getSkillTool(slot)
	local tools = {}
	for _, t in player.Backpack:GetChildren() do
		if t:IsA("Tool") then
			tools[#tools + 1] = t
		end
	end
	return tools[slot]
end

mouse.Button1Down:Connect(function()
	local air = isInAir()
	local uppercut = (not air) and UserInputService:IsKeyDown(Enum.KeyCode.Space)
	CombatRemotes.M1:FireServer(air, uppercut)
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		CombatRemotes.BlockStart:FireServer()
	elseif input.KeyCode == Enum.KeyCode.Q then
		local tool = getSkillTool(1)
		if tool then
			CombatRemotes.Skill:FireServer(tool)
		end
	elseif input.KeyCode == Enum.KeyCode.E then
		local tool = getSkillTool(2)
		if tool then
			CombatRemotes.Skill:FireServer(tool)
		end
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
