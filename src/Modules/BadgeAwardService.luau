local BadgeService = game:GetService("BadgeService")

local module = {}

local BADGES = {
	Kills50 = 3572742013654283,
}

function module:CheckKills(Player, TotalKills)
	if not Player or not Player.Parent then
		return
	end

	if TotalKills < 50 then
		return
	end

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
