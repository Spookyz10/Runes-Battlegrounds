local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SvModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local StunHandler = require(SvModules.StunHandler)
local DamageHandler = require(SvModules.DamageHandler)
local KnockbackService = require(SvModules.KnockbackModule)
local iFramesService = require(SvModules.iFramesService)
local RagdollHandler = require(SvModules.RagdollHandler)
local AnimationService = require(SvModules.AnimationService)
local DestructionService = require(SvModules.DestructionSystem)
local SFX = require(SvModules.SFXModule)

local Remotes = ReplicatedStorage.Remotes
local ReplicateSet = Remotes.Replicate.Set
local CutscenesSet = Remotes.Cutscenes.Set

local Assets = ServerStorage.Assets
local Animations = Assets.Animations
local SolarEclipseAnim = Animations.Awakenings["Solar Eclipse"]

local EXPLOSION_DAMAGE = 30
local EXPLOSION_KNOCKUP = 1000
local RAGDOLL_DURATION = 10
local CYLINDER_SIZE = Vector3.new(260.573, 110, 110)
local LEVITATE_RADIUS = CYLINDER_SIZE.X

local module = {}

local function triggerJumpCrater(Character, Position)
	RemoteManager.FireAllClients("ReplicateTask", "Ground Crater", {
		Seed = math.random(1, 2147483647),
		amount = 70,
		start = Position + Vector3.new(0, 4, 0),
		["end"] = Vector3.new(0, -20, 0),
		rings = 3,
		ringSpacing = 16 * 3,
		ringSizeGrowth = 1.5,
		ringGap = 0.20,
		outwardTilt = true,
		debrisSizeMin = 4 * 3,
		debrisSizeMax = 12 * 3,
		debrisHeightMin = 4 * 1.5,
		debrisHeightMax = 9 * 1.5,
		sizemult = 1.3 * 3,
		tiltMin = 5,
		tiltMax = 20,
	})
end

local function triggerExplosion(Character, Position)
	local Player = Players:GetPlayerFromCharacter(Character)
	if not Player then
		return
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

	local CylinderOverlapParams = OverlapParams.new()
	CylinderOverlapParams.FilterType = Enum.RaycastFilterType.Include
	CylinderOverlapParams.FilterDescendantsInstances = { workspace.Live }

	local TouchingParts = workspace:GetPartsInPart(CylinderPart, CylinderOverlapParams)
	local HitCharacters = {}

	for _, Part in TouchingParts do
		if not Part or not Part.Parent then
			continue
		end
		local EnemyCharacter = Part.Parent
		if EnemyCharacter == Character then
			continue
		end
		if table.find(HitCharacters, EnemyCharacter) then
			continue
		end
		local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
		if EnemyHumanoid and EnemyHumanoid.Health > 0 then
			table.insert(HitCharacters, EnemyCharacter)
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
	end

	CylinderPart:Destroy()
end

local function triggerLandingImpact(Character, Position)
	local ImpactStun = StunHandler:Stun(Character, 0.4, true, 0, 0, true)

	RemoteManager.FireAllClients("ReplicateTask", "SolarImpact", { char = Character })
	SFX:Play("EclipseImpact", Position)
	triggerJumpCrater(Character, Position)

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

	RemoteManager.FireAllClients("ReplicateTask", "HideHotbar")
	RemoteManager.FireAllClients("ReplicateTask", "HideAwkbar")

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("jump"):Connect(function()
			RemoteManager.FireAllClients("ReplicateTask", "SolarAwakenStart", { char = Character })
			RemoteManager.FireAllClients("ReplicateTask", "SolarImpact", { char = Character })
			SFX:Play("EclipseImpact", HumRP.Position)
			triggerJumpCrater(Character, HumRP.Position)
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
			SFX:Play("Solar Awakening", HumRP)
			RemoteManager.FireAllClients(
				"ReplicateTask",
				"GivePlayerAura",
				{ Char = Character, AuraName = "Solar Eclipse" }
			)
			triggerExplosion(Character, Character.Torso.Position + Vector3.new(0, 200, 0))
		end)
	)

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("clear"):Connect(function()
			RemoteManager.FireAllClients("ReplicateTask", "SolarAwakenExplosion", { func = "Stop", id = Player.UserId })
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
		if levitationId then
			DestructionService:CancelLevitation(levitationId)
			levitationId = nil
		end
		if fakeDebrisId then
			DestructionService:CancelFakeDebris(fakeDebrisId)
			fakeDebrisId = nil
		end
		CutscenesSet:FireClient(Player, "SolarAwaken", "End", {})
		RemoteManager.FireAllClients("ReplicateTask", "SolarAwakenEnd", { char = Character })
	end)

	Character:AddTag("CantRotate")
	AnimationService:playAnimation(Character, SolarEclipseAnim)
	CutscenesSet:FireClient(Player, "SolarAwaken", "Start", { Offset = CFrame.new(0, -3, 0) })
	AnimTrack.Stopped:Wait()
	Character:RemoveTag("CantRotate")
	RemoteManager.FireAllClients("ReplicateTask", "ShowHotbar")
	RemoteManager.FireAllClients("ReplicateTask", "ShowAwkbar")
end

return module
