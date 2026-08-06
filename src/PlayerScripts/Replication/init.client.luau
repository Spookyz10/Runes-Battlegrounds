local TouchGui

local Player = game.Players.LocalPlayer

local FunctionsHandler = require(script.Functions).new()
task.spawn(FunctionsHandler.Start, FunctionsHandler)

repeat
	task.wait()
until game:GetService("UserInputService").TouchEnabled or game:GetService("UserInputService").KeyboardEnabled

repeat
	task.wait()
until game:IsLoaded() and Player:FindFirstChild("LoadedData") and Player:HasTag("DataLoaded")

local RNS = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientContext = require(RS.Shared.Modules.ClientContext)
local TextChatService = game:GetService("TextChatService")

local Remotes = RS.Remotes
local ComRemotes = Remotes.Comunicator
local Comunicator = ComRemotes.Set
local Getter = ComRemotes.Get
local CombatRemotes = Remotes.Combat
local CombatSet = CombatRemotes.Set
local SpecialsSet = Remotes.Specials.Set

local RPModules = RS.Shared.Modules

local InfoModule = require(RS.Shared.Info)
local ClientRemoteListener = require(ReplicatedStorage.Shared.Modules.ClientRemoteListener)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local IndicatorService = require(script.Functions.Tasks.Shared.IndicatorService)
local RotationController = require(script.Functions.Tasks.Shared.RotationController)
local CutsceneController = require(script.Functions.CutsceneController)

local Animations = RS.Resources.Animations

local gameSettings = UserSettings().GameSettings
local Mouse = Player:GetMouse()

local TouchControlFrame, JumpButton, PunchButton, DashButton, BlockButton, ShiftlockButton
local ConfigFolder = Player:FindFirstChild("Configuration") or Player:WaitForChild("Configuration", 10)

local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid", 10)
local Animator = Humanoid:FindFirstChild("Animator") or Humanoid:WaitForChild("Animator", 10)
local HumRP = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart", 10)
local Camera = workspace.CurrentCamera

shared.IsMobile = UIS.TouchEnabled == true

local PlayerGui = Player.PlayerGui

local shiftlockActive = false
local shiftlockDebounce = false

RotationController:SetCharacter(Character, HumRP, Humanoid)
CutsceneController:Listen()

local function setShiftlock(enabled)
	if shiftlockDebounce then
		return
	end
	shiftlockDebounce = true
	task.delay(0.15, function()
		shiftlockDebounce = false
	end)

	shiftlockActive = enabled
	shared.customShiftlockActive = enabled

	if enabled then
		RotationController:Request("shiftlock", 1, function()
			return workspace.CurrentCamera.CFrame.LookVector
		end)
		Comunicator:FireServer("SetConfig", { CN = "Shiftlock", V = true })
	else
		RotationController:Release("shiftlock")
		if not Character:HasTag("CantRotate") then
			Humanoid.AutoRotate = true
		end
		Comunicator:FireServer("SetConfig", { CN = "Shiftlock", V = false })
	end
end

if shared.IsMobile then
	shiftlockActive = true
	shared.customShiftlockActive = true
	RotationController:Request("shiftlock", 1, function()
		return workspace.CurrentCamera.CFrame.LookVector
	end)
end

RNS.RenderStepped:Connect(function()
	if not HumRP or not HumRP.Parent then
		return
	end
	RotationController:Step()

	if
		shiftlockActive
		and not Character:HasTag("CantRotate")
		and not ClientContext.LunarAimActive
		and not ClientContext.SolarAimActive
	then
		Camera.CFrame = Camera.CFrame * CFrame.new(1.75, 0, 0)
	end
end)

Player:GetPropertyChangedSignal("Character"):Connect(function()
	if not Player or not Player.Parent then
		return
	end

	Character = Player.Character

	if not Character or not Character.Parent then
		Player.CharacterAdded:Wait()
	end

	Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid", 10)
	Animator = Humanoid:FindFirstChild("Animator") or Humanoid:WaitForChild("Animator", 10)
	HumRP = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart", 10)

	RotationController:SetCharacter(Character, HumRP, Humanoid)

	if shared.IsMobile then
		shiftlockActive = true
		shared.customShiftlockActive = true
		RotationController:Request("shiftlock", 1, function()
			return workspace.CurrentCamera.CFrame.LookVector
		end)
	end
end)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Camera = workspace.CurrentCamera
end)

local sortedMovesetIcons = nil
local selectedFrame = nil

local LastSideDash = 0
local LastBackDash = 0

local GreenSquareId, RedSquareId, notBoolId = 12343172777, 12343172715, 14795471064

local LiveOParams = OverlapParams.new()
LiveOParams.FilterType = Enum.RaycastFilterType.Include
LiveOParams.FilterDescendantsInstances = { workspace.Live }

local MapRParams = RaycastParams.new()
MapRParams.FilterType = Enum.RaycastFilterType.Include
MapRParams.FilterDescendantsInstances = {
	workspace.Map.Arena,
	workspace.Map.Miscellaneous,
	workspace.Map.Borders,
}
MapRParams.RespectCanCollide = true

local JointMotor6D = {
	["RootJoint"] = {
		C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(180), 0),
		C1 = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(180), 0),
		CurrentAngle = 0,
	},
	["Left Hip"] = {
		C0 = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0),
		C1 = CFrame.new(-0.5, 1, 0) * CFrame.Angles(0, math.rad(-90), 0),
		CurrentAngle = 0,
	},
	["Left Shoulder"] = {
		C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0),
		C1 = CFrame.new(0.5, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0),
		CurrentAngle = 0,
	},
	["Neck"] = {
		C0 = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(90), math.rad(180), 0),
		C1 = CFrame.new(0, -0.5, 0) * CFrame.Angles(math.rad(90), math.rad(180), 0),
		CurrentAngle = 0,
	},
	["Right Hip"] = {
		C0 = CFrame.new(1, -1, 0) * CFrame.Angles(0, math.rad(90), 0),
		C1 = CFrame.new(0.5, 1, 0) * CFrame.Angles(0, math.rad(90), 0),
		CurrentAngle = 0,
	},
	["Right Shoulder"] = {
		C0 = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0),
		C1 = CFrame.new(-0.5, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0),
		CurrentAngle = 0,
	},
}

local function HasProperty(Part, Property)
	local ok = pcall(function()
		local _ = Part[Property]
	end)
	return ok
end

local function getBoolConfigLabel(ConfigName)
	local ConfigObj = ConfigFolder:FindFirstChild(ConfigName)
	if ConfigObj then
		return ConfigObj.Value == true and GreenSquareId or RedSquareId
	end
	return notBoolId
end

local function Hitbox(Params)
	local touchedCharacters = {}
	local closestCharacter = nil

	local HitboxCFrame = Params.Instance.CFrame * Params.Offset
	local touchingParts = workspace:GetPartBoundsInBox(HitboxCFrame, Params.Size, LiveOParams)

	for _, Part in touchingParts do
		if Part and Part.Parent then
			local EnemyCharacter = Part.Parent
			local EnemyPlayer = game.Players:GetPlayerFromCharacter(EnemyCharacter)
			if EnemyPlayer and not EnemyPlayer:FindFirstChild("LoadedData") then
				continue
			end

			local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
			if
				EnemyHumanoid
				and not table.find(touchedCharacters, EnemyCharacter)
				and not table.find(Params.Ignore, EnemyCharacter)
			then
				table.insert(touchedCharacters, EnemyCharacter)
				if closestCharacter ~= nil then
					if
						(EnemyCharacter.HumanoidRootPart.Position - HitboxCFrame.Position).Magnitude
						< (closestCharacter.HumanoidRootPart.Position - HitboxCFrame.Position).Magnitude
					then
						closestCharacter = EnemyCharacter
					end
				else
					closestCharacter = EnemyCharacter
				end
			end
		end
	end

	if #touchedCharacters > 0 and closestCharacter ~= nil then
		local FirstIndex = touchedCharacters[1]
		if FirstIndex ~= closestCharacter then
			local tempTable = table.clone(touchedCharacters)
			touchedCharacters[1] = closestCharacter
			for i = 2, #touchedCharacters do
				touchedCharacters[i] = tempTable[i - 1]
			end
		end
		return touchedCharacters
	else
		return nil
	end
