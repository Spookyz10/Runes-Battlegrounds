return function(Distance, Center: Vector3, CheckFunction)
	local DetectedCharacters = {}
	
	for _, Character: Model in workspace.Live:GetChildren() do
		if not Character.PrimaryPart then continue end
		
		if (Character.PrimaryPart.Position - Center).Magnitude <= Distance and (not CheckFunction or CheckFunction(Character) == true) then
			table.insert(DetectedCharacters, Character)
		end
	end
	
	return DetectedCharacters
end