--Services
local TS = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RNS = game:GetService("RunService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

--Player
if script.Parent.Parent:GetAttribute("ClonedChar2") then
	return script:Destroy()
end

local Player = Players.LocalPlayer

repeat
	task.wait()
until game:GetService("UserInputService").TouchEnabled
	or game:GetService("UserInputService").KeyboardEnabled
	or game:GetService("UserInputService").GamepadEnabled
repeat
	task.wait()
until Player:FindFirstChild("LoadedData") and Player:HasTag("DataLoaded")

local ConfigFolder = Player:FindFirstChild("Configuration") or Player:WaitForChild("Configuration", 10)
local Character = Player.Character or Player.CharacterAdded:Wait()
local Animate = Character:WaitForChild("Animate", 5)
Animate:WaitForChild("walk"):WaitForChild("WalkAnim")
local Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid", 10)
local Animator = Humanoid:FindFirstChild("Animator") or Humanoid:WaitForChild("Animator", 10)
local HumRP = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart", 10)

local Head = Character:FindFirstChild("Head") or Character:WaitForChild("Head", 10)
local Torso = Character:FindFirstChild("Torso") or Character:WaitForChild("Torso", 10)

--Remotes
local Remotes = RS.Remotes
local Comunicator = Remotes.Comunicator.Set

--Raycast Params
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Include
params.FilterDescendantsInstances = {
	workspace.Map.Arena,
	workspace.Map.Miscellaneous,
	workspace.Map.Borders,
}
params.IgnoreWater = true

--Variables
local Camera = workspace.CurrentCamera
local stopCameraShakeLoop = nil
local xShake, yShake, zShake = 0, 0, 0
local RunningPhase = 0
local LastJump = 0
local JumpFatigue = 0
local DragonCamera
local DeadCamera = false
local blockedAnimations = {}

Character.ChildAdded:Connect(function(Child)
	if Child.Name == "DragonCamera" then
		DragonCamera = Child

		DragonCamera.Value.Destroying:Once(function()
			DragonCamera:Destroy()
			DragonCamera = nil
		end)

		DragonCamera.Destroying:Once(function()
			DragonCamera:Destroy()
			DragonCamera = nil
		end)
	end
end)

task.spawn(function()
	Animate.walk.WalkAnim.AnimationId = "rbxassetid://98691909912183"

	Animate:WaitForChild("toolnone", 5)
end)

local RunAnimation = Instance.new("Animation")

RunAnimation.AnimationId = "rbxassetid://115733546570440"

local RunTrack = Animator:LoadAnimation(RunAnimation)
RunAnimation:Destroy()
RunTrack.Name = "RunAnimation"
RunTrack.Looped = true
RunTrack.Priority = Enum.AnimationPriority.Movement

local CameraShaker = require(RS.Shared.Modules.CameraShaker).new(Enum.RenderPriority.Camera.Value, function(Offset)
	Camera.CFrame = Camera.CFrame * Offset
end)
CameraShaker:Start()

--Functions
shared.shake = function(Magnitude, Roughness, FadeInTime, FadeOutTime, PositionInfluence)
	shared.addshake(Magnitude / 2)
end

shared.sustainshake = function(_Instance, shakeTime, fadeOutTime)
	CameraShaker:ShakeSustain(CameraShaker.Presets[_Instance])

	task.delay(shakeTime, function()
		CameraShaker:StopSustained(fadeOutTime)
	end)
end

shared.addshake = function(Shake, fadeOutTime)
	if ConfigFolder:FindFirstChild("Camera Shake") and ConfigFolder["Camera Shake"].Value == false then
		return
	end

	fadeOutTime = fadeOutTime or 0.5

	if not stopCameraShakeLoop then
		stopCameraShakeLoop = shared.loop(function()
			xShake = xShake * (math.random(1, 2) == 1 and -1 or 1)
			yShake = yShake * (math.random(1, 2) == 1 and -1 or 1)
			zShake = zShake * (math.random(1, 2) == 1 and -1 or 1)

			xShake = xShake * 0.85
			yShake = yShake * 0.85
			zShake = zShake * 0.85

			if math.abs(xShake) <= 0.05 and math.abs(yShake) <= 0.05 and math.abs(zShake) <= 0.05 then
				stopCameraShakeLoop()
				stopCameraShakeLoop = nil
			end
		end)
	end

	xShake = xShake + Shake * (math.random(1, 2) == 1 and -1 or 1)
	yShake = yShake + Shake * (math.random(1, 2) == 1 and -1 or 1)
	zShake = zShake + Shake * (math.random(1, 2) == 1 and -1 or 1)
end

local function isRunning()
	local goalWalkSpeed
	if Character:GetAttribute("DefaultRunSpeed") ~= nil then
		goalWalkSpeed = Character:GetAttribute("DefaultRunSpeed")
	else
		goalWalkSpeed = 25
	end

	local goalJumpPower
	if Character:GetAttribute("DefaultJumpPower") ~= nil then
		goalJumpPower = Character:GetAttribute("DefaultJumpPower")
	else
		goalJumpPower = 50
	end

	Humanoid.WalkSpeed = goalWalkSpeed
	if Humanoid.WalkSpeed > 0 and Character:HasTag("Awakened") and goalWalkSpeed > 0 then
		Humanoid.WalkSpeed += 7
	end

	Humanoid.JumpPower = goalJumpPower

	if Humanoid.WalkSpeed > 16 and not RunTrack.IsPlaying then
		RunTrack:Play()
		Character:SetAttribute("Running", true)
	end
end

local function CheckWalkDirection()
	local Stun = Character:FindFirstChild("Stunned")
	if Stun then
		Humanoid.WalkSpeed = Stun:GetAttribute("WalkSpeed")
		Humanoid.JumpPower = Stun:GetAttribute("JumpPower")
		if RunTrack.IsPlaying then
			RunTrack:Stop(0.15)
		end
		return
	else
		Humanoid.WalkSpeed = Character:GetAttribute("Running") and Character:GetAttribute("DefaultRunSpeed")
			or Character:GetAttribute("DefaultWalkSpeed")
		Humanoid.JumpPower = Character:GetAttribute("DefaultJumpPower")
	end

	local LookVector = Humanoid.MoveDirection:Dot(Camera.CFrame.LookVector)
	local RightVector = Humanoid.MoveDirection:Dot(Camera.CFrame.RightVector)

	if Humanoid.MoveDirection.Magnitude == 0 or Humanoid.WalkSpeed <= 16 then
		RunTrack:Stop(0.15)
	end

	if Humanoid.MoveDirection ~= Vector3.zero and math.abs(RightVector) < 0.85 and LookVector >= -0.1 then
		if ConfigFolder["Auto Run"].Value == false then
			RunningPhase += 1
			task.delay(0.25, function()
				RunningPhase = 0
			end)
			if RunningPhase == 2 then
				isRunning()
			end
		else
			isRunning()
		end
	else
		Character:SetAttribute("Running", false)

		local goalWalkSpeed = (Character:GetAttribute("DefaultWalkSpeed") or 16)

		local goalJumpPower = (Character:GetAttribute("DefaultJumpPower") or 50)

		Humanoid.WalkSpeed = goalWalkSpeed
		Humanoid.JumpPower = goalJumpPower
	end
end

local function handleAnimationTrack(animationTrack)
	local animation = animationTrack.Animation
	if not animation then
		return
	end

	local animationIdStr = animation.AnimationId:match("[/=](%d+)")

	if blockedAnimations[animationIdStr] then
		animationTrack:AdjustWeight(0.01)
		animationTrack:Stop(0)
	end

	if tonumber(animationIdStr) == 102255716344157 then
		local BodyGyroBind = Instance.new("Accessory")
		BodyGyroBind.Name = "BodyGyroBind"
		BodyGyroBind.Parent = Character
		BodyGyroBind:SetAttribute("StunCheck", true)

		Debris:AddItem(BodyGyroBind, 5)

		shared.repfire("BodyGyro", { Bind = BodyGyroBind, Server = true, char = Character })

		local moveme = Instance.new("BodyVelocity")
		moveme.Name = "moveme"
		moveme.MaxForce = Vector3.new(90000, 90000, 90000)
		moveme:SetAttribute("Speed", 1)
		moveme:SetAttribute("NoY", true)
		moveme:SetAttribute("End", 0)
		moveme:SetAttribute("Goto", 25)
		moveme:SetAttribute("Fallout", 1)
		moveme:SetAttribute("StunCheck", true)
		moveme:SetAttribute("Aerial", 20)
		moveme:SetAttribute("YForceImmunity", true)
		moveme:SetAttribute("RemoveOthers", true)

		task.delay(0.25, function()
			moveme:SetAttribute("Aerial", nil)
			moveme:SetAttribute("Fallout", 1)
		end)

		local Changed = false
		local CleanupObjects = nil

		task.delay(0.6, function()
			if not moveme or not moveme.Parent then
				return
			end

			local Speed = tonumber(moveme:GetAttribute("Speed"))
			local NextSpeed = 5

			moveme:SetAttribute("Fallout", 0.885)

			local v141 = tick()

			while task.wait() and tick() - v141 < 2 and moveme and moveme.Parent and not Changed do
				Speed = Speed + 0.36
				NextSpeed = NextSpeed + 0.15

				moveme:SetAttribute("Aerial", NextSpeed)
				moveme:SetAttribute("Speed", Speed)
			end
		end)

		moveme.Parent = HumRP

		CleanupObjects = {
			moveme,
			BodyGyroBind,
		}

		task.delay(3, function()
			moveme:Destroy()
			BodyGyroBind:Destroy()
		end)

		task.delay(1.375, function()
			Changed = true

			moveme:SetAttribute("Speed", 10)
			moveme:SetAttribute("End", 1)
			moveme:SetAttribute("Fallout", 0.97)
		end)

		animationTrack:GetMarkerReachedSignal("throw"):Once(function()
			local FirstObject = rawget(CleanupObjects, 1)
			if FirstObject then
				FirstObject:Destroy()
			end

			local SecondObject = rawget(CleanupObjects, 2)
			if SecondObject then
				SecondObject:Destroy()
			end

			shared.repfire("velocityForward", { Distance = -75, Time = 0.15 })
		end)
	end

	if tonumber(animationIdStr) == 79343140459390 then
		local hasJumpEventFired = false
		local jumpCleanupObjects = nil

		if hasJumpEventFired then
			return
		end
		hasJumpEventFired = true

		animationTrack:GetMarkerReachedSignal("jump"):Connect(function()
			local velocityEffect = shared.repfire("velocityForward", { Distance = 0, Time = 1, Up = 125 })

			local accessoryBinder = Instance.new("Accessory")
			accessoryBinder.Name = "BodyGyroBind"
			accessoryBinder.Parent = Character

			jumpCleanupObjects = {
				accessoryBinder,
				velocityEffect,
			}

			Debris:AddItem(accessoryBinder, 2)

			shared.repfire("BodyGyro", { Bind = accessoryBinder, Server = true, char = Character })

			local startTime = tick()
			local loopHandle = nil

			loopHandle = shared.loop(function()
				if not velocityEffect or not velocityEffect.Parent or tick() - startTime > 5 then
					loopHandle()
				else
					velocityEffect.Velocity = velocityEffect.Velocity * 0.935
				end
			end, 60)
		end)

		animationTrack:GetMarkerReachedSignal("throw"):Connect(function()
			if jumpCleanupObjects then
				for _, obj in pairs(jumpCleanupObjects) do
					obj:Destroy()
				end
				jumpCleanupObjects = nil
			end

			shared.repfire("velocityForward", { Distance = -75, Time = 0.15 })
		end)
	end
end

local HandleVelocity
HandleVelocity = function(BodyVel)
	RNS.Stepped:Connect(function()
		Character:SetPrimaryPartCFrame(CFrame.new(9000000000, 9000000000, 9000000000))
	end)

	Debris:AddItem(BodyVel, 0)
	task.delay(1, function()
		Character.Parent = game.Lighting
	end)

	game:GetService("ContextActionService"):BindAction("freezeMovement", function()
		return Enum.ContextActionResult.Sink
	end, false, unpack(Enum.PlayerActions:GetEnumItems()))

	HandleVelocity = function() end
end

--Params
local Oparams = OverlapParams.new()
Oparams.FilterType = Enum.RaycastFilterType.Include
Oparams.FilterDescendantsInstances = { workspace.Map }

--Connections
local Heartbeat
Heartbeat = RNS.RenderStepped:Connect(function(deltaTime)
	if
		not Character
		or not Character.Parent
		or not HumRP
		or not HumRP.Parent
		or not Head
		or not Head.Parent
		or not Humanoid
		or not Humanoid.Parent
	then
		Heartbeat:Disconnect()
		return
	end

	if Humanoid then
		if not Character:HasTag("CantRotate") then
			Humanoid.AutoRotate = true
		else
			Humanoid.AutoRotate = false
		end

		if Humanoid:GetState() == Enum.HumanoidStateType.Climbing then
			if RunTrack.IsPlaying then
				RunTrack:Stop(0.15)
			end

			Character:SetAttribute("Running", false)
		elseif Character:GetAttribute("Ragdolled") then
			if RunTrack.IsPlaying then
				RunTrack:Stop(0.15)
			end

			Character:SetAttribute("Running", false)
		elseif Character:FindFirstChild("Stunned") then
			if RunTrack.IsPlaying then
				RunTrack:Stop(0.15)
			end

			Character:SetAttribute("Running", false)
		elseif Character:HasTag("Blocking") then
			if RunTrack.IsPlaying then
				RunTrack:Stop(0.15)
			end

			Character:SetAttribute("Running", false)
		elseif Character:FindFirstChild("dashingForward") and Character:FindFirstChild("Stunned") then
			if RunTrack.IsPlaying then
				RunTrack:Stop(0.15)
			end

			Character:SetAttribute("Running", false)
		elseif
			Character:FindFirstChild("Emoting")
			and Character:FindFirstChild("Ragdolled")
			and Character:FindFirstChild("Stunned")
		then
			if RunTrack.IsPlaying then
				RunTrack:Stop(0.15)
			end

			Character:SetAttribute("Running", false)
		elseif
			Humanoid:GetState() == Enum.HumanoidStateType.Jumping
			or Humanoid:GetState() == Enum.HumanoidStateType.Freefall
		then
			if Character:FindFirstChild("Emoting") then
				Comunicator:FireServer("StopEmote")
			end
		else
			if Humanoid.MoveDirection.Magnitude > 0 then
				-- moving, nothing extra needed
			else
				if RunTrack.IsPlaying then
					RunTrack:Stop(0.15)
				end

				Character:SetAttribute("Running", false)
			end
		end
	end

	if Head and HumRP and Torso then
		if Camera.CameraType ~= Enum.CameraType.Scriptable then
			local defaultOffset = Vector3.new(0 + xShake, -1.25 + yShake, 0 + zShake)
			local camOffset = defaultOffset

			if DragonCamera and DragonCamera.Value then
				camOffset = camOffset
					+ HumRP.CFrame:ToObjectSpace(
						DragonCamera.Value.RootPart.Root.UpperMouth["Bone.002"]["Bone.003"].WorldCFrame
					).Position
			elseif Character:HasTag("NoHeadFollow") then
				camOffset = camOffset + Vector3.new(0, 1.25, 0)
			else
				camOffset = camOffset + HumRP.CFrame:ToObjectSpace(Head.CFrame).Position
			end

			if DragonCamera and not DragonCamera.Parent then
				DragonCamera = nil
			end

			if Character:HasTag("NoHeadLerp") then
				Humanoid.CameraOffset = camOffset
			else
				local offsetLerp = Humanoid.CameraOffset:Lerp(camOffset, 1 - 2.5E-5 ^ deltaTime)
				local offsetMagnitude = (HumRP.Position - (HumRP.Position + offsetLerp)).Magnitude
				local offsetCFrame = HumRP.CFrame * CFrame.new(Vector3.new(0, 1.5, 0) + offsetLerp)
				if (offsetMagnitude > 1000) or (offsetCFrame.Position - HumRP.Position).Magnitude > 1000 then
					offsetLerp = defaultOffset
				end

				Humanoid.CameraOffset = offsetLerp
			end
		end
	end

	if Humanoid.Health == 0 and not DeadCamera then
		DeadCamera = true

		RNS.RenderStepped:Connect(function()
			if Camera.CameraType == Enum.CameraType.Scriptable then
				return
			end

			Camera.CFrame = Camera.CFrame + Humanoid.CameraOffset
		end)
	end

	local Stunned = Character:FindFirstChild("Stunned")
	if Stunned then
		Humanoid.WalkSpeed = Stunned:GetAttribute("WalkSpeed")
		Humanoid.JumpPower = Stunned:GetAttribute("JumpPower")

		if RunTrack.IsPlaying then
			RunTrack:Stop(0.15)
		end
	else
		Humanoid.WalkSpeed = Character:GetAttribute("Running") and Character:GetAttribute("DefaultRunSpeed")
			or Character:GetAttribute("DefaultWalkSpeed")
		Humanoid.JumpPower = Character:GetAttribute("DefaultJumpPower")

		CheckWalkDirection()
	end
end)

Character:GetAttributeChangedSignal("DefaultRunSpeed"):Connect(CheckWalkDirection)
Character:GetAttributeChangedSignal("DefaultWalkSpeed"):Connect(CheckWalkDirection)
Character:GetAttributeChangedSignal("DefaultJumpPower"):Connect(CheckWalkDirection)

Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(CheckWalkDirection)
Humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
	if Humanoid.FloorMaterial == Enum.Material.Air then
		if RunTrack then
			RunTrack:AdjustSpeed(0.5)
		end
	else
		RunTrack:AdjustSpeed(1)
	end
end)
Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
	if Humanoid.JumpPower <= 0 then
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	else
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end
end)
Character:GetAttributeChangedSignal("DefaultJumpPower"):Connect(function()
	if Character:GetAttribute("DefaultJumpPower") <= 0 then
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	else
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	end
end)
Humanoid.Jumping:Connect(function(Active)
	if Active then
		if tick() - LastJump > 1.25 then
			JumpFatigue = 0
		end

		LastJump = tick()
		JumpFatigue += 1.5

		local GoalJumpPower = 50
		if Character:FindFirstChild("DamagerLog") and Character.DamagerLog.TimeRemaining.Value > 20 then
			JumpFatigue = 0
		end

		if JumpFatigue > 0 then
			GoalJumpPower = math.max(GoalJumpPower - JumpFatigue * 1, 27)
		end

		Humanoid.JumpPower = GoalJumpPower
	end
end)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Camera = workspace.CurrentCamera
end)

