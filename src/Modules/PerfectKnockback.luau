local Perfect = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local SvModules = ServerStorage.Modules

local StunHandler = require(SvModules.StunHandler)
local AnimationService = require(SvModules.AnimationService)
local KnockbackService = require(SvModules.BodymoverService)

local Assets = ServerStorage.Assets
local Animations = Assets.Animations

local Remotes = ReplicatedStorage.Remotes
local ReplicateSet = Remotes.Replicate.Set

local StartAirDetect = ServerStorage.Bindables.AirDetector

Perfect.Active = {}

local MAX_AIR_TIME = 10

local function resetHumanoidState(EnemyCharacter)
	local Humanoid = EnemyCharacter:FindFirstChild("Humanoid")
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
	if Animator then
		for _, track in Animator:GetPlayingAnimationTracks() do
			track:AdjustSpeed(1)
			track:Stop(0)
		end

		local idleAnim = Instance.new("Animation")
		idleAnim.AnimationId = "rbxassetid://507766388"
		local idleTrack = Animator:LoadAnimation(idleAnim)
		idleTrack.Priority = Enum.AnimationPriority.Core
		idleTrack:Play(0)

		task.delay(0.1, function()
			if idleTrack and idleTrack.IsPlaying then
				idleTrack:Stop(0.15)
			end
			idleAnim:Destroy()
		end)
	end
end

function Perfect:Cancel(EnemyCharacter)
	local Data = Perfect.Active[EnemyCharacter]
	if not Data then
		return
	end

	Perfect.Active[EnemyCharacter] = nil

	if Data.Collision then
		Data.Collision:Disconnect()
		Data.Collision = nil
	end

	if Data.KnockbackEvents then
		for _, conn in Data.KnockbackEvents do
			conn:Disconnect()
		end
	end

	if Data.DamageConn then
		Data.DamageConn:Disconnect()
		Data.DamageConn = nil
	end

	if Data.StoppedConnection then
		Data.StoppedConnection:Disconnect()
		Data.StoppedConnection = nil
	end

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

	resetHumanoidState(EnemyCharacter)
end

