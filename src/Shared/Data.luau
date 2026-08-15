local ReplicatedStorage = game:GetService("ReplicatedStorage")

local playerClass = {}
playerClass.__index = playerClass

local DataServiceTyped = require(ReplicatedStorage.Packages.dataservicetyped)

local template = {
	Moveset = "Eclipse",

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
	Donated = 0,

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
