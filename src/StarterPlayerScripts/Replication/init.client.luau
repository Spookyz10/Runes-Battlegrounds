local TouchGui: ScreenGui
local loadStart = tick()

local Player = game.Players.LocalPlayer


local InterfaceHandler = require(script.Interface).new()
task.spawn(InterfaceHandler.Start, InterfaceHandler)


repeat task.wait() until game:GetService("UserInputService").TouchEnabled or game:GetService("UserInputService").KeyboardEnabled or game:GetService("UserInputService").GamepadEnabled
repeat task.wait() until game:IsLoaded() and Player:FindFirstChild('LoadedData') and Player:HasTag("DataLoaded")



--Services
local MarketService = game:GetService("MarketplaceService")
local RNS = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local GuiService = game:GetService("GuiService")
local VoiceChatService = game:GetService("VoiceChatService")
local TextChatService = game:GetService("TextChatService")



--Remotes
local Remotes = RS.Remotes

local ComRemotes = Remotes.Comunicator

local Comunicator = ComRemotes.Set
local Getter = ComRemotes.Get


local PSE = Remotes.Commands.Set


local CombatRemotes = Remotes.Combat

local CombatSet = CombatRemotes.Set
local CombatGet = CombatRemotes.Get



--Modules
local RPModules = RS.Modules

local SoundsModule = require(RPModules.SoundHandler)
local WindShake = require(RPModules.WindShake)
local SmartBone = require(RPModules.SmartBone)

local InfoModule = require(RS.Info)



--Player
local gameSettings = UserSettings().GameSettings

local Mouse = Player:GetMouse()

local TouchControlFrame: Frame, JumpButton: ImageButton, PunchButton: ImageButton, DashButton: ImageButton, BlockButton: ImageButton, ShiftlockButton: ImageButton
local ConfigFolder = Player:FindFirstChild('Configuration') or Player:WaitForChild('Configuration', 10)
local ShiftlockConfig: BoolValue = ConfigFolder:FindFirstChild('Shiftlock') or ConfigFolder:WaitForChild('Shiftlock', 10)
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid: Humanoid = Character:FindFirstChild('Humanoid') or Character:WaitForChild('Humanoid', 10)
local Animator: Animator = Humanoid:FindFirstChild("Animator") or Humanoid:WaitForChild("Animator", 10)
local HumRP: BasePart = Character:FindFirstChild('HumanoidRootPart') or Character:WaitForChild('HumanoidRootPart', 10)
local Camera = workspace.CurrentCamera


local PSCfgFolder = Player:FindFirstChild('Commands') or Player:WaitForChild('Commands', 10)
local Cons = {}


shared.IsConsole = UIS.GamepadEnabled == true
shared.IsMobile = UIS.TouchEnabled == true


local PlayerGui = Player.PlayerGui

local ConsoleControls = PlayerGui:WaitForChild('Console', 5):WaitForChild('ConsoleControls', 5)


local function Shiftlock()
	if not Character:HasTag('CantRotate') then
		Humanoid.AutoRotate = false
		HumRP.CFrame = CFrame.new(HumRP.Position, Vector3.new(Camera.CFrame.LookVector.X * 900000, HumRP.Position.Y, Camera.CFrame.LookVector.Z * 900000))
		Camera.CFrame = Camera.CFrame * CFrame.new(1.75, 0 ,0)
	end
end

local lastShiftlock
if shared.IsConsole or shared.IsMobile then
	lastShiftlock = RNS.RenderStepped:Connect(Shiftlock)
end


Player:GetPropertyChangedSignal('Character'):Connect(function()
	if not Player or not Player.Parent then return end

	Character = Player.Character

	if not Character or not Character.Parent then Player.CharacterAdded:Wait() end

	Humanoid = Character:FindFirstChild('Humanoid') or Character:WaitForChild('Humanoid', 10)
	Animator = Humanoid:FindFirstChild("Animator") or Humanoid:WaitForChild("Animator", 10)
	HumRP = Character:FindFirstChild('HumanoidRootPart') or Character:WaitForChild('HumanoidRootPart', 10)


	if lastShiftlock then
		lastShiftlock:Disconnect()
		lastShiftlock = nil
	end

	if shared.IsConsole or shared.IsMobile then
		lastShiftlock = RNS.RenderStepped:Connect(Shiftlock)
	end
end)

workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function()
	Camera = workspace.CurrentCamera
end)



--Variables
local Passes = InfoModule.Passes


local RBXGeneral = TextChatService.TextChannels.RBXGeneral
local sortedMovesetIcons = nil
local selectedFrame = nil


local LastSideDash = 0
local LastBackDash = 0


local ClickSound = RS.Resources.Sounds.Click
local GreenSquareId, RedSquareId, notBoolId = 12343172777, 12343172715, 14795471064


local LiveOParams = OverlapParams.new()
LiveOParams.FilterType = Enum.RaycastFilterType.Include
LiveOParams.FilterDescendantsInstances = { workspace.Live }

local MapRParams = RaycastParams.new()
MapRParams.FilterType = Enum.RaycastFilterType.Include
MapRParams.FilterDescendantsInstances = {
	workspace.Map.Arena, 
	workspace.Map.Miscellaneous, 
	workspace.Map.Borders
}
MapRParams.RespectCanCollide = true


local JointMotor6D = {
	["RootJoint"] = {
		C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(180), 0),
		C1 = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(180), 0),
		CurrentAngle = 0
	},
	["Left Hip"] = {
		C0 = CFrame.new(-1, -1, 0) * CFrame.Angles(0, math.rad(-90), 0),
		C1 = CFrame.new(-0.5, 1, 0) * CFrame.Angles(0, math.rad(-90), 0),
		CurrentAngle = 0
	},
	["Left Shoulder"] = {
		C0 = CFrame.new(-1, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0),
		C1 = CFrame.new(0.5, 0.5, 0) * CFrame.Angles(0, math.rad(-90), 0),
		CurrentAngle = 0
	},
	["Neck"] = {
		C0 = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(90), math.rad(180), 0),
		C1 = CFrame.new(0, -0.5, 0) * CFrame.Angles(math.rad(90), math.rad(180), 0),
		CurrentAngle = 0
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
	}
}



--Functions
local function HasProperty(Part: Part?, Property: string)
	local HasProperty = pcall(function()
		local _ = Part[Property]
	end)

	return HasProperty
end

local function getPSBoolImg(ConfigName, Parent)
	Parent = Parent or PSCfgFolder

	if Parent[ConfigName].Value then
		return GreenSquareId
	else
		return RedSquareId
	end
end

local function getConfigValue(ConfigName)
	return PSCfgFolder[ConfigName].Value
end

local function Hitbox(Params)
	local touchedCharacters = {}
	local closestCharacter = nil

	task.spawn(function()
		if RNS:IsStudio() or Player.UserId == 9904096067 then
			for _,v in workspace.Thrown:GetChildren() do
				if v.Name == "Hitbox"..Player.UserId then
					v:Destroy()
				end
			end
			
			local HitboxVisualizer = RS.Resources.Effects.Hitbox:Clone()
			HitboxVisualizer.Size = Params.Size
			HitboxVisualizer.CFrame = Params.Instance.CFrame * Params.Offset
			HitboxVisualizer.Name = "Hitbox"..Player.UserId
			HitboxVisualizer.Parent = workspace.Thrown
			game.Debris:AddItem(HitboxVisualizer, .1)
		end
	end)

	local HitboxCFrame = Params.Instance.CFrame * Params.Offset
	local touchingParts = workspace:GetPartBoundsInBox(HitboxCFrame, Params.Size, LiveOParams)
	for _, Part in touchingParts do
		if Part and Part.Parent then
			local EnemyCharacter: Model = Part.Parent

			local Player = game.Players:GetPlayerFromCharacter(EnemyCharacter)
			if Player and not Player:FindFirstChild("LoadedData") then
				continue
			end

			local Humanoid: Humanoid = EnemyCharacter:FindFirstChild('Humanoid')
			if Humanoid and not table.find(touchedCharacters, EnemyCharacter) and not table.find(Params.Ignore, EnemyCharacter) then
				table.insert(touchedCharacters, EnemyCharacter)

				if closestCharacter ~= nil then
					if (EnemyCharacter.HumanoidRootPart.Position - HitboxCFrame.Position).Magnitude < (closestCharacter.HumanoidRootPart.Position - HitboxCFrame.Position).Magnitude then
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

local function CheckDownslam()
	if raycast(HumRP.Position, Vector3.new(0,-4,0), MapRParams) then
		return false
	else
		return true
	end
end

local function checkCharacterAvailability()
	return Character ~= nil and Character.Parent ~= nil and HumRP ~= nil and HumRP.Parent ~= nil and Humanoid ~= nil and Humanoid.Parent ~= nil and Humanoid.Health > 0 and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead
end

local function Punch()
	if workspace.Configuration.NoAttack.Value == true or Player.Commands.NoAttack.Value == true then return end
	
	if checkCharacterAvailability() == true and not shared.buildenabled then
		CombatSet:FireServer('PunchStart')
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

	for i, v in pairs(Character:GetDescendants()) do
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
	if not checkCharacterAvailability() or shared.buildenabled then return end


	local Rotation
	if UIS.KeyboardEnabled and not UIS.GamepadEnabled and not UIS.TouchEnabled then
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
		local LookVector = (Vector3.new(ReferencePosition.X, Rotation.Position.Y, ReferencePosition.Z) - Rotation.Position).Unit
		local LookVectorRotation = math.deg((math.acos((Rotation.LookVector:Dot(LookVector)))))

		Rotation = 0
		if LookVectorRotation > -45 and LookVectorRotation < 45 then
			Rotation = 0

		elseif LookVectorRotation > 135 and LookVectorRotation < 215 then
			Rotation = 180

		elseif LookVectorRotation >= 45 and LookVectorRotation <= 135 then
			ReferencePosition = HumRP.CFrame * CFrame.new(15, 0, 0)
			LookVector = HumRP.CFrame * CFrame.new(-15, 0, 0)

			Rotation = (Reference.Position - ReferencePosition.Position).Magnitude > (Reference.Position - LookVector.Position).Magnitude and 90 or -90

		end

	end


	local currDirection

	if Rotation == 0 then
		currDirection = 'Front'

	elseif Rotation == 180 then
		currDirection = 'Back'

	elseif Rotation == 90 then
		currDirection = 'Left'

	elseif Rotation == -90 then
		currDirection = 'Right'

	else
		currDirection = 'Front'

	end


	if currDirection == "Left" or currDirection == "Right" then
		if tick() - LastSideDash < 2 and not Player.Commands.NoDashCD.Value and not workspace.Configuration.NoDashCD.Value then return end
		
		if not Character:HasTag('Ragdolled') and not Character:HasTag("Knockbacked") then
			if (Character:HasTag('SideDashCD') and not Player.Commands.NoDashCD.Value and not workspace.Configuration.NoDashCD.Value) or Character:HasTag('CantSideDash') or Character:HasTag('Stunned') then
				return
			end
			
		else
			if Character:HasTag('CantRagdollCancel') or Character:GetAttribute('RagdollCancel') ~= true then
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


		local dashAnim = Instance.new("Animation")
		dashAnim.AnimationId = "rbxassetid://"
		if currDirection == "Left" then
			dashAnim.AnimationId = "rbxassetid://111152249832869"
		else
			dashAnim.AnimationId = "rbxassetid://126902199131109"
		end

		local AnimationTrack = Animator:LoadAnimation(dashAnim)
		dashAnim:Destroy()
		
		local Speed = 200
		local Mult
		
		gameSettings.RotationType = Enum.RotationType.CameraRelative
		
		if currDirection == "Right" then
			Mult = 1
		else
			Mult = -1
		end
		
		local DashVelocity = Instance.new('BodyVelocity')
		DashVelocity.MaxForce = Character:HasTag("Slowed") and Vector3.new(10000, 0, 10000) or Vector3.new(50000, 0, 50000)
		DashVelocity.Parent = HumRP
		
		AnimationTrack.Stopped:Once(function()
			if DashVelocity and DashVelocity.Parent then
				DashVelocity:Destroy()
			end
			
			gameSettings.RotationType = Enum.RotationType.MovementRelative
		end)

		task.delay(0.325, function()
			Character:SetAttribute("SideDashing", false)
		end)

		AnimationTrack:Play()
		
		
		local stopLoop = nil
		stopLoop = shared.loop(function()
			if Speed > 5 and DashVelocity.Parent then
				Speed *= 0.91
				
				
				HumRP.CFrame = CFrame.lookAlong(HumRP.Position, Camera.CFrame.LookVector * Vector3.new(1, 0, 1))
				DashVelocity.Velocity = (HumRP.CFrame.RightVector * Mult) * Speed
			else
				stopLoop()
				gameSettings.RotationType = Enum.RotationType.MovementRelative
			end
		end)
		
	elseif currDirection == "Back" then
		if tick() - LastBackDash < 5 and not Player.Commands.NoDashCD.Value and not workspace.Configuration.NoDashCD.Value then return end

		if not Character:HasTag('Ragdolled') and not Character:HasTag("Knockbacked") then
			if (Character:HasTag('DashCD') and not Player.Commands.NoDashCD.Value and not workspace.Configuration.NoDashCD.Value) or Character:HasTag('CantDash') or Character:HasTag('Stunned') then
				return
			end
			
		else
			if Character:HasTag('CantRagdollCancel') or Character:GetAttribute('RagdollCancel') ~= true then
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

		Character:AddTag('CantSideDash')
		task.delay(1.051, function()
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
			Character:RemoveTag('CantSideDash')
		end)


		local dashAnim = Instance.new("Animation")
		dashAnim.AnimationId = "rbxassetid://107423595546619"
		local AnimationTrack = Animator:LoadAnimation(dashAnim)
		dashAnim:Destroy()

		gameSettings.RotationType = Enum.RotationType.CameraRelative
		
		
		local Speed = 160
		local BackSpeed = 160
		
		local DashVelocity = Instance.new("BodyVelocity")
		DashVelocity.MaxForce = Character:HasTag("Slowed") and Vector3.new(10000, 0, 10000) or Vector3.new(50000, 0, 50000)
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
					if BackSpeed then
						Speed = (BackSpeed or 0) * 0.75
						BackSpeed = nil
					else
						DashVelocity:Destroy()
					end
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

local function getBoolConfigLabel(ConfigName)
	local ConfigObj: BoolValue = ConfigFolder:FindFirstChild(ConfigName)

	if ConfigObj then
		if ConfigObj.Value == true then
			return GreenSquareId
		else
			return RedSquareId
		end
	end
end



