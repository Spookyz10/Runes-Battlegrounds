local SpecialsHandler = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).server
local InfoModule = require(ReplicatedStorage.Shared.Info)

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

	local playerClass = Data[Player]
	if not playerClass then
		return false
	end

	local modes = movesetInfo.Modes
	local current = playerClass.MovesetModes[moveset]() or movesetInfo.DefaultMode
	local currentIdx = table.find(modes, current) or 1
	local nextMode = modes[(currentIdx % #modes) + 1]

	playerClass.MovesetModes[moveset](nextMode)
	Player:SetAttribute("MovesetMode_" .. moveset, nextMode)

	if isUlt then
		MovesetHandler:AddAwakeningMoveset(Player, moveset)
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
		ReplicatedStorage.Remotes.Specials.Set:FireClient(
			Player,
			"OnCooldown",
			{ Remaining = remaining, IsUlt = isUlt }
		)
		return
	end

	if getAwkProgress(Player) < config.Cost then
		ReplicatedStorage.Remotes.Specials.Set:FireClient(Player, "NotEnoughAwk", {})
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

	ReplicatedStorage.Remotes.Specials.Set:FireClient(
		Player,
		"Activated",
		{ Cooldown = config.Cooldown, IsUlt = isUlt }
	)
end

function SpecialsHandler:ClearPlayer(userId)
	Cooldowns[userId] = nil
end

return SpecialsHandler
