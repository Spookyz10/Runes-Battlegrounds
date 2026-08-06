local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

return {
	Id = "Inferno",
	Definition = {
		MaxStacks = 1,
		Duration = 8,
		OnApply = function(Character, Data, Stacks, Params)
			Character:SetAttribute("InfernoMarked", true)
			Character:SetAttribute("Inferno", true)
			ReplicateSet:FireAllClients("StatusEffect", { Char = Character, Effect = "Inferno", State = true })
			ReplicateSet:FireAllClients("AuraFX", { func = "Start", char = Character, aura = "Inferno" })
		end,
		OnExpire = function(Character, Data, Stacks)
			local StatusEffectHandler = require(script.Parent.Parent)
			if StatusEffectHandler:Has(Character, "Inferno") then
				return
			end

			Character:SetAttribute("InfernoMarked", nil)
			Character:SetAttribute("Inferno", nil)
			ReplicateSet:FireAllClients("StatusEffect", { Char = Character, Effect = "Inferno", State = false })
			ReplicateSet:FireAllClients("AuraFX", { func = "End", char = Character, aura = "Inferno" })
		end,
	},
}