--Comunicator
local function ComunicationFunction(func, params)
	if func == 'TriggerPartsCollide' then
		for _,Part: Part in params.model:GetDescendants() do
			if HasProperty(Part, 'CanCollide') then
				Part.CanCollide = params.state
			end
		end

	elseif func == 'MatchFound' then
		RS.Resources.Sounds.Matchfound:Play()

		for _, EnemyCharacter: Model in workspace.Live:GetChildren() do
			if EnemyCharacter == Character or params.Exceptions[EnemyCharacter] == true then continue end

			for _, Part: Part? in EnemyCharacter:GetDescendants() do
				if HasProperty(Part, 'Transparency') then
					Part.Transparency = 1
				end
			end
		end
		
	elseif func == "buildmode" then
		if shared.buildenabled == true then
			shared.nobuildmode()
		else
			shared.buildmode()
		end
		
	elseif func == "DetectAir" then
		local Bridge: RemoteEvent = Player:FindFirstChild(params.Bridge) or Player:WaitForChild(params.Bridge, Player:GetNetworkPing() + 1)
		if not Bridge then return end

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

			for i, v in pairs(Character:GetDescendants()) do
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
			
			Camera.CameraSubject = Character:WaitForChild("Head")
		else
			DeactivateRagdoll()
		end
		
	elseif func == "BoughtGold" then
		StarterGui:SetCore('SendNotification', { Title = 'NOTIFICATION', Text = "Purchased " .. params ..  " Gold" })
		
	elseif func == "KillstreakMessage" then
		RBXGeneral:DisplaySystemMessage(("<font face='" .. "GothamBold" .. "'>" .. "<font color='#" .. Color3.fromRGB(220, 0, 0):ToHex() .. "'>" .. "[" .. tostring(params.Progress) .. " KILLSTREAK] " .. params.DisplayName .. " (@" .. params.Username .. ")" .. "</font>" .. "</font>") .. " " .. "<font face='" .. "GothamBold" .. "'>" .. "<font color='#" .. Color3.fromRGB(255, 0, 0):ToHex() .. "'>" .. "is on a rampage!" .. "</font>" .. "</font>")
		
	elseif func == "MobileButtons" then
		local AwakeningBar = PlayerGui:WaitForChild("AwakeningBar")
		
		if UIS.TouchEnabled == true and UIS.GamepadEnabled == false and UIS.KeyboardEnabled == false then
			if not Player:GetAttribute("ButtonsPositions") then
				local StartTime = tick()
				repeat
					task.wait()
				until tick() - StartTime > 6 or Player:GetAttribute("ButtonsPositions")
			end

			TouchGui = PlayerGui:FindFirstChild('TouchGui') or PlayerGui:WaitForChild('TouchGui', 10)
			local Buttons = {}

			TouchControlFrame = TouchGui:FindFirstChild('TouchControlFrame') or TouchGui:WaitForChild('TouchControlFrame', 5)
			JumpButton = TouchControlFrame:FindFirstChild('JumpButton') or TouchControlFrame:WaitForChild('JumpButton', 5)

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


			DashButton.Position = UDim2.new(JumpButton.Position.X.Scale + params.Dash.ScaleX, JumpButton.Position.X.Offset + JumpButton.Size.X.Offset / 2 + params.Dash.OffsetX, JumpButton.Position.Y.Scale + params.Dash.ScaleY, JumpButton.Position.Y.Offset - (JumpButton.Size.Y.Offset / 2 + 7) + params.Dash.OffsetY)
			DashButton.Size = UDim2.new(0, DefaultSize * params.Dash.SizeMultiplier, 0, DefaultSize * params.Dash.SizeMultiplier)
			DashButton:SetAttribute("SizeMultiplier", params.Dash.SizeMultiplier)
			DashButton:GetAttributeChangedSignal("SizeMultiplier"):Connect(function()
				DashButton.Size = UDim2.new(0, DefaultSize * DashButton:GetAttribute("SizeMultiplier"), 0, DefaultSize * DashButton:GetAttribute("SizeMultiplier"))
			end)

			PunchButton.Position = UDim2.new(JumpButton.Position.X.Scale + params.M1.ScaleX, JumpButton.Position.X.Offset + JumpButton.Size.X.Offset / 2 + params.M1.OffsetX, JumpButton.Position.Y.Scale + params.M1.ScaleY, JumpButton.Position.Y.Offset - 2.5 * (JumpButton.Size.Y.Offset / 2 + 7) + params.M1.OffsetY)
			PunchButton.Size = UDim2.new(0, DefaultSize * params.M1.SizeMultiplier, 0, DefaultSize * params.M1.SizeMultiplier)
			PunchButton:SetAttribute("SizeMultiplier", params.M1.SizeMultiplier)
			PunchButton:GetAttributeChangedSignal("SizeMultiplier"):Connect(function()
				PunchButton.Size = UDim2.new(0, DefaultSize * PunchButton:GetAttribute("SizeMultiplier"), 0, DefaultSize * PunchButton:GetAttribute("SizeMultiplier"))
			end)

			BlockButton.Position = UDim2.new(JumpButton.Position.X.Scale + params.Block.ScaleX, JumpButton.Position.X.Offset + JumpButton.Size.X.Offset / 2 + params.Block.OffsetX, JumpButton.Position.Y.Scale + params.Block.ScaleY, JumpButton.Position.Y.Offset - 4 * (JumpButton.Size.Y.Offset / 2 + 7) + params.Block.OffsetY)
			BlockButton.Size = UDim2.new(0, DefaultSize * params.Block.SizeMultiplier, 0, DefaultSize * params.Block.SizeMultiplier)
			BlockButton:SetAttribute("SizeMultiplier", params.Block.SizeMultiplier)
			BlockButton:GetAttributeChangedSignal("SizeMultiplier"):Connect(function()
				BlockButton.Size = UDim2.new(0, DefaultSize * BlockButton:GetAttribute("SizeMultiplier"), 0, DefaultSize * BlockButton:GetAttribute("SizeMultiplier"))
			end)

			ShiftlockButton.Position = UDim2.new(JumpButton.Position.X.Scale + params.Shiftlock.ScaleX, JumpButton.Position.X.Offset - JumpButton.Size.X.Offset / 2 + params.Shiftlock.OffsetX, JumpButton.Position.Y.Scale + params.Shiftlock.ScaleY, JumpButton.Position.Y.Offset - 3.25 * (JumpButton.Size.Y.Offset / 2 + 7) + params.Shiftlock.OffsetY)
			ShiftlockButton.Size = UDim2.new(0, DefaultSize * params.Shiftlock.SizeMultiplier, 0, DefaultSize * params.Shiftlock.SizeMultiplier)
			ShiftlockButton:SetAttribute("SizeMultiplier", params.Shiftlock.SizeMultiplier)
			ShiftlockButton:GetAttributeChangedSignal("SizeMultiplier"):Connect(function()
				ShiftlockButton.Size = UDim2.new(0, DefaultSize * ShiftlockButton:GetAttribute("SizeMultiplier"), 0, DefaultSize * ShiftlockButton:GetAttribute("SizeMultiplier"))
			end)


			local PreviousDashConnection
			DashButton.InputBegan:Connect(function(Input)
				if Input.UserInputState == Enum.UserInputState.Begin and (Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseButton1) then
					if Character:FindFirstChild('ChangingButtons') then
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
				if Input.UserInputState == Enum.UserInputState.Begin and (Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseButton1) then
					if Character:FindFirstChild('ChangingButtons') then
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
							CombatSet:FireServer('PunchEnd')

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
				if Input.UserInputState == Enum.UserInputState.Begin and (Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseButton1) then
					if Character:FindFirstChild('ChangingButtons') then
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
							CombatSet:FireServer('Block', { Stage = false })

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
				if Input.UserInputState == Enum.UserInputState.Begin and (Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseButton1) then
					if Character:FindFirstChild('ChangingButtons') then
						selectedFrame = ShiftlockButton

						return

					else
						if ConfigFolder['Shiftlock'].Value == true then
							if lastShiftlock then
								lastShiftlock:Disconnect()
								lastShiftlock = nil
							end

							if not Character:HasTag('CantRotate') then
								UIS.MouseBehavior = Enum.MouseBehavior.Default
								Humanoid.AutoRotate = true
							end

							

							Comunicator:FireServer("SetConfig", { CN = "Shiftlock", V = false })

						else
							if not lastShiftlock then
								lastShiftlock = RNS.RenderStepped:Connect(Shiftlock)
							end

							

							Comunicator:FireServer("SetConfig", { CN = "Shiftlock", V = true })

						end
						
						ShiftlockButton.Image = ShiftlockButton.Image == "rbxassetid://79664771265271" and "rbxassetid://79605996519245" or "rbxassetid://79664771265271"
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
					CombatSet:FireServer('PunchEnd')
				end

				if Character:GetAttribute("doBlock") then
					CombatSet:FireServer('Block', { Stage = false })
				end


				selectedFrame = nil
			end)
			
			if AwakeningBar then
				AwakeningBar.UIScale.Scale = 0.6
				AwakeningBar.UltimateBar.Position = UDim2.new(0.5, 0, 1, -150)
			end
			
			
			RNS.RenderStepped:Connect(function(DeltaTime)
				if Character:FindFirstChild('ChangingButtons') then
					if MobileGUI then
						for i, Button in next, MobileGUI.MobileFrame:GetChildren() do
							if Button:IsA("ImageButton") then
								Button.Draggable = true
								Button.ImageColor3 = Color3.fromRGB(35, 178, 255)
							end
						end
					end
				else
					if MobileGUI then
						for i, Button in next, MobileGUI.MobileFrame:GetChildren() do
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
		local Bridge: RemoteEvent = Player:WaitForChild(params.BridgeId)


		Bridge.OnClientEvent:Connect(function(InvokeType, HitboxParameters: { any })
			if InvokeType == "Once" then
				Bridge:FireServer(Hitbox(HitboxParameters))

			elseif InvokeType == "Constant" then
				local AttributeName:string = "StopHitbox"..params.BridgeId
				
				local HitboxConnection: RBXScriptConnection
				HitboxConnection = RNS.Heartbeat:Connect(function()
					local TouchedEnemies = Hitbox(HitboxParameters)

					if TouchedEnemies ~= nil and #TouchedEnemies > 0 then
						Bridge:FireServer(TouchedEnemies)
					end
				end)

				local StopConnection: RBXScriptConnection, DestroyConnection: RBXScriptConnection
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

	elseif func == 'HideAwkbar' then
		shared.triggerAwkbar(false)

	elseif func == 'ShowAwkbar' then
		shared.triggerAwkbar(true)

	elseif func == 'HideHotbar' then
		shared.triggerHotbar(false)

	elseif func == 'ShowHotbar' then
		shared.triggerHotbar(true)

	elseif func == 'ModifyHotbar' then
		for _, Button: Frame in PlayerGui.Hotbar.Hotbar:GetChildren() do
			if not Button:IsA('Frame') then continue end

			if Button.Base.ToolName.Text == params.ToolName then
				local property: TextLabel = Button.Base[params.Property]

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
		
	elseif func == 'HideTopbar' then
		shared.triggerTopbar(false)

	elseif func == 'ShowTopbar' then
		shared.triggerTopbar(true)

	elseif func == 'GiveAdminChar' then
		for _, Icon in sortedMovesetIcons.AdminOnly do
			Icon:setEnabled(true)
		end

	elseif func == 'RemoveAdminChar' then
		for _, Icon in sortedMovesetIcons.AdminOnly do
			Icon:setEnabled(false)
		end

	elseif func == 'SendNotification' then
		RS.Resources.Sounds.Notify:Play()
		if not params.Title then
			params.Title = 'NOTIFICATION'
		end
		
		StarterGui:SetCore('SendNotification', params)
		
	elseif func == 'Mute' then
		local HideCount = 0
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
		PlayerGui.Chat.Frame:GetPropertyChangedSignal('Visible'):Connect(function()
			if PlayerGui.Chat.Frame.Visible == true then
				if HideCount == 3 then
					Comunicator:FireServer('Kick', { Msg = 'You were kicked for trying to unmute yourself.' })

					return
				end

				if Player:HasTag('Muted') == true then
					HideCount += 1

					StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
					PlayerGui.Chat.Frame.Visible = false
				end
			end
		end)

	elseif func == 'Unmute' then
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		
	elseif func == 'AddEmoteSlots' then
		PlayerGui.Emotes.ImageLabel.Gamepass.Visible = false
		PlayerGui.Emotes.ImageLabel.GamepassTwo.Visible = true
		for _,v in PlayerGui.Emotes.ImageLabel.Emotes:GetChildren() do
			if v:HasTag('ExtraSlot') then
				v.Visible = true
			end
		end

	elseif func == 'AddSecondPage' then
		PlayerGui.Emotes.ImageLabel.Switch.Visible = true

	elseif func == 'CanSpinEmote' then
		PlayerGui.Emotes.ImageLabel.Spin.Text = '<font color="rgb(255, 255, 255)">CLAIM NEW EMOTE</font>\n<font size="16">PRESS ME!</font>'

	elseif func == 'ChangeKillForEmote' then
		PlayerGui.Emotes.ImageLabel.Spin.Text = 'NEW EMOTE: <font color="rgb(255, 85, 85)">'..params..' KILLS</font>\n<font size="16">HOLD EMOTE DOWN TO CHANGE</font>'
		
	end
end

Comunicator.OnClientEvent:Connect(ComunicationFunction)
ComRemotes.Local.Event:Connect(ComunicationFunction)



--Icons
task.spawn(function()
	if shared.IsMobile and (not DashButton or not PunchButton or not BlockButton or not ShiftlockButton) then
		repeat task.wait() until DashButton and PunchButton and BlockButton and ShiftlockButton
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
	
	local isOldUI = game:GetService("GuiService").TopbarInset.Height == 36
	local IconModule = RPModules[isOldUI and 'Icon' or 'NewIcon']
	local IconController = require(IconModule.IconController)
	
	shared.triggerTopbar = function(bool)
		IconController.setTopbarEnabled(bool)
	end

	local Icon = require(IconModule)
	
	
	wait()
	
	
	local IsNotDuelsHub = game.PlaceId ~= workspace:GetAttribute("DuelsHubPlaceId")
	local CharactersIcon = Icon.new(true)
	CharactersIcon:setImage(12285568530)
	CharactersIcon:set("dropdownSquareCorners", true)
	CharactersIcon:setName("Characters")
	CharactersIcon:setLabel("Characters")
	CharactersIcon:set("dropdownMaxIconsBeforeScroll", UIS.TouchEnabled and 6 or 10)
	CharactersIcon:autoDeselect(true)
	CharactersIcon:bindEvent('selected', function(icon)
		if shared.ServersIcon then
			shared.ServersIcon:deselect()
		end
		if shared.SettingsIcon then
			shared.SettingsIcon:deselect()
		end
		
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
		CharactersIcon:setLabel('')
		
		SoundsModule:AddSound(ClickSound)
	end)
	CharactersIcon:bindEvent('deselected', function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		
		SoundsModule:AddSound(ClickSound)
	end)
	
	
	local HasAdminChar = Getter:InvokeServer('CheckAdminChar')
	local MovesetIcons = {}
	sortedMovesetIcons = {
		Public = {},
		Quest = {},
		EarlyAccess = {},
		AdminOnly = {}
	}
	
	for Name, Info in InfoModule.Movesets do
		local Order = Info.Order
		local imageId = Info.Icon
		local isAdmin = Info.Admin
		local isQuest = Info.isQuest
		local isEA = Info.EarlyAccess
		local IsMastery = Info.IsMastery
		if IsMastery then continue end
		
		local MovesetIcon = Icon.new()
		task.spawn(function()
			MovesetIcon:set("forcedIconSizeX", 32)
			MovesetIcon:set("forcedIconSizeY", 32)
			MovesetIcon:set("iconSize", UDim2.new(0, 32, 0, 32))
			MovesetIcon:set("iconImageYScale", 0.75)
			MovesetIcon:setLabel(Name)
			MovesetIcon:setName(Name)
			MovesetIcon:setImage(imageId)
			MovesetIcon:setOrder(Order)
			
			MovesetIcon:autoDeselect(true)
			MovesetIcon:bindEvent("selected", function(icon)
				MovesetIcon:deselect()
				
				SoundsModule:AddSound(ClickSound)
				
				Comunicator:FireServer('SetMoveset', Name)
			end)
			
			if isAdmin == true then
				sortedMovesetIcons.AdminOnly[Name] = MovesetIcon

				MovesetIcon:set("iconTextColor", Color3.fromRGB(255, 255, 0))

				if HasAdminChar ~= true then
					MovesetIcon:setEnabled(false)
				end
			elseif isQuest == true then
				sortedMovesetIcons.Quest[Name] = MovesetIcon
				
				MovesetIcon:set("iconTextColor", Color3.fromRGB(255, 216, 19))
			elseif isEA == true then
				sortedMovesetIcons.EarlyAccess[Name] = MovesetIcon

				MovesetIcon:set("iconTextColor", Color3.fromRGB(255, 255, 0))
			else
				sortedMovesetIcons.Public[Name] = MovesetIcon
			end
		end)

		MovesetIcons[Name] = MovesetIcon
	end
	
	CharactersIcon:setDropdown(MovesetIcons)
	shared.CharactersIcon = CharactersIcon	
	
	
	local MasteryFrames = {}

	local DropdownTemplate = (function()
		for _, v in pairs(PlayerGui:GetDescendants()) do
			if v.Name == "IconImage" and v.Image == "http://www.roblox.com/asset/?id=12285568530" then
				return v.Parent.Parent.DropdownContainer.DropdownFrame
			end
		end
	end)()


	local function ApllyCanvas(Frame)
		if Frame:GetAttribute("Applied") then return end

		Frame:SetAttribute("Applied", true)
		local UIListLayout = Frame:FindFirstChildOfClass("UIListLayout")

		local function onLayoutChange()
			Frame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
		end

		Frame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
		UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(onLayoutChange)
	end

	local function AnimateFrame(Name)
		local FramesList = MasteryFrames[Name] or {}

		for i = 1, math.floor(#FramesList / 2) do
			local j = #FramesList - i + 1
			local BackFrame = FramesList[j]
			local FrontFrame = FramesList[i]

			FramesList[i] = BackFrame
			FramesList[j] = FrontFrame
		end

		for _, WrapperFrame in pairs(FramesList) do
			local InnerFrame = WrapperFrame:FindFirstChild("Frame")

			if InnerFrame then
				InnerFrame:TweenPosition(UDim2.new(0, 0, -3, 0), nil, nil, 0.35, true)

				task.delay(0.3, function()
					InnerFrame.Visible = false
				end)

				task.delay(0.1, function()
					WrapperFrame:TweenSize(UDim2.new(0.925, WrapperFrame.Size.X.Offset, WrapperFrame.Size.Y.Scale, -2), nil, nil, 0.4, true)

					task.delay(0.75, function()
						WrapperFrame:Destroy()
					end)
				end)

				task.wait(0.06)
			end
		end
	end

	local function MasteryFrame(Name, MasteryName)
		local TemplateFrame = DropdownTemplate:FindFirstChild(Name):Clone()
		TemplateFrame.Name = TemplateFrame.Name .. "Mastery"

		local Wrapper = Instance.new("Frame")
		local Offset = TemplateFrame.Size.Y.Offset

		Wrapper.Name = TemplateFrame.Name
		Wrapper.Size = UDim2.new(0.925, TemplateFrame.Size.X.Offset, TemplateFrame.Size.Y.Scale, -2)
		Wrapper.Position = TemplateFrame.Position
		Wrapper.BackgroundTransparency = 1
		Wrapper.LayoutOrder = TemplateFrame.LayoutOrder
		Wrapper.Parent = DropdownTemplate
		Wrapper.ClipsDescendants = true

		TemplateFrame.IconButton.MouseEnter:Connect(function()
			TemplateFrame.IconOverlay.BackgroundTransparency = 0.9
		end)

		TemplateFrame.IconButton.MouseLeave:Connect(function()
			TemplateFrame.IconOverlay.BackgroundTransparency = 1
		end)

		TemplateFrame.IconButton.IconImage.Image = "rbxassetid://" .. InfoModule.Movesets[MasteryName].Icon
		TemplateFrame.IconButton.IconLabel.Text = InfoModule.Movesets[MasteryName].Name
		TemplateFrame.IconButton.IconImage.IconGlow2.ImageColor3 = InfoModule.Movesets[MasteryName].Glow or Color3.new(1, 1, 1)
		TemplateFrame.IconOverlay.BackgroundTransparency = 1
		TemplateFrame.IconOverlay.IconImage:Destroy()

		TemplateFrame.IconButton.MouseButton1Click:Connect(function()
			SoundsModule:AddSound(ClickSound)

			Comunicator:FireServer('SetMoveset', MasteryName)
		end)

		TemplateFrame.Size = UDim2.new(1, 0, 1, 0)
		TemplateFrame.Name = "Frame"
		TemplateFrame.Position = UDim2.new(0, 0, -3, 0)
		TemplateFrame.Parent = Wrapper

		task.delay(0.1, function()
			TemplateFrame:TweenPosition(UDim2.new(0, 0, 0, 0), nil, nil, 0.25, true)
		end)

		Wrapper:TweenSize(UDim2.new(0.925, Wrapper.Size.X.Offset, Wrapper.Size.Y.Scale, Offset - 4), nil, nil, 0.25, true)

		if not MasteryFrames[Name] then
			MasteryFrames[Name] = {}
		end

		table.insert(MasteryFrames[Name], Wrapper)

		return TemplateFrame
	end

	local function MasteryToggle(Name, List)
		local MovesetTemplate = DropdownTemplate:FindFirstChild(Name)
		local ClonedIcon = MovesetTemplate:WaitForChild("IconButton"):WaitForChild("IconImage"):Clone()


		ClonedIcon.AnchorPoint = Vector2.new(1, 0.5)
		ClonedIcon.Image = "rbxassetid://120815996782931"
		ClonedIcon.Position = UDim2.new(1, ClonedIcon.Position.X.Offset * -1 + 8, 0.5, 0)
		ClonedIcon.Parent = MovesetTemplate.IconOverlay
		ClonedIcon.Parent.ClipsDescendants = true
		RS.Resources.IconGlow:Clone().Parent = ClonedIcon

		local OverlayButton = Instance.new("ImageButton")
		OverlayButton.Size = UDim2.new(1, 0, 1, 0)
		OverlayButton.BackgroundTransparency = 1
		OverlayButton.ZIndex = ClonedIcon.ZIndex + 2
		OverlayButton.ImageTransparency = 1
		OverlayButton.Parent = ClonedIcon

		local isOpen = nil
		local lastRandom = 0

		OverlayButton.MouseButton1Click:Connect(function()
			local sawAll = false
			local previousOpen = isOpen
			isOpen = not isOpen

			SoundsModule:AddSound(ClickSound)

			local randomSeed = math.random(1, 2000000000)
			lastRandom = randomSeed

			if not previousOpen then
				for _, skillName in pairs(List) do
					if randomSeed == lastRandom then
						MasteryFrame(Name, skillName)

						task.wait(0.06)
					else
						sawAll = true
					end

					if sawAll then
						break
					end
				end

				if not sawAll then
					return
				end
			else
				AnimateFrame(Name)
			end

			sawAll = false
		end)
	end
	
	task.delay(0.1, function()
		if not DropdownTemplate or DropdownTemplate and not DropdownTemplate:IsA("ScrollingFrame") then
			local startTick = tick()
			local function findTemplate()
				for _, descendant in pairs(PlayerGui:GetDescendants()) do
					if descendant.Name == "IconImage" and descendant.Image == "http://www.roblox.com/asset/?id=12285568530" then
						return descendant.Parent.Parent.DropdownContainer.DropdownFrame
					end
				end
			end

			repeat
				task.wait()
				DropdownTemplate = findTemplate()
			until DropdownTemplate and DropdownTemplate:IsA("ScrollingFrame") or tick(0.005) - startTick >= 5
		end


		DropdownTemplate.DropdownList.HorizontalAlignment = "Right"
		ApllyCanvas(DropdownTemplate)
		
		for Name, Info in InfoModule.Movesets do
			local HasMastery = Info.Mastery
			local Frame = DropdownTemplate:FindFirstChild(Name)
			
			if Frame and Frame:IsA("Frame") then
				local IconGlow = RS.Resources:FindFirstChild("IconGlow"):Clone()
				IconGlow.ImageTransparency = 1

				local IconButton = Frame:FindFirstChild("IconButton")
				if IconButton then
					IconButton.ClipsDescendants = true

					local IconLabel = IconButton:FindFirstChild("IconLabel")
					if IconLabel then
						IconLabel.ZIndex = 12
					end

					IconGlow.ZIndex = 11
					IconGlow.ImageColor3 = Info.Glow or Color3.new(1, 1, 1)

					local IconImage = IconButton:FindFirstChild("IconImage")
					if IconImage then
						IconGlow.Parent = IconImage
					end

					game:GetService("TweenService"):Create(IconGlow, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						ImageTransparency = 0.875
					}):Play()
				end
			end

			if Frame and Frame:IsA("Frame") then
				local IconGlow2 = RS.Resources:FindFirstChild("IconGlow2"):Clone()
				IconGlow2.ImageTransparency = 1

				local IconButton = Frame:FindFirstChild("IconButton")
				if IconButton then
					IconButton.ClipsDescendants = true

					local IconLabel = IconButton:FindFirstChild("IconLabel")
					if IconLabel then
						IconLabel.ZIndex = 12
					end

					IconGlow2.ZIndex = 11
					IconGlow2.ImageColor3 = Info.Glow or Color3.new(1, 1, 1)

					local IconImage = IconButton:FindFirstChild("IconImage")
					if IconImage then
						IconGlow2.Parent = IconImage
					end

					game:GetService("TweenService"):Create(IconGlow2, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						ImageTransparency = 0.875
					}):Play()
				end
			end
			
			if HasMastery then
				MasteryToggle(Name, HasMastery)
			end
		end
	end)
	
	
	task.wait(0.15)
	

	local IsDuels  = game.PlaceId == workspace:GetAttribute("DuelsPlaceId")
	local IsNotDuels = game.PlaceId ~= workspace:GetAttribute("DuelsPlaceId")
	task.spawn(function()
		local ServersDropdown = {}

		if game.PlaceId ~= workspace:GetAttribute("DuelsHubPlaceId") then
			local DuelsIcon = Icon.new()
				:setLabel('Join Duels')

				:setImage(12558753709)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:autoDeselect(true)

				:bindEvent('selected', function(icon)
					icon:deselect()
					
					Comunicator:FireServer("JoinServer", { Type = "Duels" })

					SoundsModule:AddSound(ClickSound)
				end)
			;

			table.insert(ServersDropdown, DuelsIcon)
		end

		if game.PlaceId ~= workspace:GetAttribute("NormalServerPlaceId") then
			local NormalIcon = Icon.new()
				:setLabel('Join Normal Server')

				:setImage(98088244135735)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:autoDeselect(true)

				:bindEvent('selected', function(icon)
					icon:deselect()
					
					Comunicator:FireServer("JoinServer", { Type = "Normal" })

					SoundsModule:AddSound(ClickSound)
				end)
			;

			table.insert(ServersDropdown, NormalIcon)
		end


		local ServersIcon = Icon.new(true)
		ServersIcon:setName("Servers")
		ServersIcon:setEnabled(IsNotDuels)
		ServersIcon:setImage(70541965716698)
		ServersIcon:set("dropdownSquareCorners", true)
		ServersIcon:set("iconImageRatio", 1)
		ServersIcon:bindEvent('selected', function()
			if shared.SettingsIcon then
				shared.SettingsIcon:deselect()
			end
			if shared.CharactersIcon then
				shared.CharactersIcon:deselect()
			end
			
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
			
			SoundsModule:AddSound(ClickSound)
		end)
		ServersIcon:bindEvent('deselected', function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
			
			SoundsModule:AddSound(ClickSound)
		end)
		ServersIcon:setDropdown(ServersDropdown)
		shared.ServersIcon = ServersIcon
	end)
	
	
	task.wait(0.15)
	
	
	local ConfigIcon = Icon.new(true)
	ConfigIcon:setName("Config")
	ConfigIcon:setImage(3687980595)
	ConfigIcon:set("dropdownSquareCorners", true)
	ConfigIcon:set("dropdownMaxIconsBeforeScroll", 8)
	ConfigIcon:setEnabled(IsNotDuelsHub)
	ConfigIcon:bindEvent('selected', function()
		if shared.ServersIcon then
			shared.ServersIcon:deselect()
		end
		if shared.CharactersIcon then
			shared.CharactersIcon:deselect()
		end
		
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
		
		SoundsModule:AddSound(ClickSound)
	end)
	ConfigIcon:bindEvent('deselected', function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		
		SoundsModule:AddSound(ClickSound)
	end)
	
	
	local IsAdmin = Player:GetAttribute("isAdmin") or false
	local configDropdown = {
		Icon.new()
			:setName('Move_Buttons')
			:setLabel('Edit Button Positions')
			:setImage(notBoolId)
			:autoDeselect(true)
			:setEnabled(shared.IsMobile)
			:bindEvent("selected", function(icon)
				icon:deselect()
				
				SoundsModule:AddSound(ClickSound)

				local ChangingButtons = Character:FindFirstChild('ChangingButtons')
				if ChangingButtons then
					icon:setLabel("Edit Button Positions")

					ChangingButtons:Destroy()

					Comunicator:FireServer('SaveButtonsPos', {
						Dash = {
							ScaleX = JumpButton.Position.X.Scale - DashButton.Position.X.Scale,
							OffsetX = DashButton.Position.X.Offset - (JumpButton.Position.X.Offset + JumpButton.Size.X.Offset / 2),
							ScaleY = JumpButton.Position.Y.Scale - DashButton.Position.Y.Scale,
							OffsetY = DashButton.Position.Y.Offset - (JumpButton.Position.Y.Offset - (JumpButton.Size.Y.Offset / 2 + 7))
						},
						M1 = {
							ScaleX = JumpButton.Position.X.Scale - PunchButton.Position.X.Scale,
							OffsetX = PunchButton.Position.X.Offset - (JumpButton.Position.X.Offset + JumpButton.Size.X.Offset / 2),
							ScaleY = JumpButton.Position.Y.Scale - PunchButton.Position.Y.Scale,
							OffsetY = PunchButton.Position.Y.Offset - (JumpButton.Position.Y.Offset - 2.5 * (JumpButton.Size.Y.Offset / 2 + 7))
						},
						Block = {
							ScaleX = JumpButton.Position.X.Scale - BlockButton.Position.X.Scale,
							OffsetX = BlockButton.Position.X.Offset - (JumpButton.Position.X.Offset + JumpButton.Size.X.Offset / 2),
							ScaleY = JumpButton.Position.Y.Scale - BlockButton.Position.Y.Scale,
							OffsetY = BlockButton.Position.Y.Offset - (JumpButton.Position.Y.Offset - 4 * (JumpButton.Size.Y.Offset / 2 + 7))
						},
						Shiftlock = {
							ScaleX = JumpButton.Position.X.Scale - ShiftlockButton.Position.X.Scale,
							OffsetX = ShiftlockButton.Position.X.Offset - (JumpButton.Position.X.Offset - JumpButton.Size.X.Offset / 2),
							ScaleY = JumpButton.Position.Y.Scale - ShiftlockButton.Position.Y.Scale,
							OffsetY = ShiftlockButton.Position.Y.Offset - (JumpButton.Position.Y.Offset - 3.25 * (JumpButton.Size.Y.Offset / 2 + 7))
						}
					})

					return
				end

				icon:setLabel("Save Edits?")

				ChangingButtons = Instance.new('BoolValue')
				ChangingButtons.Name = 'ChangingButtons'
				ChangingButtons.Value = true
				ChangingButtons.Parent = Character
			end)
		;

		Icon.new()
			:setName('Reset_Buttons')
			:setLabel('Reset Button Positions')
			:setImage(notBoolId) -- done
			:autoDeselect(true)
			:setEnabled(shared.IsMobile)
			:bindEvent("selected", function(icon)
				icon:deselect()
				
				SoundsModule:AddSound(ClickSound)

				DashButton.Position      = UDim2.new(JumpButton.Position.X.Scale, JumpButton.Position.X.Offset + JumpButton.Size.X.Offset / 2, JumpButton.Position.Y.Scale, JumpButton.Position.Y.Offset - (JumpButton.Size.Y.Offset / 2 + 7))
				PunchButton.Position     = UDim2.new(JumpButton.Position.X.Scale, JumpButton.Position.X.Offset + JumpButton.Size.X.Offset / 2, JumpButton.Position.Y.Scale, JumpButton.Position.Y.Offset - 2.5 * (JumpButton.Size.Y.Offset / 2 + 7))
				BlockButton.Position     = UDim2.new(JumpButton.Position.X.Scale, JumpButton.Position.X.Offset + JumpButton.Size.X.Offset / 2, JumpButton.Position.Y.Scale, JumpButton.Position.Y.Offset - 4 * (JumpButton.Size.Y.Offset / 2 + 7))
				ShiftlockButton.Position = UDim2.new(JumpButton.Position.X.Scale, JumpButton.Position.X.Offset - JumpButton.Size.X.Offset / 2, JumpButton.Position.Y.Scale, JumpButton.Position.Y.Offset - 3.25 * (JumpButton.Size.Y.Offset / 2 + 7))

				Comunicator:FireServer('SaveButtonsPos', {
					Dash = {
						ScaleX = 0, 
						OffsetX = 0, 
						ScaleY = 0, 
						OffsetY = 0, 
						SizeMultiplier = DashButton:GetAttribute("SizeMultiplier")
					}, 
					M1 = {
						ScaleX = 0, 
						OffsetX = 0, 
						ScaleY = 0, 
						OffsetY = 0, 
						SizeMultiplier = PunchButton:GetAttribute("SizeMultiplier")
					}, 
					Block = {
						ScaleX = 0, 
						OffsetX = 0, 
						ScaleY = 0, 
						OffsetY = 0, 
						SizeMultiplier = BlockButton:GetAttribute("SizeMultiplier")
					}, 
					Shiftlock = {
						ScaleX = 0, 
						OffsetX = 0, 
						ScaleY = 0, 
						OffsetY = 0, 
						SizeMultiplier = ShiftlockButton:GetAttribute("SizeMultiplier")
					}
				})
			end)
		;

		Icon.new()
			:setName('DashButtonSize')
			:setLabel('Dash Button Size: '.. string.format("%.2f", math.clamp(DashButton and DashButton:GetAttribute("SizeMultiplier") or 1, 0.5, 2.5)) .. 'x')
			:setImage("rbxasset://textures/ui/Controls/TouchTapIcon.png")
			:autoDeselect(true)
			:setEnabled(shared.IsMobile)
			:bindEvent("selected", function(icon)
				icon:deselect()
				
				SoundsModule:AddSound(ClickSound)

				local NewSize = DashButton:GetAttribute("SizeMultiplier") + 0.25
				NewSize = NewSize > 2.5 and 0.5 or NewSize

				DashButton:SetAttribute("SizeMultiplier", NewSize)
				icon:setLabel('Dash Button Size: '.. string.format("%.2f", math.clamp(DashButton and DashButton:GetAttribute("SizeMultiplier") or 1, 0.5, 2.5)) .. 'x')
				Comunicator:FireServer("SaveButtonSize", { Button = "Dash", Size = NewSize })
			end)
		;

		Icon.new()
			:setName('PunchButtonSize')
			:setLabel('Punch Button Size: '.. string.format("%.2f", math.clamp(PunchButton and PunchButton:GetAttribute("SizeMultiplier") or 1, 0.5, 2.5)) .. 'x')
			:setImage("rbxasset://textures/ui/Controls/TouchTapIcon.png")
			:autoDeselect(true)
			:setEnabled(shared.IsMobile)
			:bindEvent("selected", function(icon)
				icon:deselect()
				
				SoundsModule:AddSound(ClickSound)

				local NewSize = PunchButton:GetAttribute("SizeMultiplier") + 0.25
				NewSize = NewSize > 2.5 and 0.5 or NewSize

				PunchButton:SetAttribute("SizeMultiplier", NewSize)
				icon:setLabel('Punch Button Size: '.. string.format("%.2f", math.clamp(PunchButton and PunchButton:GetAttribute("SizeMultiplier") or 1, 0.5, 2.5)) .. 'x')
				Comunicator:FireServer("SaveButtonSize", { Button = "Punch", Size = NewSize })
			end)
		;

		Icon.new()
			:setName('BlockButtonSize')
			:setLabel('Block Button Size: '.. string.format("%.2f", math.clamp(BlockButton and BlockButton:GetAttribute("SizeMultiplier") or 1, 0.5, 2.5)) .. 'x')
			:setImage("rbxasset://textures/ui/Controls/TouchTapIcon.png")
			:autoDeselect(true)
			:setEnabled(shared.IsMobile)
			:bindEvent("selected", function(icon)
				icon:deselect()
				
				SoundsModule:AddSound(ClickSound)

				local NewSize = BlockButton:GetAttribute("SizeMultiplier") + 0.25
				NewSize = NewSize > 2.5 and 0.5 or NewSize

				BlockButton:SetAttribute("SizeMultiplier", NewSize)
				icon:setLabel('Block Button Size: '.. string.format("%.2f", math.clamp(BlockButton and BlockButton:GetAttribute("SizeMultiplier") or 1, 0.5, 2.5)) .. 'x')
				Comunicator:FireServer("SaveButtonSize", { Button = "Block", Size = NewSize })
			end)
		;

		Icon.new()
			:setName('ShiftlockButtonSize')
			:setLabel('Shiftlock Button Size: '.. string.format("%.2f", math.clamp(ShiftlockButton and ShiftlockButton:GetAttribute("SizeMultiplier") or 1, 0.5, 2.5)) .. 'x')
			:setImage("rbxasset://textures/ui/Controls/TouchTapIcon.png")
			:autoDeselect(true)
			:setEnabled(shared.IsMobile)
			:bindEvent("selected", function(icon)
				icon:deselect()
				
				SoundsModule:AddSound(ClickSound)

				local NewSize = ShiftlockButton:GetAttribute("SizeMultiplier") + 0.25
				NewSize = NewSize > 2.5 and 0.5 or NewSize

				ShiftlockButton:SetAttribute("SizeMultiplier", NewSize)
				icon:setLabel('Shiftlock Button Size: '.. string.format("%.2f", math.clamp(ShiftlockButton and ShiftlockButton:GetAttribute("SizeMultiplier") or 1, 0.5, 2.5)) .. 'x')
				Comunicator:FireServer("SaveButtonSize", { Button = "Shiftlock", Size = NewSize })
			end)
		;

		Icon.new()
			:setName('ResetDashButtonSize')
			:setLabel('Reset Dash Button Size')
			:setImage("rbxasset://textures/ui/Controls/TouchTapIcon.png")
			:autoDeselect(true)
			:setEnabled(shared.IsMobile)
			:bindEvent("selected", function(icon)
				icon:deselect()
				
				SoundsModule:AddSound(ClickSound)

				DashButton:SetAttribute("SizeMultiplier", 1)
				Comunicator:FireServer("SaveButtonSize", { Button = "Dash", Size = 1 })
			end)
		;

		Icon.new()
			:setName('ResetPunchButtonSize')
			:setLabel('Reset Punch Button Size')
			:setImage("rbxasset://textures/ui/Controls/TouchTapIcon.png")
			:autoDeselect(true)
			:setEnabled(shared.IsMobile)
			:bindEvent("selected", function(icon)
				icon:deselect()
				
				SoundsModule:AddSound(ClickSound)

				PunchButton:SetAttribute("SizeMultiplier", 1)
				Comunicator:FireServer("SaveButtonSize", { Button = "Punch", Size = 1 })
			end)
		;

		Icon.new()
			:setName('ResetBlockButtonSize')
			:setLabel('Reset Block Button Size')
			:setImage("rbxasset://textures/ui/Controls/TouchTapIcon.png")
			:autoDeselect(true)
			:setEnabled(shared.IsMobile)
			:bindEvent("selected", function(icon)
				icon:deselect()

				SoundsModule:AddSound(ClickSound)

				BlockButton:SetAttribute("SizeMultiplier", 1)
				Comunicator:FireServer("SaveButtonSize", { Button = "Block", Size = 1 })
			end)
		;

		Icon.new()
			:setName('ResetShiftlockButtonSize')
			:setLabel('Reset Shiftlock Button Size')
			:setImage("rbxasset://textures/ui/Controls/TouchTapIcon.png")
			:autoDeselect(true)
			:setEnabled(shared.IsMobile)
			:bindEvent("selected", function(icon)
				icon:deselect()

				SoundsModule:AddSound(ClickSound)

				ShiftlockButton:SetAttribute("SizeMultiplier", 1)
				Comunicator:FireServer("SaveButtonSize", { Button = "Shiftlock", Size = 1 })
			end)
		;
		
		Icon.new()
			:setLabel('Update Log')
			:autoDeselect(true)
			:setImage(notBoolId)

			:bindEvent('selected', function(icon)
				icon:deselect()
				
				SoundsModule:AddSound(ClickSound)

				local CurrentValue = Player:GetAttribute("Changelogs")

				Comunicator:FireServer("UpdateSettings", { SettingName = "Changelogs", Value = CurrentValue })

				if CurrentValue == true then
					Player:SetAttribute("Changelogs", false)
				else
					Player:SetAttribute("Changelogs", true)
				end
			end)
		;

		Icon.new()
			:setLabel('Auto Activate')
			:setImage(getBoolConfigLabel('Auto Use'))
			:autoDeselect(true)

			:bindEvent('selected', function(icon)
				icon:deselect()

				if ConfigFolder['Auto Use'].Value == true then
					icon:setImage(RedSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Auto Use'; V = false })
				else
					icon:setImage(GreenSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Auto Use'; V = true })
				end

				SoundsModule:AddSound(ClickSound)
			end)
		;
		
		Icon.new()
			:setLabel('Remove Packages')
			:setImage(getBoolConfigLabel('Character Packages'))
			:autoDeselect(true)

			:bindEvent('selected', function(icon)
				icon:deselect()

				if ConfigFolder['Character Packages'].Value == true then
					icon:setImage(RedSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Character Packages'; V = false })
				else
					icon:setImage(GreenSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Character Packages'; V = true })

					for _,v in workspace.Live:GetDescendants() do
						if v:IsA("CharacterMesh") then
							v:Destroy()
						end
					end
				end

				SoundsModule:AddSound(ClickSound)
			end)
		;
		
		Icon.new()
			:setLabel('Fast Mode')
			:setName("FastMode")
			:setImage(getBoolConfigLabel('Fast Mode'))
			:autoDeselect(true)

			:bindEvent('selected', function(icon)
				icon:deselect()

				if ConfigFolder['Fast Mode'].Value == true then
					icon:setImage(RedSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Fast Mode'; V = false })
					
					WindShake:Init({ MatchWorkspaceWind = false })
				else
					icon:setImage(GreenSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Fast Mode'; V = true })

					WindShake:Cleanup()
					WindShake:Pause()

				end

				SoundsModule:AddSound(ClickSound)
			end)
		;
		
		Icon.new()
			:setLabel('Day Night Cicle')
			:setName("DayNightCicle")
			:setImage(getBoolConfigLabel('Day Night Cicle'))
			:autoDeselect(true)

			:bindEvent('selected', function(icon)
				icon:deselect()

				if ConfigFolder['Day Night Cicle'].Value == true then
					icon:setImage(RedSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Day Night Cicle'; V = false })
				else
					icon:setImage(GreenSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Day Night Cicle'; V = true })
				end

				SoundsModule:AddSound(ClickSound)
			end)
		;
		
		Icon.new()
			:setLabel('Auto Run')
			:setImage(getBoolConfigLabel('Auto Run'))
			:autoDeselect(true)

			:bindEvent('selected', function(icon)
				icon:deselect()

				if ConfigFolder['Auto Run'].Value == true then
					icon:setImage(RedSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Auto Run'; V = false })
				else
					icon:setImage(GreenSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Auto Run'; V = true })
				end

				SoundsModule:AddSound(ClickSound)
			end)
		;
		
		Icon.new()
			:setLabel('Awakening Music')
			:setImage(getBoolConfigLabel('Awakening Music'))
			:autoDeselect(true)

			:bindEvent('selected', function(icon)
				icon:deselect()

				if ConfigFolder['Awakening Music'].Value == true then
					icon:setImage(RedSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Awakening Music'; V = false })
				else
					icon:setImage(GreenSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Awakening Music'; V = true })
				end

				SoundsModule:AddSound(ClickSound)
			end)
		;
		
		Icon.new()
			:setLabel('Emote Music')
			:setName("EmoteMusic")
			:setImage(getBoolConfigLabel('Emote Music'))
			:autoDeselect(true)
			
			:bindEvent('selected', function(icon)
				icon:deselect()

				if ConfigFolder['Emote Music'].Value == true then
					icon:setImage(RedSquareId)
					
					game.SoundService["Emote Music"].Volume = 0
					
					Comunicator:FireServer('SetConfig', { CN = 'Emote Music'; V = false })
				else
					icon:setImage(GreenSquareId)
					
					game.SoundService["Emote Music"].Volume = 1
					
					Comunicator:FireServer('SetConfig', { CN = 'Emote Music'; V = true })
				end
				
				SoundsModule:AddSound(ClickSound)
			end)
		;

		Icon.new()
			:setLabel('Reduced Camera Shake')
			:setName("ReduceCamShake")
			:setImage(getBoolConfigLabel('Reduce Camera Shake'))
			:autoDeselect(true)

			:bindEvent('selected', function(icon)
				icon:deselect()

				if ConfigFolder['Reduce Camera Shake'].Value == true then
					icon:setImage(RedSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Reduce Camera Shake'; V = false })
				else
					icon:setImage(GreenSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Reduce Camera Shake'; V = true })
				end

				SoundsModule:AddSound(ClickSound)
			end)
		;

		Icon.new()
			:setLabel('Camera Shake')
			:setName("CameraShake")
			:setImage(getBoolConfigLabel('Camera Shake'))
			:autoDeselect(true)

			:bindEvent('selected', function(icon)
				icon:deselect()

				if ConfigFolder['Camera Shake'].Value == true then
					icon:setImage(RedSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Camera Shake'; V = false })
				else
					icon:setImage(GreenSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Camera Shake'; V = true })
				end

				SoundsModule:AddSound(ClickSound)
			end)
		;
		
		Icon.new()
			:setLabel('Destruction Physics')
			:setImage(getBoolConfigLabel('Destruction Physics'))
			:autoDeselect(true)

			:bindEvent('selected', function(icon)
				icon:deselect()

				if ConfigFolder['Destruction Physics'].Value == true then
					icon:setImage(RedSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Destruction Physics'; V = false })
				else
					icon:setImage(GreenSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Destruction Physics'; V = true })
				end

				SoundsModule:AddSound(ClickSound)
			end)
		;

		Icon.new()
			:setLabel('Blood')
			:setName("Blood")
			:setImage(getBoolConfigLabel('Blood'))
			:autoDeselect(true)

			:bindEvent('selected', function(icon)
				icon:deselect()

				if ConfigFolder['Blood'].Value == true then
					icon:setImage(RedSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Blood'; V = false })
				else
					icon:setImage(GreenSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Blood'; V = true })
				end

				SoundsModule:AddSound(ClickSound)
			end)
		;
		
		Icon.new()
			:setLabel('Hide Gold')
			:setImage(getBoolConfigLabel('Hide Gold'))
			:autoDeselect(true)
			:bindEvent('selected', function(icon)
				icon:deselect()

				if ConfigFolder['Hide Gold'].Value == true then
					icon:setImage(RedSquareId)
					
					Comunicator:FireServer('SetConfig', { CN = 'Hide Gold'; V = false })
				else
					icon:setImage(GreenSquareId)
					
					Comunicator:FireServer('SetConfig', { CN = 'Hide Gold'; V = true })
				end
				
				SoundsModule:AddSound(ClickSound)
			end)
		;
		
		Icon.new()
			:setLabel('Console Controls')
			:setImage(getBoolConfigLabel('Show Console Controls'))
			:setEnabled(UIS.GamepadEnabled == true)
			:autoDeselect(true)
			:bindEvent('selected', function(icon)
				icon:deselect()

				if ConfigFolder['Show Console Controls'].Value == true then
					icon:setImage(RedSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Show Console Controls'; V = false })
					
					ConsoleControls.Visible = false
				else
					icon:setImage(GreenSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Show Console Controls'; V = true })
					
					ConsoleControls.Visible = true
				end

				SoundsModule:AddSound(ClickSound)
			end)
		;

		Icon.new()
			:setLabel('Sound Volume: x'.. string.format("%.1f", math.clamp(ConfigFolder.Volume.Value, .1, 1)))
			:setImage(notBoolId)
			:set("forcedIconSizeX", 32)
			:set("forcedIconSizeY", 32)
			:set("iconSize", UDim2.new(0, 32, 0, 32))
			:set("iconImageRatio", 0.6)
			:autoDeselect(true)

			:bindEvent("selected", function(icon)
				icon:deselect()
				
				SoundsModule:AddSound(ClickSound)

				local newVolume = ConfigFolder.Volume.Value + 0.1
				if 1 < newVolume then
					newVolume = 0.1
				elseif newVolume <= 0 then
					newVolume = 1
				end


				local volumeString = string.format("%.1f", math.clamp(newVolume, .1, 1))
				newVolume = tonumber(volumeString)

				game.SoundService.Sounds.Volume = newVolume
				icon:setLabel('Sound Volume: x'..volumeString)
				Comunicator:FireServer('SetConfig', { CN = 'Volume'; V = newVolume })
			end)
		;
		
		Icon.new()
			:setLabel('Shiftlock Offset: '.. ConfigFolder["Shiftlock Offset"].Value .. ' Studs')
			:setName("ShiftlockOffset")
			:autoDeselect(true)
			:bindEvent("selected", function(icon)
				icon:deselect()

				SoundsModule:AddSound(ClickSound)

				local newOffset = math.round((ConfigFolder["Shiftlock Offset"].Value + 0.05) * 100) / 100
				if newOffset > 5.5 then
					newOffset = 0
				end

				icon:setLabel('Shiftlock Offset: '.. tostring(newOffset) .. ' Studs')
				Comunicator:FireServer('SetConfig', { CN = 'Shiftlock Offset'; V = newOffset })
			end)
		;

		Icon.new()
			:setLabel('Reset Shiftlock Offset')
			:autoDeselect(true)
			:setImage(notBoolId)
			:bindEvent("selected", function(icon)
				icon:deselect()

				SoundsModule:AddSound(ClickSound)

				local newOffset = math.round(1.75 * 100) / 100
				local ShiftlockOffsetIcon = PlayerGui.TopbarPlus.TopbarContainer.Config.DropdownContainer.DropdownFrame:FindFirstChild("ShiftlockOffset")
				if ShiftlockOffsetIcon then
					ShiftlockOffsetIcon.IconButton.IconLabel.Text = 'Shiftlock Offset: 1.75 Studs'
				end
				Comunicator:FireServer('SetConfig', { CN = 'Shiftlock Offset'; V = newOffset })
			end)
		;
		
		Icon.new()
			:setLabel('Customize Kill Sound')
			:setImage(notBoolId)
			:autoDeselect(true)
			:set("iconTextColor", Color3.new(1, 0.882353, 0))
			:bindEvent("selected", function(icon)
				icon:deselect()

				SoundsModule:AddSound(ClickSound)
				
				local CurrentValue = Player:GetAttribute("CustomizeKillSound")

				if Player:GetAttribute("HasVIP") then
					Comunicator:FireServer("UpdateSettings", { SettingName = "CustomizeKillSound", Value = CurrentValue })
				else
					MarketService:PromptGamePassPurchase(Passes.VIP)
				end

				if CurrentValue == true then
					Player:SetAttribute("CustomizeKillSound", false)
				else
					Player:SetAttribute("CustomizeKillSound", true)
				end
			end)
		;

		Icon.new()
			:setLabel('Customize Awakening Outfit')
			:setImage(notBoolId)
			:autoDeselect(true)
			:set("iconTextColor", Color3.new(1, 0.882353, 0))
			:bindEvent("selected", function(icon)
				icon:deselect()

				SoundsModule:AddSound(ClickSound)

				local CurrentValue = Player:GetAttribute("CustomizeAwakeningOutfit")

				if Player:GetAttribute("HasVIP") then
					Comunicator:FireServer("UpdateSettings", { SettingName = "CustomizeAwakeningOutfit", Value = CurrentValue })
				else
					MarketService:PromptGamePassPurchase(Passes.VIP)
				end

				if CurrentValue == true then
					Player:SetAttribute("CustomizeAwakeningOutfit", false)
				else
					Player:SetAttribute("CustomizeAwakeningOutfit", true)
				end
			end)
		;
		
		Icon.new()
			:setLabel('Customize VIP Cape')
			:setImage(notBoolId)
			:autoDeselect(true)
			:set("iconTextColor", Color3.new(1, 0.882353, 0))
			:bindEvent("selected", function(icon)
				icon:deselect()

				SoundsModule:AddSound(ClickSound)
				
				local CurrentValue = Player:GetAttribute("CustomizeVIPCape")
				
				if Player:GetAttribute("HasVIP") then
					Comunicator:FireServer("UpdateSettings", { SettingName = "CustomizeVIPCape", Value = CurrentValue })
				else
					MarketService:PromptGamePassPurchase(Passes.VIP)
				end
				
				if CurrentValue == true then
					Player:SetAttribute("CustomizeVIPCape", false)
				else
					Player:SetAttribute("CustomizeVIPCape", true)
				end
			end)
		;

		Icon.new()
			:setLabel('Hide Kills')
			:setImage(getBoolConfigLabel('Hide Kills'))
			:autoDeselect(true)
			:set("iconTextColor", Color3.new(1, 0.882353, 0))
			:bindEvent('selected', function(icon)
				icon:deselect()

				if not Player:GetAttribute("HasVIP") then
					return MarketService:PromptGamePassPurchase(Passes.VIP)
				end

				if ConfigFolder['Hide Kills'].Value == true then
					icon:setImage(RedSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Hide Kills'; V = false })
				else
					icon:setImage(GreenSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Hide Kills'; V = true })
				end

				SoundsModule:AddSound(ClickSound)
			end)
		;

		Icon.new()
			:setLabel('Hide Killstreak')
			:setImage(getBoolConfigLabel('Hide Killstreak'))
			:autoDeselect(true)
			:set("iconTextColor", Color3.new(1, 0.882353, 0))
			:bindEvent('selected', function(icon)
				icon:deselect()

				SoundsModule:AddSound(ClickSound)

				if not Player:GetAttribute("HasVIP") then
					return MarketService:PromptGamePassPurchase(Player, Passes.VIP)
				end

				if ConfigFolder['Hide Killstreak'].Value == true then
					icon:setImage(RedSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Hide Killstreak'; V = false })
				else
					icon:setImage(GreenSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Hide Killstreak'; V = true })
				end
			end)
		;

		Icon.new()
			:setLabel('Hide VIP Join Message')
			:setImage(getBoolConfigLabel('Hide VIP Join Message'))
			:autoDeselect(true)
			:set("iconTextColor", Color3.new(1, 0.882353, 0))
			:bindEvent('selected', function(icon)
				icon:deselect()

				if not Player:GetAttribute("HasVIP") then
					return MarketService:PromptGamePassPurchase(Passes.VIP)
				end

				if ConfigFolder['Hide VIP Join Message'].Value == true then
					icon:setImage(RedSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Hide VIP Join Message'; V = false })
				else
					icon:setImage(GreenSquareId)

					Comunicator:FireServer('SetConfig', { CN = 'Hide VIP Join Message'; V = true })
				end

				SoundsModule:AddSound(ClickSound)
			end)
		;

		Icon.new()
			:setName("Market")

			:set("iconFont", Enum.Font.GothamBold)
			
			:setLabel('[-] ' .. "Market")
			:autoDeselect(true)
			:set("iconTextColor", Color3.new(1, 0.882353, 0))
			:bindEvent('selected', function(icon)
				icon:deselect()

				SoundsModule:AddSound(ClickSound)
			end)
		;

		Icon.new()
			:setLabel('Purchase VIP: 6000 Gold')
			:setImage(notBoolId)
			:autoDeselect(true)
			:set("iconTextColor", Color3.new(1, 0.882353, 0))
			:bindEvent('selected', function(icon)
				icon:deselect()

				SoundsModule:AddSound(ClickSound)

				Comunicator:FireServer('BuyVIP')
			end)
		;

		Icon.new()
			:setLabel('Unlock The Frozen Soul: 3500 Gold')
			:setImage(notBoolId)
			:autoDeselect(true)
			:set("iconTextColor", Color3.new(1, 0.882353, 0))
			:bindEvent('selected', function(icon)
				icon:deselect()

				SoundsModule:AddSound(ClickSound)

				Comunicator:FireServer('UnlockQuestMoveset')
			end)
		;
	}


	task.spawn(function()
		ConfigIcon:set('dropdownMaxIconsBeforeScroll', 8)
		
		for Index, Icon in configDropdown do
			Icon:setOrder(Index - #configDropdown)
			
			Icon:set("forcedIconSizeX", 32)
			Icon:set("forcedIconSizeY", 32)
			Icon:set("iconSize", UDim2.new(0, 32, 0, 32))
			Icon:set("iconImageRatio", 0.6)
		end
	end)
	
	
	task.wait()
	
	
	if Getter:InvokeServer('IsPSOwner') == true and game.PlaceId ~= workspace:GetAttribute("DuelsPlaceId") then
		local MenuSize = 8

		local CategoryChildNames = {
			{
				"Private Server +",
				'Mode',
				'MenuSize'
			},

			{
				"General",
				'Counter',
				"Godmode",
				'Heal',
				'Respawn',
				'Kill',
				'Bring',
				'Ragdoll'
			},

			{
				"Dummies",
				'SpawnDummy',
				'SpawnAttackingDummy',
				'SpawnBlockingDummy',
				'SpawnCounteringDummy',
				'SpawnFinisherDummy',
				'ClearDummies'
			},

			{
				"Toggles",
				"TpDash",
				"NoRespawn",
				"NoDashCD",
				"NoMovement",
				'NoAttack',
				'NoCooldown',
				"NoRagdoll",
				"NoFatigue",
				'NoStun',
				"NoBlock",
				"NoReset"
			},

			{
				"Awakening",
				'GiveAwk',
				'RemoveAwk',
				"ActivateAwk",
				'InfiniteAwk',
				"InstantAwk",
				"NoAwk"
			},

			{
				"Multipliers",
				"AttackSMult",
				"HealthMult",
				"DamageMult",
				"RegenMult",
				"SpeedMult",
				"GravityMult"
			},

			{
				"Moveset",
				"RandomMoveset",
				"DualMoveset",
				"OnlyFinishers"
			},

			{
				"Map",
				"BuildMode",
				"HideMap"
			},

			{
				"Misc",
				"StormActive",
				"ResetStorm",
				"StormSpeedMultiplier",
				"StormDamageMultiplier"
			},

			{
				"Server",
				"LockServer",
				"KickOnDeath",
				"ShutdownServer",
				"RefreshServer"
			}
		}

		local PSIcons = {
			GravityMult = Icon.new()
				:setLabel('Gravity Multiplier: ' .. string.format("%.1f", math.clamp(workspace.Configuration.GravityMult.Value, 0, 10)) .. "x")
				:setImage(notBoolId)
				
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				
				:autoDeselect(true)
				
				:bindEvent("selected", function(icon)
					icon:deselect()

					if not Cons['GravityMult'] then
						Cons['GravityMult'] = workspace.Configuration.GravityMult:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setLabel('Gravity Multiplier: ' .. string.format("%.1f", math.clamp(workspace.Configuration.GravityMult.Value, 0, 10)) .. "x")
						end)
					end


					PSE:FireServer('GravityMult')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			SpeedMult = Icon.new()
				:setLabel('Speed Multiplier: ' .. string.format("%.1f", math.clamp(workspace.Configuration.SpeedMult.Value, 0, 10)) .. "x")
				:setImage(notBoolId)

				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)

				:autoDeselect(true)
				
				:bindEvent("selected", function(icon)
					icon:deselect()

					if not Cons['SpeedMult'] then
						Cons['SpeedMult'] = workspace.Configuration.SpeedMult:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setLabel('Speed Multiplier: ' .. string.format("%.1f", math.clamp(workspace.Configuration.SpeedMult.Value, 0, 10)) .. "x")
						end)
					end


					PSE:FireServer('SpeedMult')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			RegenMult = Icon.new()
				:setLabel('Regen Multiplier: ' .. string.format("%.1f", math.clamp(workspace.Configuration.RegenMult.Value, 0, 10)) .. "x")
				:setImage(notBoolId)

				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)

				:autoDeselect(true)
				
				:bindEvent("selected", function(icon)
					icon:deselect()

					if not Cons['RegenMult'] then
						Cons['RegenMult'] = workspace.Configuration.RegenMult:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setLabel('Regen Multiplier: ' .. string.format("%.1f", math.clamp(workspace.Configuration.RegenMult.Value, 0, 10)) .. "x")
						end)
					end


					PSE:FireServer('RegenMult')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			DamageMult = Icon.new()
				:setLabel('Damage Multiplier: ' .. string.format("%.1f", math.clamp(workspace.Configuration.DamageMult.Value, 0, 10)) .. "x")
				:setImage(notBoolId)

				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)

				:autoDeselect(true)
				
				:bindEvent("selected", function(icon)
					icon:deselect()

					if not Cons['DamageMult'] then
						Cons['DamageMult'] = workspace.Configuration.DamageMult:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setLabel('Damage Multiplier: ' .. string.format("%.1f", math.clamp(workspace.Configuration.DamageMult.Value, 0, 10)) .. "x")
						end)
					end


					PSE:FireServer('DamageMult')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			HealthMult = Icon.new()
				:setLabel('Health Multiplier: ' .. string.format("%.1f", math.clamp(workspace.Configuration.HealthMult.Value, 0, 10)) .. "x")
				:setImage(notBoolId)

				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)

				:autoDeselect(true)
				
				:bindEvent("selected", function(icon)
					icon:deselect()

					if not Cons['HealthMult'] then
						Cons['HealthMult'] = workspace.Configuration.HealthMult:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setLabel('Health Multiplier: ' .. string.format("%.1f", math.clamp(workspace.Configuration.HealthMult.Value, 0, 10)) .. "x")
						end)
					end


					PSE:FireServer('HealthMult')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			AttackSMult = Icon.new()
				:setLabel('Attack Speed Multiplier: ' .. string.format("%.1f", math.clamp(workspace.Configuration.AttackSMult.Value, 0, 10)) .. "x")
				:setImage(notBoolId)

				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)

				:autoDeselect(true)
				
				:bindEvent("selected", function(icon)
					icon:deselect()

					if not Cons['AttackSMult'] then
						Cons['AttackSMult'] = workspace.Configuration.AttackSMult:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setLabel('Attack Speed Multiplier: ' .. string.format("%.1f", math.clamp(workspace.Configuration.AttackSMult.Value, 0, 10)) .. "x")
						end)
					end


					PSE:FireServer('AttackSMult')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			StormDamageMultiplier = Icon.new()
				:setLabel('Storm Damage Multiplier: ' .. string.format("%.1f", math.clamp(workspace.Configuration.StormDamageMultiplier.Value, 0, 10)) .. "x")
				:setImage(notBoolId)

				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)

				:autoDeselect(true)
				
				:bindEvent("selected", function(icon)
					icon:deselect()

					if not Cons['StormDamageMultiplier'] then
						Cons['StormDamageMultiplier'] = workspace.Configuration.StormDamageMultiplier:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setLabel('Storm Damage Multiplier: ' .. string.format("%.1f", math.clamp(workspace.Configuration.StormDamageMultiplier.Value, 0, 10)) .. "x")
						end)
					end


					PSE:FireServer('StormDamageMultiplier')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			StormSpeedMultiplier = Icon.new()
				:setLabel('Storm Speed Multiplier: ' .. string.format("%.1f", math.clamp(workspace.Configuration.StormSpeedMultiplier.Value, 0, 10)) .. "x")
				:setImage(notBoolId)

				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)

				:autoDeselect(true)
				
				:bindEvent("selected", function(icon)
					icon:deselect()

					if not Cons['StormSpeedMultiplier'] then
						Cons['StormSpeedMultiplier'] = workspace.Configuration.StormSpeedMultiplier:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setLabel('Storm Speed Multiplier: ' .. string.format("%.1f", math.clamp(workspace.Configuration.StormSpeedMultiplier.Value, 0, 10)) .. "x")
						end)
					end


					PSE:FireServer('StormSpeedMultiplier')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			ResetStorm = Icon.new()
				:setName('ResetStorm')
				:setLabel('Reset Storm')
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					PSE:FireServer('ResetStorm')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			StormActive = Icon.new()
				:setName('StormActive')
				:setLabel('Storm Active')
				:setImage(getPSBoolImg('StormActive', workspace.Configuration))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['StormActive'] then
						Cons['StormActive'] = workspace.Configuration.StormActive:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('StormActive', workspace.Configuration))
						end)
					end


					PSE:FireServer('StormActive')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			RefreshServer = Icon.new()
				:setName('RefreshServer')
				:setLabel('Refresh Server')
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					PSE:FireServer('RefreshServer')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			ShutdownServer = Icon.new()
				:setName('ShutdownServer')
				:setLabel('Shutdown Server')
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					PSE:FireServer('ShutdownServer')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			KickOnDeath = Icon.new()
				:setName('KickOnDeath')
				:setLabel('Kick On Death')
				:setImage(getPSBoolImg('KickOnDeath', workspace.Configuration))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['KickOnDeath'] then
						Cons['KickOnDeath'] = workspace.Configuration.KickOnDeath:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('KickOnDeath', workspace.Configuration))
						end)
					end


					PSE:FireServer('KickOnDeath')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			LockServer = Icon.new()
				:setName('LockServer')
				:setLabel('Lock Server')
				:setImage(getPSBoolImg('LockServer', workspace.Configuration))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['LockServer'] then
						Cons['LockServer'] = workspace.Configuration.LockServer:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('LockServer', workspace.Configuration))
						end)
					end


					PSE:FireServer('LockServer')


					SoundsModule:AddSound(ClickSound)
				end)
			;
			
			BuildMode = Icon.new()
				:setName('BuildMode')
				:setLabel('Build Mode')
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['BuildMode'] then
						Cons['BuildMode'] = PSCfgFolder.BuildMode:GetPropertyChangedSignal('Value'):Connect(function()
							if PSCfgFolder.BuildMode.Value == true then
								shared.buildmode()
							else
								shared.nobuildmode()
							end
						end)
					end

					PSCfgFolder.BuildMode.Value = not PSCfgFolder.BuildMode.Value

					SoundsModule:AddSound(ClickSound)
				end)
			;

			HideMap = Icon.new()
				:setName('HideMap')
				:setLabel('Hide Map')
				:setImage(getPSBoolImg('HideMap', workspace.Configuration))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['HideMap'] then
						Cons['HideMap'] = workspace.Configuration.HideMap:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('HideMap', workspace.Configuration))


							local CurrGuiValue = not workspace.Configuration.HideMap.Value

							PlayerGui.Donations.Enabled = CurrGuiValue
							workspace.Miscellaneous.Donations.a.SurfaceGui.Enabled = CurrGuiValue
							workspace.Miscellaneous.Kills.a.SurfaceGui.Enabled = CurrGuiValue
							workspace.Miscellaneous.TotalKills.a.SurfaceGui.Enabled = CurrGuiValue
						end)
					end


					PSE:FireServer('HideMap')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			RandomMoveset = Icon.new()
				:setName('RandomMoveset')
				:setLabel('Random Moveset')
				:setImage(getPSBoolImg('RandomMoveset'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['RandomMoveset'] then
						Cons['RandomMoveset'] = PSCfgFolder.RandomMoveset:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('RandomMoveset'))
						end)
					end


					PSE:FireServer('RandomMoveset')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			DualMoveset = Icon.new()
				:setName('DualMoveset')
				:setLabel('Dual Moveset')
				:setImage(getPSBoolImg('DualMoveset'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['DualMoveset'] then
						Cons['DualMoveset'] = PSCfgFolder.DualMoveset:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('DualMoveset'))
						end)
					end


					PSE:FireServer('DualMoveset')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			Mode = Icon.new()
				:setName('Mode')
				:setLabel('Mode: '..getConfigValue('Mode'))
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['Mode'] then
						Cons['Mode'] = PSCfgFolder.Mode:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setLabel('Mode: '..getConfigValue('Mode'))
						end)
					end


					PSE:FireServer('Mode')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			MenuSize = Icon.new()
				:setName('MenuSize')
				:setLabel('Menu Size: '..tostring(MenuSize))
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					MenuSize += 4

					if MenuSize > 24 then
						MenuSize = 8
					end

					ConfigIcon:set('dropdownMaxIconsBeforeScroll', MenuSize)
					icon:setLabel('Menu Size: '..tostring(MenuSize))


					SoundsModule:AddSound(ClickSound)
				end)
			;

			TpDash = Icon.new()
				:setName('TpDash')
				:setLabel('Teleport Dash')
				:setImage(getPSBoolImg('TpDash'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['TpDash'] then
						Cons['TpDash'] = PSCfgFolder.TpDash:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('TpDash'))
						end)
					end


					PSE:FireServer('TpDash')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			NoRespawn = Icon.new()
				:setName('NoRespawn')
				:setLabel('No Respawn')
				:setImage(getPSBoolImg('NoRespawn'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['NoRespawn'] then
						Cons['NoRespawn'] = PSCfgFolder.NoRespawn:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('NoRespawn'))
						end)
					end


					PSE:FireServer('NoRespawn')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			NoMovement = Icon.new()
				:setName('NoMovement')
				:setLabel('No Movement')
				:setImage(getPSBoolImg('NoMovement'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['NoMovement'] then
						Cons['NoMovement'] = PSCfgFolder.NoMovement:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('NoMovement'))
						end)
					end


					PSE:FireServer('NoMovement')


					SoundsModule:AddSound(ClickSound)
				end)
			;
			
			NoAttack = Icon.new()
				:setName('NoAttack')
				:setLabel('No Attack')
				:setImage(getPSBoolImg('NoAttack'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['NoAttack'] then
						Cons['NoAttack'] = PSCfgFolder.NoAttack:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('NoAttack'))
						end)
					end

					PSE:FireServer('NoAttack')

					SoundsModule:AddSound(ClickSound)
				end)
			;
			
			NoCooldown = Icon.new()
				:setName('NoCooldown')
				:setLabel('No Cooldowns')
				:setImage(getPSBoolImg('NoCooldown'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['NCDS'] then
						Cons['NCDS'] = PSCfgFolder.NoCooldown:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('NoCooldown'))
						end)
					end


					PSE:FireServer('NoCooldown')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			NoRagdoll = Icon.new()
				:setName('NoRagdoll')
				:setLabel('No Ragdoll')
				:setImage(getPSBoolImg('NoRagdoll'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['NoRagdoll'] then
						Cons['NoRagdoll'] = PSCfgFolder.NoRagdoll:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('NoRagdoll'))
						end)
					end


					PSE:FireServer('NoRagdoll')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			NoDashCD = Icon.new()
				:setName('NoDashCD')
				:setLabel('No Dash Cooldowns')
				:setImage(getPSBoolImg('NoDashCD'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['NDCDS'] then
						Cons['NDCDS'] = PSCfgFolder.NoDashCD:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('NoDashCD'))
						end)
					end


					PSE:FireServer('NoDashCD')


					SoundsModule:AddSound(ClickSound)
				end)
			;

			NoStun = Icon.new()
				:setName('NoStun')
				:setLabel('No Stun')
				:setImage(getPSBoolImg('NoStun'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['STN'] then
						Cons['STN'] = PSCfgFolder.NoStun:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('NoStun'))
						end)
					end

					PSE:FireServer('NoStun')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			NoBlock = Icon.new()
				:setName('NoBlock')
				:setLabel('No Block')
				:setImage(getPSBoolImg('NoBlock'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['NoBlock'] then
						Cons['NoBlock'] = PSCfgFolder.NoBlock:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('NoBlock'))
						end)
					end

					PSE:FireServer('NoBlock')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			NoReset = Icon.new()
				:setName('NoReset')
				:setLabel('No Reset')
				:setImage(getPSBoolImg('NoReset'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['NoReset'] then
						Cons['NoReset'] = PSCfgFolder.NoReset:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('NoReset'))
						end)
					end

					PSE:FireServer('NoReset')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			NoFatigue = Icon.new()
				:setName('NoFatigue')
				:setLabel('No Fatigue')
				:setImage(getPSBoolImg('NoFatigue'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['NFG'] then
						Cons['NFG'] = PSCfgFolder.NoFatigue:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('NoFatigue'))
						end)
					end

					PSE:FireServer('NoFatigue')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			OnlyFinishers = Icon.new()
				:setName('OnlyFinishers')
				:setLabel('Finishers Only')
				:setImage(getPSBoolImg('OnlyFinishers'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['OnlyFinishers'] then
						Cons['OnlyFinishers'] = PSCfgFolder.OnlyFinishers:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('OnlyFinishers'))
						end)
					end

					PSE:FireServer('OnlyFinishers')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			GiveAwk = Icon.new()
				:setName('GiveAwk')
				:setLabel('Give Awakening')
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					PSE:FireServer('GiveAwk')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			RemoveAwk = Icon.new()
				:setName('RemoveAwk')
				:setLabel('Remove Awakening')
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					PSE:FireServer('RemoveAwk')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			ActivateAwk = Icon.new()
				:setName('ActivateAwk')
				:setLabel('Activate Awakening')
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					PSE:FireServer('ActivateAwk')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			InfiniteAwk = Icon.new()
				:setName('InfiniteAwk')
				:setLabel('Infinite Awakening')
				:setImage(getPSBoolImg('InfiniteAwk'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['INFAWK'] then
						Cons['INFAWK'] = PSCfgFolder.InfiniteAwk:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('InfiniteAwk'))
						end)
					end

					PSE:FireServer('InfiniteAwk')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			InstantAwk = Icon.new()
				:setName('InstantAwk')
				:setLabel('Instant Awakening')
				:setImage(getPSBoolImg('InstantAwk'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['InstantAwk'] then
						Cons['InstantAwk'] = PSCfgFolder.InstantAwk:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('InstantAwk'))
						end)
					end

					PSE:FireServer('InstantAwk')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			NoAwk = Icon.new()
				:setName('NoAwk')
				:setLabel('No Awakening')
				:setImage(getPSBoolImg('NoAwk'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['NoAwk'] then
						Cons['NoAwk'] = PSCfgFolder.NoAwk:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('NoAwk'))
						end)
					end

					PSE:FireServer('NoAwk')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			Counter = Icon.new()
				:setName('Counter')
				:setLabel('Activate Counter')
				:setImage(getPSBoolImg('Counter'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['CNTR'] then
						Cons['CNTR'] = PSCfgFolder.Counter:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('Counter'))
						end)
					end

					PSE:FireServer('Counter')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			Godmode = Icon.new()
				:setName('Godmode')
				:setLabel('Godmode')
				:setImage(getPSBoolImg('Godmode'))
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					if not Cons['Godmode'] then
						Cons['Godmode'] = PSCfgFolder.Godmode:GetPropertyChangedSignal('Value'):Connect(function()
							icon:setImage(getPSBoolImg('Godmode'))
						end)
					end

					PSE:FireServer('Godmode')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			Heal = Icon.new()
				:setName('Heal')
				:setLabel('Heal')
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					PSE:FireServer('Heal')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			Respawn = Icon.new()
				:setName('Respawn')
				:setLabel('Respawn')
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					PSE:FireServer('Respawn')

					SoundsModule:AddSound(ClickSound)
				end)
			;
			
			Bring = Icon.new()
				:setName('Bring')
				:setLabel('Bring')
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					PSE:FireServer('Bring')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			Kill = Icon.new()
				:setName('Kill')
				:setLabel('Kill')
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					PSE:FireServer('Kill')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			Ragdoll = Icon.new()
				:setName('Ragdoll')
				:setLabel('Ragdoll')
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					PSE:FireServer('Ragdoll')

					SoundsModule:AddSound(ClickSound)
				end)
			;

			SpawnDummy = Icon.new()
				:setName('SpawnDummy')
				:setLabel('Spawn Dummy')
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					PSE:FireServer('SpawnDummy', { InitialHp = nil; ScriptName = nil })

					SoundsModule:AddSound(ClickSound)
				end)
			;

			SpawnAttackingDummy = Icon.new()
				:setName('SpawnAttackingDummy')
				:setLabel('Spawn Attacking Dummy')
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					PSE:FireServer('SpawnDummy', { InitialHp = nil, ScriptName = 'AttackScript' })

					SoundsModule:AddSound(ClickSound)
				end)
			;

			SpawnBlockingDummy = Icon.new()
				:setName('SpawnBlockingDummy')
				:setLabel('Spawn Blocking Dummy')
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					PSE:FireServer('SpawnDummy', { InitialHp = nil, ScriptName = 'BlockScript' })

					SoundsModule:AddSound(ClickSound)
				end)
			;

			SpawnCounteringDummy = Icon.new()
				:setName('SpawnCounteringDummy')
				:setLabel('Spawn Countering Dummy')
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					PSE:FireServer('SpawnDummy', { InitialHp = nil, ScriptName = 'CounterScript' })

					SoundsModule:AddSound(ClickSound)
				end)
			;

			SpawnFinisherDummy = Icon.new()
				:setName('SpawnFinisherDummy')
				:setLabel('Spawn Finisher Dummy')
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					PSE:FireServer('SpawnDummy', { InitialHp = 1; ScriptName = nil })

					SoundsModule:AddSound(ClickSound)
				end)
			;

			ClearDummies = Icon.new()
				:setName('ClearDummies')
				:setLabel('Clear Dummies')
				:setImage(notBoolId)
				:autoDeselect(true)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				:bindEvent('selected', function(icon)
					icon:deselect()

					PSE:FireServer('ClearDummies')

					SoundsModule:AddSound(ClickSound)
				end)
			;
		}


		local function toggleCategory(CategoryName, State)
			for _,v in CategoryChildNames do
				if v[1] ~= CategoryName then continue end

				for i, vv in v do
					if i == 1 then continue end

					PSIcons[vv]:setEnabled(State)
				end
			end
		end

		local CategoryIcons = {}
		local CategoryStates = {}


		local AddedIcons = 0
		for _, Parameters in CategoryChildNames do
			AddedIcons += 1


			local CategoryName = Parameters[1]
			CategoryStates[CategoryName] = true

			local Icon = Icon.new()
				:setName(CategoryName)

				:set("iconFont", Enum.Font.GothamBold)
				:set("forcedIconSizeX", 32)
				:set("forcedIconSizeY", 32)
				:set("iconSize", UDim2.new(0, 32, 0, 32))
				:set("iconImageRatio", 0.6)
				
				:setLabel('[-] ' .. CategoryName:upper())
				:autoDeselect(true)

				:bindEvent('selected', function(icon)
					icon:deselect()

					CategoryStates[CategoryName] = not CategoryStates[CategoryName]

					toggleCategory(CategoryName, CategoryStates[CategoryName])
					icon:setLabel("[" .. (CategoryStates[CategoryName] == false and "+" or "-") .. "] " .. CategoryName:upper())

					SoundsModule:AddSound(ClickSound)
				end)
			;

			CategoryIcons[CategoryName] = Icon


			CategoryIcons[Parameters[1]]:setOrder(AddedIcons)

			for ParameterIndex, ParameterName in Parameters do
				if ParameterIndex == 1 then continue end
				AddedIcons += 1

				PSIcons[ParameterName]:setOrder(AddedIcons)
			end
		end


		for _,v in CategoryIcons do
			table.insert(configDropdown, v)
		end

		for _,v in PSIcons do
			table.insert(configDropdown, v)
		end
	end

	ConfigIcon:setDropdown(configDropdown)
	shared.SettingsIcon = ConfigIcon
	
	
	task.wait(0.15)
	
	
	local EmoteIcon = Icon.new(true)
	EmoteIcon:setName('Emotes')
	EmoteIcon:setImage(13715869387)
	EmoteIcon:autoDeselect(true)
	EmoteIcon:bindEvent('selected', function()
		EmoteIcon:deselect()
		
		SoundsModule:AddSound(ClickSound)
		
		if shared.emotegui then
			shared.emotegui()
		end
	end)
	
	
	task.wait(0.15)
	
	
	local CosmeticsIcon = Icon.new(true)
	CosmeticsIcon:setEnabled(IsNotDuels)
	CosmeticsIcon:setName('Cosmetics')
	CosmeticsIcon:setImage(12291352118)
	CosmeticsIcon:autoDeselect(true)
	CosmeticsIcon:bindEvent('selected', function()
		CosmeticsIcon:deselect()

		SoundsModule:AddSound(ClickSound)

		if shared.cosgui then
			shared.cosgui()
		end
	end)
	
	
	task.wait(0.15)
	

	local GiftIcon = Icon.new(true)
	GiftIcon:setName("Gifting")
	GiftIcon:setImage(14471730934)
	GiftIcon:autoDeselect(true)
	GiftIcon:bindEvent('selected', function()
		GiftIcon:deselect()
		
		SoundsModule:AddSound(ClickSound)
		
		if shared.giftgui then
			shared.giftgui()
		end
	end)
	
	
	if not IsAdmin then
		Player:GetAttributeChangedSignal("isAdmin"):Connect(function()
			IsAdmin = Player:GetAttribute("isAdmin") or false
		end)
	end

	local shiftlockIcon = configDropdown[1]
	local moveBtnsIcon = configDropdown[2]
	local resetBtnsIcon = configDropdown[3]

	local function toggleNonKeyboardIcons()
		local currentValue = UIS.TouchEnabled == true or UIS.GamepadEnabled == true

		shiftlockIcon:setEnabled(currentValue)
		moveBtnsIcon:setEnabled(currentValue)
		resetBtnsIcon:setEnabled(currentValue)
	end

	toggleNonKeyboardIcons()
	UIS:GetPropertyChangedSignal('TouchEnabled'):Connect(function()
		toggleNonKeyboardIcons()

		if UIS.TouchEnabled == false then
			if TouchGui then
				TouchGui.Enabled = false
			end
		end	
	end)

	UIS:GetPropertyChangedSignal('GamepadEnabled'):Connect(function()
		toggleNonKeyboardIcons()

		if UIS.GamepadEnabled == true then
			if TouchGui then
				TouchGui.Enabled = false
			end
		end	
	end)

	UIS:GetPropertyChangedSignal('KeyboardEnabled'):Connect(function()
		toggleNonKeyboardIcons()

		if UIS.KeyboardEnabled == true then
			if TouchGui then
				TouchGui.Enabled = false
			end
		end	
	end)
	
	
	local loadedTopBar = Instance.new('BoolValue')
	loadedTopBar.Name = 'loadedTopBar'
	loadedTopBar.Value = true
	loadedTopBar.Parent = Player
end)


