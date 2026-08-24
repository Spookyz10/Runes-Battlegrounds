local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MemoryStoreService = game:GetService("MemoryStoreService")
local MessagingService = game:GetService("MessagingService")
local TeleportService = game:GetService("TeleportService")

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local ARENA_PLACE_ID = 74231996040153

local QUEUE_TTL = 1800
local TICK_INTERVAL = 4
local TICK_JITTER = 2
local MATCH_FOUND_TOPIC = "RankedMatchFound_v1"

local ModeConfigs = {
	["1v1"] = { NumberOfTeams = 2, PlayersPerTeam = 1, MaxLives = 2, FriendlyFire = false, TimeLimit = 600 },
}

local GlobalMatchmaking = {}

local LocalQueued = {} -- [Player] = { Mode = string, Key = string }

local function getMap(mode: string)
	return MemoryStoreService:GetSortedMap("RankedQueue_" .. mode)
end

local function fireClient(player: Player, kind: string, params: {}?)
	local ok = pcall(function()
		RemoteManager.FireClient(player, "RankedQueueUpdate", kind, params)
	end)
	if not ok then
		warn("[GlobalMatchmaking] Falha ao notificar cliente via RankedQueueUpdate")
	end
end

local function removeFromQueue(player: Player)
	local entry = LocalQueued[player]
	if not entry then
		return
	end

	local Map = getMap(entry.Mode)
	pcall(function()
		Map:RemoveAsync(entry.Key)
	end)

	LocalQueued[player] = nil
end

function GlobalMatchmaking.Join(player: Player, mode: string)
	if not player or not player.Parent then
		return { Success = false, Message = "JOGADOR INVÁLIDO" }
	end

	if not ModeConfigs[mode] then
		return { Success = false, Message = "MODO INVÁLIDO" }
	end

	if LocalQueued[player] then
		return { Success = false, Message = "VOCÊ JÁ ESTÁ NA FILA" }
	end

	local Map = getMap(mode)
	local Key = tostring(player.UserId)

	local Value = {
		UserId = player.UserId,
		JobId = game.JobId,
		JoinTime = os.time(),
	}

	local ok = pcall(function()
		Map:SetAsync(Key, Value, QUEUE_TTL)
	end)

	if not ok then
		return { Success = false, Message = "FALHA AO ENTRAR NA FILA, TENTE NOVAMENTE" }
	end

	LocalQueued[player] = { Mode = mode, Key = Key }

	print("[GlobalMatchmaking]", player.Name, "entrou na fila (" .. mode .. ")")

	return { Success = true }
end

function GlobalMatchmaking.Leave(player: Player)
	if not LocalQueued[player] then
		return { Success = false, Message = "VOCÊ NÃO ESTÁ NA FILA" }
	end

	removeFromQueue(player)

	print("[GlobalMatchmaking]", player.Name, "saiu da fila")

	return { Success = true }
end

local function requeueClaimed(mode: string, claimed)
	local Map = getMap(mode)
	for _, item in claimed do
		pcall(function()
			Map:SetAsync(item.key, item.value, QUEUE_TTL)
		end)
	end
end

local function assignTeams(mode: string, entries)
	local Config = ModeConfigs[mode]
	local UserIds = {}

	local index = 1
	for teamIndex = 1, Config.NumberOfTeams do
		for _ = 1, Config.PlayersPerTeam do
			local entry = entries[index]
			if entry then
				table.insert(UserIds, entry.value.UserId)
			end
			index += 1
		end
	end

	return UserIds
end

local function tryFormMatch(mode: string)
	local Config = ModeConfigs[mode]
	local Needed = Config.NumberOfTeams * Config.PlayersPerTeam

	local Map = getMap(mode)

	local ok, items = pcall(function()
		return Map:GetRangeAsync(Enum.SortDirection.Ascending, Needed)
	end)

	if not ok or not items or #items < Needed then
		return
	end

	local Candidates = {}
	for i = 1, Needed do
		table.insert(Candidates, items[i])
	end

	local Claimed = {}
	local AllClaimed = true

	for _, item in Candidates do
		local removeOk = pcall(function()
			Map:RemoveAsync(item.key)
		end)

		if removeOk then
			table.insert(Claimed, item)
		else
			AllClaimed = false
		end
	end

	if not AllClaimed then
		requeueClaimed(mode, Claimed)
		return
	end

	local UserIds = assignTeams(mode, Claimed)

	local reserveOk, Code = pcall(function()
		return TeleportService:ReserveServer(ARENA_PLACE_ID)
	end)

	if not reserveOk then
		warn("[GlobalMatchmaking] Falha ao reservar servidor da Arena, devolvendo jogadores para a fila")
		requeueClaimed(mode, Claimed)
		return
	end

	local Payload = {
		UserIds = UserIds,
		Code = Code,
		PlaceId = ARENA_PLACE_ID,
		MatchConfig = Config,
	}

	local publishOk = pcall(function()
		MessagingService:PublishAsync(MATCH_FOUND_TOPIC, Payload)
	end)

	if not publishOk then
		warn("[GlobalMatchmaking] Falha ao publicar match encontrado")
	end

	local IdsPrint = {}
	for _, id in UserIds do
		table.insert(IdsPrint, tostring(id))
	end

	print("[GlobalMatchmaking] Match formado (" .. mode .. "):", table.concat(IdsPrint, ", "))
end

local function matchmakingLoop()
	while true do
		task.wait(TICK_INTERVAL + math.random() * TICK_JITTER)

		for mode in ModeConfigs do
			local ok, err = pcall(tryFormMatch, mode)
			if not ok then
				warn("[GlobalMatchmaking] Erro no tick de", mode, ":", err)
			end
		end
	end
end

local function onMatchFound(message)
	local Payload = message.Data
	if typeof(Payload) ~= "table" or typeof(Payload.UserIds) ~= "table" then
		return
	end

	local LocalPlayersToTeleport = {}

	for _, userId in Payload.UserIds do
		local player = Players:GetPlayerByUserId(userId)
		if player then
			table.insert(LocalPlayersToTeleport, player)

			if LocalQueued[player] then
				LocalQueued[player] = nil
			end

			print("[GlobalMatchmaking] Partida encontrada para", player.Name)
			fireClient(player, "MatchFound")
		end
	end

	if #LocalPlayersToTeleport == 0 then
		return
	end

	local TeleportData = {
		MatchConfig = Payload.MatchConfig,
		UserIds = Payload.UserIds,
	}

	local ok, err = pcall(function()
		TeleportService:TeleportToPrivateServer(
			Payload.PlaceId,
			Payload.Code,
			LocalPlayersToTeleport,
			nil,
			TeleportData
		)
	end)

	if not ok then
		warn("[GlobalMatchmaking] Falha ao teleportar jogadores locais:", err)
		for _, player in LocalPlayersToTeleport do
			fireClient(player, "QueueLeftForcefully", { Message = "FALHA NO TELEPORT, TENTE NOVAMENTE" })
		end
	end
end

local function onPlayerRemoving(player: Player)
	removeFromQueue(player)
end

function GlobalMatchmaking.Init()
	local subscribeOk, err = pcall(function()
		MessagingService:SubscribeAsync(MATCH_FOUND_TOPIC, onMatchFound)
	end)

	if not subscribeOk then
		warn("[GlobalMatchmaking] Falha ao se inscrever no tópico de matchmaking:", err)
	end

	Players.PlayerRemoving:Connect(onPlayerRemoving)

	task.spawn(matchmakingLoop)
end

return GlobalMatchmaking
