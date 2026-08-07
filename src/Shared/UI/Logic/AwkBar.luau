local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local InfoModule = require(ReplicatedStorage.Shared.Info)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)

local Player = UIConstants.Player
local Character = UIConstants.Character

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local BarFrame = UIConstants.AwakeningBar.UltimateBar
local UltKey = BarFrame.Key
local ProgressLabel = BarFrame.ProgressLabel

local GRADIENT_TARGETS = {
	BarFrame.Progress.Bar.Bar,
	BarFrame.Progress.RuneFrame,
}

local POS_SHOWN = UDim2.new(0.5, 0, 1, -90)
local POS_HIDDEN = UDim2.new(0.5, 0, 1, 55)

local DAMAGE_PER_PERCENT = 3
local DAMAGE_REQUIRED = 100 * DAMAGE_PER_PERCENT

local DeviceUltKey = UserInputService.TouchEnabled and "[PRESS]" or "[G]"

local AwakeningProgress = nil
local awakeningDisplayConn = nil

local Awkbar = {}

function Awkbar.Show()
	BarFrame:TweenPosition(POS_SHOWN, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.6, true)
end

function Awkbar.Hide()
	BarFrame:TweenPosition(POS_HIDDEN, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.6, true)
end

local function getGradientName()
	local moveset = Player:GetAttribute("Moveset")
	local movesetInfo = InfoModule.Movesets[moveset]
	if movesetInfo and movesetInfo.Modes then
		return Player:GetAttribute("MovesetMode_" .. moveset) or movesetInfo.DefaultMode
	end
	return moveset
end

local function updateGradients()
	local name = getGradientName()
	local source = BarFrame.Progress:FindFirstChild("Gradients")
	if not source then
		return
	end

	for _, target in GRADIENT_TARGETS do
		UIFunctions.ApplyGradientTemplate(target, source, name)
	end
end

local function setUltName()
	local movesetInfo = InfoModule.Movesets[Player:GetAttribute("Moveset")]
	if not movesetInfo then
		return
	end

	local ultName = movesetInfo.UltimateName
	BarFrame.UltName.Text = ultName and ultName:upper() or "WIP"
end

local function stopAwakeningDisplay()
	if awakeningDisplayConn then
		awakeningDisplayConn:Disconnect()
		awakeningDisplayConn = nil
	end
end

local function startAwakeningDisplay()
	stopAwakeningDisplay()
	local movesetInfo = InfoModule.Movesets[Player:GetAttribute("Moveset")]
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

local function activate()
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

	RemoteManager.FireServer("Awakening")
end

local function updateProgress()
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
		local damageDone = math.floor(AwakeningProgress.Value * DAMAGE_PER_PERCENT)
		ProgressLabel.Text = string.format("%d/%d (%.0f%%)", damageDone, DAMAGE_REQUIRED, AwakeningProgress.Value)
	end
end

function Awkbar.Init()
	repeat
		task.wait()
	until game:IsLoaded() and Player:FindFirstChild("LoadedData") and Player:HasTag("DataLoaded")

	Character = Player.Character or Player.CharacterAdded:Wait()
	Player.CharacterAdded:Connect(function(newChar)
		Character = newChar
	end)

	AwakeningProgress = Player:WaitForChild("AwakeningProgress", 5)

	AwakeningProgress:GetPropertyChangedSignal("Value"):Connect(updateProgress)

	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end
		if input.KeyCode == Enum.KeyCode.G or input.KeyCode == Enum.KeyCode.DPadUp then
			activate()
		end
	end)

	BarFrame.ActivateButton.Activated:Connect(activate)

	Player:GetAttributeChangedSignal("Moveset"):Connect(function()
		setUltName()
		updateGradients()
		updateProgress()
	end)

	Player.AttributeChanged:Connect(function(attr)
		if attr:match("^MovesetMode_") then
			updateGradients()
		end
	end)

	setUltName()
	updateGradients()
	updateProgress()
end

return Awkbar
