local RunService = game:GetService("RunService")
assert(not RunService:IsRunning(), "Run in edit mode.")
local StarterGui = game:GetService("StarterGui")
assert(
	not StarterGui:FindFirstChild("Log"),
	"Log already exists. Rename the previous UI before generating a new one."
)

local function create(class, name, parent, properties)
	local object = Instance.new(class)
	object.Name = name

	for key, value in properties or {} do
		object[key] = value
	end

	object.Parent = parent

	return object
end

local function round(object, radius)
	create("UICorner", "Corner", object, { CornerRadius = UDim.new(radius or 0.06, 0) })
end

local white = Color3.fromRGB(241, 240, 250)
local muted = Color3.fromRGB(158, 158, 180)

local function label(parent, name, text, x, y, w, h, color)
	return create("TextLabel", name, parent, {
		Position = UDim2.fromScale(x, y),
		Size = UDim2.fromScale(w, h),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = color or white,
		TextScaled = true,
		Font = Enum.Font.GothamMedium,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
end

local gui = create("ScreenGui", "Log", StarterGui, {
	ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
	Enabled = false,
	ResetOnSpawn = false,
	DisplayOrder = 30,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
local main = create("Frame", "Main", gui, {
	Active = true,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(0.62, 0.62),
	BackgroundColor3 = Color3.fromRGB(19, 20, 30),
	BorderSizePixel = 0,
})
round(main, 0.035)
create(
	"UIGradient",
	"Gradient",
	main,
	{ Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(175, 177, 210)), Rotation = 75 }
)
create("UIStroke", "Stroke", main, { Color = Color3.fromRGB(82, 78, 108), Transparency = 0.4 })
label(main, "Eyebrow", "THE NEXT CHAPTER", 0.04, 0.035, 0.32, 0.025, muted)
label(main, "Title", "What is new", 0.04, 0.075, 0.35, 0.075)
local close = create("TextButton", "Close", main, {
	Position = UDim2.fromScale(0.9, 0.065),
	Size = UDim2.fromScale(0.06, 0.08),
	Text = "Ã—",
	TextScaled = true,
	Font = Enum.Font.GothamMedium,
	TextColor3 = white,
	BackgroundColor3 = Color3.fromRGB(43, 43, 59),
})
round(close)

local function button(name, text, x, y, w, h)
	local object = create("TextButton", name, main, {
		Position = UDim2.fromScale(x, y),
		Size = UDim2.fromScale(w, h),
		BackgroundColor3 = Color3.fromRGB(128, 104, 231),
		Text = text,
		TextScaled = true,
		TextColor3 = white,
		Font = Enum.Font.GothamMedium,
	})
	round(object, 0.14)
	create("UIPadding", "Padding", object, {
		PaddingTop = UDim.new(0.2, 0),
		PaddingBottom = UDim.new(0.2, 0),
		PaddingLeft = UDim.new(0.06, 0),
		PaddingRight = UDim.new(0.06, 0),
	})

	return object
end

button("Update", "Updates", 0.04, 0.2, 0.44, 0.085)
button("Roadmap", "Roadmap", 0.52, 0.2, 0.44, 0.085)
label(main, "Version", "LATEST UPDATE", 0.04, 0.315, 0.7, 0.04, muted)
local content = create("ScrollingFrame", "Content", main, {
	Position = UDim2.fromScale(0.04, 0.39),
	Size = UDim2.fromScale(0.92, 0.51),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	CanvasSize = UDim2.fromScale(0, 0),
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = muted,
})
create(
	"UIListLayout",
	"Layout",
	content,
	{ Padding = UDim.new(0.04, 0), SortOrder = Enum.SortOrder.LayoutOrder }
)
local templates = create("Folder", "Templates", gui)
local row = create("Frame", "Entry", templates, {
	Visible = false,
	Size = UDim2.fromScale(0.98, 0.23),
	BackgroundColor3 = Color3.fromRGB(32, 33, 48),
	BorderSizePixel = 0,
})
round(row, 0.12)
label(row, "Number", "01", 0.035, 0.25, 0.075, 0.5, Color3.fromRGB(170, 151, 255))
local text = label(row, "Body", "Update details", 0.15, 0.15, 0.81, 0.7)
text.TextWrapped = true
label(main, "Footer", "EVOLVING WITH EVERY BATTLE.", 0.04, 0.94, 0.8, 0.025, muted)
print("Log created in StarterGui.")
