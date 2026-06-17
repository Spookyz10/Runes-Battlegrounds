local Constants = require(script.Parent.Shared.Constants)
local State = require(script.Parent.Shared.State)
local RunService = Constants.RunService

return function(Params)
	local Character = Params.char
	local data = State.lunarData[Character]
	if not data or not data.moon or not data.moon.Parent then
		return
	end

	if data.moonConn then
		data.moonConn:Disconnect()
		data.moonConn = nil
	end

	if data.moonFog and data.moonFog.Parent then
		data.moonFog:Destroy()
		data.moonFog = nil
	end

	local Moon = data.moon
	local direction = Params.direction
	local speed = 80

	local launchConn
	launchConn = RunService.Heartbeat:Connect(function(dt)
		if not Moon or not Moon.Parent then
			launchConn:Disconnect()
			if data then
				data.moonLaunchConn = nil
			end
			return
		end
		Moon.CFrame = Moon.CFrame + direction * speed * dt
	end)
	data.moonLaunchConn = launchConn
end
