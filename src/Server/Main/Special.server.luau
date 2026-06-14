local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local SpecialsHandler = require(ServerStorage.Modules.SpecialsHandler)
local MovesetHandler = require(ServerStorage.Modules.MovesetHandler)

local SpecialsSet = ReplicatedStorage.Remotes.Specials.Set

SpecialsSet.OnServerEvent:Connect(function(Player, action, params)
	if not Player:FindFirstChild("LoadedData") then
		return
	end

	local Character = Player.Character
	if not Character or not Character.Parent then
		return
	end

	if action == "ActivateBase" then
		SpecialsHandler:Activate(Player, false, MovesetHandler)
	elseif action == "ActivateUlt" then
		SpecialsHandler:Activate(Player, true, MovesetHandler)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	SpecialsHandler:ClearPlayer(player.UserId)
end)
