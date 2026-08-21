local ServerStorage = game:GetService("ServerStorage")

local CosmeticsService = require(ServerStorage.Modules.CosmeticsService)

local Remote = {}

function Remote:Activate(Player: Player, Action: string, Params)
	if not Params or typeof(Params.Type) ~= "string" then
		return
	end

	if Action == "Equip" then
		if typeof(Params.Name) ~= "string" then
			return
		end
		CosmeticsService:Equip(Player, Params.Type, Params.Name)
	elseif Action == "Unequip" then
		CosmeticsService:Unequip(Player, Params.Type)
	end
end

return Remote
