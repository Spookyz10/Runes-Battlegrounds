local RotationController = require(script.Parent.Shared.RotationController)

return function(Params)
	shared._shadestepAimActive = true

	local duration = Params.Duration or 1
	local startTime = tick()

	RotationController:Request("shadestepAim", 10, function()
		if tick() - startTime >= duration then
			RotationController:Release("shadestepAim")
			shared._shadestepAimActive = false
			return nil
		end

		return workspace.CurrentCamera.CFrame.LookVector
	end)
end
