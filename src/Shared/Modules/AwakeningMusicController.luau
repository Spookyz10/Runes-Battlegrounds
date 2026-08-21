local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Data = require(ReplicatedStorage.Shared.Data).client

local ActiveSounds = {}

local function applySetting(Sound)
	local Enabled = Data.Settings.AwakeningMusic()
	Sound.Volume = Enabled and (Sound:GetAttribute("BaseVolume") or Sound.Volume) or 0
end

local function trackSound(Sound)
	if not Sound:GetAttribute("AwakeningMusic") then
		return
	end

	if not Sound:GetAttribute("BaseVolume") then
		Sound:SetAttribute("BaseVolume", Sound.Volume)
	end

	ActiveSounds[Sound] = true
	applySetting(Sound)

	Sound.Destroying:Once(function()
		ActiveSounds[Sound] = nil
	end)
end

workspace.DescendantAdded:Connect(function(desc)
	if desc:IsA("Sound") then
		trackSound(desc)
	end
end)

for _, desc in workspace:GetDescendants() do
	if desc:IsA("Sound") then
		trackSound(desc)
	end
end

Data.Settings.AwakeningMusic.Changed(function()
	for Sound in ActiveSounds do
		if Sound and Sound.Parent then
			applySetting(Sound)
		end
	end
end)
