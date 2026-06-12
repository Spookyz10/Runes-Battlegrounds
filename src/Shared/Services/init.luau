local Module = {
	["cache"] = {}
}


local Utility = require(script.Utility)

function Module.GetService(_, p3)
	return Module.cache[p3]
end


for _, Child in script.Package:GetChildren() do
	if Child:IsA("ModuleScript") then
		Module.cache[Child.Name] = Utility.require(Child)
	end
end


return Module