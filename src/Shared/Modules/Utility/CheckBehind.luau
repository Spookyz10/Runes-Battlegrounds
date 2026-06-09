return function(Part1: BasePart, Part0: BasePart)
	local Character: Model = Part1.Parent
	local EnemyCharacter: Model = Part0.Parent
	
	local isBehind = false

	local displacementVector: Vector3 = Part0.Position - Part1.Position
	local direction: Vector3 = displacementVector.Unit
	local distance: number = displacementVector.Magnitude

	local character1LV: Vector3 = -Part0.CFrame.LookVector

	local angle: number = math.acos(character1LV:Dot(direction))
	if angle >= math.rad(90) then
		isBehind = true
	end
	
	local canHit = not EnemyCharacter:HasTag('Blocking') or (EnemyCharacter:HasTag('Blocking') and isBehind)

	return canHit
end
