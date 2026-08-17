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
local SkillCollision = require(script.Parent.SkillCollision)

local DashHandler = {}

local DASH_HIT_SANITY_TOLERANCE = 35
local DASH_INPUT_DEBOUNCE = 0.5
local HIT_HITBOX_LIFETIME = 0.3

local DashDebounce = {}

local AxisKey = {
	Front = "Dash_Z",
	Back = "Dash_Z",
	Left = "Dash_X",
	Right = "Dash_X",
}

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

	SkillCollision:Lock(Character)

	local Velocity = Instance.new("BodyVelocity")
	Velocity.Name = Config.Id .. "Velocity"
	Velocity.MaxForce = Vector3.new(Config.Speed, 0, Config.Speed)
	Velocity.Velocity = Vector3.new()

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
		SkillCollision:Unlock(Character)
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

	local function resumeDash()
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
		if Distance > DASH_HIT_SANITY_TOLERANCE then
			return
		end

		if iFramesService:HasiFrame(EnemyCharacter, 1) then
			return
		end

		HitList[EnemyCharacter] = true

		local HitAnims = Config.HitAnimations and Config.HitAnimations()
		SFXModule:Play("DashHit", HumRP)

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

		resumeDash()

		StunHandler:Unstun(Character, Stun)
	end

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("jump"):Once(function()
			if Ended then
				return
			end

			Velocity.Parent = HumRP

			startSlopeClamp()

			DashHitbox = ReplicatedHitboxes.new(Player)
			DashHitbox.Instance = HumRP
			DashHitbox.Size = Config.Hitbox.Size
			DashHitbox.Offset = Config.Hitbox.Offset
			DashHitbox.Ignore = { Character }
			DashHitbox.onTouch = function(EnemyCharacter)
				resumeDash()
			end
			DashHitbox.onTimeout = function()
				resumeDash()
			end
			DashHitbox:Start(1, false)
		end)
	)

	table.insert(
		AnimEvents,
		AnimTrack:GetMarkerReachedSignal("freeze"):Once(function()
			if Ended or DashResumed then
				return
			end

			AnimTrack:AdjustSpeed(0)
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
			DashHitbox.onTouch = function(EnemyCharacter)
				applyHit(EnemyCharacter)
			end
			DashHitbox:Once()

			task.delay(HIT_HITBOX_LIFETIME, function()
				destroyDashHitbox()
			end)
		end)
	)

	AnimTrack.Stopped:Once(function()
		for _, v in AnimEvents do
			v:Disconnect()
		end

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

	RemoteManager.FireAllClients("ReplicateTask", "DashMiss", { PrimaryPart = HumRP })

	task.delay(2, function()
		if HumRP and HumRP.Parent then
			HumRP.AssemblyLinearVelocity = Vector3.new()
		end
		endDash()
	end)

	task.delay(1.25, function()
		if Character and Character.Parent then
			AnimTrack:AdjustSpeed(1)
			StunHandler:Unstun(Character, Stun)
		end
	end)
end

local function runDisplacementDash(Player, Character, HumRP, Humanoid, Config)
	local Duration = Config.Duration or 1.017

	Character:SetAttribute("Dashing", true)
	task.delay(Duration, function()
		if Character and Character.Parent then
			Character:SetAttribute("Dashing", false)
		end
	end)

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

	local Animation = Config.Animation and Config.Animation()
	if Animation then
		AnimationService:playAnimation(Character, Animation)
	end
end

function DashHandler:Dash(Player: Player, Direction: string): boolean
	local Character = Player.Character
	if not Character then
		return false
	end

	if DashDebounce[Character] then
		return false
	end

	local Humanoid = Character:FindFirstChild("Humanoid")
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not HumRP then
		return false
	end

	if Character:GetAttribute("Dashing") == true then
		return false
	end

	local Trapped = EvasiveService:IsTrapped(Character)

	if not Trapped and Character:HasTag("CantDash") then
		return false
	end

	if Direction == "Front" and Trapped then
		local Side = HumRP.CFrame.RightVector:Dot(Humanoid.MoveDirection)
		Direction = Side < 0 and "Left" or "Right"
	end

	if Trapped then
		if not EvasiveService:CanEscape(Character) then
			return false
		end
		if not EvasiveService:Escape(Character) then
			return false
		end
	else
		if Character:HasTag("Stunned") then
			return false
		end

		local CooldownId = AxisKey[Direction] or ("Dash_" .. Direction)

		if CooldownSystem:IsOnCooldown(Character, CooldownId) then
			return false
		end
	end

	local Config = getConfig(Player, Direction)
	if not Config then
		warn("[DashHandler] No dash config for direction " .. Direction)
		return false
	end

	local Cooldown = Config.Cooldown or 2
	local CooldownId = AxisKey[Direction] or ("Dash_" .. Direction)

	CooldownSystem:Set(Character, CooldownId, Cooldown)
	RemoteManager.FireClient(Player, "ExtraCds", Direction .. "Dash", Cooldown)
	RemoteManager.FireAllClients("ReplicateTask", "ActionHightlight", { char = Character, func = "Dash" })

	DashDebounce[Character] = true
	task.delay(DASH_INPUT_DEBOUNCE, function()
		DashDebounce[Character] = nil
	end)

	if Config.Type == "Attack" then
		SFXModule:Play("DashStart", HumRP)
	else
		SFXModule:Play("Dash", HumRP)
	end

	if Config.Type == "Attack" then
		runAttackDash(Player, Character, HumRP, Humanoid, Config)
	else
		runDisplacementDash(Player, Character, HumRP, Humanoid, Config)
	end

	return true
end

return DashHandler
