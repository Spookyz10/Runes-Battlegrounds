local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({ _handlers = {} }, Signal)
end

function Signal:Connect(fn)
	local handler = { fn = fn }
	table.insert(self._handlers, handler)

	return {
		Disconnect = function()
			local index = table.find(self._handlers, handler)
			if index then
				table.remove(self._handlers, index)
			end
		end,
	}
end

function Signal:Fire(...)
	for _, handler in self._handlers do
		task.spawn(handler.fn, ...)
	end
end

local CombatEvents = {}

CombatEvents.DamageDealt = Signal.new()

return CombatEvents
