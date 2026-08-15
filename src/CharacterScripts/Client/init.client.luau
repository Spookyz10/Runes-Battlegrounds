local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientContext = require(ReplicatedStorage.Shared.Modules.ClientContext)
local CameraShakeController = require(ReplicatedStorage.Shared.Modules.Functions.CameraShakerController)
local Loop = require(ReplicatedStorage.Shared.Modules.Functions.Loop)
local HandleVelocity = require(ReplicatedStorage.Shared.Modules.Functions.HandleVelocity)
local Tasks = require(ReplicatedStorage.Shared.Modules.Functions.Tasks)
local FootstepSFX = require(ReplicatedStorage.Shared.Modules.Functions.FootstepSFX)

if script.Parent.Parent:GetAttribute("ClonedChar2") then
	return script:Destroy()
end

local Player: Player = Players.LocalPlayer

repeat
	task.wait()
until game:GetService("UserInputService").TouchEnabled
	or game:GetService("UserInputService").KeyboardEnabled
	or game:GetService("UserInputService").GamepadEnabled

repeat
	task.wait()
until Player:FindFirstChild("LoadedData") and Player:HasTag("DataLoaded")

local ConfigFolder: Folder = Player:FindFirstChild("Configuration") or Player:WaitForChild("Configuration", 10)
local Character: Model = Player.Character or Player.CharacterAdded:Wait()
local Animate: Instance = Character:WaitForChild("Animate", 5)
Animate:WaitForChild("walk"):WaitForChild("WalkAnim")
local Humanoid: Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid", 10)
local Animator: Animator = Humanoid:FindFirstChild("Animator") or Humanoid:WaitForChild("Animator", 10)
local HumRP: BasePart = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart", 10)

local Head: BasePart = Character:FindFirstChild("Head") or Character:WaitForChild("Head", 10)
local Torso: BasePart = Character:FindFirstChild("Torso") or Character:WaitForChild("Torso", 10)

local Camera: Camera = workspace.CurrentCamera

local LastJumpTime: number = 0
local JumpFatigue: number = 0
local IsDeadCameraActive: boolean = false

task.spawn(function()
	Animate.walk.WalkAnim.AnimationId = "rbxassetid://98691909912183"
end)

local RunAnimation: Animation = Instance.new("Animation")
RunAnimation.AnimationId = "rbxassetid://85109426953918"

local RunTrack: AnimationTrack = Animator:LoadAnimation(RunAnimation)
RunAnimation:Destroy()
RunTrack.Name = "RunAnimation"
RunTrack.Looped = true
RunTrack.Priority = Enum.AnimationPriority.Movement

CameraShakeController.Init(
	Camera,
	ConfigFolder,
	require(ReplicatedStorage.Shared.Modules.CameraShaker),
	Enum.RenderPriority.Camera.Value
)

local function isRunning()
	local goalWalkSpeed: number = Character:GetAttribute("DefaultRunSpeed") or 25
	local goalJumpPower: number = Character:GetAttribute("DefaultJumpPower") or 50

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

local function checkWalkDirection()
	local StunnedFolder: Folder? = Character:FindFirstChild("Stunned")
	if StunnedFolder then
		Humanoid.WalkSpeed = StunnedFolder:GetAttribute("WalkSpeed") or 0
		Humanoid.JumpPower = StunnedFolder:GetAttribute("JumpPower") or 0
		if RunTrack.IsPlaying then
			RunTrack:Stop(0.15)
		end
		return
	end

	Humanoid.WalkSpeed = (Character:GetAttribute("Running") and Character:GetAttribute("DefaultRunSpeed"))
		or Character:GetAttribute("DefaultWalkSpeed")
		or 16
	Humanoid.JumpPower = Character:GetAttribute("DefaultJumpPower") or 50

	local forwardDot: number = Humanoid.MoveDirection:Dot(Camera.CFrame.LookVector)
	local rightDot: number = Humanoid.MoveDirection:Dot(Camera.CFrame.RightVector)

	if Humanoid.MoveDirection.Magnitude == 0 or Humanoid.WalkSpeed <= 16 then
		RunTrack:Stop(0.15)
	end

	if Humanoid.MoveDirection ~= Vector3.zero and math.abs(rightDot) < 0.85 and forwardDot >= -0.1 then
		isRunning()
	else
		Character:SetAttribute("Running", false)
		Humanoid.WalkSpeed = Character:GetAttribute("DefaultWalkSpeed") or 16
		Humanoid.JumpPower = Character:GetAttribute("DefaultJumpPower") or 50
	end
