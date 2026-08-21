local ServerStorage = game:GetService("ServerStorage")
local EvasiveService = require(ServerStorage.Modules.EvasiveService)

local Remote = {}

function Remote:Invoke(Player: Player)
	return EvasiveService:HandleGetRequest(Player)
end

return Remote
