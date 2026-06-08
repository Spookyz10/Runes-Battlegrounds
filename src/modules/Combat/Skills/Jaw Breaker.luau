local JawBreaker = {}

local ServerStorage = game:GetService("ServerStorage")
local CombatService = require(ServerStorage.Modules.Combat.CombatService)
local RagdollService = require(ServerStorage.Modules.RagdollService)

local ATTACK_DATA = {
	windup = 0.35,
	endlag = 0.55,
	endlagMiss = 0.75,
	hitbox = Vector3.new(6, 7, 5),
	hitboxOffset = Vector3.new(0, 1, -2),
	canMove = false,
	cancelTier = 1,
	interruptTier = 1,
	ignoreIframe = 1,
	ignoreCounterTier = 0,
	ignoreInterrupt = 1,
	ignoreBlock = false,
	onHit = function(attackerChar, victimChar, attackerRoot)
		local forward = attackerRoot.CFrame.LookVector
		RagdollService.applyRagdoll(victimChar, Vector3.new(forward.X * 18, 90, forward.Z * 18), 2.5)
	end,
}

function JawBreaker.execute(player, character)
	CombatService.executeAttack(player, character, ATTACK_DATA, { character })
end

return JawBreaker
