local ServerStorage = game:GetService("ServerStorage")
local AwakeningService = require(ServerStorage.Modules.AwakeningService)

local Remote = {}

function Remote:Activate(Player: Player)
	local AwkProgress = Player:FindFirstChild("AwakeningProgress") :: NumberValue?
	if not AwkProgress or AwkProgress.Value < 100 then
		return
	end

	AwakeningService:Activate(Player)
end

return Remote