function Perfect:KnockBack(_, EnemyCharacter, Params, Character)
	if not EnemyCharacter then
		return
	end
	if not EnemyCharacter.Parent then
		return
	end

	local HumanoidRootPart = EnemyCharacter:FindFirstChild("HumanoidRootPart")
	if not HumanoidRootPart then
		return
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

	local EnemyHumanoid = EnemyCharacter.Humanoid

	if EnemyHumanoid.Health <= 0 then
		return
	end

	local Touched = false
	local StartTime = os.clock()

	local BodyVelocity
	local BodyGyro

	local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

	local KnockbackAnimation = Animations.Other.Knockback
	local KnockbackTrack, KnockbackEvents = AnimationService:getAnimationTrack(EnemyCharacter, KnockbackAnimation)

	if not KnockbackTrack then
		warn("[PerfectKB] KnockbackTrack is nil for", EnemyCharacter.Name, "— animation not loaded?")
		StunHandler:Unstun(EnemyCharacter, EnemyStun)
		return
	end

	KnockbackService:makeEnemyFaceCharacter(EnemyCharacter, Character)

	for _, descendant in ipairs(EnemyCharacter:GetDescendants()) do
		if
			descendant:IsA("BodyVelocity")
			or descendant:IsA("BodyAngularVelocity")
			or descendant:IsA("LinearVelocity")
			or descendant:IsA("AngularVelocity")
			or descendant:IsA("VectorForce")
			or descendant:IsA("Torque")
		then
			descendant:Destroy()
		end

		if descendant:IsA("BasePart") then
			descendant.AssemblyLinearVelocity = Vector3.zero
			descendant.AssemblyAngularVelocity = Vector3.zero
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
		BodyVelocity.Velocity = (Params.LookVector * (Params.LookForce * Params.Dot))
		Params.StunFloatTime = 0
	else
		BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.Parent = HumanoidRootPart
		BodyVelocity.P = math.huge
		BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		BodyVelocity.Velocity = (Params.LookVector * (Params.LookForce * Params.Dot)) + Params.UpVelocity
	end

	local ActiveData = {
		KnockbackTrack = KnockbackTrack,
		KnockbackEvents = KnockbackEvents,
		BodyVelocity = BodyVelocity,
		BodyGyro = BodyGyro,
		EnemyStun = EnemyStun,
		Collision = nil,
		StoppedConnection = nil,
		DamageConn = nil,
	}
	Perfect.Active[EnemyCharacter] = ActiveData

	ActiveData.DamageConn = EnemyHumanoid.HealthChanged:Connect(function(newHealth)
		local data = Perfect.Active[EnemyCharacter]
		if not data or data ~= ActiveData then
			return
		end
		if KnockbackTrack.IsPlaying and KnockbackTrack.Speed == 0 then
			Perfect:Cancel(EnemyCharacter)
		end
	end)

	ActiveData.StoppedConnection = KnockbackTrack.Stopped:Connect(function()
		if Perfect.Active[EnemyCharacter] ~= ActiveData then
			return
		end
		Perfect.Active[EnemyCharacter] = nil

		if ActiveData.DamageConn then
			ActiveData.DamageConn:Disconnect()
			ActiveData.DamageConn = nil
		end

		if ActiveData.StoppedConnection then
			ActiveData.StoppedConnection:Disconnect()
			ActiveData.StoppedConnection = nil
		end

		if BodyVelocity and BodyVelocity.Parent then
			BodyVelocity:Destroy()
		end

		if BodyGyro and BodyGyro.Parent then
			BodyGyro:Destroy()
		end

		StunHandler:Unstun(EnemyCharacter, EnemyStun)
		EnemyCharacter:RemoveTag("CantRotate")
		EnemyCharacter:RemoveTag("Knockbacked")

		resetHumanoidState(EnemyCharacter)
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
				BodyVelocity.MaxForce = Vector3.new(1 * 50000, 0, 1 * 50000)
				BodyVelocity.P = 90000
				BodyVelocity.Velocity = (Params.LookVector * ((Params.LookFinalForce * 1.1) * Params.Dot))
			end

			StunHandler:Stun(EnemyCharacter, Params.GroundStunTime, true, 0, 0, true)

			local smallDebris = shared.cfolder({ Name = "SmallDebris" }, 0.75)
			CollectionService:AddTag(smallDebris, "SmallDebris")
			smallDebris.Parent = EnemyCharacter

			ReplicateSet:FireAllClients("smokeEffect", { time = 0.75, char = EnemyCharacter })
		end)
	)

	table.insert(
		KnockbackEvents,
		KnockbackTrack:GetMarkerReachedSignal("end"):Connect(function()
			if BodyVelocity.Parent then
				BodyVelocity.MaxForce = Vector3.new(1 * 50000, 0, 1 * 50000)
				BodyVelocity.P = 90000
				BodyVelocity.Velocity = (Params.LookVector * ((Params.LookFinalForce * 0.8) * Params.Dot))
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
			if BodyVelocity and BodyVelocity.Parent then
				BodyVelocity:Destroy()
			end

			if BodyGyro and BodyGyro.Parent then
				BodyGyro:Destroy()
			end

			StunHandler:Unstun(EnemyCharacter, EnemyStun)
			EnemyCharacter:RemoveTag("CantRotate")
			EnemyCharacter:RemoveTag("Knockbacked")

			if Perfect.Active[EnemyCharacter] == ActiveData then
				Perfect.Active[EnemyCharacter] = nil
				if ActiveData.DamageConn then
					ActiveData.DamageConn:Disconnect()
					ActiveData.DamageConn = nil
				end
				if ActiveData.StoppedConnection then
					ActiveData.StoppedConnection:Disconnect()
					ActiveData.StoppedConnection = nil
				end
			end
		end)
	)

	task.delay(Params.UpVelocityTime, function()
		if not BodyVelocity or not BodyVelocity.Parent then
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

	local function impact(Time)
		if Touched then
			return
		end
		if not Time then
			return
		end

		Touched = true

		KnockbackTrack:AdjustSpeed(1)

		if EnemyCharacter:GetAttribute("Ragdolled") == true then
			if BodyVelocity and BodyVelocity.Parent then
				BodyVelocity:Destroy()
			end

			if BodyGyro and BodyGyro.Parent then
				BodyGyro:Destroy()
			end

			StunHandler:Unstun(EnemyCharacter, EnemyStun)
			EnemyCharacter:RemoveTag("CantRotate")
			EnemyCharacter:RemoveTag("Knockbacked")

			if Perfect.Active[EnemyCharacter] == ActiveData then
				Perfect.Active[EnemyCharacter] = nil
				if ActiveData.DamageConn then
					ActiveData.DamageConn:Disconnect()
					ActiveData.DamageConn = nil
				end
				if ActiveData.StoppedConnection then
					ActiveData.StoppedConnection:Disconnect()
					ActiveData.StoppedConnection = nil
				end
			end
		end
	end

	local Collision
	Collision = RunService.Heartbeat:Connect(function()
		local FinalTime = os.clock() - StartTime

		if EnemyCharacter:GetAttribute("Stunned") == false or not EnemyCharacter.Parent then
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

		local RayParams = RaycastParams.new()
		RayParams.FilterType = Enum.RaycastFilterType.Include
		RayParams.FilterDescendantsInstances = { workspace.Map }

		local rayOrigin = HumanoidRootPart.Position
		local rayDir = Vector3.new(0, -5, 0)

		local Raycast = workspace:Raycast(rayOrigin, rayDir, RayParams)

		if Raycast then
			Collision:Disconnect()
			impact(FinalTime)
		end
	end)

	ActiveData.Collision = Collision

	EnemyCharacter:AddTag("Knockbacked")
	EnemyCharacter:AddTag("CantRotate")

	StartAirDetect:Fire(EnemyCharacter, 0, false)

	AnimationService:stopAll(EnemyCharacter)
	AnimationService:playAnimation(EnemyCharacter, KnockbackAnimation)

	return { KnockbackTrack }
end

return Perfect