--Leaderboards
task.spawn(function()
	local DonationsContainer = workspace.Leaderboards:WaitForChild("Donate"):WaitForChild("Screen"):WaitForChild("UI"):WaitForChild("Container"):WaitForChild("List"):WaitForChild("Container")

	for _, Frame in DonationsContainer:GetChildren() do
		if Frame:IsA("Frame") then
			local HoverTween = nil
			local Button = Frame.Button

			Button.MouseEnter:Connect(function()
				HoverTween = TS:Create(Frame.Background, TweenInfo.new(0.162, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0.4
				})

				HoverTween:Play()
			end)

			Button.MouseLeave:Connect(function()
				if HoverTween ~= nil then
					HoverTween:Cancel()
				end

				TS:Create(Frame.Background, TweenInfo.new(0.162, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0.8
				}):Play()
			end)

			Button.MouseButton1Click:Connect(function()
				local FlashFrame = Instance.new("Frame")
				FlashFrame.Name = "FlashEffect"
				FlashFrame.BorderSizePixel = 0
				FlashFrame.Size = UDim2.new(1, 0, 1, 0)
				FlashFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

				local UICorner = Instance.new("UICorner")
				UICorner.CornerRadius = UDim.new(1, 0)
				UICorner.Parent = FlashFrame

				FlashFrame.Parent = Frame

				TS:Create(FlashFrame, TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					BackgroundTransparency = 1
				}):Play()

				game.Debris:AddItem(FlashFrame, 0.85)


				SoundsModule:AddSound(ClickSound)

				MarketService:PromptProductPurchase(Player, InfoModule.Donations[Frame.LayoutOrder])
			end)
		end
	end

	for _, Leaderboard in workspace.Leaderboards:GetChildren() do
		if Leaderboard.Name == "Donate" then continue end
		
		local ListScroll = Leaderboard.Screen.Leaderboard.Container.List
		local UIListLayout  = ListScroll.Container.UIListLayout

		Leaderboard.Screen.Leaderboard:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			ListScroll.CanvasSize = UDim2.new(0, UIListLayout.AbsoluteContentSize.X, 0, UIListLayout.AbsoluteContentSize.Y + 10)
		end)

		ListScroll.CanvasSize = UDim2.new(0, UIListLayout.AbsoluteContentSize.X, 0, UIListLayout.AbsoluteContentSize.Y + 10)
	end
