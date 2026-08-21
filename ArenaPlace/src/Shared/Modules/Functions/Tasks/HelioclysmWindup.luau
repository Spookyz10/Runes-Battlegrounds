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

	local WindupAsset = CharacterAssets.Eclipse.Solar.Awaken.Helioclysm:FindFirstChild("Windup")
	if not WindupAsset then
		return
	end

	local Clone = WindupAsset:Clone()
	Clone.Parent = workspace
	Clone.CFrame = HumRP.CFrame + Vector3.new(0, -3, -3)

	ParticlesModule.Emit(Clone)

	Debris:AddItem(Clone, 2)
end
