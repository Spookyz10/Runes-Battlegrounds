local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local SvModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local Abilities = require(SvModules.Abilities)
local CooldownSystem = require(SvModules.CooldownSystem)

local Remote = {}

function Remote:Activate(Player: Player, Ability: string)
	local Character = Player.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	if not Character or not Character.Parent or not Humanoid or Humanoid.Health <= 0 or Character:HasTag("Ragdolled") then
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

	local AbilityModule = Abilities[Ability]
	if not AbilityModule or not AbilityModule.Start then
		return
	end

	if CooldownSystem:IsOnCooldown(Character, Ability) then
		if AbilityModule.TryPull then
			task.spawn(function()
				AbilityModule.TryPull(Player, Tool)
			end)
		end
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
