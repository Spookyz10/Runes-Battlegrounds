local playerClass = {}
playerClass.__index = playerClass

local playerClasses = {}

local InfoModule = require(game.ReplicatedStorage.Shared.Info)

local function buildDefaultModes()
	local modes = {}
	for name, info in InfoModule.Movesets do
		if info.DefaultMode then
			modes[name] = info.DefaultMode
		end
	end
	return modes
end

local defaultData = {
	Moveset = "Eclipse",

	MovesetModes = buildDefaultModes(),
	Update_2_SawLog = false,
	DidMonthlyReset = false,
	CompletedQuest = false,

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

	KillsForEmote = 50,

	OwnedPasses = {},
	OwnedEmotes = {
		"Crush",
	},

	["Auto Run"] = true,
	["Camera Shake"] = true,
	["Awakening Music"] = true,
}

playerClass.defaultData = defaultData

function playerClass.new(Player: Player, PlayerData)
	if not InfoModule.Movesets[PlayerData.Moveset] then
		PlayerData.Moveset = defaultData.Moveset
	end

	local defaultModes = buildDefaultModes()
	for name, defaultMode in defaultModes do
		if PlayerData.MovesetModes[name] == nil then
			PlayerData.MovesetModes[name] = defaultMode
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
