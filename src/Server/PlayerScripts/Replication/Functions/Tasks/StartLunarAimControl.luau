local RotationController = require(script.Parent.Shared.RotationController)

return function(Params)
	shared._lunarAimActive = true
	shared._lunarAimDirection = workspace.CurrentCamera.CFrame.LookVector

	local duration = Params.Duration or 5
	local startTime = tick()

	RotationController:Request("lunarAim", 10, function()
		if tick() - startTime >= duration then
			RotationController:Release("lunarAim")
			shared._lunarAimActive = false
			return nil
		end

		local lookDir = workspace.CurrentCamera.CFrame.LookVector
		shared._lunarAimDirection = lookDir
		return lookDir
	end)
end
