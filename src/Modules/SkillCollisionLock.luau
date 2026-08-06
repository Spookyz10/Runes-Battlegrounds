local SkillCollisionLock = {}

local ActiveLocks = {}

function SkillCollisionLock:Lock(Character)
	if not Character then
		return nil
	end

	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return nil
	end

	if ActiveLocks[Character] then
		self:Unlock(Character)
	end

	local data = {

		PartStates = {},
	}

	for _, part in Character:GetDescendants() do
		if part:IsA("BasePart") then
			data.PartStates[part] = part.CanCollide
			part.CanCollide = false
		end
	end

	ActiveLocks[Character] = data

	return data
end

function SkillCollisionLock:Unlock(Character, data)
	if not Character then
		return
	end

	data = data or ActiveLocks[Character]
	if not data then
		return
	end

	ActiveLocks[Character] = nil

	for part, wasCollide in data.PartStates do
		if part and part.Parent then
			part.CanCollide = wasCollide
		end
	end
end

function SkillCollisionLock:IsLocked(Character)
	return ActiveLocks[Character] ~= nil
end

return SkillCollisionLock
