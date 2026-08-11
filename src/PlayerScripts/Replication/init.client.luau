local Player: Player = game.Players.LocalPlayer

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

local ClientRemoteListener = require(ReplicatedStorage.Shared.Modules.ClientRemoteListener)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local Functions = require(ReplicatedStorage.Shared.Modules.Functions)
local RotationController = require(ReplicatedStorage.Shared.Modules.Functions.Tasks.Shared.RotationController)
local DashResolver = require(ReplicatedStorage.Shared.Modules.Functions.DashDirectionResolver)
local ShiftlockController = require(ReplicatedStorage.Shared.Modules.Functions.ShiftlockController)

Functions.new()
task.spawn(Functions.Start, Functions)

local Character: Model = Player.Character or Player.CharacterAdded:Wait()
local Humanoid: Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid", 10)
local Animator: Animator = Humanoid:FindFirstChild("Animator") or Humanoid:WaitForChild("Animator", 10)
local HumRP: BasePart = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart", 10)
local Camera: Camera = workspace.CurrentCamera

ClientContext.IsMobile = UIS.TouchEnabled == true

ShiftlockController.SetCamera(Camera)

RotationController:SetCharacter(Character, HumRP, Humanoid)

RunService.RenderStepped:Connect(function()
	if not HumRP or not HumRP.Parent then
		return
	end
	RotationController:Step()

	if ShiftlockController.IsActive() and not Character:HasTag("CantRotate") and not ClientContext.LunarAimActive then
		Camera.CFrame *= ShiftlockController.GetOffset()
	end
end)

Player:GetPropertyChangedSignal("Character"):Connect(function()
	if not Player or not Player.Parent then
		return
	end

	DashResolver.Cleanup(Character)

	Character = Player.Character

	if not Character or not Character.Parent then
		Player.CharacterAdded:Wait()
	end

	Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid", 10)
	Animator = Humanoid:FindFirstChild("Animator") or Humanoid:WaitForChild("Animator", 10)
	HumRP = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart", 10)

	RotationController:SetCharacter(Character, HumRP, Humanoid)
end)

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Camera = workspace.CurrentCamera
	ShiftlockController.SetCamera(Camera)
end)

local selectedFrame: GuiObject? = nil

local MapRaycastParams = RaycastParams.new()
MapRaycastParams.FilterType = Enum.RaycastFilterType.Include
MapRaycastParams.FilterDescendantsInstances = {
	workspace.Map.Arena,
	workspace.Map.Miscellaneous,
	workspace.Map.Borders,
}
MapRaycastParams.RespectCanCollide = true

local function raycastMap(origin: Vector3, direction: Vector3): RaycastResult?
	return workspace:Raycast(origin, direction, MapRaycastParams)
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

local function punch()
	if checkCharacterAvailability() then
		RemoteManager.FireServer("Combat", "PunchStart")
	end
end

local function dashCheck()
	if not checkCharacterAvailability() then
		return
	end

	DashResolver.PerformDash(Character, Humanoid, HumRP, Camera, Animator)
end

local Keycodes = Enum.KeyCode
local UserInputTypes = Enum.UserInputType
local combatKeybinds: { Punch: Enum.UserInputType?, Dash: Enum.KeyCode?, Block: Enum.KeyCode? } = {}

if UIS.KeyboardEnabled and not UIS.TouchEnabled then
	combatKeybinds.Punch = UserInputTypes.MouseButton1
	combatKeybinds.Dash = Keycodes.Q
	combatKeybinds.Block = Keycodes.F
else
	combatKeybinds.Punch = nil
	combatKeybinds.Dash = nil
	combatKeybinds.Block = nil
end

local startMouseMovePosition: Vector3?
local startSelectedButtonPosition: UDim2?
local inputChanged: RBXScriptConnection? = nil

UIS.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent and selectedFrame == nil then
		return
	end

	if
		combatKeybinds.Punch and (input.UserInputType == combatKeybinds.Punch or input.KeyCode == combatKeybinds.Punch)
	then
		local doPunch = coroutine.wrap(function()
			RunService.Heartbeat:Wait()
			punch()
		end)
		doPunch()
	elseif combatKeybinds.Dash and input.KeyCode == combatKeybinds.Dash then
		dashCheck()
	elseif combatKeybinds.Block and input.KeyCode == combatKeybinds.Block then
		local doBlock = coroutine.wrap(function()
			RunService.Heartbeat:Wait()
			if not Character:FindFirstChild("Stunned") then
				RemoteManager.FireServer("Combat", "Block", { Stage = true })
			end
		end)
		doBlock()
	elseif input.UserInputType == Enum.UserInputType.Touch and selectedFrame ~= nil then
		startMouseMovePosition = input.Position
		startSelectedButtonPosition = selectedFrame.Position

		if inputChanged then
			return
		end

		inputChanged = UIS.InputChanged:Connect(function(changedInput: InputObject)
			if not selectedFrame then
				if inputChanged then
					inputChanged:Disconnect()
					inputChanged = nil
				end
				return
			end

			if changedInput.UserInputType == Enum.UserInputType.Touch then
				local offset: Vector3 = changedInput.Position - startMouseMovePosition
				selectedFrame.Position = UDim2.new(
					startSelectedButtonPosition.X.Scale,
					startSelectedButtonPosition.X.Offset + offset.X,
					startSelectedButtonPosition.Y.Scale,
					startSelectedButtonPosition.Y.Offset + offset.Y
				)
			end
		end)
	elseif input.KeyCode == Enum.KeyCode.R then
		if not gameProcessedEvent then
			local isAwakened: boolean = Character:GetAttribute("Awakened") == true
			RemoteManager.FireServer("Specials", isAwakened and "ActivateUlt" or "ActivateBase", {})
		end
	end
