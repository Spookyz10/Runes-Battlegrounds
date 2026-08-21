local RotationController = require(script.Parent.Shared.RotationController)
local Players = game:GetService("Players")

local ClientState = require(game:GetService("ReplicatedStorage").Shared.Modules.ClientContext)

local UPDATE_INTERVAL = 0.15

return function(Params)
	ClientState.LunarAimActive = true
	ClientState.LunarAimDirection = workspace.CurrentCamera.CFrame.LookVector

	local LocalPlayer = Players.LocalPlayer
	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local Camera = workspace.CurrentCamera

	if Humanoid then
		Camera.CameraSubject = Humanoid
	end

	local Bridge = Params.BridgeId and LocalPlayer:WaitForChild(Params.BridgeId, 5)

	local duration = Params.Duration or 5
	local startTime = tick()
	local lastSent = 0

	local function restoreCamera()
		if Humanoid then
			Camera.CameraSubject = Humanoid
		end
	end

	RotationController:Request("lunarAim", 10, function()
		if tick() - startTime >= duration then
			RotationController:Release("lunarAim")
			ClientState.LunarAimActive = false
			restoreCamera()
			return nil
		end

		local lookDir = workspace.CurrentCamera.CFrame.LookVector
		ClientState.LunarAimDirection = lookDir

		if Bridge then
			local now = tick()
			if now - lastSent >= UPDATE_INTERVAL then
				lastSent = now
				Bridge:FireServer(lookDir)
			end
		end

		return lookDir
	end)

	ClientState.LunarAimRestoreCamera = restoreCamera
end
