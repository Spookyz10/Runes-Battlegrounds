local RotationController = require(script.Parent.Shared.RotationController)
local ClientState = require(game:GetService("ReplicatedStorage").Shared.Modules.ClientContext)

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
