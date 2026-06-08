local CombatService = {}

local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local HitboxService = require(ServerStorage.Modules.HitboxService)
local KnockbackService = require(ServerStorage.Modules.KnockbackService)
local RagdollService = require(ServerStorage.Modules.RagdollService)
local CombatState = require(script.Parent.CombatState)
local CharacterConfig = require(script.Parent.CharacterConfig)

local COMBO_STEPS = 4
local COMBO_RESET_TIME = 1.8

-- ─── Validacoes de hit ───────────────────────────────────────────────────────

-- O ataque passa pelo iframe da vitima?
local function passesIframe(attackData, victimState)
	return attackData.ignoreIframe >= victimState.iframeType
end

-- O ataque passa pelo block da vitima?
-- Block so protege a frente. Downslam (ignoreBlock) passa sempre.
local function passesBlock(attackData, attackerRoot, victimRoot)
	if attackData.ignoreBlock then
		return true
	end
	-- Vitima esta bloqueando?
	local toAttacker = (attackerRoot.Position - victimRoot.Position)
	toAttacker = Vector3.new(toAttacker.X, 0, toAttacker.Z).Unit
	-- dot > 0: atacante esta na frente da vitima (vitima olha pra ele)
	return toAttacker:Dot(victimRoot.CFrame.LookVector) <= 0
end

-- O ataque passa pelo counter da vitima?
local function passesCounter(attackData, victimState)
	if not victimState.isCountering then
		return true
	end
	return attackData.ignoreCounterTier >= victimState.counterTier
end

-- O hit interrompe o ataque atual do attackerPlayer da vitima?
-- (Ex: vitima esta em grab, mas recebe um ignoreInterrupt=3 → interrompe)
local function shouldInterrupt(attackData, victimState)
	if not victimState.inAttack then
		return false
	end
	return attackData.ignoreInterrupt >= victimState.interruptTier
end

-- ─── Execucao de ataque ──────────────────────────────────────────────────────

--[[
	executeAttack
	Roda o pipeline: windup → hitbox → resolucao de hits → endlag
	Pode ser chamado por M1s, skills, qualquer coisa.

	attackData: tabela do CharacterConfig (ou inline da skill)
	exclude: lista de characters a ignorar na hitbox (normalmente { character })
	onHitConfirmed: callback(victimChar) opcional por hit confirmado
]]
function CombatService.executeAttack(player, character, attackData, exclude, onHitConfirmed)
	local state = CombatState.get(player)

	state.inAttack = true
	state.cancelTier = attackData.cancelTier
	state.interruptTier = attackData.interruptTier

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	humanoid.JumpPower = 0

	-- Windup
	task.wait(attackData.windup)

	if not state.inAttack then
		humanoid.JumpPower = 50
		return false
	end

	-- Hitbox
	local root = character:FindFirstChild("HumanoidRootPart")
	local offset = attackData.hitboxOffset or Vector3.new(0, 0, -(attackData.hitbox.Z / 2))
	local cf = root.CFrame * CFrame.new(offset)
	local hits = HitboxService.query(cf, attackData.hitbox, exclude or { character })

	local didHit = false

	for _, victimChar in hits do
		local victimPlayer = Players:GetPlayerFromCharacter(victimChar)
		if not victimPlayer then
			continue
		end
		local victimState = CombatState.get(victimPlayer)
		local victimRoot = victimChar:FindFirstChild("HumanoidRootPart")

		-- 1. Iframe
		if not passesIframe(attackData, victimState) then
			continue
		end

		-- 2. Counter
		-- Se o ataque nao ignorar o counter da vitima: cancela o atacante e
		-- aciona o counter (a skill de counter le counterTriggered)
		if not passesCounter(attackData, victimState) then
			-- So cancela se o attackerState permitir (cancelTier >= 1)
			if state.cancelTier >= 1 then
				CombatService.interruptSelf(player, character)
			end
			victimState.counterTriggered = true
			victimState.counterTarget = character
			continue
		end

		-- 3. Block
		local blocked = victimState.isBlocking and not passesBlock(attackData, root, victimRoot)
		if blocked then
			if attackData.onBlock then
				attackData.onBlock(character, victimChar, root)
			end
			continue
		end

		-- 4. Hit confirmado — interrompe a vitima se necessario
		if shouldInterrupt(attackData, victimState) then
			local victimP = Players:GetPlayerFromCharacter(victimChar)
			CombatService.forceInterrupt(victimP, victimChar)
		end

		-- Aplica efeito
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

	-- Endlag
	state.inAttack = false
	state.inEndlag = true

	local lag = didHit and attackData.endlag or (attackData.endlagMiss or attackData.endlag)

	task.wait(lag)
	state.inEndlag = false
	state.cancelTier = 0
	humanoid.JumpPower = 50

	return didHit
end

-- ─── Cancels / Interrupts ────────────────────────────────────────────────────

-- O proprio jogador cancela (se cancelTier == 0)
function CombatService.selfCancel(player, character)
	local state = CombatState.get(player)
	if not state.inAttack or state.cancelTier > 0 then
		return
	end
	CombatService.interruptSelf(player, character)
end

-- Interrompe o ataque do proprio player (sem checar tiers — uso interno)
function CombatService.interruptSelf(player, character)
	local state = CombatState.get(player)
	state.inAttack = false
	state.inEndlag = false
	state.cancelTier = 0
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	humanoid.JumpPower = 50
end

-- Forcado por knockback externo: respeita cancelTier
-- (cancelTier 2 = inparavel pelo proprio jogador, mas knockback externo
--  usa ignoreInterrupt no attackData — forcado via forceInterrupt abaixo)
function CombatService.knockbackCancel(player, character)
	local state = CombatState.get(player)
	if not state.inAttack then
		return
	end
	if state.cancelTier >= 2 then
		return
	end
	CombatService.interruptSelf(player, character)
end

-- Forcado por um hit com ignoreInterrupt suficiente (ja validado em executeAttack)
function CombatService.forceInterrupt(player, character)
	local state = CombatState.get(player)
	if not state.inAttack then
		return
	end
	CombatService.interruptSelf(player, character)
end

-- ─── M1 ──────────────────────────────────────────────────────────────────────

function CombatService.m1(player, character, isAir, isUppercut)
	local state = CombatState.get(player)
	if state.inAttack or state.inEndlag then
		return
	end

	local config = CharacterConfig[state.characterName]
	local attackData

	if isAir then
		attackData = config.m1Air
	elseif isUppercut then
		attackData = config.m1Uppercut
	else
		local now = tick()
		if now - state.lastAttackTime > COMBO_RESET_TIME then
			state.comboStep = 0
		end
		state.comboStep = (state.comboStep % COMBO_STEPS) + 1
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

-- ─── Iframe helpers (para skills usarem) ─────────────────────────────────────

function CombatService.setIframe(player, tier)
	CombatState.set(player, "iframeType", tier)
end

function CombatService.clearIframe(player)
	CombatState.set(player, "iframeType", 0)
end

-- ─── Counter helpers ─────────────────────────────────────────────────────────

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
