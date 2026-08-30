local RunService = game:GetService("RunService")

local Constants = require(script.Parent.Shared.Constants)
local CharacterAssets = Constants.CharacterAssets

local FISTS_SLOW_SPEED = 5
local FISTS_SLOW_TIME = 1.2
local FISTS_FAST_SPEED = 200

local ORIENT_OFFSET_X = 45
local ORIENT_OFFSET_Y = 0
local ORIENT_OFFSET_Z = 0

local ACTIVE: { [string]: { model: Model, conn: RBXScriptConnection?, cancelled: boolean, targetPosition: Vector3? } } =
	{}

local function getKey(char: Model): string
	return tostring(char)
end

local function getOrientedCFrame(position: Vector3, lookAt: Vector3): CFrame
	return CFrame.new(position, lookAt)
		* CFrame.Angles(math.rad(ORIENT_OFFSET_X), math.rad(ORIENT_OFFSET_Y), math.rad(ORIENT_OFFSET_Z))
end

local Handlers = {}

function Handlers.Start(params)
	local Character = params.char
	local targetPosition = params.targetPosition

	if not Character or not Character.Parent or not targetPosition then
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

	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local startPosition = HumRP.Position
	local direction = (targetPosition - startPosition).Unit

	local FistsClone = FistsAsset:Clone()
	FistsClone:PivotTo(getOrientedCFrame(startPosition, targetPosition))
	FistsClone.Parent = workspace

	local data = { model = FistsClone, conn = nil, cancelled = false, targetPosition = targetPosition }
	ACTIVE[key] = data

	local startTime = os.clock()

	data.conn = RunService.Heartbeat:Connect(function()
		if data.cancelled or not FistsClone.Parent then
			if data.conn then
				data.conn:Disconnect()
				data.conn = nil
			end
			return
		end

		local elapsed = math.clamp(os.clock() - startTime, 0, FISTS_SLOW_TIME)
		local distanceTraveled = FISTS_SLOW_SPEED * elapsed
		local pos = startPosition + direction * distanceTraveled

		FistsClone:PivotTo(getOrientedCFrame(pos, targetPosition))

		if elapsed >= FISTS_SLOW_TIME then
			if data.conn then
				data.conn:Disconnect()
				data.conn = nil
			end
		end
	end)
end

function Handlers.MoveToTarget(params)
	local Character = params.char
	if not Character then
		return
	end

	local key = getKey(Character)
	local data = ACTIVE[key]
	if not data or not data.model or not data.model.Parent then
		return
	end

	if data.conn then
		data.conn:Disconnect()
		data.conn = nil
	end

	local FistsClone = data.model
	local targetPosition = params.targetPosition or data.targetPosition
	if not targetPosition then
		return
	end

	local startPosition = FistsClone:GetPivot().Position
	local totalDistance = (targetPosition - startPosition).Magnitude

	if totalDistance < 0.001 then
		FistsClone:Destroy()
		ACTIVE[key] = nil
		return
	end

	local direction = (targetPosition - startPosition).Unit
	local travelTime = totalDistance / FISTS_FAST_SPEED
	local startTime = os.clock()

	data.conn = RunService.Heartbeat:Connect(function()
		if data.cancelled or not FistsClone.Parent then
			if data.conn then
				data.conn:Disconnect()
				data.conn = nil
			end
			return
		end

		local elapsed = math.clamp(os.clock() - startTime, 0, travelTime)
		local distanceTraveled = FISTS_FAST_SPEED * elapsed
		local pos = startPosition + direction * distanceTraveled

		FistsClone:PivotTo(getOrientedCFrame(pos, targetPosition))

		if elapsed >= travelTime then
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
end

return function(params)
	local handler = Handlers[params.func or "Start"]
	if handler then
		handler(params)
	end
end
