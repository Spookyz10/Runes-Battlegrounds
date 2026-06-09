return function(Character: Model, Transparency: number)
	for _, Part: Part in Character:GetDescendants() do
		if require(script.Parent.PropChecker)(Part, 'Transparency') and typeof(Part.Transparency) == 'number' then
			if Transparency >= 1 then
				if Part.Transparency < 1 then
					Part.Transparency = Transparency
					Part:AddTag('AffectedByTransparency')
				end
			else
				if Part:HasTag('AffectedByTransparency') then
					Part:RemoveTag('AffectedByTransparency')

					Part.Transparency = Transparency
				end
			end
		end
	end
end