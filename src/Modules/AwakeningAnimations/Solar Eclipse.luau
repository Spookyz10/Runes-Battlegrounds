local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local SvModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local SFXModule = require(ReplicatedStorage.Shared.Modules.SFXModule)
local StunHandler = require(SvModules.StunHandler)
local DamageHandler = require(SvModules.DamageHandler)
local KnockbackService = require(SvModules.KnockbackModule)
local iFramesService = require(SvModules.iFramesService)
local RagdollHandler = require(SvModules.RagdollHandler)
local AnimationService = require(SvModules.AnimationService)
local DestructionService = require(SvModules.DestructionSystem)

local Assets = ServerStorage.Assets
local Animations = Assets.Animations
local SolarEclipseAnim = Animations.Awakenings["Solar Eclipse"]

local EXPLOSION_DAMAGE = 30
local EXPLOSION_KNOCKUP = 1000
local RAGDOLL_DURATION = 10
local CYLINDER_SIZE = Vector3.new(300, 200, 200)
local LEVITATE_RADIUS = CYLINDER_SIZE.X

local EXPLOSION_CHECK_INTERVAL = 0.1
local EXPLOSION_HIT_COOLDOWN = 1

local module = {}

local function startExplosionField(Character, Position)
	local Player = Players:GetPlayerFromCharacter(Character)
	if not Player then
		return nil
	end

	local PreviousiFrameLevel = iFramesService:GetLevel(Character)
	iFramesService:AddAlliFrames(Character)
	task.delay(0.5, function()
		if Character and Character.Parent then
			if PreviousiFrameLevel > 0 then
				Character:SetAttribute("iFrames", PreviousiFrameLevel)
			else
				iFramesService:RemoveAlliFrames(Character)
			end
		end
	end)

	RemoteManager.FireAllClients("ReplicateTask", "SolarAwakenExplosion", {
		func = "Start",
		id = Player.UserId,
		position = Position,
	})

	local CylinderPart = Instance.new("Part")
	CylinderPart.Shape = Enum.PartType.Cylinder
	CylinderPart.Size = CYLINDER_SIZE
	CylinderPart.CFrame = CFrame.new(Position) * CFrame.Angles(0, math.rad(90), math.rad(90))
	CylinderPart.Anchored = true
	CylinderPart.CanCollide = false
	CylinderPart.CanTouch = false
	CylinderPart.CanQuery = false
	CylinderPart.Transparency = 1
	CylinderPart.Parent = workspace
	CylinderPart.Name = "jij"

	local CylinderOverlapParams = OverlapParams.new()
	CylinderOverlapParams.FilterType = Enum.RaycastFilterType.Include
	CylinderOverlapParams.FilterDescendantsInstances = { workspace.Live }

	local hitCooldowns = {}
	local lastCheck = 0
	local stopped = false

	local conn
	conn = RunService.Heartbeat:Connect(function()
		if stopped or not CylinderPart.Parent then
			if conn then
				conn:Disconnect()
				conn = nil
			end
			return
		end

		local now = os.clock()
		if now - lastCheck < EXPLOSION_CHECK_INTERVAL then
			return
		end
		lastCheck = now

		local TouchingParts = workspace:GetPartsInPart(CylinderPart, CylinderOverlapParams)

		for _, Part in TouchingParts do
			if not Part or not Part.Parent then
				continue
			end
			local EnemyCharacter = Part.Parent
			if EnemyCharacter == Character then
				continue
			end

			local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
			if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then
				continue
			end

			local LastHit = hitCooldowns[EnemyCharacter]
			if LastHit and (now - LastHit) < EXPLOSION_HIT_COOLDOWN then
				continue
			end

			hitCooldowns[EnemyCharacter] = now

			DamageHandler:TakeDamage(
				Character,
				EnemyHumanoid,
				EXPLOSION_DAMAGE,
				1,
				nil,
				false,
				false,
				true,
				true,
				true,
				nil,
				nil
			)
			RagdollHandler.ragdoll(EnemyHumanoid, RAGDOLL_DURATION)
			KnockbackService:Knockback(
				EnemyCharacter,
				Vector3.new(0, EXPLOSION_KNOCKUP, 0),
				nil,
				nil,
				nil,
				nil,
				nil,
				false,
				false
			)
		end
	end)

	return {
		Stop = function()
			if stopped then
				return
			end
			stopped = true

			if conn then
				conn:Disconnect()
				conn = nil
			end

			if CylinderPart and CylinderPart.Parent then
				CylinderPart:Destroy()
			end
		end,
	}
