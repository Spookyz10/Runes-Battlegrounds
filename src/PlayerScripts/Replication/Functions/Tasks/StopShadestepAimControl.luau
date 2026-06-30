local RotationController = require(script.Parent.Shared.RotationController)

return function(Params)
	shared._shadestepAimActive = false
	RotationController:Release("shadestepAim")
end
