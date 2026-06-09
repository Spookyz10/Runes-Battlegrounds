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

local COOLDOWN = 1

local UPPERCUT_WINDUP = 0.35
local UPPERCUT_HITBOX = Vector3.new(6, 7, 5)
local UPPERCUT_DAMAGE = 15

local FLOAT_HEIGHT_OFFSET = 18
local FLOAT_DURATION = 4.5

local ATTACKER_FLOAT_OFFSET = 2
local ATTACKER_RISE_DELAY = 0.5

local SLAM_WINDUP = 0.8
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

local function cleanupAttacker(character, humanoid)
	AirborneService.release(character)
	humanoid.PlatformStand = false
	humanoid.AutoRotate = true
	humanoid.WalkSpeed = 16
	humanoid.JumpPower = 50
end

local function cleanupVictim(victimChar)
	AirborneService.release(victimChar)
	if RagdollService.isRagdolled(victimChar) then
		RagdollService.remove(victimChar)
	end
	StunService.clear(victimChar)
end

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

	-- ── Hitbox ───────────────────────────────────────────────────────────────
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
	AirborneService.apply(validVictim, targetY, true, FLOAT_DURATION)

	humanoid.AutoRotate = false

	-- ── Delay antes de subir ─────────────────────────────────────────────────
	task.wait(ATTACKER_RISE_DELAY)

	if not state.inAttack then
		cleanupVictim(validVictim)
		humanoid.AutoRotate = true
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		return
	end

	-- ── Sobe o attacker ──────────────────────────────────────────────────────
	-- PlatformStand desliga o controle do Humanoid sobre a física,
	-- permitindo que o AirborneService mova o personagem com velocidade direta.
	humanoid.PlatformStand = true

	local attackerTargetY = targetY - ATTACKER_FLOAT_OFFSET
	AirborneService.apply(character, attackerTargetY, true)

	-- Espera chegar na Y alvo (timeout 3s)
	local riseTimeout = 0
	while root.Parent and math.abs(root.Position.Y - attackerTargetY) > 1.5 do
		local dt = task.wait()
		riseTimeout += dt
		if riseTimeout > 3 or not state.inAttack then
			break
		end
	end

	if not state.inAttack then
		cleanupAttacker(character, humanoid)
		cleanupVictim(validVictim)
		return
	end

	-- ── Slam windup no ar ────────────────────────────────────────────────────
	task.wait(SLAM_WINDUP)

	if not state.inAttack then
		cleanupAttacker(character, humanoid)
		cleanupVictim(validVictim)
		return
	end

	-- ── Slam ─────────────────────────────────────────────────────────────────
	local victimStillAirborne = AirborneService.isAirborne(validVictim) and validVictim.Parent ~= nil

	cleanupAttacker(character, humanoid)

	if victimStillAirborne then
		DamageService.apply(validVictim, SLAM_DAMAGE)
		AirborneService.release(validVictim)
		RagdollService.remove(validVictim)
		StunService.clear(validVictim)

		local toVictim = victimRoot.Position - root.Position
		local dir = Vector3.new(toVictim.X, 0, toVictim.Z)
		dir = dir.Magnitude > 0.01 and dir.Unit or root.CFrame.LookVector

		LaunchService.apply(
			validVictim,
			Vector3.new(dir.X * SLAM_HORIZONTAL, SLAM_VERTICAL, dir.Z * SLAM_HORIZONTAL),
			SLAM_LANDING
		)
	else
		cleanupVictim(validVictim)
	end

	-- ── Endlag ───────────────────────────────────────────────────────────────
	state.inAttack = false
	state.inEndlag = true
	state.cancelTier = 0

	task.wait(ENDLAG)

	state.inEndlag = false
end

return LunarUppercut
