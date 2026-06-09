--// Services \\--

local Debris = game:GetService('Debris')

local SoundsGroup = game:GetService("SoundService").Sounds



--// Module \\--

local module = {}

local ThrownFolder = workspace.Thrown or workspace:WaitForChild('Thrown', 5)



--// Module Functions \\--

function module:AddSound(Sound: Sound, SoundParam, Parameters): Sound
	if typeof(Sound) ~= "Instance" or not Sound:IsA("Sound") or typeof(SoundParam) == "string" then return end

	Parameters = Parameters or {}

	local ParameterType = typeof(SoundParam)

	if typeof(Sound) == "Instance" then
		Sound = Sound:Clone()
		Sound.SoundGroup = SoundsGroup

	elseif typeof(Sound) == "number" or typeof(Sound) == "string" then
		local RealSound = Instance.new("Sound")
		RealSound.SoundGroup = SoundsGroup
		RealSound.SoundId = typeof(Sound) == "number" and "rbxassetid://" .. tostring(Sound) or Sound
		RealSound.Volume = Parameters.Volume or 1
		RealSound.RollOffMaxDistance = Parameters.RollOffMaxDistance or 300
		RealSound.RollOffMinDistance = Parameters.RollOffMinDistance or 10
		RealSound.RollOffMode = Parameters.RollOffMode or Enum.RollOffMode.InverseTapered

		Sound = RealSound

	end

	local SoundParent

	if SoundParam == nil or (ParameterType ~= "Vector3" and ParameterType ~= "CFrame") then
		SoundParent = SoundParam or workspace

	elseif ParameterType == 'Vector3' or ParameterType == "CFrame" then
		local PositionName = "WorldPosition"
		if ParameterType == "CFrame" then
			PositionName = "WorldCFrame"
		end

		local SoundPart = Instance.new('Attachment')
		SoundPart.Parent = workspace.Terrain
		SoundPart[PositionName] = SoundParam

		SoundParent = SoundPart

	end

	Sound.Ended:Once(function()
		Sound:Destroy()
	end)

	Sound.Parent = SoundParent
	Sound:Play()

	return Sound
end

return module
