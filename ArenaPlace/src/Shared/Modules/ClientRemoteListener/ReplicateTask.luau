local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Tasks = require(ReplicatedStorage.Shared.Modules.Functions.Tasks)

local Remote = {}

function Remote:Activate(Task: string, ...)
	if Tasks[Task] then
		Tasks[Task](...)
	end
end

return Remote
