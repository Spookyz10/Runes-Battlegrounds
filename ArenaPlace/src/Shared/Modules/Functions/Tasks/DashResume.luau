local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

return function(params)
	local Player = Players.LocalPlayer
	local Character = Player.Character
	if not Character then
		return
	end

	local DashDirectionResolver = require(RS.Shared.Modules.Functions.DashDirectionResolver)
	DashDirectionResolver.ResumeFrontDash(Character)
end
