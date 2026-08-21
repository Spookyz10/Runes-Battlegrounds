local Abilities = {}

for _, skill in script:GetDescendants() do
	if skill:IsA("ModuleScript") then
		Abilities[skill.Name] = require(skill)
	end
end

return Abilities
