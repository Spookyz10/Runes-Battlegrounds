local RotationController = require(script.Parent.Shared.RotationController)

return function(Params)
	shared._lunarAimActive = false
	RotationController:Release("lunarAim")
end
