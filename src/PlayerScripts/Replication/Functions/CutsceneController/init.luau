local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local CameraRigs = ReplicatedStorage.Resources.CameraRigs
local CutsceneAnimations = ReplicatedStorage.Resources.Animations.Cutscenes
local CutscenesSet = ReplicatedStorage.Remotes.Cutscenes.Set
local CutscenesEnded = ReplicatedStorage.Remotes.Cutscenes.Ended

local Controller = {}

local activeName = nil
local activeCutscene = nil

local activeCutsceneId = nil

local activeRig = nil
local activeRigTrack = nil
local rigConnection = nil

local activeGoalPart = nil
local activeOffset = nil
local activeRigPrimary = nil

local previousCameraType = nil
local previousCameraSubject = nil

local cutscenes = {}

for _, module in script.Cutscenes:GetDescendants() do
	if module:IsA("ModuleScript") then
		cutscenes[module.Name] = require(module)
	end
end

function Controller:ReportEnded()
	if activeCutsceneId then
		CutscenesEnded:FireServer(activeCutsceneId)
		activeCutsceneId = nil
	end
end

function Controller:PlayRig(name, Character, params)
	local RigTemplate = CameraRigs:FindFirstChild("MainRig")
	if not RigTemplate then
		warn("[CutsceneController] MainRig não encontrado")
		return nil
	end

	local goalPart

	if params.goalPart or params.GoalPart then
		goalPart = params.goalPart or params.GoalPart
	else
		goalPart = Character:FindFirstChild("HumanoidRootPart")
	end

	if not goalPart then
		return nil
	end

	local Animation = CutsceneAnimations:FindFirstChild(name)
	if not Animation then
		warn("[CutsceneController] Animação de rig não encontrada: " .. tostring(name))
		return nil
	end

	local Rig = RigTemplate:Clone()
	Rig.Parent = workspace

	local Offset = params.Offset or CFrame.new()

	if params.Offset then
		Rig:PivotTo(goalPart.CFrame * params.Offset)
	else
		Rig:PivotTo(goalPart.CFrame)
	end

	local RigPrimary = Rig.PrimaryPart or Rig:FindFirstChildWhichIsA("BasePart", true)
	if not RigPrimary then
		warn("[CutsceneController] Rig não possui PrimaryPart nem BasePart")
		Rig:Destroy()
		return nil
	end

	-- Teleport manual (em vez de WeldConstraint) — necessário pois a PrimaryPart
	-- do rig costuma estar Anchored, o que faz o WeldConstraint não ter efeito algum.
	activeGoalPart = goalPart
	activeOffset = Offset
	activeRigPrimary = RigPrimary

	local AnimController = Rig:FindFirstChildOfClass("AnimationController") or Rig:FindFirstChildOfClass("Humanoid")
	local Animator = AnimController and AnimController:FindFirstChildOfClass("Animator")
	if AnimController and not Animator then
		Animator = Instance.new("Animator")
		Animator.Parent = AnimController
	end

	if not Animator then
		warn("[CutsceneController] Animator não encontrado no rig")
		Rig:Destroy()
		return nil
	end

	local Track = Animator:LoadAnimation(Animation)

	local RigCamera = Rig:FindFirstChild("camera")
	local Camera = workspace.CurrentCamera

	previousCameraType = Camera.CameraType
	previousCameraSubject = Camera.CameraSubject
	Camera.CameraType = Enum.CameraType.Scriptable

	rigConnection = RunService.RenderStepped:Connect(function()
		if activeGoalPart and activeGoalPart.Parent and activeRigPrimary and activeRigPrimary.Parent then
			local currentPivot = Rig:GetPivot()
			local targetCFrame = activeGoalPart.CFrame * activeOffset
			-- Preserva o offset entre PrimaryPart e o pivot do modelo (caso não sejam coincidentes)
			local pivotOffset = activeRigPrimary.CFrame:ToObjectSpace(currentPivot)
			Rig:PivotTo(targetCFrame * pivotOffset)
		end

		if RigCamera and RigCamera.Parent then
			Camera.CFrame = RigCamera.CFrame
		end
	end)

	activeRig = Rig
	activeRigTrack = Track

	Track.Stopped:Once(function()
		if activeRigTrack == Track then
			Controller:StopRig()
		end
	end)

	Track:Play()

	return Rig, Track
end

function Controller:StopRig(skipCameraSubject)
	if rigConnection then
		rigConnection:Disconnect()
		rigConnection = nil
	end

	if activeRigTrack then
		local Track = activeRigTrack
		activeRigTrack = nil
		Track:Stop()
	end

	activeGoalPart = nil
	activeOffset = nil
	activeRigPrimary = nil

	if activeRig and activeRig.Parent then
		activeRig:Destroy()
	end
	activeRig = nil

	local Camera = workspace.CurrentCamera
	Camera.CameraType = previousCameraType or Enum.CameraType.Custom
	if not skipCameraSubject and previousCameraSubject then
		Camera.CameraSubject = previousCameraSubject
	end
	previousCameraType = nil
	previousCameraSubject = nil
	Controller:ReportEnded()
end

function Controller:Start(name, Character, Params)
	if activeCutscene and activeCutscene.EndEarly then
		activeCutscene.EndEarly(Controller)
	end

	local CutsceneModule = cutscenes[name]
	if not CutsceneModule then
		warn("[CutsceneController] Cutscene não encontrada: " .. tostring(name))
		return
	end

	activeName = name
	activeCutscene = CutsceneModule
	activeCutsceneId = Params and Params.CutsceneId

	if CutsceneModule.Start then
		CutsceneModule.Start(Character, Params or {}, Controller)
	end
end

function Controller:EndEarly()
	if activeCutscene and activeCutscene.EndEarly then
		activeCutscene.EndEarly(Controller)
	end
	activeName = nil
	activeCutscene = nil
end

function Controller:GetActiveName()
	return activeName
end

function Controller:Dispatch(name, action, Params)
	if action == "Start" then
		Controller:Start(name, LocalPlayer.Character, Params)
		return
	end

	if activeName ~= name or not activeCutscene then
		return
	end

	local handler = activeCutscene[action]
	if handler then
		handler(Params or {}, Controller)
	end
end

function Controller:Listen()
	CutscenesSet.OnClientEvent:Connect(function(name, action, Params)
		Controller:Dispatch(name, action, Params)
	end)
end

return Controller
