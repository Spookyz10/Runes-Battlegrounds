local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SvSt = ServerStorage

local ServerModules = ServerStorage.Modules

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local KnockbackModule = require(ServerModules.KnockbackModule)

local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

local HITBOX_SIZE = Vector3.new(20, 4, 20)
local HITBOX_OFFSET = CFrame.new(0, -2, -4)
local KNOCKUP_VELOCITY = Vector3.new(0, 65, 0)
local DAMAGE = 22
local STUN_TIME = 0.4
local INFERNO_DURATION = 4

local function applyInferno(Character, EnemyCharacter)
	local existing = EnemyCharacter:GetAttribute("Inferno")
	EnemyCharacter:SetAttribute("Inferno", true)

	if existing then
		return
	end

	local tickStart = tick()
	local duration = INFERNO_DURATION
	local dotInterval = 0.5
	local dotDamage = 3

	task.spawn(function()
		while EnemyCharacter and EnemyCharacter.Parent and EnemyCharacter:GetAttribute("Inferno") do
			local elapsed = tick() - tickStart
			if elapsed >= duration then
				break
			end

			local Hum = EnemyCharacter:FindFirstChild("Humanoid")
			if not Hum or Hum.Health <= 0 then
				break
			end

			Hum:TakeDamage(dotDamage)
			task.wait(dotInterval)
		end

		if EnemyCharacter and EnemyCharacter.Parent then
			EnemyCharacter:SetAttribute("Inferno", nil)
		end
	end)

	task.delay(duration, function()
		if EnemyCharacter and EnemyCharacter.Parent then
			EnemyCharacter:SetAttribute("Inferno", nil)
		end
	end)
end

return {
	Start = function(Player, Tool)
		local Character = Player.Character
		if not Character then
			return
		end

		local HumRP = Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character:FindFirstChild("Humanoid")
		if not HumRP or not Humanoid then
			return
		end

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		task.wait(0.3)

		local HitList = {}

		HitboxHandler:SimpleOnce(HumRP, HITBOX_SIZE, HITBOX_OFFSET, { Character }, "Box", nil, function(EnemyCharacter)
			if table.find(HitList, EnemyCharacter) then
				return
			end

			local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
			local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
			if not EnemyHumanoid or not EnemyHumRP then
				return
			end
			if EnemyHumanoid.Health <= 0 or EnemyCharacter:HasTag("Ragdolled") then
				return
			end
			if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
				return
			end

			table.insert(HitList, EnemyCharacter)

			local HitInfo = DamageHandler:TakeDamage(
				Character,
				EnemyHumanoid,
				DAMAGE,
				STUN_TIME,
				nil,
				false,
				false,
				true,
				true,
				false,
				nil,
				nil
			)

			if HitInfo.Countered or HitInfo.Blocked then
				return
			end

			EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

			KnockbackModule:Knockback(EnemyCharacter, KNOCKUP_VELOCITY, nil, nil, nil, nil, false)

			SvSt.Bindables.AirDetector:Fire(EnemyCharacter, nil, true)

			applyInferno(Character, EnemyCharacter)

			ReplicateSet:FireAllClients("SunquakeHit", {
				Char = Character,
				EChar = EnemyCharacter,
			})
		end)

		ReplicateSet:FireAllClients("SunquakePunch", { Char = Character })

		task.wait(0.5)

		iFramesService:RemoveAlliFrames(Character)
		StunHandler:Unstun(Character, Stun)
	end,
}
