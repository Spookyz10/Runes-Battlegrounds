local LunarLunge = {}

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CombatState = require(script.Parent.Parent.CombatState)
local CombatService = require(script.Parent.Parent.CombatService)
local CooldownService = require(ServerStorage.Modules.CooldownService)
local HitboxService = require(ServerStorage.Modules.HitboxService)
local KnockbackService = require(ServerStorage.Modules.KnockbackService)

local COOLDOWN = 1
local DASH_SPEED = 80
local DASH_DURATION = 0.35
local HITBOX_SIZE = Vector3.new(10, 10, 10)
local STUN_DURATION = 1.2
local ENDLAG = 0.45
local INTERRUPT_TIER = 1
local IGNORE_IFRAME = 1
local IGNORE_COUNTER = 0
local CANCEL_TIER = 2

local VFXRemotes = ReplicatedStorage.Remotes.VFX

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
	bv.MaxForce = Vector3.new(1e5, 0, 1e5)
	bv.P = 1e4
	bv.Parent = root

	task.wait(duration)

	bv:Destroy()
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

	local dir = root.CFrame.LookVector
	dir = Vector3.new(dir.X, 0, dir.Z).Unit

	state.inAttack = true
	state.cancelTier = CANCEL_TIER
	state.interruptTier = INTERRUPT_TIER
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0

	VFXRemotes.SkillEffect:FireAllClients("Lunar Lunge", "dash", character, dir)

	doDash(character, dir, DASH_SPEED, DASH_DURATION)

	if not state.inAttack then
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 50
		return
	end

	-- Relê a posição APÓS o dash
	local postDashCFrame = root.CFrame

	VFXRemotes.SkillEffect:FireAllClients("Lunar Lunge", "impact", character, dir)

	local hits = HitboxService.query({
		origin = postDashCFrame,
		size = HITBOX_SIZE,
		exclude = { character },
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

		if victimState.iframeType > IGNORE_IFRAME then
			continue
		end

		if victimState.isCountering and victimState.counterTier > IGNORE_COUNTER then
			victimState.counterTriggered = true
			victimState.counterTarget = character
			continue
		end

		if victimState.isBlocking then
			local toAttacker = (root.Position - victimRoot.Position)
			toAttacker = Vector3.new(toAttacker.X, 0, toAttacker.Z).Unit
			if toAttacker:Dot(victimRoot.CFrame.LookVector) > 0 then
				VFXRemotes.SkillEffect:FireAllClients("Lunar Lunge", "blocked", victimChar, dir)
				continue
			end
		end

		if victimState.inAttack and victimState.interruptTier <= INTERRUPT_TIER then
			CombatService.forceInterrupt(victimPlayer, victimChar)
		end

		applyStun(victimChar, STUN_DURATION)
		KnockbackService.applyFromHit(victimChar, root.Position, 25, 10)
		VFXRemotes.SkillEffect:FireAllClients("Lunar Lunge", "hit", victimChar, dir)
	end

	state.inAttack = false
	state.inEndlag = true

	task.wait(ENDLAG)

	state.inEndlag = false
	state.cancelTier = 0
	humanoid.WalkSpeed = 16
	humanoid.JumpPower = 50
end

return LunarLunge
