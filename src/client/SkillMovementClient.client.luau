local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local SkillMovementRemote = ReplicatedStorage.Remotes.VFX.SkillMovement

local handlers = require(script.Parent.SkillMovements)

SkillMovementRemote.OnClientEvent:Connect(function(skillName, params)
	local character = player.Character
	if not character then
		return
	end
	local handler = handlers[skillName]
	if handler and handler.execute then
		task.spawn(handler.execute, character, params)
	end
end)
