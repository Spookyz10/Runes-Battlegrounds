--[[
	Character: Lunar
	src/modules/Characters/Lunar.luau
]]

local Lunar = {}

local RagdollService = require(game:GetService("ServerStorage").Modules.RagdollService)

Lunar.comboWindow = 1.8
Lunar.skills = { "Lunar Lunge", "Skull Breaker", "Lunar Uppercut", "Moon Cutter" }

Lunar.m1 = {
	[1] = {
		windup = 0.15,
		endlag = 0.20,
		endlagMiss = 0.35,
		hitbox = Vector3.new(5, 5, 4),
		canMove = false,
		cancelTier = 0,
		interruptTier = 0,
		ignoreIframe = 0,
		ignoreCounterTier = 0,
		ignoreInterrupt = 0,
		ignoreBlock = false,
		knockback = { horizontal = 20, vertical = 2, duration = 0 },
	},
	[2] = {
		windup = 0.15,
		endlag = 0.20,
		endlagMiss = 0.35,
		hitbox = Vector3.new(5, 5, 4),
		canMove = false,
		cancelTier = 0,
		interruptTier = 0,
		ignoreIframe = 0,
		ignoreCounterTier = 0,
		ignoreInterrupt = 0,
		ignoreBlock = false,
		knockback = { horizontal = 22, vertical = 3, duration = 0 },
	},
	[3] = {
		windup = 0.20,
		endlag = 0.15,
		endlagMiss = 0.40,
		hitbox = Vector3.new(5, 5, 4),
		canMove = false,
		cancelTier = 1,
		interruptTier = 0,
		ignoreIframe = 0,
		ignoreCounterTier = 0,
		ignoreInterrupt = 0,
		ignoreBlock = false,
		knockback = { horizontal = 28, vertical = 5, duration = 0.4 },
	},
	[4] = {
		windup = 0.25,
		endlag = 0.35,
		endlagMiss = 0.55,
		hitbox = Vector3.new(5.5, 5, 4.5),
		canMove = false,
		cancelTier = 1,
		interruptTier = 0,
		ignoreIframe = 0,
		ignoreCounterTier = 0,
		ignoreInterrupt = 0,
		ignoreBlock = false,
		onHit = function(attackerChar, victimChar, attackerRoot)
			local forward = attackerRoot.CFrame.LookVector
			RagdollService.applyRagdoll(victimChar, Vector3.new(forward.X * 55, 8, forward.Z * 55))
		end,
	},
}

Lunar.m1Air = {
	windup = 0.20,
	endlag = 0.40,
	endlagMiss = 0.60,
	hitbox = Vector3.new(5, 3, 5),
	hitboxOffset = Vector3.new(0, -2, 0),
	canMove = false,
	cancelTier = 1,
	interruptTier = 0,
	ignoreIframe = 0,
	ignoreCounterTier = 0,
	ignoreInterrupt = 0,
	ignoreBlock = true,
	onHit = function(attackerChar, victimChar, attackerRoot)
		RagdollService.applyRagdoll(victimChar, Vector3.new(0, -40, 0))
	end,
}

Lunar.m1Uppercut = {
	windup = 0.20,
	endlag = 0.50,
	endlagMiss = 0.65,
	hitbox = Vector3.new(5, 6, 4),
	hitboxOffset = Vector3.new(0, 1, 0),
	canMove = false,
	cancelTier = 1,
	interruptTier = 0,
	ignoreIframe = 0,
	ignoreCounterTier = 0,
	ignoreInterrupt = 0,
	ignoreBlock = false,
	onHit = function(attackerChar, victimChar, attackerRoot)
		RagdollService.applyRagdoll(victimChar, Vector3.new(0, 60, 0))
	end,
}

return Lunar
