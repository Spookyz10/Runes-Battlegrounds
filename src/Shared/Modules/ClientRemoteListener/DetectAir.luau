local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Remote = {}

function Remote:Activate(Params)
	local Char = Params.Char
	if not Char then
		return
	end

	local Bridge = LocalPlayer:WaitForChild(Params.Bridge, 5)
	if not Bridge then
		return
	end

	task.spawn(function()
		local Detected = shared.detectAir(Params)
		if Detected and Bridge and Bridge.Parent then
			Bridge:FireServer()
		end
	end)
end

return Remote
