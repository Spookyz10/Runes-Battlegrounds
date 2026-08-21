local Module = {}

function Module.Start(Character, Params, Controller)
	Controller:PlayRig("Cataclysm", Character, Params)
end

function Module.End(Params, Controller)
	Controller:StopRig(Params and Params.SkipCameraSubject)
end

function Module.EndEarly(Controller)
	Controller:StopRig()
end

return Module
