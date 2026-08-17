local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local HitboxQuery = require(script.Parent.HitboxQuery)
local DrawHitbox = require(script.Parent.Hitbox)

local getCframe = {
	["Instance"] = function(point)
		return point.CFrame
	end,

	["CFrame"] = function(point)
		return point
	end,

	["Vector3"] = function(point)
		return CFrame.new(point)
	end,
}

local function drawDebug(HitboxParameters)
	local cframeFunc = getCframe[typeof(HitboxParameters.Instance)]
	if not cframeFunc then
		return
	end

	local BaseCFrame = cframeFunc(HitboxParameters.Instance)
	if not BaseCFrame then
		return
	end

	DrawHitbox({
		CFrame = BaseCFrame,
		Offset = HitboxParameters.Offset,
		Method = HitboxParameters.Method or "Box",
		Size = HitboxParameters.Size,
	})
end

return function(Params)
	local Bridge = LocalPlayer:WaitForChild(Params.BridgeId, 5)
	if not Bridge then
		return
	end

	local HitboxParameters = {
		Instance = Params.Instance,
		Size = Params.Size,
		Offset = Params.Offset,
		Ignore = Params.Ignore,
	}

	if Params.Mode == "Once" then
		--drawDebug(HitboxParameters)
		Bridge:FireServer(HitboxQuery(HitboxParameters))
		return
	elseif Params.Mode == "Constant" then
		local HitboxConnection
		HitboxConnection = RunService.Heartbeat:Connect(function()
			--drawDebug(HitboxParameters)

			local TouchedEnemies = HitboxQuery(HitboxParameters)
			if TouchedEnemies ~= nil and #TouchedEnemies > 0 then
				Bridge:FireServer(TouchedEnemies)
			end
		end)

		local StopConnection, DestroyConnection
		StopConnection = Bridge.ChildAdded:Connect(function(Child)
			if Child.Name == "StopConstant" then
				HitboxConnection:Disconnect()
				StopConnection:Disconnect()
				DestroyConnection:Disconnect()
			end
		end)
		DestroyConnection = Bridge.Destroying:Once(function()
			HitboxConnection:Disconnect()
			StopConnection:Disconnect()
			DestroyConnection:Disconnect()
		end)
	end
end
