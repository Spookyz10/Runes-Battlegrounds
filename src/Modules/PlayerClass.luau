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
		-- deep copy pra não compartilhar referência entre players
		PlayerData = {}
		for k, v in defaultData do
			PlayerData[k] = v
		end
		PlayerData.MovesetModes = buildDefaultModes()
	else
		-- migração: moveset que não existe mais no Info → reseta pro default
		if not InfoModule.Movesets[PlayerData.Moveset] then
			PlayerData.Moveset = defaultData.Moveset
		end

		-- merge normal dos campos de topo
		for Index, Value in defaultData do
			if PlayerData[Index] == nil then
				PlayerData[Index] = Value
			end
		end

		-- merge especial de MovesetModes: preenche modos novos sem apagar os salvos
		if type(PlayerData.MovesetModes) ~= "table" then
			PlayerData.MovesetModes = buildDefaultModes()
		else
			for name, defaultMode in buildDefaultModes() do
				if PlayerData.MovesetModes[name] == nil then
					PlayerData.MovesetModes[name] = defaultMode
				end
			end
		end

		-- remove chaves obsoletas
		for Index in PlayerData do
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
