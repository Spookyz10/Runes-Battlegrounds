local playerClass = {}
playerClass.__index = playerClass

local playerClasses = {}

local defaultData = {
	Moveset = "Lunar",

	--Booleans
	Update_2_SawLog = false,
	DidMonthlyReset = false,
	CompletedQuest = false,

	--Emotes
	Emotes = {
		["1"] = "Crush",
		["2"] = "Crush",
		["3"] = "Crush",
		["4"] = "Crush",
		["5"] = "Crush",
		["6"] = "Crush",
		["7"] = "Crush",
		["8"] = "Crush",
	},
	Emotes2 = {
		["1"] = "Crush",
		["2"] = "Crush",
		["3"] = "Crush",
		["4"] = "Crush",
		["5"] = "Crush",
		["6"] = "Crush",
		["7"] = "Crush",
		["8"] = "Crush",
	},

	--Settings
	ButtonsInfo = {
		Dash = {
			ScaleX = 0,
			OffsetX = 0,
			ScaleY = 0,
			OffsetY = 0,
			SizeMultiplier = 1,
		},
		M1 = {
			ScaleX = 0,
			OffsetX = 0,
			ScaleY = 0,
			OffsetY = 0,
			SizeMultiplier = 1,
		},
		Block = {
			ScaleX = 0,
			OffsetX = 0,
			ScaleY = 0,
			OffsetY = 0,
			SizeMultiplier = 1,
		},
		Shiftlock = {
			ScaleX = 0,
			OffsetX = 0,
			ScaleY = 0,
			OffsetY = 0,
			SizeMultiplier = 1,
		},
	},

	--Statistics
	KillsForEmote = 50,

	--Owneds
	OwnedPasses = {},
	OwnedEmotes = {
		"Crush",
	},

	--Configuration
	---Booleaned Configs
	["Auto Run"] = true,
	["Camera Shake"] = true,
	["Awakening Music"] = true,
	["Shiftlock"] = false,
}

playerClass.defaultData = defaultData

function playerClass.new(Player: Player, PlayerData)
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

function playerClass:RemoveClass(userId: number)
	return table.remove(playerClasses, userId)
end

return playerClass
