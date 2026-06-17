local Constants = require(script.Parent.Shared.Constants)
local State = require(script.Parent.Shared.State)
local CharacterAssets = Constants.CharacterAssets
local RunService = Constants.RunService
local TS = Constants.TS

local function getScalarValue(value)
	if typeof(value) == "number" then
		return value
	elseif typeof(value) == "NumberSequence" then
		local peak = value.Keypoints[1].Value
		for _, keypoint in value.Keypoints do
			peak = math.max(peak, keypoint.Value)
		end
		return peak
	end
	return nil
end

local function tweenParticleSizes(rig, duration)
	local emitters = {}

	for _, descendant in rig:GetDescendants() do
		if descendant:IsA("ParticleEmitter") then
			local originalSize = getScalarValue(descendant:GetAttribute("OriginalSize"))
			if originalSize then
				local keypoints = descendant.Size.Keypoints
				local referenceValue = keypoints[1].Value
				for _, keypoint in keypoints do
					referenceValue = math.max(referenceValue, keypoint.Value)
				end

				if referenceValue > 0 then
					table.insert(emitters, {
						emitter = descendant,
						baseKeypoints = keypoints,
						scaleTarget = originalSize / referenceValue,
					})
				end
			end
		end
	end

	if #emitters == 0 then
		return
	end

	local startTime = os.clock()

	local connection
	connection = RunService.Heartbeat:Connect(function()
		local elapsed = os.clock() - startTime
		local alpha = math.clamp(elapsed / duration, 0, 1)
		local easedAlpha = TS:GetValue(alpha, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		for _, data in emitters do
			if data.emitter and data.emitter.Parent then
				local scale = 1 + (data.scaleTarget - 1) * easedAlpha

				local newKeypoints = {}
				for index, keypoint in data.baseKeypoints do
					newKeypoints[index] =
						NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * scale, keypoint.Envelope)
				end

				data.emitter.Size = NumberSequence.new(newKeypoints)
			end
		end

		if alpha >= 1 then
			connection:Disconnect()
		end
	end)
end

return function(Params)
	local Character = Params.char
	if not Character or not Character.Parent then
		return
	end
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	State.lunarNightCount += 1
	if State.lunarNightCount == 1 then
		State:tweenToNight()
	end

	local LunarAwaken = CharacterAssets.Eclipse.Lunar.Awaken

	local MoonFog = LunarAwaken.MoonFog:Clone()
	MoonFog.Position = HumRP.Position + Vector3.new(0, -3, 0)
	MoonFog.Anchored = true
	MoonFog.Parent = workspace

	local Moon = LunarAwaken.Moon:Clone()
	Moon.Anchored = true
	Moon.CFrame = CFrame.new(HumRP.Position + Vector3.new(0, 70, 0))
	Moon.Parent = workspace

	tweenParticleSizes(Moon, 4)

	local moonConn = RunService.RenderStepped:Connect(function()
		if not HumRP or not HumRP.Parent then
			return
		end
		Moon.CFrame = CFrame.new(HumRP.Position + Vector3.new(0, 70, 0))
	end)

	State.lunarData[Character] = { moon = Moon, moonFog = MoonFog, moonConn = moonConn }
end
