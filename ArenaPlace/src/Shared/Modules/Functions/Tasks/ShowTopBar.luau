local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Topbar = require(ReplicatedStorage.Shared.UI.Logic.Topbar)

return function(_Params)
	Topbar.Show()
end
