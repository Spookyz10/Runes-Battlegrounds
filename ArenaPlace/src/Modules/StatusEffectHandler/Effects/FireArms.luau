local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local DAMAGE_BONUS = 2

return {
	Id = "FireArms",
	Definition = {
		MaxStacks = math.huge,
		OnApply = function(Character, Data, Stacks, Params)
			Character:SetAttribute("DamageDealtBonus", DAMAGE_BONUS)
			RemoteManager.FireAllClients("ReplicateTask", "UndawnVFX", { func = "Arms", char = Character })
		end,
		OnExpire = function(Character, Data, Stacks)
			if Character and Character.Parent then
				Character:SetAttribute("DamageDealtBonus", nil)
			end
			RemoteManager.FireAllClients("ReplicateTask", "UndawnVFX", { func = "ArmsRemove", char = Character })
		end,
	},
}
