local Constants = require(script.Parent.Shared.Constants)
local CharacterAssets = Constants.CharacterAssets

local OFFSET_POSITION = Vector3.new(0, 0, 0)
local OFFSET_ROTATION = Vector3.new(-90, 0, 0)

return function(Params)
	local Char = Params.Char
	if not Char or not Char.Parent then
		return
	end

	local RightArm = Char:FindFirstChild("Right Arm")
	if not RightArm then
		return
	end

	local FinalImpact = CharacterAssets.Eclipse.Lunar:FindFirstChild("FinalImpact")
	if not FinalImpact then
		return
	end

	local FIClone = FinalImpact:Clone()
	FIClone.Name = "FinalImpact"
	FIClone.Anchored = false

	FIClone.CFrame = RightArm.CFrame
		* CFrame.new(OFFSET_POSITION)
		* CFrame.Angles(math.rad(OFFSET_ROTATION.X), math.rad(OFFSET_ROTATION.Y), math.rad(OFFSET_ROTATION.Z))

	FIClone.Parent = RightArm

	local Weld = Instance.new("WeldConstraint")
	Weld.Part0 = RightArm
	Weld.Part1 = FIClone
	Weld.Parent = FIClone
end
