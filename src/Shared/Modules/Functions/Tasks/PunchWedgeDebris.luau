local Constants = require(script.Parent.Shared.Constants)
local Helpers = require(script.Parent.Shared.Helpers)

local Debris = Constants.Debris
local TS = Constants.TS
local MapRayParams = Constants.MapRayParams
local RandomSeed = Helpers.RandomSeed

-- Ângulo total do "bico" do wedge (estilo sinal de maior que < com a boca
-- virada pra frente). Cada linha abre HALF_ANGLE graus pra cada lado do
-- vetor de frente do personagem.
local HALF_ANGLE = 30

local ROCKS_PER_LINE = 5
local LINE_LENGTH = 10
local ROCK_BASE_SIZE = 0.9

local EMERGE_TIME = 0.18
local KEEP_TIME = 0.45
local SINK_TIME = 0.4

return function(Params)
	local Character = Params.char or Params.Char
	if not Character or not Character.Parent then
		return
	end

	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local lv = HumRP.CFrame.LookVector
	local forward = Vector3.new(lv.X, 0, lv.Z)
	if forward.Magnitude < 0.001 then
		forward = Vector3.new(0, 0, -1)
	else
		forward = forward.Unit
	end

	local origin = HumRP.Position

	local function spawnLine(SideSign)
		local RotatedDir = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), math.rad(HALF_ANGLE * SideSign)) * forward

		for i = 1, ROCKS_PER_LINE do
			local t = i / ROCKS_PER_LINE
			local dist = LINE_LENGTH * t

			local pointPos = origin + RotatedDir * dist

			local _, RayPosition = Helpers.performRaycast({
				orig = pointPos + Vector3.new(0, 5, 0),
				dir = Vector3.new(0, -12, 0),
				Whitelist = MapRayParams.FilterDescendantsInstances,
			})

			local groundPos = RayPosition or (pointPos - Vector3.new(0, 2, 0))

			local sizeScale = 1 + t * 0.6
			local Size = Vector3.new(ROCK_BASE_SIZE, ROCK_BASE_SIZE, ROCK_BASE_SIZE)
				* sizeScale
				* RandomSeed:NextNumber(0.85, 1.15)

			local Rock = Instance.new("Part")
			Rock.Name = "PunchWedgeRock"
			Rock.Anchored = true
			Rock.CanCollide = false
			Rock.CanTouch = false
			Rock.CanQuery = false
			Rock.Material = Enum.Material.Rock
			Rock.Color = Color3.fromRGB(80, 80, 85)
			Rock.Size = Size
			Rock.CFrame = CFrame.new(groundPos)
				* CFrame.Angles(
					math.rad(RandomSeed:NextNumber(-360, 360)),
					math.rad(RandomSeed:NextNumber(-360, 360)),
					math.rad(RandomSeed:NextNumber(-360, 360))
				)
			Rock.Parent = workspace.Debris

			local restCFrame = Rock.CFrame
			local buriedCFrame = restCFrame * CFrame.new(0, -Size.Y * 2, 0)
			Rock.CFrame = buriedCFrame

			local delay = t * 0.12

			task.delay(delay, function()
				if not Rock or not Rock.Parent then
					return
				end
				TS:Create(
					Rock,
					TweenInfo.new(EMERGE_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ CFrame = restCFrame }
				):Play()
			end)

			task.delay(delay + EMERGE_TIME + KEEP_TIME, function()
				if not Rock or not Rock.Parent then
					return
				end
				TS:Create(Rock, TweenInfo.new(SINK_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					CFrame = buriedCFrame,
					Transparency = 1,
				}):Play()
			end)

			Debris:AddItem(Rock, delay + EMERGE_TIME + KEEP_TIME + SINK_TIME + 0.2)
		end
	end

	spawnLine(1)
	spawnLine(-1)
end
