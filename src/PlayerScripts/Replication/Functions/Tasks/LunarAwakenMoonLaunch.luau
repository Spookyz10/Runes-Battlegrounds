local Constants = require(script.Parent.Shared.Constants)
local State = require(script.Parent.Shared.State)
local RunService = Constants.RunService

return function(Params)
	local Character = Params.char
	local ownerId = Params.ownerId
	local data = State.lunarData[Character]

	if not data or not data.moon or not data.moon.Parent then
		return
	end

	if data.moonConn then
		data.moonConn:Disconnect()
		data.moonConn = nil
	end

	if shared._indicators and ownerId and shared._indicators[ownerId] then
		local IndicatorEnd = require(script.Parent.IndicatorEnd)
		IndicatorEnd({ ownerId = ownerId })
	end

	local Moon = data.moon

	data.moon = nil
	State.launchedMoons[Character] = Moon

	local direction = Params.direction
	local speed = 80
	local launchConn

	launchConn = RunService.Heartbeat:Connect(function(dt)
		if not Moon or not Moon.Parent then
			launchConn:Disconnect()
			return
		end
		Moon.CFrame = Moon.CFrame + direction * speed * dt
	end)

	Moon.AncestryChanged:Once(function(_, parent)
		if not parent then
			launchConn:Disconnect()
		end
	end)
end
