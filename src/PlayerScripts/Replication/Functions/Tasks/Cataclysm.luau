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
	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not Torso or not RootPart then
		return
	end

	local SolarAwaken = CharacterAssets.Eclipse.Solar.Awaken
	local ImpactAsset = SolarAwaken:FindFirstChild("CataclysmExplosion")
	if not ImpactAsset then
		return
	end

	local Clone = ImpactAsset:Clone()
	Clone.Parent = workspace
	Clone.Position = Vector3.new(Torso.Position.X, RootPart.Position.Y, Torso.Position.Z)

	for i = 1, 3 do
		ParticlesModule.Emit(Clone)
	end

	Debris:AddItem(Clone, 6)
end
