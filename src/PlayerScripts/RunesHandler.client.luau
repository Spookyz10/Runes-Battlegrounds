local Players: Players = game:GetService("Players")
local RunService: RunService = game:GetService("RunService")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local FadeOut = require(ReplicatedStorage.Shared.Modules.Utility.FadeOut)
local InfoModule = require(ReplicatedStorage.Shared.Info)

local RunesFolder: Folder = ReplicatedStorage.Resources.Runes

local RUNE_OFFSET: Vector3 = Vector3.new(2.5, 1, 0)
local BOB_HEIGHT: number = 0.35
local BOB_SPEED: number = 2.2
local ALIGN_RESPONSIVENESS: number = 8
local ALIGN_MAX_FORCE: number = 15000
local ALIGN_MAX_TORQUE: number = 15000
local FADE_DURATION: number = 0.4
local PLAYER_RESOLVE_TIMEOUT: number = 5

type RuneData = {
	model: Model,
	mainPart: BasePart,
	targetAnchor: Part,
	conn: RBXScriptConnection,
	key: string,
}

local activeRunes: { [Model]: RuneData } = {}

local function getRuneKey(Character: Model, Player: Player): string?
	local moveset: string? = Character:GetAttribute("Moveset") :: string?
	if not moveset then
		return nil
	end

	local movesetInfo = InfoModule.Movesets[moveset]
	if not movesetInfo then
		return nil
	end

	local isAwakened: boolean = Character:GetAttribute("Awakened") == true or Character:HasTag("Awakened")

	if not movesetInfo.Modes then
		return moveset
	end

	local mode: string? = (Player:GetAttribute("MovesetMode_" .. moveset) :: string?) or movesetInfo.DefaultMode
	if not mode then
		return nil
	end

	if isAwakened then
		return mode .. " " .. moveset
	end

	return mode
end

local function getFlatCFrame(Torso: BasePart, extraOffset: Vector3?): CFrame
	local lookVector: Vector3 = Torso.CFrame.LookVector
	local flatLook: Vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)

	if flatLook.Magnitude < 0.001 then
		flatLook = Vector3.new(0, 0, -1)
	else
		flatLook = flatLook.Unit
	end

	local basePosition: Vector3 = Torso.Position
	local flatCFrame: CFrame = CFrame.lookAt(basePosition, basePosition + flatLook)

	if extraOffset then
		flatCFrame = flatCFrame * CFrame.new(extraOffset)
	end

	return flatCFrame
end

local function destroyRune(Character: Model)
	local data: RuneData? = activeRunes[Character]
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

local function fadeOutRune(data: RuneData)
	if data.conn then
		data.conn:Disconnect()
	end

	if data.model and data.model.Parent then
		FadeOut.OutAndDestroy(data.model, FADE_DURATION)
	end

	if data.targetAnchor and data.targetAnchor.Parent then
		local TargetAnchor: Part = data.targetAnchor
		task.delay(FADE_DURATION, function()
			if TargetAnchor and TargetAnchor.Parent then
				TargetAnchor:Destroy()
			end
		end)
	end
end

