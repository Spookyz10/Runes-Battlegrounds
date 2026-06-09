return function(Object: Instance, Property: string)
	local Success, Error = pcall(function()
		local _ = Object[Property]
	end)
	
	return Success
end