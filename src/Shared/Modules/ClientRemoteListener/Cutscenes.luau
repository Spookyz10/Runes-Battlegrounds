local CutsceneController = require(script.Parent.Parent.Parent.PlayerScripts.Replication.Functions.CutsceneController)

local Remote = {}

function Remote:Activate(name: string, action: string, params)
	CutsceneController:Handle(name, action, params)
end

return Remote
