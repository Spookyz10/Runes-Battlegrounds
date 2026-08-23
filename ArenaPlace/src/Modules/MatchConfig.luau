local MatchTypes = require(script.Parent.MatchTypes)

local MatchConfig = {}
MatchConfig.__index = MatchConfig

function MatchConfig.new(config: MatchTypes.MatchConfig)
	assert(config, "MatchConfig.new requires a config table")
	assert(type(config.NumberOfTeams) == "number" and config.NumberOfTeams >= 2, "NumberOfTeams must be a number >= 2")
	assert(
		type(config.PlayersPerTeam) == "number" and config.PlayersPerTeam >= 1,
		"PlayersPerTeam must be a number >= 1"
	)
	assert(type(config.MaxLives) == "number" and config.MaxLives >= 1, "MaxLives must be a number >= 1")
	assert(type(config.FriendlyFire) == "boolean", "FriendlyFire must be a boolean")
	assert(type(config.TimeLimit) == "number" and config.TimeLimit > 0, "TimeLimit must be a number > 0")
	assert(config.NumberOfTeams <= #MatchTypes.TeamNames, "NumberOfTeams exceeds supported team names")

	local self = setmetatable({}, MatchConfig)

	self.NumberOfTeams = config.NumberOfTeams
	self.PlayersPerTeam = config.PlayersPerTeam
	self.MaxLives = config.MaxLives
	self.FriendlyFire = config.FriendlyFire
	self.TimeLimit = config.TimeLimit

	return self
end

function MatchConfig:GetTeamNames(): { string }
	local names = {}
	for i = 1, self.NumberOfTeams do
		table.insert(names, MatchTypes.TeamNames[i])
	end
	return names
end

return MatchConfig
