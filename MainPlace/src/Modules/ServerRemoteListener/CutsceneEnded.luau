local ServerStorage = game:GetService("ServerStorage")
local CutsceneManager = require(ServerStorage.Modules.CutsceneManager)

local Remote = {}

function Remote:Activate(Player: Player, id)
	CutsceneManager:MarkEnded(Player, id)
end

return Remote
