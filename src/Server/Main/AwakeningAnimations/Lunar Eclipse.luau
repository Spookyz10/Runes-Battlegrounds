local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SvModules = ServerStorage.Modules

local DamageHandler = require(SvModules.DamageHandler)
local KnockbackService = require(SvModules.KnockbackModule)
local iFramesService = require(SvModules.iFramesService)
local HitboxHandler = require(SvModules.HitboxHandler)
local RagdollHandler = require(SvModules.RagdollHandler)
local AnimationService = require(SvModules.AnimationService)
local IndicatorService = require(SvModules.IndicatorService)
local CutsceneManager = require(SvModules.CutsceneManager)
local DestructionService = require(SvModules.DestructionSystem)

local Remotes = ReplicatedStorage.Remotes
local ReplicateSet = Remotes.Replicate.Set

local Assets = ServerStorage.Assets
local Animations = Assets.Animations
local LunarEclipseAnim = Animations.Awakenings["Lunar Eclipse"]

local CharacterAssets = ReplicatedStorage.Resources.CharacterAssets
local LunarIndicatorAsset = CharacterAssets.Eclipse.Lunar.Awaken.LunarIndicator

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = { workspace.Map }
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true

local ProjectileOverlapParams = OverlapParams.new()
ProjectileOverlapParams.FilterType = Enum.RaycastFilterType.Include
ProjectileOverlapParams.FilterDescendantsInstances = { workspace.Live }

local PROJECTILE_SPEED = 80
local PROJECTILE_LIFETIME = 10
local PROJECTILE_SIZE = Vector3.new(20, 20, 20)
local EXPLOSION_SIZE = Vector3.new(100, 100, 100)

local AIM_CONTROL_MAX_DURATION = 30
local THROW_DELAY = 1
local TP_LIFT_HEIGHT = 200

local MOON_IMPACT_FORCE = 400
local MOON_IMPACT_RADIUS = 50
local module = {}

local function radialKnockback(Character, EnemyCharacter, EnemyHumanoid, ExplosionPosition, BaseForce, Damage)
	DamageHandler:TakeDamage(Character, EnemyHumanoid, Damage, 1, nil, false, false, true, true, true, nil, nil)
	RagdollHandler.ragdoll(EnemyHumanoid, 5)
	KnockbackService:Knockback(EnemyCharacter, Vector3.new(0, BaseForce, 0), nil, nil, nil, nil, nil, false, false)
end

local function explode(Character, Position)
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

	ReplicateSet:FireAllClients("LunarAwakenMoonImpact", { char = Character, position = Position })

	ReplicateSet:FireAllClients("Ground Crater", {
		nosmoke = true,
		nosound = true,
		nodebris = true,
		Seed = math.random(1, 2147483647),
		amount = 60,
		start = Position + Vector3.new(0, 1, 0),
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
	})

	if Player then
		ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 10, Last = 1 })
	end

	DestructionService:ApplyRadialImpact(Position, MOON_IMPACT_RADIUS, MOON_IMPACT_FORCE, Player, Vector3.new(0, -1, 0))

	HitboxHandler:SimpleOnce(Position, MOON_IMPACT_RADIUS, nil, { Character }, "Radius", nil, function(EnemyCharacter)
		local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
		if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then
			return
		end
		radialKnockback(Character, EnemyCharacter, EnemyHumanoid, Position, 145, 18)
	end)
end

