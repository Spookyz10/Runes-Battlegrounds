return {
	["get"] = function(TimeBetween)
		local ServerTime = workspace:GetServerTimeNow()
		
		if TimeBetween then
			return ServerTime - TimeBetween, ServerTime
		else
			return ServerTime
		end
	end
}