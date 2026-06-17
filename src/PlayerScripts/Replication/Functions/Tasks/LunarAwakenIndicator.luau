local Constants = require(script.Parent.Shared.Constants)
local RunService = Constants.RunService
local TS = Constants.TS
local LocalPlayer = Constants.LocalPlayer

local INDICATOR_COLOR = Color3.fromRGB(180, 220, 255)
local INDICATOR_SIZE_START = 4
local INDICATOR_SIZE_MAX = 60
local GROW_TIME = 0.5
local PULSE_SPEED = 2.5
local Y_OFFSET = 0.15
local PROJECTILE_ORIGIN_OFFSET = Vector3.new(0, 70, 0)
local MAX_RAYCAST_DIST = 1500

local ExcludeRayParams = RaycastParams.new()
ExcludeRayParams.FilterType = Enum.RaycastFilterType.Exclude
ExcludeRayParams.FilterDescendantsInstances = { workspace.Live, workspace.Thrown }
ExcludeRayParams.IgnoreWater = true

return function(Params)
	local Character = Params.char
	local ownerId = Params.ownerId
	if not Character or not Character.Parent then
		return
	end
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local isOwner = LocalPlayer and LocalPlayer.UserId == ownerId

	local Indicator = Instance.new("Part")
	Indicator.Name = "LunarIndicator_" .. tostring(ownerId or Character.Name)
	Indicator.Anchored = true
	Indicator.CanCollide = false
	Indicator.CanTouch = false
	Indicator.CanQuery = false
	Indicator.CastShadow = false
	Indicator.Material = Enum.Material.Neon
	Indicator.Color = INDICATOR_COLOR
	Indicator.Shape = Enum.PartType.Cylinder
	Indicator.Size = Vector3.new(0.08, INDICATOR_SIZE_START, INDICATOR_SIZE_START)
	Indicator.Transparency = 0.2
	Indicator.Parent = workspace.Thrown

	TS:Create(
		Indicator,
		TweenInfo.new(GROW_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = Vector3.new(0.08, INDICATOR_SIZE_MAX, INDICATOR_SIZE_MAX) }
	):Play()

	local startTime = os.clock()
	local conn
	conn = RunService.Heartbeat:Connect(function()
		if not Indicator or not Indicator.Parent then
			conn:Disconnect()
			return
		end

		local moonOrigin = HumRP and HumRP.Parent and (HumRP.Position + PROJECTILE_ORIGIN_OFFSET) or Indicator.Position

		local aimDir
		if isOwner then
			aimDir = shared._lunarAimDirection
		end
		if not aimDir or aimDir.Magnitude < 0.01 then
			aimDir = HumRP and HumRP.Parent and HumRP.CFrame.LookVector or Vector3.new(0, 0, -1)
		end
		aimDir = aimDir.Unit

		local ray = workspace:Raycast(moonOrigin, aimDir * MAX_RAYCAST_DIST, ExcludeRayParams)

		local landPos
		if ray then
			landPos = ray.Position
		else
			if math.abs(aimDir.Y) > 0.001 then
				local t = -moonOrigin.Y / aimDir.Y
				if t > 0 then
					landPos = moonOrigin + aimDir * t
				end
			end
		end

		if landPos then
			Indicator.CFrame = CFrame.new(landPos + Vector3.new(0, Y_OFFSET, 0)) * CFrame.Angles(0, 0, math.rad(90))
		end

		local elapsed = os.clock() - startTime
		local pulse = math.sin(elapsed * PULSE_SPEED * math.pi) * 0.15
		Indicator.Transparency = math.clamp(0.35 + pulse, 0.1, 0.6)
	end)

	if not shared._lunarIndicators then
		shared._lunarIndicators = {}
	end
	shared._lunarIndicators[ownerId] = { part = Indicator, conn = conn }
end
