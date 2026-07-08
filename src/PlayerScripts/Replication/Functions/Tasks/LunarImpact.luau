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

	local LunarAwaken = CharacterAssets.Eclipse.Lunar.Awaken
	local ImpactAsset = LunarAwaken:FindFirstChild("LunarImpact")
	if not ImpactAsset then
		return
	end

	local TeleportAsset = LunarAwaken:FindFirstChild("Teleport")
	if not TeleportAsset then
		return
	end

	local Clone = ImpactAsset:Clone()
	Clone.Parent = workspace
	Clone.Position = HumRP.Position + Vector3.new(0, -3, 0)

	local TpClone = TeleportAsset:Clone()
	TpClone.Parent = workspace
	TpClone.Position = HumRP.Position

	ParticlesModule.Emit(TpClone)
	ParticlesModule.Emit(Clone)

	Debris:AddItem(Clone, 6)
	Debris:AddItem(TpClone, 6)
end
