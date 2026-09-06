local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local Catalog = require(ReplicatedStorage.Shared.Info.Shop)
local Cosmetics = require(ReplicatedStorage.Shared.Info.Cosmetics)
local NotificationService = require(script.Parent.Parent.NotificationService)
local _GoldService = require(script.Parent.Parent.GoldService)

local LastRequest = {}
local Shop = {}

function Shop:Activate(player, itemId)
	if typeof(itemId) ~= "string" or #itemId > 80 then
		return
	end

	local now = os.clock()

	if LastRequest[player] and now - LastRequest[player] < 0.5 then
		return
	end

	LastRequest[player] = now

	local function reply(success, message)
		NotificationService.Send(player, success, message, itemId)
	end

	local profile = Data.Service:getProfile(player)

	if not profile or not profile:IsActive() then
		reply(false, "Your data is still loading.")
		return
	end

	local item

	for _, entry in Catalog.Items do
		if entry.Id == itemId then
			item = entry
			break
		end
	end

	local category

	for _, entry in Catalog.Categories do
		if item and entry.Id == item.Category then
			category = entry
		end
	end

	if
		not item
		or not category
		or category.ComingSoon
		or not category.OwnedField
		or not Cosmetics[item.Category]
		or not Cosmetics[item.Category][item.Id]
		or typeof(item.Price) ~= "number"
		or item.Price < 0
		or item.Price % 1 ~= 0
	then
		reply(false, "This item is unavailable.")
		return
	end

	local data = Data[player]
	local owned = data[category.OwnedField]()

	if table.find(owned, item.Id) then
		reply(false, "You already own this item.")
		return
	end

	if data.Gold() < item.Price then
		reply(false, "Not enough gold to buy this item.")
		return
	end

	data.Gold(function(balance)
		return balance - item.Price
	end)

	data[category.OwnedField].Insert(item.Id)
	reply(true, "Purchase successful! Equip your item in Cosmetics.")
end

Players.PlayerRemoving:Connect(function(player)
	LastRequest[player] = nil
end)

return Shop
