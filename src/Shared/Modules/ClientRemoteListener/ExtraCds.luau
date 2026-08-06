local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ExtraCds = require(ReplicatedStorage.Shared.UI.Logic.ExtraCDs)

local Remote = {}

function Remote:Activate(SkillName: string, Cooldown: number)
	ExtraCds.StartCooldown(SkillName, Cooldown)
end

return Remote
