local ServerStorage = game:GetService("ServerStorage")

local DashHandler = require(ServerStorage.Modules.DashHandler)

local Remote = {}

function Remote:Invoke(Player: Player, Direction: string): boolean
	if typeof(Direction) ~= "string" then
		return false
	end

	local Character = Player.Character
	if not Character then
		return false
	end

	local Humanoid = Character:FindFirstChild("Humanoid")
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not Humanoid or not HumRP then
		return false
	end

	return DashHandler:Dash(Player, Direction) == true
end

return Remote
