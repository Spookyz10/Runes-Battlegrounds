local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local ParticlesModule = Constants.ParticlesModule

return function(Params)
	local Char = Params.Char
	if not Char or not Char.Parent then
		return
	end

	local RightArm = Char:FindFirstChild("Right Arm")
	if not RightArm then
		return
	end

	local FinalImpact = RightArm:FindFirstChild("FinalImpact")
	if not FinalImpact then
		return
	end

	local VFX = FinalImpact:FindFirstChild("VFX")
	if VFX then
		local Impact = VFX:FindFirstChild("Impact")
		local Impact2 = VFX:FindFirstChild("Impact2")

		if Impact then
			ParticlesModule.Emit(Impact)
		end
		if Impact2 then
			ParticlesModule.Emit(Impact2)
		end
	end

	Debris:AddItem(FinalImpact, 0.3)
end
