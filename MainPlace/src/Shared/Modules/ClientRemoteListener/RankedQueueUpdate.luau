local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Ranked = require(ReplicatedStorage.Shared.UI.Logic.Ranked)

local Remote = {}

function Remote:Activate(Kind: string, Params)
	Ranked.HandleUpdate(Kind, Params)
end

return Remote
