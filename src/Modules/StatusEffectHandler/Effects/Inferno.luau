local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

return {
	Id = "Inferno",
	Definition = {
		MaxStacks = 1,
		Duration = 8,
		OnApply = function(Character, Data, Stacks, Params)
			Character:SetAttribute("InfernoMarked", true)
			ReplicateSet:FireAllClients("StatusEffect", { Char = Character, Effect = "Inferno", State = true })
		end,
		OnExpire = function(Character, Data, Stacks)
			Character:SetAttribute("InfernoMarked", nil)
			ReplicateSet:FireAllClients("StatusEffect", { Char = Character, Effect = "Inferno", State = false })
		end,
	},
}
