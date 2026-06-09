local playerClass = {}
playerClass.__index = playerClass

local playerClasses = {}


local defaultData = {
	Moveset = 'The Strongest Hero',
	
	
	--Booleans
	Update_2_SawLog = false,
	DidMonthlyReset = false,
	CompletedQuest = false,
	
	
	--Emotes
	Emotes = {
		['1'] = 'Crush',
		['2'] = 'Crush',
		['3'] = 'Crush',
		['4'] = 'Crush',
		['5'] = 'Crush',
		['6'] = 'Crush',
		['7'] = 'Crush',
		['8'] = 'Crush'
	},
	Emotes2 = {
		['1'] = 'Crush',
		['2'] = 'Crush',
		['3'] = 'Crush',
		['4'] = 'Crush',
		['5'] = 'Crush',
		['6'] = 'Crush',
		['7'] = 'Crush',
		['8'] = 'Crush'
	},
	
	
	--Cosmetics
	Cosmetics = {
		Accessories = {},
		Auras = {},
		Titles = {}
	},
	
	
	--Settings
	ButtonsInfo = {
		Dash = {
			ScaleX = 0, OffsetX = 0, ScaleY = 0, OffsetY = 0,
			SizeMultiplier = 1
		},
		M1 = {
			ScaleX = 0, OffsetX = 0, ScaleY = 0, OffsetY = 0,
			SizeMultiplier = 1
		},
		Block = {
			ScaleX = 0, OffsetX = 0, ScaleY = 0, OffsetY = 0,
			SizeMultiplier = 1
		},
		Shiftlock = {
			ScaleX = 0, OffsetX = 0, ScaleY = 0, OffsetY = 0,
			SizeMultiplier = 1
		}
	},
	
	
	--Statistics
	Gold = 700,
	Rank1v1 = 0,
	Rank2v2 = 0,
	SaveSlots = 1,
	killSound = 0,
	deathSound = 0,
	KillsForEmote = 50,
	
	
	--Awakening
	AwakeningOutfits = {},
	
	
	--Owneds
	OwnedCosmetics = {},
	OwnedPasses = {},
	OwnedTitles = {},
	OwnedEmotes = {
		'Crush'
	},
	
	
	--Titles
	TitlesProgress = {
		Kills = 0,
		Emotes = 0,
		Cosmetics = 0,
		Awakens = 0,
		TreesDestroyed = 0,
		WallCombo = 0,
		Counters = 0,
		Killstreak = 0,
		Robux = 0
	},
	EquippedTitle = "",
	
	
	--Gifts
	PendingGifts = {},
	
	
	--Configuration
	---Booleaned Configs
	['Auto Run'] = true,
	['Auto Use'] = true,
	['Camera Shake'] = true,
	['Awakening Music'] = true,
	["Destruction Physics"] = true,
	['Character Packages'] = true,
	['Reduce Camera Shake'] = false,
	['Shiftlock'] = false,
	['Blood'] = false,
	["Hide Kills"] = false,
	["Hide Gold"] = false,
	["Hide Killstreak"] = false,
	["Hide VIP Join Message"] = false,
	["Show Console Controls"] = true,
	['Fast Mode'] = false,
	["Day Night Cicle"] = false,
	["Emote Music"] = true,
	
	
	---Valued Configs
	['Volume'] = 1,
	['Mod'] = 1,
	["Shiftlock Offset"] = 1.75
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