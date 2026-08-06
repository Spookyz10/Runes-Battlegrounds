local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local SoundsModule = require(ServerStorage.Modules.SoundsModule)
local SFXFolder = ReplicatedStorage.Resources.SFX

local sounds = {}

for _, v in SFXFolder.Main:GetDescendants() do
	if v:IsA("Sound") then
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
