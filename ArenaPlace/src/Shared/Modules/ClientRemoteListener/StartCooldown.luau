local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Hotbar = require(ReplicatedStorage.Shared.UI.Logic.Hotbar)

local Remote = {}

function Remote:Activate(Ability: string, Duration: number)
	Hotbar.StartCooldown(Ability, Duration)
end

return Remote
