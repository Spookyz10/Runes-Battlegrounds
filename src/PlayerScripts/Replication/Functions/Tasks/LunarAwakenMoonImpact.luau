local Constants = require(script.Parent.Shared.Constants)
local State = require(script.Parent.Shared.State)

return function(Params)
	local Character = Params.char
	local data = State.lunarData[Character]
	if not data then
		return
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
	State.lunarData[Character] = nil
end
