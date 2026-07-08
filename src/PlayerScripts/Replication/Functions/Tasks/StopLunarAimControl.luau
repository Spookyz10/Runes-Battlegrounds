local RotationController = require(script.Parent.Shared.RotationController)

return function(Params)
	shared._lunarAimActive = false
	RotationController:Release("lunarAim")

	if Params.RestoreCamera ~= false then
		if shared._lunarAimRestoreCamera then
			shared._lunarAimRestoreCamera()
			shared._lunarAimRestoreCamera = nil
		end
	end
end
