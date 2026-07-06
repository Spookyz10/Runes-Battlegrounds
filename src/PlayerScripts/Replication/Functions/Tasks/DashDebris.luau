local Constants = require(script.Parent.Shared.Constants)
local Helpers = require(script.Parent.Shared.Helpers)

local Debris = Constants.Debris
local TS = Constants.TS
local MapRayParams = Constants.MapRayParams

local SPAWN_INTERVAL = 0.05
local PIECE_SIZE = 0.5
local RAY_DISTANCE = 8
local EMERGE_TIME = 0.18
local KEEP_TIME = 0.6
local SINK_TIME = 3

local ACTIVE = {}

local function getKey(char)
	return tostring(char)
end

local function spawnPiece(PrimaryPart)
	local hitPart, hitPosition, hitMaterial, hitNormal = Helpers.performRaycast({
		orig = PrimaryPart.Position,
		dir = Vector3.new(0, -RAY_DISTANCE, 0),
		Whitelist = MapRayParams.FilterDescendantsInstances,
	})

	if not hitPart then
		hitPart, hitPosition, hitMaterial, hitNormal = Helpers.performRaycast({
			orig = PrimaryPart.Position,
			dir = Vector3.new(0, -RAY_DISTANCE, 0),
			Ignore = { workspace.Live, workspace.Debris },
		})
	end

	if not hitPart then
		return
	end

	local alignCFrame =
		Helpers.calculateCFrameBetweenVectors(CFrame.new(hitPosition).UpVector, hitNormal, Vector3.new(0, 1, 0))

	local restCFrame = CFrame.new(hitPosition) * alignCFrame * CFrame.Angles(0, math.rad(math.random(0, 360)), 0)

	local Piece = Instance.new("Part")
	Piece.Name = "DashDebrisPiece"
	Piece.Anchored = true
	Piece.CanCollide = false
	Piece.CanTouch = false
	Piece.CanQuery = false
	Piece.Material = hitMaterial
	Piece.Color = hitPart.Color
	Piece.Size = Vector3.new(PIECE_SIZE, PIECE_SIZE, PIECE_SIZE)
	Piece.CFrame = restCFrame * CFrame.new(0, -PIECE_SIZE, 0)
	Piece.Parent = workspace.Debris

	TS
		:Create(
			Piece,
			TweenInfo.new(EMERGE_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ CFrame = restCFrame }
		)
		:Play()

	task.delay(EMERGE_TIME + KEEP_TIME, function()
		if not Piece or not Piece.Parent then
			return
		end
		TS:Create(
			Piece,
			TweenInfo.new(SINK_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ CFrame = restCFrame * CFrame.new(0, -PIECE_SIZE, 0), Transparency = 1 }
		):Play()
	end)

	Debris:AddItem(Piece, EMERGE_TIME + KEEP_TIME + SINK_TIME + 0.1)
end

local Handlers = {}

function Handlers.Start(params)
	local char = params.char
	if not char or not char.Parent then
		return
	end

	local key = getKey(char)

	if ACTIVE[key] then
		ACTIVE[key].running = false
	end

	local data = { running = true }
	ACTIVE[key] = data

	task.spawn(function()
		while data.running do
			local PrimaryPart = char.PrimaryPart
			if not PrimaryPart or not PrimaryPart.Parent then
				break
			end

			spawnPiece(PrimaryPart)

			task.wait(SPAWN_INTERVAL)
		end
	end)
end

function Handlers.Stop(params)
	local char = params.char
	if not char then
		return
	end

	local key = getKey(char)
	local data = ACTIVE[key]
	if data then
		data.running = false
		ACTIVE[key] = nil
	end
end

return function(Params)
	local handler = Handlers[Params.func]
	if handler then
		handler(Params)
	end
end
