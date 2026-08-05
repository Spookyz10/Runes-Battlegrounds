local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local module = {}

local ALLTIME_STORE_NAME = "Leaderboard_Kills_AllTime_v1"
local MONTHLY_STORE_PREFIX = "Leaderboard_Kills_v1_"
local FLUSH_DEBOUNCE = 8
local CACHE_LIFETIME = 60
local TOP_COUNT = 10

local function GetMonthKey()
	return os.date("!%Y_%m")
end

local function GetMonthlyStore()
	return DataStoreService:GetOrderedDataStore(MONTHLY_STORE_PREFIX .. GetMonthKey())
end

local AllTimeStore = DataStoreService:GetOrderedDataStore(ALLTIME_STORE_NAME)

local PendingKills = {}
local FlushScheduled = {}

local Cache = {
	AllTime = { Data = nil, UpdatedAt = 0 },
	Monthly = { Data = nil, UpdatedAt = 0, MonthKey = GetMonthKey() },
}

local function SafeUpdateAsync(store, key, delta)
	local attempts = 0
	while attempts < 5 do
		attempts += 1
		local ok, err = pcall(function()
			store:UpdateAsync(key, function(old)
				return (old or 0) + delta
			end)
		end)
		if ok then
			return true
		end
		task.wait(1.5 * attempts)
	end
	return false
end

local function FlushPlayerKey(userId)
	local delta = PendingKills[userId]
	if not delta or delta <= 0 then
		FlushScheduled[userId] = nil
		return
	end
	PendingKills[userId] = 0
	FlushScheduled[userId] = nil

	local key = tostring(userId)

	task.spawn(function()
		SafeUpdateAsync(AllTimeStore, key, delta)
	end)
	task.spawn(function()
		SafeUpdateAsync(GetMonthlyStore(), key, delta)
	end)
end

local function ScheduleFlush(userId)
	if FlushScheduled[userId] then
		return
	end
	FlushScheduled[userId] = true
	task.delay(FLUSH_DEBOUNCE, function()
		FlushPlayerKey(userId)
	end)
end

function module:AddKill(player, amount)
	if not player or not player:IsA("Player") then
		return
	end
	amount = amount or 1

	local userId = player.UserId
	PendingKills[userId] = (PendingKills[userId] or 0) + amount

	ScheduleFlush(userId)
end

local function ResolveNames(entries)
	local result = {}
	for _, entry in entries do
		local userId = tonumber(entry.key)
		local name = "Unknown"

		local ok, info = pcall(function()
			return Players:GetNameFromUserIdAsync(userId)
		end)
		if ok and info then
			name = info
		end

		table.insert(result, {
			UserId = userId,
			Name = name,
			Kills = entry.value,
		})
	end
	return result
end

local function FetchTop(store)
	local ok, pages = pcall(function()
		return store:GetSortedAsync(false, TOP_COUNT)
	end)
	if not ok or not pages then
		return nil
	end

	local ok2, page = pcall(function()
		return pages:GetCurrentPage()
	end)
	if not ok2 then
		return nil
	end

	return ResolveNames(page)
end

function module:GetTopAllTime()
	local now = os.clock()
	if Cache.AllTime.Data and (now - Cache.AllTime.UpdatedAt) < CACHE_LIFETIME then
		return Cache.AllTime.Data
	end

	local top = FetchTop(AllTimeStore)
	if top then
		Cache.AllTime.Data = top
		Cache.AllTime.UpdatedAt = now
	end

	return Cache.AllTime.Data or {}
end

function module:GetTopMonthly()
	local now = os.clock()
	local currentMonthKey = GetMonthKey()

	if Cache.Monthly.MonthKey ~= currentMonthKey then
		Cache.Monthly.Data = nil
		Cache.Monthly.MonthKey = currentMonthKey
	end

	if Cache.Monthly.Data and (now - Cache.Monthly.UpdatedAt) < CACHE_LIFETIME then
		return Cache.Monthly.Data
	end

	local top = FetchTop(GetMonthlyStore())
	if top then
		Cache.Monthly.Data = top
		Cache.Monthly.UpdatedAt = now
	end

	return Cache.Monthly.Data or {}
end

local function FlushAllPending()
	for userId in PendingKills do
		FlushPlayerKey(userId)
	end
end

Players.PlayerRemoving:Connect(function(player)
	FlushPlayerKey(player.UserId)
end)

game:BindToClose(function()
	FlushAllPending()
	task.wait(2)
end)

return module
