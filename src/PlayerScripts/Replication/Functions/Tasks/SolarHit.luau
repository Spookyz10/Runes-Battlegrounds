local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local ParticlesModule = Constants.ParticlesModule
local CharacterAssets = Constants.CharacterAssets

return function(Params)
	local Character = Params.char
	if not Character or not Character.Parent then
		return
	end

	local Torso = Character:FindFirstChild("Torso")
	if not Torso then
		return
	end

	local SolarAwaken = CharacterAssets.Eclipse.Solar.Awaken
	local ImpactAsset = SolarAwaken:FindFirstChild("SolarHit")
	if not ImpactAsset then
		return
	end

	local Clone = ImpactAsset:Clone()
	Clone.Parent = workspace
	Clone.Position = Torso.Position + Vector3.new(0, 0, -2)

	ParticlesModule.Emit(Clone)

	Debris:AddItem(Clone, 6)
end
