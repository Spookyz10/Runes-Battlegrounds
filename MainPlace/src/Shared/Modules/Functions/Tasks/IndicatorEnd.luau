local IndicatorService = require(script.Parent.Shared.IndicatorService)
local AimDirections = require(script.Parent.Shared.AimDirections)

return function(Params)
	local id = Params.id
	if not id then
		return
	end
	IndicatorService:Destroy(id)

	local ownerId = Params.ownerId
	if ownerId then
		AimDirections[ownerId] = nil
	end
end