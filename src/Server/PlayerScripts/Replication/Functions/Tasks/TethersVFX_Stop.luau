local TethersVFXState = require(script.Parent.Shared.TethersVFXState)

local activeVFX = TethersVFXState.activeVFX

local function getKey(casterChar)
	return tostring(casterChar)
end

return function(params)
	local casterChar = params.casterChar
	if not casterChar then
		return
	end

	local key = getKey(casterChar)
	local entry = activeVFX[key]
	if not entry then
		return
	end

	for _, c in entry.chains or {} do
		if c.chain and c.chain.Parent then
			c.chain:Destroy()
		end
		if c.victimPart and c.victimPart.Parent then
			c.victimPart:Destroy()
		end
	end

	for _, part in entry.armParts or {} do
		if part and part.Parent then
			part:Destroy()
		end
	end

	activeVFX[key] = nil
end
