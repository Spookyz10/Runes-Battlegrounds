local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local AssetLoader = require(script.Parent.AssetsLoader)

local Resources = ReplicatedStorage:WaitForChild("Resources")
local Workspace = game:GetService("Workspace")

local PlayerGui = Player:WaitForChild("PlayerGui")
local LoadingScreen = PlayerGui:WaitForChild("LoadingScreen")

LoadingScreen.Enabled = true

local AssetAmountLabel = LoadingScreen:WaitForChild("AssetAmount")
local SkipButton = LoadingScreen:WaitForChild("SkipButton")

local Buttons = LoadingScreen:WaitForChild("Buttons")
local PlayButton = Buttons:WaitForChild("Play")

local Cameras = Workspace:WaitForChild("CamParts")
local LoadingCamera = Cameras:WaitForChild("LoadingCam")

local Camera = Workspace.CurrentCamera
Camera.CameraType = Enum.CameraType.Scriptable
Camera.CFrame = LoadingCamera.CFrame

Buttons.Position = UDim2.new(-0.5, 0, Buttons.Position.Y.Scale, Buttons.Position.Y.Offset)

local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local targetPosition = UDim2.new(0.021, 0, 0.571, 0)

local function showButtons()
	TweenService:Create(Buttons, tweenInfo, { Position = targetPosition }):Play()
end

local loadingDone = false

SkipButton.MouseButton1Click:Connect(function()
	if not loadingDone then
		loadingDone = true
		Buttons.Position = targetPosition
	end
end)

AssetAmountLabel.Text = "Loading: 0/?"

AssetLoader:LoadAssets({ Resources, Workspace }, function(loaded, total)
	AssetAmountLabel.Text = `Loading: {loaded}/{total}`
end)

if not loadingDone then
	loadingDone = true
	AssetAmountLabel.Text = "Loading: Done!"
	SkipButton.Visible = false
	showButtons()
end

PlayButton.MouseButton1Click:Connect(function()
	Camera.CameraType = Enum.CameraType.Custom
	LoadingScreen.Enabled = false
end)
