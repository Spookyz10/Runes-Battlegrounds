local function HasProperty(Part: Part?, Property: string)
	return pcall(function()
		local _ = Part[Property]
	end)
end

return function(Character: Model, Time: number)
	for _, Part: Part? in Character:GetDescendants() do
		if HasProperty(Part, 'Transparency') and typeof(Part.Transparency) ~= 'NumberSequence' and Part.Transparency == 0 then
			Part:AddTag('BecomeVisible')
			
			Part.Transparency = 1
		end
	end
	
	task.wait(Time)
	
	for _, Part: Part? in Character:GetDescendants() do
		if Part:HasTag('BecomeVisible') then
			Part:RemoveTag('BecomeVisible')

			Part.Transparency = 0
		end
	end
end