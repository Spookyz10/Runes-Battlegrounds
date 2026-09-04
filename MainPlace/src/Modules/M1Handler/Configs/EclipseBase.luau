local ServerStorage = game:GetService("ServerStorage")
local Animations = ServerStorage.Assets.Animations
local CombatAnims = Animations.Combat
local EclipsePunches = CombatAnims.Punches.Eclipse
local HitsFolder = CombatAnims.Hits

local DefaultHitbox = { Size = Vector3.new(7, 5, 7), Offset = CFrame.new(0, 0, -3.5) }

local function build(ModeName)
	local PunchesFolder = EclipsePunches
	if ModeName then
		PunchesFolder = EclipsePunches:FindFirstChild(ModeName) or EclipsePunches
	end

	return {
		Steps = {
			[1] = {
				Damage = 2,
				Animation = PunchesFolder["1"],
				HitAnimation = HitsFolder["1"],
				Hitbox = DefaultHitbox,
				Blockable = true,
				Knockback = "PushBoth",
				HitSound = "M1",
			},
			[2] = {
				Damage = 2,
				Animation = PunchesFolder["2"],
				HitAnimation = HitsFolder["2"],
				Hitbox = DefaultHitbox,
				Blockable = true,
				Knockback = "PushBoth",
				HitSound = "M2",
			},
			[3] = {
				Damage = 2,
				Animation = PunchesFolder["3"],
				HitAnimation = HitsFolder["3"],
				Hitbox = DefaultHitbox,
				Blockable = true,
				Knockback = "PushBoth",
				HitSound = "M3",
			},
			[4] = {
				Damage = 4,
				Animation = PunchesFolder["4"],
				HitAnimation = HitsFolder["3"],
				Hitbox = DefaultHitbox,
				Blockable = true,
				Knockback = "RagdollForward",
				HitSound = "M3",
			},
		},
		Uppercut = {
			Damage = 4,
			Animation = PunchesFolder:FindFirstChild("Uppercut") or CombatAnims.Punches.Uppercut,
			HitAnimation = HitsFolder["3"],
			Hitbox = { Size = Vector3.new(7, 14, 7), Offset = CFrame.new(0, -3, -3.5) },
			Blockable = true,
			Knockback = "RagdollUppercut",
			HitSound = "Uppercut",
		},
		Downslam = {
			Damage = 4,
			Animation = PunchesFolder:FindFirstChild("Downslam") or CombatAnims.Punches.Downslam,
			HitAnimation = HitsFolder["3"],
			Hitbox = { Size = Vector3.new(7, 14, 7), Offset = CFrame.new(0, -7, -3.5) },
			Blockable = false,
			IgnoreRagdollCheck = true,
			Knockback = "RagdollDownslam",
			HitSound = "Downslam",
		},
	}
end

return build