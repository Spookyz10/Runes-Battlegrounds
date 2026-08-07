local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

return {
	Id = "Inferno",
	Definition = {
		MaxStacks = 1,
		Duration = 8,
		OnApply = function(Character, Data, Stacks, Params)
			Character:SetAttribute("InfernoMarked", true)
			Character:SetAttribute("Inferno", true)
			RemoteManager.FireAllClients(
				"ReplicateTask",
				"StatusEffect",
				{ Char = Character, Effect = "Inferno", State = true }
			)
			RemoteManager.FireAllClients(
				"ReplicateTask",
				"AuraFX",
				{ func = "Start", char = Character, aura = "Inferno" }
			)
		end,
		OnExpire = function(Character, Data, Stacks)
			local StatusEffectHandler = require(script.Parent.Parent)
			if StatusEffectHandler:Has(Character, "Inferno") then
				return
			end

			Character:SetAttribute("InfernoMarked", nil)
			Character:SetAttribute("Inferno", nil)
			RemoteManager.FireAllClients(
				"ReplicateTask",
				"StatusEffect",
				{ Char = Character, Effect = "Inferno", State = false }
			)
			RemoteManager.FireAllClients(
				"ReplicateTask",
				"AuraFX",
				{ func = "End", char = Character, aura = "Inferno" }
			)
		end,
	},
}
