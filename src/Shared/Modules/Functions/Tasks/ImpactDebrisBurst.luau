local GroundCrater = require(script.Parent["Ground Crater"])

return function(Params)
	local Position = Params.Position
	if not Position then
		return
	end

	local Radius = Params.Radius or 6
	local RockSize: Vector3 = Params.RockSize or Vector3.new(1.5, 1.5, 1.5)
	local ScaleFromRadius = Radius / 6

	GroundCrater({
		Seed = Params.Seed or math.random(1, 2147483647),
		start = Position + Vector3.new(0, 4, 0),
		["end"] = Vector3.new(0, -20, 0),
		amount = Params.RockCount or 10,
		size = ScaleFromRadius,
		sizemult = RockSize.X / 1.5,
		rings = Params.Rings or 2,
		ringSpacing = Params.RingSpacing or (Radius / 2),
		ringSizeGrowth = Params.RingSizeGrowth or 1.5,
		ringGap = Params.RingGap or 0.2,
		outwardTilt = true,
		debrisSizeMin = Params.DebrisSizeMin or (RockSize.X * 1.3),
		debrisSizeMax = Params.DebrisSizeMax or (RockSize.X * 2.6),
		debrisHeightMin = Params.DebrisHeightMin or (RockSize.Y * 1.3),
		debrisHeightMax = Params.DebrisHeightMax or (RockSize.Y * 2.2),
	})
end
