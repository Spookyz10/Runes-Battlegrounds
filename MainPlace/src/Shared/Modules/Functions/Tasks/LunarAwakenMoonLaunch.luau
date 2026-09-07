local Constants = require(script.Parent.Shared.Constants)
local State = require(script.Parent.Shared.State)
local ClientState = require(game:GetService("ReplicatedStorage").Shared.Modules.ClientContext)
local RunService = Constants.RunService

return function(Params)
	local Character = Params.char
	local ownerId = Params.ownerId
	local data = State.lunarData[Character]

	if not data or not data.moon or not data.moon.Parent then
		return
	end

	if data.moonConn then
		data.moonConn:Disconnect()
		data.moonConn = nil
	end

	if ownerId and ClientState.Indicators[ownerId] then
		local IndicatorEnd = require(script.Parent.IndicatorEnd)
		IndicatorEnd({ ownerId = ownerId })
	end

	local Moon = data.moon

	data.moon = nil
	local oldMoon = State.launchedMoons[Character]
	if oldMoon then
		oldMoon:Destroy()
	end
	State.launchedMoons[Character] = Moon
	game:GetService("Debris"):AddItem(Moon, 11)
	Moon.Destroying:Once(function()
		if State.launchedMoons[Character] == Moon then
			State.launchedMoons[Character] = nil
			State:endNight("Lunar", Character)
		end
	end)

	local direction = Params.direction
	local speed = 80
	local launchConn

	launchConn = RunService.Heartbeat:Connect(function(dt)
		if not Character.Parent then
			Moon:Destroy()
		end
		if not Moon or not Moon.Parent then
			if State.launchedMoons[Character] == Moon then
				State.launchedMoons[Character] = nil
			end
			launchConn:Disconnect()
			return
		end
		Moon.CFrame = Moon.CFrame + direction * speed * dt
	end)

	Moon.AncestryChanged:Once(function(_, parent)
		if not parent then
			launchConn:Disconnect()
		end
	end)
end
