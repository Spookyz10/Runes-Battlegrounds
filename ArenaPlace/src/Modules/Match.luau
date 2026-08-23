local HttpService = game:GetService("HttpService")

local MatchTypes = require(script.Parent.MatchTypes)
local MatchConfig = require(script.Parent.MatchConfig)
local Team = require(script.Parent.Team)

local Match = {}
Match.__index = Match

function Match.new(config: MatchTypes.MatchConfig)
	local self = setmetatable({}, Match)

	self.MatchId = HttpService:GenerateGUID(false)
	self.Config = MatchConfig.new(config)
	self.State = MatchTypes.MatchState.Preparing

	self.Teams = {}
	self.TeamOrder = self.Config:GetTeamNames()

	for _, teamName in self.TeamOrder do
		self.Teams[teamName] = Team.new(teamName, self.Config.MaxLives)
	end

	return self
end

function Match:SetState(newState: string)
	self.State = newState
end

function Match:GetState(): string
	return self.State
end

function Match:GetTeam(teamName: string)
	return self.Teams[teamName]
end

function Match:AddPlayerToTeam(player: Player, teamName: string)
	local team = self.Teams[teamName]
	assert(team, string.format("Team %s does not exist in this match", teamName))

	return team:AddPlayer(player)
end

function Match:GetPlayerTeam(userId: number)
	for _, team in self.Teams do
		if team:GetPlayerState(userId) then
			return team
		end
	end
	return nil
end

function Match:GetPlayerState(userId: number): MatchTypes.PlayerState?
	local team = self:GetPlayerTeam(userId)
	if not team then
		return nil
	end
	return team:GetPlayerState(userId)
end

function Match:DamagePlayer(userId: number, lifeLoss: number?)
	local team = self:GetPlayerTeam(userId)
	if not team then
		return
	end

	team:RemoveLife(userId, lifeLoss)
end

function Match:GetAliveTeams()
	local alive = {}
	for _, teamName in self.TeamOrder do
		local team = self.Teams[teamName]
		if not team:IsEliminated() then
			table.insert(alive, team)
		end
	end
	return alive
end

function Match:CheckForWinner(): string?
	local aliveTeams = self:GetAliveTeams()

	if #aliveTeams == 1 then
		return aliveTeams[1].Name
	end

	return nil
end

function Match:GetAllPlayers(): { MatchTypes.PlayerState }
	local list = {}
	for _, teamName in self.TeamOrder do
		local team = self.Teams[teamName]
		for _, state in team:GetPlayers() do
			table.insert(list, state)
		end
	end
	return list
end

return Match