end

local heartbeatConnection: RBXScriptConnection
heartbeatConnection = RunService.RenderStepped:Connect(function(deltaTime: number)
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
		heartbeatConnection:Disconnect()
		return
	end

	Humanoid.AutoRotate = not Character:HasTag("CantRotate")
	FootstepSFX.Step(Character, Humanoid, HumRP, RunTrack.IsPlaying)

	local isMoveLocked: boolean = Humanoid:GetState() == Enum.HumanoidStateType.Climbing
		or Character:GetAttribute("Ragdolled")
		or Character:FindFirstChild("Stunned") ~= nil
		or Character:HasTag("Blocking")

	if isMoveLocked then
		if RunTrack.IsPlaying then
			RunTrack:Stop(0.15)
		end
		Character:SetAttribute("Running", false)
	elseif Humanoid.MoveDirection.Magnitude == 0 then
		if RunTrack.IsPlaying then
			RunTrack:Stop(0.15)
		end
		Character:SetAttribute("Running", false)
	end

	if
		Camera.CameraType ~= Enum.CameraType.Scriptable
		and not ClientContext.LunarAimActive
		and not ClientContext.SolarAimActive
	then
		local shakeOffset: Vector3 = CameraShakeController.GetOffset()
		local defaultOffset: Vector3 = Vector3.new(shakeOffset.X, -1.25 + shakeOffset.Y, shakeOffset.Z)
		local camOffset: Vector3 = defaultOffset

		if Character:HasTag("NoHeadFollow") then
			camOffset += Vector3.new(0, 1.25, 0)
		else
			camOffset += HumRP.CFrame:ToObjectSpace(Head.CFrame).Position
		end

		if Character:HasTag("NoHeadLerp") then
			Humanoid.CameraOffset = camOffset
		else
			local lerpedOffset: Vector3 = Humanoid.CameraOffset:Lerp(camOffset, 1 - 2.5E-5 ^ deltaTime)
			local offsetMagnitude: number = (HumRP.Position - (HumRP.Position + lerpedOffset)).Magnitude
			local offsetCFrame: CFrame = HumRP.CFrame * CFrame.new(Vector3.new(0, 1.5, 0) + lerpedOffset)

			if offsetMagnitude > 1000 or (offsetCFrame.Position - HumRP.Position).Magnitude > 1000 then
				lerpedOffset = defaultOffset
			end

			Humanoid.CameraOffset = lerpedOffset
		end
	end

	if Humanoid.Health == 0 and not IsDeadCameraActive then
		IsDeadCameraActive = true

		RunService.RenderStepped:Connect(function()
			if Camera.CameraType == Enum.CameraType.Scriptable then
				return
			end
			Camera.CFrame += Humanoid.CameraOffset
		end)
	end

	local StunnedFolder: Folder? = Character:FindFirstChild("Stunned")
	if StunnedFolder then
		Humanoid.WalkSpeed = StunnedFolder:GetAttribute("WalkSpeed") or 0
		Humanoid.JumpPower = StunnedFolder:GetAttribute("JumpPower") or 0

		if RunTrack.IsPlaying then
			RunTrack:Stop(0.15)
		end
	else
		Humanoid.WalkSpeed = (Character:GetAttribute("Running") and Character:GetAttribute("DefaultRunSpeed"))
			or Character:GetAttribute("DefaultWalkSpeed")
			or 16
		Humanoid.JumpPower = Character:GetAttribute("DefaultJumpPower") or 50

		checkWalkDirection()
	end
end)

