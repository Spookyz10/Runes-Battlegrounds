local RunService = game:GetService("RunService")
assert(not RunService:IsRunning(), "Run in edit mode.")
local StarterGui = game:GetService("StarterGui")
assert(
	not StarterGui:FindFirstChild("KillSound"),
	"KillSound already exists. Rename the previous UI before generating a new one."
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

local gui = create("ScreenGui", "KillSound", StarterGui, {
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
	Size = UDim2.fromScale(0.46, 0.48),
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
label(main, "Eyebrow", "MAKE YOUR MARK", 0.04, 0.035, 0.32, 0.025, muted)
label(main, "Title", "Kill sound", 0.04, 0.075, 0.35, 0.075)
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

local hint = label(
	main,
	"Hint",
	"Your finishing touch. Play an audio after each elimination.",
	0.04,
	0.22,
	0.92,
	0.1,
	muted
)
hint.TextWrapped = true
label(main, "InputLabel", "AUDIO ASSET ID", 0.04, 0.38, 0.6, 0.035, muted)
local box = create("TextBox", "SoundBox", main, {
	Position = UDim2.fromScale(0.04, 0.44),
	Size = UDim2.fromScale(0.92, 0.14),
	BackgroundColor3 = Color3.fromRGB(32, 33, 48),
	Text = "",
	PlaceholderText = "Paste an audio ID or asset URL",
	PlaceholderColor3 = muted,
	TextColor3 = white,
	TextScaled = true,
	Font = Enum.Font.GothamMedium,
	ClearTextOnFocus = false,
})
round(box, 0.12)
create("UIPadding", "Padding", box, {
	PaddingLeft = UDim.new(0.04, 0),
	PaddingRight = UDim.new(0.04, 0),
	PaddingTop = UDim.new(0.22, 0),
	PaddingBottom = UDim.new(0.22, 0),
})
button("Preview", "Preview", 0.04, 0.63, 0.44, 0.12)
button("Submit", "Save sound", 0.52, 0.63, 0.44, 0.12)
local feedback = label(
	main,
	"Feedback",
	"Only audio available to this experience can play.",
	0.04,
	0.81,
	0.92,
	0.09,
	muted
)
feedback.TextWrapped = true
create("Sound", "PreviewSound", gui, { Volume = 0.5 })
print("KillSound created in StarterGui.")
