local Players = game:GetService("Players")

local LiveOverlapParams = OverlapParams.new()
LiveOverlapParams.FilterType = Enum.RaycastFilterType.Include
LiveOverlapParams.FilterDescendantsInstances = { workspace.Live }

export type HitboxParams = {
	Instance: BasePart,
	Offset: CFrame,
	Size: Vector3,
	Ignore: { Model },
}

return function(Params: HitboxParams): { Model }?
	local touchedCharacters: { Model } = {}
	local closestCharacter: Model? = nil

	local HitboxCFrame = Params.Instance.CFrame * Params.Offset
	local touchingParts = workspace:GetPartBoundsInBox(HitboxCFrame, Params.Size, LiveOverlapParams)

	for _, Part in touchingParts do
		if not (Part and Part.Parent) then
			continue
		end

		local EnemyCharacter = Part.Parent :: Model
		local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
		if EnemyPlayer and not EnemyPlayer:FindFirstChild("LoadedData") then
			continue
		end

		local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
		if
			not EnemyHumanoid
			or table.find(touchedCharacters, EnemyCharacter)
			or table.find(Params.Ignore, EnemyCharacter)
		then
			continue
		end

		table.insert(touchedCharacters, EnemyCharacter)

		if not closestCharacter then
			closestCharacter = EnemyCharacter
		elseif
			(EnemyCharacter.HumanoidRootPart.Position - HitboxCFrame.Position).Magnitude
			< (closestCharacter.HumanoidRootPart.Position - HitboxCFrame.Position).Magnitude
		then
			closestCharacter = EnemyCharacter
		end
	end

	if #touchedCharacters == 0 or not closestCharacter then
		return nil
	end

	if touchedCharacters[1] ~= closestCharacter then
		local ordered = table.clone(touchedCharacters)
		touchedCharacters[1] = closestCharacter
		for i = 2, #touchedCharacters do
			touchedCharacters[i] = ordered[i - 1]
		end
	end

	return touchedCharacters
end
