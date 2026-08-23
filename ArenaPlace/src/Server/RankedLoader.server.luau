local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local ServerStorage = game:GetService("ServerStorage")

local ServerModules = ServerStorage.Modules
local ArenaController = require(ServerModules.ArenaController)
local MatchTypes = require(ServerModules.MatchTypes)

local MAIN_PLACE_ID = 127260051609429

local PLAYER_JOIN_TIMEOUT = 30
local POST_MATCH_WAIT = 5
local TELEPORT_RETRY_ATTEMPTS = 3
local TELEPORT_RETRY_DELAY = 2

local function getTeleportData(player: Player)
	local joinData = player:GetJoinData()
	return joinData and joinData.TeleportData
end

local function waitForExpectedPlayers(expectedUserIds, timeout)
	local deadline = os.clock() + timeout

	while os.clock() < deadline do
		local allPresent = true

		for _, userId in expectedUserIds do
			if not Players:GetPlayerByUserId(userId) then
				allPresent = false
				break
			end
		end

		if allPresent then
			return true
		end

		task.wait(0.5)
	end

	return false
end

local function teleportPlayersBack(players)
	if #players == 0 then
		return
	end

	for attempt = 1, TELEPORT_RETRY_ATTEMPTS do
		local Ok = pcall(function()
			TeleportService:TeleportAsync(MAIN_PLACE_ID, players)
		end)

		if Ok then
			return
		end

		task.wait(TELEPORT_RETRY_DELAY)
	end

	for _, player in players do
		if player and player.Parent then
			player:Kick("Não foi possível retornar ao lobby, entre novamente.")
		end
	end
end

local function run()
	local FirstPlayer = Players:GetPlayers()[1]
	if not FirstPlayer then
		FirstPlayer = Players.PlayerAdded:Wait()
	end

	local TeleportData = getTeleportData(FirstPlayer)
	if typeof(TeleportData) ~= "table" then
		warn("[RankedLoader] TeleportData ausente, abortando")
		return
	end

	local Config = TeleportData.MatchConfig
	local ExpectedUserIds = TeleportData.UserIds

	if typeof(Config) ~= "table" or typeof(ExpectedUserIds) ~= "table" then
		warn("[RankedLoader] TeleportData inválido, abortando")
		return
	end

	waitForExpectedPlayers(ExpectedUserIds, PLAYER_JOIN_TIMEOUT)

	local ConnectedPlayers = {}
	for _, userId in ExpectedUserIds do
		local player = Players:GetPlayerByUserId(userId)
		if player then
			table.insert(ConnectedPlayers, player)
		end
	end

	if #ConnectedPlayers == 0 then
		warn("[RankedLoader] Nenhum jogador presente, abortando")
		return
	end

	local ArenaControllerInstance = ArenaController.new(Config)

	ArenaControllerInstance:StartMatch(ConnectedPlayers)

	while true do
		task.wait(1)

		if ArenaControllerInstance.Cancelled then
			break
		end

		if ArenaControllerInstance.MatchInstance:GetState() == MatchTypes.MatchState.Finished then
			break
		end
	end

	if not ArenaControllerInstance.Cancelled then
		ArenaControllerInstance:Cleanup()
	end

	task.wait(POST_MATCH_WAIT)

	teleportPlayersBack(Players:GetPlayers())
end

local Ok, Err = pcall(run)
if not Ok then
	warn("[RankedLoader] Erro fatal:", Err)
	for _, player in Players:GetPlayers() do
		player:Kick("Erro ao inicializar a partida.")
	end
end