local function buildRune(Character: Model, key: string, spawnCFrame: CFrame?)
	local RuneTemplate: Instance? = RunesFolder:FindFirstChild(key)
	if not RuneTemplate then
		return
	end

	local Torso: BasePart? = (Character:FindFirstChild("Torso") :: BasePart?)
		or Character:FindFirstChild("UpperTorso") :: BasePart?
	if not Torso then
		return
	end

	local ResolvedCFrame: CFrame = spawnCFrame or getFlatCFrame(Torso, RUNE_OFFSET)

	local RuneModel: Model = (RuneTemplate :: Model):Clone()
	RuneModel.Name = "EquippedRune"

	local MainPart: BasePart? = RuneModel.PrimaryPart or RuneModel:FindFirstChildWhichIsA("BasePart")
	if not MainPart then
		RuneModel:Destroy()
		return
	end
	if not RuneModel.PrimaryPart then
		RuneModel.PrimaryPart = MainPart
	end

	for _, part: Instance in RuneModel:GetDescendants() do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
			part.CanTouch = false
			part.CanQuery = false
			part.Massless = true

			if part ~= MainPart then
				local Weld: WeldConstraint = Instance.new("WeldConstraint")
				Weld.Part0 = MainPart
				Weld.Part1 = part
				Weld.Parent = part
			end
		end
	end

	RuneModel:PivotTo(ResolvedCFrame)
	RuneModel.Parent = Character

	local RuneAttachment: Attachment = Instance.new("Attachment")
	RuneAttachment.Name = "RuneAttachment"
	RuneAttachment.Parent = MainPart

	local TargetAnchor: Part = Instance.new("Part")
	TargetAnchor.Name = "RuneTargetAnchor"
	TargetAnchor.Anchored = true
	TargetAnchor.CanCollide = false
	TargetAnchor.CanTouch = false
	TargetAnchor.CanQuery = false
	TargetAnchor.Transparency = 1
	TargetAnchor.Size = Vector3.new(0.1, 0.1, 0.1)
	TargetAnchor.CFrame = ResolvedCFrame
	TargetAnchor.Parent = workspace.Debris

	local TargetAttachment: Attachment = Instance.new("Attachment")
	TargetAttachment.Parent = TargetAnchor

	local AlignPosition: AlignPosition = Instance.new("AlignPosition")
	AlignPosition.Attachment0 = RuneAttachment
	AlignPosition.Attachment1 = TargetAttachment
	AlignPosition.MaxForce = ALIGN_MAX_FORCE
	AlignPosition.Responsiveness = ALIGN_RESPONSIVENESS
	AlignPosition.RigidityEnabled = false
	AlignPosition.Parent = MainPart

	local AlignOrientation: AlignOrientation = Instance.new("AlignOrientation")
	AlignOrientation.Attachment0 = RuneAttachment
	AlignOrientation.Attachment1 = TargetAttachment
	AlignOrientation.MaxTorque = ALIGN_MAX_TORQUE
	AlignOrientation.Responsiveness = ALIGN_RESPONSIVENESS
	AlignOrientation.RigidityEnabled = false
	AlignOrientation.Parent = MainPart

	local startTime: number = os.clock()

	local conn: RBXScriptConnection = RunService.Heartbeat:Connect(function()
		if not Character.Parent or not Torso.Parent or not TargetAnchor.Parent then
			return
		end

		local bobY: number = math.sin((os.clock() - startTime) * BOB_SPEED) * BOB_HEIGHT
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

local function updateRune(Character: Model, Player: Player)
	local key: string? = getRuneKey(Character, Player)
	local previous: RuneData? = activeRunes[Character]

	if previous and previous.key == key then
		return
	end

	activeRunes[Character] = nil

	if key then
		local Torso: BasePart? = (Character:FindFirstChild("Torso") :: BasePart?)
			or Character:FindFirstChild("UpperTorso") :: BasePart?

		local spawnCFrame: CFrame? = nil
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

local function resolvePlayer(Character: Model): Player?
	local Player: Player? = Players:GetPlayerFromCharacter(Character)
	if Player then
		return Player
	end

	local startTime: number = os.clock()
	repeat
		task.wait()
		Player = Players:GetPlayerFromCharacter(Character)
	until Player or not Character.Parent or (os.clock() - startTime) > PLAYER_RESOLVE_TIMEOUT

	return Player
end

local function setupCharacter(Character: Model)
	local Player: Player? = resolvePlayer(Character)
	if not Player then
		return
	end

	updateRune(Character, Player)

	local connections: { RBXScriptConnection } = {}

	table.insert(
		connections,
		Character:GetAttributeChangedSignal("Moveset"):Connect(function()
			updateRune(Character, Player :: Player)
		end)
	)

	table.insert(
		connections,
		Character:GetAttributeChangedSignal("Awakened"):Connect(function()
			updateRune(Character, Player :: Player)
		end)
	)

	table.insert(
		connections,
		(Player :: Player).AttributeChanged:Connect(function(attr: string)
			if attr:match("^MovesetMode_") then
				updateRune(Character, Player :: Player)
			end
		end)
	)

	Character.AncestryChanged:Once(function(_, parent: Instance?)
		if parent then
			return
		end

		destroyRune(Character)
		for _, conn: RBXScriptConnection in connections do
			conn:Disconnect()
		end
	end)
end

for _, Character: Instance in workspace.Live:GetChildren() do
	task.spawn(setupCharacter, Character :: Model)
end

workspace.Live.ChildAdded:Connect(function(Character: Instance)
	task.spawn(setupCharacter, Character :: Model)
end)

workspace.Live.ChildRemoved:Connect(function(Character: Instance)
	destroyRune(Character :: Model)
end)
