local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris

local BLOCK_SIZE = Vector3.new(0.5, 0.5, 0.5)
local SPAWN_INTERVAL = 0.1
local LIFETIME = 3

return function(Params)
	if not Params.char then
		return
	end

	local Character = Params.char
	local start = time()

	task.spawn(function()
		while time() - start < (Params.time or 0.2) do
			local PrimaryPart = Character.PrimaryPart
			if not PrimaryPart or not PrimaryPart.Parent then
				break
			end

			local rayParams = RaycastParams.new()
			rayParams.FilterType = Enum.RaycastFilterType.Include
			rayParams.FilterDescendantsInstances = { workspace.Map }

			local raycast = workspace:Raycast(PrimaryPart.Position, Vector3.new(0, -5, 0), rayParams)

			if raycast then
				local Block = Instance.new("Part")
				Block.Name = "DashDebrisBlock"
				Block.Size = BLOCK_SIZE
				Block.Anchored = true
				Block.CanCollide = false
				Block.CanTouch = false
				Block.CanQuery = false
				Block.Material = raycast.Instance.Material
				Block.Color = raycast.Instance.Color
				Block.CFrame = CFrame.new(raycast.Position + Vector3.new(0, 0.15, 0))
					* CFrame.Angles(
						math.rad(math.random(0, 360)),
						math.rad(math.random(0, 360)),
						math.rad(math.random(0, 360))
					)
				Block.Parent = workspace.Debris

				Debris:AddItem(Block, LIFETIME)
			end

			task.wait(SPAWN_INTERVAL)
		end
	end)
end
