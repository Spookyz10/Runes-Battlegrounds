local Constants = require(script.Parent.Shared.Constants)
local State = require(script.Parent.Shared.State)

return function(Params)
	local Character = Params.char
	local data = State.lunarData[Character]
	if not data then
		return
	end

	if data.moonFog and data.moonFog.Parent then
		data.moonFog:Destroy()
		data.moonFog = nil
	end

	State.lunarData[Character] = nil
end
