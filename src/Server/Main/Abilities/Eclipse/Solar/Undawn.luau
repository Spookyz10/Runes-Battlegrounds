local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local iFramesService = require(ServerModules.iFramesService)
local PerfectKnockback = require(ServerModules.PerfectKnockback)

local PILLAR_SEARCH_RADIUS = 60
local PILLAR_DAMAGE = 35
local PILLAR_STUN = 1.5

local EMPOWERED_DAMAGE = 22
local EMPOWERED_STUN = 0.35

local INFERNO_DURATION = 3

local function applyInferno(EnemyCharacter)
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
			if tick() - tickStart >= duration then
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

local function setupEmpoweredM1s(Character, Tool, chargesLeft)
	if chargesLeft <= 0 then
		Character:SetAttribute("UndawnEmpowered", nil)
		Character:SetAttribute("UndawnCharges", nil)
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

		local hitboxCF = HumRP.CFrame * CFrame.new(0, 0, -3.5)
		local hitSize = Vector3.new(7, 5, 7)
		local hitOnce = false

		HitboxHandler:SimpleOnce(
			hitboxCF,
			hitSize,
			CFrame.new(0, 0, 0),
			{ Character },
			"Box",
			nil,
			function(EnemyCharacter)
				if hitOnce then
					return
				end

				local hum = EnemyCharacter:FindFirstChild("Humanoid")
				local hrp = EnemyCharacter:FindFirstChild("HumanoidRootPart")
				if not hum or not hrp then
					return
				end
				if hum.Health <= 0 then
					return
				end

				hitOnce = true

				local newRemaining = (Character:GetAttribute("UndawnCharges") or 0) - 1
				Character:SetAttribute("UndawnCharges", newRemaining)

				local HitInfo = DamageHandler:TakeDamage(
					Character,
					hum,
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

				if not HitInfo.Countered and not HitInfo.Blocked then
					hrp.AssemblyLinearVelocity = Vector3.zero

					local pushDir = HumRP.CFrame.LookVector
					local lookFlat = Vector3.new(pushDir.X, 0, pushDir.Z).Unit
					local lookCF = CFrame.lookAt(hrp.Position, hrp.Position + lookFlat)

					PerfectKnockback:KnockBack(nil, EnemyCharacter, {
						LookVector = lookFlat,
						LookForce = 52,
						LookFinalForce = 48,
						LookAt = lookCF,
						UpVelocity = Vector3.new(0, 35, 0),
						UpVelocityTime = 0.12,
						GroundStunTime = 0.9,
						FallingDetectDelay = 0.4,
						Dot = 1,
						DontFreeze = false,
					}, Character)

					applyInferno(EnemyCharacter)
				end

				if newRemaining <= 0 then
					connection:Disconnect()
					Character:SetAttribute("UndawnEmpowered", nil)
					Character:SetAttribute("UndawnCharges", nil)
				end
			end
		)
	end)

	local toolCDS = Tool:GetAttribute("CDS") or 15
	task.delay(toolCDS, function()
		if Character:GetAttribute("UndawnEmpowered") then
			connection:Disconnect()
			Character:SetAttribute("UndawnEmpowered", nil)
			Character:SetAttribute("UndawnCharges", nil)
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

		HitboxHandler:SimpleOnce(
			HumRP,
			PILLAR_SEARCH_RADIUS,
			CFrame.new(0, 0, 0),
			{ Character },
			"Sphere",
			nil,
			function(EnemyCharacter)
				if not EnemyCharacter:GetAttribute("Inferno") then
					return
				end
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
					return
				end

				local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
				local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
				if not EnemyHumanoid or not EnemyHumRP then
					return
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

					local pushDir = (EnemyHumRP.Position - HumRP.Position)
					pushDir = Vector3.new(pushDir.X, 0, pushDir.Z)
					if pushDir.Magnitude > 0 then
						pushDir = pushDir.Unit
					else
						pushDir = HumRP.CFrame.LookVector
					end

					local lookCF = CFrame.lookAt(EnemyHumRP.Position, EnemyHumRP.Position + pushDir)

					PerfectKnockback:KnockBack(nil, EnemyCharacter, {
						LookVector = pushDir,
						LookForce = 40,
						LookFinalForce = 35,
						LookAt = lookCF,
						UpVelocity = Vector3.new(0, 60, 0),
						UpVelocityTime = 0.2,
						GroundStunTime = 1.2,
						FallingDetectDelay = 0.6,
						Dot = 1,
						DontFreeze = false,
					}, Character)
				end
			end
		)

		task.wait(0.3)

		iFramesService:RemoveAlliFrames(Character)
		StunHandler:Unstun(Character, Stun)

		setupEmpoweredM1s(Character, Tool, 2)
	end,
}
