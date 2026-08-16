local GroundCrater = require(script.Parent["Ground Crater"])
local Constants = require(script.Parent.Shared.Constants)
local Helpers = require(script.Parent.Shared.Helpers)

local RandomSeed = Helpers.RandomSeed

local HALF_ANGLE = 26

local ROCKS_PER_LINE = 9
local LINE_LENGTH = 35

local CRATER_RINGS = 1
local CRATER_RING_SPACING = 2.5
local CRATER_RING_GAP = 0.15
local CRATER_AMOUNT_BASE = 6

local CRATER_DEBRIS_SIZE_MIN = 1.4
local CRATER_DEBRIS_SIZE_MAX = 3
local CRATER_DEBRIS_HEIGHT_MIN = 1.4
local CRATER_DEBRIS_HEIGHT_MAX = 2.6

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
			local delay = t * 0.18

			task.delay(delay, function()
				GroundCrater({
					Seed = RandomSeed:NextInteger(1, 2147483647),
					start = pointPos + Vector3.new(0, 5, 0),
					["end"] = Vector3.new(0, -14, 0),
					amount = CRATER_AMOUNT_BASE,
					size = 0.6 + t * 0.5,
					sizemult = 0.85,
					nodebris = true,
					rings = CRATER_RINGS,
					ringSpacing = CRATER_RING_SPACING,
					ringSizeGrowth = 1,
					ringGap = CRATER_RING_GAP,
					outwardTilt = false,
					debrisSizeMin = CRATER_DEBRIS_SIZE_MIN,
					debrisSizeMax = CRATER_DEBRIS_SIZE_MAX,
					debrisHeightMin = CRATER_DEBRIS_HEIGHT_MIN,
					debrisHeightMax = CRATER_DEBRIS_HEIGHT_MAX,
				})
			end)
		end
	end

	spawnLine(1)
	spawnLine(-1)
end
