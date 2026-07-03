local RotationController = require(script.Parent.Shared.RotationController)

return function(Params)
	shared._solarAimActive = false
	RotationController:Release("solarAim")
end
