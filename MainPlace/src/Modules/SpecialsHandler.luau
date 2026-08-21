local SpecialsHandler = {}

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InfoModule = require(ReplicatedStorage.Shared.Info)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local CooldownSystem = require(ServerStorage.Modules.CooldownSystem)
local Specials = require(ServerStorage.Modules.Specials)

function SpecialsHandler:Activate(Player)
	local Character = Player.Character
	if not Character then
		return
	end

	local isAwakened = Character:HasTag("Awakened") or Character:GetAttribute("Awakened") == true
	local isUlt = isAwakened

	if Character:HasTag("Stunned") then
		return
	end

	local moveset = Player:GetAttribute("Moveset")
	local moveInfo = InfoModule.Movesets[moveset]

	if not moveInfo then
		return
	end

	local config = isUlt and moveInfo.UltimateSpecial or moveInfo.Special

	if not config then
		return
	end

	local Special = Specials[config.Action]
	if not Special or not Special.Activate then
		return
	end

	local CooldownId = config.Action .. (isUlt and "_Ult" or "_Base")

	if CooldownSystem:IsOnCooldown(Player.UserId, CooldownId) then
		RemoteManager.FireClient(Player, "SpecialsResult", "OnCooldown", {
			Remaining = CooldownSystem:GetRemaining(Player.UserId, CooldownId),
			IsUlt = isUlt,
		})
		return
	end

	local ok = Special.Activate(Player, isUlt)
	if not ok then
		return
	end

	local Cooldown = Special.Cooldown or 0
	CooldownSystem:Set(Player.UserId, CooldownId, Cooldown)

	RemoteManager.FireClient(Player, "SpecialsResult", "Activated", { Cooldown = Cooldown, IsUlt = isUlt })
end

function SpecialsHandler:ClearPlayer(userId)
	CooldownSystem:ClearAll(userId)
end

return SpecialsHandler