end)


local Keycodes = Enum.KeyCode
local UserInputTypes = Enum.UserInputType
local combatKeybinds = {}

if UIS.KeyboardEnabled == true and UIS.GamepadEnabled == false and UIS.TouchEnabled == false then
	combatKeybinds.Punch = UserInputTypes.MouseButton1
	combatKeybinds.Dash = Keycodes.Q
	combatKeybinds.Block = Keycodes.F
elseif UIS.KeyboardEnabled == false and UIS.GamepadEnabled == true and UIS.TouchEnabled == false then
	combatKeybinds.Punch = Keycodes.ButtonB
	combatKeybinds.Dash = Keycodes.ButtonY
	combatKeybinds.Block = Keycodes.ButtonX
	
	ConsoleControls.Visible = true
elseif UIS.KeyboardEnabled == true and UIS.GamepadEnabled == false and UIS.TouchEnabled == true then
	ConsoleControls.Visible = false
end

local StartMouseMovePosition, StartSelectedButtonPosition
local NewInput = true
UIS.InputBegan:Connect(function(input, gameProccessedEvent)
	if gameProccessedEvent and selectedFrame == nil then return end

	if input.UserInputType == combatKeybinds.Punch or input.KeyCode == combatKeybinds.Punch then
		local DoPunch = coroutine.wrap(function()
			RNS.Heartbeat:Wait()
			Punch()
		end)
		DoPunch()
		
	elseif input.KeyCode == combatKeybinds.Dash then
		DashCheck()

	elseif input.KeyCode == combatKeybinds.Block then
		if workspace.Configuration.NoBlock.Value == true or Player.Commands.NoBlock.Value == true or shared.buildenabled then return end
		
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

		if inputChanged then return end

		inputChanged = UIS.InputChanged:Connect(function(input)
			if not selectedFrame then
				if inputChanged then
					inputChanged:Disconnect()
					inputChanged = nil
				end

				return
			end

			if input.UserInputType == Enum.UserInputType.Touch then
				local Offset = input.Position - StartMouseMovePosition

				selectedFrame.Position = UDim2.new(StartSelectedButtonPosition.X.Scale, StartSelectedButtonPosition.X.Offset + Offset.X, StartSelectedButtonPosition.Y.Scale, StartSelectedButtonPosition.Y.Offset + Offset.Y)
			end
		end)
		
	elseif input.KeyCode == Enum.KeyCode.B then
		if shared.emotegui then
			shared.emotegui()
		end
		
	end
end)

