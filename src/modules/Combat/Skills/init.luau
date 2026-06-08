local skills = {}

for _, skill in script:GetDescendants() do
	if skill:IsA("ModuleScript") then
		local name = skill.Name
		skills[name] = require(skill)
	end
end

return skills
