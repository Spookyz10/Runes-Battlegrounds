local ServerStorage = game:GetService("ServerStorage")

local DashHandler = require(ServerStorage.Modules.DashHandler)

local Remote = {}

function Remote:Activate(Player: Player, Parameters)
	local Character = Player.Character
	if not Character then
		return
	end

	local Humanoid = Character:FindFirstChild("Humanoid")
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not HumRP then
		return
	end

	if Parameters.Key == Enum.KeyCode.Q then
		DashHandler:Dash(Player, Parameters.Direction)
	end
end

return Remote
