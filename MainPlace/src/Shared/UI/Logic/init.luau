local Logic = {}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		Logic[module.Name] = require(module)
	end
end

return Logic
