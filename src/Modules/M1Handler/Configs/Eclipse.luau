local ServerStorage = game:GetService("ServerStorage")
local Animations = ServerStorage.Assets.Animations
local CombatAnims = Animations.Combat
local PunchesFolder = CombatAnims.Punches:FindFirstChild("Eclipse") or CombatAnims.Punches.Default
local HitsFolder = CombatAnims.Hits

local DefaultHitbox = { Size = Vector3.new(7, 5, 7), Offset = CFrame.new(0, 0, -3.5) }

return {
	Steps = {
		[1] = {
			Damage = 2,
			Animation = PunchesFolder["1"],
			HitAnimation = HitsFolder["1"],
			Hitbox = DefaultHitbox,
			Blockable = true,
			Knockback = "PushBoth",
		},
		[2] = {
			Damage = 2,
			Animation = PunchesFolder["2"],
			HitAnimation = HitsFolder["2"],
			Hitbox = DefaultHitbox,
			Blockable = true,
			Knockback = "PushBoth",
		},
		[3] = {
			Damage = 2,
			Animation = PunchesFolder["3"],
			HitAnimation = HitsFolder["3"],
			Hitbox = DefaultHitbox,
			Blockable = true,
			Knockback = "PushBoth",
		},
		[4] = {
			Damage = 4,
			Animation = PunchesFolder["4"],
			HitAnimation = HitsFolder["3"],
			Hitbox = DefaultHitbox,
			Blockable = true,
			Knockback = "RagdollForward",
		},
	},
	Uppercut = {
		Damage = 4,
		Animation = CombatAnims.Punches.Uppercut,
		HitAnimation = HitsFolder["3"],
		Hitbox = { Size = Vector3.new(7, 14, 7), Offset = CFrame.new(0, -3, -3.5) },
		Blockable = true,
		Knockback = "RagdollUppercut",
	},
	Downslam = {
		Damage = 4,
		Animation = CombatAnims.Punches.Downslam,
		HitAnimation = HitsFolder["3"],
		Hitbox = { Size = Vector3.new(7, 14, 7), Offset = CFrame.new(0, -7, -3.5) },
		Blockable = false,
		IgnoreRagdollCheck = true,
		Knockback = "RagdollDownslam",
	},
}