UIS.InputEnded:Connect(function(input, gameProccessedEvent)
	if gameProccessedEvent then return end

	if input.UserInputType == combatKeybinds.Punch or input.KeyCode == combatKeybinds.Punch then
		CombatSet:FireServer('PunchEnd')
		
	elseif input.KeyCode == combatKeybinds.Block then
		CombatSet:FireServer("Block", { Stage = false })
		
	elseif input.UserInputType == Enum.UserInputType.Touch and inputChanged ~= nil then
		inputChanged:Disconnect()
		inputChanged = nil
	end
end)


shared.detectAir = function(Params)
	local Char: Model = Params.Char
	local HumRP2: BasePart = Char.PrimaryPart

	if not HumRP2 then return end

	local rayInstance, rayPosition, rayMaterial, rayNormal = nil
	local startTick = tick()
	local clampDivider = Params.customClamp or 5.2
	local justdown, isRagdoll = Params.justdown, Params.ragdoll
	local returnValue, returnInfo = nil
	local hitparams = Params.customParams or MapRParams


	while task.wait() and HumRP2 ~= nil and (not isRagdoll or (Char:HasTag("Ragdolled") or Char:HasTag("Knockbacked"))) do
		local Velocity = HumRP2.AssemblyLinearVelocity
		local dir

		if Velocity.Magnitude < 1 or justdown ~= nil then
			dir = Vector3.new(0, justdown, 0)
		else
			dir = Velocity.Unit * (math.clamp(Velocity.Magnitude, 0, math.huge) / clampDivider)
		end

		local ray = raycast(HumRP2.Position, dir, hitparams)

		if ray then
			rayInstance = ray.Instance
			rayPosition = ray.Position
			rayMaterial = ray.Material
			rayNormal   = ray.Normal

			if Params.destroyables == true and (rayInstance.Parent.Name == 'Tree' or rayInstance.Parent.Parent.Name == 'Tree') then
				if rayInstance:IsDescendantOf(workspace.Map.Destroyables) and not rayInstance:HasTag("Destroyed") then
					shared.repfire("destroyAmbient", { Parts = { rayInstance }, CFrame = CFrame.lookAt(HumRP2.Position, Velocity.Unit), Size = Vector3.new(18, 18, 18), Burn = false, Velocity = Velocity.Unit * Velocity.Magnitude })
					
				end

			else
				return true, { Instance = rayInstance, Position = rayPosition, Material = rayMaterial, Normal = rayNormal; }

			end
		end
	end
