local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ServerModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local StunHandler = require(ServerModules.StunHandler)
local EloService = require(ServerModules.EloService)

local MatchTypes = require(script.Parent.MatchTypes)
local Match = require(script.Parent.Match)

local RankedMapsFolder = ServerStorage:FindFirstChild("RankedMaps")

local CHARACTER_SELECTION_TIME = 15
local COUNTDOWN_TIME = 3

local ArenaController = {}
ArenaController.__index = ArenaController

local function getRandomPositionInPart(part: BasePart): Vector3
	local halfSize = part.Size / 2
	local randomOffset = Vector3.new((math.random() * 2 - 1) * halfSize.X, 0, (math.random() * 2 - 1) * halfSize.Z)

	return part.Position + randomOffset + Vector3.new(0, halfSize.Y + 3, 0)
end

local function shuffle(list)
	local result = table.clone(list)

	for i = #result, 2, -1 do
		local j = math.random(1, i)
		result[i], result[j] = result[j], result[i]
	end

	return result
end

function ArenaController.new(config: MatchTypes.MatchConfig)
	local self = setmetatable({}, ArenaController)

	self.MatchInstance = Match.new(config)
	self.Map = nil
	self.StunTokens = {}
	self.DeathConnections = {}
	self.Cancelled = false
	self.RoundTimerThread = nil
	self.LastResult = nil
	self.PlayerRemovingConnection = nil

	return self
end

function ArenaController:GetMatch()
	return self.MatchInstance
end

