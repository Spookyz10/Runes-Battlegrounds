local RotationController = require(script.Parent.Shared.RotationController)
local ClientState = require(game:GetService("ReplicatedStorage").Shared.Modules.ClientContext)

return function(Params)
	ClientState.SolarAimActive = false
	RotationController:Release("solarAim")
end
