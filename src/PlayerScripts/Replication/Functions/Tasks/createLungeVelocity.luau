local Constants = require(script.Parent.Shared.Constants)
local LocalPlayer = Constants.LocalPlayer
local RunService = Constants.RunService

return function(Params)
	local Character = LocalPlayer.Character
	if not Character then
		return
	end
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local speed = Params.Speed or 60
	local duration = Params.DashDuration or 5

	local bv = Instance.new("BodyVelocity")
	bv.Name = "LungeVelocity"
	bv.MaxForce = Vector3.new(math.huge, 0, math.huge)
	bv.Velocity = HumRP.CFrame.LookVector * speed
	bv.P = math.huge
	bv.Parent = HumRP

	local slowdownStart = duration * 0.3
	local startTime = tick()
	local slowingDown = false
	local slowStartTime = nil

	local conn
	conn = RunService.Heartbeat:Connect(function(dt)
		if not (bv and bv.Parent) then
			conn:Disconnect()
			return
		end

		local elapsed = tick() - startTime

		if elapsed >= slowdownStart and not slowingDown then
			slowingDown = true
			slowStartTime = tick()
		end

		if slowingDown then
			local slowElapsed = tick() - slowStartTime
			local slowDuration = duration - slowdownStart
			local t = math.clamp(slowElapsed / slowDuration, 0, 1)

			local easedT = 1 - (1 - t) ^ 2
			speed = (Params.Speed or 60) * (1 - easedT)

			if speed <= 0.5 then
				bv:Destroy()
				conn:Disconnect()
				shared._lungeConn = nil
				return
			end
		end

		bv.Velocity = HumRP.CFrame.LookVector * speed
	end)

	shared._lungeConn = conn
end
