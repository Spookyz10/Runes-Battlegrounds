local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local ParticlesModule = Constants.ParticlesModule
local CharacterAssets = Constants.CharacterAssets

return function(Params)
	local Solar = CharacterAssets.Eclipse.Solar.Awaken
	local ImpactAsset = Solar:FindFirstChild("CataclysmWindup")
	if not ImpactAsset then
		return
	end

	local Clone = ImpactAsset:Clone()
	Clone.Parent = workspace
	Clone.CFrame = Params.CFrame

	ParticlesModule.Emit(Clone)

	Debris:AddItem(Clone, 6)
end
