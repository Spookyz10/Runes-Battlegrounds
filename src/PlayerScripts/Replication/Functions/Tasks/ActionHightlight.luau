local TweenService = game:GetService("TweenService")

local FLASH_IN_TIME = 0.05
local FLASH_OUT_TIME = 0.18
local HOLD_IN_TIME = 0.08
local HOLD_OUT_TIME = 0.15

local WHITE = Color3.new(1, 1, 1)

local State = {}

local function getHighlight(Character)
	local Highlight = Character:FindFirstChild("ActionHighlight")
	if Highlight then
		return Highlight
	end

	Highlight = Instance.new("Highlight")
	Highlight.Name = "ActionHighlight"
	Highlight.FillColor = WHITE
	Highlight.OutlineColor = WHITE
	Highlight.FillTransparency = 1
	Highlight.OutlineTransparency = 1
	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	Highlight.Parent = Character

	return Highlight
end

local function getState(Character)
	if not State[Character] then
		State[Character] = { Holding = false, Tween = nil }

		Character.Destroying:Once(function()
			State[Character] = nil
		end)
	end

	return State[Character]
end

local function flash(Character)
	local Highlight = getHighlight(Character)
	local data = getState(Character)

	if data.Holding then
		return
	end

	if data.Tween then
		data.Tween:Cancel()
	end

	Highlight.FillTransparency = 1
	Highlight.OutlineTransparency = 1

	local tweenIn = TweenService:Create(
		Highlight,
		TweenInfo.new(FLASH_IN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ FillTransparency = 0, OutlineTransparency = 0 }
	)

	local tweenOut = TweenService:Create(
		Highlight,
		TweenInfo.new(FLASH_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ FillTransparency = 1, OutlineTransparency = 1 }
	)

	data.Tween = tweenIn
	tweenIn:Play()

	tweenIn.Completed:Once(function(state)
		if state ~= Enum.PlaybackState.Completed then
			return
		end
		if data.Holding then
			return
		end

		data.Tween = tweenOut
		tweenOut:Play()
	end)
end

local function hold(Character)
	local Highlight = getHighlight(Character)
	local data = getState(Character)

	data.Holding = true

	if data.Tween then
		data.Tween:Cancel()
	end

	local tween = TweenService:Create(
		Highlight,
		TweenInfo.new(HOLD_IN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ FillTransparency = 0, OutlineTransparency = 0 }
	)

	data.Tween = tween
	tween:Play()
end

local function release(Character)
	local Highlight = Character:FindFirstChild("ActionHighlight")
	local data = getState(Character)

	data.Holding = false

	if not Highlight then
		return
	end

	if data.Tween then
		data.Tween:Cancel()
	end

	local tween = TweenService:Create(
		Highlight,
		TweenInfo.new(HOLD_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ FillTransparency = 1, OutlineTransparency = 1 }
	)

	data.Tween = tween
	tween:Play()
end

return function(params)
	local Character = params.char
	if not Character then
		return
	end

	local func = params.func

	if func == "Hit" or func == "Dash" or func == "M1" then
		flash(Character)
	elseif func == "BlockStart" then
		hold(Character)
	elseif func == "BlockEnd" then
		release(Character)
	end
end
