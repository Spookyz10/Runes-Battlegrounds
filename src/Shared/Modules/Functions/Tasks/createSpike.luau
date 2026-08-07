local Constants = require(script.Parent.Shared.Constants)
local Debris = Constants.Debris
local RunService = Constants.RunService
local Resources = Constants.Resources
local ParticlesModule = Constants.ParticlesModule

local EMERGE_TIME = 0.25
local KEEP_TIME = 0.5
local SINK_TIME = 0.5

local function easeOutBack(t)
	local c1 = 1.70158
	local c3 = c1 + 1
	return 1 + c3 * (t - 1) ^ 3 + c1 * (t - 1) ^ 2
end

return function(Params)
	local Position = Params.Position
	local Scale = Params.Scale or 1

	if not Position then
		return
	end

	local SpikeAsset = Resources.CharacterAssets.Eclipse.Lunar:FindFirstChild("Spike")
	if not SpikeAsset then
		return
	end

	local Spike = SpikeAsset:Clone()
	Spike.Parent = workspace.Debris
	Spike:ScaleTo(Scale)

	local restCFrame = CFrame.new(Position)
	local depth = Spike:GetExtentsSize().Y
	local buriedCFrame = restCFrame * CFrame.new(0, -depth, 0)

	Spike:PivotTo(buriedCFrame)

	ParticlesModule.Emit(Spike)

	local startTime = os.clock()
	local emergeConn
	emergeConn = RunService.Heartbeat:Connect(function()
		if not Spike or not Spike.Parent then
			emergeConn:Disconnect()
			return
		end

		local alpha = math.clamp((os.clock() - startTime) / EMERGE_TIME, 0, 1)
		Spike:PivotTo(buriedCFrame:Lerp(restCFrame, easeOutBack(alpha)))

		if alpha >= 1 then
			emergeConn:Disconnect()
		end
	end)

	task.delay(EMERGE_TIME + KEEP_TIME, function()
		if not Spike or not Spike.Parent then
			return
		end

		local sinkStart = os.clock()
		local sinkConn
		sinkConn = RunService.Heartbeat:Connect(function()
			if not Spike or not Spike.Parent then
				sinkConn:Disconnect()
				return
			end

			local sinkAlpha = math.clamp((os.clock() - sinkStart) / SINK_TIME, 0, 1)
			Spike:PivotTo(restCFrame:Lerp(buriedCFrame, sinkAlpha))

			if sinkAlpha >= 1 then
				sinkConn:Disconnect()
			end
		end)
	end)

	Debris:AddItem(Spike, EMERGE_TIME + KEEP_TIME + SINK_TIME + 0.2)
end
