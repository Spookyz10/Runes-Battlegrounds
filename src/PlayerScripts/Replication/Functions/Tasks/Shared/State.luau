local Constants = require(script.Parent.Constants)
local Lighting = Constants.Lighting
local TS = Constants.TS
local RunService = Constants.RunService

local state = {
	lunarData = {},
	lunarNightCount = 0,
	nightTween = nil,
	dayTween = nil,
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

return state
