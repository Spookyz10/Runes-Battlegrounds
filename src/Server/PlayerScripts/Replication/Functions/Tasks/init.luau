local function isInShared(module)
	local parent = module.Parent
	while parent and parent ~= script do
		if parent.Name == "Shared" then
			return true
		end
		parent = parent.Parent
	end
	return false
end

local tasks = {}

for _, module in script:GetDescendants() do
	if module:IsA("ModuleScript") and not isInShared(module) then
		tasks[module.Name] = require(module)
	end
end

return tasks
