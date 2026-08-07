local Constants = require(script.Parent.Shared.Constants)
local CamShakePresets = Constants.CamShakePresets

return function(params)
	task.spawn(function()
		if params["Intensity"] ~= nil then
			if params.Last then
				local Intensity = params.Intensity

				for i = 1, params.Last / 0.03 do
					shared.addshake(Intensity)

					Intensity *= 0.9

					task.wait(0.03)
				end
			else
				shared.addshake(params.Intensity)
			end
		elseif params.Instance then
			shared.sustainshake(params.Instance, params.shakeTime, params.fadeOutTime)
		else
			if params.Preset then
				local Preset = CamShakePresets[params.Preset]
				assert(Preset, "The specified preset does not exist.")

				shared.addshake(Preset.Magnitude, Preset.Roughness, Preset.FadeInTime, Preset.FadeOutTime)
			else
				shared.addshake(params.Magnitude, params.Roughness, params.FadeInTime, params.FadeOutTime)
			end
		end
	end)
end
