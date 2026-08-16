local Constants = require(script.Parent.Shared.Constants)
local Helpers = require(script.Parent.Shared.Helpers)

local Debris = Constants.Debris
local TS = Constants.TS
local RandomSeed = Helpers.RandomSeed

local EMERGE_TIME_MIN = 0.15
local EMERGE_TIME_MAX = 0.25
local KEEP_TIME = 0.5
local SINK_TIME = 0.5

local function easeOutBack(t)
	local c1 = 1.70158
	local c3 = c1 + 1
	return 1 + c3 * (t - 1) ^ 3 + c1 * (t - 1) ^ 2
end

return function(Params)
	local Position: Vector3 = Params.Position
	if not Position then
		return
	end

	local RockCount = Params.RockCount or 8
	local Radius = Params.Radius or 6
	local RockSize: Vector3 = Params.RockSize or Vector3.new(1.5, 1.5, 1.5)

	for i = 1, RockCount do
		local Angle = RandomSeed:NextNumber(0, math.pi * 2)
		local Dist = RandomSeed:NextNumber(0, Radius)

		local Offset = Vector3.new(math.cos(Angle) * Dist, 0, math.sin(Angle) * Dist)
		local SpawnPos = Position + Offset

		local SizeJitter = RandomSeed:NextNumber(0.6, 1.3)
		local Size = RockSize * SizeJitter

		local Rock = Instance.new("Part")
		Rock.Name = "ImpactDebrisRock"
		Rock.Anchored = true
		Rock.CanCollide = false
		Rock.CanTouch = false
		Rock.CanQuery = false
		Rock.Material = Enum.Material.Rock
		Rock.Color = Color3.fromRGB(
			RandomSeed:NextInteger(70, 110),
			RandomSeed:NextInteger(70, 110),
			RandomSeed:NextInteger(70, 110)
		)
		Rock.Size = Size
		Rock.CFrame = CFrame.new(SpawnPos)
			* CFrame.Angles(
				math.rad(RandomSeed:NextNumber(-360, 360)),
				math.rad(RandomSeed:NextNumber(-360, 360)),
				math.rad(RandomSeed:NextNumber(-360, 360))
			)
		Rock.Parent = workspace.Debris

		local restCFrame = Rock.CFrame
		local buriedCFrame = restCFrame * CFrame.new(0, -Size.Y * 1.5, 0)
		Rock.CFrame = buriedCFrame

		local EmergeTime = RandomSeed:NextNumber(EMERGE_TIME_MIN, EMERGE_TIME_MAX)
		local Delay = RandomSeed:NextNumber(0, 0.08)

		task.delay(Delay, function()
			if not Rock or not Rock.Parent then
				return
			end
			TS:Create(
				Rock,
				TweenInfo.new(EmergeTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ CFrame = restCFrame }
			):Play()
		end)

		task.delay(Delay + EmergeTime + KEEP_TIME, function()
			if not Rock or not Rock.Parent then
				return
			end
			TS:Create(Rock, TweenInfo.new(SINK_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				CFrame = buriedCFrame,
				Transparency = 1,
			}):Play()
		end)

		Debris:AddItem(Rock, Delay + EmergeTime + KEEP_TIME + SINK_TIME + 0.2)
	end
end
