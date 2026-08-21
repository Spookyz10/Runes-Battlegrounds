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
	Gold = 0,

	OwnedPasses = {} :: { number },
	OwnedEmotes = {
		"Crush",
	},

	OwnedAuras = {} :: { string },
	OwnedRuneCosmetics = {} :: { string },
	EquippedAura = nil :: string?,
	EquippedRuneCosmetic = nil :: string?,

	KillSoundId = nil :: number?,

	Settings = {
		CameraShake = true,
		AwakeningMusic = true,
		FastMode = false,
	},
}

return DataServiceTyped({ template = template, profileStoreIndex = "PlayerData" })
