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
local HitboxHandler = require(SvModules.HitboxHandler)
local RagdollHandler = require(SvModules.RagdollHandler)
local AnimationService = require(SvModules.AnimationService)
local IndicatorService = require(SvModules.IndicatorService)

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

local RISE_HEIGHT = 60
local RISE_TOP_THRESHOLD = 2
local CHARGE_TIME = 5
local PROJECTILE_SPEED = 80
local PROJECTILE_LIFETIME = 10
local PROJECTILE_SIZE = Vector3.new(2, 2, 2)
local EXPLOSION_SIZE = Vector3.new(100, 100, 100)
local IMPACT_SIZE = Vector3.new(90, 30, 90)

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

	HitboxHandler:SimpleOnce(Position, EXPLOSION_SIZE, nil, { Character }, "Box", nil, function(EnemyCharacter)
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

local function triggerLandingImpact(Character, Position)
	local ImpactStun = StunHandler:Stun(Character, 0.4, true, 0, 0, true)

	ReplicateSet:FireAllClients("LunarAwakenFogEnd", { char = Character })

	HitboxHandler:SimpleOnce(Position, IMPACT_SIZE, nil, { Character }, "Box", nil, function(EnemyCharacter)
		local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
		if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then
			return
		end
		radialKnockback(Character, EnemyCharacter, EnemyHumanoid, Position, 145, 12)
	end)

	ReplicateSet:FireAllClients("Ground Crater", {
		Seed = math.random(1, 2147483647),
		amount = 70,
		start = Position + Vector3.new(0, 4, 0),
		["end"] = Vector3.new(0, -20, 0),
		rings = 3,
		ringSpacing = 16,
		ringSizeGrowth = 1.5,
		ringGap = 0.20,
		outwardTilt = true,
		debrisSizeMin = 4,
		debrisSizeMax = 12,
		debrisHeightMin = 4,
		debrisHeightMax = 9,
		sizemult = 1.3,
		tiltMin = 5,
		tiltMax = 20,
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

	local indicatorId = "LunarAwaken_" .. Player.UserId
	local StartPosition = HumRP.Position
	local TargetY = StartPosition.Y + RISE_HEIGHT

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

	local AnimTrack, AnimEvents = AnimationService:getAnimationTrack(Character, LunarEclipseAnim)
	if not AnimTrack then
		warn("[LunarEclipse] AnimTrack is nil for", Character.Name)
		return
	end

	ReplicateSet:FireAllClients("GivePlayerAura", { Char = Character, AuraName = "Lunar Eclipse" })
	ReplicateSet:FireAllClients("HideHotbar")
	ReplicateSet:FireAllClients("HideAwkbar")

	local RiseBodyPosition
	local RiseConnection
	local ReachedTop = false

	local function startRise()
		ReplicateSet:FireAllClients("LunarAwakenStart", { char = Character })

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
				Seed = math.random(1, 2147483647),
				amount = 70,
				start = LiftRay.Position + Vector3.new(0, 4, 0),
				["end"] = Vector3.new(0, -20, 0),
				rings = 3,
				ringSpacing = 16,
				ringSizeGrowth = 1.5,
				ringGap = 0.20,
				outwardTilt = true,
				debrisSizeMin = 4,
				debrisSizeMax = 12,
				debrisHeightMin = 4,
				debrisHeightMax = 9,
				sizemult = 1.3,
				tiltMin = 5,
				tiltMax = 20,
			})
		end

		HumRP.AssemblyLinearVelocity = Vector3.new(0, HumRP.AssemblyLinearVelocity.Y, 0)

		RiseBodyPosition = Instance.new("BodyPosition")
		RiseBodyPosition.Name = "LunarAwaken_Rise"
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

			ReplicateSet:FireAllClients("LunarAwakenMoonSpawn", { char = Character })
			ReplicateSet:FireClient(Player, "StartLunarAimControl", { Duration = CHARGE_TIME })

			IndicatorService:Create({
				id = indicatorId,
				character = Character,
				ownerId = Player.UserId,
				asset = LunarIndicatorAsset,
			})

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
			ReplicateSet:FireClient(Player, "StopLunarAimControl", {})

			local launchPosition = IndicatorService:GetPosition(Player, indicatorId)
			IndicatorService:Destroy(indicatorId)

			if not Character.Parent or Humanoid.Health <= 0 then
				if Character.Parent then
					restoreControl()
				end
				return
			end

			restoreControl()

			local LaunchDirection = HumRP.CFrame.LookVector
			if launchPosition then
				local toTarget = (launchPosition - (HumRP.Position + Vector3.new(0, 70, 0)))
				if toTarget.Magnitude > 0.01 then
					LaunchDirection = toTarget.Unit
				end
			end

			ReplicateSet:FireAllClients("LunarAwakenMoonLaunch", {
				char = Character,
				direction = LaunchDirection,
				ownerId = Player.UserId,
			})

			local LaunchOrigin = HumRP.Position + Vector3.new(0, 70, 0)
			fireProjectile(Character, LaunchOrigin, LaunchDirection)
			task.spawn(function()
				watchForLanding(Character, Humanoid, HumRP)
			end)
		end)
	)

	AnimTrack.Stopped:Once(function()
		stopRise()
	end)

	AnimationService:playAnimation(Character, LunarEclipseAnim)
	AnimTrack.Stopped:Wait()
	ReplicateSet:FireAllClients("ShowHotbar")
	ReplicateSet:FireAllClients("ShowAwkbar")
end

return module
