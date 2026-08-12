local Movesets = {}
local MovesInfo = {}
local AwakeningMovesInfo = {}

for _, module in script:GetDescendants() do
	if not module:IsA("ModuleScript") then
		continue
	end

	local data = require(module)

	local movesetInfo = data.Info
	movesetInfo.Moves = data.Moves or {}
	movesetInfo.AwakeningMoves = data.AwakeningMoves or {}
	movesetInfo.Special = data.Special

	Movesets[module.Name] = movesetInfo

	for moveName, moveInfo in movesetInfo.Moves do
		MovesInfo[moveName] = moveInfo
	end

	for moveName, moveInfo in movesetInfo.AwakeningMoves do
		AwakeningMovesInfo[moveName] = moveInfo
	end
end

return {
	Movesets = Movesets,
	MovesInfo = MovesInfo,
	AwakeningMovesInfo = AwakeningMovesInfo,
}
