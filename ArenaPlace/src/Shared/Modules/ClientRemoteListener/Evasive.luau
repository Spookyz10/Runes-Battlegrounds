local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ExtraCds = require(ReplicatedStorage.Shared.UI.Logic.ExtraCDs)

local Remote = {}

function Remote:Activate(Progress: number, Threshold: number, Charges: number)
	ExtraCds.SetEvasiveMeter(Progress, Threshold, Charges)
end

return Remote
