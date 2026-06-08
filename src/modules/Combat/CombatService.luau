--[[
	CombatService
	src/modules/Combat/CombatService.luau
]]

local CombatService = {}

local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local HitboxService = require(ServerStorage.Modules.HitboxService)
local KnockbackService = require(ServerStorage.Modules.KnockbackService)
local RagdollService = require(ServerStorage.Modules.RagdollService)
local CombatState = require(script.Parent.CombatState)

-- ─── Verificações de hit ─────────────────────────────────────────────────────

local function passesIframe(attackData, victimState)
	return attackData.ignoreIframe >= victimState.iframeType
end

local function passesBlock(attackData, attackerRoot, victimRoot)
	if attackData.ignoreBlock then
		return true
	end
	local toAttacker = (attackerRoot.Position - victimRoot.Position)
	toAttacker = Vector3.new(toAttacker.X, 0, toAttacker.Z).Unit
	return toAttacker:Dot(victimRoot.CFrame.LookVector) <= 0
end

local function passesCounter(attackData, victimState)
	if not victimState.isCountering then
		return true
	end
	return attackData.ignoreCounterTier >= victimState.counterTier
end

local function shouldInterrupt(attackData, victimState)
	if not victimState.inAttack then
		return false
	end
	return attackData.ignoreInterrupt >= victimState.interruptTier
end

-- ─── executeAttack ───────────────────────────────────────────────────────────

function CombatService.executeAttack(player, character, attackData, exclude, onHitConfirmed)
	local state = CombatState.get(player)

	state.inAttack = true
	state.cancelTier = attackData.cancelTier
	state.interruptTier = attackData.interruptTier

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	humanoid.JumpPower = 0

	task.wait(attackData.windup)

	if not state.inAttack then
		humanoid.JumpPower = 50
		return false
	end

	local root = character:FindFirstChild("HumanoidRootPart")

	-- Query usando a nova API do HitboxService
	local hits = HitboxService.query({
		origin = root.CFrame,
		size = attackData.hitbox,
		offset = attackData.hitboxOffset, -- nil é aceito (usa Vector3.zero)
		exclude = exclude or { character },
	})

	local didHit = false

	for _, victimChar in hits do
		local victimPlayer = Players:GetPlayerFromCharacter(victimChar)
		if not victimPlayer then
			continue
		end
		local victimState = CombatState.get(victimPlayer)
		local victimRoot = victimChar:FindFirstChild("HumanoidRootPart")

		if not passesIframe(attackData, victimState) then
			continue
		end

		if not passesCounter(attackData, victimState) then
			if state.cancelTier >= 1 then
				CombatService.interruptSelf(player, character)
			end
			victimState.counterTriggered = true
			victimState.counterTarget = character
			continue
		end

		local blocked = victimState.isBlocking and not passesBlock(attackData, root, victimRoot)
		if blocked then
			if attackData.onBlock then
				attackData.onBlock(character, victimChar, root)
			end
			continue
		end

		if shouldInterrupt(attackData, victimState) then
			CombatService.forceInterrupt(victimPlayer, victimChar)
		end

		if attackData.onHit then
			attackData.onHit(character, victimChar, root)
		elseif attackData.knockback then
			local kb = attackData.knockback
			if not RagdollService.isRagdolled(victimChar) then
				RagdollService.applyRagdoll(victimChar, nil, kb.duration > 0 and kb.duration or nil)
			end
			KnockbackService.applyFromHit(victimChar, root.Position, kb.horizontal, kb.vertical)
		end

		if onHitConfirmed then
			onHitConfirmed(victimChar)
		end
		didHit = true
	end

	state.inAttack = false
	state.inEndlag = true

	local lag = didHit and attackData.endlag or (attackData.endlagMiss or attackData.endlag)
	task.wait(lag)

	state.inEndlag = false
	state.cancelTier = 0
	humanoid.JumpPower = 50

	return didHit
end

-- ─── Helpers de estado ───────────────────────────────────────────────────────

function CombatService.interruptSelf(player, character)
	local state = CombatState.get(player)
	state.inAttack = false
	state.inEndlag = false
	state.cancelTier = 0
	character:FindFirstChildOfClass("Humanoid").JumpPower = 50
end

function CombatService.selfCancel(player, character)
	local state = CombatState.get(player)
	if not state.inAttack or state.cancelTier > 0 then
		return
	end
	CombatService.interruptSelf(player, character)
end

function CombatService.knockbackCancel(player, character)
	local state = CombatState.get(player)
	if not state.inAttack or state.cancelTier >= 2 then
		return
	end
	CombatService.interruptSelf(player, character)
end

function CombatService.forceInterrupt(player, character)
	if not CombatState.get(player).inAttack then
		return
	end
	CombatService.interruptSelf(player, character)
end

-- ─── M1 ──────────────────────────────────────────────────────────────────────

function CombatService.m1(player, character, config, isAir, isUppercut)
	local state = CombatState.get(player)
	if state.inAttack or state.inEndlag then
		return
	end

	local attackData

	if isAir then
		attackData = config.m1Air
	elseif isUppercut then
		attackData = config.m1Uppercut
	else
		local now = tick()
		if now - state.lastAttackTime > config.comboWindow then
			state.comboStep = 0
		end
		state.comboStep = (state.comboStep % #config.m1) + 1
		state.lastAttackTime = now
		attackData = config.m1[state.comboStep]
	end

	CombatService.executeAttack(player, character, attackData, { character })
end

-- ─── Block ───────────────────────────────────────────────────────────────────

function CombatService.blockStart(player)
	CombatState.set(player, "isBlocking", true)
end

function CombatService.blockEnd(player)
	CombatState.set(player, "isBlocking", false)
end

-- ─── Iframe ──────────────────────────────────────────────────────────────────

function CombatService.setIframe(player, tier)
	CombatState.set(player, "iframeType", tier)
end

function CombatService.clearIframe(player)
	CombatState.set(player, "iframeType", 0)
end

-- ─── Counter ─────────────────────────────────────────────────────────────────

function CombatService.activateCounter(player, tier)
	local state = CombatState.get(player)
	state.isCountering = true
	state.counterTier = tier
	state.counterTriggered = false
	state.counterTarget = nil
end

function CombatService.deactivateCounter(player)
	local state = CombatState.get(player)
	state.isCountering = false
	state.counterTier = 0
	state.counterTriggered = false
	state.counterTarget = nil
end

return CombatService
