local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SvModules = ServerStorage.Modules

local StunHandler = require(SvModules.StunHandler)
local DamageHandler = require(SvModules.DamageHandler)
local KnockbackService = require(SvModules.KnockbackModule)
local iFramesService = require(SvModules.iFramesService)
local RagdollHandler = require(SvModules.RagdollHandler)
local AnimationService = require(SvModules.AnimationService)

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

local module = {}

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

	ReplicateSet:FireAllClients("SolarAwakenExplosion", {
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

	ReplicateSet:FireAllClients("SolarImpact", { char = Character })

	ReplicateSet:FireAllClients("Ground Crater", {
		Seed = math.random(1, 2147483647),
		amount = 80,
		start = Position + Vector3.new(0, 4, 0),
		["end"] = Vector3.new(0, -20, 0),
		rings = 2,
		ringSpacing = 60,
		ringSizeGrowth = 1.4,
		ringGap = 0.20,
		outwardTilt = true,
		debrisSizeMin = 4,
		debrisSizeMax = 12,
		debrisHeightMin = 4,
		debrisHeightMax = 9,
		sizemult = 1.3,
		tiltMin = 5,
		tiltMax = 30,
	})

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

	ReplicateSet:FireAllClients("HideHotbar")
	ReplicateSet:FireAllClients("HideAwkbar")

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("jump"):Connect(function()
			ReplicateSet:FireAllClients("SolarAwakenStart", { char = Character })
			ReplicateSet:FireAllClients("SolarImpact", { char = Character })
		end)
	)

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("clap"):Connect(function()
			if not Character or not Character.Parent or Humanoid.Health <= 0 then
				return
			end
			ReplicateSet:FireAllClients("GivePlayerAura", { Char = Character, AuraName = "Solar Eclipse" })
			triggerExplosion(Character, Character.Torso.Position + Vector3.new(0, 200, 0))
		end)
	)

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("clear"):Connect(function()
			ReplicateSet:FireAllClients("SolarAwakenExplosion", { func = "Stop", id = Player.UserId })
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
		CutscenesSet:FireClient(Player, "SolarAwaken", "End", {})
		ReplicateSet:FireAllClients("SolarAwakenEnd", { char = Character })
	end)

	AnimationService:playAnimation(Character, SolarEclipseAnim)
	CutscenesSet:FireClient(Player, "SolarAwaken", "Start", { Offset = CFrame.new(0, -3, 0) })
	AnimTrack.Stopped:Wait()
	ReplicateSet:FireAllClients("ShowHotbar")
	ReplicateSet:FireAllClients("ShowAwkbar")
end

return module
