local Constants = require(script.Parent.Shared.Constants)
local LocalPlayer = Constants.LocalPlayer
local RunService = Constants.RunService

return function(Params)
	if shared._solarAimConn then
		shared._solarAimConn:Disconnect()
		shared._solarAimConn = nil
	end

	shared._solarAimActive = true

	local LocalChar = LocalPlayer.Character
	local LocalHumRP = LocalChar and LocalChar:FindFirstChild("HumanoidRootPart")
	local LocalHumanoid = LocalChar and LocalChar:FindFirstChild("Humanoid")
	if not LocalHumRP or not LocalHumanoid then
		return
	end

	LocalHumanoid.AutoRotate = false
	shared._solarAimDirection = workspace.CurrentCamera.CFrame.LookVector

	local duration = Params.Duration or 5
	local startTime = tick()

	shared._solarAimConn = RunService.RenderStepped:Connect(function()
		if not LocalHumRP or not LocalHumRP.Parent then
			if shared._solarAimConn then
				shared._solarAimConn:Disconnect()
				shared._solarAimConn = nil
			end
			LocalHumanoid.AutoRotate = true
			return
		end

		if tick() - startTime >= duration then
			if shared._solarAimConn then
				shared._solarAimConn:Disconnect()
				shared._solarAimConn = nil
			end
			LocalHumanoid.AutoRotate = true
			return
		end

		local lookDir = workspace.CurrentCamera.CFrame.LookVector
		shared._solarAimDirection = lookDir

		LocalHumRP.CFrame = CFrame.new(LocalHumRP.Position, LocalHumRP.Position + lookDir)
	end)
end