local function fireProjectile(Character, Origin, Direction)
	local Projectile = Instance.new("Part")
	Projectile.Name = "LunarAwakenProjectile"
	Projectile.Size = PROJECTILE_SIZE
	Projectile.Transparency = 1
	Projectile.CanCollide = false
	Projectile.CanTouch = false
	Projectile.CanQuery = false
	Projectile.Anchored = true
	Projectile.Massless = true
	Projectile.CFrame = CFrame.new(Origin, Origin + Direction)
	Projectile.Parent = workspace.Debris

	Debris:AddItem(Projectile, PROJECTILE_LIFETIME + 1)

	local ProjectileRayParams = RaycastParams.new()
	ProjectileRayParams.FilterType = Enum.RaycastFilterType.Exclude
	ProjectileRayParams.FilterDescendantsInstances = { Character, Projectile }

	local StartTime = os.clock()
	local Exploded = false
	local Connection

	Connection = RunService.Heartbeat:Connect(function(dt)
		if Exploded then
			return
		end

		if not Projectile or not Projectile.Parent then
			Exploded = true
			if Connection then
				Connection:Disconnect()
			end
			return
		end

		if os.clock() - StartTime >= PROJECTILE_LIFETIME then
			Exploded = true
			local Position = Projectile.Position
			Connection:Disconnect()
			Projectile:Destroy()
			explode(Character, Position)
			return
		end

		local Step = Direction * PROJECTILE_SPEED * dt
		local RayResult = workspace:Raycast(Projectile.Position, Step, ProjectileRayParams)

		if RayResult then
			Exploded = true
			local ImpactPosition = RayResult.Position
			Connection:Disconnect()
			Projectile:Destroy()
			explode(Character, ImpactPosition)
			return
		end

		local TouchingParts =
			workspace:GetPartBoundsInRadius(Projectile.Position, PROJECTILE_SIZE.X, ProjectileOverlapParams)
		for _, Part in TouchingParts do
			if not Part or not Part.Parent then
				continue
			end
			local PartCharacter = Part.Parent
			if PartCharacter == Character then
				continue
			end
			local PartHumanoid = PartCharacter:FindFirstChild("Humanoid")
			if PartHumanoid then
				Exploded = true
				local Position = Projectile.Position
				Connection:Disconnect()
				Projectile:Destroy()
				explode(Character, Position)
				return
			end
		end

		Projectile.CFrame = CFrame.new(Projectile.Position + Step, Projectile.Position + Step + Direction)
	end)
end

local function spawnCrater(Position, opts)
	local LiftRay = workspace:Raycast(Position, Vector3.new(0, -6, 0), MapRayParams)
	local CraterPosition = (LiftRay and LiftRay.Position) or Position

	local params = {
		Seed = math.random(1, 2147483647),
		amount = opts.amount or 65,
		start = CraterPosition + Vector3.new(0, 4, 0),
		["end"] = Vector3.new(0, -20, 0),
		rings = 3,
		ringSpacing = 16,
		ringSizeGrowth = 1.5,
		ringGap = 0.2,
		outwardTilt = true,
		debrisSizeMin = 4,
		debrisSizeMax = 12,
		debrisHeightMin = 4,
		debrisHeightMax = 9,
		sizemult = 1.3,
	}
	for k, v in opts do
		params[k] = v
	end

	ReplicateSet:FireAllClients("Ground Crater", params)
end

local function lockAirborne(Humanoid, HumRP)
	Humanoid.AutoRotate = false
	Humanoid.PlatformStand = true
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	HumRP.AssemblyLinearVelocity = Vector3.zero
	HumRP.Anchored = true
end

local function restoreGroundControl(Humanoid, HumRP)
	HumRP.Anchored = false
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

