local MatchTypes = require(script.Parent.MatchTypes)

local Team = {}
Team.__index = Team

function Team.new(teamName: string, maxLives: number)
	local self = setmetatable({}, Team)

	self.Name = teamName
	self.MaxLives = maxLives
	self.Players = {}
	self.Eliminated = false

	return self
end

function Team:AddPlayer(player: Player)
	local state: MatchTypes.PlayerState = {
		Player = player,
		UserId = player.UserId,
		Team = self.Name,
		Lives = self.MaxLives,
		Eliminated = false,
	}

	self.Players[player.UserId] = state

	return state
end

function Team:GetPlayerState(userId: number): MatchTypes.PlayerState?
	return self.Players[userId]
end

function Team:RemoveLife(userId: number, amount: number?)
	local state = self.Players[userId]
	if not state or state.Eliminated then
		return
	end

	local lossAmount = amount or 1
	state.Lives = math.max(0, state.Lives - lossAmount)

	if state.Lives <= 0 then
		state.Eliminated = true
	end

	self:RefreshEliminationStatus()
end

function Team:EliminatePlayer(userId: number)
	local state = self.Players[userId]
	if not state or state.Eliminated then
		return
	end

	state.Lives = 0
	state.Eliminated = true

	self:RefreshEliminationStatus()
end

function Team:RefreshEliminationStatus()
	for _, state in self.Players do
		if not state.Eliminated then
			self.Eliminated = false
			return
		end
	end

	self.Eliminated = true
end

function Team:IsEliminated(): boolean
	return self.Eliminated
end

function Team:GetTotalLivesRemaining(): number
	local total = 0
	for _, state in self.Players do
		total += state.Lives
	end
	return total
end

function Team:GetPlayers(): { MatchTypes.PlayerState }
	local list = {}
	for _, state in self.Players do
		table.insert(list, state)
	end
	return list
end

return Team
