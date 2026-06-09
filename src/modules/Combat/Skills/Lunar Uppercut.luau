local LunarUppercut = {}

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CombatState = require(script.Parent.Parent.CombatState)
local CombatService = require(script.Parent.Parent.CombatService)
local CooldownService = require(ServerStorage.Modules.CooldownService)
local HitboxService = require(ServerStorage.Modules.HitboxService)
local RagdollService = require(ServerStorage.Modules.RagdollService)
local LaunchService = require(ServerStorage.Modules.LaunchService)
local StunService = require(ServerStorage.Modules.StunService)
local AirborneService = require(ServerStorage.Modules.AirborneService)
local DamageService = require(ServerStorage.Modules.DamageService)

-- ─── Config ──────────────────────────────────────────────────────────────────

local COOLDOWN = 12

local UPPERCUT_WINDUP = 0.35
local UPPERCUT_HITBOX = Vector3.new(6, 7, 5)
local UPPERCUT_DAMAGE = 15

local FLOAT_HEIGHT_OFFSET = 18 -- studs acima da posição atual da vítima
local FLOAT_DURATION = 4.5 -- tempo máximo presa no ar

local ATTACKER_FLOAT_OFFSET = 2 -- attacker flutua um pouco abaixo da vítima
local ATTACKER_RISE_DELAY = 0.5 -- espera antes de começar a subir
local ATTACKER_RISE_SPEED = 40

local SLAM_WINDUP = 0.8 -- pausa no ar antes do slam
local SLAM_DAMAGE = 25
local SLAM_HORIZONTAL = 180
local SLAM_VERTICAL = 12
local SLAM_LANDING = { horizontal = 22, vertical = 5 }

local CANCEL_TIER = 2
local INTERRUPT_TIER = 1
local IGNORE_IFRAME = 1
local IGNORE_COUNTER = 0

local ENDLAG = 0.55

local VFXRemotes = ReplicatedStorage.Remotes.VFX

-- ─── ShiftLock disable ───────────────────────────────────────────────────────
-- Força o personagem a não rotacionar pelo mouse do cliente enquanto ativo.
-- Feito mandando o CFrame do root travado no servidor a cada frame.
-- Técnica simples: PlatformStand + AutoRotate = false.

local function lockFacing(character, humanoid)
	humanoid.AutoRotate = false
end

local function unlockFacing(humanoid)
	humanoid.AutoRotate = true
end

-- ─── canHit ──────────────────────────────────────────────────────────────────

local function canHit(victimChar, attackerChar, attackerRoot)
	local victimPlayer = Players:GetPlayerFromCharacter(victimChar)
	if not victimPlayer then
		return true
	end

	local victimState = CombatState.get(victimPlayer)
	local victimRoot = victimChar:FindFirstChild("HumanoidRootPart")

	if victimState.iframeType > IGNORE_IFRAME then
		return false
	end

	if victimState.isCountering and victimState.counterTier > IGNORE_COUNTER then
		victimState.counterTriggered = true
		victimState.counterTarget = attackerChar
		return false
	end

	if victimState.isBlocking and victimRoot then
		local toAttacker = (attackerRoot.Position - victimRoot.Position)
		toAttacker = Vector3.new(toAttacker.X, 0, toAttacker.Z).Unit
		if toAttacker:Dot(victimRoot.CFrame.LookVector) > 0 then
			return false
		end
	end

	if victimState.inAttack and victimState.interruptTier <= INTERRUPT_TIER then
		CombatService.forceInterrupt(victimPlayer, victimChar)
	end

	return true
end

-- ─── riseAttacker ────────────────────────────────────────────────────────────
-- Sobe o atacante até targetY usando AirborneService em modo lock=true.
-- Retorna uma promise-like: chama onDone() quando chega lá.

local function riseAttacker(character, humanoid, targetY, onDone)
	humanoid.WalkSpeed = 0

	-- Usa AirborneService pra subir + travar na Y
	AirborneService.apply(character, targetY, true)

	-- Espera chegar perto o suficiente
	local root = character:FindFirstChild("HumanoidRootPart")
	task.spawn(function()
		while root and root.Parent do
			if math.abs(root.Position.Y - targetY) <= 1.5 then
				break
			end
			task.wait()
		end
		if onDone then
			onDone()
		end
	end)
end

-- ─── Execute ─────────────────────────────────────────────────────────────────

