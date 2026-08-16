local TweenService = game:GetService("TweenService")

local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris

-- Cada lado do "<" recebe blocos grandes, progressivamente maiores e com
-- rotação sutil para o efeito não parecer perfeitamente simétrico.
local HALF_ANGLE = 26
local BLOCKS_PER_SIDE = 5
local FIRST_DISTANCE = 6
local DISTANCE_STEP = 8.5
local FIRST_SIZE = Vector3.new(7, 7, 7)
local SIZE_STEP = Vector3.new(0.9, 0.65, 0.9)
local RISE_TIME = 0.22
local HOLD_TIME = 7

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = { workspace.Live, workspace.Debris }
rayParams.IgnoreWater = true

local function getSurfaceColor(result: RaycastResult)
	if result.Instance:IsA("BasePart") then
		return result.Instance.Color
	end
	return workspace.Terrain:GetMaterialColor(result.Material)
end

local function spawnBlock(point: Vector3, size: Vector3, rotation: CFrame)
	local result = workspace:Raycast(point + Vector3.new(0, 12, 0), Vector3.new(0, -30, 0), rayParams)
	if not result then
		return
	end

	local block = Instance.new("Part")
	block.Name = "ShatteredPunchBlock"
	block.Anchored = true
	block.CanCollide = true
	block.CanQuery = true
	block.CanTouch = true
	block.Material = result.Material
	block.Color = getSurfaceColor(result)
	block.CastShadow = false
	block.Size = Vector3.new(size.X, 0.05, size.Z)
	block.CFrame = CFrame.new(result.Position - Vector3.new(0, size.Y / 2, 0)) * rotation
	block.Parent = workspace.Debris

	TweenService:Create(
		block,
		TweenInfo.new(RISE_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size = size, CFrame = CFrame.new(result.Position + Vector3.new(0, size.Y / 2, 0)) * rotation }
	):Play()

	task.delay(HOLD_TIME, function()
		if not block.Parent then
			return
		end
		TweenService:Create(
			block,
			TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Transparency = 1, Size = Vector3.new(size.X, 0.05, size.Z) }
		):Play()
	end)

	Debris:AddItem(block, RISE_TIME + HOLD_TIME + 0.4)
end

return function(params)
	local character = params.char or params.Char
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local look = root.CFrame.LookVector
	local forward = Vector3.new(look.X, 0, look.Z)
	if forward.Magnitude < 0.001 then
		return
	end
	forward = forward.Unit

	for _, side in { -1, 1 } do
		local direction = CFrame.fromAxisAngle(Vector3.yAxis, math.rad(HALF_ANGLE * side)) * forward
		for index = 1, BLOCKS_PER_SIDE do
			local distance = FIRST_DISTANCE + (index - 1) * DISTANCE_STEP
			local size = FIRST_SIZE + SIZE_STEP * (index - 1)
			local rotation = CFrame.Angles(
				math.rad(math.random(-4, 4)),
				math.rad(math.random(-14, 14)),
				math.rad(math.random(-4, 4))
			)
			task.delay((index - 1) * 0.07, function()
				spawnBlock(root.Position + direction * distance, size, rotation)
			end)
		end
	end
end
