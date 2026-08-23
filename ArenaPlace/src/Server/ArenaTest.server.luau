local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

if not RunService:IsStudio() then
	return
end

local ServerModules = ServerStorage.Modules
local ArenaController = require(ServerModules.ArenaController)

local TEST_NUMBER_OF_TEAMS = 2
local TEST_PLAYERS_PER_TEAM = 1
local TEST_MAX_LIVES = 2
local TEST_FRIENDLY_FIRE = false
local TEST_TIME_LIMIT = 600

local REQUIRED_PLAYERS = TEST_NUMBER_OF_TEAMS * TEST_PLAYERS_PER_TEAM
local CHARACTER_WAIT_TIMEOUT = 10

local started = false

local function waitForCharacters(players)
	local startTime = os.clock()

	for _, player in players do
		while not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") do
			if os.clock() - startTime > CHARACTER_WAIT_TIMEOUT then
				return false
			end
			task.wait()
		end
	end

	return true
end

local function tryStart()
	if started then
		return
	end

	local players = Players:GetPlayers()
	if #players < REQUIRED_PLAYERS then
		return
	end

	started = true

	print("[ArenaTestBootstrap] Jogadores suficientes conectados (", #players, "). Preparando partida de teste")

	task.spawn(function()
		local ready = waitForCharacters(players)
		if not ready then
			warn("[ArenaTestBootstrap] Timeout esperando characters, abortando")
			started = false
			return
		end

		local Controller = ArenaController.new({
			NumberOfTeams = TEST_NUMBER_OF_TEAMS,
			PlayersPerTeam = TEST_PLAYERS_PER_TEAM,
			MaxLives = TEST_MAX_LIVES,
			FriendlyFire = TEST_FRIENDLY_FIRE,
			TimeLimit = TEST_TIME_LIMIT,
		})

		Controller:StartMatch(players)
	end)
end

Players.PlayerAdded:Connect(tryStart)
task.spawn(tryStart)
