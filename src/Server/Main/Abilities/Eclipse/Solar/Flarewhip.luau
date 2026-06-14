local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local KnockbackModule = require(ServerModules.KnockbackModule)

local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

local SEARCH_RADIUS = 30
local DAMAGE = 20
local INFERNO_DURATION = 3.5
local KNOCKBACK_VELOCITY_MULT = 55
local KNOCKUP_Y = 12

local function isInAir(EnemyCharacter)
	if EnemyCharacter:FindFirstChild("inAir") then
		return true
	end
	local touched = EnemyCharacter:GetAttribute("TouchedGround")
	if touched and (tick() - touched) <= 0.25 then
		return true
	end
	return false
end

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

		task.wait(0.2)

		local closestEnemy = nil
		local closestDist = math.huge

		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Include
		overlapParams.FilterDescendantsInstances = { workspace.Live }

		local parts = workspace:GetPartBoundsInRadius(HumRP.Position, SEARCH_RADIUS, overlapParams)

		for _, part in parts do
			local char = part.Parent
			if not char or char == Character then
				continue
			end

			local hum = char:FindFirstChild("Humanoid")
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hum or not hrp then
				continue
			end
			if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then
				continue
			end
			if char:HasTag("Ragdolled") then
				continue
			end
			if iFramesService:HasiFrame(char, Tool.Name) then
				continue
			end
			if not isInAir(char) then
				continue
			end

			local dist = (hrp.Position - HumRP.Position).Magnitude
			if dist < closestDist then
				closestDist = dist
				closestEnemy = char
			end
		end

		if not closestEnemy then
			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)
			return
		end

		local EnemyHumanoid = closestEnemy:FindFirstChild("Humanoid")
		local EnemyHumRP = closestEnemy:FindFirstChild("HumanoidRootPart")
		local EnemyPlayer = Players:GetPlayerFromCharacter(closestEnemy)

		if not EnemyHumanoid or not EnemyHumRP then
			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)
			return
		end

		local pushDir = (EnemyHumRP.Position - HumRP.Position)
		pushDir = Vector3.new(pushDir.X, 0, pushDir.Z)
		if pushDir.Magnitude > 0 then
			pushDir = pushDir.Unit
		else
			pushDir = HumRP.CFrame.LookVector
		end

		local HitInfo = DamageHandler:TakeDamage(
			Character,
			EnemyHumanoid,
			DAMAGE,
			nil,
			nil,
			false,
			false,
			true,
			true,
			false,
			nil,
			nil
		)

		if not HitInfo.Countered and not HitInfo.Blocked then
			EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

			KnockbackModule:Knockback(
				closestEnemy,
				pushDir * KNOCKBACK_VELOCITY_MULT + Vector3.new(0, KNOCKUP_Y, 0),
				nil,
				nil,
				nil,
				nil,
				false
			)

			applyInferno(Character, closestEnemy)

			if EnemyPlayer then
				ReplicateSet:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 2, Last = 0.3 })
			end

			ReplicateSet:FireAllClients("FlarewhipHit", {
				Char = Character,
				EChar = closestEnemy,
			})
		end

		ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 1.5, Last = 0.2 })

		task.wait(0.35)

		iFramesService:RemoveAlliFrames(Character)
		StunHandler:Unstun(Character, Stun)
	end,
}
