local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server

local EloService = {}

local K_FACTOR = 32
local DEFAULT_ELO = 0
local MIN_ELO = 0

local function getPlayerElo(playerData)
	local elo = playerData.Elo()
	if typeof(elo) ~= "number" then
		return DEFAULT_ELO
	end
	return elo
end

local function getTeamAverageElo(MatchInstance, teamName)
	local team = MatchInstance:GetTeam(teamName)
	local total = 0
	local count = 0

	for _, playerState in team:GetPlayers() do
		local playerData = Data.Service:waitForData(playerState.Player)
		if playerData then
			total += getPlayerElo(playerData)
			count += 1
		end
	end

	if count == 0 then
		return DEFAULT_ELO
	end

	return total / count
end

local function getActualScore(teamName, MatchResult)
	if MatchResult.Draw then
		return 0.5
	end

	if MatchResult.Winner == teamName then
		return 1
	end

	return 0
end

function EloService:ProcessMatchResult(MatchInstance, MatchResult)
	local teamAverages = {}
	for _, teamName in MatchInstance.TeamOrder do
		teamAverages[teamName] = getTeamAverageElo(MatchInstance, teamName)
	end

	local deltas = {}

	for _, teamName in MatchInstance.TeamOrder do
		local team = MatchInstance:GetTeam(teamName)
		local actualScore = getActualScore(teamName, MatchResult)

		local opponentTeams = {}
		for _, otherTeamName in MatchInstance.TeamOrder do
			if otherTeamName ~= teamName then
				table.insert(opponentTeams, otherTeamName)
			end
		end

		if #opponentTeams == 0 then
			continue
		end

		for _, playerState in team:GetPlayers() do
			local Player = playerState.Player
			local playerData = Data.Service:waitForData(Player)
			if not playerData then
				continue
			end

			local playerElo = getPlayerElo(playerData)

			local totalDelta = 0

			for _, opponentTeamName in opponentTeams do
				local opponentElo = teamAverages[opponentTeamName]
				local expectedScore = 1 / (1 + 10 ^ ((opponentElo - playerElo) / 400))
				totalDelta += (K_FACTOR * (actualScore - expectedScore))
			end

			local averageDelta = totalDelta / #opponentTeams

			if MatchResult.Draw and averageDelta < 0 then
				averageDelta /= 2
			end

			deltas[Player] = averageDelta
		end
	end

	for Player, Delta in deltas do
		local playerData = Data.Service:waitForData(Player)
		if not playerData then
			continue
		end

		local RoundedDelta = math.round(Delta)
		local BeforeElo = getPlayerElo(playerData)

		playerData.Elo(function(currentElo)
			local BaseElo = typeof(currentElo) == "number" and currentElo or DEFAULT_ELO
			return math.max(MIN_ELO, BaseElo + RoundedDelta)
		end)

		print(
			"[EloService]",
			Player.Name,
			"Elo:",
			BeforeElo,
			"->",
			math.max(MIN_ELO, BeforeElo + RoundedDelta),
			"(",
			RoundedDelta >= 0 and ("+" .. RoundedDelta) or RoundedDelta,
			")"
		)
	end

	return deltas
end

return EloService
