local AimDirections = require(script.Parent.Shared.AimDirections)

return function(Params)
	local ownerId = Params.ownerId
	local direction = Params.direction

	if not ownerId or typeof(direction) ~= "Vector3" then
		return
	end

	AimDirections[ownerId] = direction
end