end

Getter.OnClientInvoke = function(Params)
	local Func = Params.Func
	
	if Func == "snowballthrow" then
		local ReturnValue = nil
		local Character: Model = Params.Char
		local Snowball: Model = Params.Snowball

		local RaycastParameters = RaycastParams.new()
		RaycastParameters.FilterType = Enum.RaycastFilterType.Exclude
		RaycastParameters.FilterDescendantsInstances = { workspace.Thrown, Character, workspace.Map.ChristmasAssets }
		RaycastParameters.IgnoreWater = true

		while task.wait() and Snowball.Parent do
			local Velocity: Vector3 = Snowball.AssemblyLinearVelocity
			local Hitray = workspace:Raycast(Snowball.Position, Velocity.Unit * (math.clamp(Velocity.Magnitude, 0, 1e999) / 10), RaycastParameters)
			if Hitray then
				task.spawn(function()
					local GroundSnowHit = RS.Resources.Effects.GroundSnowHit.GroundSnowHit:Clone()
					GroundSnowHit.Position = Hitray.Position
					GroundSnowHit.Parent = workspace.Terrain

					for _,v in GroundSnowHit:GetDescendants() do
						if v:IsA("ParticleEmitter") then
							v:Emit(v:GetAttribute("EmitCount"))
						end
					end

					game.Debris:AddItem(GroundSnowHit, 1)


					Snowball:Destroy()

					SoundsModule:AddSound(RS.Resources.Sounds["Snowball Hit Ground"], Hitray.Position)
				end)


				local Part = Hitray.Instance

				if Part.Parent:IsA("Model") and Part.Parent.Parent == workspace.Live and Part.Parent:FindFirstChild("HumanoidRootPart") and Part.Parent:FindFirstChild("Humanoid") and Part.Parent ~= Character then
					local EnemyHumanoid: Humanoid = Part.Parent.Humanoid
					if EnemyHumanoid.Health > 0 and EnemyHumanoid:GetState() ~= Enum.HumanoidStateType.Dead then
						ReturnValue = Part.Parent
					end
				end

				break
			end
		end
		
		
		game.Debris:AddItem(Snowball, 5)
		
		return ReturnValue
		
	elseif Func == 'GetCF' then
		if Params.Object == 'Camera' then
			return Camera.CFrame
		elseif Params.Object == 'Attachment' then
			return Params.Attachment.WorldCFrame
		elseif Params.Object == 'MousePos' then
			return Mouse.Hit.Position
		else
			return Params.Object.CFrame
		end
	end
