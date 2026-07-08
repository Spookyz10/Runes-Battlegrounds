local RotationController = require(script.Parent.Shared.RotationController)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local BIND_NAME = "LunarAimCameraFollow"

return function(Params)
	shared._lunarAimActive = true
	shared._lunarAimDirection = workspace.CurrentCamera.CFrame.LookVector

	local LocalPlayer = Players.LocalPlayer
	local Character = LocalPlayer.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local HumRP = Character and Character:FindFirstChild("HumanoidRootPart")
	local Torso = Character and Character:FindFirstChild("Torso")
	local Camera = workspace.CurrentCamera

	local Anchor = nil

	if Torso and HumRP and Humanoid then
		Anchor = Instance.new("Part")
		Anchor.Name = "LunarAimCameraAnchor"
		Anchor.Anchored = true
		Anchor.CanCollide = false
		Anchor.CanTouch = false
		Anchor.CanQuery = false
		Anchor.Transparency = 1
		Anchor.Size = Vector3.new(0.2, 0.2, 0.2)
		Anchor.Parent = workspace

		-- Roda ANTES do módulo de câmera nativo (Camera priority), pra não
		-- ter 1 frame de atraso e evitar jitter.
		RunService:BindToRenderStep(BIND_NAME, Enum.RenderPriority.Camera.Value - 1, function()
			if not Torso or not Torso.Parent or not HumRP or not HumRP.Parent then
				return
			end
			-- Posição real do Torso (segue a animação), mas ROTAÇÃO do
			-- HumanoidRootPart (estável, só muda via RotationController).
			-- Isso evita que a câmera "sinta" a rotação dos ossos animados.
			Anchor.CFrame = CFrame.new(Torso.Position) * (HumRP.CFrame - HumRP.Position)
		end)

		Camera.CameraSubject = Anchor
	end

	local duration = Params.Duration or 5
	local startTime = tick()

	local function restoreCamera()
		pcall(function()
			RunService:UnbindFromRenderStep(BIND_NAME)
		end)
		if Humanoid then
			Camera.CameraSubject = Humanoid
		end
		if Anchor then
			Anchor:Destroy()
			Anchor = nil
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
