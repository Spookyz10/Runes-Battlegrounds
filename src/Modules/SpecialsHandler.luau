local SpecialsHandler = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InfoModule = require(ReplicatedStorage.Shared.Info)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local Cooldowns = {}

local function getCooldowns(userId)
	if not Cooldowns[userId] then
		Cooldowns[userId] = { base = 0, ult = 0 }
	end
	return Cooldowns[userId]
end

local function getAwkProgress(Player)
	local obj = Player:FindFirstChild("AwakeningProgress")
	return obj and obj.Value or 0
end

local function consumeAwk(Player, amount)
	local obj = Player:FindFirstChild("AwakeningProgress")
	if obj then
		obj.Value = math.max(0, obj.Value - amount)
	end
end

local SpecialActions = {}

SpecialActions["SwapMode"] = function(Player, MovesetHandler, isUlt)
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

	return true
end

function SpecialsHandler:Activate(Player, isUlt, MovesetHandler)
	local moveset = Player:GetAttribute("Moveset")
	local moveInfo = InfoModule.Movesets[moveset]
	if not moveInfo then
		return
	end

	local config = isUlt and moveInfo.UltimateSpecial or moveInfo.Special
	if not config then
		return
	end

	local cd = getCooldowns(Player.UserId)
	local cdKey = isUlt and "ult" or "base"
	local now = tick()

	if now - cd[cdKey] < config.Cooldown then
		local remaining = config.Cooldown - (now - cd[cdKey])
		RemoteManager.FireClient(Player, "SpecialsResult", "OnCooldown", { Remaining = remaining, IsUlt = isUlt })
		return
	end

	if getAwkProgress(Player) < config.Cost then
		RemoteManager.FireClient(Player, "SpecialsResult", "NotEnoughAwk", {})
		return
	end

	local Character = Player.Character
	if not Character then
		return
	end
	if Character:HasTag("Stunned") or Character:HasTag("Awakened") == false and isUlt then
		if isUlt then
			return
		end
	end

	local action = SpecialActions[config.Action]
	if not action then
		warn("SpecialsHandler: action not found:", config.Action)
		return
	end

	local ok = action(Player, MovesetHandler, isUlt)
	if not ok then
		return
	end

	consumeAwk(Player, config.Cost)
	cd[cdKey] = now

	RemoteManager.FireClient(Player, "SpecialsResult", "Activated", { Cooldown = config.Cooldown, IsUlt = isUlt })
end

function SpecialsHandler:ClearPlayer(userId)
	Cooldowns[userId] = nil
end

return SpecialsHandler
