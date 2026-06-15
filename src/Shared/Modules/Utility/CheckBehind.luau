return function(Part1, Part0)
	local EnemyCharacter = Part0.Parent

	local isBehind = false

	local displacementVector = Part0.Position - Part1.Position
	local direction = displacementVector.Unit

	local character1LV = -Part0.CFrame.LookVector

	local angle = math.acos(character1LV:Dot(direction))
	if angle >= math.rad(90) then
		isBehind = true
	end

	local canHit = not EnemyCharacter:HasTag("Blocking") or (EnemyCharacter:HasTag("Blocking") and isBehind)

	return canHit
end
