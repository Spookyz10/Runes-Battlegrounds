local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local InfoModule = require(RS.Shared.Info)

local RpRemotes = RS.Remotes
local AwakeningRemotes = RpRemotes.Awakening
local AwakeningSet = AwakeningRemotes.Set

local Player = Players.LocalPlayer
repeat
	task.wait()
until game:IsLoaded() and Player:FindFirstChild("LoadedData") and Player:HasTag("DataLoaded")
local Character = Player.Character or Player.CharacterAdded:Wait()

local AwakeningProgress = Player:WaitForChild("AwakeningProgress", 5)

local AwkProgChanged = AwakeningProgress:GetPropertyChangedSignal("Value")
local IB = UIS.InputBegan

local GUI = Player:WaitForChild("PlayerGui"):WaitForChild("AwakeningBar")
local BarFrame = GUI.UltimateBar
local UltKey = BarFrame.Key
local ProgressLabel = BarFrame.ProgressLabel

shared.triggerAwkbar = function(State: boolean)
	if State == true then
		BarFrame:TweenPosition(UDim2.new(0.5, 0, 1, -90), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.6, true)
	else
		BarFrame:TweenPosition(UDim2.new(0.5, 0, 1, 55), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.6, true)
	end
end

local DeviceUltKey = "[G]"
if UIS.TouchEnabled then
	DeviceUltKey = "[PRESS]"
end

local function getGradientName()
	local moveset = Player:GetAttribute("Moveset")
	local movesetInfo = InfoModule.Movesets[moveset]
	if movesetInfo and movesetInfo.Modes then
		return Player:GetAttribute("MovesetMode_" .. moveset) or movesetInfo.DefaultMode
	end
	return moveset
end

local GRADIENT_TARGETS = {
	BarFrame.Progress.Bar.Bar,
	BarFrame.Progress.RuneFrame,
}

local function updateAwkGradients()
	local name = getGradientName()
	local source = BarFrame.Progress:FindFirstChild("Gradients")
	if not source then
		return
	end

	local template = source:FindFirstChild(name)

	for _, target in GRADIENT_TARGETS do
		for _, child in target:GetChildren() do
			if child:IsA("UIGradient") then
				child:Destroy()
			end
		end
		if template then
			template:Clone().Parent = target
		end
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
		BarFrame.UltName.Text = "WIP"
	end
end

local function ActivateAwk()
	if AwakeningProgress.Value < 100 or Character:HasTag("Stunned") or Character:HasTag("Awakened") then
		return
	end

	AwakeningSet:FireServer("Awakening")
end

