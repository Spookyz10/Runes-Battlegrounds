local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local EarlyAccess = require(ReplicatedStorage.Shared.EarlyAccess)
local MovesetHandler = require(ServerStorage.Modules.MovesetHandler)
local GamepassService = require(ServerStorage.Modules.GamepassService)

local Remote = {}

local function notify(Player, Text)
	RemoteManager.FireClient(Player, "ReplicateTask", "SendNotification", {
		Title = "NOTIFICATION",
		Text = Text,
	})
end

function Remote:Activate(Player: Player, MovesetName: string)
	if typeof(MovesetName) ~= "string" then
		return
	end

	local Character = Player.Character
	if not Character or Character:HasTag("Stunned") then
		notify(Player, "YOU CAN'T CHANGE MOVESETS RIGHT NOW.")
		return
	end

	if Character:GetAttribute("InRankedMatch") == true and Character:GetAttribute("AllowMovesetSwap") ~= true then
		notify(Player, "YOU CAN'T CHANGE MOVESETS RIGHT NOW.")
		return
	end

	if EarlyAccess:IsEarlyAccess(MovesetName) and not GamepassService:PlayerOwnsEarlyAccess(Player) then
		MarketplaceService:PromptGamePassPurchase(Player, EarlyAccess.GamepassId)
		return
	end

	local DamagerLog = Character:FindFirstChild("DamagerLog")
	local DamagedLog = Character:FindFirstChild("DamagedLog")

	if
		(DamagerLog and not DamagerLog.Value:FindFirstChild("Dummy"))
		or (DamagedLog and not DamagedLog.Value:FindFirstChild("Dummy"))
	then
		local DamagerTime, DamagedTime = 0, 0

		if DamagerLog then
			DamagerTime = math.round(DamagerLog.TimeRemaining.Value)
		end

		if DamagedLog then
			DamagedTime = math.round(DamagedLog.TimeRemaining.Value)
		end

		local HighestTime = math.max(DamagerTime, DamagedTime)

		if HighestTime > 0 then
			notify(Player, "CAN'T CHANGE MOVESETS RIGHT NOW, WAIT " .. HighestTime .. " SECONDS.")
			return
		end
	end

	if Player:HasTag("MovesetCD") then
		notify(Player, "CAN'T EQUIP MOVESET, YOU ARE ON COOLDOWN.")
		return
	end

	local Ok, Reason = MovesetHandler:SetMoveset(Player, MovesetName)
	if not Ok then
		if Reason == "AlreadyEquipped" then
			notify(Player, "YOU ARE ALREADY PLAYING THIS CHARACTER.")
		end
		return
	end

	Player:AddTag("MovesetCD")
	task.delay(2, function()
		Player:RemoveTag("MovesetCD")
	end)
end

return Remote
