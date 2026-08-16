local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).server
local EarlyAccess = require(ReplicatedStorage.Shared.EarlyAccess)

local module = {}

local BADGES = {
	Kills50 = 3572742013654283,
}

local function GrantEarlyAccess(Player)
	local playerData = Data.Service:waitForData(Player)
	if not playerData then
		return
	end

	local GamepassId = EarlyAccess.GamepassId

	if playerData.OwnedPasses()[GamepassId] then
		return
	end

	playerData.OwnedPasses(function(passes)
		passes[GamepassId] = true
		return passes
	end)
end

function module:CheckKills(Player, TotalKills)
	if not Player or not Player.Parent then
		return
	end

	if TotalKills < 50 then
		return
	end

	GrantEarlyAccess(Player)

	local BadgeId = BADGES.Kills50

	local OwnsOk, Owns = pcall(function()
		return BadgeService:UserHasBadgeAsync(Player.UserId, BadgeId)
	end)

	if not OwnsOk or Owns then
		return
	end

	pcall(function()
		BadgeService:AwardBadgeAsync(Player.UserId, BadgeId)
	end)
end

return module
