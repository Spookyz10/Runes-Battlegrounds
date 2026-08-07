local TweenService = game:GetService("TweenService")

local UIFunctions = {}

local DARK_OFFSET_START = Vector2.new(0, -0.4)
local DARK_OFFSET_END = Vector2.new(0, 0.4)
local DARK_ROTATION = -90

local DARK_GRADIENT_TRANSPARENCY = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.49, 0),
	NumberSequenceKeypoint.new(0.51, 1),
	NumberSequenceKeypoint.new(1, 1),
})

local activeCooldownTweens: { [GuiObject]: Tween } = {}
local activeSlideTweens: { [GuiObject]: Tween } = {}
local typingSessions: { [TextLabel]: number } = {}

local function getGradient(darkIcon: GuiObject)
	return darkIcon and darkIcon:FindFirstChildOfClass("UIGradient")
end

function UIFunctions.ResetCooldownIcon(darkIcon: GuiObject)
	if not darkIcon then
		return
	end

	if activeCooldownTweens[darkIcon] then
		activeCooldownTweens[darkIcon]:Cancel()
		activeCooldownTweens[darkIcon] = nil
	end

	darkIcon.ImageTransparency = 1

	local grad = getGradient(darkIcon)
	if grad then
		grad.Transparency = DARK_GRADIENT_TRANSPARENCY
		grad.Rotation = DARK_ROTATION
		grad.Offset = DARK_OFFSET_START
	end
end

function UIFunctions.PlayCooldownFill(darkIcon: GuiObject, duration: number, onComplete: (() -> ())?)
	if not darkIcon then
		return
	end

	if activeCooldownTweens[darkIcon] then
		activeCooldownTweens[darkIcon]:Cancel()
		activeCooldownTweens[darkIcon] = nil
	end

	local grad = getGradient(darkIcon)

	if duration <= 0 or not grad then
		darkIcon.ImageTransparency = 1
		if onComplete then
			onComplete()
		end
		return
	end

	darkIcon.ImageTransparency = 0
	grad.Transparency = DARK_GRADIENT_TRANSPARENCY
	grad.Rotation = DARK_ROTATION
	grad.Offset = DARK_OFFSET_START

	local tween =
		TweenService:Create(grad, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Offset = DARK_OFFSET_END })
	activeCooldownTweens[darkIcon] = tween

	tween.Completed:Once(function(state)
		if activeCooldownTweens[darkIcon] == tween then
			activeCooldownTweens[darkIcon] = nil
		end
		if state == Enum.PlaybackState.Completed then
			darkIcon.ImageTransparency = 1
			if onComplete then
				onComplete()
			end
		end
	end)

	tween:Play()
end

function UIFunctions.SetCooldownProgress(darkIcon: GuiObject, alpha: number)
	if not darkIcon then
		return
	end

	if activeCooldownTweens[darkIcon] then
		activeCooldownTweens[darkIcon]:Cancel()
		activeCooldownTweens[darkIcon] = nil
	end

	alpha = math.clamp(alpha, 0, 1)

	if alpha >= 1 then
		UIFunctions.ResetCooldownIcon(darkIcon)
		return
	end

	local grad = getGradient(darkIcon)
	if not grad then
		return
	end

	darkIcon.ImageTransparency = 0
	grad.Transparency = DARK_GRADIENT_TRANSPARENCY
	grad.Rotation = DARK_ROTATION
	grad.Offset = DARK_OFFSET_START:Lerp(DARK_OFFSET_END, alpha)
end

function UIFunctions.TweenSlide(target: GuiObject, goal: UDim2, tweenInfo: TweenInfo, onComplete: (() -> ())?)
	if activeSlideTweens[target] then
		activeSlideTweens[target]:Cancel()
		activeSlideTweens[target] = nil
	end

	local tween = TweenService:Create(target, tweenInfo, { Position = goal })
	activeSlideTweens[target] = tween

	tween.Completed:Once(function(state)
		if activeSlideTweens[target] == tween then
			activeSlideTweens[target] = nil
		end
		if state == Enum.PlaybackState.Completed and onComplete then
			onComplete()
		end
	end)

	tween:Play()
	return tween
end

function UIFunctions.ApplyGradientTemplate(container: GuiObject, sourceFolder: Instance, templateName: string)
	for _, child in container:GetChildren() do
		if child:IsA("UIGradient") then
			child:Destroy()
		end
	end

	local template = sourceFolder:FindFirstChild(templateName)
	if template then
		template:Clone().Parent = container
	end
end

function UIFunctions.TypeText(
	label: TextLabel,
	text: string,
	charDelay: number?,
	onComplete: (() -> ())?
): (() -> (), () -> boolean)
	typingSessions[label] = (typingSessions[label] or 0) + 1
	local session = typingSessions[label]

	local delay = charDelay or 0.03
	local completed = false

	label.Text = ""

	local function finish()
		if completed or typingSessions[label] ~= session then
			return
		end

		completed = true
		label.Text = text

		if onComplete then
			onComplete()
		end
	end

	local function isComplete(): boolean
		return completed
	end

	task.spawn(function()
		for index = 1, #text do
			if typingSessions[label] ~= session or completed then
				return
			end

			label.Text = string.sub(text, 1, index)
			task.wait(delay)
		end

		finish()
	end)

	return finish, isComplete
end

return UIFunctions
