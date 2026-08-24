local ServerStorage = game:GetService("ServerStorage")

local GlobalMatchmaking = require(ServerStorage.Modules.Ranked.GlobalMatchmaking)

local Remote = {}

function Remote:Invoke(Player: Player, Action: string, Params)
	if Action == "Join" then
		return GlobalMatchmaking.Join(Player, Params and Params.Mode)
	elseif Action == "Leave" then
		return GlobalMatchmaking.Leave(Player)
	end

	return { Success = false, Message = "AÇÃO DESCONHECIDA" }
end

return Remote
