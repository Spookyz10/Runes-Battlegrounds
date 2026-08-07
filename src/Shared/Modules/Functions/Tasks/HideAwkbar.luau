local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AwkBar = require(ReplicatedStorage.Shared.UI.Logic.AwkBar)

return function(_Params)
	AwkBar.Hide()
end
