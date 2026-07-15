local Constants = require(script.Parent.Shared.Constants)
local Helpers = require(script.Parent.Shared.Helpers)

local Debris = Constants.Debris
local Resources = Constants.Resources
local ParticlesModule = Constants.ParticlesModule
local MapRayParams = Constants.MapRayParams

return function(Params)
	local PrimaryPart: BasePart = Params.PrimaryPart
	local YAngle = Params.YAngle or 0

	local ZOffset = Params.Front and -4 or 4

	local GroundRay = Helpers.raycast(PrimaryPart.Position, Vector3.new(0, -4, 0), MapRayParams)
	if not GroundRay then
		return
	end

	local SmokeBack = Resources.Effects.SmokeBack:Clone()
	SmokeBack.CFrame = PrimaryPart.CFrame * CFrame.new(0, -3, ZOffset) * CFrame.Angles(0, YAngle, 0)
	SmokeBack.Parent = workspace
	SmokeBack.SmokeBack.Smoke.Color = ColorSequence.new(GroundRay.Instance.Color)
	ParticlesModule.Emit(SmokeBack)
	Debris:AddItem(SmokeBack, 3)
end
