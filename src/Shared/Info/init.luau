local MovesetsData = require(script.Movesets)

return {
	Admins = {
		game.CreatorId,
	},

	Movesets = MovesetsData.Movesets,
	MovesInfo = MovesetsData.MovesInfo,
	AwakeningMovesInfo = MovesetsData.AwakeningMovesInfo,
}
