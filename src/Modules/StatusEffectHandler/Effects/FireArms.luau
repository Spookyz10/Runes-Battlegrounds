local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

return {
	Id = "FireArms",
	Definition = {
		MaxStacks = math.huge,
		OnApply = function(Character, Data, Stacks, Params)
			RemoteManager.FireAllClients("ReplicateTask", "UndawnVFX", { func = "Arms", char = Character })
		end,
		OnExpire = function(Character, Data, Stacks)
			RemoteManager.FireAllClients("ReplicateTask", "UndawnVFX", { func = "ArmsRemove", char = Character })
		end,
	},
}
