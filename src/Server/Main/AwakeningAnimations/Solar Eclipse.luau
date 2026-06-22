local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
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
local IndicatorService = require(SvModules.IndicatorService)

local Remotes = ReplicatedStorage.Remotes
local ReplicateSet = Remotes.Replicate.Set

local Assets = ServerStorage.Assets
local Animations = Assets.Animations
local SolarEclipseAnim = Animations.Awakenings["Solar Eclipse"]

local CharacterAssets = ReplicatedStorage.Resources.CharacterAssets
local SolarIndicatorAsset = CharacterAssets.Eclipse.Solar.Awaken.SolarIndicator

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = { workspace.Map }
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true

local RISE_HEIGHT = 60
local RISE_TOP_THRESHOLD = 2
local CHARGE_TIME = 5
local EXPLOSION_DELAY = 3
local EXPLOSION_DAMAGE = 30
local EXPLOSION_KNOCKUP = 1000
local RAGDOLL_DURATION = 10
local CYLINDER_SIZE = Vector3.new(260.573, 110, 110)

local module = {}

local function triggerExplosion(Character, Position)
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

	-- Explosion visual agora é feito no client
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

local function watchForLanding(Character, Humanoid, HumRP)
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
			return
		end

		if os.clock() - StartTime > 20 then
			Landed = true
			Connection:Disconnect()
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
		triggerLandingImpact(Character, RayResult.Position)
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

	local indicatorId = "SolarAwaken_" .. Player.UserId
	local StartPosition = HumRP.Position
	local TargetY = StartPosition.Y + RISE_HEIGHT

	local capturedImpactPosition = nil

	local function restoreControl()
		Humanoid.PlatformStand = false
		Humanoid.AutoRotate = true
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
		if Humanoid.Health > 0 then
			Humanoid:ChangeState(Enum.HumanoidStateType.Running)
		end
	end

	AnimationService:stopAll(Character)

	local AnimTrack, AnimEvents = AnimationService:getAnimationTrack(Character, SolarEclipseAnim)
	if not AnimTrack then
		warn("[SolarEclipse] AnimTrack is nil for", Character.Name)
		return
	end

	ReplicateSet:FireAllClients("GivePlayerAura", { Char = Character, AuraName = "Solar Eclipse" })
	ReplicateSet:FireAllClients("HideHotbar")
	ReplicateSet:FireAllClients("HideAwkbar")

	local RiseBodyPosition
	local RiseConnection
	local ReachedTop = false

	local pollingConnection = nil

	local function startPolling()
		pollingConnection = RunService.Heartbeat:Connect(function()
			if not Character or not Character.Parent or Humanoid.Health <= 0 then
				if pollingConnection then
					pollingConnection:Disconnect()
					pollingConnection = nil
				end
				return
			end
			local pos = IndicatorService:GetPosition(Player, indicatorId)
			if pos then
				capturedImpactPosition = pos
			end
		end)
	end

	local function stopPolling()
		if pollingConnection then
			pollingConnection:Disconnect()
			pollingConnection = nil
		end
	end

	local function startRise()
		ReplicateSet:FireAllClients("SolarAwakenStart", { char = Character })

		Humanoid.AutoRotate = false
		Humanoid.PlatformStand = true
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

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

		HumRP.AssemblyLinearVelocity = Vector3.new(0, HumRP.AssemblyLinearVelocity.Y, 0)

		RiseBodyPosition = Instance.new("BodyPosition")
		RiseBodyPosition.Name = "SolarAwaken_Rise"
		RiseBodyPosition.MaxForce = Vector3.new(0, math.huge, 0)
		RiseBodyPosition.P = 10000
		RiseBodyPosition.D = 500
		RiseBodyPosition.Position = Vector3.new(StartPosition.X, TargetY, StartPosition.Z)
		RiseBodyPosition.Parent = HumRP

		RiseConnection = RunService.Heartbeat:Connect(function()
			if not Character or not Character.Parent or Humanoid.Health <= 0 then
				if RiseConnection then
					RiseConnection:Disconnect()
					RiseConnection = nil
				end
				return
			end
			if not RiseBodyPosition or not RiseBodyPosition.Parent then
				if RiseConnection then
					RiseConnection:Disconnect()
					RiseConnection = nil
				end
				return
			end

			HumRP.AssemblyLinearVelocity = Vector3.new(0, HumRP.AssemblyLinearVelocity.Y, 0)
			RiseBodyPosition.Position = Vector3.new(HumRP.Position.X, TargetY, HumRP.Position.Z)

			if not ReachedTop and math.abs(HumRP.Position.Y - TargetY) <= RISE_TOP_THRESHOLD then
				ReachedTop = true
				AnimTrack:AdjustSpeed(1)
			end
		end)
	end

	local function stopRise()
		if RiseConnection then
			RiseConnection:Disconnect()
			RiseConnection = nil
		end
		if RiseBodyPosition and RiseBodyPosition.Parent then
			RiseBodyPosition:Destroy()
			RiseBodyPosition = nil
		end
	end

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("jump"):Connect(function()
			AnimTrack:AdjustSpeed(0)
			startRise()
		end)
	)

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("charge"):Connect(function()
			AnimTrack:AdjustSpeed(0)

			ReplicateSet:FireAllClients("SolarAwakenSunSpawn", { char = Character })
			ReplicateSet:FireClient(Player, "StartSolarAimControl", { Duration = CHARGE_TIME })

			IndicatorService:Create({
				id = indicatorId,
				character = Character,
				ownerId = Player.UserId,
				asset = SolarIndicatorAsset,
			})

			startPolling()

			task.delay(CHARGE_TIME, function()
				if not Character or not Character.Parent or Humanoid.Health <= 0 then
					return
				end
				AnimTrack:AdjustSpeed(1)
			end)
		end)
	)

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("throw"):Connect(function()
			stopRise()
			stopPolling()
			ReplicateSet:FireClient(Player, "StopSolarAimControl", {})

			IndicatorService:Destroy(indicatorId)
			ReplicateSet:FireAllClients("SolarAwakenEnd", { char = Character })

			if not Character.Parent or Humanoid.Health <= 0 then
				if Character.Parent then
					restoreControl()
				end
				return
			end

			restoreControl()

			local resolvedPosition = capturedImpactPosition or HumRP.Position
			local explosionPosition = resolvedPosition + Vector3.new(0, 250, 0)

			task.spawn(function()
				watchForLanding(Character, Humanoid, HumRP)
			end)

			task.spawn(function()
				task.wait(EXPLOSION_DELAY)
				if not Character or not Character.Parent then
					return
				end
				triggerExplosion(Character, explosionPosition)
			end)
		end)
	)

	AnimTrack.Stopped:Once(function()
		stopRise()
		stopPolling()
	end)

	AnimationService:playAnimation(Character, SolarEclipseAnim)
	AnimTrack.Stopped:Wait()
	ReplicateSet:FireAllClients("ShowHotbar")
	ReplicateSet:FireAllClients("ShowAwkbar")
end

return module
