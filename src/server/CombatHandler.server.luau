-- CombatHandler (Script em ServerScriptService)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local CombatService = require(ServerStorage.Modules.Combat.CombatService)
local CombatState = require(ServerStorage.Modules.Combat.CombatState)
local RapidPunches = require(ServerStorage.Modules.Combat.Skills.RapidPunches)

--[[
	Estrutura de Remotes em ReplicatedStorage.Shared:
	Shared/
	  Remotes/
	    Combat/
	      M1          RemoteEvent   args: isAir (bool), isUppercut (bool)
	      BlockStart  RemoteEvent   sem args
	      BlockEnd    RemoteEvent   sem args
	      Skill       RemoteEvent   args: skillName (string)
]]

local CombatRemotes = ReplicatedStorage.Remotes.Combat

local function getChar(player)
	return player.Character
end

CombatRemotes.M1.OnServerEvent:Connect(function(player, isAir, isUppercut)
	local character = getChar(player)
	if not character then
		return
	end
	CombatService.m1(player, character, isAir == true, isUppercut == true)
end)

CombatRemotes.BlockStart.OnServerEvent:Connect(function(player)
	CombatService.blockStart(player)
end)

CombatRemotes.BlockEnd.OnServerEvent:Connect(function(player)
	CombatService.blockEnd(player)
end)

CombatRemotes.Skill.OnServerEvent:Connect(function(player, skillName)
	local character = getChar(player)
	if not character then
		return
	end

	if skillName == "RapidPunches" then
		task.spawn(RapidPunches.execute, player, character)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	CombatState.clear(player)
end)
