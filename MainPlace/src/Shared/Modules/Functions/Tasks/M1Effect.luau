local ReplicatedStorage = game:GetService("ReplicatedStorage")
local M1Effects = require(ReplicatedStorage.Shared.Modules.M1Effects)

return function(params)
	M1Effects.Play(params)
end
