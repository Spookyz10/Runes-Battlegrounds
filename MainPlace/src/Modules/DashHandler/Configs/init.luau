local Configs = {}

for _, moduleScript in script:GetDescendants() do
	if moduleScript:IsA("ModuleScript") then
		Configs[moduleScript.Name] = require(moduleScript)
	end
end

return Configs
