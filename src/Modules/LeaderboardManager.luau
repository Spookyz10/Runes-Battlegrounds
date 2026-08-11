local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server

local module = {}

local STORE_NAMES = {
	Kills = "Leaderboard_Kills_AllTime_v1",
	Donated = "Leaderboard_Donated_AllTime_v1",
}

local DATA_KEYS = {
	Kills = "TotalKills",
	Donated = "Donated",
}

local SYNC_INTERVAL = 60
local CACHE_LIFETIME = 60
local TOP_COUNT = 10

local Stores = {}
for board, name in STORE_NAMES do
	Stores[board] = DataStoreService:GetOrderedDataStore(name)
end

local Cache = {
	Kills = { Data = nil, UpdatedAt = 0 },
	Donated = { Data = nil, UpdatedAt = 0 },
}

local LastSynced = { Kills = {}, Donated = {} }

local function SafeUpdateAsync(store, key, value)
	local attempts = 0
	while attempts < 5 do
		attempts += 1
		local ok = pcall(function()
			store:UpdateAsync(key, function()
				return value
			end)
		end)
		if ok then
			return true
		end
		task.wait(1.5 * attempts)
	end
	return false
end

local function SyncPlayer(board, player)
	if not player or not player:IsA("Player") then
		return
	end

	local dataKey = DATA_KEYS[board]
	local playerData = Data.Service:waitForData(player)
	if not playerData then
		return
	end

	local ok, currentValue = pcall(function()
		return playerData[dataKey]()
	end)
	if not ok or not currentValue then
		return
	end

	if LastSynced[board][player.UserId] == currentValue then
		return
	end

	local key = tostring(player.UserId)

	task.spawn(function()
		local success = SafeUpdateAsync(Stores[board], key, currentValue)
		if success then
			LastSynced[board][player.UserId] = currentValue
		end
	end)
end

local function SyncAllBoards(player)
	for board in STORE_NAMES do
		SyncPlayer(board, player)
	end
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
	print(result)
	return result
end

local function FetchTop(store)
	local ok, pages = pcall(function()
		return store:GetSortedAsync(false, TOP_COUNT)
	end)
	if not ok then
		warn("[Leaderboard] GetSortedAsync falhou:", pages)
		return nil
	end
	if not pages then
		warn("[Leaderboard] pages veio nil sem erro")
		return nil
	end

	local ok2, page = pcall(function()
		return pages:GetCurrentPage()
	end)
	if not ok2 then
		warn("[Leaderboard] GetCurrentPage falhou:", page)
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

Players.PlayerAdded:Connect(function(player)
	task.spawn(function()
		local ok = pcall(function()
			return Data[player] ~= nil
		end)
		while not ok or not Data[player] do
			task.wait(1)
			ok = pcall(function()
				return Data[player] ~= nil
			end)
			if not player.Parent then
				return
			end
		end
		SyncAllBoards(player)
	end)
end)

for _, player in Players:GetPlayers() do
	task.spawn(SyncAllBoards, player)
end

Players.PlayerRemoving:Connect(function(player)
	SyncAllBoards(player)
end)

task.spawn(function()
	while true do
		task.wait(SYNC_INTERVAL)
		for _, player in Players:GetPlayers() do
			SyncAllBoards(player)
		end
	end
end)

game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		SyncAllBoards(player)
	end
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
