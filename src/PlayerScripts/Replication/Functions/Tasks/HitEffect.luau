local Constants = require(script.Parent.Shared.Constants)
local ParticlesModule = Constants.ParticlesModule
local Debris = Constants.Debris
local Resources = Constants.Resources

local HitEffectsFolder = Resources.Effects.HitEffects

return function(Params)
	print(Params)
	local EChar = Params.EChar
	local Style = Params.Style

	if not EChar or not EChar.Parent then
		return
	end

	local HumRP = EChar:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local effectAsset = HitEffectsFolder:FindFirstChild(Style)
	print("Effect Asset: ", effectAsset)
	if not effectAsset then
		return
	end

	local clone = effectAsset:Clone()
	clone.CFrame = HumRP.CFrame * CFrame.new(0, 0, -2)
	clone.Parent = workspace.Debris

	ParticlesModule.Emit(clone)
	Debris:AddItem(clone, 3)
end
