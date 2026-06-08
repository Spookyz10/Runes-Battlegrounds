local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player.PlayerGui

local CombatRemotes = ReplicatedStorage.Remotes.Combat
local skillTemplate = ReplicatedStorage.Assets.UI.SkillTemplate

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local hotbar = playerGui:WaitForChild("HUD"):WaitForChild("Hotbar")

local slots = {}

local function clearHotbar()
	for _, slot in slots do
		slot:Destroy()
	end
	table.clear(slots)
end

local function buildHotbar(tools)
	clearHotbar()
	for _, tool in tools do
		local slot = skillTemplate:Clone()
		slot.Name = tool.Name
		slot.SkillName.Text = tool.Name
		slot.Parent = hotbar

		slot.MouseButton1Click:Connect(function()
			if tool.Parent == player.Backpack then
				CombatRemotes.Skill:FireServer(tool)
			end
		end)

		slots[#slots + 1] = slot
	end
end

local function refreshFromBackpack()
	local tools = {}
	for _, item in player.Backpack:GetChildren() do
		if item:IsA("Tool") then
			tools[#tools + 1] = item
		end
	end
	buildHotbar(tools)
end

player.Backpack.ChildAdded:Connect(refreshFromBackpack)
player.Backpack.ChildRemoved:Connect(refreshFromBackpack)

refreshFromBackpack()
