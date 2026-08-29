local animations = {}

for _, module in script:GetChildren() do
	if module:IsA("ModuleScript") then
		animations[module.Name] = require(module)
	end
end

return animations