Character:GetAttributeChangedSignal("DefaultRunSpeed"):Connect(checkWalkDirection)
Character:GetAttributeChangedSignal("DefaultWalkSpeed"):Connect(checkWalkDirection)
Character:GetAttributeChangedSignal("DefaultJumpPower"):Connect(checkWalkDirection)

Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(checkWalkDirection)

Humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
	if Humanoid.FloorMaterial == Enum.Material.Air then
		RunTrack:AdjustSpeed(0.5)
	else
		RunTrack:AdjustSpeed(1)
	end
end)

Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, Humanoid.JumpPower > 0)
end)

Character:GetAttributeChangedSignal("DefaultJumpPower"):Connect(function()
	local jumpPower: number = Character:GetAttribute("DefaultJumpPower")
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, jumpPower > 0)
end)

Humanoid.Jumping:Connect(function(active: boolean)
	if not active then
		return
	end

	if tick() - LastJumpTime > 1.25 then
		JumpFatigue = 0
	end

	LastJumpTime = tick()
	JumpFatigue += 1.5

	local DamagerLog = Character:FindFirstChild("DamagerLog")
	if DamagerLog and DamagerLog.TimeRemaining.Value > 20 then
		JumpFatigue = 0
	end

	local goalJumpPower: number = 50
	if JumpFatigue > 0 then
		goalJumpPower = math.max(goalJumpPower - JumpFatigue, 27)
	end

	Humanoid.JumpPower = goalJumpPower
end)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Camera = workspace.CurrentCamera
end)

Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
TweenService:Create(Camera, TweenInfo.new(0.5), { FieldOfView = 70 }):Play()

if ClientContext.IsMobile then
	Camera:GetPropertyChangedSignal("CameraType"):Connect(function()
		if Camera.CameraType == Enum.CameraType.Custom then
			Camera.CameraType = Enum.CameraType.Track
		end
	end)

	Camera.CameraType = Enum.CameraType.Track
else
	Camera.CameraType = Enum.CameraType.Custom
end

Camera.CameraSubject = Humanoid

Humanoid.Died:Connect(function()
	if not Head then
		return
	end
	if Character:GetAttribute("Override") then
		return
	end

	Camera.CameraSubject = Head
	Head.CanCollide = true
end)

Humanoid.StateChanged:Connect(function(oldState: Enum.HumanoidStateType, newState: Enum.HumanoidStateType)
	if
		newState == Enum.HumanoidStateType.Ragdoll
		or newState == Enum.HumanoidStateType.FallingDown
		or newState == Enum.HumanoidStateType.Swimming
		or newState == Enum.HumanoidStateType.Climbing
	then
		Humanoid:ChangeState(oldState)
	end
end)

