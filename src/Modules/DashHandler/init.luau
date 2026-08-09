local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local SvModules = ServerStorage.Modules

local StunHandler = require(SvModules.StunHandler)
local iFramesService = require(SvModules.iFramesService)
local AnimationService = require(SvModules.AnimationService)

local ReplicatedHitboxes = require(SvModules.ReplicatedHitboxes)
local DamageHandler = require(SvModules.DamageHandler)
local StatusEffectHandler = require(SvModules.StatusEffectHandler)
local CooldownSystem = require(SvModules.CooldownSystem)
local EvasiveService = require(SvModules.EvasiveService)

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local SFXModule = require(ReplicatedStorage.Shared.Modules.SFXModule)

local Configs = require(script.Configs)

local DashHandler = {}

local DASH_HIT_SANITY_TOLERANCE = 15

local function getConfig(Player, Direction)
	local Moveset = Player:GetAttribute("Moveset") or "Default"
	local MovesetConfigs = Configs[Moveset] or Configs.Default
	return MovesetConfigs[Direction]
end

local function runAttackDash(Player: Player, Character: Model, HumRP: BasePart, Humanoid: Humanoid, Config)
	local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)
	local Hit = false
	local Ended = false
	local DashHitbox
	local DashResumed = false
	local HitList = {}
	local SlopeClampConn

	local Animation = Config.Animation()
	local AnimTrack, AnimEvents = AnimationService:getAnimationTrack(Character, Animation)
	if not AnimTrack then
		StunHandler:Unstun(Character, Stun)
		return
	end

	local Velocity = Instance.new("BodyVelocity")
	Velocity.Name = Config.Id .. "Velocity"
	Velocity.MaxForce = Vector3.new(Config.Speed, 0, Config.Speed)

	local function stopSlopeClamp()
		if SlopeClampConn then
			SlopeClampConn:Disconnect()
			SlopeClampConn = nil
		end
	end

	local function startSlopeClamp()
		stopSlopeClamp()
		SlopeClampConn = RunService.Heartbeat:Connect(function()
			if not HumRP or not HumRP.Parent then
				stopSlopeClamp()
				return
			end

			local Vel = HumRP.AssemblyLinearVelocity
			if Vel.Y > 0 then
				HumRP.AssemblyLinearVelocity = Vector3.new(Vel.X, 0, Vel.Z)
			end
		end)
	end

	local function destroyDashHitbox()
		if DashHitbox then
			pcall(function()
				DashHitbox:Destroy()
			end)
			DashHitbox = nil
		end
	end

	local function endDash()
		if Ended then
			return
		end
		Ended = true
		Character:SetAttribute("Dashing", false)
		destroyDashHitbox()
		stopSlopeClamp()
		if Velocity and Velocity.Parent then
			Velocity:Destroy()
		end
		AnimTrack:AdjustSpeed(1)
	end

	local function killVelocity()
		if Velocity and Velocity.Parent then
			Velocity.Velocity = Vector3.new()
			Velocity.MaxForce = Vector3.new()
		end
		if HumRP and HumRP.Parent then
			HumRP.AssemblyLinearVelocity = Vector3.new(0, HumRP.AssemblyLinearVelocity.Y, 0)
		end
	end

	local function resumeDash(WasHit: boolean)
		if Ended or DashResumed then
			return
		end

		DashResumed = true
		AnimTrack:AdjustSpeed(1)
		destroyDashHitbox()

		killVelocity()

		if Velocity and Velocity.Parent then
			Velocity:Destroy()
		end
	end

	local function applyHit(EnemyCharacter: Model)
		if Ended or HitList[EnemyCharacter] then
			return
		end

		local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid") :: Humanoid?
		local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not EnemyHumanoid or not EnemyHumRP or EnemyHumanoid.Health <= 0 then
			return
		end

		if not HumRP or not HumRP.Parent then
			return
		end

		local Distance = (EnemyHumRP.Position - HumRP.Position).Magnitude
		local MaxSanityDistance = Config.Hitbox.Size.Z + DASH_HIT_SANITY_TOLERANCE

		if Distance > MaxSanityDistance then
			return
		end

		if iFramesService:HasiFrame(EnemyCharacter, 1) then
			return
		end

		HitList[EnemyCharacter] = true

		local HitAnims = Config.HitAnimations and Config.HitAnimations()
		SFXModule:Play(Config.HitSound or "Hit", HumRP)

		local HitInfo = DamageHandler:TakeDamage(
			Character,
			EnemyHumanoid,
			Config.Damage,
			Config.StunTime,
			HitAnims and HitAnims[tostring(math.random(1, 3))],
			true,
			true,
			true
		)

		if HitInfo.Countered then
			return
		end

		Hit = true

		resumeDash(true)

		task.delay(0.05, function()
			StunHandler:Unstun(Character, Stun)
		end)
	end

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("jump"):Once(function()
			if Ended then
				return
			end

			Velocity.Parent = HumRP
			Debris:AddItem(Velocity, 0.85)
			startSlopeClamp()
		end)
	)

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("freeze"):Once(function()
			if Ended then
				return
			end

			AnimTrack:AdjustSpeed(0)

			DashHitbox = ReplicatedHitboxes.new(Player)
			DashHitbox.Instance = HumRP
			DashHitbox.Size = Config.Hitbox.Size
			DashHitbox.Offset = Config.Hitbox.Offset
			DashHitbox.Ignore = { Character }
			DashHitbox.onTouch = applyHit
			DashHitbox.onTimeout = function()
				resumeDash(false)
			end
			DashHitbox:Start(1, false)
		end)
	)

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("hit"):Once(function()
			if Ended then
				return
			end

			destroyDashHitbox()

			DashHitbox = ReplicatedHitboxes.new(Player)
			DashHitbox.Instance = HumRP
			DashHitbox.Size = Config.Hitbox.Size
			DashHitbox.Offset = Config.Hitbox.Offset
			DashHitbox.Ignore = { Character }
			DashHitbox.onTouch = applyHit
			DashHitbox:Once()

			task.delay(0.15, function()
				destroyDashHitbox()
			end)
		end)
	)

	AnimTrack.Stopped:Once(function()
		for _, v in AnimEvents do
			v:Disconnect()
		end
		destroyDashHitbox()
		stopSlopeClamp()
		StunHandler:Unstun(Character, Stun)
		if not Hit then
			RemoteManager.FireAllClients(
				"ReplicateTask",
				"DashMiss",
				{ PrimaryPart = HumRP, YAngle = math.pi, Front = true }
			)
		end
	end)

	AnimationService:stopAll(Character)
	AnimationService:playAnimation(Character, Animation)

	Character:SetAttribute("Dashing", true)
	RemoteManager.FireAllClients("ReplicateTask", "ActionHightlight", { char = Character, func = "Dash" })
	RemoteManager.FireAllClients("ReplicateTask", "DashMiss", { PrimaryPart = HumRP })

	task.delay(0.7, function()
		HumRP.AssemblyLinearVelocity = Vector3.new()
		endDash()
	end)

	task.delay(1.25, function()
		if Stun and Stun.Parent == Character then
			AnimTrack:AdjustSpeed(1)
			StunHandler:Unstun(Character, Stun)
		end
	end)
