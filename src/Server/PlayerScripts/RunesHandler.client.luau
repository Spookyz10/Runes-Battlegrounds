local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FadeOut = require(ReplicatedStorage.Shared.Modules.Utility.FadeOut)

local RunesFolder = ReplicatedStorage.Resources.Runes

local RUNE_OFFSET = Vector3.new(2.5, 1, 0)
local BOB_HEIGHT = 0.35
local BOB_SPEED = 2.2
local ALIGN_RESPONSIVENESS = 8
local ALIGN_MAX_FORCE = 15000
local ALIGN_MAX_TORQUE = 15000
local FADE_DURATION = 0.4

local activeRunes = {}

local function getRuneKey(Character, Player)
	local moveset = Character:GetAttribute("Moveset")
	if moveset ~= "Eclipse" then
		return nil
	end

	local mode = Player:GetAttribute("MovesetMode_Eclipse")
	if not mode then
		return nil
	end

	local isAwakened = Character:GetAttribute("Awakened") == true or Character:HasTag("Awakened")

	if isAwakened then
		return mode .. " Eclipse"
	end

	return mode
end

local function getFlatCFrame(Torso, extraOffset)
	local lookVector = Torso.CFrame.LookVector
	local flatLook = Vector3.new(lookVector.X, 0, lookVector.Z)

	if flatLook.Magnitude < 0.001 then
		flatLook = Vector3.new(0, 0, -1)
	else
		flatLook = flatLook.Unit
	end

	local basePosition = Torso.Position
	local flatCFrame = CFrame.lookAt(basePosition, basePosition + flatLook)

	if extraOffset then
		flatCFrame = flatCFrame * CFrame.new(extraOffset)
	end

	return flatCFrame
end

local function destroyRune(Character)
	local data = activeRunes[Character]
	if not data then
		return
	end

	if data.conn then
		data.conn:Disconnect()
	end
	if data.targetAnchor and data.targetAnchor.Parent then
		data.targetAnchor:Destroy()
	end
	if data.model and data.model.Parent then
		data.model:Destroy()
	end

	activeRunes[Character] = nil
end

local function fadeOutRune(data)
	if data.conn then
		data.conn:Disconnect()
	end

	if data.model and data.model.Parent then
		FadeOut.OutAndDestroy(data.model, FADE_DURATION)
	end

	if data.targetAnchor and data.targetAnchor.Parent then
		local TargetAnchor = data.targetAnchor
		task.delay(FADE_DURATION, function()
			if TargetAnchor and TargetAnchor.Parent then
				TargetAnchor:Destroy()
			end
		end)
	end
end

