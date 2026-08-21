local NetworkOwnershipLock = {}

local Locks = setmetatable({}, { __mode = "k" })

function NetworkOwnershipLock:Take(Part: BasePart)
	if not Part then
		return
	end

	local Data = Locks[Part]
	if not Data then
		Data = { Count = 0 }
		Locks[Part] = Data

		pcall(function()
			if Part:CanSetNetworkOwnership() then
				Part:SetNetworkOwner(nil)
			end
		end)
	end

	Data.Count += 1
end

function NetworkOwnershipLock:Release(Part: BasePart, RestoreOwner: Player?)
	if not Part then
		return
	end

	local Data = Locks[Part]
	if not Data then
		return
	end

	Data.Count -= 1

	if Data.Count > 0 then
		return
	end

	Locks[Part] = nil

	if not Part.Parent then
		return
	end

	pcall(function()
		if Part:CanSetNetworkOwnership() then
			Part:SetNetworkOwner(RestoreOwner)
		end
	end)
end

function NetworkOwnershipLock:IsLocked(Part: BasePart)
	return Locks[Part] ~= nil
end

return NetworkOwnershipLock
