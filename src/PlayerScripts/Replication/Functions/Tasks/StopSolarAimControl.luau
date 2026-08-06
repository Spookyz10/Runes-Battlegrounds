local RotationController = require(script.Parent.Shared.RotationController)
local ClientState = require(script.Parent.Shared.ClientState)

return function(Params)
	ClientState.SolarAimActive = false
	RotationController:Release("solarAim")
end