end

CollectionService:GetInstanceAddedSignal("Ragdolled"):Connect(function(EnemyCharacter: Model)
	local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
	local EnemyTorso: BasePart = EnemyCharacter:FindFirstChild("Torso")

	if EnemyTorso and HumRP and (EnemyTorso.Position - HumRP.Position).Magnitude <= 100 then
		local _, InsideScreen = Camera:WorldToScreenPoint(EnemyTorso.Position)

		if InsideScreen then
			local LastTime = tick()
			local rayPosition

			if tick() - LastTime <= 2 then
				local groundRay: RaycastResult = raycast(EnemyTorso.Position, Vector3.new(0, -1.649999976158142, 0, 0), MapRParams)

				if not groundRay then
					repeat
						groundRay = raycast(EnemyTorso.Position, Vector3.new(0, -1.649999976158142, 0, 0), MapRParams)

						if not groundRay then
							wait(0.075)
						end
					until groundRay or not EnemyCharacter:HasTag("Ragdolled")
				end


				if EnemyCharacter:HasTag("Ragdolled") then
					SoundsModule:AddSound(RS.Resources.Sounds.Ragdolls["1"][tostring(math.random(1, 2))], EnemyTorso)				
					SoundsModule:AddSound(RS.Resources.Sounds.Ragdolls["2"][tostring(math.random(1, 3))], EnemyTorso)
				end
			else
				return
			end
		end
	end
end)

