local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local EarlyAccess = require(ReplicatedStorage.Shared.EarlyAccess)

local GamepassService = {}


local COMPLIMENTARY_EARLY_ACCESS_USERS = {
	[2843265067] = true,
}

function GamepassService:SyncPlayer(Player)
	local playerData = Data.Service:waitForData(Player)
	if not playerData then
		return
	end

	local GamepassId = EarlyAccess.GamepassId

	if COMPLIMENTARY_EARLY_ACCESS_USERS[Player.UserId] then
		playerData.OwnedPasses(function(passes)
			passes[GamepassId] = true
			return passes
		end)
		return
	end

	if playerData.OwnedPasses()[GamepassId] then
		return
	end

	local Ok, Owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamepassId)
	end)

	if Ok and Owns then
		playerData.OwnedPasses(function(passes)
			passes[GamepassId] = true
			return passes
		end)
	end
end

function GamepassService:PlayerOwnsEarlyAccess(Player)
	local playerData = Data.Service:waitForData(Player)
	if not playerData then
		return false
	end

	if playerData.OwnedPasses()[EarlyAccess.GamepassId] == true then
		return true
	end

	local GamepassId = EarlyAccess.GamepassId

	local Ok, Owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamepassId)
	end)

	if Ok and Owns then
		playerData.OwnedPasses(function(passes)
			passes[GamepassId] = true
			return passes
		end)
		return true
	end

	return false
end

Players.PlayerAdded:Connect(function(Player)
	task.spawn(function()
		GamepassService:SyncPlayer(Player)
	end)
end)

for _, Player in Players:GetPlayers() do
	task.spawn(function()
		GamepassService:SyncPlayer(Player)
	end)
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(Player, GamepassId, WasPurchased)
	if not WasPurchased or GamepassId ~= EarlyAccess.GamepassId then
		return
	end

	local playerData = Data.Service:waitForData(Player)
	if not playerData then
		return
	end

	playerData.OwnedPasses(function(passes)
		passes[GamepassId] = true
		return passes
	end)
end)

return GamepassService
