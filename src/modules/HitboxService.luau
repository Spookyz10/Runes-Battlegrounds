local HitboxService = {}
local Players = game:GetService("Players")

local HITBOX_SIZE = Vector3.new(3, 5, 2.5)
local HITBOX_ATTR = "PlayerHitbox"

local function init(character)
	local root = character:WaitForChild("HumanoidRootPart")

	local box = Instance.new("Part")
	box.Name = "Hitbox"
	box.Size = HITBOX_SIZE
	box.Transparency = 0.2
	box.CanCollide = false
	box.CastShadow = false
	box.Massless = true
	box.Position = root.Position
	box:SetAttribute(HITBOX_ATTR, true)
	box.Parent = character

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = box
	weld.Parent = box
end

function HitboxService.query(cframe, size, exclude)
	local params = OverlapParams.new()
	params.FilterDescendantsInstances = exclude
	params.FilterType = Enum.RaycastFilterType.Exclude

	local parts = workspace:GetPartBoundsInBox(cframe, size, params)
	local hits = {}
	local seen = {}

	for _, part in parts do
		if not part:GetAttribute(HITBOX_ATTR) then
			continue
		end
		local char = part.Parent
		if seen[char] then
			continue
		end
		seen[char] = true
		hits[#hits + 1] = char
	end

	return hits
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(init)
end)

for _, player in Players:GetPlayers() do
	if player.Character then
		init(player.Character)
	end
	player.CharacterAdded:Connect(init)
end

return HitboxService
