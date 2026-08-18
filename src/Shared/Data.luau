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

	Kills = 0,
	TotalKills = 0,
	Donated = 0,

	OwnedPasses = {} :: { number },
	OwnedEmotes = {
		"Crush",
	},

	KillSoundId = nil :: number?,

	Settings = {
		AutoRun = true,
		CameraShake = true,
		AwakeningMusic = true,
	},
}

return DataServiceTyped({ template = template, profileStoreIndex = "PlayerData" })
