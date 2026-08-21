local Remotes = {}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		Remotes[module.Name] = require(module)
	end
end

return Remotes
