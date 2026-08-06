local RotationController = require(script.Parent.Shared.RotationController)
local ClientState = require(script.Parent.Shared.ClientState)

return function(Params)
	ClientState.SolarAimActive = true
	ClientState.SolarAimDirection = workspace.CurrentCamera.CFrame.LookVector

	local duration = Params.Duration or 5
	local startTime = tick()

	RotationController:Request("solarAim", 10, function()
		if tick() - startTime >= duration then
			RotationController:Release("solarAim")
			ClientState.SolarAimActive = false
			return nil
		end

		local lookDir = workspace.CurrentCamera.CFrame.LookVector
		ClientState.SolarAimDirection = lookDir
		return lookDir
	end)
end
