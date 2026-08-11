local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientContext = require(ReplicatedStorage.Shared.Modules.ClientContext)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local DashResolver = require(ReplicatedStorage.Shared.Modules.Functions.DashDirectionResolver)
local ShiftlockController = require(ReplicatedStorage.Shared.Modules.Functions.ShiftlockController)

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local MobileHUD = {}

local Buttons = {}
local HUD

local Character
local Humanoid
local HumRP
local Animator

local HoldState = {
	Attack = false,
	Block = false,
}

local ShiftlockImages = {
	OFF = "rbxasset://textures/ui/mouseLock_off@2x.png",
	ON = "rbxasset://textures/ui/mouseLock_on@2x.png",
}

local function refreshCharacterRefs()
	Character = Player.Character
	if not Character then
		return
	end

	Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid", 10)
	HumRP = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart", 10)
	Animator = Humanoid and (Humanoid:FindFirstChild("Animator") or Humanoid:WaitForChild("Animator", 10))
end

local function checkCharacterAvailability()
	return Character ~= nil
		and Character.Parent ~= nil
		and HumRP ~= nil
		and HumRP.Parent ~= nil
		and Humanoid ~= nil
		and Humanoid.Parent ~= nil
		and Humanoid.Health > 0
		and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead
end

local function doAttackStart()
	if HoldState.Attack then
		return
	end
	HoldState.Attack = true
	RemoteManager.FireServer("Combat", "PunchStart")
end

local function doAttackEnd()
	if not HoldState.Attack then
		return
	end
	HoldState.Attack = false
	RemoteManager.FireServer("Combat", "PunchEnd")
end

local function doBlockStart()
	if HoldState.Block then
		return
	end
	if Character and Character:FindFirstChild("Stunned") then
		return
	end
	HoldState.Block = true
	RemoteManager.FireServer("Combat", "Block", { Stage = true })
end

local function doBlockEnd()
	if not HoldState.Block then
		return
	end
	HoldState.Block = false
	RemoteManager.FireServer("Combat", "Block", { Stage = false })
end

local function doDash()
	if not checkCharacterAvailability() then
		return
	end

	local Camera = workspace.CurrentCamera
	DashResolver.PerformDash(Character, Humanoid, HumRP, Camera, Animator)
end

local function doShiftlockToggle()
	local active = ShiftlockController.Toggle()

	local button = Buttons.Shiftlock
	if button and button:IsA("ImageButton") then
		button.Image = active and ShiftlockImages.ON or ShiftlockImages.OFF
	end
end

local function setupHoldButton(Button, onPress, onRelease)
	if not Button then
		return
	end

	local activeInputConn = nil

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

		onPress()

		if activeInputConn then
			activeInputConn:Disconnect()
		end

		activeInputConn = Input:GetPropertyChangedSignal("UserInputState"):Connect(function()
			if
				Input.UserInputState ~= Enum.UserInputState.End
				and Input.UserInputState ~= Enum.UserInputState.Cancel
			then
				return
			end

			onRelease()

			if activeInputConn then
				activeInputConn:Disconnect()
				activeInputConn = nil
			end
		end)
	end)

	Button.AncestryChanged:Connect(function(_, parent)
		if not parent then
			onRelease()
		end
	end)
end

local function setupTapButton(Button, onTap)
	if not Button then
		return
	end

	Button.Activated:Connect(function()
		onTap()
	end)
end

function MobileHUD.Init()
	HUD = PlayerGui:WaitForChild("MobileHUD")

	if ClientContext.IsMobile then
		HUD.Enabled = true
	else
		HUD.Enabled = false
	end

	Buttons.Attack = HUD:WaitForChild("Attack")
	Buttons.Dash = HUD:WaitForChild("Dash")
	Buttons.Block = HUD:WaitForChild("Block")
	Buttons.Shiftlock = HUD:WaitForChild("Shiftlock")

	setupHoldButton(Buttons.Attack, doAttackStart, doAttackEnd)
	setupHoldButton(Buttons.Block, doBlockStart, doBlockEnd)

	setupTapButton(Buttons.Dash, doDash)
	setupTapButton(Buttons.Shiftlock, doShiftlockToggle)

	if Buttons.Shiftlock and Buttons.Shiftlock:IsA("ImageButton") then
		Buttons.Shiftlock.Image = ShiftlockController.IsActive() and ShiftlockImages.ON or ShiftlockImages.OFF
	end

	refreshCharacterRefs()

	Player.CharacterAdded:Connect(function()
		if HoldState.Attack then
			doAttackEnd()
		end
		if HoldState.Block then
			doBlockEnd()
		end

		DashResolver.Cleanup(Character)
		refreshCharacterRefs()
	end)
end

return MobileHUD
