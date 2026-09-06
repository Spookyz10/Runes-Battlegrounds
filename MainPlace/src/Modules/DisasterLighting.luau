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

return function()
	local saved = {}

	local function apply(object, values)
		local original = {}

		for key, value in values do
			original[key] = object[key]
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

	return function()
		grade:Destroy()

		for object, values in saved do
			if object == Lighting or object.Parent then
				for key, value in values do
					object[key] = value
				end
			end
		end
	end
end
