local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InfoModule = require(ReplicatedStorage.Shared.Info)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local AwakeningService = require(ServerStorage.Modules.AwakeningService)
local MovesetHandler = require(ServerStorage.Modules.MovesetHandler)

local BASE_COST = 5
local ULT_COST = 0

local Special = {}

Special.Cooldown = 5

function Special.Activate(Player, isUlt)
	local Cost = isUlt and ULT_COST or BASE_COST

	local AwkProgressObj = Player:FindFirstChild("AwakeningProgress")
	local CurrentProgress = AwkProgressObj and AwkProgressObj.Value or 0

	if CurrentProgress < Cost then
		RemoteManager.FireClient(Player, "SpecialsResult", "NotEnoughAwk", {})
		return false
	end

	local moveset = Player:GetAttribute("Moveset")
	local movesetInfo = InfoModule.Movesets[moveset]

	if not movesetInfo or not movesetInfo.Modes then
		warn("SwapMode: moveset sem modos definidos:", moveset)
		return false
	end

	local modes = movesetInfo.Modes
	local current = Player:GetAttribute("MovesetMode_" .. moveset) or movesetInfo.DefaultMode
	local currentIdx = table.find(modes, current) or 1
	local nextMode = modes[(currentIdx % #modes) + 1]

	Player:SetAttribute("MovesetMode_" .. moveset, nextMode)

	if isUlt then
		MovesetHandler:AddAwakeningMoveset(Player, moveset)

		local Character = Player.Character
		if Character and Character:HasTag("Awakened") then
			RemoteManager.FireAllClients(
				"ReplicateTask",
				"GivePlayerAura",
				{ Char = Character, AuraName = nextMode .. " " .. moveset }
			)
		end
	else
		MovesetHandler:AddBaseMoveset(Player, moveset)
	end

	AwakeningService:DrainProgress(Player, Cost)

	return true
end

return Special
