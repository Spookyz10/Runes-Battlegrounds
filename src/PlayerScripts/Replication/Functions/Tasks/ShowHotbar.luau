local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Hotbar = require(ReplicatedStorage.Shared.UI.Logic.Hotbar)

return function(_Params)
	Hotbar.Show()
end
