local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

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
	OwnedRuneSkins = {} :: { string },
	AdminProcessed = {} :: { [string]: number },
	EquippedAura = nil :: string?,
	EquippedRuneCosmetic = nil :: string?,

	KillSoundId = nil :: number?,

	Settings = {
		CameraShake = true,
		AwakeningMusic = true,
		FastMode = false,
	},
}

local Data = DataServiceTyped({ template = template, profileStoreIndex = "PlayerData" })

if RunService:IsServer() then
	function Data.server.Service:onPlayerInit(player, data)
		local OwnedPasses = data.OwnedPasses

		if typeof(OwnedPasses) ~= "table" then
			return
		end

		if OwnedPasses[1] ~= nil or next(OwnedPasses) == nil then
			return
		end

		local IsLegacyFormat = false
		for key in OwnedPasses do
			if typeof(key) == "string" then
				IsLegacyFormat = true
				break
			end
		end

		if not IsLegacyFormat then
			return
		end

		local Converted = {}
		for key, value in OwnedPasses do
			if value == true then
				local GamepassId = tonumber(key)
				if GamepassId then
					table.insert(Converted, GamepassId)
				end
			end
		end

		data.OwnedPasses = Converted
	end
end

return Data
