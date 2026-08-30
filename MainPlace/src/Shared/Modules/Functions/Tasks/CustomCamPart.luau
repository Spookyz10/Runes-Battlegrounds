local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local activeConn = nil
local originalCameraType = nil
local originalSubject = nil

local Handlers = {}

function Handlers.Start(params)
	local position = params.position
	local lookTarget = params.lookTarget
	if not position then
		return
	end

	local Camera = workspace.CurrentCamera

	if activeConn then
		activeConn:Disconnect()
		activeConn = nil
	end

	originalCameraType = Camera.CameraType
	originalSubject = Camera.CameraSubject

	Camera.CameraType = Enum.CameraType.Scriptable

	activeConn = RunService.RenderStepped:Connect(function()
		if not position then
			return
		end

		local lookAtPosition = position + Vector3.new(0, 0, -1)

		if lookTarget and lookTarget.Parent then
			local HumRP = lookTarget:FindFirstChild("HumanoidRootPart")
			if HumRP and HumRP.Parent then
				lookAtPosition = HumRP.Position
			end
		end

		Camera.CFrame = CFrame.new(position, lookAtPosition)
	end)
end

function Handlers.Stop(_params)
	local Camera = workspace.CurrentCamera

	if activeConn then
		activeConn:Disconnect()
		activeConn = nil
	end

	Camera.CameraType = originalCameraType or Enum.CameraType.Custom

	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

	Camera.CameraSubject = originalSubject or Humanoid

	originalCameraType = nil
	originalSubject = nil
end

return function(params)
	local handler = Handlers[params.func]
	if handler then
		handler(params)
	end
end