end

local function raycast(origin, direction)
	return workspace:Raycast(origin, direction, MapRParams)
end

local function checkCharacterAvailability()
	return Character ~= nil
		and Character.Parent ~= nil
		and HumRP ~= nil
		and HumRP.Parent ~= nil
		and Humanoid ~= nil
		and Humanoid.Parent ~= nil
		and Humanoid.Health > 0
		and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead
end

local function Punch()
	if checkCharacterAvailability() == true and not shared.buildenabled then
		CombatSet:FireServer("PunchStart")
	end
end

local function DeactivateRagdoll()
	if Humanoid.Health > 0 then
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		Humanoid:ChangeState(Enum.HumanoidStateType.Running)
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
		Camera.CameraSubject = Humanoid
	end

	for _, v in pairs(Character:GetDescendants()) do
		if v:IsA("Motor6D") then
			if JointMotor6D[v.Name] then
				v.C0 = JointMotor6D[v.Name].C0
				v.C1 = JointMotor6D[v.Name].C1
				if JointMotor6D[v.Name]["CurrentAngle"] then
					v.CurrentAngle = JointMotor6D[v.Name]["CurrentAngle"]
				end
			end
		end
	end
end

local function DashCheck()
	if not checkCharacterAvailability() or shared.buildenabled then
		return
	end

	local Rotation
	if UIS.KeyboardEnabled and not UIS.TouchEnabled then
		if UIS:IsKeyDown(Enum.KeyCode.W) then
			Rotation = 0
		elseif UIS:IsKeyDown(Enum.KeyCode.S) then
			Rotation = 180
		elseif UIS:IsKeyDown(Enum.KeyCode.D) then
			Rotation = -90
		elseif UIS:IsKeyDown(Enum.KeyCode.A) then
			Rotation = 90
		end
	else
		Rotation = HumRP.CFrame
		local Reference = HumRP.CFrame + Humanoid.MoveDirection * 15
		local ReferencePosition = Reference.Position
		local LookVector = (
			Vector3.new(ReferencePosition.X, Rotation.Position.Y, ReferencePosition.Z) - Rotation.Position
		).Unit
		local LookVectorRotation = math.deg(math.acos(Rotation.LookVector:Dot(LookVector)))

		Rotation = 0
		if LookVectorRotation > -45 and LookVectorRotation < 45 then
			Rotation = 0
		elseif LookVectorRotation > 135 and LookVectorRotation < 215 then
			Rotation = 180
		elseif LookVectorRotation >= 45 and LookVectorRotation <= 135 then
			ReferencePosition = HumRP.CFrame * CFrame.new(15, 0, 0)
			LookVector = HumRP.CFrame * CFrame.new(-15, 0, 0)
			Rotation = (Reference.Position - ReferencePosition.Position).Magnitude
						> (Reference.Position - LookVector.Position).Magnitude
					and 90
				or -90
		end
	end

	local currDirection
	if Rotation == 0 then
		currDirection = "Front"
	elseif Rotation == 180 then
		currDirection = "Back"
	elseif Rotation == 90 then
		currDirection = "Left"
	elseif Rotation == -90 then
		currDirection = "Right"
	else
		currDirection = "Front"
	end

	if currDirection == "Left" or currDirection == "Right" then
		if tick() - LastSideDash < 2 then
			return
		end

		if not Character:HasTag("Ragdolled") and not Character:HasTag("Knockbacked") then
			if (Character:HasTag("SideDashCD")) or Character:HasTag("CantSideDash") or Character:HasTag("Stunned") then
				return
			end
		else
			if Character:HasTag("CantRagdollCancel") or Character:GetAttribute("RagdollCancel") ~= true then
				return
			end
		end

		LastSideDash = tick()
		shared.clearVelocities(HumRP)
		Character:SetAttribute("SideDashing", true)

		if Humanoid:GetState() == Enum.HumanoidStateType.Physics then
			Humanoid:ChangeState(Enum.HumanoidStateType.Running)
		end
		if Humanoid.PlatformStand then
			Humanoid.PlatformStand = false
		end

		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		task.delay(0.6, function()
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		end)

		local dashAnim
		if currDirection == "Left" then
			dashAnim = Animations.Dashes.DashLeft
		else
			dashAnim = Animations.Dashes.DashRight
		end

		local AnimationTrack = Animator:LoadAnimation(dashAnim)

		local Speed = 200
		local Mult = currDirection == "Right" and 1 or -1

		gameSettings.RotationType = Enum.RotationType.CameraRelative

		local stopLoop = nil

		local DashVelocity = Instance.new("BodyVelocity")
		DashVelocity.MaxForce = Character:HasTag("Slowed") and Vector3.new(10000, 0, 10000)
			or Vector3.new(50000, 0, 50000)
		DashVelocity.Parent = HumRP

		AnimationTrack.Stopped:Once(function()
			if stopLoop then
				stopLoop()
			end
			if DashVelocity and DashVelocity.Parent then
				DashVelocity:Destroy()
			end

			HumRP.AssemblyLinearVelocity = Vector3.new(0, HumRP.AssemblyLinearVelocity.Y, 0)
			gameSettings.RotationType = Enum.RotationType.MovementRelative
		end)

		task.delay(0.325, function()
			Character:SetAttribute("SideDashing", false)
		end)

		AnimationTrack:Play()

		stopLoop = shared.loop(function()
			if Speed > 5 and DashVelocity.Parent then
				Speed *= 0.91
				HumRP.CFrame = CFrame.lookAlong(HumRP.Position, Camera.CFrame.LookVector * Vector3.new(1, 0, 1))
				DashVelocity.Velocity = (HumRP.CFrame.RightVector * Mult) * Speed
			else
				stopLoop()
				if DashVelocity and DashVelocity.Parent then
					DashVelocity:Destroy()
				end

				HumRP.AssemblyLinearVelocity = Vector3.new(0, HumRP.AssemblyLinearVelocity.Y, 0)
				gameSettings.RotationType = Enum.RotationType.MovementRelative
			end
		end)
	elseif currDirection == "Back" then
		if tick() - LastBackDash < 5 then
			return
		end

		if not Character:HasTag("Ragdolled") and not Character:HasTag("Knockbacked") then
			if (Character:HasTag("DashCD")) or Character:HasTag("CantDash") or Character:HasTag("Stunned") then
				return
			end
		else
			if Character:HasTag("CantRagdollCancel") or Character:GetAttribute("RagdollCancel") ~= true then
				return
			end
		end

		LastBackDash = tick()
		shared.clearVelocities(HumRP)
		Character:SetAttribute("Dashing", true)

		if Humanoid:GetState() == Enum.HumanoidStateType.Physics then
			Humanoid:ChangeState(Enum.HumanoidStateType.Running)
		end
		if Humanoid.PlatformStand then
			Humanoid.PlatformStand = false
		end

		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		Character:AddTag("CantSideDash")
		task.delay(1.051, function()
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
			Character:RemoveTag("CantSideDash")
		end)

		local dashAnim = Animations.Dashes.DashBack
		local AnimationTrack = Animator:LoadAnimation(dashAnim)

		gameSettings.RotationType = Enum.RotationType.CameraRelative

		local Speed = 260

		local DashVelocity = Instance.new("BodyVelocity")
		DashVelocity.MaxForce = Character:HasTag("Slowed") and Vector3.new(10000, 0, 10000)
			or Vector3.new(50000, 0, 50000)
		DashVelocity.Parent = HumRP

		AnimationTrack.Stopped:Once(function()
			Character:SetAttribute("Dashing", false)
			if DashVelocity and DashVelocity.Parent then
				DashVelocity:Destroy()
			end
			gameSettings.RotationType = Enum.RotationType.MovementRelative
		end)

		AnimationTrack:Play()

		local stopLoop = nil
		stopLoop = shared.loop(function()
			if DashVelocity and DashVelocity.Parent then
				Speed *= 0.91
				if Speed <= 10 then
					DashVelocity:Destroy()
				end
				HumRP.CFrame = CFrame.lookAlong(HumRP.Position, Camera.CFrame.LookVector * Vector3.new(1, 0, 1))
				DashVelocity.Velocity = -HumRP.CFrame.LookVector * Speed
			else
				stopLoop()
				gameSettings.RotationType = Enum.RotationType.MovementRelative
			end
		end)
	end

	Comunicator:FireServer("Keypress", { Key = Enum.KeyCode.Q, Direction = currDirection, ClientCFrame = HumRP.CFrame })
