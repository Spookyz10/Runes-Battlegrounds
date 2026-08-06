local ServerStorage = game:GetService("ServerStorage")
local SvModules = ServerStorage.Modules

local RagdollHandler = require(SvModules.RagdollHandler)
local NewKnockback = require(SvModules.BodymoverService)
local PerfectKnockback = require(SvModules.PerfectKnockback)

local KnockbackPresets = {}

KnockbackPresets.PushBoth = function(Character, EnemyCharacter, HumRP, EnemyHumRP)
	local Velocity = HumRP.CFrame.LookVector * 13

	NewKnockback:Knockback(Character, {
		KnockbackType = "Velocity",
		MaxForce = Vector3.new(math.huge, 0, math.huge),
		Velocity = Velocity,
	})

	if not EnemyCharacter:HasTag("Knockbacked") then
		NewKnockback:Knockback(EnemyCharacter, {
			KnockbackType = "Velocity",
			MaxForce = Vector3.new(math.huge, 0, math.huge),
			Velocity = Velocity,
		})
	end
end

KnockbackPresets.RagdollForward = function(Character, EnemyCharacter, HumRP, EnemyHumRP)
	local pushDir = HumRP.CFrame.LookVector
	local pushFlat = Vector3.new(pushDir.X, 0, pushDir.Z)
	pushFlat = pushFlat.Magnitude > 0 and pushFlat.Unit or Vector3.new(0, 0, -1)

	RagdollHandler.ragdoll(EnemyCharacter.Humanoid, 3)

	NewKnockback:Knockback(EnemyCharacter, {
		KnockbackType = "Velocity",
		MaxForce = Vector3.new(100000, 100000, 100000),
		Velocity = pushFlat * 45 + Vector3.new(0, 20, 0),
	})

	ServerStorage.Bindables.AirDetector:Fire(EnemyCharacter, nil, true, nil, 6.2)
end

KnockbackPresets.RagdollUppercut = function(Character, EnemyCharacter, HumRP, EnemyHumRP)
	RagdollHandler.ragdoll(EnemyCharacter.Humanoid, 3)

	NewKnockback:Knockback(EnemyCharacter, {
		KnockbackType = "Velocity",
		MaxForce = Vector3.new(1, 100000, 1),
		Velocity = Vector3.new(0, 75, 0),
	})

	ServerStorage.Bindables.AirDetector:Fire(EnemyCharacter, nil, true, nil, 6.2)
end

KnockbackPresets.RagdollDownslam = function(Character, EnemyCharacter, HumRP, EnemyHumRP)
	RagdollHandler.ragdoll(EnemyCharacter.Humanoid, 3, nil, nil, nil, nil, true)
	EnemyHumRP.CFrame *= CFrame.Angles(math.pi / 2, 0, 0)
end

KnockbackPresets.PerfectFinisher = function(Character, EnemyCharacter, HumRP, EnemyHumRP)
	EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

	local pushDir = HumRP.CFrame.LookVector
	local lookFlat = Vector3.new(pushDir.X, 0, pushDir.Z)
	lookFlat = lookFlat.Magnitude > 0 and lookFlat.Unit or Vector3.new(0, 0, -1)
	local lookCF = CFrame.lookAt(EnemyHumRP.Position, EnemyHumRP.Position + lookFlat)

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
end

return KnockbackPresets