end)

UIS.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then
		return
	end

	if
		combatKeybinds.Punch and (input.UserInputType == combatKeybinds.Punch or input.KeyCode == combatKeybinds.Punch)
	then
		RemoteManager.FireServer("Combat", "PunchEnd")
	elseif combatKeybinds.Block and input.KeyCode == combatKeybinds.Block then
		RemoteManager.FireServer("Combat", "Block", { Stage = false })
	elseif input.UserInputType == Enum.UserInputType.Touch and inputChanged ~= nil then
		inputChanged:Disconnect()
		inputChanged = nil
	end
end)

CollectionService:GetInstanceAddedSignal("Ragdolled"):Connect(function(EnemyCharacter: Model)
	local enemyTorso: BasePart? = EnemyCharacter:FindFirstChild("Torso")
	if not enemyTorso or not HumRP or (enemyTorso.Position - HumRP.Position).Magnitude > 100 then
		return
	end

	local _, insideScreen: boolean = Camera:WorldToScreenPoint(enemyTorso.Position)
	if not insideScreen then
		return
	end

	local groundRay: RaycastResult? = raycastMap(enemyTorso.Position, Vector3.new(0, -1.649999976158142, 0))
	if not groundRay then
		repeat
			groundRay = raycastMap(enemyTorso.Position, Vector3.new(0, -1.649999976158142, 0))
			if not groundRay then
				task.wait(0.075)
			end
		until groundRay or not EnemyCharacter:HasTag("Ragdolled")
	end
end)

CollectionService:GetInstanceRemovedSignal("Ragdolled"):Connect(function(EnemyCharacter: Model)
	local enemyHumanoid: Humanoid = EnemyCharacter:WaitForChild("Humanoid")
	enemyHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	enemyHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	enemyHumanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
	enemyHumanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
	enemyHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end)

game.SoundService.Sounds.Volume = 1
game.SoundService["Emote Music"].Volume = 1

local function setupLiveCharacter(GoalCharacter: Model)
	local goalHumanoid: Humanoid? = GoalCharacter:WaitForChild("Humanoid", 5)
	local goalTorso: BasePart? = GoalCharacter:WaitForChild("Torso", 5)
	if not goalHumanoid or not goalTorso then
		return
	end

	goalHumanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	goalHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	goalHumanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	goalHumanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)

	local previousTransparencies: { [BasePart | Decal]: number } = {}
	GoalCharacter:GetAttributeChangedSignal("Invisible"):Connect(function()
		if GoalCharacter:GetAttribute("Invisible") == true then
			for _, part in GoalCharacter:GetDescendants() do
				if (part:IsA("BasePart") or part:IsA("Decal")) and part.Transparency < 1 then
					if not previousTransparencies[part] then
						previousTransparencies[part] = part.Transparency
					end
					part.Transparency = 1
				end
			end
		else
			for part, transparency in previousTransparencies do
				part.Transparency = transparency
			end
		end
	end)

	GoalCharacter:GetAttributeChangedSignal("AwakeningAura"):Connect(function()
		if GoalCharacter:GetAttribute("AwakeningAura") ~= true then
			return
		end
		if GoalCharacter:GetAttribute("Moveset") ~= "Monster Form" then
			return
		end

		local auraContainer: Instance = RS.Resources.HeroHunter["Monster Form"].AuraHolder

		for _, bodyPart in GoalCharacter:GetChildren() do
			local goalAura: Instance? = auraContainer:FindFirstChild(tostring(bodyPart))
			if not goalAura then
				continue
			end

			local beamsAndTrails: { [Trail | Beam]: { Attachment0: CFrame, Attachment1: CFrame } } = {}
			local goalPart: Instance = GoalCharacter[tostring(goalAura)]

			for _, auraPart in goalAura:GetChildren() do
				local auraClone: Instance = auraPart:Clone()
				auraClone.Parent = goalPart
				auraClone:SetAttribute("MonsterParticles", true)

				for _, v in auraClone:GetDescendants() do
					if v:IsA("Trail") or v:IsA("Beam") or v:IsA("ParticleEmitter") then
						v.Enabled = true
					end
					if (v:IsA("Trail") or v:IsA("Beam")) and v.Attachment0 and v.Attachment1 then
						beamsAndTrails[v] = { Attachment0 = v.Attachment0.CFrame, Attachment1 = v.Attachment1.CFrame }
					end
				end
			end

			for beamOrTrail, cframes in beamsAndTrails do
				local targetParent: Instance = beamOrTrail.Parent.Parent

				for _, object in GoalCharacter:GetDescendants() do
					if not object:IsA("Attachment") then
						continue
					end

					local objectParent: Instance? = object.Parent
					if not objectParent or not objectParent:IsA("BasePart") or objectParent ~= targetParent then
						continue
					end

					if object.CFrame == cframes.Attachment0 then
						beamOrTrail.Attachment0 = object
					elseif object.CFrame == cframes.Attachment1 then
						beamOrTrail.Attachment1 = object
					end
				end
			end
		end
	end)
end

workspace.Live.ChildAdded:Connect(setupLiveCharacter)
for _, GoalCharacter in workspace.Live:GetChildren() do
	task.spawn(function()
		setupLiveCharacter(GoalCharacter)
	end)
end

RemoteManager.ListenToAllClient(ClientRemoteListener)
RemoteManager.ListenToAllClientFunctions(ClientRemoteListener)
