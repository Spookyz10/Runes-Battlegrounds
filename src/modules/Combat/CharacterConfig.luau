--[[
	CharacterConfig
	Cada ataque tem os seguintes campos:

	windup          number    segundos antes da hitbox sair
	endlag          number    endlag apos acertar
	endlagMiss      number?   endlag se errar (nil = igual endlag)
	hitbox          Vector3   tamanho da hitbox
	hitboxOffset    Vector3?  offset relativo ao HumanoidRootPart (nil = (0,0,-hitbox.Z/2))
	canMove         bool      pode andar durante o ataque

	-- Cancelabilidade pelo PROPRIO JOGADOR:
	cancelTier      number
	    0 = pode cancelar livremente (ex: dash cancela)
	    1 = so cancela se receber knockback
	    2 = inparavel pelo proprio jogador

	-- Resistencia a ser interrompido por INIMIGOS:
	interruptTier   number
	    0 = qualquer hit com ignoreInterrupt >= 0 interrompe
	    1 = so ignoreInterrupt >= 1 interrompe
	    2 = so ignoreInterrupt >= 2 interrompe
	    3 = absolutamente ininterruptivel por qualquer hit

	-- O ataque ignora iframes da vitima com iframeType <= ignoreIframe
	ignoreIframe    number    (0 = respeita todos)

	-- O ataque ignora counters da vitima com counterTier <= ignoreCounterTier
	ignoreCounterTier  number  (0 = respeita todos os counters)

	-- O ataque ignora o interrupt do atacante com interruptTier <= ignoreInterrupt
	ignoreInterrupt    number  (0 = nao forca interrupcao em ninguem)

	ignoreBlock     bool      ignora block
	onHit           function? (attackerChar, victimChar, attackerRoot) -> nil
	onBlock         function? (attackerChar, victimChar, attackerRoot) -> nil
	onCountered     function? (attackerChar, victimChar) -> nil
	knockback       { horizontal, vertical, duration }?
]]

local RagdollService = game:GetService("ServerStorage").Modules.RagdollService
local KnockbackService = game:GetService("ServerStorage").Modules.KnockbackService

-- Lazy require para evitar ciclo (CharacterConfig nao e require'd no load chain inicial)
local function RS()
	return require(RagdollService)
end
local function KS()
	return require(KnockbackService)
end

local CharacterConfig = {}

CharacterConfig["Vitality"] = {
	m1 = {
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
		-- Finalizador Vitality: lanca pra frente
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
				local launchVec = Vector3.new(forward.X * 55, 8, forward.Z * 55)
				RS().applyRagdoll(victimChar, launchVec, 1.2)
			end,
		},
	},

	-- M1 no ar: downslam (ignora block — cai de cima)
	m1Air = {
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
			RS().applyRagdoll(victimChar, Vector3.new(0, -30, 0), 0.8)
		end,
	},

	-- Uppercut (segurando Space no chao): lanca oponente pra cima
	m1Uppercut = {
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
			RS().applyRagdoll(victimChar, Vector3.new(0, 60, 0), 1.5)
		end,
	},
}

return CharacterConfig
