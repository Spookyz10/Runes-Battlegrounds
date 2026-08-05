local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local module = {}

local STORE_NAMES = {
	Kills = "Leaderboard_Kills_AllTime_v1",
	Donated = "Leaderboard_Donated_AllTime_v1",
}

local FLUSH_DEBOUNCE = 8
local CACHE_LIFETIME = 60
local TOP_COUNT = 10

local Stores = {}
for board, name in STORE_NAMES do
	Stores[board] = DataStoreService:GetOrderedDataStore(name)
end

local Pending = { Kills = {}, Donated = {} }
local FlushScheduled = { Kills = {}, Donated = {} }

local Cache = {
	Kills = { Data = nil, UpdatedAt = 0 },
	Donated = { Data = nil, UpdatedAt = 0 },
}

local function SafeUpdateAsync(store, key, delta)
	local attempts = 0
	while attempts < 5 do
		attempts += 1
		local ok = pcall(function()
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

local function FlushPlayerKey(board, userId)
	local delta = Pending[board][userId]
	if not delta or delta <= 0 then
		FlushScheduled[board][userId] = nil
		return
	end
	Pending[board][userId] = 0
	FlushScheduled[board][userId] = nil

	local key = tostring(userId)

	task.spawn(function()
		SafeUpdateAsync(Stores[board], key, delta)
	end)
end

local function ScheduleFlush(board, userId)
	if FlushScheduled[board][userId] then
		return
	end
	FlushScheduled[board][userId] = true
	task.delay(FLUSH_DEBOUNCE, function()
		FlushPlayerKey(board, userId)
	end)
end

local function AddValue(board, player, amount)
	if not player or not player:IsA("Player") then
		return
	end
	amount = amount or 1

	local userId = player.UserId
	Pending[board][userId] = (Pending[board][userId] or 0) + amount

	ScheduleFlush(board, userId)
end

function module:AddKill(player, amount)
	AddValue("Kills", player, amount)
end

function module:AddDonation(player, amount)
	AddValue("Donated", player, amount)
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
			Value = entry.value,
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

local function GetTop(board)
	local now = os.clock()
	if Cache[board].Data and (now - Cache[board].UpdatedAt) < CACHE_LIFETIME then
		return Cache[board].Data
	end

	local top = FetchTop(Stores[board])
	if top then
		Cache[board].Data = top
		Cache[board].UpdatedAt = now
	end

	return Cache[board].Data or {}
end

function module:GetTopKills()
	return GetTop("Kills")
end

function module:GetTopDonated()
	return GetTop("Donated")
end

local function FlushAllPending(board)
	for userId in Pending[board] do
		FlushPlayerKey(board, userId)
	end
end

Players.PlayerRemoving:Connect(function(player)
	FlushPlayerKey("Kills", player.UserId)
	FlushPlayerKey("Donated", player.UserId)
end)

game:BindToClose(function()
	FlushAllPending("Kills")
	FlushAllPending("Donated")
	task.wait(2)
end)

local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local LeaderboardsRemote = Remotes and Remotes:FindFirstChild("Leaderboards")
local LeaderboardsGet = LeaderboardsRemote and LeaderboardsRemote:FindFirstChild("Get")

if LeaderboardsGet then
	LeaderboardsGet.OnServerInvoke = function(Player, Board)
		if Board == "Kills" then
			return module:GetTopKills()
		elseif Board == "Donated" then
			return module:GetTopDonated()
		end
		return {}
	end
end

return module
