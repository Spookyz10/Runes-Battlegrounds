--// Services \\--

local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

--// Modules \\--

local InfoModule = require(RS.Shared.Info)

--// Remotes \\--

local RpRemotes = RS.Remotes

local AwakeningRemotes = RpRemotes.Awakening

local AwakeningSet = AwakeningRemotes.Set

--// Player \\--

local Player: Player = Players.LocalPlayer
repeat
	task.wait()
until game:IsLoaded() and Player:FindFirstChild("LoadedData") and Player:HasTag("DataLoaded")
local Character = Player.Character or Player.CharacterAdded:Wait()

local AwakeningProgress = Player:WaitForChild("AwakeningProgress", 5)

--// Events \\--

local AwkProgChanged = AwakeningProgress:GetPropertyChangedSignal("Value")
local IB = UIS.InputBegan

--// GUI \\--

local GUI = Player:WaitForChild("PlayerGui"):WaitForChild("AwakeningBar")
local BarFrame = GUI.UltimateBar
local UltKey = BarFrame.UltKey
local Progress = BarFrame.Progress.Bar
local RuneFrame = BarFrame.RuneFrame

local DeviceUltKey = "[G]"
if UIS.TouchEnabled then
	DeviceUltKey = "[PRESS]"
end

--// Functions \\--

local InfoModule = require(RS.Shared.Info) -- já existe no awk script, adiciona no hotbar

-- Retorna o nome do gradiente a usar: modo atual ou nome do moveset
local function getGradientName()
	local moveset = Player:GetAttribute("Moveset")
	local movesetInfo = InfoModule.Movesets[moveset]

	if movesetInfo and movesetInfo.Modes then
		return Player:GetAttribute("MovesetMode_" .. moveset) or movesetInfo.DefaultMode
	end

	return moveset
end

-- Clona o gradiente correto de container.Gradients, remove o anterior
local function applyGradient(container, gradientName)
	local source = container:FindFirstChild("Gradients")
	if not source then
		return
	end

	-- remove gradiente anterior
	for _, child in container:GetChildren() do
		if child:IsA("UIGradient") then
			child:Destroy()
		end
	end

	local template = source:FindFirstChild(gradientName)
	if template then
		template:Clone().Parent = container
	end
end

function SetUltName()
	local MovesetName = Player:GetAttribute("Moveset")
	local MovesetInfo = InfoModule.Movesets[MovesetName]
	if not MovesetInfo then
		return
	end

	local ultName: string = MovesetInfo.UltimateName

	if ultName then
		ultName = ultName:upper()

		BarFrame.UltName.Text = ultName
	else
		BarFrame.UltName.Text = "No ult yet!"
	end
end

local function updateAwkGradients()
	local name = getGradientName()
	applyGradient(RuneFrame, name)
	applyGradient(BarFrame.Progress.Bar, name)
end

Player:GetAttributeChangedSignal("Moveset"):Connect(function()
	SetUltName()
	updateAwkGradients()
end)

Player.AttributeChanged:Connect(function(attr)
	if attr:match("^MovesetMode_") then
		updateAwkGradients()
	end
end)

SetUltName()
updateAwkGradients()

Player:GetPropertyChangedSignal("Character"):Connect(function()
	Character = Player.Character or Player.CharacterAdded:Wait()

	SetUltName()
end)

local function ActivateAwk()
	if AwakeningProgress.Value < 100 or Character:HasTag("Stunned") or Character:HasTag("Awakened") then
		return
	end
	if game.PlaceId == workspace:GetAttribute("DuelsHubPlaceId") then
		return
	end

	AwakeningSet:FireServer("Awakening")
end

--// Connections \\--

AwkProgChanged:Connect(function()
	local FinalXSize = AwakeningProgress.Value / 100

	if FinalXSize > 1 then
		FinalXSize = 1
	end

	BarFrame.Progress.Bar:TweenSize(UDim2.fromScale(FinalXSize, 1), nil, nil, 0.4, true)

	if AwakeningProgress.Value >= 100 then
		if UltKey.Visible then
			return
		end
		UltKey.Text = DeviceUltKey
		UltKey.Text = DeviceUltKey
		UltKey.Visible = true

		local Indicator = InfoModule.Movesets[Player:GetAttribute("Moveset")].Indicator
		shared
			.sfx({
				SoundId = Indicator.Sound,
				Parent = Character.Torso,
				Volume = Indicator.Volume,
				RollOffMaxDistance = 100,
			})
			:Play()
	else
		UltKey.Visible = false
	end
end)

IB:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then
		return
	end

	if input.KeyCode == Enum.KeyCode.G or input.KeyCode == Enum.KeyCode.DPadUp then
		ActivateAwk()
	end
end)

BarFrame.ActivateButton.Activated:Connect(ActivateAwk)

Player:GetAttributeChangedSignal("Moveset"):Connect(SetUltName)

SetUltName()

shared.triggerAwkbar = function(State)
	if State == true then
		BarFrame:TweenPosition(
			UDim2.new(0.5, 0, 1, -(UIS.TouchEnabled and 150 or 90)),
			Enum.EasingDirection.InOut,
			Enum.EasingStyle.Quad,
			1,
			true
		)
	else
		BarFrame:TweenPosition(UDim2.new(0.5, 0, 1, 100), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 1, true)
	end
end