local function buildRune(Character, key, spawnCFrame)
	local RuneTemplate = RunesFolder:FindFirstChild(key)
	if not RuneTemplate then
		return
	end

	local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not Torso then
		return
	end

	spawnCFrame = spawnCFrame or getFlatCFrame(Torso, RUNE_OFFSET)

	local RuneModel = RuneTemplate:Clone()
	RuneModel.Name = "EquippedRune"

	local MainPart = RuneModel.PrimaryPart or RuneModel:FindFirstChildWhichIsA("BasePart")
	if not MainPart then
		RuneModel:Destroy()
		return
	end
	if not RuneModel.PrimaryPart then
		RuneModel.PrimaryPart = MainPart
	end

	for _, part in RuneModel:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true

			if part ~= MainPart then
				local Weld = Instance.new("WeldConstraint")
				Weld.Part0 = MainPart
				Weld.Part1 = part
				Weld.Parent = part
			end
		end
	end

	RuneModel:PivotTo(spawnCFrame)
	RuneModel.Parent = Character

	local RuneAttachment = Instance.new("Attachment")
	RuneAttachment.Name = "RuneAttachment"
	RuneAttachment.Parent = MainPart

	local TargetAnchor = Instance.new("Part")
	TargetAnchor.Name = "RuneTargetAnchor"
	TargetAnchor.Anchored = true
	TargetAnchor.CanCollide = false
	TargetAnchor.CanTouch = false
	TargetAnchor.CanQuery = false
	TargetAnchor.Transparency = 1
	TargetAnchor.Size = Vector3.new(0.1, 0.1, 0.1)
	TargetAnchor.CFrame = spawnCFrame
	TargetAnchor.Parent = workspace.Debris

	local TargetAttachment = Instance.new("Attachment")
	TargetAttachment.Parent = TargetAnchor

	local AlignPosition = Instance.new("AlignPosition")
	AlignPosition.Attachment0 = RuneAttachment
	AlignPosition.Attachment1 = TargetAttachment
	AlignPosition.MaxForce = ALIGN_MAX_FORCE
	AlignPosition.Responsiveness = ALIGN_RESPONSIVENESS
	AlignPosition.RigidityEnabled = false
	AlignPosition.Parent = MainPart

	local AlignOrientation = Instance.new("AlignOrientation")
	AlignOrientation.Attachment0 = RuneAttachment
	AlignOrientation.Attachment1 = TargetAttachment
	AlignOrientation.MaxTorque = ALIGN_MAX_TORQUE
	AlignOrientation.Responsiveness = ALIGN_RESPONSIVENESS
	AlignOrientation.RigidityEnabled = false
	AlignOrientation.Parent = MainPart

	local startTime = os.clock()

	local conn = RunService.Heartbeat:Connect(function()
		if not Character.Parent or not Torso.Parent or not TargetAnchor.Parent then
			return
		end

		local bobY = math.sin((os.clock() - startTime) * BOB_SPEED) * BOB_HEIGHT
		TargetAnchor.CFrame = getFlatCFrame(Torso, RUNE_OFFSET + Vector3.new(0, bobY, 0))
	end)

	activeRunes[Character] = {
		model = RuneModel,
		mainPart = MainPart,
		targetAnchor = TargetAnchor,
		conn = conn,
		key = key,
	}

	FadeOut.In(RuneModel, FADE_DURATION)
end

local function updateRune(Character, Player)
	local key = getRuneKey(Character, Player)
	local previous = activeRunes[Character]

	if previous and previous.key == key then
		return
	end

	activeRunes[Character] = nil

	if key then
		local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")

		local spawnCFrame
		if previous and previous.mainPart and previous.mainPart.Parent then
			spawnCFrame = previous.mainPart.CFrame
		elseif Torso then
			spawnCFrame = getFlatCFrame(Torso, RUNE_OFFSET)
		end

		if spawnCFrame then
			buildRune(Character, key, spawnCFrame)
		end
	end

	if previous then
		fadeOutRune(previous)
	end
end

local function setupCharacter(Character)
	local Player = Players:GetPlayerFromCharacter(Character)
	if not Player then
		return
	end

	updateRune(Character, Player)

	local connections = {}

	table.insert(
		connections,
		Character:GetAttributeChangedSignal("Moveset"):Connect(function()
			updateRune(Character, Player)
		end)
	)

	table.insert(
		connections,
		Character:GetAttributeChangedSignal("Awakened"):Connect(function()
			updateRune(Character, Player)
		end)
	)

	table.insert(
		connections,
		Player:GetAttributeChangedSignal("MovesetMode_Eclipse"):Connect(function()
			updateRune(Character, Player)
		end)
	)

	Character.AncestryChanged:Once(function(_, parent)
		if parent then
			return
		end

		destroyRune(Character)
		for _, conn in connections do
			conn:Disconnect()
		end
	end)
end

for _, Character in workspace.Live:GetChildren() do
	task.spawn(setupCharacter, Character)
end

workspace.Live.ChildAdded:Connect(function(Character)
	task.spawn(setupCharacter, Character)
end)

workspace.Live.ChildRemoved:Connect(function(Character)
	destroyRune(Character)
end)
