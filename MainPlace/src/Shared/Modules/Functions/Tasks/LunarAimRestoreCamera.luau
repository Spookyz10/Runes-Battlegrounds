local ClientState = require(game:GetService("ReplicatedStorage").Shared.Modules.ClientContext)

return function(_Params)
	if ClientState.LunarAimRestoreCamera then
		ClientState.LunarAimRestoreCamera()
		ClientState.LunarAimRestoreCamera = nil
	end
end
