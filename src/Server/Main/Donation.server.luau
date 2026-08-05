local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local LeaderboardManager = require(ServerStorage.Modules.LeaderboardManager)

local ProductPrices = {
	[3616886344] = 10,
	[3616896152] = 100,
	[3616912324] = 1000,
	[3616922612] = 10000,
}

local function grantDonation(Player, Amount)
	local playerData = Data[Player]
	if not playerData then
		return false
	end

	local ok = pcall(function()
		playerData.Donated(function(current)
			return current + Amount
		end)
	end)

	if not ok then
		return false
	end

	LeaderboardManager:AddDonation(Player, Amount)
	return true
end

MarketplaceService.ProcessReceipt = function(receiptInfo)
	local Player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not Player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local Amount = ProductPrices[receiptInfo.ProductId]
	if not Amount then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local Granted = grantDonation(Player, Amount)
	if not Granted then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end
