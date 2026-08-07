local IndicatorService = require(script.Parent.Shared.IndicatorService)

return function(Params)
	local id = Params.id
	if not id then
		return
	end
	IndicatorService:Destroy(id)
end
