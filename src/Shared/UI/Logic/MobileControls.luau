local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local Player = UIConstants.Player
local PlayerGui = UIConstants.PlayerGui

local MobileControls = {}

local Deps = {}
local SelectedFrame = nil

local TouchGui, TouchControlFrame, JumpButton, MobileGUI
local Buttons = {}

local BUTTON_LAYOUT = {
	Dash = { paramKey = "Dash", xSign = 1, yMultiplier = 1 },
	M1 = { paramKey = "M1", xSign = 1, yMultiplier = 2.5 },
	Block = { paramKey = "Block", xSign = 1, yMultiplier = 4 },
	Shiftlock = { paramKey = "Shiftlock", xSign = -1, yMultiplier = 3.25 },
}

local IMAGES = {
	Dash = { Default = "rbxassetid://12252434969", Pressed = "rbxassetid://12253813495" },
	M1 = { Default = "rbxassetid://12252402662", Pressed = "rbxassetid://12253807149" },
	Block = { Default = "rbxassetid://12252418253", Pressed = "rbxassetid://12253793254" },
	Shiftlock = { Default = "rbxassetid://79605996519245", Pressed = "rbxassetid://79664771265271" },
}

function MobileControls.GetSelectedFrame()
	return SelectedFrame
end

function MobileControls.SetSelectedFrame(frame)
	SelectedFrame = frame
end

local function positionButton(Button, layout, params)
	local buttonParams = params[layout.paramKey]
	local DefaultSize = JumpButton.Size.X.Offset - 10

	Button.Position = UDim2.new(
		JumpButton.Position.X.Scale + buttonParams.ScaleX,
		JumpButton.Position.X.Offset + layout.xSign * (JumpButton.Size.X.Offset / 2) + buttonParams.OffsetX,
		JumpButton.Position.Y.Scale + buttonParams.ScaleY,
		JumpButton.Position.Y.Offset - layout.yMultiplier * (JumpButton.Size.Y.Offset / 2 + 7) + buttonParams.OffsetY
	)

	Button.Size = UDim2.new(0, DefaultSize * buttonParams.SizeMultiplier, 0, DefaultSize * buttonParams.SizeMultiplier)
	Button:SetAttribute("SizeMultiplier", buttonParams.SizeMultiplier)

	Button:GetAttributeChangedSignal("SizeMultiplier"):Connect(function()
		local size = DefaultSize * Button:GetAttribute("SizeMultiplier")
		Button.Size = UDim2.new(0, size, 0, size)
	end)
end

local function setupPressRelease(Button, images, onPress, onRelease)
	local activeConn = nil

	Button.InputBegan:Connect(function(Input)
		if
			Input.UserInputState ~= Enum.UserInputState.Begin
			or not (
				Input.UserInputType == Enum.UserInputType.Touch
				or Input.UserInputType == Enum.UserInputType.MouseButton1
			)
		then
			return
		end

		if Player.Character and Player.Character:FindFirstChild("ChangingButtons") then
			SelectedFrame = Button
			return
		end

		if onPress then
			onPress()
		end

		if activeConn then
			activeConn:Disconnect()
		end

		activeConn = Input:GetPropertyChangedSignal("UserInputState"):Connect(function()
			if Input.UserInputState ~= Enum.UserInputState.End then
				return
			end

			if onRelease then
				onRelease()
			end

			if SelectedFrame == Button then
				SelectedFrame = nil
			end

			activeConn:Disconnect()
			activeConn = nil

			if images then
				Button.Image = images.Default
			end
		end)

		if images then
			Button.Image = images.Pressed
		end
	end)
end

local function doDash()
	if Deps.DashCheck then
		Deps.DashCheck()
	end
end

local function doPunch()
	task.spawn(function()
		RunService.Heartbeat:Wait()
		if Deps.Punch then
			Deps.Punch()
		end
	end)
end

local function doPunchEnd()
	RemoteManager.FireServer("Combat", "PunchEnd")
end

local function doBlockStart()
	local Character = Player.Character
	if not Character or Character:FindFirstChild("Stunned") then
		return
	end

	RemoteManager.FireServer("Combat", "Block", { Stage = true })
end

local function doBlockEnd()
	RemoteManager.FireServer("Combat", "Block", { Stage = false })
end

local function doShiftlockPress()
	if not Deps.ToggleShiftlock then
		return
	end

	local active = Deps.ToggleShiftlock()
	Buttons.Shiftlock.Image = active and IMAGES.Shiftlock.Pressed or IMAGES.Shiftlock.Default
end

local function setupDragToggle()
	RunService.RenderStepped:Connect(function()
		local Character = Player.Character
		if not Character then
			return
		end

		local dragging = Character:FindFirstChild("ChangingButtons") ~= nil

		for _, Button in MobileGUI.MobileFrame:GetChildren() do
			if Button:IsA("ImageButton") then
				Button.Draggable = dragging
				Button.ImageColor3 = dragging and Color3.fromRGB(35, 178, 255) or Color3.fromRGB(255, 255, 255)
			end
		end
	end)
end

local function setupMenuClearing()
	GuiService.MenuOpened:Connect(function()
		local Character = Player.Character
		if Character then
			if Character:GetAttribute("doPunch") then
				doPunchEnd()
			end
			if Character:GetAttribute("doBlock") then
				doBlockEnd()
			end
		end

		SelectedFrame = nil
	end)
end

local function setupTouchGuiVisibility()
	UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(function()
		if UserInputService.TouchEnabled == false and TouchGui then
			TouchGui.Enabled = false
		end
	end)

	UserInputService:GetPropertyChangedSignal("KeyboardEnabled"):Connect(function()
		if UserInputService.KeyboardEnabled == true and TouchGui then
			TouchGui.Enabled = false
		end
	end)
end

function MobileControls.Setup(params)
	if not UserInputService.TouchEnabled or UserInputService.KeyboardEnabled then
		return
	end

	if not Player:GetAttribute("ButtonsPositions") then
		local StartTime = tick()
		repeat
			task.wait()
		until tick() - StartTime > 6 or Player:GetAttribute("ButtonsPositions")
	end

	TouchGui = PlayerGui:FindFirstChild("TouchGui") or PlayerGui:WaitForChild("TouchGui", 10)
	TouchControlFrame = TouchGui:FindFirstChild("TouchControlFrame") or TouchGui:WaitForChild("TouchControlFrame", 5)
	JumpButton = TouchControlFrame:FindFirstChild("JumpButton") or TouchControlFrame:WaitForChild("JumpButton", 5)

	MobileGUI = game.ReplicatedFirst.Mobile:Clone()

	Buttons.M1 = MobileGUI.MobileFrame.PunchButton
	Buttons.Dash = MobileGUI.MobileFrame.DashButton
	Buttons.Block = MobileGUI.MobileFrame.BlockButton
	Buttons.Shiftlock = MobileGUI.MobileFrame.ShiftlockButton

	for name, layout in BUTTON_LAYOUT do
		positionButton(Buttons[name], layout, params)
	end

	setupPressRelease(Buttons.Dash, IMAGES.Dash, doDash, nil)
	setupPressRelease(Buttons.M1, IMAGES.M1, doPunch, doPunchEnd)
	setupPressRelease(Buttons.Block, IMAGES.Block, doBlockStart, doBlockEnd)
	setupPressRelease(Buttons.Shiftlock, nil, doShiftlockPress, nil)

	MobileGUI.Parent = PlayerGui

	setupMenuClearing()
	setupDragToggle()
	setupTouchGuiVisibility()
end

function MobileControls.SetDependencies(deps)
	Deps = deps or {}
end

function MobileControls.Init() end

return MobileControls
