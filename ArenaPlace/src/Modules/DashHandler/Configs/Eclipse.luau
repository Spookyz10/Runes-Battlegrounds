local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

return {
	Front = {
		Id = "FrontDash",
		Type = "Attack",
		Animation = function()
			return ReplicatedStorage.Resources.Animations.Dashes.DashFront
		end,
		Cooldown = 5,
		Speed = 40000,
		NearEnemyRadius = 15,
		Hitbox = { Size = Vector3.new(8, 8, 8), Offset = CFrame.new(0, 1, -4) },
		Damage = 4,
		StunTime = 1,
		HitAnimations = function()
			return ServerStorage.Assets.Animations.Combat.Hits
		end,
		Knockback = {
			LookForce = 58.5,
			LookFinalForce = 55,
			GroundStunTime = 0.95,
			Escapable = false,
			FallingDetectDelay = 0.2,
			DotParams = { 0.4, 1 },
		},
	},
	Back = {
		Id = "BackDash",
		Type = "Displacement",
		Duration = 1.017,
		IFrames = true,
		Cooldown = 5,
	},
	Left = {
		Id = "LeftDash",
		Type = "Displacement",
		Duration = 0.6,
		NoStun = true,
		Cooldown = 2,
	},
	Right = {
		Id = "RightDash",
		Type = "Displacement",
		Duration = 0.6,
		NoStun = true,
		Cooldown = 2,
	},
}
