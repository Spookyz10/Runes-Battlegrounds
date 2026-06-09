local Perfect = {}


-- Services

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")


-- Server Modules

local SvModules = ServerStorage.Modules


local StunHandler = require(SvModules.StunHandler)
local SoundsModule = require(SvModules.SoundsModule)
local AnimationService = require(SvModules.AnimationService)
local KnockbackService = require(SvModules.BodymoverService)


-- Assets

local Assets = ServerStorage.Assets


local Animations = Assets.Animations


-- Remotes

local Remotes = ReplicatedStorage.Remotes


local Replication = Remotes.Replicate

local ReplicateSet = Replication.Set
local ReplicateGet = Replication.Get


local StartAirDetect = ServerStorage.Bindables.AirDetector


-- Functions

function Perfect:KnockBack(EnemyCharacter : Model, Params : {}, Character: Model)
	if not EnemyCharacter then return end
	if not EnemyCharacter.Parent then return end

	local HumanoidRootPart = EnemyCharacter:FindFirstChild("HumanoidRootPart")
	if not HumanoidRootPart then return end


	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {
		workspace.Thrown,
		workspace.Live 
	}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude


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
		Params.DotParams = {-1, 1}
	end

	if Params.DotParams[1] > Params.DotParams[2] then
		Params.DotParams = {-1, 1}
	end


	Params.Dot = math.clamp(Params.Dot, Params.DotParams[1], Params.DotParams[2]) or 1
	Params.GroundStunTime = Params.GroundStunTime or 1.1
	Params.StunFloatTime = Params.StunFloatTime or 0
	Params.UpVelocityTime = Params.UpVelocityTime or 0.2
	Params.EscapableCooldown = math.clamp(Params.EscapableCooldown, 1, 9999999) or 1
	Params.FallingDetectDelay = Params.FallingDetectDelay or 0.715


	local EnemyHumanoid : Humanoid = EnemyCharacter.Humanoid
	local EnemyHumRP : Part = EnemyHumanoid.RootPart
	
	
	if EnemyHumanoid.Health <= 0 then return end
	
	
	local UppercutVFX
	if Params.Saitama then
		local VFX = ServerStorage.Assets.Models["Uppercut VFX"].Uppercut_Start:Clone()
		VFX.Parent = EnemyCharacter

		task.spawn(function()
			for _, descendant in VFX:GetDescendants() do
				if descendant:IsA("ParticleEmitter") then
					descendant.Enabled = true
				end	
			end
		end)
		
		UppercutVFX = VFX
	end
	
	
	local Touched = false
	local Falling = false
	local Freezed = false
	
	
	local StartTime = os.clock()
	
	
	local BodyVelocity
	local BodyGyro
	
	
	local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
	
	
	local KnockbackAnimation = Animations.Other.Knockback
	local KnockbackTrack, KnockbackEvents = AnimationService:getAnimationTrack(EnemyCharacter, KnockbackAnimation)
	
	
	KnockbackService:makeEnemyFaceCharacter(EnemyCharacter, Character)
	
	
	for _, descendant in ipairs(EnemyCharacter:GetDescendants()) do
		if descendant:IsA("BodyVelocity") or descendant:IsA("BodyAngularVelocity") or descendant:IsA("LinearVelocity") or descendant:IsA("AngularVelocity") or descendant:IsA("VectorForce") or descendant:IsA("Torque") then
			descendant:Destroy()
		end
		
		if descendant:IsA("BasePart") then
			descendant.AssemblyLinearVelocity = Vector3.zero
			descendant.AssemblyAngularVelocity = Vector3.zero
		end
	end
	
	
	if Params.LookAt then
		if Params.Ligma then
			EnemyCharacter:PivotTo(Params.LookAt)
		end

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
	
	
	KnockbackTrack.Stopped:Once(function()
		if BodyVelocity then
			if BodyVelocity.Parent then
				BodyVelocity:Destroy()
			end
		end

		if BodyGyro then
			if BodyGyro.Parent then
				BodyGyro:Destroy()
			end
		end

		StunHandler:Unstun(EnemyCharacter, EnemyStun)
		EnemyCharacter:RemoveTag("CantRotate")
		EnemyCharacter:RemoveTag("Knockbacked")
		
		if Params.Saitama then
			if UppercutVFX then
				UppercutVFX:Destroy()
			end
			
			SoundsModule:PlaySound(Assets.Sounds.Moves.Baldhero.Uppercut.Land, EnemyCharacter.Torso)
		end
	end)
	
	
	table.insert(KnockbackEvents, KnockbackTrack:GetMarkerReachedSignal("freeze"):Connect(function()
		if Params.DontFreeze then return end

		if not Touched then
			KnockbackTrack:AdjustSpeed(0)
		end
	end))
	
	table.insert(KnockbackEvents, KnockbackTrack:GetMarkerReachedSignal("impact"):Connect(function()
		if BodyVelocity.Parent then
			BodyVelocity.MaxForce = Vector3.new(1 * 50000, 0, 1 * 50000)
			BodyVelocity.P = 90000
			BodyVelocity.Velocity = (Params.LookVector * ((Params.LookFinalForce*1.1) * Params.Dot))
		end
		
		local GroundStun = StunHandler:Stun(EnemyCharacter, Params.GroundStunTime, true, 0, 0, true)
		
		local smallDebris = shared.cfolder({ Name = "SmallDebris" }, 0.75)
		CollectionService:AddTag(smallDebris, "SmallDebris")
		smallDebris.Parent = EnemyCharacter
		
		ReplicateSet:FireAllClients("smokeEffect", { time = 0.75, char = EnemyCharacter })
		
		SoundsModule:PlaySound(Assets.Sounds.Combat.Knockbacks.Impact, EnemyHumRP)
	end))
	
	table.insert(KnockbackEvents, KnockbackTrack:GetMarkerReachedSignal("end"):Connect(function()
		if BodyVelocity.Parent then
			BodyVelocity.MaxForce = Vector3.new(1 * 50000, 0, 1 * 50000)
			BodyVelocity.P = 90000
			BodyVelocity.Velocity = (Params.LookVector * ((Params.LookFinalForce*0.8) * Params.Dot))
		end
	end))
	
	table.insert(KnockbackEvents, KnockbackTrack:GetMarkerReachedSignal("getup"):Connect(function()
		EnemyCharacter:RemoveTag("CantRotate")
		EnemyCharacter:RemoveTag("Knockbacked")
	end))
	
	table.insert(KnockbackEvents, KnockbackTrack:GetMarkerReachedSignal("landed"):Connect(function()	
		if BodyVelocity then
			if BodyVelocity.Parent then
				BodyVelocity:Destroy()
			end
		end
		
		if BodyGyro then
			if BodyGyro.Parent then
				BodyGyro:Destroy()
			end
		end

		StunHandler:Unstun(EnemyCharacter, EnemyStun)
		EnemyCharacter:RemoveTag("CantRotate")
		EnemyCharacter:RemoveTag("Knockbacked")
	end))
	
	
	task.delay(Params.UpVelocityTime, function()
		if BodyVelocity.Parent then
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
		end
	end)
	
	task.delay(Params.FallingDetectDelay + Params.StunFloatTime, function()
		if BodyVelocity.Parent then
			Falling = true
		end
	end)
	
	
	local function impact(Time : number)
		if Touched or not Time then return end

		if not Touched then
			Touched = true

			if Time >= 0.1331675 then
				local RandomValue = math.random(1, 2)
				
				if RandomValue == 1 then
					SoundsModule:PlaySound(Assets.Sounds.Combat.Knockbacks.Sound1, EnemyHumRP)
				else
					SoundsModule:PlaySound(Assets.Sounds.Combat.Knockbacks.Sound2, EnemyHumRP)
				end
			end

			KnockbackTrack:AdjustSpeed(1)
			
			if Params.Saitama then
				local LaunchLanded = shared.cfolder({
					Name = "LaunchLanded"
				}, 2)
				LaunchLanded.Parent = EnemyCharacter
			end
			
			if EnemyCharacter:GetAttribute("Ragdolled") == true then
				if BodyVelocity then
					if BodyVelocity.Parent then
						BodyVelocity:Destroy()
					end
				end

				if BodyGyro then
					if BodyGyro.Parent then
						BodyGyro:Destroy()
					end
				end

				StunHandler:Unstun(EnemyCharacter, EnemyStun)
				EnemyCharacter:RemoveTag("CantRotate")
				EnemyCharacter:RemoveTag("Knockbacked")
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
		
		
		local RayParams = RaycastParams.new()
		RayParams.FilterType = Enum.RaycastFilterType.Include
		RayParams.FilterDescendantsInstances = { workspace.Map }
		
		
		if FinalTime < 1.5 then		
			local Raycast = workspace:Raycast(HumanoidRootPart.Position, Vector3.new(0, -3.45, 0), RayParams)
			
			if Raycast then
				if Falling then
					Collision:Disconnect()
					impact(FinalTime)
				end
				
				return
			end
		else
			local Raycast = workspace:Raycast(HumanoidRootPart.Position, Vector3.new(0, -27.5, 0), RayParams)
			
			if Raycast then
				if Falling then
					Collision:Disconnect()
					
					impact(FinalTime)
				end
				
				return
			end
		end
	end)
	
	
	EnemyCharacter:AddTag("Knockbacked")
	EnemyCharacter:AddTag("CantRotate")
	
	StartAirDetect:Fire(EnemyCharacter, 0, false)
	
	AnimationService:stopAll(EnemyCharacter)
	AnimationService:playAnimation(EnemyCharacter, KnockbackAnimation)
	
	
	if Params.Saitama then
		ReplicateSet:FireAllClients("saitamaAirTrail", { Hit = EnemyCharacter, Root = EnemyHumRP, Uppercut = UppercutVFX })
	end
	
	return {
		KnockbackTrack
	}
end


return Perfect