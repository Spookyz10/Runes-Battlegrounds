local Constants = require(script.Parent.Shared.Constants)
local Helpers = require(script.Parent.Shared.Helpers)
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
	local ImpactAsset = SolarAwaken:FindFirstChild("CataclysmExplosion")
	if not ImpactAsset then
		return
	end

	local RayOrigin = Torso.Position
	local RayDirection = Vector3.new(0, -100, 0)

	local _HitInstance, HitPosition = Helpers.performRaycast({
		orig = RayOrigin,
		dir = RayDirection,
		Ignore = { Character },
	})

	local GroundPosition = HitPosition or (Torso.Position + Vector3.new(0, -80, 0))

	local Clone = ImpactAsset:Clone()
	Clone.Parent = workspace
	Clone.Position = GroundPosition

	for i = 1, 3 do
		ParticlesModule.Emit(Clone)
		task.wait(0.1)
	end

	Debris:AddItem(Clone, 6)
end
