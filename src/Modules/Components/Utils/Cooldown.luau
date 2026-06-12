local Cooldown = {}
local CooldownTable = {}

function Cooldown.Add(Character, Moveset, Skillname, Cooldown)
	if not CooldownTable[Character] then
		CooldownTable[Character] = {}
	end

	if not CooldownTable[Character][Moveset] then
		CooldownTable[Character][Moveset] = {}
	end

	CooldownTable[Character][Moveset][Skillname] = tick() + Cooldown
end

function Cooldown.Check(Character, Moveset, Skillname)
	if CooldownTable[Character] and CooldownTable[Character][Moveset] then
		local ExpirationTime = CooldownTable[Character][Moveset][Skillname]
		if ExpirationTime and tick() < ExpirationTime then
			return false
		end
	end

	return true
end

function Cooldown.Remove(Character, Moveset, Skillname)
	if CooldownTable[Character] and CooldownTable[Character][Moveset] then
		CooldownTable[Character][Moveset][Skillname] = nil
	end
end

function Cooldown.RemoveAll(Character)
	if CooldownTable[Character] then
		CooldownTable[Character] = {}
	end
end

return Cooldown