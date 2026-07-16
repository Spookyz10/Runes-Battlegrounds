local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local ParticlesModule = Constants.ParticlesModule
local CharacterAssets = Constants.CharacterAssets

return function(Params)
	local LunarAwaken = CharacterAssets.Eclipse.Lunar.Awaken
	local ImpactAsset = LunarAwaken:FindFirstChild("IslandExplosion")
	if not ImpactAsset then
		return
	end

	local Clone = ImpactAsset:Clone()
	Clone.Parent = workspace
	Clone.Position = Params.position

	ParticlesModule.Emit(Clone)

	Debris:AddItem(Clone, 6)
end
