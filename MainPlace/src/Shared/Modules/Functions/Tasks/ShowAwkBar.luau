local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Awkbar = require(ReplicatedStorage.Shared.UI.Logic.AwkBar)

return function(_Params)
	Awkbar.Show()
end
