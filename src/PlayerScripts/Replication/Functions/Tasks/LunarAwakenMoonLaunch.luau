local Constants = require(script.Parent.Shared.Constants)
local State = require(script.Parent.Shared.State)
local RunService = Constants.RunService
local TS = Constants.TS

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

	-- Destrói o indicador pelo ownerId (suporta múltiplos simultâneos)
	if shared._lunarIndicators and ownerId and shared._lunarIndicators[ownerId] then
		local ind = shared._lunarIndicators[ownerId]
		if ind.conn then
			ind.conn:Disconnect()
		end
		if ind.part and ind.part.Parent then
			TS:Create(ind.part, TweenInfo.new(0.15, Enum.EasingStyle.Linear), { Transparency = 1 }):Play()
			game.Debris:AddItem(ind.part, 0.2)
		end
		shared._lunarIndicators[ownerId] = nil
	end

	local Moon = data.moon
	local direction = Params.direction
	local speed = 80

	local launchConn
	launchConn = RunService.Heartbeat:Connect(function(dt)
		if not Moon or not Moon.Parent then
			launchConn:Disconnect()
			if data then
				data.moonLaunchConn = nil
			end
			return
		end
		Moon.CFrame = Moon.CFrame + direction * speed * dt
	end)
	data.moonLaunchConn = launchConn
end
