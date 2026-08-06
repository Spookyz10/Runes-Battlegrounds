local StarterPlayer = game:GetService("StarterPlayer")
local Tasks = require(StarterPlayer.StarterPlayerScripts.Player.Replication.Functions.Tasks)
local Remote = {}

function Remote:Activate(Task: string, ...)
	if Tasks[Task] then
		Tasks[Task](...)
	end
end

return Remote
