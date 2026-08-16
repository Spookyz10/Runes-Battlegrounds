local Loop = require(script.Parent.Loop)

local CameraShakeController = {}

local CameraShaker = nil
local ConfigFolder = nil

local xShake, yShake, zShake = 0, 0, 0
local stopCameraShakeLoop = nil

function CameraShakeController.Init(Camera, ShakerClass, RenderPriority)
	if CameraShaker then
		CameraShaker:Stop()
		CameraShaker = nil
	end

	CameraShaker = ShakerClass.new(RenderPriority, function(Offset)
		Camera.CFrame = Camera.CFrame * Offset
	end)
	CameraShaker:Start()
end

function CameraShakeController.GetOffset()
	return Vector3.new(xShake, yShake, zShake)
end

function CameraShakeController.AddShake(Shake, fadeOutTime)
	if ConfigFolder and ConfigFolder:FindFirstChild("Camera Shake") and ConfigFolder["Camera Shake"].Value == false then
		return
	end

	fadeOutTime = fadeOutTime or 0.5

	if not stopCameraShakeLoop then
		stopCameraShakeLoop = Loop.new(function()
			xShake = xShake * (math.random(1, 2) == 1 and -1 or 1)
			yShake = yShake * (math.random(1, 2) == 1 and -1 or 1)
			zShake = zShake * (math.random(1, 2) == 1 and -1 or 1)

			xShake = xShake * 0.85
			yShake = yShake * 0.85
			zShake = zShake * 0.85

			if math.abs(xShake) <= 0.05 and math.abs(yShake) <= 0.05 and math.abs(zShake) <= 0.05 then
				stopCameraShakeLoop()
				stopCameraShakeLoop = nil
			end
		end)
	end

	xShake = xShake + Shake * (math.random(1, 2) == 1 and -1 or 1)
	yShake = yShake + Shake * (math.random(1, 2) == 1 and -1 or 1)
	zShake = zShake + Shake * (math.random(1, 2) == 1 and -1 or 1)
end

function CameraShakeController.Shake(Magnitude, Roughness, FadeInTime, FadeOutTime, PositionInfluence)
	CameraShakeController.AddShake(Magnitude / 2)
end

function CameraShakeController.SustainShake(PresetName, shakeTime, fadeOutTime)
	if not CameraShaker then
		return
	end

	CameraShaker:ShakeSustain(CameraShaker.Presets[PresetName])

	task.delay(shakeTime, function()
		CameraShaker:StopSustained(fadeOutTime)
	end)
end

return CameraShakeController
