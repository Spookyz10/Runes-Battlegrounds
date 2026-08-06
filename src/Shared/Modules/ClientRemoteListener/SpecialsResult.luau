local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remote = {}

function Remote:Activate(action: string, params)
	if action == "Activated" and not params.IsUlt then
		local ExtraCds = require(ReplicatedStorage.Shared.UI.Logic.ExtraCDs)
		ExtraCds.StartCooldown("Special", params.Cooldown)
	end
end

return Remote
