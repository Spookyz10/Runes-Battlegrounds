assert(not game:GetService("RunService"):IsRunning(), "Run in edit mode.")
local starter = game:GetService("StarterGui")
assert(
	not starter:FindFirstChild("Notifications"),
	"Notifications already exists. Rename the previous UI before generating a new one."
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

local gui = create(
	"ScreenGui",
	"Notifications",
	starter,
	{
		Enabled = false,
		ResetOnSpawn = false,
		DisplayOrder = 100,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}
)
local stack = create("Frame", "Stack", gui, {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.fromScale(0.98, 0.06),
	Size = UDim2.fromScale(0.26, 0.45),
	BackgroundTransparency = 1,
})
create("UIListLayout", "Layout", stack, {
	Padding = UDim.new(0.025, 0),
	SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
})
local templates = create("Folder", "Templates", gui)
local toast = create("CanvasGroup", "Toast", templates, {
	Visible = false,
	Size = UDim2.fromScale(1, 0.19),
	BackgroundColor3 = Color3.fromRGB(24, 35, 31),
	BorderSizePixel = 0,
})
create("UICorner", "Corner", toast, { CornerRadius = UDim.new(0.12, 0) })
create("UIStroke", "Stroke", toast, { Color = Color3.fromRGB(75, 195, 132), Transparency = 0.25 })
create("TextLabel", "Title", toast, {
	Position = UDim2.fromScale(0.055, 0.12),
	Size = UDim2.fromScale(0.78, 0.23),
	BackgroundTransparency = 1,
	Text = "SUCCESS",
	TextScaled = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.GothamBold,
	TextColor3 = Color3.fromRGB(103, 231, 157),
})
create("TextLabel", "Message", toast, {
	MaxVisibleGraphemes = 0,
	Position = UDim2.fromScale(0.055, 0.42),
	Size = UDim2.fromScale(0.8, 0.4),
	BackgroundTransparency = 1,
	Text = "Purchase successful!",
	TextScaled = true,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Color3.fromRGB(241, 244, 248),
})
create("TextButton", "Close", toast, {
	Position = UDim2.fromScale(0.87, 0.12),
	Size = UDim2.fromScale(0.09, 0.3),
	BackgroundTransparency = 1,
	Text = "Ã—",
	TextScaled = true,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Color3.fromRGB(220, 225, 235),
})
create("Frame", "Lifetime", toast, {
	Position = UDim2.fromScale(0, 0.97),
	Size = UDim2.fromScale(1, 0.03),
	BackgroundColor3 = Color3.fromRGB(103, 231, 157),
	BorderSizePixel = 0,
})
print("Notifications created in StarterGui.")
