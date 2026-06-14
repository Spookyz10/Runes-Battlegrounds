local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local KnockbackModule = require(ServerModules.KnockbackModule)

local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

local PILLAR_SEARCH_RADIUS = 60
local PILLAR_DAMAGE = 35
local PILLAR_STUN = 1.5

local EMPOWERED_DAMAGE = 18
local EMPOWERED_KNOCKBACK = 40
local EMPOWERED_KNOCKUP = 30
local EMPOWERED_STUN = 0.35

local INFERNO_DURATION = 3

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

local function handleEmpoweredHit(Character, EnemyCharacter, Tool)
	local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
	local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
	local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)

	if not EnemyHumanoid or not EnemyHumRP then
		return
	end
	if EnemyHumanoid.Health <= 0 or EnemyCharacter:HasTag("Ragdolled") then
		return
	end
	if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
		return
	end

	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local HitInfo = DamageHandler:TakeDamage(
		Character,
		EnemyHumanoid,
		EMPOWERED_DAMAGE,
		EMPOWERED_STUN,
		nil,
		true,
		true,
		true,
		true,
		false,
		"M1",
		nil
	)

	if HitInfo.Countered or HitInfo.Blocked then
		return
	end

	EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

	local pushDir = HumRP.CFrame.LookVector
	KnockbackModule:Knockback(
		EnemyCharacter,
		pushDir * EMPOWERED_KNOCKBACK + Vector3.new(0, EMPOWERED_KNOCKUP, 0),
		nil,
		nil,
		nil,
		nil,
		false
	)

	ServerStorage.Bindables.AirDetector:Fire(EnemyCharacter, nil, true)

	applyInferno(Character, EnemyCharacter)

	if EnemyPlayer then
		ReplicateSet:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 3, Last = 0.3 })
	end

	ReplicateSet:FireAllClients("UndawnEmpoweredHit", {
		Char = Character,
		EChar = EnemyCharacter,
	})
end

local function setupEmpoweredM1s(Character, Tool, chargesLeft)
	if chargesLeft <= 0 then
		Character:SetAttribute("UndawnEmpowered", nil)
		Character:SetAttribute("UndawnCharges", nil)
		ReplicateSet:FireAllClients("UndawnEmpoweredEnd", { Char = Character })
		return
	end

	Character:SetAttribute("UndawnEmpowered", true)
	Character:SetAttribute("UndawnCharges", chargesLeft)

	local connection
	connection = Character:GetAttributeChangedSignal("LastM1Time"):Connect(function()
		local remaining = Character:GetAttribute("UndawnCharges") or 0
		if remaining <= 0 then
			connection:Disconnect()
			return
		end

		local HumRP = Character:FindFirstChild("HumanoidRootPart")
		if not HumRP then
			return
		end

		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Include
		overlapParams.FilterDescendantsInstances = { workspace.Live }

		local parts =
			workspace:GetPartBoundsInBox(HumRP.CFrame * CFrame.new(0, 0, -3.5), Vector3.new(7, 5, 7), overlapParams)

		for _, part in parts do
			local char = part.Parent
			if not char or char == Character then
				continue
			end
			local hum = char:FindFirstChild("Humanoid")
			if not hum or hum.Health <= 0 then
				continue
			end

			local newRemaining = (Character:GetAttribute("UndawnCharges") or 0) - 1
			Character:SetAttribute("UndawnCharges", newRemaining)

			handleEmpoweredHit(Character, char, Tool)

			if newRemaining <= 0 then
				connection:Disconnect()
				Character:SetAttribute("UndawnEmpowered", nil)
				Character:SetAttribute("UndawnCharges", nil)
				ReplicateSet:FireAllClients("UndawnEmpoweredEnd", { Char = Character })
			end

			break
		end
	end)

	local toolCDS = Tool:GetAttribute("CDS") or 15
	task.delay(toolCDS, function()
		if Character:GetAttribute("UndawnEmpowered") then
			connection:Disconnect()
			Character:SetAttribute("UndawnEmpowered", nil)
			Character:SetAttribute("UndawnCharges", nil)
			ReplicateSet:FireAllClients("UndawnEmpoweredEnd", { Char = Character })
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

		task.wait(0.4)

		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Include
		overlapParams.FilterDescendantsInstances = { workspace.Live }

		local parts = workspace:GetPartBoundsInRadius(HumRP.Position, PILLAR_SEARCH_RADIUS, overlapParams)

		local pillarTargets = {}
		for _, part in parts do
			local char = part.Parent
			if not char or char == Character then
				continue
			end
			if table.find(pillarTargets, char) then
				continue
			end

			if not char:GetAttribute("Inferno") then
				continue
			end

			local hum = char:FindFirstChild("Humanoid")
			if not hum or hum.Health <= 0 then
				continue
			end
			if iFramesService:HasiFrame(char, Tool.Name) then
				continue
			end

			table.insert(pillarTargets, char)
		end

		for _, EnemyCharacter in pillarTargets do
			local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
			local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
			local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)

			if not EnemyHumanoid or not EnemyHumRP then
				continue
			end

			EnemyCharacter:SetAttribute("Inferno", nil)

			local HitInfo = DamageHandler:TakeDamage(
				Character,
				EnemyHumanoid,
				PILLAR_DAMAGE,
				PILLAR_STUN,
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

				KnockbackModule:Knockback(EnemyCharacter, Vector3.new(0, 50, 0), nil, nil, nil, nil, false)

				if EnemyPlayer then
					ReplicateSet:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 5, Last = 0.5 })
				end
			end

			ReplicateSet:FireAllClients("UndawnPillar", {
				Char = Character,
				EChar = EnemyCharacter,
				HumRP = EnemyHumRP,
			})
		end

		ReplicateSet:FireAllClients("UndawnCast", { Char = Character })
		ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 2, Last = 0.4 })

		task.wait(0.3)

		iFramesService:RemoveAlliFrames(Character)
		StunHandler:Unstun(Character, Stun)

		setupEmpoweredM1s(Character, Tool, 2)
	end,
}
