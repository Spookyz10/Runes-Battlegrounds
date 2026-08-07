local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local ParticlesModule = Constants.ParticlesModule
local CharacterAssets = Constants.CharacterAssets

return function(Params)
	local Character = Params.char
	if not Character or not Character.Parent then
		return
	end

	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local SunquakeAsset = CharacterAssets.Eclipse.Solar:FindFirstChild("Sunquake")
	if not SunquakeAsset then
		return
	end

	local Clone = SunquakeAsset:Clone()
	Clone.Parent = workspace
	Clone.WorldPosition = HumRP.Position + Vector3.new(0, -3, 0)

	ParticlesModule.Emit(Clone)

	Debris:AddItem(Clone, 5)
end
