local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

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

local function doSpecial()
	if not checkCharacterAvailability() then
		return
	end

	RemoteManager.FireServer("Specials")
end

local function doShiftlockToggle()
	local active = ShiftlockController.Toggle()

	local button = Buttons.Shiftlock
	if button and button:IsA("ImageButton") then
		button.Image = active and ShiftlockImages.ON or ShiftlockImages.OFF
	end
end

local function isInsideButton(Button: GuiObject, ScreenPosition: Vector2): boolean
	local Position = Button.AbsolutePosition
	local Size = Button.AbsoluteSize

	return ScreenPosition.X >= Position.X
		and ScreenPosition.X <= Position.X + Size.X
		and ScreenPosition.Y >= Position.Y
		and ScreenPosition.Y <= Position.Y + Size.Y
end

local function isPressInput(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1
end

local function setupPassthroughHold(Button, onPress, onRelease)
	if not Button then
		return
	end

	Button.Active = false

	local TrackedInput: InputObject? = nil

	UserInputService.InputBegan:Connect(function(input)
		if TrackedInput or not isPressInput(input) then
			return
		end
		if not Button.Visible or not isInsideButton(Button, Vector2.new(input.Position.X, input.Position.Y)) then
			return
		end

		TrackedInput = input
		onPress()
	end)

	UserInputService.InputEnded:Connect(function(input)
		if TrackedInput ~= input then
			return
		end
		TrackedInput = nil
		onRelease()
	end)

	Button.AncestryChanged:Connect(function(_, parent)
		if not parent and TrackedInput then
			TrackedInput = nil
			onRelease()
		end
	end)
end

local function setupPassthroughTap(Button, onTap)
	if not Button then
		return
	end

	Button.Active = false

	local TrackedInput: InputObject? = nil

	UserInputService.InputBegan:Connect(function(input)
		if TrackedInput or not isPressInput(input) then
			return
		end
		if not Button.Visible or not isInsideButton(Button, Vector2.new(input.Position.X, input.Position.Y)) then
			return
		end

		TrackedInput = input
		onTap()
	end)

	UserInputService.InputEnded:Connect(function(input)
		if TrackedInput ~= input then
			return
		end
		TrackedInput = nil
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
	Buttons.Special = HUD:WaitForChild("Special")

	setupPassthroughHold(Buttons.Attack, doAttackStart, doAttackEnd)
	setupPassthroughHold(Buttons.Block, doBlockStart, doBlockEnd)

	setupPassthroughTap(Buttons.Dash, doDash)
	setupPassthroughTap(Buttons.Shiftlock, doShiftlockToggle)
	setupPassthroughTap(Buttons.Special, doSpecial)

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
