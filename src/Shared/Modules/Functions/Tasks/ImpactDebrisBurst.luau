local GroundCrater = require(script.Parent["Ground Crater"])

return function(params)
	local position = params.Position
	if not position then
		return
	end

	local rockSize: Vector3 = params.RockSize or Vector3.new(2, 2, 2)
	local radius = params.Radius or 8

	GroundCrater({
		Seed = params.Seed or math.random(1, 2147483647),
		start = position + Vector3.new(0, 5, 0),
		["end"] = Vector3.new(0, -18, 0),
		amount = math.clamp(params.RockCount or 9, 6, 14),
		size = math.clamp(radius / 12, 0.55, 0.8),
		sizemult = math.clamp(rockSize.X / 2.5, 0.7, 1),
		rings = 1,
		ringSpacing = math.clamp(radius * 0.42, 3, 4),
		ringSizeGrowth = 1.2,
		ringGap = 0.15,
		outwardTilt = true,
		tileMode = params.TileMode,
		debrisSizeMin = rockSize.X * 0.85,
		debrisSizeMax = rockSize.X * 1.35,
		debrisHeightMin = rockSize.Y * 0.8,
		debrisHeightMax = rockSize.Y * 1.25,
	})
end
