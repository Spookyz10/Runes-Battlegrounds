local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = {}

UIConstants.Player = Players.LocalPlayer
UIConstants.PlayerGui = UIConstants.Player:WaitForChild("PlayerGui")

UIConstants.Hotbar = UIConstants.PlayerGui:WaitForChild("Hotbar")
UIConstants.AwakeningBar = UIConstants.PlayerGui:WaitForChild("AwakeningBar")
UIConstants.ExtraCds = UIConstants.PlayerGui:WaitForChild("ExtraCds")

UIConstants.Gradients = ReplicatedStorage.Resources.UI.Gradients

UIConstants.Character = UIConstants.Player.Character or UIConstants.Player.CharacterAdded:Wait()

UIConstants.Player.CharacterAdded:Connect(function(newCharacter)
	UIConstants.Character = newCharacter
end)

return UIConstants