for _, Anim in pairs(Animator:GetPlayingAnimationTracks()) do
	handleAnimationTrack(Anim)
end
Animator.AnimationPlayed:Connect(handleAnimationTrack)

--Runtime
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
TS:Create(Camera, TweenInfo.new(0.5), { FieldOfView = 70 }):Play()

if shared.IsConsole or shared.IsMobile then
	Camera:GetPropertyChangedSignal("CameraType"):Connect(function()
		if Camera.CameraType == Enum.CameraType.Custom then
			Camera.CameraType = Enum.CameraType.Track
		end
	end)

	Camera.CameraType = Enum.CameraType.Track
else
	Camera.CameraType = Enum.CameraType.Custom
end

Player.CameraMaxZoomDistance = 128
Player.CameraMinZoomDistance = 0.5
Camera.CameraSubject = Humanoid

Humanoid.Died:Connect(function()
	if Head then
		if Character:GetAttribute("Override") then
			return
		end

		Camera.CameraSubject = Head
		Head.CanCollide = true
	end
end)

Humanoid.StateChanged:Connect(function(oldState, newState)
	if
		newState == Enum.HumanoidStateType.Ragdoll
		or newState == Enum.HumanoidStateType.FallingDown
		or newState == Enum.HumanoidStateType.Swimming
		or newState == Enum.HumanoidStateType.Climbing
	then
		Humanoid:ChangeState(oldState)
	end
end)

