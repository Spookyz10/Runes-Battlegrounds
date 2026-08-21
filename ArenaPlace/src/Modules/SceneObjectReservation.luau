local ServerStorage = game:GetService("ServerStorage")

local module = {}

local Reservations = {}

local DEFAULT_DURATION = 20

local function getCache()
	local Cache = ServerStorage:FindFirstChild("ModelCache")
	return Cache
end

local function getKey(Object)
	return Object
end

function module:Reserve(Object, SkillName, Owner, Duration, OnReturn)
	if not Object then
		return nil
	end

	local key = getKey(Object)

	if Reservations[key] then
		return nil
	end

	Duration = Duration or DEFAULT_DURATION

	local OriginalParent = Object.Parent
	local OriginalPivot = Object:GetPivot()

	local Clone = Object:Clone()

	Object.Parent = getCache()

	local Entry = {
		SkillName = SkillName,
		Owner = Owner,
		OnReturn = OnReturn,
		OriginalParent = OriginalParent,
		OriginalPivot = OriginalPivot,
		Clone = Clone,
		Handle = nil,
	}

	Entry.Handle = task.delay(Duration, function()
		module:Return(Object)
	end)

	Reservations[key] = Entry

	return Clone
end

function module:Return(Object)
	local key = getKey(Object)
	local Entry = Reservations[key]

	if not Entry then
		return false
	end

	Reservations[key] = nil

	if Entry.Handle then
		pcall(function()
			task.cancel(Entry.Handle)
		end)
	end

	if Entry.Clone and Entry.Clone.Parent then
		Entry.Clone:Destroy()
	end

	if Object and Object.Parent == getCache() then
		Object.Parent = Entry.OriginalParent
		Object:PivotTo(Entry.OriginalPivot)
	end

	if Entry.OnReturn then
		task.spawn(Entry.OnReturn, Object, Entry.SkillName, Entry.Owner)
	end

	return true
end

function module:IsReserved(Object)
	return Reservations[getKey(Object)] ~= nil
end

function module:GetReservation(Object)
	return Reservations[getKey(Object)]
end

function module:GetClone(Object)
	local Entry = Reservations[getKey(Object)]
	return Entry and Entry.Clone
end

function module:ReleaseAllFor(SkillName, Owner)
	for key, Entry in Reservations do
		if Entry.SkillName == SkillName and (Owner == nil or Entry.Owner == Owner) then
			module:Return(key)
		end
	end
end

return module
