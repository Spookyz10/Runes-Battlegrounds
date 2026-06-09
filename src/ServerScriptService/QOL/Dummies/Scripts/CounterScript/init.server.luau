local Character = script.Parent

local CounterModule = require(script.Counter)

if CounterModule and CounterModule["Start"] then
	coroutine.wrap(function()
		CounterModule.Start(Character)
	end)()
end