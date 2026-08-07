local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SoundsModule = require(ReplicatedStorage.Shared.Modules.SoundsModule)

local MoveSounds: Folder = ReplicatedStorage.Resources.SFX.MoveSounds

local FootstepSFX = {}

local lastMaterial: Enum.Material? = nil
local lastPlayTime: number = 0

local RaycastFilter = RaycastParams.new()
RaycastFilter.FilterType = Enum.RaycastFilterType.Exclude

local function getSoundsForMaterial(material: Enum.Material): Folder?
	return MoveSounds:FindFirstChild(material.Name)
end

function FootstepSFX.Step(Character: Model, Humanoid: Humanoid, HumRP: BasePart, forcePlay: boolean?)
	RaycastFilter.FilterDescendantsInstances = { Character, workspace.CurrentCamera }

	local isClimbing: boolean = Humanoid:GetState() == Enum.HumanoidStateType.Climbing
	local isSwimming: boolean = Humanoid:GetState() == Enum.HumanoidStateType.Swimming

	local rayLength: number = forcePlay and -5 or -3.5
	local ray: RaycastResult? = workspace:Raycast(HumRP.Position, Vector3.new(0, rayLength, 0), RaycastFilter)

	if not (ray or isClimbing or isSwimming) then
		return
	end

	local rayIsStill: boolean = ray ~= nil
		and ray.Instance:IsA("BasePart")
		and ray.Instance.AssemblyLinearVelocity.Magnitude < 1

	if not (rayIsStill or tick() - lastPlayTime > 0.35 or forcePlay) then
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

		SoundsModule:PlaySound(sound, HumRP, isClimbing and 1.25 + math.random() * 0.15 or nil, sound.Volume)
	end

	lastMaterial = material
end

return FootstepSFX
