local State = require(script.Parent.Shared.State)

return function(Params)
	local Character = Params.char
	local data = State.lunarData[Character]
	if not data then
		return
	end

	if data.moonConn then
		data.moonConn:Disconnect()
		data.moonConn = nil
	end
	if data.moonLaunchConn then
		data.moonLaunchConn:Disconnect()
		data.moonLaunchConn = nil
	end
	if data.moon and data.moon.Parent then
		data.moon:Destroy()
		data.moon = nil
	end
end
