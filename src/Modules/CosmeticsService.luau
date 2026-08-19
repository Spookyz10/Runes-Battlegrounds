local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local CosmeticsInfo = require(ReplicatedStorage.Shared.Info.Cosmetics)
local VIPPass = require(ReplicatedStorage.Shared.VIPPass)

local CosmeticsService = {}

local function ownsCosmetic(playerData, cosmeticType, name)
	local list = (cosmeticType == "Auras") and playerData.OwnedAuras() or playerData.OwnedRuneCosmetics()
	return table.find(list, name) ~= nil
end

local function grant(playerData, cosmeticType, name)
	if ownsCosmetic(playerData, cosmeticType, name) then
		return
	end

	if cosmeticType == "Auras" then
		playerData.OwnedAuras.Insert(name)
	else
		playerData.OwnedRuneCosmetics.Insert(name)
	end
end

local function grantVIPCosmetics(playerData)
	grant(playerData, "Auras", "VIP")
	grant(playerData, "RuneCosmetics", "Crown")
end

local function getEquippedField(playerData, cosmeticType)
	if cosmeticType == "Auras" then
		return playerData.EquippedAura
	end
	return playerData.EquippedRuneCosmetic
end

local function attrNameFor(cosmeticType)
	if cosmeticType == "Auras" then
		return "EquippedAura"
	end
	return "EquippedRuneCosmetic"
end

local function syncAttributes(Player, playerData)
	Player:SetAttribute("EquippedAura", playerData.EquippedAura())
	Player:SetAttribute("EquippedRuneCosmetic", playerData.EquippedRuneCosmetic())
end

function CosmeticsService:SyncPlayer(Player)
	local playerData = Data.Service:waitForData(Player)
	if not playerData then
		return
	end

	local Ok, Owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(Player.UserId, VIPPass.GamepassId)
	end)

	if Ok and Owns then
		grantVIPCosmetics(playerData)
	end

	syncAttributes(Player, playerData)
end

function CosmeticsService:Equip(Player: Player, cosmeticType: string, name: string)
	if cosmeticType ~= "Auras" and cosmeticType ~= "RuneCosmetics" then
		return false
	end

	local catalog = CosmeticsInfo[cosmeticType]
	if not catalog or not catalog[name] then
		return false
	end

	local playerData = Data.Service:waitForData(Player)
	if not playerData then
		return false
	end

	if not ownsCosmetic(playerData, cosmeticType, name) then
		return false
	end

	getEquippedField(playerData, cosmeticType)(name)
	Player:SetAttribute(attrNameFor(cosmeticType), name)

	return true
end

function CosmeticsService:Unequip(Player: Player, cosmeticType: string)
	if cosmeticType ~= "Auras" and cosmeticType ~= "RuneCosmetics" then
		return false
	end

	local playerData = Data.Service:waitForData(Player)
	if not playerData then
		return false
	end

	getEquippedField(playerData, cosmeticType)(nil)
	Player:SetAttribute(attrNameFor(cosmeticType), nil)

	return true
end

Players.PlayerAdded:Connect(function(Player)
	task.spawn(function()
		CosmeticsService:SyncPlayer(Player)
	end)
end)

for _, Player in Players:GetPlayers() do
	task.spawn(function()
		CosmeticsService:SyncPlayer(Player)
	end)
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(Player, GamepassId, WasPurchased)
	if not WasPurchased or GamepassId ~= VIPPass.GamepassId then
		return
	end

	local playerData = Data.Service:waitForData(Player)
	if not playerData then
		return
	end

	grantVIPCosmetics(playerData)
	syncAttributes(Player, playerData)
end)

return CosmeticsService
