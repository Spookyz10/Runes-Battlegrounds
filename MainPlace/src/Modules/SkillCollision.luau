local SkillCollision = {}
local CharacterLifetime = require(script.Parent.CharacterLifetime)

local ActiveLocks = {}

function SkillCollision:Lock(Character)
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
	data.DisconnectLifetime = CharacterLifetime.Watch(Character, function()
		self:Unlock(Character, data)
	end)

	return data
end

function SkillCollision:Unlock(Character, data)
	if not Character then
		return
	end

	data = data or ActiveLocks[Character]
	if not data or ActiveLocks[Character] ~= data then
		return
	end

	ActiveLocks[Character] = nil
	if data.DisconnectLifetime then
		data.DisconnectLifetime()
	end

	for part, wasCollide in data.PartStates do
		if part and part.Parent then
			part.CanCollide = wasCollide
		end
	end
end

function SkillCollision:IsLocked(Character)
	return ActiveLocks[Character] ~= nil
end

return SkillCollision
