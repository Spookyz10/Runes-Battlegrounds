local Constants = require(script.Parent.Shared.Constants)
local State = require(script.Parent.Shared.State)

return function(Params)
	local Character = Params.char
	local data = State.lunarData[Character]
	if data then
		if data.removingConnection then
			data.removingConnection:Disconnect()
		end
		if data.moonConn then
			data.moonConn:Disconnect()
		end
		if data.moonLaunchConn then
			data.moonLaunchConn:Disconnect()
		end
		if data.moon and data.moon.Parent then
			data.moon:Destroy()
		end
		if data.moonFog then
			data.moonFog:Destroy()
			data.moonFog = nil
		end
		State.lunarData[Character] = nil
	end
	if not State.launchedMoons[Character] then
		State:endNight("Lunar", Character)
	end
end
