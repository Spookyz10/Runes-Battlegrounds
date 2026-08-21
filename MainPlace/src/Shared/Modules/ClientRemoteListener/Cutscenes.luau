local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CutsceneController = require(ReplicatedStorage.Shared.Modules.CutsceneController)

local Remote = {}

function Remote:Activate(name: string, action: string, params)
	CutsceneController:Dispatch(name, action, params)
end

return Remote
