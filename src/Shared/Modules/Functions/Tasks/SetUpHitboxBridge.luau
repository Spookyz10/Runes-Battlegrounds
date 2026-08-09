local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local HitboxQuery = require(script.Parent.HitboxQuery)
local HitboxVisual = require(script.Parent.Hitbox)

local function drawDebug(HitboxParameters)
	HitboxVisual({
		Method = "Box",
		Size = HitboxParameters.Size,
		CFrame = HitboxParameters.Instance.CFrame * (HitboxParameters.Offset or CFrame.new(0, 0, 0)),
	})
end

return function(Params)
	local Bridge = LocalPlayer:WaitForChild(Params.BridgeId)

	Bridge.OnClientEvent:Connect(function(InvokeType, HitboxParameters)
		if InvokeType == "Once" then
			drawDebug(HitboxParameters)
			Bridge:FireServer(HitboxQuery(HitboxParameters))
		elseif InvokeType == "Constant" then
			local HitboxConnection
			HitboxConnection = RunService.Heartbeat:Connect(function()
				drawDebug(HitboxParameters)

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
	end)
end