end

local function runDisplacementDash(Player, Character, HumRP, Humanoid, Config)
	local Duration = Config.Duration or 1.017

	if not Config.NoStun then
		StunHandler:Stun(Character, Duration, true, 0, 0, true, nil, false)
	else
		Character:AddTag("CantDash")
		task.delay(Duration, function()
			if Character and Character.Parent then
				Character:RemoveTag("CantDash")
			end
		end)
	end

	if Config.IFrames then
		iFramesService:AddBaseiFrames(Character)
		task.delay(Duration, function()
			iFramesService:RemoveiFrames(Character, "Base")
		end)
	end

	local IsTeleport = StatusEffectHandler:Has(Character, "TpDash")

	if IsTeleport then
		RemoteManager.FireClient(
			Player,
			"ReplicateTask",
			"DashTeleport",
			{ Direction = Config.Id, Duration = Duration }
		)
	else
		RemoteManager.FireAllClients("ReplicateTask", "DashDebris", { func = "Start", char = Character })
		task.delay(Duration, function()
			RemoteManager.FireAllClients("ReplicateTask", "DashDebris", { func = "Stop", char = Character })
		end)
	end

	RemoteManager.FireAllClients("ReplicateTask", "ActionHightlight", { char = Character, func = "Dash" })

	local Animation = Config.Animation and Config.Animation()
	if Animation then
		AnimationService:playAnimation(Character, Animation)
	end
end

function DashHandler:Dash(Player, Direction)
	local Character = Player.Character
	if not Character then
		return
	end

	local Humanoid = Character:FindFirstChild("Humanoid")
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not HumRP then
		return
	end

	local Trapped = EvasiveService:IsTrapped(Character)

	if not Trapped and Character:HasTag("CantDash") then
		return
	end

	if Direction == "Front" and Trapped then
		local Side = HumRP.CFrame.RightVector:Dot(Humanoid.MoveDirection)
		Direction = Side < 0 and "Left" or "Right"
	end

	if Trapped then
		if not EvasiveService:CanEscape(Character) then
			return
		end
		if not EvasiveService:Escape(Character) then
			return
		end
	else
		if Character:HasTag("Stunned") then
			return
		end
		if CooldownSystem:IsOnCooldown(Character, "Dash_" .. Direction) then
			return
		end
	end

	local Config = getConfig(Player, Direction)
	if not Config then
		warn("[DashHandler] No dash config for direction " .. Direction)
		return
	end

	CooldownSystem:Set(Character, "Dash_" .. Direction, Config.Cooldown or 2)
	RemoteManager.FireClient(Player, "ExtraCds", Direction .. "Dash", Config.Cooldown or 2)
	SFXModule:Play(Config.Sound or "Dash", HumRP)

	if Config.Type == "Attack" then
		runAttackDash(Player, Character, HumRP, Humanoid, Config)
	else
		runDisplacementDash(Player, Character, HumRP, Humanoid, Config)
	end
end

return DashHandler
