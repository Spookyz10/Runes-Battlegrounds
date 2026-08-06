local ClientState = require(script.Parent.Shared.ClientState)

return function(_Params)
	if ClientState.LunarAimRestoreCamera then
		ClientState.LunarAimRestoreCamera()
		ClientState.LunarAimRestoreCamera = nil
	end
end
