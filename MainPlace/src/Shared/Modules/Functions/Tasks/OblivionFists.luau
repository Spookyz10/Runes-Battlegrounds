local RunService = game:GetService("RunService")

local Constants = require(script.Parent.Shared.Constants)
local CharacterAssets = Constants.CharacterAssets

local FISTS_START_DISTANCE = 700
local FISTS_SLOW_SPEED = 5
local FISTS_SLOW_TIME = 1.2
local FISTS_FAST_SPEED = 120

local ORIENT_OFFSET_X = 45
local ORIENT_OFFSET_Y = 0
local ORIENT_OFFSET_Z = 0

local ACTIVE = {}

local function getKey(char)
	return tostring(char)
end

local Handlers = {}

function Handlers.Start(params)
	local Character = params.char
	local targetPosition = params.targetPosition
	local waitTime = params.waitTime or 2

	if not Character or not Character.Parent or not targetPosition then
		return
	end

	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local key = getKey(Character)

	local Old = ACTIVE[key]
	if Old then
		if Old.conn then
			Old.conn:Disconnect()
		end
		if Old.model and Old.model.Parent then
			Old.model:Destroy()
		end
		ACTIVE[key] = nil
	end

	local ObliviionAssets = CharacterAssets.Shattered.Oblivion
	local FistsAsset = ObliviionAssets:FindFirstChild("Fists")
	if not FistsAsset then
		return
	end

	local approachDirection = targetPosition - HumRP.Position
	local flatApproach = Vector3.new(approachDirection.X, 0, approachDirection.Z)
	if flatApproach.Magnitude < 0.001 then
		local lookVector = HumRP.CFrame.LookVector
		flatApproach = Vector3.new(lookVector.X, 0, lookVector.Z)
	end
	flatApproach = flatApproach.Unit

	local totalDistance = FISTS_START_DISTANCE
	local startPosition = targetPosition - flatApproach * totalDistance

	local FistsClone = FistsAsset:Clone()
	local startCFrame = CFrame.new(startPosition, targetPosition)
		* CFrame.Angles(math.rad(ORIENT_OFFSET_X), math.rad(ORIENT_OFFSET_Y), math.rad(ORIENT_OFFSET_Z))
	FistsClone:PivotTo(startCFrame)
	FistsClone.Parent = workspace

	local data = { model = FistsClone, conn = nil, cancelled = false }
	ACTIVE[key] = data

	task.delay(waitTime, function()
		if data.cancelled or not FistsClone.Parent then
			return
		end

		local slowDistance = FISTS_SLOW_SPEED * FISTS_SLOW_TIME
		local remainingDistance = math.max(totalDistance - slowDistance, 0)
		local fastTime = remainingDistance / FISTS_FAST_SPEED

		local startTime = os.clock()

		data.conn = RunService.Heartbeat:Connect(function()
			if data.cancelled or not FistsClone.Parent then
				if data.conn then
					data.conn:Disconnect()
					data.conn = nil
				end
				return
			end

			local elapsed = os.clock() - startTime
			local distanceTraveled

			if elapsed <= FISTS_SLOW_TIME then
				distanceTraveled = FISTS_SLOW_SPEED * elapsed
			else
				local fastElapsed = math.clamp(elapsed - FISTS_SLOW_TIME, 0, fastTime)
				distanceTraveled = slowDistance + FISTS_FAST_SPEED * fastElapsed
			end

			distanceTraveled = math.clamp(distanceTraveled, 0, totalDistance)

			local pos = startPosition + flatApproach * distanceTraveled

			FistsClone:PivotTo(
				CFrame.new(pos, targetPosition)
					* CFrame.Angles(math.rad(ORIENT_OFFSET_X), math.rad(ORIENT_OFFSET_Y), math.rad(ORIENT_OFFSET_Z))
			)

			if elapsed >= FISTS_SLOW_TIME + fastTime then
				if data.conn then
					data.conn:Disconnect()
					data.conn = nil
				end

				if FistsClone and FistsClone.Parent then
					FistsClone:Destroy()
				end

				ACTIVE[key] = nil
			end
		end)
	end)
end

function Handlers.Stop(params)
	local Character = params.char
	if not Character then
		return
	end

	local key = getKey(Character)
	local data = ACTIVE[key]
	if not data then
		return
	end

	data.cancelled = true
	ACTIVE[key] = nil

	if data.conn then
		data.conn:Disconnect()
	end

	if data.model and data.model.Parent then
		--data.model:Destroy()
	end
end

return function(params)
	local handler = Handlers[params.func or "Start"]
	if handler then
		handler(params)
	end
end
