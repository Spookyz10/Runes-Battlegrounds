local Constants = require(script.Parent.Shared.Constants)
local CharacterAssets = Constants.CharacterAssets

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
	FIClone.CFrame = RightArm.CFrame * CFrame.Angles(math.rad(170.702), math.rad(-180), math.rad(-172.399))
	FIClone.Parent = RightArm

	local Weld = Instance.new("WeldConstraint")
	Weld.Part0 = RightArm
	Weld.Part1 = FIClone
	Weld.Parent = FIClone
end
