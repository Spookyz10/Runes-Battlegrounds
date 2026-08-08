local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local SvModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local Abilities = require(SvModules.Abilities)
local CooldownSystem = require(SvModules.CooldownSystem)

local Remote = {}

function Remote:Activate(Player: Player, Ability: string)
	local Character = Player.Character
	if not Character then
		return
	end

	local Stunned = Character:HasTag("Stunned")
		or Character:FindFirstChild("Stunned")
		or Character:GetAttribute("Stunned") == true

	if Stunned or Character:HasTag("Blocking") then
		return
	end

	local MovesetFolder = Player:FindFirstChild("Moveset")
	local Tool = MovesetFolder and MovesetFolder:FindFirstChild(Ability)
	if not Tool then
		return
	end

	if CooldownSystem:IsOnCooldown(Character, Ability) then
		return
	end

	local AbilityModule = Abilities[Ability]
	if not AbilityModule or not AbilityModule.Start then
		return
	end

	local Duration = AbilityModule.Cooldown
	if Duration == nil then
		Duration = Tool:GetAttribute("CDS") or 0
	end

	if Duration > -1 then
		CooldownSystem:Set(Character, Ability, Duration)

		if Duration > 0 then
			RemoteManager.FireClient(Player, "StartCooldown", Ability, Duration)
		end
	end

	RemoteManager.FireAllClients("ActionHightlight", { char = Character, func = "Hit" })

	task.spawn(function()
		AbilityModule.Start(Player, Tool)
	end)
end

return Remote