function LunarUppercut.execute(player, character)
	local state = CombatState.get(player)
	if state.inAttack or state.inEndlag then
		return
	end

	local ok = CooldownService.start(player, "LunarUppercut", COOLDOWN)
	if not ok then
		return
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid then
		return
	end

	state.inAttack = true
	state.cancelTier = CANCEL_TIER
	state.interruptTier = INTERRUPT_TIER
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0

	-- ── Windup ───────────────────────────────────────────────────────────────
	task.wait(UPPERCUT_WINDUP)

	if not state.inAttack then
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		return
	end

	-- ── Hitbox inicial ───────────────────────────────────────────────────────
	local hits = HitboxService.query({
		origin = root.CFrame,
		size = UPPERCUT_HITBOX,
		exclude = { character },
	})

	local validVictim = nil
	for _, victimChar in hits do
		if canHit(victimChar, character, root) then
			validVictim = victimChar
			break
		end
	end

	if not validVictim then
		state.inAttack = false
		state.inEndlag = true
		state.cancelTier = 0
		task.wait(0.4)
		state.inEndlag = false
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		return
	end

	local victimRoot = validVictim:FindFirstChild("HumanoidRootPart")
	if not victimRoot then
		state.inAttack = false
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		return
	end

	DamageService.apply(validVictim, UPPERCUT_DAMAGE)

	-- ── Lança vítima pro ar ──────────────────────────────────────────────────
	local targetY = victimRoot.Position.Y + FLOAT_HEIGHT_OFFSET

	RagdollService.apply(validVictim)
	StunService.apply(validVictim, FLOAT_DURATION + 2)

	-- Impulso inicial pra subir
	for _, part in validVictim:GetDescendants() do
		if part:IsA("BasePart") then
			part.AssemblyLinearVelocity = Vector3.new(0, 55, 0)
		end
	end

	-- AirborneService trava a vítima na targetY com lock=true
	AirborneService.apply(validVictim, targetY, true, FLOAT_DURATION)

	-- ── Disable shiftlock / AutoRotate do atacante ───────────────────────────
	lockFacing(character, humanoid)

	-- ── Atacante sobe até perto da vítima ────────────────────────────────────
	task.wait(ATTACKER_RISE_DELAY)

	if not state.inAttack then
		AirborneService.release(validVictim)
		RagdollService.remove(validVictim)
		StunService.clear(validVictim)
		unlockFacing(humanoid)
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		return
	end

	local attackerTargetY = targetY - ATTACKER_FLOAT_OFFSET
	local riseReady = false

	riseAttacker(character, humanoid, attackerTargetY, function()
		riseReady = true
	end)

	-- Espera subir ou ser interrompido (timeout de segurança de 3s)
	local riseTimeout = 0
	while not riseReady and state.inAttack do
		local dt = task.wait()
		riseTimeout += dt
		if riseTimeout > 3 then
			break
		end
	end

	if not state.inAttack then
		AirborneService.release(character)
		AirborneService.release(validVictim)
		RagdollService.remove(validVictim)
		StunService.clear(validVictim)
		unlockFacing(humanoid)
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 50
		humanoid.WalkSpeed = 16
		return
	end

	-- ── Pausa no ar (slam windup) ────────────────────────────────────────────
	task.wait(SLAM_WINDUP)

	if not state.inAttack then
		AirborneService.release(character)
		AirborneService.release(validVictim)
		RagdollService.remove(validVictim)
		StunService.clear(validVictim)
		unlockFacing(humanoid)
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		return
	end

	-- ── Slam — hitbox centrada NO VICTIM, não na frente do attacker ──────────
	-- O victim foi travado na targetY; só conferimos se ainda está lá.
	-- Não tem como errar: usamos o victimRoot diretamente como origem.
	local victimStillAirborne = AirborneService.isAirborne(validVictim) and validVictim.Parent ~= nil

	AirborneService.release(character)
	AirborneService.release(validVictim)
	unlockFacing(humanoid)

	if victimStillAirborne then
		DamageService.apply(validVictim, SLAM_DAMAGE)

		RagdollService.remove(validVictim)
		StunService.clear(validVictim)

		-- Direção do slam = da posição atual do root do attacker pro victim
		-- (não usa LookVector, então shiftlock não interfere)
		local toVictim = (victimRoot.Position - root.Position)
		local dir = Vector3.new(toVictim.X, 0, toVictim.Z)
		if dir.Magnitude > 0.01 then
			dir = dir.Unit
		else
			dir = root.CFrame.LookVector
		end

		LaunchService.apply(
			validVictim,
			Vector3.new(dir.X * SLAM_HORIZONTAL, SLAM_VERTICAL, dir.Z * SLAM_HORIZONTAL),
			SLAM_LANDING
		)
	else
		-- Vítima escapou (rara edge-case), limpa mesmo assim
		if RagdollService.isRagdolled(validVictim) then
			RagdollService.remove(validVictim)
		end
		StunService.clear(validVictim)
	end

	-- ── Endlag ───────────────────────────────────────────────────────────────
	humanoid.WalkSpeed = 0
	state.inAttack = false
	state.inEndlag = true
	state.cancelTier = 0

	task.wait(ENDLAG)

	state.inEndlag = false
	humanoid.WalkSpeed = 16
	humanoid.JumpPower = 50
end

return LunarUppercut
