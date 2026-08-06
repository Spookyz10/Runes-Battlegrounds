local ServerStorage = game:GetService("ServerStorage")

local SpecialsHandler = require(ServerStorage.Modules.SpecialsHandler)
local MovesetHandler = require(ServerStorage.Modules.MovesetHandler)

local Remote = {}

function Remote:Activate(Player: Player, action: string, params)
	if not Player:FindFirstChild("LoadedData") then
		return
	end

	local Character = Player.Character
	if not Character or not Character.Parent then
		return
	end

	if action == "ActivateBase" then
		SpecialsHandler:Activate(Player, false, MovesetHandler)
	elseif action == "ActivateUlt" then
		SpecialsHandler:Activate(Player, true, MovesetHandler)
	end
end

return Remote
