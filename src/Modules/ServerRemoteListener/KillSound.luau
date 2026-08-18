local ServerStorage = game:GetService("ServerStorage")

local KillSoundService = require(ServerStorage.Modules.KillSoundService)

local Remote = {}

function Remote:Invoke(Player: Player, Action: string, Params)
	if Action ~= "SetSoundId" then
		return { Success = false, Message = "UNKNOWN ACTION" }
	end

	return KillSoundService:SetSoundId(Player, Params)
end

return Remote