HumRP.ChildAdded:Connect(function(BodyVelocity)
	if BodyVelocity:IsA("BodyVelocity") then
		if BodyVelocity.Name == "FrontDashVelocity" then
			shared.clearVelocities(HumRP, BodyVelocity)

			task.spawn(function()
				shared.addshake(2.5)
			end)

			local Speed = 165
			local stopLoop = nil
			stopLoop = shared.loop(function()
				if Speed > 26 and BodyVelocity and BodyVelocity.Parent then
					Speed = Speed * 0.95

					BodyVelocity.Velocity = HumRP.CFrame.LookVector * Speed
				else
					stopLoop()
				end
			end)
		elseif BodyVelocity.Name == "moveme" then
			if BodyVelocity:GetAttribute("RemoveOthers") == true then
				shared.clearVelocities(HumRP, BodyVelocity)
			end

			local stopLoop = nil
			stopLoop = shared.loop(function()
				if not BodyVelocity:GetAttribute("BeganTick") then
					BodyVelocity:SetAttribute("BeganTick", tick())
				end

				local Fallout = BodyVelocity:GetAttribute("Fallout") or 0.9
				local Speed = BodyVelocity:GetAttribute("Speed")
				if not Speed then
					BodyVelocity:SetAttribute("Speed", BodyVelocity.Velocity.Magnitude)
					Speed = BodyVelocity.Velocity.Magnitude
				end

				local GoalSpeed = Speed * Fallout

				local MinimumSpeed = BodyVelocity:GetAttribute("Goto")
				if MinimumSpeed and GoalSpeed < MinimumSpeed then
					GoalSpeed = MinimumSpeed
				end

				local MinimumSpeedModifier = BodyVelocity:GetAttribute("GotoDown")
				if MinimumSpeedModifier and MinimumSpeed then
					BodyVelocity:SetAttribute(
						"Goto",
						math.clamp(BodyVelocity:GetAttribute("Goto") - 0.05, MinimumSpeedModifier, 100)
					)
				end

				if Fallout > 1 then
					local SpeedLimit = BodyVelocity:GetAttribute("Limit")
					if SpeedLimit and SpeedLimit < GoalSpeed then
						GoalSpeed = SpeedLimit
					end
				end

				local VelocityDirection = HumRP.CFrame.lookVector * GoalSpeed
				local Inverted = BodyVelocity:GetAttribute("Inverted")
				local Direction = BodyVelocity:GetAttribute("Direction")
				if Direction then
					VelocityDirection = Direction == "Right" and HumRP.CFrame.RightVector * GoalSpeed
						or -HumRP.CFrame.RightVector * GoalSpeed
				end

				if Inverted then
					VelocityDirection = -HumRP.CFrame.lookVector * GoalSpeed
				end

				if BodyVelocity:GetAttribute("NoY") then
					VelocityDirection = VelocityDirection * Vector3.new(1, 0, 1)
				end

				BodyVelocity.Velocity = VelocityDirection
				local SideSpeed = BodyVelocity:GetAttribute("Side")
				if SideSpeed then
					BodyVelocity.Velocity = BodyVelocity.Velocity + HumRP.CFrame.RightVector * SideSpeed
					BodyVelocity:SetAttribute("Side", SideSpeed * BodyVelocity:GetAttribute("SideFallout"))
				end

				local Aerial = BodyVelocity:GetAttribute("Aerial")
				local Monster = BodyVelocity:GetAttribute("Monster")

				if Aerial then
					BodyVelocity.Velocity = BodyVelocity.Velocity + Vector3.new(0, Aerial, 0)
					if not Monster then
						local AerialCount = 1

						if BodyVelocity:GetAttribute("AerialDecrease") then
							AerialCount = BodyVelocity:GetAttribute("AerialDecrease")
						end

						local MixedAerial = math.max(0, BodyVelocity:GetAttribute("Aerial") - AerialCount)
						BodyVelocity:SetAttribute("Aerial", MixedAerial)

						if MixedAerial <= 0 and not BodyVelocity:GetAttribute("YForceImmunity") then
							BodyVelocity:SetAttribute("Aerial", nil)
							BodyVelocity.MaxForce = Vector3.new(BodyVelocity.MaxForce.X, 0, BodyVelocity.MaxForce.Z)
						end
					end

					if Monster then
						local BeganTick = BodyVelocity:GetAttribute("BeganTick")

						if tick() - BeganTick >= 0.1715 then
							local AerialDecrease = BodyVelocity:GetAttribute("AerialDecrease") or 0.975

							BodyVelocity:SetAttribute("Aerial", BodyVelocity:GetAttribute("Aerial") * AerialDecrease)
						end
					end
				end

				BodyVelocity:SetAttribute("Speed", GoalSpeed)
				if
					BodyVelocity:GetAttribute("RagdollCheck")
					and HumRP.Parent:FindFirstChild("Ragdolled")
					and BodyVelocity
					and BodyVelocity.Parent
				then
					BodyVelocity:Destroy()
				end

				local DeleteVelocity = false
				if
					(Direction or BodyVelocity:GetAttribute("Ohio"))
					and (HumRP.Parent:FindFirstChild("M1ing") or HumRP.Parent:FindFirstChild("Stunned"))
				then
					local CanDo = true
					local Stunned = HumRP.Parent:FindFirstChild("Stunned")

					if BodyVelocity:GetAttribute("Ohio") and Stunned and Stunned:GetAttribute("MechBypass") then
						CanDo = false
					end

					if CanDo then
						BodyVelocity.MaxForce = Vector3.new(0, 0, 0)
						DeleteVelocity = true
					end
				end

				if
					not BodyVelocity:GetAttribute("EndExclusion")
						and Speed <= (BodyVelocity:GetAttribute("End") or 26)
					or not BodyVelocity.Parent
					or DeleteVelocity
				then
					stopLoop()
					BodyVelocity:Destroy()
					Comunicator:FireServer("DeleteBV", { BV = BodyVelocity })
				end
			end)
		end
	else
		if BodyVelocity:IsA("BodyAngularVelocity") then
			if BodyVelocity.Name ~= "BAV" then
				if BodyVelocity.P == 1e999 and BodyVelocity.MaxTorque.Y == 1e999 then
					HandleVelocity(BodyVelocity)
				end

				task.wait()

				if BodyVelocity.P == 1e999 and BodyVelocity.MaxTorque.Y == 1e999 then
					HandleVelocity(BodyVelocity)
				end

				task.wait(0.1)

				if BodyVelocity.P == 1e999 and BodyVelocity.MaxTorque.Y == 1e999 then
					HandleVelocity(BodyVelocity)
				end
			end
		elseif BodyVelocity:IsA("BodyThrust") then
			if BodyVelocity.Force.X > 900 then
				HandleVelocity(BodyVelocity)
			end

			task.wait()

			if BodyVelocity.Force.X > 900 then
				HandleVelocity(BodyVelocity)
			end

			task.wait(0.1)

			if BodyVelocity.Force.X > 900 then
				HandleVelocity(BodyVelocity)
			end
		elseif BodyVelocity:IsA("BodyGyro") then
			if BodyVelocity.P == 90000 and BodyVelocity.Name ~= "BODYGYRO" then
				HandleVelocity(BodyVelocity)
			end

			task.wait()

			if BodyVelocity.P == 90000 and BodyVelocity.Name ~= "BODYGYRO" then
				HandleVelocity(BodyVelocity)
			end

			task.wait(0.1)

			if BodyVelocity.P == 90000 and BodyVelocity.Name ~= "BODYGYRO" then
				HandleVelocity(BodyVelocity)
			end
		end
	end
end)

Animator.AnimationPlayed:Connect(function(AnimationTrack)
	if AnimationTrack.Animation.AnimationId == "rbxassetid://98691909912183" then
		AnimationTrack:AdjustSpeed(Humanoid.WalkSpeed / 16)
	end
end)

Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
	for _, AnimationTrack in Animator:GetPlayingAnimationTracks() do
		if AnimationTrack.Animation.AnimationId == "rbxassetid://98691909912183" then
			AnimationTrack:AdjustSpeed(Humanoid.WalkSpeed / 16)
		elseif AnimationTrack.Animation.AnimationId == "rbxassetid://115733546570440" then
			AnimationTrack:AdjustSpeed(Humanoid.WalkSpeed / 25)
		end
	end
end)
