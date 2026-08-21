local module = {}

local Players = game:GetService("Players")

local SPAWN_IFRAME_DURATION = 5

local LevelValue = {
	Base = 1,
	Strong = 2,
	All = 3,
}

function module:HasiFrame(Character, pierceLevel)
	local current = Character:GetAttribute("iFrames") or 0
	if current <= 0 then
		return false
	end

	local level = pierceLevel
	if level == nil then
		level = 0
	elseif typeof(level) ~= "number" then
		warn("[iFramesService] Invalid pierceLevel type '" .. typeof(level) .. "', defaulting to 0")
		level = 0
	end

	return current > level
end

function module:AddiFrames(Character, Level)
	local value = LevelValue[Level]
	if not value then
		warn("[iFramesService] Invalid level '" .. tostring(Level) .. "'")
		return
	end

	local current = Character:GetAttribute("iFrames") or 0
	if current >= value then
		return
	end

	Character:SetAttribute("iFrames", value)
end

function module:RemoveiFrames(Character, Level)
	local current = Character:GetAttribute("iFrames") or 0
	if current <= 0 then
		return
	end

	local value = LevelValue[Level]
	if not value then
		warn("[iFramesService] Invalid level '" .. tostring(Level) .. "'")
		return
	end

	if value >= 3 then
		Character:SetAttribute("iFrames", 0)
	elseif value == 2 then
		if current >= 2 then
			Character:SetAttribute("iFrames", 1)
		end
	elseif value == 1 then
		if current <= 1 then
			Character:SetAttribute("iFrames", 0)
		end
	end
end

function module:GetLevel(Character)
	return Character:GetAttribute("iFrames") or 0
end

local function grantSpawnProtection(Character)
	Character:SetAttribute("SpawnProtectionToken", tick())
	local ThisToken = Character:GetAttribute("SpawnProtectionToken")

	module:AddiFrames(Character, "All")

	task.delay(SPAWN_IFRAME_DURATION, function()
		if not Character or not Character.Parent then
			return
		end
		if Character:GetAttribute("SpawnProtectionToken") ~= ThisToken then
			return
		end
		module:RemoveiFrames(Character, "All")
	end)
end

Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(Character)
		grantSpawnProtection(Character)
	end)
end)

for _, Player in Players:GetPlayers() do
	Player.CharacterAdded:Connect(function(Character)
		grantSpawnProtection(Character)
	end)

	if Player.Character then
		grantSpawnProtection(Player.Character)
	end
end

return module
