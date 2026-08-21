local CooldownSystem = {}

local ActiveCooldowns = {}

function CooldownSystem:Set(Entity, SkillId, Duration)
	if not Entity or not SkillId or not Duration then
		return
	end

	if not ActiveCooldowns[Entity] then
		ActiveCooldowns[Entity] = {}
	end

	ActiveCooldowns[Entity][SkillId] = os.clock() + Duration
end

function CooldownSystem:IsOnCooldown(Entity, SkillId)
	local EntityCooldowns = ActiveCooldowns[Entity]
	if not EntityCooldowns then
		return false
	end

	local Expiration = EntityCooldowns[SkillId]
	if not Expiration then
		return false
	end

	if os.clock() >= Expiration then
		EntityCooldowns[SkillId] = nil
		return false
	end

	return true
end

function CooldownSystem:GetRemaining(Entity, SkillId)
	local EntityCooldowns = ActiveCooldowns[Entity]
	if not EntityCooldowns then
		return 0
	end

	local Expiration = EntityCooldowns[SkillId]
	if not Expiration then
		return 0
	end

	local Remaining = Expiration - os.clock()
	if Remaining <= 0 then
		EntityCooldowns[SkillId] = nil
		return 0
	end

	return Remaining
end

function CooldownSystem:TryUse(Entity, SkillId, Duration)
	if CooldownSystem:IsOnCooldown(Entity, SkillId) then
		return false, CooldownSystem:GetRemaining(Entity, SkillId)
	end

	CooldownSystem:Set(Entity, SkillId, Duration)
	return true, Duration
end

function CooldownSystem:Clear(Entity, SkillId)
	local EntityCooldowns = ActiveCooldowns[Entity]
	if not EntityCooldowns then
		return
	end

	EntityCooldowns[SkillId] = nil
end

function CooldownSystem:ClearAll(Entity)
	ActiveCooldowns[Entity] = nil
end

function CooldownSystem:BindCleanup(Entity)
	if not Entity then
		return
	end

	local Connection
	Connection = Entity.Destroying:Connect(function()
		ActiveCooldowns[Entity] = nil
		if Connection then
			Connection:Disconnect()
		end
	end)

	return Connection
end

return CooldownSystem
