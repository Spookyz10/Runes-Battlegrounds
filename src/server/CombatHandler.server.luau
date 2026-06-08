local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local CombatService = require(ServerStorage.Modules.Combat.CombatService)
local CombatState = require(ServerStorage.Modules.Combat.CombatState)
local CharacterService = require(ServerStorage.Modules.Characters)

local CombatRemotes = ReplicatedStorage.Remotes.Combat

local function getChar(player)
	return player.Character
end

CombatRemotes.M1.OnServerEvent:Connect(function(player)
	local character = getChar(player)
	if not character then
		return
	end
	local config = CharacterService.getConfig(CombatState.get(player).characterName)
	CombatService.m1(player, character, config)
end)

CombatRemotes.BlockStart.OnServerEvent:Connect(function(player)
	CombatService.blockStart(player)
end)

CombatRemotes.BlockEnd.OnServerEvent:Connect(function(player)
	CombatService.blockEnd(player)
end)

CombatRemotes.Skill.OnServerEvent:Connect(function(player, tool)
	if not tool or not tool:IsA("Tool") then
		return
	end
	if tool.Parent ~= player.Backpack then
		return
	end
	local character = getChar(player)
	if not character then
		return
	end
	local config = CharacterService.getConfig(CombatState.get(player).characterName)
	for _, toolName in config.skills do
		if toolName == tool.Name then
			local skillModule = CharacterService.getSkillModule(toolName)
			task.spawn(skillModule.execute, player, character)
			return
		end
	end
end)

CombatRemotes.ChangeCharacter.OnServerEvent:Connect(function(player, characterName)
	CharacterService.assign(player, characterName)
end)
