local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local ParticlesModule = Constants.ParticlesModule
local CharacterAssets = Constants.CharacterAssets

return function(Params)
	local Position = Params.position
	if not Position then
		return
	end

	local PulseAsset = CharacterAssets.Eclipse.Solar:FindFirstChild("ImmolatedPulse")
	if not PulseAsset then
		return
	end

	local Clone = PulseAsset:Clone()
	Clone.Parent = workspace
	Clone.Position = Position + Vector3.new(0, -2.5, 0)

	ParticlesModule.Emit(Clone)

	Debris:AddItem(Clone, 4)
end
