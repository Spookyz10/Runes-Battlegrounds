--[[
	Skill: Lunar Uppercut
	src/modules/Combat/Skills/Lunar Uppercut.luau
]]

local LunarUppercut = {}

local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local CombatState = require(script.Parent.Parent.CombatState)
local CombatService = require(script.Parent.Parent.CombatService)
local CooldownService = require(ServerStorage.Modules.CooldownService)
local HitboxService = require(ServerStorage.Modules.HitboxService)
local RagdollService = require(ServerStorage.Modules.RagdollService)
local LaunchService = require(ServerStorage.Modules.LaunchService)
local StunService = require(ServerStorage.Modules.StunService)

-- ─── Config ──────────────────────────────────────────────────────────────────

local COOLDOWN = 1

local UPPERCUT_WINDUP = 0.35
local UPPERCUT_HITBOX = Vector3.new(6, 7, 5)

local PEAK_HEIGHT = 18
local VICTIM_TRAVEL_TIME = 0.45
local VICTIM_EASING = Enum.EasingStyle.Sine -- suave, parece uppercut

local ATTACKER_BACK_OFFSET = 3
local ATTACKER_TRAVEL_TIME = 0.35
local ATTACKER_EASING = Enum.EasingStyle.Quad

local SLAM_WINDUP = 0.2
local SLAM_HITBOX = Vector3.new(7, 6, 6)

local SLAM_LAUNCH_HORIZONTAL = 200
local SLAM_LAUNCH_VERTICAL = 15
local SLAM_LANDING_IMPACT = { horizontal = 25, vertical = 5 }

local CANCEL_TIER = 2
local INTERRUPT_TIER = 1
local IGNORE_IFRAME = 1
local IGNORE_COUNTER = 0

local ENDLAG = 0.55

-- ─── Helpers ─────────────────────────────────────────────────────────────────

-- Trava o personagem no ar (anula gravidade, desativa física)
local function freezeInAir(character)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	if root:FindFirstChild("UppercutFreeze") then
		return
	end

	local bv = Instance.new("BodyVelocity")
	bv.Name = "UppercutFreeze"
	bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bv.Velocity = Vector3.zero
	bv.P = 1e5
	bv.Parent = root

	local hum = character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = true
	end
end

local function unfreezeInAir(character)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local bv = root:FindFirstChild("UppercutFreeze")
	if bv then
		bv:Destroy()
	end
	local hum = character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = false
	end
end

-- Move o HumanoidRootPart via Tween (sem gravidade interferindo)
-- Retorna o Tween criado para poder cancelar se necessário
local function tweenTo(character, targetPos, duration, easingStyle)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end

	local info = TweenInfo.new(duration, easingStyle, Enum.EasingDirection.Out)
	local tween =
		TweenService:Create(root, info, { CFrame = CFrame.new(targetPos) * (root.CFrame - root.CFrame.Position) })
	tween:Play()
	return tween
end

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

local function cleanup(humanoid, victimChar, attackerChar)
	humanoid.WalkSpeed = 16
	humanoid.JumpPower = 50
	humanoid.PlatformStand = false
	unfreezeInAir(attackerChar)
	if victimChar then
		unfreezeInAir(victimChar)
		if RagdollService.isRagdolled(victimChar) then
			RagdollService.remove(victimChar)
		end
		StunService.clear(victimChar)
	end
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

	-- ── Fase 1: Uppercut windup ─────────────────────────────────────────────
	task.wait(UPPERCUT_WINDUP)

	if not state.inAttack then
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		return
	end

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

	-- ── Calcula destinos ────────────────────────────────────────────────────
	local peakPos = victimRoot.Position + Vector3.new(0, PEAK_HEIGHT, 0)
	local attackerPeakPos = peakPos

	-- ── Fase 2a: Vítima sobe via Tween ─────────────────────────────────────
	RagdollService.apply(validVictim)
	StunService.apply(validVictim, 999)
	freezeInAir(validVictim) -- anula gravidade durante o tween

	local victimTween = tweenTo(validVictim, peakPos, VICTIM_TRAVEL_TIME, VICTIM_EASING)
	if victimTween then
		victimTween.Completed:Wait()
	end

	if not state.inAttack then
		cleanup(humanoid, validVictim, character)
		state.inAttack = false
		state.cancelTier = 0
		return
	end

	-- ── Fase 2b: Attacker sobe via Tween ───────────────────────────────────
	freezeInAir(character) -- attacker também sem gravidade durante o tween
	humanoid.PlatformStand = true

	local attackerTween = tweenTo(character, attackerPeakPos, ATTACKER_TRAVEL_TIME, ATTACKER_EASING)
	if attackerTween then
		attackerTween.Completed:Wait()
	end

	if not state.inAttack then
		cleanup(humanoid, validVictim, character)
		state.inAttack = false
		state.cancelTier = 0
		return
	end

	-- ── Fase 3: Slam windup ─────────────────────────────────────────────────
	task.wait(SLAM_WINDUP)

	if not state.inAttack then
		cleanup(humanoid, validVictim, character)
		state.inAttack = false
		state.cancelTier = 0
		return
	end

	local slamHits = HitboxService.query({
		origin = root.CFrame,
		size = SLAM_HITBOX,
		exclude = { character },
	})

	local slamHit = false
	for _, victimChar in slamHits do
		if victimChar == validVictim then
			slamHit = true

			unfreezeInAir(victimChar)
			RagdollService.remove(victimChar)
			StunService.clear(victimChar)

			local dir = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z).Unit
			LaunchService.apply(
				victimChar,
				Vector3.new(dir.X * SLAM_LAUNCH_HORIZONTAL, SLAM_LAUNCH_VERTICAL, dir.Z * SLAM_LAUNCH_HORIZONTAL),
				SLAM_LANDING_IMPACT
			)
			break
		end
	end

	if not slamHit then
		unfreezeInAir(validVictim)
		if RagdollService.isRagdolled(validVictim) then
			RagdollService.remove(validVictim)
		end
		StunService.clear(validVictim)
	end

	-- Libera attacker
	unfreezeInAir(character)
	humanoid.PlatformStand = false

	state.inAttack = false
	state.inEndlag = true
	state.cancelTier = 0
	task.wait(ENDLAG)
	state.inEndlag = false
	humanoid.WalkSpeed = 16
	humanoid.JumpPower = 50
end

return LunarUppercut