end

local function ComunicationFunction(func, params)
	if func == "TriggerPartsCollide" then
		for _, Part in params.model:GetDescendants() do
			if HasProperty(Part, "CanCollide") then
				Part.CanCollide = params.state
			end
		end
	elseif func == "DetectAir" then
		local Bridge = Player:FindFirstChild(params.Bridge)
			or Player:WaitForChild(params.Bridge, Player:GetNetworkPing() + 1)
		if not Bridge then
			return
		end
		shared.detectAir(params)
		Bridge:FireServer()
	elseif func == "Ragdoll" then
		local State = params.State
		if State then
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
			Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			for _, v in pairs(Character:GetDescendants()) do
				if v:IsA("Motor6D") and JointMotor6D[v.Name] then
					v.C0 = JointMotor6D[v.Name].C0
					v.C1 = JointMotor6D[v.Name].C1
					if JointMotor6D[v.Name]["CurrentAngle"] then
						v.CurrentAngle = JointMotor6D[v.Name]["CurrentAngle"]
					end
				end
			end
			Camera.CameraSubject = Character:WaitForChild("Head")
		else
			DeactivateRagdoll()
		end
	elseif func == "MobileButtons" then
		local AwakeningBar = PlayerGui:WaitForChild("AwakeningBar")

		if UIS.TouchEnabled == true and not UIS.KeyboardEnabled then
			if not Player:GetAttribute("ButtonsPositions") then
				local StartTime = tick()
				repeat
					task.wait()
				until tick() - StartTime > 6 or Player:GetAttribute("ButtonsPositions")
			end

			TouchGui = PlayerGui:FindFirstChild("TouchGui") or PlayerGui:WaitForChild("TouchGui", 10)
			local Buttons = {}

			TouchControlFrame = TouchGui:FindFirstChild("TouchControlFrame")
				or TouchGui:WaitForChild("TouchControlFrame", 5)
			JumpButton = TouchControlFrame:FindFirstChild("JumpButton")
				or TouchControlFrame:WaitForChild("JumpButton", 5)

			local DefaultSize = JumpButton.Size.X.Offset - 10
			local MobileGUI = game.ReplicatedFirst.Mobile:Clone()

			Buttons.Punch = MobileGUI.MobileFrame.PunchButton
			Buttons.Dash = MobileGUI.MobileFrame.DashButton
			Buttons.Block = MobileGUI.MobileFrame.BlockButton
			Buttons.Shiftlock = MobileGUI.MobileFrame.ShiftlockButton

			PunchButton = Buttons.Punch
			DashButton = Buttons.Dash
			BlockButton = Buttons.Block
			ShiftlockButton = Buttons.Shiftlock

			DashButton.Position = UDim2.new(
				JumpButton.Position.X.Scale + params.Dash.ScaleX,
				JumpButton.Position.X.Offset + JumpButton.Size.X.Offset / 2 + params.Dash.OffsetX,
				JumpButton.Position.Y.Scale + params.Dash.ScaleY,
				JumpButton.Position.Y.Offset - (JumpButton.Size.Y.Offset / 2 + 7) + params.Dash.OffsetY
			)
			DashButton.Size =
				UDim2.new(0, DefaultSize * params.Dash.SizeMultiplier, 0, DefaultSize * params.Dash.SizeMultiplier)
			DashButton:SetAttribute("SizeMultiplier", params.Dash.SizeMultiplier)
			DashButton:GetAttributeChangedSignal("SizeMultiplier"):Connect(function()
				DashButton.Size = UDim2.new(
					0,
					DefaultSize * DashButton:GetAttribute("SizeMultiplier"),
					0,
					DefaultSize * DashButton:GetAttribute("SizeMultiplier")
				)
			end)

			PunchButton.Position = UDim2.new(
				JumpButton.Position.X.Scale + params.M1.ScaleX,
				JumpButton.Position.X.Offset + JumpButton.Size.X.Offset / 2 + params.M1.OffsetX,
				JumpButton.Position.Y.Scale + params.M1.ScaleY,
				JumpButton.Position.Y.Offset - 2.5 * (JumpButton.Size.Y.Offset / 2 + 7) + params.M1.OffsetY
			)
			PunchButton.Size =
				UDim2.new(0, DefaultSize * params.M1.SizeMultiplier, 0, DefaultSize * params.M1.SizeMultiplier)
			PunchButton:SetAttribute("SizeMultiplier", params.M1.SizeMultiplier)
			PunchButton:GetAttributeChangedSignal("SizeMultiplier"):Connect(function()
				PunchButton.Size = UDim2.new(
					0,
					DefaultSize * PunchButton:GetAttribute("SizeMultiplier"),
					0,
					DefaultSize * PunchButton:GetAttribute("SizeMultiplier")
				)
			end)

			BlockButton.Position = UDim2.new(
				JumpButton.Position.X.Scale + params.Block.ScaleX,
				JumpButton.Position.X.Offset + JumpButton.Size.X.Offset / 2 + params.Block.OffsetX,
				JumpButton.Position.Y.Scale + params.Block.ScaleY,
				JumpButton.Position.Y.Offset - 4 * (JumpButton.Size.Y.Offset / 2 + 7) + params.Block.OffsetY
			)
			BlockButton.Size =
				UDim2.new(0, DefaultSize * params.Block.SizeMultiplier, 0, DefaultSize * params.Block.SizeMultiplier)
			BlockButton:SetAttribute("SizeMultiplier", params.Block.SizeMultiplier)
			BlockButton:GetAttributeChangedSignal("SizeMultiplier"):Connect(function()
				BlockButton.Size = UDim2.new(
					0,
					DefaultSize * BlockButton:GetAttribute("SizeMultiplier"),
					0,
					DefaultSize * BlockButton:GetAttribute("SizeMultiplier")
				)
			end)

			ShiftlockButton.Position = UDim2.new(
				JumpButton.Position.X.Scale + params.Shiftlock.ScaleX,
				JumpButton.Position.X.Offset - JumpButton.Size.X.Offset / 2 + params.Shiftlock.OffsetX,
				JumpButton.Position.Y.Scale + params.Shiftlock.ScaleY,
				JumpButton.Position.Y.Offset - 3.25 * (JumpButton.Size.Y.Offset / 2 + 7) + params.Shiftlock.OffsetY
			)
			ShiftlockButton.Size = UDim2.new(
				0,
				DefaultSize * params.Shiftlock.SizeMultiplier,
				0,
				DefaultSize * params.Shiftlock.SizeMultiplier
			)
			ShiftlockButton:SetAttribute("SizeMultiplier", params.Shiftlock.SizeMultiplier)
			ShiftlockButton:GetAttributeChangedSignal("SizeMultiplier"):Connect(function()
				ShiftlockButton.Size = UDim2.new(
					0,
					DefaultSize * ShiftlockButton:GetAttribute("SizeMultiplier"),
					0,
					DefaultSize * ShiftlockButton:GetAttribute("SizeMultiplier")
				)
			end)

			local PreviousDashConnection
			DashButton.InputBegan:Connect(function(Input)
				if
					Input.UserInputState == Enum.UserInputState.Begin
					and (
						Input.UserInputType == Enum.UserInputType.Touch
						or Input.UserInputType == Enum.UserInputType.MouseButton1
					)
				then
					if Character:FindFirstChild("ChangingButtons") then
						selectedFrame = DashButton
						return
					else
						DashCheck()
					end

					if PreviousDashConnection ~= nil then
						PreviousDashConnection:Disconnect()
					end
					PreviousDashConnection = Input:GetPropertyChangedSignal("UserInputState"):Connect(function()
						if Input.UserInputState == Enum.UserInputState.End then
							if selectedFrame == DashButton then
								selectedFrame = nil
							end
							PreviousDashConnection:Disconnect()
							PreviousDashConnection = nil
							DashButton.Image = "rbxassetid://12252434969"
						end
					end)
					DashButton.Image = "rbxassetid://12253813495"
				end
			end)

			local LastPunchConnection
			PunchButton.InputBegan:Connect(function(Input)
				if
					Input.UserInputState == Enum.UserInputState.Begin
					and (
						Input.UserInputType == Enum.UserInputType.Touch
						or Input.UserInputType == Enum.UserInputType.MouseButton1
					)
				then
					if Character:FindFirstChild("ChangingButtons") then
						selectedFrame = PunchButton
						return
					else
						local DoPunch = coroutine.wrap(function()
							RNS.Heartbeat:Wait()
							Punch()
						end)
						DoPunch()
					end

					if LastPunchConnection ~= nil then
						LastPunchConnection:Disconnect()
					end
					LastPunchConnection = Input:GetPropertyChangedSignal("UserInputState"):Connect(function()
						if Input.UserInputState == Enum.UserInputState.End then
							CombatSet:FireServer("PunchEnd")
							if selectedFrame == PunchButton then
								selectedFrame = nil
							end
							LastPunchConnection:Disconnect()
							LastPunchConnection = nil
							PunchButton.Image = "rbxassetid://12252402662"
						end
					end)
					PunchButton.Image = "rbxassetid://12253807149"
				end
			end)

			local LastBlockConnection
			BlockButton.InputBegan:Connect(function(Input)
				if
					Input.UserInputState == Enum.UserInputState.Begin
					and (
						Input.UserInputType == Enum.UserInputType.Touch
						or Input.UserInputType == Enum.UserInputType.MouseButton1
					)
				then
					if Character:FindFirstChild("ChangingButtons") then
						selectedFrame = BlockButton
						return
					else
						local DoBlock = coroutine.wrap(function()
							RNS.Heartbeat:Wait()
							if not Character:FindFirstChild("Stunned") then
								CombatSet:FireServer("Block", { Stage = true })
								if Character:FindFirstChild("Emoting") then
									Comunicator:FireServer("StopEmote")
								end
							end
						end)
						DoBlock()
					end

					if LastBlockConnection ~= nil then
						LastBlockConnection:Disconnect()
					end
					LastBlockConnection = Input:GetPropertyChangedSignal("UserInputState"):Connect(function()
						if Input.UserInputState == Enum.UserInputState.End then
							CombatSet:FireServer("Block", { Stage = false })
							if selectedFrame == BlockButton then
								selectedFrame = nil
							end
							LastBlockConnection:Disconnect()
							LastBlockConnection = nil
							BlockButton.Image = "rbxassetid://12252418253"
						end
					end)
					BlockButton.Image = "rbxassetid://12253793254"
				end
			end)

			local LastShiftlockConnection
			ShiftlockButton.InputBegan:Connect(function(Input)
				if
					Input.UserInputState == Enum.UserInputState.Begin
					and (
						Input.UserInputType == Enum.UserInputType.Touch
						or Input.UserInputType == Enum.UserInputType.MouseButton1
					)
				then
					if Character:FindFirstChild("ChangingButtons") then
						selectedFrame = ShiftlockButton
						return
					else
						setShiftlock(not shiftlockActive)
						ShiftlockButton.Image = shiftlockActive and "rbxassetid://79664771265271"
							or "rbxassetid://79605996519245"
					end

					if LastShiftlockConnection ~= nil then
						LastShiftlockConnection:Disconnect()
					end
					LastShiftlockConnection = Input:GetPropertyChangedSignal("UserInputState"):Connect(function()
						if Input.UserInputState == Enum.UserInputState.End then
							if selectedFrame == ShiftlockButton then
								selectedFrame = nil
							end
							LastShiftlockConnection:Disconnect()
							LastShiftlockConnection = nil
						end
					end)
				end
			end)

			MobileGUI.Parent = PlayerGui

			game:GetService("GuiService").MenuOpened:Connect(function()
				if Character:GetAttribute("doPunch") then
					CombatSet:FireServer("PunchEnd")
				end
				if Character:GetAttribute("doBlock") then
					CombatSet:FireServer("Block", { Stage = false })
				end
				selectedFrame = nil
			end)

			RNS.RenderStepped:Connect(function()
				if Character:FindFirstChild("ChangingButtons") then
					if MobileGUI then
						for _, Button in next, MobileGUI.MobileFrame:GetChildren() do
							if Button:IsA("ImageButton") then
								Button.Draggable = true
								Button.ImageColor3 = Color3.fromRGB(35, 178, 255)
							end
						end
					end
				else
					if MobileGUI then
						for _, Button in next, MobileGUI.MobileFrame:GetChildren() do
							if Button:IsA("ImageButton") then
								Button.Draggable = false
								Button.ImageColor3 = Color3.fromRGB(255, 255, 255)
							end
						end
					end
				end
			end)
		end
	elseif func == "SetupHitboxBridge" then
		local Bridge = Player:WaitForChild(params.BridgeId)
		Bridge.OnClientEvent:Connect(function(InvokeType, HitboxParameters)
			if InvokeType == "Once" then
				Bridge:FireServer(Hitbox(HitboxParameters))
			elseif InvokeType == "Constant" then
				local HitboxConnection
				HitboxConnection = RNS.Heartbeat:Connect(function()
					local TouchedEnemies = Hitbox(HitboxParameters)
					if TouchedEnemies ~= nil and #TouchedEnemies > 0 then
						Bridge:FireServer(TouchedEnemies)
					end
				end)

				local StopConnection, DestroyConnection
				StopConnection = Bridge.ChildAdded:Connect(function(Child)
					if Child.Name == "StopConstant" then
						HitboxConnection:Disconnect()
						StopConnection:Disconnect()
						DestroyConnection:Disconnect()
					end
				end)
				DestroyConnection = Bridge.Destroying:Once(function()
					HitboxConnection:Disconnect()
					StopConnection:Disconnect()
					DestroyConnection:Disconnect()
				end)
			end
		end)
	elseif func == "HideAwkbar" then
		shared.triggerAwkbar(false)
	elseif func == "ShowAwkbar" then
		shared.triggerAwkbar(true)
	elseif func == "HideHotbar" then
		shared.triggerHotbar(false)
	elseif func == "ShowHotbar" then
		shared.triggerHotbar(true)
	elseif func == "ModifyHotbar" then
		for _, Button in PlayerGui.Hotbar.Hotbar:GetChildren() do
			if not Button:IsA("Frame") then
				continue
			end
			if Button.Base.SkillName.Text == params.ToolName then
				local property = Button.Base[params.Property]
				if params.Visible ~= nil then
					property.Visible = params.Visible
					if property:FindFirstChild("Description") then
						property.Description.Visible = params.Visible
					end
				else
					local defaultPropertyValue = property.Text
					local defaultPropertyVisibility = property.Visible
					Button.Base[params.Property].Text = params.Value
					property.Visible = true
					if property:FindFirstChild("Description") then
						Button.Base[params.Property].Description.Text = params.Value
						property.Description.Visible = true
					end
					if params.Time then
						task.delay(params.Time, function()
							property.Text = defaultPropertyValue
							property.Visible = defaultPropertyVisibility
							if property:FindFirstChild("Description") then
								property.Description.Text = defaultPropertyValue
								property.Description.Visible = defaultPropertyVisibility
							end
						end)
					end
				end
			end
		end
	elseif func == "HideTopbar" then
		shared.triggerTopbar(false)
	elseif func == "ShowTopbar" then
		shared.triggerTopbar(true)
	elseif func == "GiveAdminChar" then
		for _, Icon in sortedMovesetIcons.AdminOnly do
			Icon:setEnabled(true)
		end
	elseif func == "RemoveAdminChar" then
		for _, Icon in sortedMovesetIcons.AdminOnly do
			Icon:setEnabled(false)
		end
	elseif func == "SendNotification" then
		if not params.Title then
			params.Title = "NOTIFICATION"
		end
		StarterGui:SetCore("SendNotification", params)
	elseif func == "Mute" then
		local HideCount = 0
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
		PlayerGui.Chat.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
			if PlayerGui.Chat.Frame.Visible == true then
				if HideCount == 3 then
					Comunicator:FireServer("Kick", { Msg = "You were kicked for trying to unmute yourself." })
					return
				end
				if Player:HasTag("Muted") == true then
					HideCount += 1
					StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
					PlayerGui.Chat.Frame.Visible = false
				end
			end
		end)
	elseif func == "Unmute" then
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	elseif func == "AddEmoteSlots" then
		PlayerGui.Emotes.ImageLabel.Gamepass.Visible = false
		PlayerGui.Emotes.ImageLabel.GamepassTwo.Visible = true
		for _, v in PlayerGui.Emotes.ImageLabel.Emotes:GetChildren() do
			if v:HasTag("ExtraSlot") then
				v.Visible = true
			end
		end
	elseif func == "AddSecondPage" then
		PlayerGui.Emotes.ImageLabel.Switch.Visible = true
	elseif func == "CanSpinEmote" then
		PlayerGui.Emotes.ImageLabel.Spin.Text =
			'<font color="rgb(255, 255, 255)">CLAIM NEW EMOTE</font>\n<font size="16">PRESS ME!</font>'
	elseif func == "ChangeKillForEmote" then
		PlayerGui.Emotes.ImageLabel.Spin.Text = 'NEW EMOTE: <font color="rgb(255, 85, 85)">'
			.. params
			.. ' KILLS</font>\n<font size="16">HOLD EMOTE DOWN TO CHANGE</font>'
	end
