local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local SoundsModule = require(ServerStorage.Modules.SoundsModule)
local SFXFolder = ReplicatedStorage.Resources.SFX

local sounds = {}

local function isUnused(instance)
	local p = instance.Parent
	while p and p ~= SFXFolder do
		if p.Name == "Unused" then
			return true
		end
		p = p.Parent
	end
	return false
end

for _, v in SFXFolder:GetDescendants() do
	if v:IsA("Sound") and not isUnused(v) then
		sounds[v.Name] = v
	end
end

local module = {}

function module:Play(name, location, playbackSpeed, fadeOutParams, timePosition)
	local sound = sounds[name]
	if not sound then
		warn("[SFX] Sound not found: " .. tostring(name))
		return
	end
	return SoundsModule:PlaySound(sound, location, playbackSpeed, nil, fadeOutParams, timePosition)
end

function module:Get(name)
	return sounds[name]
end

return module
