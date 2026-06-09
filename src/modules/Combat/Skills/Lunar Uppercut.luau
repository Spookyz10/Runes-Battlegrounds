--[[
	Skill: Lunar Uppercut (v3)
	src/modules/Combat/Skills/Lunar Uppercut.luau
]]

local LunarUppercut = {}

local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

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

local VICTIM_LAUNCH_UP = 50
local FLOAT_HEIGHT_OFFSET = 18
local FLOAT_CORRECTION_SPEED = 40
local FLOAT_DEADZONE = 0.4
local FLOAT_DURATION = 3.5

local ATTACKER_WAIT = 2.0
local ATTACKER_RISE_SPEED = 45

local SLAM_HITBOX = Vector3.new(7, 8, 6)
local SLAM_HITBOX_OFFSET = Vector3.new(0, 0, 0)

local SLAM_HORIZONTAL = 180
local SLAM_VERTICAL = 12
local SLAM_LANDING = { horizontal = 22, vertical = 5 }

local CANCEL_TIER = 2
local INTERRUPT_TIER = 1
local IGNORE_IFRAME = 1
local IGNORE_COUNTER = 0

local ENDLAG = 0.55

-- ─── Float lock ──────────────────────────────────────────────────────────────

-- Mantém a vítima na altura targetY corrigindo via AssemblyLinearVelocity Y.
-- Retorna função stop() para encerrar o loop.
local function startFloatLock(character, targetY)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return function() end
	end

	local running = true

	task.spawn(function()
		while running and character.Parent and root.Parent do
			local currentY = root.Position.Y
			local diff = targetY - currentY

			if math.abs(diff) > FLOAT_DEADZONE then
				local correctionVel = math.clamp(diff * FLOAT_CORRECTION_SPEED, -60, 60)
				for _, part in character:GetDescendants() do
					if part:IsA("BasePart") then
						local v = part.AssemblyLinearVelocity
						part.AssemblyLinearVelocity = Vector3.new(v.X * 0.1, correctionVel, v.Z * 0.1)
					end
				end
			else
				for _, part in character:GetDescendants() do
					if part:IsA("BasePart") then
						local v = part.AssemblyLinearVelocity
						part.AssemblyLinearVelocity = Vector3.new(v.X * 0.1, 0, v.Z * 0.1)
					end
				end
			end

			task.wait()
		end
	end)

	return function()
		running = false
	end
end

-- ─── Helpers ─────────────────────────────────────────────────────────────────

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

-- ─── Helpers ─────────────────────────────────────────────────────────────────

local function riseAttackerToY(root, humanoid, targetY, onDone)
	local att = Instance.new("Attachment")
	att.Name = "UppercutRiseAtt"
	att.Parent = root

	-- LinearVelocity de subida
	local lv = Instance.new("LinearVelocity")
	lv.Name = "UppercutRise"
	lv.MaxForce = 1e5
	lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	lv.VectorVelocity = Vector3.new(0, ATTACKER_RISE_SPEED, 0)
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.Attachment0 = att
	lv.Parent = root

	humanoid.PlatformStand = true
	humanoid.WalkSpeed = 0

	task.spawn(function()
		-- Sobe até a targetY
		while root.Parent and root.Position.Y < targetY do
			task.wait()
		end

		-- Troca pra velocidade zero (trava no ar, sem gravidade)
		lv.VectorVelocity = Vector3.new(0, 0, 0)

		-- Zera momentum residual
		for _, part in root.Parent:GetDescendants() do
			if part:IsA("BasePart") then
				part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			end
		end

		if onDone then
			onDone()
		end
	end)

	-- Retorna função que destrói o LinearVelocity (libera gravidade)
	return function()
		lv:Destroy()
		att:Destroy()
	end
end

local function cleanup(humanoid, stopFloat, victimChar)
	humanoid.WalkSpeed = 16
	humanoid.JumpPower = 50
	humanoid.PlatformStand = false
	if stopFloat then
		stopFloat()
	end
	if victimChar and victimChar.Parent then
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

	-- ── Fase 1: Windup ──────────────────────────────────────────────────────
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

	-- ── Fase 2: Lança vítima e trava na altura ──────────────────────────────
	local targetY = victimRoot.Position.Y + FLOAT_HEIGHT_OFFSET

	RagdollService.apply(validVictim)
	StunService.apply(validVictim, FLOAT_DURATION + 1)

	-- Impulso inicial pra subir
	for _, part in validVictim:GetDescendants() do
		if part:IsA("BasePart") then
			part.AssemblyLinearVelocity = Vector3.new(0, VICTIM_LAUNCH_UP, 0)
		end
	end

	-- Loop que mantém a vítima presa na targetY
	local stopFloat = startFloatLock(validVictim, targetY)

	-- ── Fase 3: Attacker sobe e pausa no nível da vítima ────────────────────────
	task.wait(ATTACKER_WAIT)

	if not state.inAttack then
		cleanup(humanoid, stopFloat, validVictim)
		state.inAttack = false
		state.cancelTier = 0
		return
	end

	local riseComplete = false
	local stopRise = riseAttackerToY(root, humanoid, targetY, function()
		riseComplete = true
	end)

	while not riseComplete and state.inAttack do
		task.wait()
	end

	if not state.inAttack then
		stopRise()
		cleanup(humanoid, stopFloat, validVictim)
		state.inAttack = false
		state.cancelTier = 0
		return
	end

	-- Pausa de 1s no ar antes do slam
	task.wait(1.0)

	-- Libera a trava do atacante antes do slam
	stopRise()
	humanoid.PlatformStand = false

	local slamHits = HitboxService.query({
		origin = root.CFrame,
		size = SLAM_HITBOX,
		offset = SLAM_HITBOX_OFFSET,
		exclude = { character },
	})

	local slamHit = false
	for _, victimChar in slamHits do
		if victimChar == validVictim then
			slamHit = true
			stopFloat()

			RagdollService.remove(victimChar)
			StunService.clear(victimChar)

			local dir = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z).Unit
			LaunchService.apply(
				victimChar,
				Vector3.new(dir.X * SLAM_HORIZONTAL, SLAM_VERTICAL, dir.Z * SLAM_HORIZONTAL),
				SLAM_LANDING
			)
			break
		end
	end

	if not slamHit then
		stopFloat()
		if RagdollService.isRagdolled(validVictim) then
			RagdollService.remove(validVictim)
		end
		StunService.clear(validVictim)
	end

	humanoid.PlatformStand = false
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
