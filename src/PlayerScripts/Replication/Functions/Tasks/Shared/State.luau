local Constants = require(script.Parent.Constants)
local Lighting = Constants.Lighting
local TS = Constants.TS
local RunService = Constants.RunService

local state = {
	EclipseNightTime = 0,
	lunarData = {},
	lunarNightCount = 0,
	nightTween = nil,
	dayTween = nil,
	tweenToNight = nil,
	tweenToDay = nil,
}

function state:tweenToNight()
	if self.dayTween then
		self.dayTween:Cancel()
		self.dayTween = nil
	end
	self.nightTween =
		TS:Create(Lighting, TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), { ClockTime = 0 })
	self.nightTween:Play()
end

function state:tweenToDay()
	if self.nightTween then
		self.nightTween:Cancel()
		self.nightTween = nil
	end
	self.dayTween =
		TS:Create(Lighting, TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ClockTime = 12 })
	self.dayTween:Play()
end

-- Background loops (originally at bottom of Client Tasks)
RunService.RenderStepped:Connect(function()
	if state.EclipseNightTime > 0 then
		Lighting.TimeOfDay = "00:00:00"
	else
		Lighting.TimeOfDay = "12:00:00"
	end
end)

task.spawn(function()
	while true do
		task.wait(1)
		if state.EclipseNightTime > 0 then
			state.EclipseNightTime -= 1
		end
	end
end)

return state
