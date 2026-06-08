local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VFXRemotes = ReplicatedStorage.Remotes.VFX

local handlers = {}

local function loadHandler(skillName)
	if handlers[skillName] then
		return handlers[skillName]
	end
	local ok, result = pcall(function()
		return require(script.Parent.VFX:FindFirstChild(skillName))
	end)
	if ok and result then
		handlers[skillName] = result
		return result
	end
	warn("VFXClient: handler não encontrado para skill:", skillName)
	return nil
end

VFXRemotes.SkillEffect.OnClientEvent:Connect(function(skillName, phase, character, ...)
	local handler = loadHandler(skillName)
	if handler and handler.handle then
		handler.handle(phase, character, ...)
	end
end)
