local ServerStorage = game:GetService("ServerStorage")
local playerClass = {}
playerClass.__index = playerClass

local InfoModule = require(game.ReplicatedStorage.Shared.Info)
local DataServiceTyped = require(ServerStorage.ServerPackages.dataservicetyped)

local function buildDefaultModes()
	local modes = {}
	for name, info in InfoModule.Movesets do
		if info.DefaultMode then
			modes[name] = info.DefaultMode
		end
	end
	return modes
end

local template = {
	Moveset = "Eclipse",

	MovesetModes = buildDefaultModes(),

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

	Kills = 0,
	TotalKills = 0,

	OwnedPasses = {} :: { number },
	OwnedEmotes = {
		"Crush",
	},

	Settings = {
		AutoRun = true,
		CameraShake = true,
		AwakeningMuisc = true,
	},
}

return DataServiceTyped({ template = template, profileStoreIndex = "PlayerData" })
