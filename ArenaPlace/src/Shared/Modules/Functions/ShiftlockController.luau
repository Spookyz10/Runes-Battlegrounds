local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RotationController = require(ReplicatedStorage.Shared.Modules.Functions.Tasks.Shared.RotationController)

local ShiftlockController = {}

local Active = false
local Camera = workspace.CurrentCamera

function ShiftlockController.SetCamera(camera)
	Camera = camera
end

function ShiftlockController.IsActive()
	return Active
end

function ShiftlockController.Enable()
	if Active then
		return
	end
	Active = true

	RotationController:Request("shiftlock", 1, function()
		local cam = Camera or workspace.CurrentCamera
		return cam.CFrame.LookVector
	end)
end

function ShiftlockController.Disable()
	if not Active then
		return
	end
	Active = false
	RotationController:Release("shiftlock")
end

function ShiftlockController.Toggle()
	if Active then
		ShiftlockController.Disable()
	else
		ShiftlockController.Enable()
	end
	return Active
end

function ShiftlockController.GetOffset()
	if not Active then
		return CFrame.new()
	end
	return CFrame.new(1.75, 0, 0)
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Camera = workspace.CurrentCamera
end)

return ShiftlockController
