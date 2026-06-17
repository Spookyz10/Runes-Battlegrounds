local Constants = require(script.Parent.Shared.Constants)
local Helpers = require(script.Parent.Shared.Helpers)

local TS = Constants.TS
local Debris = Constants.Debris
local RandomSeed = Helpers.RandomSeed

return function(Params)
	for i = 1, RandomSeed:NextInteger(2, 6) do
		local Shard = Instance.new("Part")
		Shard.Anchored = true
		Shard.CanCollide = false
		Shard.Material = Enum.Material.Neon
		Shard.Color = Color3.new(1, 1, 1)
		Shard.CanTouch = false
		Shard.Size = Vector3.new(0.15000000596046448, 0.15000000596046448, 3)
		Shard.CanQuery = false
		Shard.Transparency = 0.6

		local Mesh = Instance.new("SpecialMesh")
		Mesh.MeshType = "Sphere"
		Mesh.Parent = Shard

		Shard.CFrame = CFrame.lookAlong(
			(Params.RootPart.CFrame * CFrame.new(RandomSeed:NextNumber(-1, 1), RandomSeed:NextNumber(-1, 1), 0)).Position,
			-Params.LookVector
		)
		Shard.Parent = workspace.Thrown

		local ZSize = RandomSeed:NextNumber(10, 20)
		local TweenTime = RandomSeed:NextNumber(0.1, 0.15)
		local Lifetime = RandomSeed:NextNumber(0.2, 0.4)

		TS:Create(Shard, TweenInfo.new(TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.15, 0.15, ZSize - 2),
			CFrame = Shard.CFrame * CFrame.new(0, 0, ZSize / 2),
		}):Play()

		task.delay(TweenTime, function()
			TS:Create(Shard, TweenInfo.new(Lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(0, 0, 0),
				CFrame = Shard.CFrame * CFrame.new(0, 0, ZSize / 2),
			}):Play()
		end)

		Debris:AddItem(Shard, Lifetime + TweenTime)
	end
end