end

Comunicator.OnClientEvent:Connect(ComunicationFunction)
ComRemotes.Local.Event:Connect(ComunicationFunction)

task.spawn(function()
	if shared.IsMobile and (not DashButton or not PunchButton or not BlockButton or not ShiftlockButton) then
		repeat
			task.wait()
		until DashButton and PunchButton and BlockButton and ShiftlockButton
	end

	local startTick = tick()
	if game:GetService("GuiService").TopbarInset.Max.Y <= 0 then
		while true do
			task.wait()
			if not (tick() - startTick <= 5 and game:GetService("GuiService").TopbarInset.Max.Y <= 0) then
				break
			end
		end
	end

	local IconModule = RPModules["NewIcon"]
	local IconController = require(IconModule.IconController)

	shared.triggerTopbar = function(bool)
		IconController.setTopbarEnabled(bool)
	end

	local Icon = require(IconModule)
	task.wait()

	-- local CharactersIcon = Icon.new(true)
	-- CharactersIcon:set("dropdownSquareCorners", true)
	-- CharactersIcon:setName("Characters")
	-- CharactersIcon:setLabel("Characters")
	-- CharactersIcon:set("dropdownMaxIconsBeforeScroll", UIS.TouchEnabled and 6 or 10)
	-- CharactersIcon:autoDeselect(true)
	-- CharactersIcon:bindEvent("selected", function()
	-- 	if shared.SettingsIcon then
	-- 		shared.SettingsIcon:deselect()
	-- 	end
	-- 	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	-- 	CharactersIcon:setLabel("")
	-- end)
	-- CharactersIcon:bindEvent("deselected", function()
	-- 	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	-- end)

	-- local MovesetIcons = {}
	-- sortedMovesetIcons = { Public = {}, Quest = {}, EarlyAccess = {}, AdminOnly = {} }

	-- for Name, Info in InfoModule.Movesets do
	-- 	local Order = Info.Order
	-- 	local imageId = Info.Icon

	-- 	local isQuest = Info.isQuest
	-- 	local isEA = Info.EarlyAccess

	-- 	local MovesetIcon = Icon.new()
	-- 	task.spawn(function()
	-- 		MovesetIcon:set("forcedIconSizeX", 32)
	-- 		MovesetIcon:set("forcedIconSizeY", 32)
	-- 		MovesetIcon:set("iconSize", UDim2.new(0, 32, 0, 32))
	-- 		MovesetIcon:set("iconImageYScale", 0.75)
	-- 		MovesetIcon:setLabel(Name)
	-- 		MovesetIcon:setName(Name)
	-- 		MovesetIcon:setImage(imageId)
	-- 		MovesetIcon:setOrder(Order)
	-- 		MovesetIcon:autoDeselect(true)
	-- 		MovesetIcon:bindEvent("selected", function(icon)
	-- 			MovesetIcon:deselect()
	-- 			Comunicator:FireServer("SetMoveset", Name)
	-- 		end)

	-- 		if isQuest == true then
	-- 			sortedMovesetIcons.Quest[Name] = MovesetIcon
	-- 			MovesetIcon:set("iconTextColor", Color3.fromRGB(255, 216, 19))
	-- 		elseif isEA == true then
	-- 			sortedMovesetIcons.EarlyAccess[Name] = MovesetIcon
	-- 			MovesetIcon:set("iconTextColor", Color3.fromRGB(255, 255, 0))
	-- 		else
	-- 			sortedMovesetIcons.Public[Name] = MovesetIcon
	-- 		end
	-- 	end)
	-- 	MovesetIcons[Name] = MovesetIcon
	-- end

	-- CharactersIcon:setDropdown(MovesetIcons)
	-- shared.CharactersIcon = CharactersIcon

	-- task.wait(0.15)

	-- local ConfigIcon = Icon.new(true)
	-- ConfigIcon:setName("Config")
	-- ConfigIcon:setImage(3687980595)
	-- ConfigIcon:set("dropdownSquareCorners", true)
	-- ConfigIcon:set("dropdownMaxIconsBeforeScroll", 8)
	-- ConfigIcon:bindEvent("selected", function()
	-- 	if shared.CharactersIcon then
	-- 		shared.CharactersIcon:deselect()
	-- 	end
	-- 	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	-- end)
	-- ConfigIcon:bindEvent("deselected", function()
	-- 	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	-- end)

	-- local configDropdown = {
	-- 	Icon.new()
	-- 		:setName("Move_Buttons")
	-- 		:setLabel("Edit Button Positions")
	-- 		:setImage(notBoolId)
	-- 		:autoDeselect(true)
	-- 		:setEnabled(shared.IsMobile)
	-- 		:bindEvent("selected", function(icon)
	-- 			icon:deselect()

	-- 			local ChangingButtons = Character:FindFirstChild("ChangingButtons")
	-- 			if ChangingButtons then
	-- 				icon:setLabel("Edit Button Positions")
	-- 				ChangingButtons:Destroy()
	-- 				Comunicator:FireServer("SaveButtonsPos", {
	-- 					Dash = {
	-- 						ScaleX = JumpButton.Position.X.Scale - DashButton.Position.X.Scale,
	-- 						OffsetX = DashButton.Position.X.Offset
	-- 							- (JumpButton.Position.X.Offset + JumpButton.Size.X.Offset / 2),
	-- 						ScaleY = JumpButton.Position.Y.Scale - DashButton.Position.Y.Scale,
	-- 						OffsetY = DashButton.Position.Y.Offset
	-- 							- (JumpButton.Position.Y.Offset - (JumpButton.Size.Y.Offset / 2 + 7)),
	-- 					},
	-- 					M1 = {
	-- 						ScaleX = JumpButton.Position.X.Scale - PunchButton.Position.X.Scale,
	-- 						OffsetX = PunchButton.Position.X.Offset
	-- 							- (JumpButton.Position.X.Offset + JumpButton.Size.X.Offset / 2),
	-- 						ScaleY = JumpButton.Position.Y.Scale - PunchButton.Position.Y.Scale,
	-- 						OffsetY = PunchButton.Position.Y.Offset
	-- 							- (JumpButton.Position.Y.Offset - 2.5 * (JumpButton.Size.Y.Offset / 2 + 7)),
	-- 					},
	-- 					Block = {
	-- 						ScaleX = JumpButton.Position.X.Scale - BlockButton.Position.X.Scale,
	-- 						OffsetX = BlockButton.Position.X.Offset
	-- 							- (JumpButton.Position.X.Offset + JumpButton.Size.X.Offset / 2),
	-- 						ScaleY = JumpButton.Position.Y.Scale - BlockButton.Position.Y.Scale,
	-- 						OffsetY = BlockButton.Position.Y.Offset
	-- 							- (JumpButton.Position.Y.Offset - 4 * (JumpButton.Size.Y.Offset / 2 + 7)),
	-- 					},
	-- 					Shiftlock = {
	-- 						ScaleX = JumpButton.Position.X.Scale - ShiftlockButton.Position.X.Scale,
	-- 						OffsetX = ShiftlockButton.Position.X.Offset
	-- 							- (JumpButton.Position.X.Offset - JumpButton.Size.X.Offset / 2),
	-- 						ScaleY = JumpButton.Position.Y.Scale - ShiftlockButton.Position.Y.Scale,
	-- 						OffsetY = ShiftlockButton.Position.Y.Offset
	-- 							- (JumpButton.Position.Y.Offset - 3.25 * (JumpButton.Size.Y.Offset / 2 + 7)),
	-- 					},
	-- 				})
	-- 				return
	-- 			end
	-- 			icon:setLabel("Save Edits?")
	-- 			local CB = Instance.new("BoolValue")
	-- 			CB.Name = "ChangingButtons"
	-- 			CB.Value = true
	-- 			CB.Parent = Character
	-- 		end),

	-- 	Icon.new()
	-- 		:setName("Reset_Buttons")
	-- 		:setLabel("Reset Button Positions")
	-- 		:setImage(notBoolId)
	-- 		:autoDeselect(true)
	-- 		:setEnabled(shared.IsMobile)
	-- 		:bindEvent("selected", function(icon)
	-- 			icon:deselect()

	-- 			DashButton.Position = UDim2.new(
	-- 				JumpButton.Position.X.Scale,
	-- 				JumpButton.Position.X.Offset + JumpButton.Size.X.Offset / 2,
	-- 				JumpButton.Position.Y.Scale,
	-- 				JumpButton.Position.Y.Offset - (JumpButton.Size.Y.Offset / 2 + 7)
	-- 			)
	-- 			PunchButton.Position = UDim2.new(
	-- 				JumpButton.Position.X.Scale,
	-- 				JumpButton.Position.X.Offset + JumpButton.Size.X.Offset / 2,
	-- 				JumpButton.Position.Y.Scale,
	-- 				JumpButton.Position.Y.Offset - 2.5 * (JumpButton.Size.Y.Offset / 2 + 7)
	-- 			)
	-- 			BlockButton.Position = UDim2.new(
	-- 				JumpButton.Position.X.Scale,
	-- 				JumpButton.Position.X.Offset + JumpButton.Size.X.Offset / 2,
	-- 				JumpButton.Position.Y.Scale,
	-- 				JumpButton.Position.Y.Offset - 4 * (JumpButton.Size.Y.Offset / 2 + 7)
	-- 			)
	-- 			ShiftlockButton.Position = UDim2.new(
	-- 				JumpButton.Position.X.Scale,
	-- 				JumpButton.Position.X.Offset - JumpButton.Size.X.Offset / 2,
	-- 				JumpButton.Position.Y.Scale,
	-- 				JumpButton.Position.Y.Offset - 3.25 * (JumpButton.Size.Y.Offset / 2 + 7)
	-- 			)
	-- 			Comunicator:FireServer("SaveButtonsPos", {
	-- 				Dash = {
	-- 					ScaleX = 0,
	-- 					OffsetX = 0,
	-- 					ScaleY = 0,
	-- 					OffsetY = 0,
	-- 					SizeMultiplier = DashButton:GetAttribute("SizeMultiplier"),
	-- 				},
	-- 				M1 = {
	-- 					ScaleX = 0,
	-- 					OffsetX = 0,
	-- 					ScaleY = 0,
	-- 					OffsetY = 0,
	-- 					SizeMultiplier = PunchButton:GetAttribute("SizeMultiplier"),
	-- 				},
	-- 				Block = {
	-- 					ScaleX = 0,
	-- 					OffsetX = 0,
	-- 					ScaleY = 0,
	-- 					OffsetY = 0,
	-- 					SizeMultiplier = BlockButton:GetAttribute("SizeMultiplier"),
	-- 				},
	-- 				Shiftlock = {
	-- 					ScaleX = 0,
	-- 					OffsetX = 0,
	-- 					ScaleY = 0,
	-- 					OffsetY = 0,
	-- 					SizeMultiplier = ShiftlockButton:GetAttribute("SizeMultiplier"),
	-- 				},
	-- 			})
	-- 		end),

	-- 	Icon.new()
	-- 		:setLabel("Awakening Music")
	-- 		:setImage(getBoolConfigLabel("Awakening Music"))
	-- 		:autoDeselect(true)
	-- 		:bindEvent("selected", function(icon)
	-- 			icon:deselect()
	-- 			if ConfigFolder["Awakening Music"].Value == true then
	-- 				icon:setImage(RedSquareId)
	-- 				Comunicator:FireServer("SetConfig", { CN = "Awakening Music", V = false })
	-- 			else
	-- 				icon:setImage(GreenSquareId)
	-- 				Comunicator:FireServer("SetConfig", { CN = "Awakening Music", V = true })
	-- 			end
	-- 		end),

	-- 	Icon.new()
	-- 		:setLabel("Camera Shake")
	-- 		:setName("CameraShake")
	-- 		:setImage(getBoolConfigLabel("Camera Shake"))
	-- 		:autoDeselect(true)
	-- 		:bindEvent("selected", function(icon)
	-- 			icon:deselect()
	-- 			if ConfigFolder["Camera Shake"].Value == true then
	-- 				icon:setImage(RedSquareId)
	-- 				Comunicator:FireServer("SetConfig", { CN = "Camera Shake", V = false })
	-- 			else
	-- 				icon:setImage(GreenSquareId)
	-- 				Comunicator:FireServer("SetConfig", { CN = "Camera Shake", V = true })
	-- 			end
	-- 		end),
	-- }

	-- task.spawn(function()
	-- 	ConfigIcon:set("dropdownMaxIconsBeforeScroll", 8)
	-- 	for Index, Ico in configDropdown do
	-- 		Ico:setOrder(Index - #configDropdown)
	-- 		Ico:set("forcedIconSizeX", 32)
	-- 		Ico:set("forcedIconSizeY", 32)
	-- 		Ico:set("iconSize", UDim2.new(0, 32, 0, 32))
	-- 		Ico:set("iconImageRatio", 0.6)
	-- 	end
	-- end)

	-- ConfigIcon:setDropdown(configDropdown)
	-- shared.SettingsIcon = ConfigIcon

	-- local shiftlockIcon = configDropdown[1]
	-- local moveBtnsIcon = configDropdown[2]
	-- local resetBtnsIcon = configDropdown[3]

	local function toggleNonKeyboardIcons()
		local currentValue = UIS.TouchEnabled == true
		-- shiftlockIcon:setEnabled(currentValue)
		-- moveBtnsIcon:setEnabled(currentValue)
		-- resetBtnsIcon:setEnabled(currentValue)
	end

	toggleNonKeyboardIcons()
	UIS:GetPropertyChangedSignal("TouchEnabled"):Connect(function()
		toggleNonKeyboardIcons()
		if UIS.TouchEnabled == false and TouchGui then
			TouchGui.Enabled = false
		end
	end)
	UIS:GetPropertyChangedSignal("KeyboardEnabled"):Connect(function()
		toggleNonKeyboardIcons()
		if UIS.KeyboardEnabled == true and TouchGui then
			TouchGui.Enabled = false
		end
	end)

	local loadedTopBar = Instance.new("BoolValue")
	loadedTopBar.Name = "loadedTopBar"
	loadedTopBar.Value = true
	loadedTopBar.Parent = Player
end)

local Keycodes = Enum.KeyCode
local UserInputTypes = Enum.UserInputType
local combatKeybinds = {}

if UIS.KeyboardEnabled == true and not UIS.TouchEnabled then
	combatKeybinds.Punch = UserInputTypes.MouseButton1
	combatKeybinds.Dash = Keycodes.Q
	combatKeybinds.Block = Keycodes.F
else
	combatKeybinds.Punch = nil
	combatKeybinds.Dash = nil
	combatKeybinds.Block = nil
end

local StartMouseMovePosition, StartSelectedButtonPosition
local inputChanged = nil

UIS.InputBegan:Connect(function(input, gameProccessedEvent)
	if gameProccessedEvent and selectedFrame == nil then
		return
	end

	if
		combatKeybinds.Punch and (input.UserInputType == combatKeybinds.Punch or input.KeyCode == combatKeybinds.Punch)
	then
		local DoPunch = coroutine.wrap(function()
			RNS.Heartbeat:Wait()
			Punch()
		end)
		DoPunch()
	elseif combatKeybinds.Dash and input.KeyCode == combatKeybinds.Dash then
		DashCheck()
	elseif combatKeybinds.Block and input.KeyCode == combatKeybinds.Block then
		local DoBlock = coroutine.wrap(function()
			RNS.Heartbeat:Wait()
			if not Character:FindFirstChild("Stunned") then
				CombatSet:FireServer("Block", { Stage = true })
				if Character:FindFirstChild("Emoting") then
					Comunicator:FireServer("StopEmote")
				end
			end
		end)
		DoBlock()
	elseif input.UserInputType == Enum.UserInputType.Touch and selectedFrame ~= nil then
		StartMouseMovePosition = input.Position
		StartSelectedButtonPosition = selectedFrame.Position
		if inputChanged then
			return
		end
		inputChanged = UIS.InputChanged:Connect(function(changedInput)
			if not selectedFrame then
				if inputChanged then
					inputChanged:Disconnect()
					inputChanged = nil
				end
				return
			end
			if changedInput.UserInputType == Enum.UserInputType.Touch then
				local Offset = changedInput.Position - StartMouseMovePosition
				selectedFrame.Position = UDim2.new(
					StartSelectedButtonPosition.X.Scale,
					StartSelectedButtonPosition.X.Offset + Offset.X,
					StartSelectedButtonPosition.Y.Scale,
					StartSelectedButtonPosition.Y.Offset + Offset.Y
				)
			end
		end)
	elseif input.KeyCode == Enum.KeyCode.B then
		if shared.emotegui then
			shared.emotegui()
		end
	elseif input.KeyCode == Enum.KeyCode.R then
		if not gameProccessedEvent then
			local isAwakened = Character:GetAttribute("Awakened") == true
			SpecialsSet:FireServer(isAwakened and "ActivateUlt" or "ActivateBase", {})
		end
	end
end)

UIS.InputEnded:Connect(function(input, gameProccessedEvent)
	if gameProccessedEvent then
		return
	end

	if
		combatKeybinds.Punch and (input.UserInputType == combatKeybinds.Punch or input.KeyCode == combatKeybinds.Punch)
	then
		CombatSet:FireServer("PunchEnd")
	elseif combatKeybinds.Block and input.KeyCode == combatKeybinds.Block then
		CombatSet:FireServer("Block", { Stage = false })
	elseif input.UserInputType == Enum.UserInputType.Touch and inputChanged ~= nil then
		inputChanged:Disconnect()
		inputChanged = nil
	end
end)

shared.detectAir = function(Params)
	local Char = Params.Char
	local HumRP2 = Char.PrimaryPart
	if not HumRP2 then
		return
	end

	local clampDivider = Params.customClamp or 5.2
	local justdown, isRagdoll = Params.justdown, Params.ragdoll
	local hitparams = Params.customParams or MapRParams

	while
		task.wait()
		and HumRP2 ~= nil
		and (not isRagdoll or (Char:HasTag("Ragdolled") or Char:HasTag("Knockbacked")))
	do
		local Velocity = HumRP2.AssemblyLinearVelocity
		local dir
		if Velocity.Magnitude < 1 or justdown ~= nil then
			dir = Vector3.new(0, justdown, 0)
		else
			dir = Velocity.Unit * (math.clamp(Velocity.Magnitude, 0, math.huge) / clampDivider)
		end
		local ray = workspace:Raycast(HumRP2.Position, dir, hitparams)
		if ray then
			local rayInstance = ray.Instance
			local rayPosition = ray.Position
			local rayMaterial = ray.Material
			local rayNormal = ray.Normal
			if
				Params.destroyables == true
				and (rayInstance.Parent.Name == "Tree" or rayInstance.Parent.Parent.Name == "Tree")
			then
				if rayInstance:IsDescendantOf(workspace.Map.Destroyables) and not rayInstance:HasTag("Destroyed") then
					shared.repfire("destroyAmbient", {
						Parts = { rayInstance },
						CFrame = CFrame.lookAt(HumRP2.Position, Velocity.Unit),
						Size = Vector3.new(18, 18, 18),
						Burn = false,
						Velocity = Velocity.Unit * Velocity.Magnitude,
					})
				end
			else
				return true,
					{ Instance = rayInstance, Position = rayPosition, Material = rayMaterial, Normal = rayNormal }
			end
		end
	end

	return nil
end

Getter.OnClientInvoke = function(Params)
	local Func = Params.Func
	if Func == "GetCF" then
		if Params.Object == "Camera" then
			return Camera.CFrame
		elseif Params.Object == "Attachment" then
			return Params.Attachment.WorldCFrame
		elseif Params.Object == "MousePos" then
			return Mouse.Hit.Position
		else
			return Params.Object.CFrame
		end
	elseif Func == "GetIndicatorPosition" then
		return IndicatorService:GetPosition(Params.id)
	end

	return nil
end

CollectionService:GetInstanceAddedSignal("Ragdolled"):Connect(function(EnemyCharacter)
	local EnemyTorso = EnemyCharacter:FindFirstChild("Torso")
	if EnemyTorso and HumRP and (EnemyTorso.Position - HumRP.Position).Magnitude <= 100 then
		local _, InsideScreen = Camera:WorldToScreenPoint(EnemyTorso.Position)
		if InsideScreen then
			local LastTime = tick()
			if tick() - LastTime <= 2 then
				local groundRay = raycast(EnemyTorso.Position, Vector3.new(0, -1.649999976158142, 0))
				if not groundRay then
					repeat
						groundRay = raycast(EnemyTorso.Position, Vector3.new(0, -1.649999976158142, 0))
						if not groundRay then
							task.wait(0.075)
						end
					until groundRay or not EnemyCharacter:HasTag("Ragdolled")
				end
			end
		end
	end
end)

CollectionService:GetInstanceRemovedSignal("Ragdolled"):Connect(function(EnemyCharacter)
	local EnemyHumanoid = EnemyCharacter:WaitForChild("Humanoid")
	EnemyHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	EnemyHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	EnemyHumanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
	EnemyHumanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
	EnemyHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end)

game.SoundService.Sounds.Volume = 1
game.SoundService["Emote Music"].Volume = 1

local function SetupLiveCharacter(GoalCharacter)
	local GoalHumanoid = GoalCharacter:WaitForChild("Humanoid", 5)
	local GoalTorso = GoalCharacter:WaitForChild("Torso", 5)
	if not GoalHumanoid or not GoalTorso then
		return
	end

	GoalHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	GoalHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	GoalHumanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	GoalHumanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)

	local PreviousTransparencies = {}
	GoalCharacter:GetAttributeChangedSignal("Invisible"):Connect(function()
		if GoalCharacter:GetAttribute("Invisible") == true then
			for _, Part in GoalCharacter:GetDescendants() do
				if (Part:IsA("BasePart") or Part:IsA("Decal")) and Part.Transparency < 1 then
					if not PreviousTransparencies[Part] then
						PreviousTransparencies[Part] = Part.Transparency
					end
					Part.Transparency = 1
				end
			end
		else
			for Part, Transparency in PreviousTransparencies do
				Part.Transparency = Transparency
			end
		end
	end)

	GoalCharacter:GetAttributeChangedSignal("AwakeningAura"):Connect(function()
		if GoalCharacter:GetAttribute("AwakeningAura") == true then
			if GoalCharacter:GetAttribute("Moveset") == "Monster Form" then
				local AuraContainer = RS.Resources.HeroHunter["Monster Form"].AuraHolder
				for _, BodyPart in pairs(GoalCharacter:GetChildren()) do
					local GoalAura = AuraContainer:FindFirstChild(tostring(BodyPart))
					if not GoalAura then
						continue
					end
					local NextContainer = {}
					local GoalPart = GoalCharacter[tostring(GoalAura)]
					for _, AuraPart in pairs(GoalAura:GetChildren()) do
						local AuraClone = AuraPart:Clone()
						AuraClone.Parent = GoalPart
						AuraClone:SetAttribute("MonsterParticles", true)
						for _, v in pairs(AuraClone:GetDescendants()) do
							if v:IsA("Trail") or v:IsA("Beam") or v:IsA("ParticleEmitter") then
								v.Enabled = true
							end
							if v:IsA("Trail") or v:IsA("Beam") then
								if v.Attachment0 and v.Attachment1 then
									NextContainer[v] =
										{ Attachment0 = v.Attachment0.CFrame, Attachment1 = v.Attachment1.CFrame }
								end
							end
						end
					end
					if next(NextContainer) then
						for i, v in pairs(NextContainer) do
							local AttachmentZero = v.Attachment0
							local AttachmentOne = v.Attachment1
							local NextParent = i.Parent.Parent
							for _, Object in pairs(GoalCharacter:GetDescendants()) do
								if Object:IsA("Attachment") then
									local GoalParent = Object.Parent
									if GoalParent and GoalParent:IsA("BasePart") and GoalParent == NextParent then
										local GoalCF = Object.CFrame
										if GoalCF == AttachmentZero then
											i.Attachment0 = Object
										elseif GoalCF == AttachmentOne then
											i.Attachment1 = Object
										end
									end
								end
							end
						end
					end
				end
			end
		else
			if GoalCharacter:GetAttribute("Moveset") == "Monster Form" then
				for _, AuraObject in GoalCharacter:GetDescendants() do
					if AuraObject:GetAttribute("MonsterParticles") then
						if AuraObject:IsA("ParticleEmitter") or AuraObject:IsA("Beam") or AuraObject:IsA("Trail") then
							AuraObject.Enabled = false
						end
						game.Debris:AddItem(AuraObject, 2)
					end
				end
			end
		end
	end)
