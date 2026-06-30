local RotationController = require(script.Parent.Shared.RotationController)

return function(Params)
	shared._solarAimActive = true
	shared._solarAimDirection = workspace.CurrentCamera.CFrame.LookVector

	local duration = Params.Duration or 5
	local startTime = tick()

	RotationController:Request("solarAim", 10, function()
		if tick() - startTime >= duration then
			RotationController:Release("solarAim")
			shared._solarAimActive = false
			return nil
		end

		local lookDir = workspace.CurrentCamera.CFrame.LookVector
		shared._solarAimDirection = lookDir
		return lookDir
	end)
end
