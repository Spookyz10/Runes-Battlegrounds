local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local HitboxQuery = require(script.Parent.HitboxQuery)

return function(Params)
	local Bridge = LocalPlayer:WaitForChild(Params.BridgeId)

	local HitboxParameters = {
		Instance = Params.Instance,
		Size = Params.Size,
		Offset = Params.Offset,
		Ignore = Params.Ignore,
	}

	if Params.Mode == "Once" then
		Bridge:FireServer(HitboxQuery(HitboxParameters))
		return
	elseif Params.Mode == "Constant" then
		local HitboxConnection
		HitboxConnection = RunService.Heartbeat:Connect(function()
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
