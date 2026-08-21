local ServerStorage = game:GetService("ServerStorage")

local SpecialsHandler = require(ServerStorage.Modules.SpecialsHandler)
local MovesetHandler = require(ServerStorage.Modules.MovesetHandler)

local Remote = {}

function Remote:Activate(Player: Player)
	if not Player:FindFirstChild("LoadedData") then
		return
	end

	local Character = Player.Character
	if not Character or not Character.Parent then
		return
	end

	SpecialsHandler:Activate(Player, MovesetHandler)
end

return Remote
