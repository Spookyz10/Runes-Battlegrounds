local Perfect = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local SvModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local StunHandler = require(SvModules.StunHandler)
local AnimationService = require(SvModules.AnimationService)
local KnockbackService = require(SvModules.BodymoverService)
local RagdollHandler = require(SvModules.RagdollHandler)
local AirDetectionService = require(SvModules.AirDetectionService)
local CombatEvents = require(SvModules.CombatEvents)
local NetworkOwnershipLock = require(SvModules.NetworkOwnershipLock)

local Assets = ServerStorage.Assets
local Animations = Assets.Animations

export type KnockbackParams = {
	Dot: number?,
	DotParams: { number }?,
	LookAt: CFrame?,
	LookVector: Vector3,
	LookForce: number,
	LookFinalForce: number,
	UpVelocity: Vector3?,
	UpVelocityTime: number?,
	StunFloatTime: number?,
	GroundStunTime: number?,
	FallingDetectDelay: number?,
	EscapableCooldown: number?,
	Escapable: boolean?,
	DontFreeze: boolean?,
}

type ActiveData = {
	KnockbackTrack: AnimationTrack,
	KnockbackEvents: { RBXScriptConnection },
	BodyVelocity: BodyVelocity?,
	BodyGyro: BodyGyro?,
	EnemyStun: any,
	Escapable: boolean,
	EscapableCooldown: number,
	Collision: RBXScriptConnection?,
	StoppedConnection: RBXScriptConnection?,
	DamageConn: RBXScriptConnection?,
	OriginalOwner: Player?,
	OwnerRestored: boolean,
	StartTime: number,
}

Perfect.Active = {} :: { [Model]: ActiveData }

local MAX_AIR_TIME = 10
local IGNORE_DAMAGE_WINDOW = 0.05

local function resetHumanoidState(EnemyCharacter: Model)
	local Humanoid = EnemyCharacter:FindFirstChild("Humanoid") :: Humanoid?
	if not Humanoid then
		return
	end

	Humanoid.AutoRotate = true

	Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)

	if
		Humanoid:GetState() == Enum.HumanoidStateType.Physics
		or Humanoid:GetState() == Enum.HumanoidStateType.PlatformStanding
		or Humanoid:GetState() == Enum.HumanoidStateType.FallingDown
	then
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end

	local Animator = Humanoid:FindFirstChildOfClass("Animator")
	if not Animator then
		return
	end

	for _, Track in Animator:GetPlayingAnimationTracks() do
		Track:AdjustSpeed(1)
		Track:Stop(0)
	end

	local IdleAnim = Instance.new("Animation")
	IdleAnim.AnimationId = "rbxassetid://507766388"
	local IdleTrack = Animator:LoadAnimation(IdleAnim)
	IdleTrack.Priority = Enum.AnimationPriority.Core
	IdleTrack:Play(0)

	task.delay(0.1, function()
		if IdleTrack.IsPlaying then
			IdleTrack:Stop(0.15)
		end
		IdleAnim:Destroy()
	end)
end

local function disconnectActive(ActiveData: ActiveData)
	if ActiveData.DamageConn then
		ActiveData.DamageConn:Disconnect()
		ActiveData.DamageConn = nil
	end

	if ActiveData.StoppedConnection then
		ActiveData.StoppedConnection:Disconnect()
		ActiveData.StoppedConnection = nil
	end
end

local function restoreOwnership(EnemyCharacter: Model, ActiveData: ActiveData)
	if ActiveData.OwnerRestored then
		return
	end
	ActiveData.OwnerRestored = true

	local HumanoidRootPart = EnemyCharacter:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not HumanoidRootPart or not HumanoidRootPart.Parent then
		return
	end

	NetworkOwnershipLock:Release(HumanoidRootPart, ActiveData.OriginalOwner)
end

local function finishKnockback(EnemyCharacter: Model, ActiveData: ActiveData)
	if Perfect.Active[EnemyCharacter] ~= ActiveData then
		return
	end
	Perfect.Active[EnemyCharacter] = nil

	disconnectActive(ActiveData)

	if ActiveData.BodyVelocity and ActiveData.BodyVelocity.Parent then
		ActiveData.BodyVelocity:Destroy()
	end

	if ActiveData.BodyGyro and ActiveData.BodyGyro.Parent then
		ActiveData.BodyGyro:Destroy()
	end

	StunHandler:Unstun(EnemyCharacter, ActiveData.EnemyStun)
	EnemyCharacter:RemoveTag("CantRotate")
	EnemyCharacter:RemoveTag("Knockbacked")

	restoreOwnership(EnemyCharacter, ActiveData)
	resetHumanoidState(EnemyCharacter)
