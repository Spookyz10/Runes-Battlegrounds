local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local EarlyAccess = require(ReplicatedStorage.Shared.EarlyAccess)
local VIPPass = require(ReplicatedStorage.Shared.VIPPass)

local module = {}

local BADGES = {
	{ Kills = 1, BadgeId = 2210491191060246 },
	{ Kills = 15, BadgeId = 4169635045969282 },
	{ Kills = 50, BadgeId = 3572742013654283 }, -- beta lol
	{ Kills = 100, BadgeId = 10289439831 },
	{ Kills = 1000, BadgeId = 1953485311265542 },
	{ Kills = 10000, BadgeId = 1041322512332776 },
}

local function GrantPass(Player, GamepassId)
	local playerData = Data.Service:waitForData(Player)
	if not playerData then
		return
	end

	if table.find(playerData.OwnedPasses(), GamepassId) then
		return
	end

	playerData.OwnedPasses.Insert(GamepassId)
end

function module:CheckKills(Player, TotalKills)
	if not Player or not Player.Parent then
		return
	end

	if TotalKills >= 50 then
		GrantPass(Player, EarlyAccess.GamepassId)
		GrantPass(Player, VIPPass.GamepassId)
	end

	for _, BadgeInfo in BADGES do
		if TotalKills >= BadgeInfo.Kills then
			local OwnsOk, Owns = pcall(function()
				return BadgeService:UserHasBadgeAsync(Player.UserId, BadgeInfo.BadgeId)
			end)

			if OwnsOk and not Owns then
				pcall(function()
					BadgeService:AwardBadgeAsync(Player.UserId, BadgeInfo.BadgeId)
				end)
			end
		end
	end
end

return module
