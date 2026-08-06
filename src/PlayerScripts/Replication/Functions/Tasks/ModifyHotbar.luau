local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Hotbar = require(ReplicatedStorage.Shared.UI.Logic.Hotbar)

return function(Params)
	Hotbar.Modify(Params)
end
