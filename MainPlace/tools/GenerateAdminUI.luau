local RunService = game:GetService("RunService")
assert(not RunService:IsRunning(), "Run in edit mode.")
local StarterGui = game:GetService("StarterGui")
assert(
	not StarterGui:FindFirstChild("Admin"),
	"Admin already exists. Rename the previous UI before generating a new one."
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

local gui = create("ScreenGui", "Admin", StarterGui, {
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
	Size = UDim2.fromScale(0.65, 0.76),
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
label(main, "Eyebrow", "SERVER OPERATIONS", 0.04, 0.035, 0.32, 0.025, muted)
label(main, "Title", "Admin panel", 0.04, 0.075, 0.35, 0.075)
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

local function input(name, hint, x, y, w, h)
	local box = create("TextBox", name, main, {
		Position = UDim2.fromScale(x, y),
		Size = UDim2.fromScale(w, h),
		BackgroundColor3 = Color3.fromRGB(32, 33, 48),
		Text = "",
		PlaceholderText = hint,
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

	return box
end

local actions = {
	{ "Gold", "Give gold" },
	{ "Cosmetic", "Give cosmetic" },
	{ "Aura", "Give aura" },
	{ "Skin", "Give skin" },
	{ "Gamepass", "Give pass" },
	{ "Kick", "Kick" },
	{ "Ban", "Ban" },
	{ "Unban", "Unban" },
}

for index, entry in actions do
	button(
		entry[1],
		entry[2],
		0.04 + ((index - 1) % 4) * 0.235,
		0.19 + math.floor((index - 1) / 4) * 0.07,
		0.215,
		0.058
	)
end

input("Target", "Target UserId or exact username", 0.04, 0.35, 0.44, 0.065)
input("Value", "Gold amount", 0.52, 0.35, 0.44, 0.065)
input("Reason", "Reason (required for bans)", 0.04, 0.43, 0.92, 0.065)
local help = label(main, "Help", "Grants reach players across servers.", 0.04, 0.51, 0.92, 0.048, muted)
help.TextWrapped = true
button("Execute", "Send command", 0.62, 0.57, 0.34, 0.065)
label(main, "DisasterTitle", "VOLCANIC ERUPTION", 0.04, 0.67, 0.7, 0.03, muted)
button("Scope", "This server", 0.04, 0.72, 0.28, 0.065)
button("StartDisaster", "Start eruption", 0.36, 0.72, 0.28, 0.065)
button("StopDisaster", "Stop eruption", 0.68, 0.72, 0.28, 0.065)
local status =
	label(main, "Status", "Ready. Commands are authorized by the server.", 0.04, 0.83, 0.92, 0.09, muted)
status.TextWrapped = true
print("Admin created in StarterGui. Only allowlisted players can use it.")
