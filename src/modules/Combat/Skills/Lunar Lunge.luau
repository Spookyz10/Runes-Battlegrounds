local LunarLunge = {}

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CombatState = require(script.Parent.Parent.CombatState)
local CombatService = require(script.Parent.Parent.CombatService)
local CooldownService = require(ServerStorage.Modules.CooldownService)
local HitboxService = require(ServerStorage.Modules.HitboxService)
local KnockbackService = require(ServerStorage.Modules.KnockbackService)
local StunService = require(ServerStorage.Modules.StunService)
local DamageService = require(ServerStorage.Modules.DamageService)

local COOLDOWN = 8
local DASH_SPEED = 60
local DASH_DURATION = 0.4
local PRE_DASH_WINDUP = 0.2 -- animação antes do dash começar
local LATENCY_MARGIN = 0.15
local LINGER_DURATION = 0.3
local HITBOX_SIZE = Vector3.new(10, 10, 10)
local STUN_DURATION = 1.2
local KNOCKBACK_HORIZONTAL = 20
local KNOCKBACK_VERTICAL = 5
local DAMAGE = 20
local ENDLAG = 0.45
local INTERRUPT_TIER = 1
local IGNORE_IFRAME = 1
local IGNORE_COUNTER = 0
local CANCEL_TIER = 2

local VFXRemotes = ReplicatedStorage.Remotes.VFX
local SkillMovementRemote = VFXRemotes.SkillMovement

local function applyHit(victimChar, attackerChar, attackerRoot, dir)
	local victimRoot = victimChar:FindFirstChild("HumanoidRootPart")
	if not victimRoot then
		return
	end

	DamageService.apply(victimChar, DAMAGE)
	StunService.apply(victimChar, STUN_DURATION)
	KnockbackService.applyFromHit(victimChar, attackerRoot.Position, KNOCKBACK_HORIZONTAL, KNOCKBACK_VERTICAL)
	VFXRemotes.SkillEffect:FireAllClients("Lunar Lunge", "hit", victimChar, dir)
end

local function processHit(victimChar, attackerChar, attackerRoot, dir)
	local victimRoot = victimChar:FindFirstChild("HumanoidRootPart")
	if not victimRoot then
		return
	end

	local victimPlayer = Players:GetPlayerFromCharacter(victimChar)
	if not victimPlayer then
		applyHit(victimChar, attackerChar, attackerRoot, dir)
		return
	end

	local victimState = CombatState.get(victimPlayer)

	if victimState.iframeType > IGNORE_IFRAME then
		return
	end

	if victimState.isCountering and victimState.counterTier > IGNORE_COUNTER then
		victimState.counterTriggered = true
		victimState.counterTarget = attackerChar
		return
	end

	if victimState.isBlocking then
		local toAttacker = (attackerRoot.Position - victimRoot.Position)
		toAttacker = Vector3.new(toAttacker.X, 0, toAttacker.Z).Unit
		if toAttacker:Dot(victimRoot.CFrame.LookVector) > 0 then
			VFXRemotes.SkillEffect:FireAllClients("Lunar Lunge", "blocked", victimChar, dir)
			return
		end
	end

	if victimState.inAttack and victimState.interruptTier <= INTERRUPT_TIER then
		CombatService.forceInterrupt(victimPlayer, victimChar)
	end

	applyHit(victimChar, attackerChar, attackerRoot, dir)
end

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

	state.inAttack = true
	state.cancelTier = CANCEL_TIER
	-- interruptTier alto durante o dash: qualquer hit cancela tudo
	state.interruptTier = INTERRUPT_TIER

	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0

	-- ── Windup pré-dash ──────────────────────────────────────────────────────
	VFXRemotes.SkillEffect:FireAllClients("Lunar Lunge", "dash", character)
	task.wait(PRE_DASH_WINDUP)

	if not state.inAttack then
		-- Foi interrompido durante o windup
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		return
	end

	-- ── Dash (ainda é windup: se acertado aqui, cancela tudo) ───────────────
	SkillMovementRemote:FireClient(player, "Lunar Lunge", {
		speed = DASH_SPEED,
		duration = DASH_DURATION,
	})

	-- Enquanto dura o dash, checamos a cada frame se inAttack ainda é true.
	-- O CombatService.forceInterrupt já seta inAttack = false se acertado.
	local elapsed = 0
	while elapsed < DASH_DURATION + LATENCY_MARGIN do
		local dt = task.wait()
		elapsed += dt
		if not state.inAttack then
			-- Foi interrompido/acertado durante o dash — aborta tudo
			humanoid.WalkSpeed = 16
			humanoid.JumpPower = 50
			return
		end
	end

	-- ── Impacto ──────────────────────────────────────────────────────────────
	local dir = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z).Unit
	VFXRemotes.SkillEffect:FireAllClients("Lunar Lunge", "impact", character, dir)

	humanoid.WalkSpeed = 16
	humanoid.JumpPower = 50

	HitboxService.queryLinger({
		anchor = root,
		size = HITBOX_SIZE,
		duration = LINGER_DURATION,
		exclude = { character },
		onHit = function(victimChar)
			processHit(victimChar, character, root, dir)
		end,
	})

	state.inAttack = false
	state.inEndlag = true

	task.wait(ENDLAG)

	state.inEndlag = false
	state.cancelTier = 0
end

return LunarLunge
