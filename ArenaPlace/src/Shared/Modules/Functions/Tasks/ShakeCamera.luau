local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).client
local CameraShakerController = require(ReplicatedStorage.Shared.Modules.Functions.CameraShakerController)
local Constants = require(script.Parent.Shared.Constants)
local CamShakePresets = Constants.CamShakePresets

return function(params)
	task.spawn(function()
		if not Data.Settings.CameraShake() then
			return
		end

		if params["Intensity"] ~= nil then
			if params.Last then
				local Intensity = params.Intensity

				for i = 1, params.Last / 0.03 do
					CameraShakerController.AddShake(Intensity)

					Intensity *= 0.9

					task.wait(0.03)
				end
			else
				CameraShakerController.AddShake(params.Intensity)
			end
		elseif params.Instance then
			CameraShakerController.sustainShake(params.Instance, params.shakeTime, params.fadeOutTime)
		else
			if params.Preset then
				local Preset = CamShakePresets[params.Preset]
				assert(Preset, "The specified preset does not exist.")

				CameraShakerController.AddShake(
					Preset.Magnitude,
					Preset.Roughness,
					Preset.FadeInTime,
					Preset.FadeOutTime
				)
			else
				CameraShakerController.AddShake(
					params.Magnitude,
					params.Roughness,
					params.FadeInTime,
					params.FadeOutTime
				)
			end
		end
	end)
end