local function UpdateAwakeningProgress()
	local FinalXSize = math.clamp(AwakeningProgress.Value / 100, 0, 1)

	BarFrame.Progress.Bar:TweenSize(UDim2.fromScale(FinalXSize, 2.4), nil, nil, 0.4, true)

	if AwakeningProgress.Value >= 100 then
		if UltKey.Visible then
			return
		end
		UltKey.Text = DeviceUltKey
		UltKey.Visible = true
		ProgressLabel.Visible = false
	else
		UltKey.Visible = false
		local RS = game:GetService("ReplicatedStorage")
		local UIS = game:GetService("UserInputService")
		local Players = game:GetService("Players")
		local RunService = game:GetService("RunService")

		local InfoModule = require(RS.Shared.Info)

		local RpRemotes = RS.Remotes
		local AwakeningRemotes = RpRemotes.Awakening
		local AwakeningSet = AwakeningRemotes.Set

		local Player = Players.LocalPlayer
		repeat
			task.wait()
		until game:IsLoaded() and Player:FindFirstChild("LoadedData") and Player:HasTag("DataLoaded")

		local Character = Player.Character or Player.CharacterAdded:Wait()

		Player.CharacterAdded:Connect(function(newChar)
			Character = newChar
		end)

		local AwakeningProgress = Player:WaitForChild("AwakeningProgress", 5)

		local AwkProgChanged = AwakeningProgress:GetPropertyChangedSignal("Value")
		local IB = UIS.InputBegan

		local GUI = Player:WaitForChild("PlayerGui"):WaitForChild("AwakeningBar")
		local BarFrame = GUI.UltimateBar
		local UltKey = BarFrame.Key
		local ProgressLabel = BarFrame.ProgressLabel

		local DeviceUltKey = "[G]"
		if UIS.TouchEnabled then
			DeviceUltKey = "[PRESS]"
		end

		local function getGradientName()
			local moveset = Player:GetAttribute("Moveset")
			local movesetInfo = InfoModule.Movesets[moveset]
			if movesetInfo and movesetInfo.Modes then
				return Player:GetAttribute("MovesetMode_" .. moveset) or movesetInfo.DefaultMode
			end
			return moveset
		end

		local GRADIENT_TARGETS = {
			BarFrame.Progress.Bar.Bar,
			BarFrame.Progress.RuneFrame,
		}

		local function updateAwkGradients()
			local name = getGradientName()
			local source = BarFrame.Progress:FindFirstChild("Gradients")
			if not source then
				return
			end

			local template = source:FindFirstChild(name)

			for _, target in GRADIENT_TARGETS do
				for _, child in target:GetChildren() do
					if child:IsA("UIGradient") then
						child:Destroy()
					end
				end
				if template then
					template:Clone().Parent = target
				end
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
				BarFrame.UltName.Text = "WIP"
			end
		end

		local awakeningDisplayConn = nil

		local function stopAwakeningDisplay()
			if awakeningDisplayConn then
				awakeningDisplayConn:Disconnect()
				awakeningDisplayConn = nil
			end
		end

		local function startAwakeningDisplay()
			stopAwakeningDisplay()
			local moveset = Player:GetAttribute("Moveset")
			local movesetInfo = InfoModule.Movesets[moveset]
			local ultTime = (movesetInfo and movesetInfo.UltimateTime) or 30

			awakeningDisplayConn = RunService.Heartbeat:Connect(function()
				if not Character or not Character.Parent or not Character:HasTag("Awakened") then
					stopAwakeningDisplay()
					return
				end
				local remaining = math.max(0, (AwakeningProgress.Value / 100) * ultTime)
				ProgressLabel.Visible = true
				UltKey.Visible = false
				ProgressLabel.Text = string.format("%d.%02d", math.floor(remaining), math.floor((remaining % 1) * 100))
			end)
		end

		local function ActivateAwk()
			if not Character or not Character.Parent then
				return
			end
			local humanoid = Character:FindFirstChild("Humanoid")
			if not humanoid or humanoid.Health <= 0 then
				return
			end
			if AwakeningProgress.Value < 100 or Character:HasTag("Stunned") or Character:HasTag("Awakened") then
				return
			end

			AwakeningSet:FireServer("Awakening")
		end

		local function UpdateAwakeningProgress()
			local FinalXSize = math.clamp(AwakeningProgress.Value / 100, 0, 1)
			BarFrame.Progress.Bar:TweenSize(UDim2.fromScale(FinalXSize, 2.4), nil, nil, 0.4, true)

			if Character and Character.Parent and Character:HasTag("Awakened") then
				if not awakeningDisplayConn then
					startAwakeningDisplay()
				end
				UltKey.Visible = false
				ProgressLabel.Visible = true
			elseif AwakeningProgress.Value >= 100 then
				stopAwakeningDisplay()
				if UltKey.Visible then
					return
				end
				UltKey.Text = DeviceUltKey
				UltKey.Visible = true
				ProgressLabel.Visible = false
			else
				stopAwakeningDisplay()
				UltKey.Visible = false
				ProgressLabel.Visible = true
				ProgressLabel.Text = string.format("%.1f%%", AwakeningProgress.Value)
			end
		end

		AwkProgChanged:Connect(UpdateAwakeningProgress)

		IB:Connect(function(input, gameProcessedEvent)
			if gameProcessedEvent then
				return
			end

			if input.KeyCode == Enum.KeyCode.G or input.KeyCode == Enum.KeyCode.DPadUp then
				ActivateAwk()
			end
		end)

		BarFrame.ActivateButton.Activated:Connect(ActivateAwk)

		Player:GetAttributeChangedSignal("Moveset"):Connect(function()
			SetUltName()
			updateAwkGradients()
			UpdateAwakeningProgress()
		end)

		Player.AttributeChanged:Connect(function(attr)
			if attr:match("^MovesetMode_") then
				updateAwkGradients()
			end
		end)

		SetUltName()
		updateAwkGradients()
		UpdateAwakeningProgress()
		ProgressLabel.Text = string.format("%.1f%%", AwakeningProgress.Value)
	end
end

AwkProgChanged:Connect(UpdateAwakeningProgress)

IB:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then
		return
	end

	if input.KeyCode == Enum.KeyCode.G or input.KeyCode == Enum.KeyCode.DPadUp then
		ActivateAwk()
	end
end)

BarFrame.ActivateButton.Activated:Connect(ActivateAwk)

Player:GetAttributeChangedSignal("Moveset"):Connect(function()
	SetUltName()
	updateAwkGradients()
	UpdateAwakeningProgress()
end)

Player.AttributeChanged:Connect(function(attr)
	if attr:match("^MovesetMode_") then
		updateAwkGradients()
	end
end)

SetUltName()
updateAwkGradients()
UpdateAwakeningProgress()