end

local function triggerLandingImpact(Character, Position)
	local ImpactStun = StunHandler:Stun(Character, 0.4, true, 0, 0, true)

	RemoteManager.FireAllClients("ReplicateTask", "SolarImpact", { char = Character })
	SFXModule:Play("EclipseImpact", Position)

	task.delay(0.4, function()
		if Character and Character.Parent then
			StunHandler:Unstun(Character, ImpactStun)
		end
	end)
end

function module:Activate(Player)
	local Character = Player.Character
	if not Character or not Character.Parent then
		return
	end

	local Humanoid = Character:FindFirstChild("Humanoid")
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not HumRP or Humanoid.Health <= 0 then
		return
	end

	AnimationService:stopAll(Character)

	local AnimTrack, AnimEvents = AnimationService:getAnimationTrack(Character, SolarEclipseAnim)
	if not AnimTrack then
		warn("[SolarEclipse] AnimTrack is nil for", Character.Name)
		return
	end

	local levitationId = nil
	local fakeDebrisId = nil
	local explosionField = nil

	local AwakeningStun = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)

	RemoteManager.FireClient(Player, "ReplicateTask", "HideHotbar")
	RemoteManager.FireClient(Player, "ReplicateTask", "HideAwkBar")

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("jump"):Connect(function()
			RemoteManager.FireAllClients("ReplicateTask", "SolarAwakenStart", { char = Character })
			RemoteManager.FireAllClients("ReplicateTask", "SolarImpact", { char = Character })
			SFXModule:Play("EclipseImpact", HumRP.Position)

			levitationId = DestructionService:LevitateArea(HumRP.Position, LEVITATE_RADIUS, Player)
			fakeDebrisId = DestructionService:SpawnFakeDebris(Character, {
				MinRadius = 100,
				MaxRadius = 200,
				Interval = 0.2,
				PerTick = 1,
				OwnerPlayer = Player,
				RiseAcceleration = 4,
				MaxRiseSpeed = 40,
			})
		end)
	)

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("clap"):Connect(function()
			if not Character or not Character.Parent or Humanoid.Health <= 0 then
				return
			end
			SFXModule:Play("Solar Awakening", HumRP)
			RemoteManager.FireAllClients(
				"ReplicateTask",
				"GivePlayerAura",
				{ Char = Character, AuraName = "Solar Eclipse" }
			)
			explosionField = startExplosionField(Character, Character.Torso.Position)
		end)
	)

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("clear"):Connect(function()
			RemoteManager.FireAllClients("ReplicateTask", "SolarAwakenExplosion", { func = "Stop", id = Player.UserId })
			if explosionField then
				explosionField.Stop()
				explosionField = nil
			end
			if levitationId then
				DestructionService:DropArea(levitationId)
				levitationId = nil
			end
			if fakeDebrisId then
				DestructionService:DropFakeDebris(fakeDebrisId)
				fakeDebrisId = nil
			end
		end)
	)

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("landed"):Connect(function()
			if not Character or not Character.Parent or Humanoid.Health <= 0 then
				return
			end
			triggerLandingImpact(Character, HumRP.Position)
		end)
	)

	AnimTrack.Stopped:Once(function()
		if explosionField then
			explosionField.Stop()
			explosionField = nil
		end
		if levitationId then
			DestructionService:CancelLevitation(levitationId)
			levitationId = nil
		end
		if fakeDebrisId then
			DestructionService:CancelFakeDebris(fakeDebrisId)
			fakeDebrisId = nil
		end
		RemoteManager.FireClient(Player, "Cutscenes", "SolarAwaken", "End", {})
		RemoteManager.FireAllClients("ReplicateTask", "SolarAwakenEnd", { char = Character })
		StunHandler:Unstun(Character, AwakeningStun)
	end)

	Character:AddTag("CantRotate")
	AnimationService:playAnimation(Character, SolarEclipseAnim)
	RemoteManager.FireClient(Player, "Cutscenes", "SolarAwaken", "Start", { Offset = CFrame.new(0, -3, 0) })
	AnimTrack.Stopped:Wait()
	Character:RemoveTag("CantRotate")
	RemoteManager.FireAllClients("ReplicateTask", "ShowHotbar")
	RemoteManager.FireAllClients("ReplicateTask", "ShowAwkbar")
end

return module
