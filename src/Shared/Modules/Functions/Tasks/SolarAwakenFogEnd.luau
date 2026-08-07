local State = require(script.Parent.Shared.State)

return function(Params)
	local Character = Params.char
	State.solarData = State.solarData or {}
	local data = State.solarData[Character]
	if not data then
		return
	end

	if data.solarFog and data.solarFog.Parent then
		data.solarFog:Destroy()
		data.solarFog = nil
	end
end
