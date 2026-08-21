local TweenService = game:GetService("TweenService")

local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris

local DEFAULTS = {
	HalfAngle = 26,
	StepsPerSide = 7,
	FirstDistance = 3,
	LastDistance = 20,

	SpreadRadius = 1.6,
	ChunksPerStepMin = 1,
	ChunksPerStepMax = 3,

	StartSize = Vector3.new(1, 0.9, 1),
	EndSize = Vector3.new(5.2, 4.2, 5.2),
	SizeRandomSpread = 0.35,

	RiseTime = 0.22,
	HoldTime = 7,

	AxisScaleMin = 0.55,
	AxisScaleMax = 1.35,

	Shapes = { "Part", "WedgePart", "CornerWedgePart" },
	ShapeWeights = { 0.55, 0.3, 0.15 },
}

local BAD_MATERIALS = {
	[Enum.Material.Neon] = true,
	[Enum.Material.Glass] = true,
	[Enum.Material.ForceField] = true,
	[Enum.Material.Ice] = true,
}

local FALLBACK_MATERIAL = Enum.Material.Slate
local FALLBACK_COLOR = Color3.fromRGB(96, 96, 102)

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = { workspace.Live, workspace.Debris }
rayParams.IgnoreWater = true

local function getSurfaceMaterialAndColor(result: RaycastResult)
	local material = result.Material
	local color

	if result.Instance:IsA("BasePart") then
		color = result.Instance.Color
	else
		color = workspace.Terrain:GetMaterialColor(result.Material)
	end

	if BAD_MATERIALS[material] then
		material = FALLBACK_MATERIAL
		color = FALLBACK_COLOR
	end

	local shade = 1 + (math.random() * 2 - 1) * 0.08
	color = Color3.new(
		math.clamp(color.R * shade, 0, 1),
		math.clamp(color.G * shade, 0, 1),
		math.clamp(color.B * shade, 0, 1)
	)

	return material, color
end

local function pickShape(config)
	local roll = math.random()
	local cumulative = 0
	for index, weight in config.ShapeWeights do
		cumulative += weight
		if roll <= cumulative then
			return config.Shapes[index]
		end
	end
	return config.Shapes[1]
end

local function randomSize(progress: number, config)
	local base = config.StartSize:Lerp(config.EndSize, progress)

	local function axisJitter(value)
		local jitter = 1 + (math.random() * 2 - 1) * config.SizeRandomSpread
		local scaled = value
			* jitter
			* (config.AxisScaleMin + math.random() * (config.AxisScaleMax - config.AxisScaleMin))
		return math.max(scaled, 0.4)
	end

	return Vector3.new(axisJitter(base.X), axisJitter(base.Y), axisJitter(base.Z))
end

local function spawnChunk(point: Vector3, size: Vector3, rotation: CFrame, config)
	local result = workspace:Raycast(point + Vector3.new(0, 12, 0), Vector3.new(0, -30, 0), rayParams)
	if not result then
		return
	end

	local material, color = getSurfaceMaterialAndColor(result)

	local chunk = Instance.new(pickShape(config))
	chunk.Name = "ShatteredPunchDebris"
	chunk.Anchored = true
	chunk.CanCollide = true
	chunk.CanQuery = true
	chunk.CanTouch = true
	chunk.Material = material
	chunk.Color = color
	chunk.CastShadow = false

	local flatSize = Vector3.new(size.X, 0.05, size.Z)
	chunk.Size = flatSize
	chunk.CFrame = CFrame.new(result.Position - Vector3.new(0, size.Y / 2, 0)) * rotation
	chunk.Parent = workspace.Debris

	TweenService:Create(
		chunk,
		TweenInfo.new(config.RiseTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size = size, CFrame = CFrame.new(result.Position + Vector3.new(0, size.Y / 2, 0)) * rotation }
	):Play()

	task.delay(config.HoldTime, function()
		if not chunk.Parent then
			return
		end
		TweenService:Create(
			chunk,
			TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Transparency = 1, Size = flatSize }
		):Play()
	end)

	Debris:AddItem(chunk, config.RiseTime + config.HoldTime + 0.4)
end

local function resolveConfig(params)
	local config = table.clone(DEFAULTS)
	for key in DEFAULTS do
		if params[key] ~= nil then
			config[key] = params[key]
		end
	end
	return config
end

return function(params)
	local character = params.char or params.Char
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local config = resolveConfig(params)

	local look = root.CFrame.LookVector
	local forward = Vector3.new(look.X, 0, look.Z)
	if forward.Magnitude < 0.001 then
		return
	end
	forward = forward.Unit
	local right = Vector3.new(forward.Z, 0, -forward.X)

	for _, side in { -1, 1 } do
		local sideDirection = CFrame.fromAxisAngle(Vector3.yAxis, math.rad(config.HalfAngle * side)) * forward

		for step = 1, config.StepsPerSide do
			local progress = config.StepsPerSide > 1 and (step - 1) / (config.StepsPerSide - 1) or 1
			local distance = config.FirstDistance + (config.LastDistance - config.FirstDistance) * progress
			local stepCenter = root.Position + sideDirection * distance

			local chunkCount = math.random(config.ChunksPerStepMin, config.ChunksPerStepMax)

			for chunkIndex = 1, chunkCount do
				local angle = math.random() * math.pi * 2
				local radius = math.random() * config.SpreadRadius * (0.7 + progress * 0.6)
				local scatterOffset = (right * math.cos(angle) + forward * math.sin(angle)) * radius

				local size = randomSize(progress, config)
				local rotation = CFrame.Angles(
					math.rad(math.random(-10, 10)),
					math.rad(math.random(0, 360)),
					math.rad(math.random(-10, 10))
				)

				local delay = (step - 1) * 0.07 + math.random() * 0.05

				task.delay(delay, function()
					spawnChunk(stepCenter + scatterOffset, size, rotation, config)
				end)
			end
		end
	end
end
