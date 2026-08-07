local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SFXModule = require(ReplicatedStorage.Shared.Modules.SFXModule)

local MoveSounds: Folder = ReplicatedStorage.Resources.SFX.MoveSounds

local FootstepSFX = {}

local lastMaterial: Enum.Material? = nil
local lastPlayTime: number = 0

local WALK_INTERVAL = 0.35
local RUN_INTERVAL = 0.25

local RaycastFilter = RaycastParams.new()
RaycastFilter.FilterType = Enum.RaycastFilterType.Exclude

local function getSoundsForMaterial(material: Enum.Material): Folder?
	return MoveSounds:FindFirstChild(material.Name)
end

function FootstepSFX.Step(Character: Model, Humanoid: Humanoid, HumRP: BasePart, forcePlay: boolean?)
	local isClimbing: boolean = Humanoid:GetState() == Enum.HumanoidStateType.Climbing
	local isSwimming: boolean = Humanoid:GetState() == Enum.HumanoidStateType.Swimming
	local isMoving: boolean = Humanoid.MoveDirection.Magnitude > 0

	if not (isMoving or isClimbing or isSwimming) then
		return
	end

	local interval: number = forcePlay and RUN_INTERVAL or WALK_INTERVAL
	if tick() - lastPlayTime < interval then
		return
	end

	RaycastFilter.FilterDescendantsInstances = { Character, workspace.CurrentCamera }

	local rayLength: number = forcePlay and -5 or -3.5
	local ray: RaycastResult? = workspace:Raycast(HumRP.Position, Vector3.new(0, rayLength, 0), RaycastFilter)

	if not (ray or isClimbing or isSwimming) then
		return
	end

	lastPlayTime = tick()

	local material: Enum.Material = isClimbing and Enum.Material.ForceField
		or isSwimming and Enum.Material.Water
		or ray.Material

	local soundList: Folder? = getSoundsForMaterial(isClimbing and lastMaterial or material)
	if soundList and #soundList:GetChildren() > 0 then
		local children = soundList:GetChildren()
		local sound: Sound = children[math.random(#children)]

		SFXModule:PlayInstance(sound, HumRP, isClimbing and 1.25 + math.random() * 0.15 or nil)
	end

	lastMaterial = material
end

return FootstepSFX
