local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local SvModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local SFXModule = require(ReplicatedStorage.Shared.Modules.SFXModule)
local StunHandler = require(SvModules.StunHandler)
local DamageHandler = require(SvModules.DamageHandler)
local BodymoverService = require(SvModules.BodymoverService)
local iFramesService = require(SvModules.iFramesService)
local RagdollHandler = require(SvModules.RagdollHandler)
local AnimationService = require(SvModules.AnimationService)
local DestructionService = require(SvModules.DestructionSystem)

local Assets = ServerStorage.Assets
local Animations = Assets.Animations
local SolarEclipseAnim = Animations.Awakenings["Solar Eclipse"]

local EXPLOSION_DAMAGE = 5
local EXPLOSION_OUTWARD_FORCE = 50
local EXPLOSION_UP_FORCE = 100
local EXPLOSION_KNOCKBACK_BODY_TIME = 0.3
local RAGDOLL_DURATION = 12
local CYLINDER_SIZE = Vector3.new(300, 200, 200)
local LEVITATE_RADIUS = CYLINDER_SIZE.X

local EXPLOSION_CHECK_INTERVAL = 0.4

local HardRagdollConfig = {
	Damage = EXPLOSION_DAMAGE,
	Size = Vector3.new(60, 60, 60),
	Offset = CFrame.new(0, 0, 0),
	KnockupForce = 225,
	GroundCrater = {
		{
			Seed = math.random(1, 2147483647),
			amount = 60,
			["end"] = Vector3.new(0, -20, 0),
			size = 2.8,
			rings = 3,
			ringSpacing = 18,
			ringSizeGrowth = 1.8,
			ringGap = 0.22,
			outwardTilt = true,
			debrisSizeMin = 7,
			debrisSizeMax = 18,
			debrisHeightMin = 4,
			debrisHeightMax = 9,
			sizemult = 1.6,
		},
	},
}

local module = {}

local function startExplosionField(Character, Position)
	local Player = Players:GetPlayerFromCharacter(Character)
	if not Player then
		return nil
	end

	local PreviousiFrameLevel = iFramesService:GetLevel(Character)
	iFramesService:AddiFrames(Character, "All")
	task.delay(0.5, function()
		if Character and Character.Parent then
			if PreviousiFrameLevel > 0 then
				Character:SetAttribute("iFrames", PreviousiFrameLevel)
			else
				iFramesService:RemoveiFrames(Character, "All")
			end
		end
	end)

	RemoteManager.FireAllClients("ReplicateTask", "SolarAwakenExplosion", {
		func = "Start",
		id = Player.UserId,
		position = Position + Vector3.new(0, 200, 0),
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

			if hitCooldowns[EnemyCharacter] then
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

			if EnemyCharacter:HasTag("Ragdolled") then
				RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, false, true, true)
			end

			RagdollHandler.ragdoll(EnemyHumanoid, RAGDOLL_DURATION, true, Character, HardRagdollConfig, nil, false)

			local FallbackStun = StunHandler:Stun(EnemyCharacter, RAGDOLL_DURATION, true, 0, 0, true, nil, false)
			task.delay(RAGDOLL_DURATION, function()
				if EnemyCharacter and EnemyCharacter.Parent then
					StunHandler:Unstun(EnemyCharacter, FallbackStun)
				end
			end)

			task.defer(function()
				if not EnemyCharacter or not EnemyCharacter.Parent then
					return
				end

				local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
				if not EnemyHumRP or not EnemyHumRP.Parent then
					return
				end

				if stopped then
					return
				end
				local offset = EnemyHumRP.Position - Position
				local outward = Vector3.new(offset.X, 0, offset.Z)
				if outward.Magnitude < 0.001 then
					outward = Vector3.new(0, 0, -1)
				end
				outward = outward.Magnitude > 0 and outward.Unit or Vector3.new(0, 0, -1)

				EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
				EnemyHumRP.AssemblyAngularVelocity = Vector3.zero

				pcall(function()
					EnemyHumRP:SetNetworkOwner(nil)
				end)

				BodymoverService:Knockback(EnemyCharacter, {
					KnockbackType = "Velocity",
					MaxForce = Vector3.new(100000, 100000, 100000),
					Velocity = outward * EXPLOSION_OUTWARD_FORCE + Vector3.new(0, EXPLOSION_UP_FORCE, 0),
					Time = EXPLOSION_KNOCKBACK_BODY_TIME,
				})
			end)
		end
	end)

	return {
		Stop = function()
			if stopped then
				return
			end
			stopped = true
			RemoteManager.FireAllClients("ReplicateTask", "SolarAwakenExplosion", { func = "Stop", id = Player.UserId })

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
	local finished = false

	local AwakeningStun = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)

	RemoteManager.FireClient(Player, "ReplicateTask", "HideHotbar")
	RemoteManager.FireClient(Player, "ReplicateTask", "HideAwkBar")

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("jump"):Connect(function()
			task.wait(0.1)
			if finished or not Character.Parent or Humanoid.Health <= 0 then
				return
			end
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

	local function finish()
		if finished then
			return
		end
		finished = true
		Character:RemoveTag("CantRotate")
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
		RemoteManager.FireClient(Player, "ReplicateTask", "ShowHotbar")
		RemoteManager.FireClient(Player, "ReplicateTask", "ShowAwkBar")
	end
	AnimTrack.Stopped:Once(finish)

	Character:AddTag("CantRotate")
	if not AnimationService:playAnimation(Character, SolarEclipseAnim) then
		finish()
		return
	end
	RemoteManager.FireClient(Player, "Cutscenes", "SolarAwaken", "Start", { Offset = CFrame.new(0, -3, 0) })
	if not finished then
		AnimTrack.Stopped:Wait()
	end
	Character:RemoveTag("CantRotate")
	RemoteManager.FireClient(Player, "ReplicateTask", "ShowHotbar")
	RemoteManager.FireClient(Player, "ReplicateTask", "ShowAwkBar")
end

return module
