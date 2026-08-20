local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local EarlyAccess = require(ReplicatedStorage.Shared.EarlyAccess)
local KillSoundPass = require(ReplicatedStorage.Shared.KillSoundPass)
local VIPPass = require(ReplicatedStorage.Shared.VIPPass)

local GamepassService = {}

local COMPLIMENTARY_EARLY_ACCESS_USERS = {
	[2843265067] = true,
	[856738442] = true,
}

local COMPLIMENTARY_VIP_USERS = {
	[856738442] = true,
}

local TRACKED_GAMEPASSES = {
	EarlyAccess.GamepassId,
	KillSoundPass.GamepassId,
	VIPPass.GamepassId,
}

local function addOwnedPass(playerData, GamepassId)
	if table.find(playerData.OwnedPasses(), GamepassId) then
		return
	end
	playerData.OwnedPasses.Insert(GamepassId)
end

local function ownsPass(playerData, GamepassId)
	return table.find(playerData.OwnedPasses(), GamepassId) ~= nil
end

function GamepassService:SyncPlayer(Player)
	local playerData = Data.Service:waitForData(Player)
	if not playerData then
		return
	end

	if COMPLIMENTARY_EARLY_ACCESS_USERS[Player.UserId] then
		addOwnedPass(playerData, EarlyAccess.GamepassId)
	end

	if COMPLIMENTARY_VIP_USERS[Player.UserId] then
		addOwnedPass(playerData, VIPPass.GamepassId)
	end

	for _, GamepassId in TRACKED_GAMEPASSES do
		if ownsPass(playerData, GamepassId) then
			continue
		end

		local Ok, Owns = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamepassId)
		end)

		if Ok and Owns then
			addOwnedPass(playerData, GamepassId)
		end
	end
end

function GamepassService:PlayerOwnsEarlyAccess(Player)
	local playerData = Data.Service:waitForData(Player)
	if not playerData then
		return false
	end

	if ownsPass(playerData, EarlyAccess.GamepassId) then
		return true
	end

	local GamepassId = EarlyAccess.GamepassId

	local Ok, Owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamepassId)
	end)

	if Ok and Owns then
		addOwnedPass(playerData, GamepassId)
		return true
	end

	return false
end

function GamepassService:PlayerOwnsGamepass(Player, GamepassId)
	local playerData = Data.Service:waitForData(Player)
	if not playerData then
		return false
	end

	if ownsPass(playerData, GamepassId) then
		return true
	end

	local Ok, Owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamepassId)
	end)

	if Ok and Owns then
		addOwnedPass(playerData, GamepassId)
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
	if not WasPurchased or not table.find(TRACKED_GAMEPASSES, GamepassId) then
		return
	end

	local playerData = Data.Service:waitForData(Player)
	if not playerData then
		return
	end

	addOwnedPass(playerData, GamepassId)
end)

return GamepassService