end

workspace.Live.ChildAdded:Connect(SetupLiveCharacter)
for _, GoalCharacter in workspace.Live:GetChildren() do
	task.spawn(function()
		SetupLiveCharacter(GoalCharacter)
	end)
end

for _, LegIron in pairs(CollectionService:GetTagged("ballnchain")) do
	local LegIronParent = LegIron.Parent
	if LegIronParent and LegIronParent.Parent ~= Player.Character then
		LegIron.CanCollide = false
	else
		LegIron:GetPropertyChangedSignal("CollisionGroup"):Connect(function()
			LegIron.CollisionGroup = "NonPColDebri"
		end)
	end
end
CollectionService:GetInstanceAddedSignal("ballnchain"):Connect(function(LegIron)
	local LegIronParent = LegIron.Parent
	if LegIronParent and LegIronParent.Parent ~= Player.Character then
		LegIron.CanCollide = false
	else
		LegIron:GetPropertyChangedSignal("CollisionGroup"):Connect(function()
			LegIron.CollisionGroup = "NonPColDebri"
		end)
	end
end)

Animator.AnimationPlayed:Connect(function(animationTrack)
	animationTrack.Ended:Once(function()
		if not HumRP then
			return
		end
		local Part = Instance.new("Part")
		Part.Massless = true
		Part.Anchored = false
		Part.Size = Vector3.zero
		Part.Material = Enum.Material.SmoothPlastic
		Part.Transparency = 1
		Part.EnableFluidForces = false
		Part.CastShadow = false
		Part.CanCollide = false
		Part.CanTouch = false
		Part.CanQuery = false
		Part.Parent = HumRP
		local Weld = Instance.new("Weld")
		Weld.Parent = Part
		Weld.Part0 = HumRP
		Weld.Part1 = Part
		RNS.RenderStepped:Wait()
		Part:Destroy()
	end)
end)

TextChatService.OnIncomingMessage = function(message)
	local textSource = message.TextSource
	if not textSource then
		return
	end
	local Chatter = game.Players:GetPlayerByUserId(textSource.UserId)
	if not Chatter or not Chatter:GetAttribute("EquippedTitle") or not Chatter:GetAttribute("TitleColor") then
		return
	end
	local overrideProperties = Instance.new("TextChatMessageProperties")
	overrideProperties.PrefixText = "<font color='#"
		.. Chatter:GetAttribute("TitleColor"):ToHex()
		.. "'>"
		.. Chatter:GetAttribute("EquippedTitle")
		.. "</font> "
		.. message.PrefixText
	return overrideProperties
end

RemoteManager.ListenToAllClient(ClientRemoteListener)
