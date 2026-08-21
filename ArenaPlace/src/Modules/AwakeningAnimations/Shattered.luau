local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SvModules = ServerStorage.Modules

local CooldownSystem = require(SvModules.CooldownSystem)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local SFXModule = require(ReplicatedStorage.Shared.Modules.SFXModule)

local module = {}

function module:Activate(Player)
	local Character = Player.Character
	if not Character or not Character.Parent then
		return
	end

	local Humanoid = Character:FindFirstChild("Humanoid")
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not HumRP or Humanoid.Health <= 0 then
		return
	end

	CooldownSystem:ClearAll(Character)
	CooldownSystem:ClearAll(Player.UserId)

	Humanoid.Health = Humanoid.MaxHealth

	SFXModule:Play("ShatterRefresh", HumRP)
	RemoteManager.FireAllClients("ReplicateTask", "ShatterRefresh", { char = Character })
	RemoteManager.FireClient(Player, "ReplicateTask", "RefreshAllCooldowns", {})
end

return module
