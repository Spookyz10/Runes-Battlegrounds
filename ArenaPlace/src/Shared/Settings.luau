local function createIns(className: string, name: string, parent: Instance, autoPos: boolean)
	local instance = Instance.new(className)
	instance.Name = name
	instance.Parent = parent
	if autoPos then
		instance.AnchorPoint = Vector2.nwe(0.5, 0.5)
		instance.Position = UDim2.fromScale(0.5, 0.5)
	end
	return instance
end

local function createSettingFrame(setting: string, desc: string, scroll: ScrollingFrame)
	local frame = createIns("Frame", setting, scroll) :: Frame
	frame.BackgroundColor3 = Color3.fromRGB(10, 20, 80)
	local label = createIns("TextLabel", "SettingName", frame, true) :: TextLabel
	label.Text = setting
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	createIns("UIStroke", "UIStroke", label).Thickness = 1.2
	label.Position = UDim2.fromScale(0.02, 0.02)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.TextScaled = true
	local descLabel = createIns("TextLabel", "Desc", frame, true) :: TextLabel
	descLabel.Text = desc
	descLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	createIns("UIStroke", "UIStroke", descLabel).Thickness = 1.2
	descLabel.Position = UDim2.fromScale(0.02, 0.3)
	descLabel.BackgroundTransparency = 1
	descLabel.Font = Enum.Font.GothamBlack
	descLabel.TextScaled = true
end

local function createUI()
	local screen = createIns("ScreenGui", "Settings", game.StarterGui) :: ScreenGui
	screen.ResetOnSpawn = false
	local main = createIns("Frame", "Main", screen, true) :: Frame
	main.BackgroundColor3 = Color3.fromRGB(48, 47, 47)
	main.BackgroundTransparency = 0.4
	main.Size = UDim2.fromScale(0.6, 0.6)
	local topFrame = createIns("Frame", "Main", screen, true) :: Frame
	topFrame.BackgroundColor3 = Color3.fromRGB(48, 47, 47)
	topFrame.Size = UDim2.fromScale(1, 1)
	topFrame.Position = UDim2.fromScale(0.5, 0.05)
	local label = createIns("TextLabel", "Label", topFrame) :: TextLabel
	label.Text = "Settings"
	label.Font = Enum.Font.GothamBold
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	createIns("UIStroke", "UIStroke", label).Thickness = 1.2
	local scroll = createIns("ScrollingFrame", "Container", main, true) :: ScrollingFrame
	scroll.CanvasSize = UDim2.fromScale(0, 4)
	scroll.BackgroundColor3 = 1
	scroll.ScrollBarThickness = 0
	scroll.Position = UDim2.fromScale(0.5, 0.4)
	local uiliist = createIns("UIListLayout", "UIListLayout", scroll) :: UIListLayout
	uiliist.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiliist.Padding = UDim(0.02, 0)
	local padding = createIns("UIPadding", "UIPadding", scroll) :: UIPadding
	padding.PaddingTop = UDim(0.05, 0)
	createSettingFrame("Awakening Music", "Disable/Enable awakeningi musics emitted from players", scroll)
	createSettingFrame("Camera Shake", "Disable/Enable camera shake when players use awakening", scroll)
end

createUI()

return {}
