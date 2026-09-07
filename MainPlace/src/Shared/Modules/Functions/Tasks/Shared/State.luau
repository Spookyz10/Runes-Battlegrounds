local Constants = require(script.Parent.Constants)
local Lighting = Constants.Lighting
local TS = Constants.TS

local state = {
	lunarData = {},
	solarData = {},
	launchedMoons = {},
	lunarNightCount = 0,
	nightOwners = { Lunar = {}, Solar = {} },
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

function state:beginNight(mode, character)
	if self.nightOwners[mode][character] then
		return
	end
	self.nightOwners[mode][character] = true
	self.lunarNightCount += 1
	if self.lunarNightCount == 1 then
		self:tweenToNight()
	end
end

function state:endNight(mode, character)
	if not self.nightOwners[mode][character] then
		return
	end
	self.nightOwners[mode][character] = nil
	self.lunarNightCount = math.max(0, self.lunarNightCount - 1)
	if self.lunarNightCount == 0 then
		self:tweenToDay()
	end
end

return state
