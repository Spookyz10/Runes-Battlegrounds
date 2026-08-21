local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Leaderboards = require(ReplicatedStorage.Shared.UI.Logic.Leaderboards)

local Remote = {}

function Remote:Activate(Data)
	Leaderboards.UpdateFromServer(Data)
end

return Remote