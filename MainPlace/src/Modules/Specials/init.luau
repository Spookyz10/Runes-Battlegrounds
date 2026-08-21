local Specials = {}

for _, special in script:GetDescendants() do
	if special:IsA("ModuleScript") then
		Specials[special.Name] = require(special)
	end
end

return Specials
