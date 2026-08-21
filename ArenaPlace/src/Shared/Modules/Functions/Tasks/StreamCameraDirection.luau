local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local UPDATE_INTERVAL = 0.05

return function(Params)
	local Bridge = Params.BridgeId and LocalPlayer:WaitForChild(Params.BridgeId, 5)
	if not Bridge then
		return
	end

	local duration = Params.Duration or 3
	local startTime = tick()
	local lastSent = 0

	local conn
	conn = RunService.Heartbeat:Connect(function()
		if not Bridge or not Bridge.Parent then
			if conn then
				conn:Disconnect()
			end
			return
		end

		if tick() - startTime >= duration then
			conn:Disconnect()
			return
		end

		local now = tick()
		if now - lastSent < UPDATE_INTERVAL then
			return
		end
		lastSent = now

		Bridge:FireServer(workspace.CurrentCamera.CFrame.LookVector)
	end)
end