function module:Activate(Player)
	local Character = Player.Character
	if not Character or not Character.Parent then
		return
	end

	local Humanoid = Character:FindFirstChild("Humanoid")
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	local Torso = Character:FindFirstChild("Torso")
	if not Humanoid or not HumRP or not Torso or Humanoid.Health <= 0 then
		return
	end

	local indicatorId = "LunarAwaken_" .. Player.UserId

	AnimationService:stopAll(Character)

	local AnimTrack, AnimEvents = AnimationService:getAnimationTrack(Character, LunarEclipseAnim)
	if not AnimTrack then
		warn("[LunarEclipse] AnimTrack is nil for", Character.Name)
		return
	end

	ReplicateSet:FireAllClients("HideHotbar")
	ReplicateSet:FireAllClients("HideAwkbar")

	local CutsceneSession =
		CutsceneManager:PlayCutscene(Player, "LunarAwaken", { Offset = CFrame.new(0, -3, 0), weld = true })
	local cutsceneEnded = false
	local isAirborne = false

	task.spawn(function()
		CutsceneSession:WaitTilEnd()
		cutsceneEnded = true

		if Character and Character.Parent and Humanoid.Health > 0 then
			ReplicateSet:FireClient(Player, "StartLunarAimControl", { Duration = AIM_CONTROL_MAX_DURATION })
			IndicatorService:Create({
				id = indicatorId,
				character = Character,
				ownerId = Player.UserId,
				asset = LunarIndicatorAsset,
			})
		end
	end)

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("tpup"):Connect(function()
			if not Character or not Character.Parent or Humanoid.Health <= 0 then
				return
			end

			local OriginPosition = HumRP.Position

			ReplicateSet:FireAllClients("LunarAwakenStart", { char = Character })
			spawnCrater(OriginPosition, { amount = 70, tiltMin = 30, tiltMax = 50 })
			ReplicateSet:FireAllClients("LunarImpact", { char = Character })

			task.wait(0.1)

			if not Character or not Character.Parent then
				return
			end

			local pivot = Character:GetPivot()
			Character:PivotTo(CFrame.new(OriginPosition + Vector3.new(0, TP_LIFT_HEIGHT, 0)) * (pivot - pivot.Position))

			lockAirborne(Humanoid, HumRP)
			isAirborne = true
		end)
	)

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("charge"):Connect(function()
			if not Character or not Character.Parent or Humanoid.Health <= 0 then
				return
			end

			ReplicateSet:FireAllClients("LunarAwakenMoonSpawn", { char = Character })
			ReplicateSet:FireAllClients("LunarAwakenFogEnd", { char = Character })
			ReplicateSet:FireAllClients("GivePlayerAura", { Char = Character, AuraName = "Lunar Eclipse" })
		end)
	)

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("throw"):Connect(function()
			if not Character or not Character.Parent or Humanoid.Health <= 0 then
				return
			end

			local LaunchOrigin = Torso.Position + Vector3.new(0, 70, 0)
			local LaunchDirection

			if cutsceneEnded then
				ReplicateSet:FireClient(Player, "StopLunarAimControl", { RestoreCamera = false })

				local launchPosition = IndicatorService:GetPosition(Player, indicatorId)
				IndicatorService:Destroy(indicatorId)

				LaunchDirection = HumRP.CFrame.LookVector
				if launchPosition then
					local toTarget = launchPosition - LaunchOrigin
					if toTarget.Magnitude > 0.01 then
						LaunchDirection = toTarget.Unit
					end
				end
			else
				warn("[LunarEclipse] throw antes do fim da cutscene, usando fallback para", Character.Name)
				CutsceneSession:ForceEnd()
				cutsceneEnded = true
				IndicatorService:Destroy(indicatorId)
				LaunchDirection = Vector3.new(0, -1, 0)
			end

			task.delay(THROW_DELAY, function()
				if Character and Character.Parent then
					fireProjectile(Character, LaunchOrigin, LaunchDirection)
					ReplicateSet:FireAllClients("LunarAwakenMoonLaunch", {
						char = Character,
						direction = LaunchDirection,
						ownerId = Player.UserId,
					})
				end
			end)
		end)
	)

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("tpdown"):Connect(function()
			if not Character or not Character.Parent then
				return
			end

			local CurrentPosition = HumRP.Position

			if isAirborne then
				HumRP.Anchored = false
			end

			HumRP.Position = CurrentPosition - Vector3.new(0, TP_LIFT_HEIGHT, 0)
			HumRP.AssemblyLinearVelocity = Vector3.zero

			if isAirborne then
				restoreGroundControl(Humanoid, HumRP)
				isAirborne = false
			end

			task.wait()

			if not Character or not Character.Parent then
				return
			end

			ReplicateSet:FireAllClients("LunarImpact", { char = Character })
			spawnCrater(HumRP.Position, { amount = 60, debrisSizeMin = 5, debrisSizeMax = 14, sizemult = 1.4 })
		end)
	)

	AnimTrack.Stopped:Once(function()
		if isAirborne then
			HumRP.Anchored = false
			restoreGroundControl(Humanoid, HumRP)
			isAirborne = false
		end

		CutsceneSession:ForceEnd()
		if not cutsceneEnded then
			ReplicateSet:FireClient(Player, "StopLunarAimControl", { RestoreCamera = false })
		end
		IndicatorService:Destroy(indicatorId)
		ReplicateSet:FireClient(Player, "LunarAimRestoreCamera", {})
		ReplicateSet:FireAllClients("LunarAwakenEnd", { char = Character })
	end)

	AnimationService:playAnimation(Character, LunarEclipseAnim)
	AnimTrack.Stopped:Wait()
	ReplicateSet:FireAllClients("ShowHotbar")
	ReplicateSet:FireAllClients("ShowAwkbar")
end

return module
