local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local DataManager = {}

local ProfileStore = require(ServerStorage.ServerPackages.profilestore)

local defaultData = {
	Kills = 0,
	TotalKills = 0,
	Deaths = 0,
	Emotes = {},
	CurrentCharacter = "Vitality",
	PlayTime = 0,
	FirstJoin = 0,
}

local DataStore = ProfileStore.New("PlayerData", defaultData)
local profiles = {}

Players.PlayerAdded:Connect(function(player)
	local profile = DataStore:StartSessionAsync(player.UserId)
	profile:Reconcile()
	profiles[player.UserId] = profile
	profile:ListenToRelease(function()
		player:Kick("Your data has been loaded on another device.")
		profiles[player.UserId] = nil
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local profile = profiles[player.UserId]
	if profile then
		profile:EndSession()
		profiles[player.UserId] = nil
	end
end)

return DataManager