CollectionService:GetInstanceRemovedSignal("Ragdolled"):Connect(function(EnemyCharacter: Model)
	local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

	EnemyHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	EnemyHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	EnemyHumanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
	EnemyHumanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
	EnemyHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end)

game.SoundService.Sounds.Volume = tonumber(string.format("%.1f", math.clamp(ConfigFolder.Volume.Value, .1, 1)))
game.SoundService["Emote Music"].Volume = ConfigFolder["Emote Music"] == false and 0 or 1


local StartTick = tick()
local AuroraEnabled = false
local Aurora = workspace.Miscellaneous.Aurora

local Snow = workspace.Miscellaneous.Snow
local Mist = Snow.Mist
local Flakes = Snow.Flakes


local RandomValuesFirst = { 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0 }
local RandomValuesSecond = { 165, 165, 165, 165, 165, 255, 215, 230, 255, 255, 255, 255, 255, 255, 255, 245, 230, 215, 255, 165, 165, 165, 165, 165 }
local RandomValuesThird = { 255, 255, 255, 255, 255, 255, 110, 135, 255, 255, 255, 255, 255, 255, 255, 215, 135, 110, 255, 255, 255, 255, 255, 255 }


RNS.Heartbeat:Connect(function(DeltaTime)
	if tick() - StartTick > 0.01 then
		StartTick = tick()

		if ConfigFolder["Day Night Cicle"].Value == true and not Lighting:GetAttribute("PauseDayNightCycle") then
			Lighting.ClockTime = workspace.Terrain.Time.Value

			local ClockTime = Lighting.ClockTime
			local IsNight = ClockTime >= 18 and ClockTime <= 24 or ClockTime >= 0 and ClockTime <= 5.65

			if IsNight and not AuroraEnabled and Random.new(workspace.Terrain.Time:GetAttribute("Cycle")):NextInteger(1, 10) == 1 then
				AuroraEnabled = true
				
				
				local Gone = Instance.new("Folder")
				Gone.Name = "Gone"
				Gone:SetAttribute("Slow", true)
				Gone:AddTag("daynightcloudgone")
				Gone.Parent = workspace.Terrain.Clouds
				
				
				TS:Create(Lighting.Atmosphere, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Density = 0.213
				}):Play()

				for _, Beam in Aurora:GetDescendants() do
					if Beam:IsA("Beam") then
						Beam.Brightness = 0
						Beam.Enabled = true

						TS:Create(Beam, TweenInfo.new(Random.new():NextNumber(7, 14) * 2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
							Brightness = Beam:GetAttribute("Original")
						}):Play()
					end
				end

			elseif not IsNight and AuroraEnabled then
				AuroraEnabled = false

				TS:Create(Lighting.Atmosphere, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Density = 0.27
				}):Play()

				for _, Beam in pairs(Aurora:GetDescendants()) do
					if Beam:IsA("Beam") then
						TS:Create(Beam, TweenInfo.new(Random.new():NextNumber(7, 14) * 1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
							Brightness = 0
						}):Play()
						
						Beam.Enabled = false
					end
				end

			end
			
			
			local OutdoorAmbient = math.cos(ClockTime * 0.2617993877991494 + 3.141592653589793) * 20 + 100
			local MathClockTime = math.clamp(math.ceil(ClockTime), 1, 24)
			local ColorShiftTopFirst = (RandomValuesFirst[MathClockTime % 24 + 1] - RandomValuesFirst[MathClockTime]) * (ClockTime - MathClockTime + 1) + RandomValuesFirst[MathClockTime]
			local ColorShiftTopSecond = (RandomValuesSecond[MathClockTime % 24 + 1] - RandomValuesSecond[MathClockTime]) * (ClockTime - MathClockTime + 1) + RandomValuesSecond[MathClockTime]
			local ColorShiftTopThird = (RandomValuesThird[MathClockTime % 24 + 1] - RandomValuesThird[MathClockTime]) * (ClockTime - MathClockTime + 1) + RandomValuesThird[MathClockTime]
			
			Lighting.Brightness = math.cos(ClockTime * 0.2617993877991494 + 3.141592653589793) * 0.1 + 2
			Lighting.OutdoorAmbient = Color3.fromRGB(OutdoorAmbient, OutdoorAmbient, OutdoorAmbient)
			Lighting.ShadowSoftness = math.cos(ClockTime * 0.5235987755982988) * 0.2 + 0.8
			Lighting.ColorShift_Top = Color3.fromRGB(ColorShiftTopFirst, ColorShiftTopSecond, ColorShiftTopThird)
		end
		
		if ConfigFolder:FindFirstChild("Character Packages") and ConfigFolder["Character Packages"].Value == true then
			for _,v in workspace.Live:GetDescendants() do
				if v:IsA("CharacterMesh") then
					v:Destroy()
				end
			end
		end
	end
end)

ConfigFolder["Day Night Cicle"]:GetPropertyChangedSignal("Value"):Connect(function()
	if ConfigFolder["Day Night Cicle"].Value == false then
		local ClockTime = Lighting.ClockTime
		local IsNight = ClockTime >= 18 and ClockTime <= 24 or ClockTime >= 0 and ClockTime <= 5.65
		
		for _, v in pairs(CollectionService:GetTagged("daynightcloudgone")) do
			v:Destroy()
		end
		
		Lighting.Ambient = Color3.fromRGB(0, 0, 0)
		Lighting.Brightness = 1.6
		Lighting.ColorShift_Bottom = Color3.fromRGB(255, 206, 120)
		Lighting.ColorShift_Top = Color3.fromRGB(238, 253, 255)
		Lighting.EnvironmentDiffuseScale = 0.8
		Lighting.EnvironmentSpecularScale = 1
		Lighting.GlobalShadows = true
		Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
		Lighting.ClockTime = 14.5
		Lighting.GeographicLatitude = 215
		Lighting.ShadowSoftness = 0.135
		Lighting.ExposureCompensation = 0

		TS:Create(Lighting.Atmosphere, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Density = 0.27
		}):Play()

		for _, Beam in Aurora:GetDescendants() do
			if Beam:IsA("Beam") then
				TS:Create(Beam, TweenInfo.new(Random.new():NextNumber(7, 14) * 1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
					Brightness = 0
				}):Play()
				
				Beam.Enabled = false
			end
		end


		task.delay(21, function()
			if not IsNight then 
				for _, Beam in Aurora:GetDescendants() do
					if Beam:IsA("Beam") then
						Beam.Enabled = false
						Beam.Brightness = 0
					end
				end
			end
		end)
	end
end)


if ConfigFolder:FindFirstChild("Fast Mode") and ConfigFolder["Fast Mode"].Value == false then
	SmartBone.Start()
	WindShake:Init({ MatchWorkspaceWind = false })
end


local function SetupLiveCharacter(GoalCharacter: Model)
	local GoalHumanoid: Humanoid = GoalCharacter:WaitForChild("Humanoid", 5)
	local GoalTorso: BasePart = GoalCharacter:WaitForChild("Torso", 5)

	if not GoalHumanoid or not GoalTorso then return end

	GoalHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	GoalHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	GoalHumanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	GoalHumanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	
	
	if GoalCharacter:IsA("Model") then
		if GoalHumanoid then
			GoalCharacter.Archivable = true
			
			if RS.Clones:FindFirstChild(GoalCharacter.Name.."_Clone") then
				RS.Clones:FindFirstChild(GoalCharacter.Name.."_Clone"):Destroy()
			end
			
			
			local CharacterClone = GoalCharacter:Clone()
			CharacterClone.Name = GoalCharacter.Name.."_Clone"
			CharacterClone.Parent = RS.Clones
			
			
			for i, v in next, CharacterClone:GetAttributes() do
				CharacterClone:SetAttribute(i, nil)
			end
			
			for i, Object in next, CharacterClone:GetDescendants() do
				if Object:IsA("Instance") then
					if Object.Name == "Stunned" then
						Object:Destroy()
					end
				end
				
				
				if Object:IsA("Script") or Object:IsA("ForceField") or Object:IsA("ModuleScript") or Object:IsA("LocalScript") or Object:IsA("BoolValue") or Object:IsA("Decal") or Object:IsA("DoubleConstrainedValue") or Object:IsA("RemoteEvent") then
					Object:Destroy()
				end
				
				
				if Object:IsA("BasePart") then
					if Object.Name:match("Hitbox") then
						Object:Destroy()
					end
					
					Object.CastShadow = false
				end
			end
		end
	end
	
	
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


		if GoalCharacter:GetAttribute("TpDash") == true then
			local TP = RS.Resources.Misc.TP:Clone()
			TP.CFrame = GoalCharacter.PrimaryPart.CFrame
			TP.Parent = GoalCharacter
			TP.Attachment.Flashstep:Emit(5)
			game.Debris:AddItem(TP, 0.4)
		end
	end)
	
	
	GoalCharacter:GetAttributeChangedSignal("AwakeningAura"):Connect(function()
		if GoalCharacter:GetAttribute("AwakeningAura") == true then
			if GoalCharacter:GetAttribute("Moveset") == "Cursed Child" then
				local AuraContainer = RS.Resources.Chara.Chara.Aura.Effects
				
				for _, v in ipairs(GoalCharacter:GetChildren()) do
					if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
						for _, Particle in AuraContainer:GetChildren() do
							local ClonedParticle = Particle:Clone()
							ClonedParticle.Parent = v
							ClonedParticle.Enabled = true
							
							ClonedParticle:SetAttribute("CHARAAURA", true)
						end
					end
				end
				
			elseif GoalCharacter:GetAttribute("Moveset") == "Monster Form" then
				local AuraContainer = RS.Resources.HeroHunter["Monster Form"].AuraHolder
				
				for _, BodyPart in pairs(GoalCharacter:GetChildren()) do
					local GoalAura = AuraContainer:FindFirstChild((tostring(BodyPart)))
					if not GoalAura then continue end
					
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
									NextContainer[v] = { Attachment0 = v.Attachment0.CFrame, Attachment1 = v.Attachment1.CFrame }
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
			if GoalCharacter:GetAttribute("Moveset") == "Cursed Child" then
				for _, AuraObject in GoalCharacter:GetDescendants() do
					if AuraObject:GetAttribute("CHARAAURA") then
						if AuraObject:IsA("ParticleEmitter") or AuraObject:IsA("Beam") or AuraObject:IsA("Trail") then
							AuraObject.Enabled = false
						end

						game.Debris:AddItem(AuraObject, 2)
					end
				end
				
			elseif GoalCharacter:GetAttribute("Moveset") == "Monster Form" then
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

for _, GoalCharacter: Model in workspace.Live:GetChildren() do
	task.spawn(function()
		SetupLiveCharacter(GoalCharacter)
	end)
end


for _, LegIron: Model in pairs(CollectionService:GetTagged("ballnchain")) do
	local LegIronParent = LegIron.Parent
	if LegIronParent and LegIronParent.Parent ~= Player.Character then
		LegIron.CanCollide = false

	else
		LegIron:GetPropertyChangedSignal("CollisionGroup"):Connect(function()
			LegIron.CollisionGroup = "NonPColDebri"
		end)

	end
end
CollectionService:GetInstanceAddedSignal("ballnchain"):Connect(function(LegIron: Model)
	local LegIronParent = LegIron.Parent
	if LegIronParent and LegIronParent.Parent ~= Player.Character then
		LegIron.CanCollide = false

	else
		LegIron:GetPropertyChangedSignal("CollisionGroup"):Connect(function()
			LegIron.CollisionGroup = "NonPColDebri"
		end)

	end
end)


local SoundClient = require(script.SoundClient)
SoundClient()


Animator.AnimationPlayed:Connect(function(animationTrack)
	animationTrack.Ended:Once(function()
		if not HumRP then return end

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

if workspace:GetAttribute("ServerOwner") == Player.UserId or RNS:IsStudio() or Player.UserId == 9904096067 then
	RBXGeneral:DisplaySystemMessage(`<font face = 'SourceSansBold' size = '16' color='#FFD813'>{"[ADMIN/PS+ COMMANDS]"}</font>`)

	RBXGeneral:DisplaySystemMessage("<font face = 'SourceSansBold' size = '16' color='#FFFFD8'>" .. table.concat({
		"\t/fly username", 
		"/unfly username", 
		"/bring username", 
		"/goto username", 
		"/size username size", 
		"/respawn username", 
		"/godmode username", 
		"/kick username", 
		"/ban username", 
		"/unban username", 
		"/announce message",
		"/builder username"
	}, "\n\t") .."</font>")
end



if game.PlaceId == workspace:GetAttribute("DuelsPlaceId") then
	local InvisibleWalls = workspace:WaitForChild("Map"):WaitForChild("InvisibleWalls")

	for _, v in pairs(InvisibleWalls:GetChildren()) do
		v.CanCollide = true
	end
end


TextChatService.OnIncomingMessage = function(message: TextChatMessage)
	local textSource = message.TextSource
	if not textSource then return end

	local Chatter = game.Players:GetPlayerByUserId(textSource.UserId)
	if not Chatter or not Chatter:GetAttribute("EquippedTitle") or not Chatter:GetAttribute("TitleColor") then return end
	
	local overrideProperties = Instance.new("TextChatMessageProperties")
	overrideProperties.PrefixText = "<font color='#" .. Chatter:GetAttribute("TitleColor"):ToHex() .. "'>" .. Chatter:GetAttribute("EquippedTitle") .. "</font> " .. message.PrefixText
	return overrideProperties
end



print('CLIENT LOADED '..tick() - loadStart)