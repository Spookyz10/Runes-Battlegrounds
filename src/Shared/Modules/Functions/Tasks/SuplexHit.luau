local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local ParticlesModule = Constants.ParticlesModule
local CharacterAssets = Constants.CharacterAssets
local GroundCrater = require(script.Parent["Ground Crater"])

local FORWARD_OFFSET = 2
local RIGHT_OFFSET = 1
local ANGLE = 45

return function(Params)
	local Character = Params.char
	if not Character or not Character.Parent then
		return
	end

	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local ImpactAsset = CharacterAssets.Shattered.Suplex:FindFirstChild("Impact")
	if ImpactAsset then
		local Clone = ImpactAsset:Clone()
		Clone.Parent = workspace
		Clone:PivotTo(
			HumRP.CFrame * CFrame.new(RIGHT_OFFSET, 0, -FORWARD_OFFSET) * CFrame.Angles(0, math.rad(ANGLE), 0)
		)

		ParticlesModule.Emit(Clone)

		Debris:AddItem(Clone, 5)
	end

	GroundCrater({
		Seed = math.random(1, 2147483647),
		start = HumRP.CFrame + Vector3.new(0, 6, 0),
		["end"] = Vector3.new(0, -20, 0),
		NoGroundAlign = true,
		amount = 30,
		rings = 3,
		ringSpacing = 2.5,
		ringSizeGrowth = 1.25,
		ringGap = 0.2,
		outwardTilt = false,
		debrisSizeMin = 2,
		debrisSizeMax = 3.5,
		debrisHeightMin = 1.4,
		debrisHeightMax = 2.4,
		maxDebrisHeight = 3,
		sizemult = 1,
		largeDebrisCountMin = 6,
		largeDebrisCountMax = 10,
		largeDebrisSizeMin = 1.2,
		largeDebrisSizeMax = 3.5,
		largeDebrisSpeedMin = -30,
		largeDebrisSpeedMax = 30,
		largeDebrisUpMin = 10,
		largeDebrisUpMax = 35,
		largeDebrisSpeedMult = 2.2,
		largeDebrisLifetime = 3,
		largeDebrisLifetimeRandom = 1,
		smallDebrisCountMin = 8,
		smallDebrisCountMax = 14,
		smallDebrisSizeMin = 0.5,
		smallDebrisSizeMax = 1,
		smallDebrisSpeedMin = -30,
		smallDebrisSpeedMax = 30,
		smallDebrisUpMin = 8,
		smallDebrisUpMax = 30,
		smallDebrisSpeedMult = 2.2,
		smallDebrisLifetime = 3,
		smallDebrisLifetimeRandom = 1,
	})
end
