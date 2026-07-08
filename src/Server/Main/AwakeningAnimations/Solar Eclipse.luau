local RunService = game:GetService("RunService")
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

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = { workspace.Map }
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true

local EXPLOSION_DAMAGE = 30
local EXPLOSION_KNOCKUP = 1000
local RAGDOLL_DURATION = 10
local CYLINDER_SIZE = Vector3.new(260.573, 110, 110)
local CFrameToTp

local module = {}

local function triggerPillar(Character, Position)
	local Player = Players:GetPlayerFromCharacter(Character)

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

	ReplicateSet:FireAllClients("SolarAwakenExplosion", { char = Character, position = Position })

	if Player then
		ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 10, Last = 1 })
	end

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

	ReplicateSet:FireAllClients("SolarAwakenFogEnd", { char = Character })

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

-- Espera o player cair e tocar o chão. Só depois disso o controle volta.
local function watchForLanding(Character, Humanoid, HumRP, onLand)
	local Landed = false
	local Connection
	local StartTime = os.clock()

	Connection = RunService.Heartbeat:Connect(function()
		if Landed then
			return
		end

		if not Character or not Character.Parent or not HumRP.Parent or Humanoid.Health <= 0 then
			Landed = true
			Connection:Disconnect()
			onLand(HumRP and HumRP.Parent and HumRP.Position or nil)
			return
		end

		if os.clock() - StartTime > 20 then
			Landed = true
			Connection:Disconnect()
			onLand(HumRP.Position)
			return
		end

		if HumRP.AssemblyLinearVelocity.Y > 0 then
			return
		end

		local RayResult = workspace:Raycast(HumRP.Position, Vector3.new(0, -6, 0), MapRayParams)
		if not RayResult then
			return
		end

		Landed = true
		Connection:Disconnect()
		onLand(RayResult.Position)
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

	local PreviousWalkSpeed = Humanoid.WalkSpeed
	Humanoid.WalkSpeed = 0

	ReplicateSet:FireAllClients("HideHotbar")
	ReplicateSet:FireAllClients("HideAwkbar")
	ReplicateSet:FireAllClients("SolarAwakenStart", { char = Character })

	CutscenesSet:FireClient(Player, "SolarAwaken", "Start", { Offset = CFrame.new(0, -3, 0) })

	local function restoreControl()
		if Humanoid then
			Humanoid.WalkSpeed = PreviousWalkSpeed
		end
	end

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("jump"):Connect(function()
			local LiftRay = workspace:Raycast(HumRP.Position, Vector3.new(0, -6, 0), MapRayParams)
			if LiftRay then
				ReplicateSet:FireAllClients("Ground Crater", {
					nodebris = true,
					nosmoke = true,
					Seed = math.random(1, 2147483647),
					amount = 30,
					start = LiftRay.Position + Vector3.new(0, 1, 0),
					["end"] = Vector3.new(0, -10, 0),
					rings = 2,
					ringSpacing = 12,
					ringSizeGrowth = 1.4,
					ringGap = 0.20,
					outwardTilt = true,
					debrisSizeMin = 3,
					debrisSizeMax = 8,
					debrisHeightMin = 2,
					debrisHeightMax = 5,
					sizemult = 0.8,
				})
			end
		end)
	)

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("clap"):Connect(function()
			if not Character or not Character.Parent then
				return
			end

			ReplicateSet:FireAllClients("GivePlayerAura", { Char = Character, AuraName = "Solar Eclipse" })
			triggerPillar(Character, HumRP.Position)
			CFrameToTp = Character.Torso.CFrame
		end)
	)

	AnimTrack.Stopped:Once(function()
		if not Character or not Character.Parent or Humanoid.Health <= 0 then
			ReplicateSet:FireAllClients("SolarAwakenEnd", { char = Character })
			ReplicateSet:FireAllClients("ShowHotbar")
			ReplicateSet:FireAllClients("ShowAwkbar")
			CutscenesSet:FireClient(Player, "SolarAwaken", "End", {})
			restoreControl()
			return
		end

		CutscenesSet:FireClient(Player, "SolarAwaken", "End", {})

		Character.HumanoidRootPart.CFrame = CFrameToTp
		CFrameToTp = nil
		Character.HumanoidRootPart.Anchored = true
		task.wait(1)
		Character.HumanoidRootPart.Anchored = false

		watchForLanding(Character, Humanoid, HumRP, function(LandPosition)
			if LandPosition then
				triggerLandingImpact(Character, LandPosition)
			end

			ReplicateSet:FireAllClients("SolarAwakenEnd", { char = Character })
			ReplicateSet:FireAllClients("ShowHotbar")
			ReplicateSet:FireAllClients("ShowAwkbar")

			restoreControl()
		end)
	end)

	AnimationService:playAnimation(Character, SolarEclipseAnim)
end

return module