end

function Perfect:Cancel(EnemyCharacter: Model)
	local Data = Perfect.Active[EnemyCharacter]
	if not Data then
		return
	end

	Perfect.Active[EnemyCharacter] = nil

	if Data.Collision then
		Data.Collision:Disconnect()
		Data.Collision = nil
	end

	for _, Conn in Data.KnockbackEvents do
		Conn:Disconnect()
	end

	disconnectActive(Data)

	if Data.KnockbackTrack then
		Data.KnockbackTrack:AdjustSpeed(1)
		Data.KnockbackTrack:Stop(0)
	end

	if Data.BodyVelocity and Data.BodyVelocity.Parent then
		Data.BodyVelocity:Destroy()
	end

	if Data.BodyGyro and Data.BodyGyro.Parent then
		Data.BodyGyro:Destroy()
	end

	if Data.EnemyStun then
		StunHandler:Unstun(EnemyCharacter, Data.EnemyStun)
	end

	EnemyCharacter:RemoveTag("CantRotate")
	EnemyCharacter:RemoveTag("Knockbacked")

	restoreOwnership(EnemyCharacter, Data)
	resetHumanoidState(EnemyCharacter)
end

function Perfect:CanEscape(EnemyCharacter: Model): boolean
	local Data = Perfect.Active[EnemyCharacter]
	if not Data then
		return false
	end

	return Data.Escapable ~= false and (os.clock() - Data.StartTime) >= Data.EscapableCooldown
end

function Perfect:Escape(EnemyCharacter: Model): boolean
	if not Perfect:CanEscape(EnemyCharacter) then
		return false
	end

	Perfect:Cancel(EnemyCharacter)
	return true
end

RagdollHandler.RegisterActiveKnockbackCanceller(function(Character: Model)
	if Perfect.Active[Character] then
		Perfect:Cancel(Character)
	end
end)

