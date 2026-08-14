local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).client
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local PlayerGui = UIConstants.PlayerGui

local GUI = PlayerGui:WaitForChild("Store")
local Container = GUI:FindFirstChild("Main"):WaitForChild("Container")

local UI = {}

function UI.Init()
	for _, button in Container:GetDescendants() do
		if button:IsA("ImageButton") then
			local id = button:FindFirstChild("ID").Value
			if Data.OwnedPasses[id] then
				button.Parent.Owned.Visible = true
			else
				button.MouseButton1Click:Connect(function()
					MarketplaceService:PromptGamePassPurchase(UIConstants.Player, id)
				end)
			end
		end
	end
end

local function instance(name, class, parent)
	local instance = Instance.new(class)
	instance.Name = name
	instance.Parent = parent
	return instance
end

local function createGamepass(id: number, parent)
	local gp = instance("Gamepass", "Frame", parent) :: Frame
	gp.Size = UDim2.fromScale(0.2, 0.3)
	gp.BackgroundColor3 = Color3.fromRGB(42, 41, 41)
	gp.BackgroundTransparency = 0.4
	local label = instance("Label", "TextLabel", gp) :: TextLabel
	label.Text = "Early Access"
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	label.Size = UDim2.fromScale(1, 0.5)
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Position = UDim2.fromScale(0.5, 0.5)
	local uistroke = instance("UIStroke", "UIStroke", label) :: UIStroke
	uistroke.Thickness = 1.5
	local button = instance("Buy", "ImageButton", gp) :: ImageButton
	button.Size = UDim2.fromScale(0.6, 0.2)
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.Position = UDim2.fromScale(0.5, 0.86)
	button.Image = ""
	button.BackgroundColor3 = Color3.fromRGB(3, 253, 57)
	local uistroke1 = instance("UIStroke", "UIStroke", button) :: UIStroke
	uistroke1.Thickness = 1.5
	local labelprice = instance("Label", "TextLabel", button) :: TextLabel
	labelprice.Text = "⏣159"
	labelprice.Font = Enum.Font.GothamBlack
	labelprice.TextScaled = true
	labelprice.Size = UDim2.fromScale(1, 0.5)
	labelprice.AnchorPoint = Vector2.new(0.5, 0.5)
	labelprice.Position = UDim2.fromScale(0.5, 0.5)
	local value = instance("ID", "NumberValue", gp)
	value.Value = id
end

local function createUI()
	local StarterGui = game:GetService("StarterGui")
	local screen = instance("Store", "ScreenGui", StarterGui) :: ScreenGui
	screen.ResetOnSpawn = false
	local mainFrame = instance("Main", "Frame", screen) :: Frame
	mainFrame.AnchorPoint = Vector2.nwe(0.5, 0.5)
	mainFrame.BackgroundColor3 = Color3.fromRGB(100, 99, 99)
	mainFrame.BackgroundTransparency = 0.7
	mainFrame.Position = UDim2.fromScale(0.5, 0.5)
	mainFrame.Size = UDim2.fromScale(0.6, 0.7)
	local topFrame = instance("Top", "Frame", mainFrame) :: Frame
	topFrame.AnchorPoint = Vector2.nwe(0.5, 0.5)
	topFrame.Size = UDim2.fromScale(1, 0.2)
	topFrame.Position = UDim2.fromScale(0.5, 0.05)
	topFrame.BackgroundColor3 = Color3.fromRGB(46, 45, 45)
	local label = instance("Label", "TextLabel", topFrame) :: TextLabel
	label.Text = "Store"
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.AnchorPoint = Vector2.new(0.5, 0.5)
	label.Size = UDim2.fromScale(1, 0.8)
	label.Position = UDim2.fromScale(0.5, 0.5)
	label.Font = Enum.Font.GothamBlack
	local uistroke = instance("UIStroke", "UIStroke", label) :: UIStroke
	uistroke.Thickness = 1.5
	local container = instance("Container", "ScrollingFrame", mainFrame) :: ScrollingFrame
	container.Size = UDim2.fromScale(1, 0.8)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.CanvasSize = UDim2.fromScale(0, 0)
	container.AutomaticCanvasSize = Enum.AutomaticSize.Y
	container.Posiiton = UDim2.fromScale(0.5, 0.55)
	container.BackgroundTransparency = 1
	local uilist = instance("UIListLayout", "UIListLayout", container) :: UIListLayout
	uilist.Padding = UDim.new(0.1, 0)
	uilist.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uilist.FillDirection = Enum.FillDirection.Horizontal
end

return UI
