local StatusEffectHandler = require(script.Parent)

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") then
		local Effect = require(module)
		StatusEffectHandler:RegisterEffect(Effect.Id, Effect.Definition)
	end
end
