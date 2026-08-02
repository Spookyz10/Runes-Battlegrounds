local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Freeze = require(ReplicatedStorage.Shared.Modules.Utility.Freeze)

local ACTIVE = {}

local Handlers = {}

function Handlers.Start(params)
	local char = params.char
	if not char or not char.Parent then
		return
	end

	local existing = ACTIVE[char]
	if existing then
		Freeze.Release(char, existing)
	end

	ACTIVE[char] = Freeze.Lock(char)
end

function Handlers.End(params)
	local char = params.char
	if not char then
		return
	end

	local lockHandle = ACTIVE[char]
	ACTIVE[char] = nil

	Freeze.Release(char, lockHandle, params.KeepRotationLock)
end

return function(params)
	local handler = Handlers[params.func]
	if handler then
		handler(params)
	end
end
