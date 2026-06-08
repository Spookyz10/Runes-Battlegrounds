local skills = {}

for _, module in pairs(script:GetChildren()) do
	if module:IsA("ModuleScript") then
		local skill = require(module)
		skills[module.Name] = skill
	end
end

return skills
