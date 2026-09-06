local RunService = game:GetService("RunService")
assert(not RunService:IsRunning(), "Run in edit mode.")
local StarterGui = game:GetService("StarterGui")
assert(
	not StarterGui:FindFirstChild("Shop"),
	"Shop already exists. Rename the previous UI before generating a new one."
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

local gui = create("ScreenGui", "Shop", StarterGui, {
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
label(main, "Eyebrow", "RUNE COLLECTION", 0.04, 0.035, 0.32, 0.025, muted)
label(main, "Title", "Shop", 0.04, 0.075, 0.35, 0.075)
label(main, "Gold", "0 GOLD", 0.64, 0.08, 0.23, 0.055, Color3.fromRGB(246, 206, 112))
local close = create("TextButton", "Close", main, {
	Position = UDim2.fromScale(0.9, 0.065),
	Size = UDim2.fromScale(0.06, 0.08),
	Text = "Ãƒâ€”",
	TextScaled = true,
	Font = Enum.Font.GothamMedium,
	TextColor3 = white,
	BackgroundColor3 = Color3.fromRGB(43, 43, 59),
})
round(close)
local tabs = create(
	"Frame",
	"Tabs",
	main,
	{
		Position = UDim2.fromScale(0.04, 0.19),
		Size = UDim2.fromScale(0.92, 0.085),
		BackgroundTransparency = 1,
	}
)

for index, entry in
	{
		{ "Auras", "Auras" },
		{ "RuneCosmetics", "Rune cosmetics" },
		{ "RuneSkins", "Rune skins" },
		{ "Robux", "Robux" },
	}

do
	local button = create("TextButton", entry[1], tabs, {
		Position = UDim2.fromScale((index - 1) * 0.255, 0),
		Size = UDim2.fromScale(0.235, 1),
		BackgroundColor3 = Color3.fromRGB(40, 40, 57),
		Text = entry[2],
		TextScaled = true,
		TextColor3 = white,
		Font = Enum.Font.GothamMedium,
	})
	create("UIPadding", "Padding", button, {
		PaddingTop = UDim.new(0.22, 0),
		PaddingBottom = UDim.new(0.22, 0),
		PaddingLeft = UDim.new(0.05, 0),
		PaddingRight = UDim.new(0.05, 0),
	})
	round(button, 0.16)
end

local content = create("ScrollingFrame", "Content", main, {
	Position = UDim2.fromScale(0.04, 0.31),
	Size = UDim2.fromScale(0.92, 0.58),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.fromScale(0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = muted,
})
create("UIGridLayout", "Grid", content, {
	CellSize = UDim2.fromScale(0.31, 0.94),
	CellPadding = UDim2.fromScale(0.025, 0.04),
	SortOrder = Enum.SortOrder.LayoutOrder,
})
local empty = label(main, "Empty", "New auras coming soon.", 0.15, 0.47, 0.7, 0.18, muted)
empty.TextXAlignment = Enum.TextXAlignment.Center
empty.TextWrapped = true
label(main, "Footer", "YOUR RUNE. YOUR STYLE.", 0.04, 0.935, 0.6, 0.025, muted)
local templates = create("Folder", "Templates", gui)
local card = create("Frame", "Item", templates, {
	Visible = false,
	Size = UDim2.fromScale(0.31, 0.94),
	BackgroundColor3 = Color3.fromRGB(32, 33, 48),
	BorderSizePixel = 0,
})
round(card)
create("UIStroke", "Stroke", card, { Color = Color3.fromRGB(67, 64, 89), Transparency = 0.35 })
create("ViewportFrame", "Preview", card, {
	Position = UDim2.fromScale(0.06, 0.04),
	Size = UDim2.fromScale(0.88, 0.44),
	BackgroundTransparency = 1,
	Ambient = Color3.fromRGB(190, 190, 210),
	LightColor = Color3.fromRGB(255, 239, 206),
	LightDirection = Vector3.new(-1, -1, -1),
})
create("ImageLabel", "Image", card, {
	Position = UDim2.fromScale(0.1, 0.06),
	Size = UDim2.fromScale(0.8, 0.4),
	BackgroundTransparency = 1,
	ScaleType = Enum.ScaleType.Fit,
	Visible = false,
})
local placeholder = label(card, "Placeholder", "Preview unavailable", 0.08, 0.15, 0.84, 0.18, muted)
placeholder.TextXAlignment = Enum.TextXAlignment.Center
placeholder.Visible = false
label(card, "ItemName", "Crown", 0.08, 0.51, 0.84, 0.075)
local description = label(card, "Description", "A crown worthy of your rune.", 0.08, 0.6, 0.84, 0.095, muted)
description.TextWrapped = true
label(card, "Price", "100,000 GOLD", 0.08, 0.72, 0.84, 0.065, Color3.fromRGB(246, 206, 112))
local buy = create("TextButton", "Buy", card, {
	Position = UDim2.fromScale(0.08, 0.82),
	Size = UDim2.fromScale(0.84, 0.12),
	BackgroundColor3 = Color3.fromRGB(128, 104, 231),
	Text = "Buy",
	TextScaled = true,
	TextColor3 = white,
	Font = Enum.Font.GothamBold,
})
round(buy, 0.18)
create("UIPadding", "Padding", buy, { PaddingTop = UDim.new(0.2, 0), PaddingBottom = UDim.new(0.2, 0) })
print("Shop created in StarterGui.")
local robux = content:Clone()
robux.Name = "RobuxContent"
robux.Visible = false
robux.Parent = main
