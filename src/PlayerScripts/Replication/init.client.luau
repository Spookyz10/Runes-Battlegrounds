local Player = game.Players.LocalPlayer

local FunctionsHandler = require(script.Functions).new()
task.spawn(FunctionsHandler.Start, FunctionsHandler)

repeat
	task.wait()
until game:GetService("UserInputService").TouchEnabled or game:GetService("UserInputService").KeyboardEnabled

repeat
	task.wait()
until game:IsLoaded() and Player:FindFirstChild("LoadedData") and Player:HasTag("DataLoaded")

local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientContext = require(RS.Shared.Modules.ClientContext)

local Remotes = RS.Remotes
local ComRemotes = Remotes.Comunicator
local Comunicator = ComRemotes.Set
local Getter = ComRemotes.Get
local CombatRemotes = Remotes.Combat
local CombatSet = CombatRemotes.Set
local SpecialsSet = Remotes.Specials.Set

local ClientRemoteListener = require(ReplicatedStorage.Shared.Modules.ClientRemoteListener)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local IndicatorService = require(script.Functions.Tasks.Shared.IndicatorService)
local RotationController = require(script.Functions.Tasks.Shared.RotationController)
local CutsceneController = require(script.Functions.CutsceneController)

local Animations = RS.Resources.Animations

local gameSettings = UserSettings().GameSettings
local Mouse = Player:GetMouse()

local Character = Player.Character or Player.CharacterAdded:Wait() :: Model
local Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid", 10) :: Humanoid
local Animator = Humanoid:FindFirstChild("Animator") or Humanoid:WaitForChild("Animator", 10) :: Animator
local HumRP = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart", 10) :: BasePart
local Camera = workspace.CurrentCamera

shared.IsMobile = UIS.TouchEnabled == true

local shiftlockActive = false

RotationController:SetCharacter(Character, HumRP, Humanoid)
CutsceneController:Listen()

RunService.RenderStepped:Connect(function()
	if not HumRP or not HumRP.Parent then
		return
	end
	RotationController:Step()

	if shiftlockActive and not Character:HasTag("CantRotate") and not ClientContext.LunarAimActive then
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

local selectedFrame: GuiObject? = nil

local LastSideDash = 0
local LastBackDash = 0

local MapRParams = RaycastParams.new()
MapRParams.FilterType = Enum.RaycastFilterType.Include
MapRParams.FilterDescendantsInstances = {
	workspace.Map.Arena,
	workspace.Map.Miscellaneous,
	workspace.Map.Borders,
}
MapRParams.RespectCanCollide = true

local function raycast(origin: Vector3, direction: Vector3): RaycastResult?
	return workspace:Raycast(origin, direction, MapRParams)
end

local function checkCharacterAvailability(): boolean
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

	local currDirection: string
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

		local dashAnim = currDirection == "Left" and Animations.Dashes.DashLeft or Animations.Dashes.DashRight
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

local Keycodes = Enum.KeyCode
local UserInputTypes = Enum.UserInputType
local combatKeybinds: { Punch: Enum.UserInputType?, Dash: Enum.KeyCode?, Block: Enum.KeyCode? } = {}

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
local inputChanged: RBXScriptConnection? = nil

UIS.InputBegan:Connect(function(input, gameProccessedEvent)
	if gameProccessedEvent and selectedFrame == nil then
		return
	end

	if
		combatKeybinds.Punch and (input.UserInputType == combatKeybinds.Punch or input.KeyCode == combatKeybinds.Punch)
	then
		local DoPunch = coroutine.wrap(function()
			RunService.Heartbeat:Wait()
			Punch()
		end)
		DoPunch()
	elseif combatKeybinds.Dash and input.KeyCode == combatKeybinds.Dash then
		DashCheck()
	elseif combatKeybinds.Block and input.KeyCode == combatKeybinds.Block then
		local DoBlock = coroutine.wrap(function()
			RunService.Heartbeat:Wait()
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

local function SetupLiveCharacter(GoalCharacter: Model)
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
		end
	end)
end

workspace.Live.ChildAdded:Connect(SetupLiveCharacter)
for _, GoalCharacter in workspace.Live:GetChildren() do
	task.spawn(function()
		SetupLiveCharacter(GoalCharacter)
	end)
end

RemoteManager.ListenToAllClient(ClientRemoteListener)
