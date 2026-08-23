local MatchTypes = {}

MatchTypes.MatchState = {
	Preparing = "Preparing",
	CharacterSelection = "CharacterSelection",
	Countdown = "Countdown",
	InProgress = "InProgress",
	Resolving = "Resolving",
	Finished = "Finished",
}

MatchTypes.ResultReason = {
	Elimination = "Elimination",
	TimeLimit = "TimeLimit",
	Draw = "Draw",
}

MatchTypes.TeamNames = {
	"TeamA",
	"TeamB",
	"TeamC",
	"TeamD",
}

export type PlayerState = {
	Player: Player,
	UserId: number,
	Team: string,
	Lives: number,
	Eliminated: boolean,
}

export type MatchConfig = {
	NumberOfTeams: number,
	PlayersPerTeam: number,
	MaxLives: number,
	FriendlyFire: boolean,
	TimeLimit: number,
}

export type PlayerResult = {
	UserId: number,
	Team: string,
	Lives: number,
	Eliminated: boolean,
}

export type TeamResult = {
	Team: string,
	Eliminated: boolean,
	TotalLivesRemaining: number,
}

export type MatchResult = {
	Winner: string?,
	Losers: {string},
	Draw: boolean,
	Reason: string,
	TeamResults: {[string]: TeamResult},
	PlayerResults: {[number]: PlayerResult},
}

return MatchTypes