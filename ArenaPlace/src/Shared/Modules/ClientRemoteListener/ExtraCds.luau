local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ExtraCds = require(ReplicatedStorage.Shared.UI.Logic.ExtraCDs)
local DashDirectionResolver = require(ReplicatedStorage.Shared.Modules.Functions.DashDirectionResolver)

local Remote = {}

function Remote:Activate(SkillName: string, Cooldown: number)
	ExtraCds.StartCooldown(SkillName, Cooldown)
	DashDirectionResolver.ConfirmAxisCooldown(SkillName, Cooldown)
end

return Remote
