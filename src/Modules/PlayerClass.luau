local playerClass = {}
playerClass.__index = playerClass

local playerClasses = {}

local defaultData = {
	Inventory = {},
	OwnedPasses = {},

	Settings = {
		["Camera Shake"] = true,
	},
}

playerClass.defaultData = defaultData

function playerClass.new(Player, PlayerData)
	if PlayerData == nil then
		PlayerData = defaultData
	else
		for Index, Value in defaultData do
			if PlayerData[Index] == nil then
				PlayerData[Index] = Value
			end
		end

		for Index, _ in PlayerData do
			if defaultData[Index] == nil then
				PlayerData[Index] = nil
			end
		end
	end

	setmetatable(PlayerData, playerClass)
	playerClasses[Player.UserId] = PlayerData

	return PlayerData
end

function playerClass:RemoveClass(userId)
	return table.remove(playerClasses, userId)
end

return playerClass
