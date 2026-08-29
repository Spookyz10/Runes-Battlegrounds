local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local activeConn = nil
local originalCameraType = nil
local originalSubject = nil

local Handlers = {}

function Handlers.Start(params)
	local part = params.part
	if not part then
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
		if not part or not part.Parent then
			if activeConn then
				activeConn:Disconnect()
				activeConn = nil
			end
			return
		end

		Camera.CFrame = part.CFrame
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