function ArenaController:SelectMap()
	assert(RankedMapsFolder, "ServerStorage.RankedMaps not found")

	local candidates = RankedMapsFolder:GetChildren()
	assert(#candidates > 0, "No maps available in ServerStorage.RankedMaps")

	local chosen = candidates[math.random(1, #candidates)]
	local clone = chosen:Clone()
	clone.Name = "Map"
	clone.Parent = workspace

	self.Map = clone

	print("[ArenaController] Map selecionado:", chosen.Name)

	return clone
end

function ArenaController:AssignPlayersToTeams(players: { Player })
	local teamOrder = self.MatchInstance.TeamOrder
	local playersPerTeam = self.MatchInstance.Config.PlayersPerTeam

	local shuffledPlayers = shuffle(players)

	local index = 1
	for _, teamName in teamOrder do
		for _ = 1, playersPerTeam do
			local player = shuffledPlayers[index]
			if not player then
				break
			end

			self.MatchInstance:AddPlayerToTeam(player, teamName)
			print("[ArenaController]", player.Name, "-> time", teamName)
			index += 1
		end
	end
end

function ArenaController:PositionPlayers()
	assert(self.Map, "Map must be selected before positioning players")

	local SpawnLocations = self.Map:FindFirstChild("SpawnLocations")
	assert(SpawnLocations, "map.SpawnLocations not found")

	for _, playerState in self.MatchInstance:GetAllPlayers() do
		local player = playerState.Player
		local Character = player.Character
		if not Character then
			continue
		end

		local SpawnPart = SpawnLocations:FindFirstChild(playerState.Team)
		if not SpawnPart then
			continue
		end

		local HumRP = Character:FindFirstChild("HumanoidRootPart")
		if not HumRP then
			continue
		end

		local targetPosition = getRandomPositionInPart(SpawnPart)
		local targetCFrame = CFrame.new(targetPosition)

		Character:PivotTo(targetCFrame)
		player:SetAttribute("ArenaSpawnCFrame", targetCFrame)

		Character:SetAttribute("MatchTeam", playerState.Team)
		Character:SetAttribute("MatchFriendlyFire", self.MatchInstance.Config.FriendlyFire)
		Character:SetAttribute("MatchId", self.MatchInstance.MatchId)
	end
end

function ArenaController:StunAllPlayers()
	for _, playerState in self.MatchInstance:GetAllPlayers() do
		local Character = playerState.Player.Character
		if not Character then
			continue
		end

		local token = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)
		self.StunTokens[playerState.UserId] = token
	end
end

function ArenaController:UnstunAllPlayers()
	for _, playerState in self.MatchInstance:GetAllPlayers() do
		local Character = playerState.Player.Character
		if not Character then
			continue
		end

		local token = self.StunTokens[playerState.UserId]
		if token then
			StunHandler:Unstun(Character, token)
			self.StunTokens[playerState.UserId] = nil
		end
	end
end

function ArenaController:BroadcastMessage(message: string)
	RemoteManager.FireAllClients("ReplicateTask", "SystemMessage", message)
end

function ArenaController:RunCharacterSelection()
	self.MatchInstance:SetState(MatchTypes.MatchState.CharacterSelection)

	print("[ArenaController] Seleção de personagem iniciada (", CHARACTER_SELECTION_TIME, "s )")

	self:StunAllPlayers()

	for _, playerState in self.MatchInstance:GetAllPlayers() do
		local Character = playerState.Player.Character
		if Character then
			Character:SetAttribute("AllowMovesetSwap", true)
		end
	end

	task.wait(CHARACTER_SELECTION_TIME)

	for _, playerState in self.MatchInstance:GetAllPlayers() do
		local Character = playerState.Player.Character
		if Character then
			Character:SetAttribute("AllowMovesetSwap", false)
		end
	end

	print("[ArenaController] Seleção de personagem encerrada")
end

function ArenaController:RunCountdown()
	if self.Cancelled then
		return
	end

	self.MatchInstance:SetState(MatchTypes.MatchState.Countdown)

	for i = COUNTDOWN_TIME, 1, -1 do
		if self.Cancelled then
			return
		end
		print("[ArenaController]", i)
		self:BroadcastMessage(tostring(i))
		task.wait(1)
	end

	if self.Cancelled then
		return
	end

	print("[ArenaController] START")
	self:BroadcastMessage("START")
end

function ArenaController:HandlePlayerDeath(playerState: MatchTypes.PlayerState)
	if self.Cancelled then
		return
	end
	if self.MatchInstance:GetState() ~= MatchTypes.MatchState.InProgress then
		return
	end

	self.MatchInstance:DamagePlayer(playerState.UserId, 1)

	local updatedState = self.MatchInstance:GetPlayerState(playerState.UserId)
	print(
		"[ArenaController]",
		playerState.Player.Name,
		"perdeu uma vida (",
		updatedState and updatedState.Lives or 0,
		"restantes )"
	)

	self:CheckMatchEnd()
end

function ArenaController:ConnectDeathTracking()
	for _, playerState in self.MatchInstance:GetAllPlayers() do
		local Character = playerState.Player.Character
		if not Character then
			continue
		end

		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if not Humanoid then
			continue
		end

		local connection = Humanoid.Died:Connect(function()
			self:HandlePlayerDeath(playerState)
		end)

		self.DeathConnections[playerState.UserId] = connection
	end
end

function ArenaController:DisconnectDeathTracking()
	for userId, connection in self.DeathConnections do
		connection:Disconnect()
		self.DeathConnections[userId] = nil
	end
end

function ArenaController:HandlePlayerLeft(player: Player)
	if self.Cancelled then
		return
	end

	local playerState = self.MatchInstance:GetPlayerState(player.UserId)
	if not playerState then
		return
	end

	print("[ArenaController]", player.Name, "saiu da partida")

	local connection = self.DeathConnections[player.UserId]
	if connection then
		connection:Disconnect()
		self.DeathConnections[player.UserId] = nil
	end

	local state = self.MatchInstance:GetState()

	if state == MatchTypes.MatchState.InProgress then
		local team = self.MatchInstance:GetPlayerTeam(player.UserId)
		if team then
			team:EliminatePlayer(player.UserId)
			print("[ArenaController]", player.Name, "foi eliminado por desconexão")
		end

		self:CheckMatchEnd()
	elseif
		state == MatchTypes.MatchState.Preparing
		or state == MatchTypes.MatchState.CharacterSelection
		or state == MatchTypes.MatchState.Countdown
	then
		print("[ArenaController] Jogador saiu antes do round começar, cancelando partida")
		self:AbortMatch()
	end
end

function ArenaController:BeginRound()
	if self.Cancelled then
		return
	end

	self.MatchInstance:SetState(MatchTypes.MatchState.InProgress)

	print("[ArenaController] Round iniciado (limite de", self.MatchInstance.Config.TimeLimit, "s )")

	self:UnstunAllPlayers()
	self:ConnectDeathTracking()

	for _, playerState in self.MatchInstance:GetAllPlayers() do
		local Character = playerState.Player.Character
		if Character then
			Character:SetAttribute("InRankedMatch", true)
		end
	end

	self.RoundTimerThread = task.delay(self.MatchInstance.Config.TimeLimit, function()
		self:ResolveByTimeLimit()
	end)
end

function ArenaController:CheckMatchEnd()
	if self.Cancelled then
		return
	end
	if self.MatchInstance:GetState() ~= MatchTypes.MatchState.InProgress then
		return
	end

	local winner = self.MatchInstance:CheckForWinner()
	if winner then
		print("[ArenaController] Time vencedor por eliminação:", winner)
		self:FinishMatch(MatchTypes.ResultReason.Elimination, winner, false)
	end
end

function ArenaController:ResolveByTimeLimit()
	if self.Cancelled then
		return
	end
	if self.MatchInstance:GetState() ~= MatchTypes.MatchState.InProgress then
		return
	end

	print("[ArenaController] Tempo limite atingido, calculando desempate")

	local aliveTeams = self.MatchInstance:GetAliveTeams()

	local bestLives = -1
	local bestTeams = {}

	for _, team in aliveTeams do
		local lives = team:GetTotalLivesRemaining()
		print("[ArenaController] Time", team.Name, "com", lives, "vidas restantes")
		if lives > bestLives then
			bestLives = lives
			bestTeams = { team }
		elseif lives == bestLives then
			table.insert(bestTeams, team)
		end
	end

	if #bestTeams == 1 then
		print("[ArenaController] Vencedor por tempo:", bestTeams[1].Name)
		self:FinishMatch(MatchTypes.ResultReason.TimeLimit, bestTeams[1].Name, false)
	else
		print("[ArenaController] Empate por tempo")
		self:FinishMatch(MatchTypes.ResultReason.TimeLimit, nil, true)
	end
end

function ArenaController:BuildMatchResult(Reason, WinnerTeamName, Draw)
	local TeamResults = {}
	local PlayerResults = {}
	local Losers = {}

	for _, teamName in self.MatchInstance.TeamOrder do
		local team = self.MatchInstance:GetTeam(teamName)

		TeamResults[teamName] = {
			Team = teamName,
			Eliminated = team:IsEliminated(),
			TotalLivesRemaining = team:GetTotalLivesRemaining(),
		}

		if teamName ~= WinnerTeamName then
			table.insert(Losers, teamName)
		end

		for _, playerState in team:GetPlayers() do
			PlayerResults[playerState.UserId] = {
				UserId = playerState.UserId,
				Team = playerState.Team,
				Lives = playerState.Lives,
				Eliminated = playerState.Eliminated,
			}
		end
	end

	return {
		Winner = WinnerTeamName,
		Losers = Losers,
		Draw = Draw == true,
		Reason = Reason,
		TeamResults = TeamResults,
		PlayerResults = PlayerResults,
	}
end

function ArenaController:FinishMatch(Reason, WinnerTeamName, Draw)
	if self.RoundTimerThread then
		task.cancel(self.RoundTimerThread)
		self.RoundTimerThread = nil
	end

	self.MatchInstance:SetState(MatchTypes.MatchState.Resolving)

	self:DisconnectDeathTracking()

	if self.PlayerRemovingConnection then
		self.PlayerRemovingConnection:Disconnect()
		self.PlayerRemovingConnection = nil
	end

	for _, playerState in self.MatchInstance:GetAllPlayers() do
		local Character = playerState.Player.Character
		if Character then
			Character:SetAttribute("InRankedMatch", false)
		end
	end

	local Result = self:BuildMatchResult(Reason or MatchTypes.ResultReason.Elimination, WinnerTeamName, Draw)
	self.LastResult = Result

	print("[ArenaController] Match finalizada. Reason:", Result.Reason, "Winner:", Result.Winner, "Draw:", Result.Draw)

	task.spawn(function()
		EloService:ProcessMatchResult(self.MatchInstance, Result)
	end)

	self.MatchInstance:SetState(MatchTypes.MatchState.Finished)

	return Result
end

function ArenaController:AbortMatch()
	if self.Cancelled then
		return
	end

	print("[ArenaController] Partida abortada")

	self:BroadcastMessage("PARTIDA CANCELADA - JOGADOR SAIU")

	for _, playerState in self.MatchInstance:GetAllPlayers() do
		local Character = playerState.Player.Character
		if Character then
			Character:SetAttribute("InRankedMatch", false)
		end
	end

	self:Cleanup()
end

function ArenaController:Cleanup()
	self.Cancelled = true

	if self.RoundTimerThread then
		task.cancel(self.RoundTimerThread)
		self.RoundTimerThread = nil
	end

	self:UnstunAllPlayers()
	self:DisconnectDeathTracking()

	if self.PlayerRemovingConnection then
		self.PlayerRemovingConnection:Disconnect()
		self.PlayerRemovingConnection = nil
	end

	for _, playerState in self.MatchInstance:GetAllPlayers() do
		local player = playerState.Player
		local Character = player.Character
		if Character then
			Character:SetAttribute("MatchTeam", nil)
			Character:SetAttribute("MatchFriendlyFire", nil)
			Character:SetAttribute("MatchId", nil)
			Character:SetAttribute("AllowMovesetSwap", nil)
			Character:SetAttribute("InRankedMatch", nil)
		end
		player:SetAttribute("ArenaSpawnCFrame", nil)
	end

	if self.Map and self.Map.Parent then
		self.Map:Destroy()
	end
	self.Map = nil

	print("[ArenaController] Cleanup concluído")
end

function ArenaController:StartMatch(players: { Player })
	self.MatchInstance:SetState(MatchTypes.MatchState.Preparing)

	print("[ArenaController] Iniciando partida com", #players, "jogadores")

	self.PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
		self:HandlePlayerLeft(player)
	end)

	self:SelectMap()
	self:AssignPlayersToTeams(players)
	self:PositionPlayers()

	self:RunCharacterSelection()
	self:RunCountdown()
	self:BeginRound()
end

return ArenaController
