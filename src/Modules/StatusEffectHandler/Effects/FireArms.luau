local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

return {
	Id = "FireArms",
	Definition = {
		MaxStacks = math.huge,
		OnApply = function(Character, Data, Stacks, Params)
			ReplicateSet:FireAllClients("UndawnVFX", { func = "Arms", char = Character })
		end,
		OnExpire = function(Character, Data, Stacks)
			ReplicateSet:FireAllClients("UndawnVFX", { func = "ArmsRemove", char = Character })
		end,
	},
}
