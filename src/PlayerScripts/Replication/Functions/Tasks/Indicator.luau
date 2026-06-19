local Constants = require(script.Parent.Shared.Constants)
local RunService = Constants.RunService
local LocalPlayer = Constants.LocalPlayer

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
	local AssetTemplate = Params.asset

	if not Character or not Character.Parent then
		return
	end
	if not AssetTemplate then
		warn("[Indicator] Params.asset não fornecido para", tostring(ownerId))
		return
	end

	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local isOwner = LocalPlayer and LocalPlayer.UserId == ownerId

	local Indicator = AssetTemplate:Clone()
	Indicator.Name = "Indicator_" .. tostring(ownerId or Character.Name)

	local isAttachment = Indicator:IsA("Attachment")

	if isAttachment then
		Indicator.Parent = workspace
	else
		Indicator.Parent = workspace.Thrown
	end

	local startTime = os.clock()
	local conn

	conn = RunService.Heartbeat:Connect(function()
		if not Indicator or not Indicator.Parent then
			conn:Disconnect()
			return
		end

		local moonOrigin = HumRP and HumRP.Parent and (HumRP.Position + PROJECTILE_ORIGIN_OFFSET)
			or (isAttachment and Indicator.WorldPosition or Indicator.Position)

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
			local targetPos = landPos + Vector3.new(0, Y_OFFSET, 0)
			if isAttachment then
				Indicator.WorldPosition = targetPos
			else
				Indicator.Position = targetPos
			end
		end

		local elapsed = os.clock() - startTime
		local pulse = math.sin(elapsed * PULSE_SPEED * math.pi) * 0.15

		if not isAttachment then
			Indicator.Transparency = math.clamp(0.35 + pulse, 0.1, 0.6)
		end
	end)

	if not shared._indicators then
		shared._indicators = {}
	end

	shared._indicators[ownerId] = { part = Indicator, conn = conn }
end
