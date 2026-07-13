local State = require(script.Parent.Shared.State)

return function(Params)
	local Character = Params.char
	State.solarData = State.solarData or {}
	local data = State.solarData[Character]
	if data then
		if data.sunConn then
			data.sunConn:Disconnect()
		end
		if data.sunLaunchConn then
			data.sunLaunchConn:Disconnect()
		end
		if data.sun and data.sun.Parent then
			data.sun:Destroy()
		end
		if data.solarFog then
			data.solarFog:Destroy()
			data.solarFog = nil
		end
		State.solarData[Character] = nil
	end

	State.lunarNightCount = math.max(0, State.lunarNightCount - 1)
	if State.lunarNightCount <= 0 then
		State:tweenToDay()
	end
end
