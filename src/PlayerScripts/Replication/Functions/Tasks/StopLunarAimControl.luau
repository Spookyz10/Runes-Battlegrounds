local RotationController = require(script.Parent.Shared.RotationController)
local ClientState = require(script.Parent.Shared.ClientState)

return function(Params)
	ClientState.LunarAimActive = false
	RotationController:Release("lunarAim")

	if Params.RestoreCamera ~= false then
		if ClientState.LunarAimRestoreCamera then
			ClientState.LunarAimRestoreCamera()
			ClientState.LunarAimRestoreCamera = nil
		end
	end
end
