local Lighting = game:GetService("Lighting")
local Presets = {
	Atmosphere = {
		Density = 0.35,
		Offset = 0.1,
		Color = Color3.fromRGB(224, 145, 119),
		Decay = Color3.fromRGB(118, 65, 57),
		Glare = 0.3,
		Haze = 2,
	},
	BloomEffect = { Enabled = true, Intensity = 0.65, Size = 30, Threshold = 1.1 },
	DepthOfFieldEffect = {
		Enabled = true,
		FarIntensity = 0.08,
		NearIntensity = 0,
		FocusDistance = 100,
		InFocusRadius = 100,
	},
	SunRaysEffect = { Enabled = true, Intensity = 0.04, Spread = 0.7 },
}

return function(name)
	local saved = {}
	local created = {}

	local function apply(object, values)
		local original = saved[object] or {}

		for key, value in values do
			if original[key] == nil then
				original[key] = object[key]
			end
			object[key] = value
		end

		saved[object] = original
	end

	apply(Lighting, {
		ClockTime = 18.2,
		Brightness = 2,
		Ambient = Color3.fromRGB(115, 70, 65),
		OutdoorAmbient = Color3.fromRGB(140, 90, 78),
		ExposureCompensation = 0.1,
		FogColor = Color3.fromRGB(155, 82, 65),
		FogStart = 150,
		FogEnd = 1800,
	})

	for _, child in Lighting:GetChildren() do
		local preset = Presets[child.ClassName]

		if preset then
			apply(child, preset)
		end
	end

	local grade = Instance.new("ColorCorrectionEffect")
	grade.Name = "VolcanoColor"
	grade.TintColor = Color3.fromRGB(255, 191, 162)
	grade.Contrast = 0.12
	grade.Saturation = -0.1
	grade.Parent = Lighting
	if name ~= "Volcano" then
		local snow = name == "Blizzard"
		local night = name == "MeteorShower"
		Lighting.ClockTime = if night then 0 else 14
		Lighting.Brightness = if snow then 1.5 else 0.7
		Lighting.Ambient = Color3.fromRGB(75, 85, 110)
		Lighting.OutdoorAmbient = Color3.fromRGB(105, 115, 135)
		Lighting.FogColor = if snow then Color3.fromRGB(210, 225, 240) else Color3.fromRGB(60, 70, 95)
		Lighting.FogStart = if snow then 30 else 100
		Lighting.FogEnd = if snow then 350 else 1400
		grade.Name = "DisasterColor"
		grade.TintColor = if snow then Color3.fromRGB(210, 230, 255) else Color3.fromRGB(170, 190, 235)
		for _, child in Lighting:GetChildren() do
			if child:IsA("Atmosphere") then
				child.Color = Lighting.FogColor
				child.Decay = Color3.fromRGB(90, 105, 135)
				child.Density = if snow then 0.5 else 0.35
			end
		end
	end

	if name == "MeteorShower" then
		apply(Lighting, {
			ClockTime = 0.4,
			Brightness = 1.3,
			ExposureCompensation = -0.1,
			Ambient = Color3.fromRGB(65, 42, 100),
			OutdoorAmbient = Color3.fromRGB(100, 72, 145),
			FogColor = Color3.fromRGB(57, 28, 95),
			FogStart = 120,
			FogEnd = 1050,
		})
		grade.TintColor = Color3.fromRGB(215, 190, 255)
		grade.Contrast, grade.Saturation = 0.2, 0.1
		local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
		if not atmosphere then
			atmosphere = Instance.new("Atmosphere")
			atmosphere.Parent = Lighting
			table.insert(created, atmosphere)
		end
		apply(atmosphere, {
			Color = Color3.fromRGB(135, 90, 195),
			Decay = Color3.fromRGB(55, 25, 95),
			Density = 0.4,
			Haze = 3,
			Glare = 0.2,
			Offset = 0.15,
		})
		local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
		if not bloom then
			bloom = Instance.new("BloomEffect")
			bloom.Parent = Lighting
			table.insert(created, bloom)
		end
		apply(bloom, { Enabled = true, Intensity = 1.1, Size = 45, Threshold = 0.85 })
		local sky = Lighting:FindFirstChildOfClass("Sky")
		if sky then
			apply(sky, { StarCount = 5000, CelestialBodiesShown = true, MoonAngularSize = 14 })
		end
	end

	return function()
		grade:Destroy()

		for object, values in saved do
			if object == Lighting or object.Parent then
				for key, value in values do
					object[key] = value
				end
			end
		end
		for _, object in created do
			object:Destroy()
		end
	end
end