HumRP.ChildAdded:Connect(function(child: Instance)
	if child:IsA("BodyVelocity") then
		if child.Name == "FrontDashVelocity" then
			Tasks["ClearVelocities"](HumRP, child)

			task.spawn(function()
				CameraShakeController.AddShake(2.5)
			end)

			local speed: number = 165
			local stopLoop: (() -> ())? = nil
			stopLoop = Loop.new(function()
				if speed > 26 and child.Parent then
					speed *= 0.95
					child.Velocity = HumRP.CFrame.LookVector * speed
				else
					stopLoop()
				end
			end)
		elseif child.Name == "moveme" then
			if child:GetAttribute("RemoveOthers") == true then
				Tasks["ClearVelocities"](HumRP, child)
			end

			local stopLoop: (() -> ())? = nil
			stopLoop = Loop.new(function()
				if not child:GetAttribute("BeganTick") then
					child:SetAttribute("BeganTick", tick())
				end

				local fallout: number = child:GetAttribute("Fallout") or 0.9
				local speed: number? = child:GetAttribute("Speed")
				if not speed then
					child:SetAttribute("Speed", child.Velocity.Magnitude)
					speed = child.Velocity.Magnitude
				end

				local goalSpeed: number = speed * fallout

				local minimumSpeed: number? = child:GetAttribute("Goto")
				if minimumSpeed and goalSpeed < minimumSpeed then
					goalSpeed = minimumSpeed
				end

				local minimumSpeedModifier: number? = child:GetAttribute("GotoDown")
				if minimumSpeedModifier and minimumSpeed then
					child:SetAttribute("Goto", math.clamp(child:GetAttribute("Goto") - 0.05, minimumSpeedModifier, 100))
				end

				if fallout > 1 then
					local speedLimit: number? = child:GetAttribute("Limit")
					if speedLimit and speedLimit < goalSpeed then
						goalSpeed = speedLimit
					end
				end

				local velocityDirection: Vector3 = HumRP.CFrame.LookVector * goalSpeed

				local direction: string? = child:GetAttribute("Direction")
				if direction then
					velocityDirection = direction == "Right" and HumRP.CFrame.RightVector * goalSpeed
						or -HumRP.CFrame.RightVector * goalSpeed
				end

				if child:GetAttribute("Inverted") then
					velocityDirection = -HumRP.CFrame.LookVector * goalSpeed
				end

				if child:GetAttribute("NoY") then
					velocityDirection *= Vector3.new(1, 0, 1)
				end

				child.Velocity = velocityDirection

				local sideSpeed: number? = child:GetAttribute("Side")
				if sideSpeed then
					child.Velocity += HumRP.CFrame.RightVector * sideSpeed
					child:SetAttribute("Side", sideSpeed * child:GetAttribute("SideFallout"))
				end

				local aerial: number? = child:GetAttribute("Aerial")
				local isMonster: boolean? = child:GetAttribute("Monster")

				if aerial then
					child.Velocity += Vector3.new(0, aerial, 0)

					if not isMonster then
						local aerialDecrease: number = child:GetAttribute("AerialDecrease") or 1
						local nextAerial: number = math.max(0, aerial - aerialDecrease)
						child:SetAttribute("Aerial", nextAerial)

						if nextAerial <= 0 and not child:GetAttribute("YForceImmunity") then
							child:SetAttribute("Aerial", nil)
							child.MaxForce = Vector3.new(child.MaxForce.X, 0, child.MaxForce.Z)
						end
					else
						local beganTick: number = child:GetAttribute("BeganTick")
						if tick() - beganTick >= 0.1715 then
							local aerialDecrease: number = child:GetAttribute("AerialDecrease") or 0.975
							child:SetAttribute("Aerial", aerial * aerialDecrease)
						end
					end
				end

				child:SetAttribute("Speed", goalSpeed)

				if child:GetAttribute("RagdollCheck") and HumRP.Parent:FindFirstChild("Ragdolled") and child.Parent then
					child:Destroy()
					return
				end

				local shouldDelete: boolean = false
				if direction and (Character:HasTag("Punching") or HumRP.Parent:FindFirstChild("Stunned")) then
					child.MaxForce = Vector3.zero
					shouldDelete = true
				end

				local endSpeed: number = child:GetAttribute("End") or 26
				if
					(not child:GetAttribute("EndExclusion") and speed <= endSpeed)
					or not child.Parent
					or shouldDelete
				then
					stopLoop()
					child:Destroy()
				end
			end)
		end
	elseif child:IsA("BodyAngularVelocity") then
		if child.Name ~= "BAV" and child.P == 1e999 and child.MaxTorque.Y == 1e999 then
			HandleVelocity(child, Character)
		end
	elseif child:IsA("BodyThrust") then
		if child.Force.X > 900 then
			HandleVelocity(child, Character)
		end
	elseif child:IsA("BodyGyro") then
		if child.P == 90000 and child.Name ~= "BODYGYRO" then
			HandleVelocity(child, Character)
		end
	end
end)