function Perfect:KnockBack(_, EnemyCharacter: Model, Params: KnockbackParams, Character: Model)
	if not EnemyCharacter or not EnemyCharacter.Parent then
		return
	end

	local HumanoidRootPart = EnemyCharacter:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not HumanoidRootPart then
		return
	end

	local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid") :: Humanoid?
	if not EnemyHumanoid then
		return
	end

	if EnemyCharacter:HasTag("Ragdolled") then
		RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, false, true, true)
	end

	Perfect:Cancel(EnemyCharacter)

	if Params.DontFreeze == nil then
		Params.DontFreeze = false
	end

	if Params.EscapableCooldown == nil or typeof(Params.EscapableCooldown) ~= "number" then
		Params.EscapableCooldown = 1
	end

	if not Params.Dot then
		Params.Dot = 1
	end

	if not Params.DotParams then
		Params.DotParams = { -1, 1 }
	end

	if Params.DotParams[1] > Params.DotParams[2] then
		Params.DotParams = { -1, 1 }
	end

	Params.Dot = math.clamp(Params.Dot, Params.DotParams[1], Params.DotParams[2]) or 1
	Params.GroundStunTime = Params.GroundStunTime or 1.1
	Params.StunFloatTime = Params.StunFloatTime or 0
	Params.UpVelocityTime = Params.UpVelocityTime or 0.2
	Params.EscapableCooldown = math.clamp(Params.EscapableCooldown, 1, 9999999) or 1
	Params.FallingDetectDelay = Params.FallingDetectDelay or 0.715
	Params.Escapable = Params.Escapable ~= false

	local OriginalOwner: Player? = nil

	local Ok, CurrentOwner = pcall(function()
		return HumanoidRootPart:GetNetworkOwner()
	end)
	if Ok then
		OriginalOwner = CurrentOwner
	end

	if EnemyHumanoid.Health <= 0 then
		NetworkOwnershipLock:Take(HumanoidRootPart)
		local DeathVelocity = Instance.new("BodyVelocity")
		DeathVelocity.Parent = HumanoidRootPart
		DeathVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		DeathVelocity.Velocity = (Params.LookVector * Params.LookForce) + (Params.UpVelocity or Vector3.zero)
		Debris:AddItem(DeathVelocity, 0.5)
		task.delay(0.5, function()
			NetworkOwnershipLock:Release(HumanoidRootPart, OriginalOwner)
		end)
		return
	end

	NetworkOwnershipLock:Take(HumanoidRootPart)

	local Touched = false
	local StartTime = os.clock()
	local GroundContactStart = nil
	local REQUIRED_GROUND_TIME = 0.12
	local MAX_GROUND_CHECK_DIST = 3.5

	local BodyVelocity: BodyVelocity
	local BodyGyro: BodyGyro?

	local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

	local KnockbackAnimation = Animations.Other.Knockback

	local KnockbackTrack, KnockbackEvents = AnimationService:getAnimationTrack(EnemyCharacter, KnockbackAnimation)

	if not KnockbackTrack then
		warn("[PerfectKB] KnockbackTrack is nil for", EnemyCharacter.Name, "— animation not loaded?")
		StunHandler:Unstun(EnemyCharacter, EnemyStun)
		NetworkOwnershipLock:Release(HumanoidRootPart, OriginalOwner)
		return
	end

	KnockbackService:makeEnemyFaceCharacter(EnemyCharacter, Character)

	for _, Descendant in EnemyCharacter:GetDescendants() do
		if
			Descendant:IsA("BodyVelocity")
			or Descendant:IsA("BodyAngularVelocity")
			or Descendant:IsA("LinearVelocity")
			or Descendant:IsA("AngularVelocity")
			or Descendant:IsA("VectorForce")
			or Descendant:IsA("Torque")
		then
			Descendant:Destroy()
		elseif Descendant:IsA("BasePart") then
			Descendant.AssemblyLinearVelocity = Vector3.zero
			Descendant.AssemblyAngularVelocity = Vector3.zero
		end
	end

	if Params.LookAt then
		BodyGyro = Instance.new("BodyGyro")
		BodyGyro.Parent = HumanoidRootPart
		BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		BodyGyro.CFrame = Params.LookAt
		BodyGyro.P = 20000000
		BodyGyro.D = 20000000
		Debris:AddItem(BodyGyro, 15)
	end

	if not Params.UpVelocity then
		BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.Parent = HumanoidRootPart
		BodyVelocity.P = math.huge
		BodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
		BodyVelocity.Velocity = Params.LookVector * (Params.LookForce * Params.Dot)
		Params.StunFloatTime = 0
	else
		BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.Parent = HumanoidRootPart
		BodyVelocity.P = math.huge
		BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		BodyVelocity.Velocity = (Params.LookVector * (Params.LookForce * Params.Dot)) + Params.UpVelocity
	end

	local ActiveData: ActiveData = {
		KnockbackTrack = KnockbackTrack,
		KnockbackEvents = KnockbackEvents,
		BodyVelocity = BodyVelocity,
		BodyGyro = BodyGyro,
		EnemyStun = EnemyStun,
		Escapable = Params.Escapable,
		EscapableCooldown = Params.EscapableCooldown,
		Collision = nil,
		StoppedConnection = nil,
		DamageConn = nil,
		OriginalOwner = OriginalOwner,
		OwnerRestored = false,
		StartTime = StartTime,
	}
	Perfect.Active[EnemyCharacter] = ActiveData

	ActiveData.DamageConn = CombatEvents.DamageDealt:Connect(function(_, Damaged, _, _)
		if Perfect.Active[EnemyCharacter] ~= ActiveData then
			return
		end
		if Damaged ~= EnemyCharacter then
			return
		end
		if (os.clock() - ActiveData.StartTime) < IGNORE_DAMAGE_WINDOW then
			return
		end
		if KnockbackTrack.IsPlaying and KnockbackTrack.Speed == 0 then
			Perfect:Cancel(EnemyCharacter)
		end
	end)

	ActiveData.StoppedConnection = KnockbackTrack.Stopped:Connect(function()
		finishKnockback(EnemyCharacter, ActiveData)
	end)

	table.insert(
		KnockbackEvents,
		KnockbackTrack:GetMarkerReachedSignal("freeze"):Connect(function()
			if Params.DontFreeze then
				return
			end

			if not Touched then
				KnockbackTrack:AdjustSpeed(0)
			end
		end)
	)

	table.insert(
		KnockbackEvents,
		KnockbackTrack:GetMarkerReachedSignal("impact"):Connect(function()
			if BodyVelocity.Parent then
				BodyVelocity.MaxForce = Vector3.new(50000, 0, 50000)
				BodyVelocity.P = 90000
				BodyVelocity.Velocity = Params.LookVector * (Params.LookFinalForce * 1.1 * Params.Dot)
			end

			StunHandler:Stun(EnemyCharacter, Params.GroundStunTime, true, 0, 0, true)

			RemoteManager.FireAllClients("ReplicateTask", "smokeEffect", { time = 0.75, char = EnemyCharacter })
		end)
	)

	table.insert(
		KnockbackEvents,
		KnockbackTrack:GetMarkerReachedSignal("end"):Connect(function()
			if BodyVelocity.Parent then
				BodyVelocity.MaxForce = Vector3.new(50000, 0, 50000)
				BodyVelocity.P = 90000
				BodyVelocity.Velocity = Params.LookVector * (Params.LookFinalForce * 0.8 * Params.Dot)
			end
		end)
	)

	table.insert(
		KnockbackEvents,
		KnockbackTrack:GetMarkerReachedSignal("getup"):Connect(function()
			EnemyCharacter:RemoveTag("CantRotate")
			EnemyCharacter:RemoveTag("Knockbacked")
		end)
	)

	table.insert(
		KnockbackEvents,
		KnockbackTrack:GetMarkerReachedSignal("landed"):Connect(function()
			finishKnockback(EnemyCharacter, ActiveData)
		end)
	)

	task.delay(Params.UpVelocityTime, function()
		if not BodyVelocity.Parent then
			return
		end

		if Params.StunFloatTime > 0 then
			BodyVelocity.Velocity = (Params.LookVector * Params.LookForce) + Vector3.new(0, 0, 0)

			task.delay(Params.StunFloatTime, function()
				if BodyVelocity.Parent then
					BodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
				end
			end)
		else
			BodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
		end
	end)

	local function impact(Time: number?)
		if Touched or not Time then
			return
		end

		Touched = true

		KnockbackTrack:AdjustSpeed(1)

		if EnemyCharacter:GetAttribute("Ragdolled") == true then
			finishKnockback(EnemyCharacter, ActiveData)
		end
	end

	local Collision: RBXScriptConnection
	Collision = RunService.Heartbeat:Connect(function()
		local FinalTime = os.clock() - StartTime

		if not EnemyStun or not EnemyStun.Parent or not EnemyCharacter.Parent then
			Collision:Disconnect()
			impact(0)
			return
		end

		if FinalTime >= MAX_AIR_TIME then
			Collision:Disconnect()
			impact(FinalTime)
			return
		end

		if FinalTime < Params.FallingDetectDelay then
			return
		end

		if HumanoidRootPart.AssemblyLinearVelocity.Y > 2 then
			GroundContactStart = nil
			return
		end

		local RayParams = RaycastParams.new()
		RayParams.FilterType = Enum.RaycastFilterType.Include
		RayParams.FilterDescendantsInstances = { workspace.Map }

		local Raycast =
			workspace:Raycast(HumanoidRootPart.Position, Vector3.new(0, -MAX_GROUND_CHECK_DIST, 0), RayParams)

		if Raycast then
			if not GroundContactStart then
				GroundContactStart = os.clock()
			end

			if (os.clock() - GroundContactStart) >= REQUIRED_GROUND_TIME then
				Collision:Disconnect()
				impact(FinalTime)
			end
		else
			GroundContactStart = nil
		end
	end)

	ActiveData.Collision = Collision

	EnemyCharacter:AddTag("Knockbacked")
	EnemyCharacter:AddTag("CantRotate")

	AirDetectionService:Start(EnemyCharacter, {
		justDown = 3,
	})

	AnimationService:stopAll(EnemyCharacter)
	AnimationService:playAnimation(EnemyCharacter, KnockbackAnimation)

	return { KnockbackTrack }
end

return Perfect
