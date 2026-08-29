local Constants = require(script.Parent.Shared.Constants)
local RunService = Constants.RunService
local CharacterAssets = Constants.CharacterAssets

local FISTS_SPAWN_OFFSET = Vector3.new(0, 0, 300)

local ACTIVE = {}

local function getKey(char)
	return tostring(char)
end

local Handlers = {}

function Handlers.Start(params)
	local Character = params.char
	local targetPosition = params.targetPosition
	local waitTime = params.waitTime or 2
	local travelTime = params.travelTime or 1.6

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

	local FistsClone = FistsAsset:Clone()
	local startCFrame = HumRP.CFrame * CFrame.new(FISTS_SPAWN_OFFSET)
	FistsClone:PivotTo(startCFrame)
	FistsClone.Parent = workspace

	local data = { model = FistsClone, conn = nil, cancelled = false }
	ACTIVE[key] = data

	task.delay(waitTime, function()
		if data.cancelled or not FistsClone.Parent then
			return
		end

		local travelStart = FistsClone:GetPivot()
		local startTime = os.clock()

		data.conn = RunService.Heartbeat:Connect(function()
			if data.cancelled or not FistsClone.Parent then
				if data.conn then
					data.conn:Disconnect()
					data.conn = nil
				end
				return
			end

			local t = math.clamp((os.clock() - startTime) / travelTime, 0, 1)
			local eased = 1 - (1 - t) ^ 3
			local pos = travelStart.Position:Lerp(targetPosition, eased)

			local lookAt = (HumRP and HumRP.Parent) and HumRP.Position or (pos + Vector3.new(0, 0, -1))
			FistsClone:PivotTo(CFrame.new(pos, lookAt))

			if t >= 1 then
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
		data.model:Destroy()
	end
end

return function(params)
	local handler = Handlers[params.func or "Start"]
	if handler then
		handler(params)
	end
end
