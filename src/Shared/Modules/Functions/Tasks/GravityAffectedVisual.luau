local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(script.Parent.Shared.Constants)

local TS = Constants.TS
local Lighting = Constants.Lighting

local CameraShakeController = require(ReplicatedStorage.Shared.Modules.Functions.CameraShakerController)

local CC_NAME = "GravityAffectedCC"
local BLUR_NAME = "GravityAffectedBlur"

local TWEEN_TIME = 0.6
local SHAKE_INTERVAL = 0.25
local SHAKE_INTENSITY = 1.2

local active = false
local shakeThread = nil

local function getEffects()
	local CC = Lighting:FindFirstChild(CC_NAME)
	if not CC then
		CC = Instance.new("ColorCorrectionEffect")
		CC.Name = CC_NAME
		CC.Brightness = 0
		CC.Contrast = 0
		CC.Saturation = 0
		CC.TintColor = Color3.new(1, 1, 1)
		CC.Parent = Lighting
	end

	local Blur = Lighting:FindFirstChild(BLUR_NAME)
	if not Blur then
		Blur = Instance.new("BlurEffect")
		Blur.Name = BLUR_NAME
		Blur.Size = 0
		Blur.Parent = Lighting
	end

	return CC, Blur
end

local Handlers = {}

function Handlers.Start(_params)
	if active then
		return
	end
	active = true

	local CC, Blur = getEffects()

	TS:Create(CC, TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Brightness = -0.25,
		Contrast = 0.15,
		Saturation = -0.6,
		TintColor = Color3.fromRGB(180, 190, 210),
	}):Play()

	TS:Create(Blur, TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = 10,
	}):Play()

	shakeThread = task.spawn(function()
		while active do
			CameraShakeController.AddShake(SHAKE_INTENSITY)
			task.wait(SHAKE_INTERVAL)
		end
	end)
end

function Handlers.Stop(_params)
	if not active then
		return
	end
	active = false

	if shakeThread then
		task.cancel(shakeThread)
		shakeThread = nil
	end

	local CC = Lighting:FindFirstChild(CC_NAME)
	local Blur = Lighting:FindFirstChild(BLUR_NAME)

	if CC then
		TS:Create(CC, TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Brightness = 0,
			Contrast = 0,
			Saturation = 0,
			TintColor = Color3.new(1, 1, 1),
		}):Play()
	end

	if Blur then
		TS:Create(Blur, TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = 0,
		}):Play()
	end
end

return function(params)
	local Handler = Handlers[params.func]
	if Handler then
		Handler(params)
	end
end
