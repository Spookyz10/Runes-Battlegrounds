local Constants = require(script.Parent.Constants)
local RunService = Constants.RunService

local PULSE_SPEED = 2.5
local Y_OFFSET = 0.15
local MAX_RAYCAST_DIST = 1500

local ExcludeRayParams = RaycastParams.new()
ExcludeRayParams.FilterType = Enum.RaycastFilterType.Exclude
ExcludeRayParams.FilterDescendantsInstances = { workspace.Live, workspace.Debris }
ExcludeRayParams.IgnoreWater = true

local IndicatorService = {}
IndicatorService._active = {}

function IndicatorService:Create(params)
	local id = params.id
	assert(id, "[IndicatorService] params.id é obrigatório")

	if self._active[id] then
		self:Destroy(id)
	end

	local asset = params.asset
	local character = params.character

	local getRayOrigin = params.getRayOrigin
	local getDirection = params.getDirection

	local HumRP = character and character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local indicator = asset:Clone()
	indicator.Name = "Indicator_" .. tostring(id)

	local isAttachment = indicator:IsA("Attachment")
	if isAttachment then
		indicator.Parent = workspace
	else
		indicator.Parent = workspace.Debris
	end

	local startTime = os.clock()
	local lastPosition = HumRP.Position

	local conn = RunService.Heartbeat:Connect(function()
		if not indicator or not indicator.Parent then
			return
		end

		local origin = getRayOrigin and getRayOrigin()
			or (HumRP and HumRP.Parent and HumRP.Position + Vector3.new(0, 70, 0))
		local direction = getDirection and getDirection() or workspace.CurrentCamera.CFrame.LookVector

		if not origin then
			return
		end

		direction = direction.Unit

		local ray = workspace:Raycast(origin, direction * MAX_RAYCAST_DIST, ExcludeRayParams)
		local landPos

		if ray then
			landPos = ray.Position
		else
			if math.abs(direction.Y) > 0.001 then
				local t = -origin.Y / direction.Y
				if t > 0 then
					landPos = origin + direction * t
				end
			end

			if not landPos then
				landPos = lastPosition
			end
		end

		if landPos then
			lastPosition = landPos + Vector3.new(0, Y_OFFSET, 0)
			if isAttachment then
				indicator.WorldPosition = lastPosition
			else
				indicator.Position = lastPosition
			end
		end

		local elapsed = os.clock() - startTime
		local pulse = math.sin(elapsed * PULSE_SPEED * math.pi) * 0.15
		if not isAttachment then
			indicator.Transparency = math.clamp(0.35 + pulse, 0.1, 0.6)
		end
	end)

	self._active[id] = {
		indicator = indicator,
		conn = conn,
		getPosition = function()
			return lastPosition
		end,
	}
end

function IndicatorService:GetPosition(id)
	local entry = self._active[id]
	if not entry then
		return nil
	end
	return entry.getPosition()
end

function IndicatorService:Destroy(id)
	local entry = self._active[id]
	if not entry then
		return
	end

	if entry.conn then
		entry.conn:Disconnect()
	end

	local ind = entry.indicator
	if ind and ind.Parent then
		for _, desc in ind:GetDescendants() do
			if desc:IsA("Beam") or desc:IsA("ParticleEmitter") then
				desc.Enabled = false
			end
		end
		task.delay(5, function()
			if ind and ind.Parent then
				ind:Destroy()
			end
		end)
	end

	self._active[id] = nil
end

return IndicatorService
