local Module = {}

function Module.Start(Character, Params, Controller)
	Controller:PlayRig("SolarAwaken", Character, Params)
end

function Module.End(Params, Controller)
	Controller:StopRig()
end

function Module.EndEarly(Controller)
	Controller:StopRig()
end

return Module
