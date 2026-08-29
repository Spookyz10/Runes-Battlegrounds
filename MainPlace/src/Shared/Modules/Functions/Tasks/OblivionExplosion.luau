local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local ParticlesModule = Constants.ParticlesModule
local CharacterAssets = Constants.CharacterAssets

return function(Params)
	local Position = Params.position
	if not Position then
		return
	end

	local ObliviionAssets = CharacterAssets.Shattered.Oblivion
	local ImpactAsset = ObliviionAssets:FindFirstChild("OblivionExplosion")
	if not ImpactAsset then
		return
	end

	local Clone = ImpactAsset:Clone()
	Clone.Parent = workspace
	Clone.Position = Position

	for i = 1, 3 do
		ParticlesModule.Emit(Clone)
	end

	Debris:AddItem(Clone, 6)
end
