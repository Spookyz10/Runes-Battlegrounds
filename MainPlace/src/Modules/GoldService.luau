local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local NotificationService = require(script.Parent.NotificationService)

local GoldService = {}

function GoldService.Award(player, amount)
	if game.PrivateServerId ~= "" or game.PrivateServerOwnerId ~= 0 then
		return false
	end

	local profile = Data.Service:getProfile(player)

	if player.Parent ~= Players or not profile or not profile:IsActive() then
		return false
	end

	Data[player].Gold(function(balance)
		return balance + amount
	end)

	return true
end

local function track(player)
	local data = Data.Service:waitForData(player)

	if not data then
		return
	end

	while player.Parent == Players do
		task.wait(300)

		if GoldService.Award(player, 25) then
			NotificationService.Send(player, true, "+25 gold for playing 5 minutes!")
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	task.spawn(track, player)
end)

for _, player in Players:GetPlayers() do
	task.spawn(track, player)
end

return GoldService
