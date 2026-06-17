local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SvModules = ServerStorage.Modules

local StunHandler = require(SvModules.StunHandler)
local DamageHandler = require(SvModules.DamageHandler)
local NewKnockback = require(SvModules.BodymoverService)
local iFramesService = require(SvModules.iFramesService)

local Remotes = ReplicatedStorage.Remotes
local ReplicateSet = Remotes.Replicate.Set

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = { workspace.Map }
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true

local ExplosionOverlapParams = OverlapParams.new()
ExplosionOverlapParams.FilterType = Enum.RaycastFilterType.Include
ExplosionOverlapParams.FilterDescendantsInstances = { workspace.Live }

local ProjectileRayParams = RaycastParams.new()
ProjectileRayParams.FilterType = Enum.RaycastFilterType.Exclude

local RISE_HEIGHT = 60
local CHARGE_TIME = 5
local PROJECTILE_SPEED = 80
local PROJECTILE_LIFETIME = 10
local PROJECTILE_SIZE = Vector3.new(2, 2, 2)
local EXPLOSION_SIZE = Vector3.new(100, 100, 100)
local IMPACT_SIZE = Vector3.new(30, 30, 30)

local module = {}

local function radialKnockback(Character, EnemyCharacter, EnemyHumanoid, ExplosionPosition, BaseForce, Damage)
	local EnemyHumRP = EnemyCharacter.HumanoidRootPart

	local Direction = (EnemyHumRP.Position - ExplosionPosition)
	if Direction.Magnitude <= 0.05 then
		Direction = Vector3.new(0, 1, 0)
	else
		Direction = Direction.Unit
	end

	DamageHandler:TakeDamage(Character, EnemyHumanoid, Damage, 1, nil, false, false, true, true, true, nil, nil)

	NewKnockback:Knockback(EnemyCharacter, {
		KnockbackType = "Velocity",
		MaxForce = Vector3.new(1, 1, 1) * 100000,
		Velocity = Direction * BaseForce + Vector3.new(0, BaseForce * 0.6, 0),
	})
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

	ReplicateSet:FireAllClients("Ground Crater", {
		Seed = math.random(1, 2000000000),
		start = Position,
		["end"] = Vector3.new(0, -14, 0),
		amount = 16,
		size = 3,
		nosound = true,
	})

	if Player then
		ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 10, Last = 1 })
	end

	local TouchedCharacters = workspace:GetPartBoundsInBox(CFrame.new(Position), EXPLOSION_SIZE, ExplosionOverlapParams)
	local AlreadyHit = {}

	for _, Part in TouchedCharacters do
		if not Part or not Part.Parent then
			continue
		end

		local EnemyCharacter = Part.Parent
		if AlreadyHit[EnemyCharacter] or EnemyCharacter == Character then
			continue
		end

		local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
		if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then
			continue
		end

		local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
		if EnemyPlayer and not EnemyPlayer:FindFirstChild("LoadedData") then
			continue
		end

		AlreadyHit[EnemyCharacter] = true

		radialKnockback(Character, EnemyCharacter, EnemyHumanoid, Position, 145, 18)
	end
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
	Projectile.Parent = workspace.Thrown

	Debris:AddItem(Projectile, PROJECTILE_LIFETIME + 1)

	local RayParams = ProjectileRayParams
	RayParams.FilterDescendantsInstances = { Character, Projectile }

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
		local RayResult = workspace:Raycast(Projectile.Position, Step, RayParams)

		if RayResult then
			Exploded = true
			local ImpactPosition = RayResult.Position
			Connection:Disconnect()
			Projectile:Destroy()
			explode(Character, ImpactPosition)
			return
		end

		local TouchingParts = workspace:GetPartBoundsInRadius(Projectile.Position, PROJECTILE_SIZE.X, RayParams)
		for _, Part in TouchingParts do
			if Part and Part.Parent and Part.CanCollide ~= false then
				local PartCharacter = Part.Parent
				local PartHumanoid = PartCharacter:FindFirstChild("Humanoid")
				if PartHumanoid and PartCharacter ~= Character then
					Exploded = true
					local Position = Projectile.Position
					Connection:Disconnect()
					Projectile:Destroy()
					explode(Character, Position)
					return
				end
			end
		end

		Projectile.CFrame = CFrame.new(Projectile.Position + Step, Projectile.Position + Step + Direction)
	end)
end

local function triggerLandingImpact(Character, Position)
	local ImpactStun = StunHandler:Stun(Character, 0.4, true, 0, 0, true)

	local TouchedCharacters = workspace:GetPartBoundsInBox(CFrame.new(Position), IMPACT_SIZE, ExplosionOverlapParams)
	local AlreadyHit = {}

	for _, Part in TouchedCharacters do
		if not Part or not Part.Parent then
			continue
		end

		local EnemyCharacter = Part.Parent
		if AlreadyHit[EnemyCharacter] or EnemyCharacter == Character then
			continue
		end

		local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
		if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then
			continue
		end

		local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
		if EnemyPlayer and not EnemyPlayer:FindFirstChild("LoadedData") then
			continue
		end

		AlreadyHit[EnemyCharacter] = true

		radialKnockback(Character, EnemyCharacter, EnemyHumanoid, Position, 95, 12)
	end

	ReplicateSet:FireAllClients("Ground Crater", {
		Seed = math.random(1, 2000000000),
		start = Position,
		["end"] = Vector3.new(0, -14, 0),
		amount = 9,
		size = 1.5,
		nosound = true,
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

	local StartPosition = HumRP.Position
	local TargetY = StartPosition.Y + RISE_HEIGHT

	local RiseBodyPosition = Instance.new("BodyPosition")
	RiseBodyPosition.Name = "LunarAwaken_Rise"
	RiseBodyPosition.MaxForce = Vector3.new(0, math.huge, 0)
	RiseBodyPosition.P = 10000
	RiseBodyPosition.D = 500
	RiseBodyPosition.Position = Vector3.new(StartPosition.X, TargetY, StartPosition.Z)
	RiseBodyPosition.Parent = HumRP

	local RiseConnection
	RiseConnection = RunService.Heartbeat:Connect(function()
		if not RiseBodyPosition or not RiseBodyPosition.Parent then
			if RiseConnection then
				RiseConnection:Disconnect()
			end
			return
		end

		RiseBodyPosition.Position = Vector3.new(HumRP.Position.X, TargetY, HumRP.Position.Z)
	end)

	task.wait(CHARGE_TIME)

	if RiseConnection then
		RiseConnection:Disconnect()
		RiseConnection = nil
	end

	if RiseBodyPosition and RiseBodyPosition.Parent then
		RiseBodyPosition:Destroy()
	end

	if not Character.Parent or Humanoid.Health <= 0 then
		return
	end

	local LaunchDirection = HumRP.CFrame.LookVector
	local LaunchOrigin = HumRP.Position

	fireProjectile(Character, LaunchOrigin, LaunchDirection)
	watchForLanding(Character, Humanoid, HumRP)
end

return module
