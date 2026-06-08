--[[
	Skill: Lunar Lunge
	src/modules/Combat/Skills/Lunar Lunge.luau

	Servidor:
	  1. Verifica cooldown
	  2. Dispara VFXRemotes.SkillEffect para TODOS os clientes (com dados do dash)
	  3. Executa o dash via BodyVelocity
	  4. Ao terminar o dash, cria hitbox ao redor do personagem
	  5. Quem for acertado: recebe stun (PlatformStand por STUN_DURATION)
	  6. É bloqueável normalmente

	VFX é 100% no cliente — o servidor só manda o sinal com os dados necessários.
]]

local LunarLunge = {}

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CombatState = require(script.Parent.Parent.CombatState)
local CombatService = require(script.Parent.Parent.CombatService)
local CooldownService = require(ServerStorage.Modules.CooldownService)
local HitboxService = require(ServerStorage.Modules.HitboxService)
local KnockbackService = require(ServerStorage.Modules.KnockbackService)

-- ─── Configuração ────────────────────────────────────────────────────────────

local COOLDOWN = 12 -- segundos
local DASH_SPEED = 80 -- studs/s durante o dash
local DASH_DURATION = 0.35 -- segundos de dash
local HITBOX_SIZE = Vector3.new(10, 10, 10) -- hitbox ao redor após o dash
local STUN_DURATION = 1.2 -- segundos de stun em quem for acertado
local ENDLAG = 0.45 -- endlag após o hitbox

-- Tier de interrupt/iframe da skill
local INTERRUPT_TIER = 1
local IGNORE_IFRAME = 1
local IGNORE_COUNTER = 0
local CANCEL_TIER = 2 -- ininterruptível pelo próprio jogador durante o dash

-- Remote de VFX (criado em ReplicatedStorage.Remotes.VFX)
local VFXRemotes = ReplicatedStorage.Remotes.VFX

-- ─── Helpers ─────────────────────────────────────────────────────────────────

local function applyStun(victimChar, duration)
	local humanoid = victimChar:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	humanoid.PlatformStand = true
	task.delay(duration, function()
		if humanoid and humanoid.Parent then
			humanoid.PlatformStand = false
		end
	end)
end

local function doDash(character, direction, speed, duration)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local bv = Instance.new("BodyVelocity")
	bv.Velocity = direction * speed
	bv.MaxForce = Vector3.new(1e5, 0, 1e5) -- não afeta Y (mantém gravidade)
	bv.P = 1e4
	bv.Parent = root

	task.wait(duration)

	bv:Destroy()
end

-- ─── Execute ─────────────────────────────────────────────────────────────────

function LunarLunge.execute(player, character)
	local state = CombatState.get(player)
	if state.inAttack or state.inEndlag then
		return
	end

	local ok = CooldownService.start(player, "LunarLunge", COOLDOWN)
	if not ok then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end

	-- Direção do dash (look vector do personagem, sem Y)
	local dir = root.CFrame.LookVector
	dir = Vector3.new(dir.X, 0, dir.Z).Unit

	-- Estado de ataque
	state.inAttack = true
	state.cancelTier = CANCEL_TIER
	state.interruptTier = INTERRUPT_TIER
	humanoid.JumpPower = 0

	-- ── Notifica TODOS os clientes para rodar o VFX de dash ──────────────────
	-- Payload: { skill = "LunarLunge", phase = "dash", caster = character, direction = dir }
	VFXRemotes.SkillEffect:FireAllClients("Lunar Lunge", "dash", character, dir)

	-- ── Dash ─────────────────────────────────────────────────────────────────
	doDash(character, dir, DASH_SPEED, DASH_DURATION)

	-- Checa se foi interrompido durante o dash
	if not state.inAttack then
		humanoid.JumpPower = 50
		return
	end

	-- ── Notifica clientes para o VFX de impacto (hitbox visual) ──────────────
	VFXRemotes.SkillEffect:FireAllClients("LunarLunge", "impact", character, dir)

	-- ── Hitbox ao redor após o dash ───────────────────────────────────────────
	local hits = HitboxService.query({
		origin = root.CFrame,
		size = HITBOX_SIZE,
		exclude = { character },
		-- Bloqueável: filtro de block é feito manualmente abaixo
	})

	for _, victimChar in hits do
		local victimPlayer = Players:GetPlayerFromCharacter(victimChar)
		if not victimPlayer then
			continue
		end

		local victimState = CombatState.get(victimPlayer)
		local victimRoot = victimChar:FindFirstChild("HumanoidRootPart")
		if not victimRoot then
			continue
		end

		-- Iframe
		if victimState.iframeType > IGNORE_IFRAME then
			continue
		end

		-- Counter
		if victimState.isCountering and victimState.counterTier > IGNORE_COUNTER then
			victimState.counterTriggered = true
			victimState.counterTarget = character
			continue
		end

		-- Block (bloqueável)
		if victimState.isBlocking then
			local toAttacker = (root.Position - victimRoot.Position)
			toAttacker = Vector3.new(toAttacker.X, 0, toAttacker.Z).Unit
			if toAttacker:Dot(victimRoot.CFrame.LookVector) > 0 then
				-- VFX de block no cliente
				VFXRemotes.SkillEffect:FireAllClients("LunarLunge", "blocked", victimChar, dir)
				continue
			end
		end

		-- Interrupt
		if victimState.inAttack and victimState.interruptTier <= INTERRUPT_TIER then
			CombatService.forceInterrupt(victimPlayer, victimChar)
		end

		-- Aplica stun
		applyStun(victimChar, STUN_DURATION)

		-- Knockback leve pra afastar
		KnockbackService.applyFromHit(victimChar, root.Position, 25, 10)

		-- VFX de hit no cliente
		VFXRemotes.SkillEffect:FireAllClients("LunarLunge", "hit", victimChar, dir)
	end

	-- ── Endlag ────────────────────────────────────────────────────────────────
	state.inAttack = false
	state.inEndlag = true

	task.wait(ENDLAG)

	state.inEndlag = false
	state.cancelTier = 0
	humanoid.JumpPower = 50
end

return LunarLunge
