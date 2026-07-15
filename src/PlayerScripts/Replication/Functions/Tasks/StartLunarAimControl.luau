local RotationController = require(script.Parent.Shared.RotationController)
local Players = game:GetService("Players")

return function(Params)
	shared._lunarAimActive = true
	shared._lunarAimDirection = workspace.CurrentCamera.CFrame.LookVector

	local LocalPlayer = Players.LocalPlayer
	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local Camera = workspace.CurrentCamera

	if Humanoid then
		Camera.CameraSubject = Humanoid
	end

	local duration = Params.Duration or 5
	local startTime = tick()

	local function restoreCamera()
		if Humanoid then
			Camera.CameraSubject = Humanoid
		end
	end

	RotationController:Request("lunarAim", 10, function()
		if tick() - startTime >= duration then
			RotationController:Release("lunarAim")
			shared._lunarAimActive = false
			restoreCamera()
			return nil
		end

		local lookDir = workspace.CurrentCamera.CFrame.LookVector
		shared._lunarAimDirection = lookDir
		return lookDir
	end)

	shared._lunarAimRestoreCamera = restoreCamera
end
