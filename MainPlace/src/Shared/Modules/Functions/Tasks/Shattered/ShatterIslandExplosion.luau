local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Modules.Functions.Tasks.Shared.Constants)

local Debris = Constants.Debris
local ParticlesModule = Constants.ParticlesModule
local CharacterAssets = Constants.CharacterAssets

return function(Params)
	local ImpactAsset = CharacterAssets.Shattered.IslandExplosion

	local Clone = ImpactAsset:Clone()
	Clone.Parent = workspace
	Clone.Position = Params.Part

	ParticlesModule.Emit(Clone)

	Debris:AddItem(Clone, 6)
end
