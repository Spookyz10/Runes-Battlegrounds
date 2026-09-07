-- Paste this entire file into the Roblox Studio Command Bar in edit mode.
local RunService = game:GetService("RunService")
assert(not RunService:IsRunning(), "Run in edit mode.")
local StarterGui = game:GetService("StarterGui")
local function create(class, name, parent, properties)
	local object = Instance.new(class)
	object.Name = name
	for key, value in properties or {} do
		object[key] = value
	end
	object.Parent = parent
	return object
end
local colors = {
	Background = Color3.fromRGB(18, 20, 30),
	Surface = Color3.fromRGB(30, 33, 47),
	Text = Color3.fromRGB(241, 243, 252),
	Muted = Color3.fromRGB(161, 171, 194),
	Accent = Color3.fromRGB(111, 99, 225),
	Danger = Color3.fromRGB(153, 53, 69),
}
local function corner(object)
	create("UICorner", "Corner", object, { CornerRadius = UDim.new(0, 8) })
end
local function text(parent, name, value, x, y, width, height, muted)
	return create("TextLabel", name, parent, {
		Position = UDim2.new(x, 0, 0, y),
		Size = UDim2.new(width, 0, 0, height),
		BackgroundTransparency = 1,
		Text = value,
		TextColor3 = if muted then colors.Muted else colors.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
end
local function button(parent, name, value, x, y, width, height, color)
	local object = create("TextButton", name, parent, {
		Position = UDim2.new(x, 0, 0, y),
		Size = UDim2.new(width, 0, 0, height),
		BackgroundColor3 = color or colors.Surface,
		BorderSizePixel = 0,
		Text = value,
		TextColor3 = colors.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextWrapped = true,
		AutoButtonColor = true,
	})
	corner(object)
	return object
end
local function input(parent, name, title, hint, y)
	text(parent, name .. "Label", title, 0.02, y, 0.96, 22, true)
	local object = create("TextBox", name, parent, {
		Position = UDim2.new(0.02, 0, 0, y + 26),
		Size = UDim2.new(0.96, 0, 0, 42),
		BackgroundColor3 = colors.Surface,
		BorderSizePixel = 0,
		Text = "",
		PlaceholderText = hint,
		PlaceholderColor3 = colors.Muted,
		TextColor3 = colors.Text,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	corner(object)
	create("UIPadding", "Padding", object, { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) })
end

-- Build off-tree first, so an error cannot remove the existing panel.
local gui = create("ScreenGui", "Admin", nil, {
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
	Size = UDim2.new(0.46, 0, 0.76, 0),
	BackgroundColor3 = colors.Background,
	BorderSizePixel = 0,
})
corner(main)
create("UIStroke", "Border", main, { Color = Color3.fromRGB(71, 77, 105), Transparency = 0.35 })
text(main, "Eyebrow", "SERVER OPERATIONS", 0.04, 15, 0.75, 18, true).TextSize = 11
text(main, "Title", "Admin panel", 0.04, 38, 0.75, 30).TextSize = 24
button(main, "Close", "X", 0.88, 23, 0.08, 36)
button(main, "PlayersTab", "Players", 0.04, 83, 0.45, 36, colors.Accent)
button(main, "EventsTab", "Events", 0.51, 83, 0.45, 36)
local function page(name, visible)
	return create("ScrollingFrame", name, main, {
		Position = UDim2.new(0.03, 0, 0, 133),
		Size = UDim2.new(0.94, 0, 1, -261),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = colors.Accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Visible = visible,
	})
end
local players = page("PlayerPage", true)
local actions = {
	{ "Gold", "Give gold" },
	{ "Cosmetic", "Give cosmetic" },
	{ "Aura", "Give aura" },
	{ "Skin", "Give skin" },
	{ "Gamepass", "Give gamepass" },
	{ "Kick", "Kick player" },
	{ "Ban", "Ban player" },
	{ "Unban", "Unban player" },
}
text(players, "Heading", "PLAYER ACTIONS", 0.02, 0, 0.96, 24, true)
for index, entry in actions do
	button(
		players,
		entry[1],
		entry[2],
		0.02 + ((index - 1) % 2) * 0.49,
		32 + math.floor((index - 1) / 2) * 46,
		0.47,
		38
	)
end
input(players, "Target", "TARGET PLAYER", "UserId or exact username", 226)
input(players, "Value", "VALUE", "Gold amount", 306)
input(players, "Reason", "REASON", "Required for bans", 386)
text(players, "Help", "Adds gold to the target's saved balance.", 0.02, 465, 0.96, 52, true)
button(players, "Execute", "Send command", 0.02, 529, 0.96, 44, colors.Accent)
text(players, "Delivery", "Player commands can reach other servers.", 0.02, 583, 0.96, 30, true)

local events = page("EventsPage", false)
text(events, "ActiveEvent", "This server: no active event", 0.02, 0, 0.96, 30)
text(events, "Heading", "SELECT AN EVENT", 0.02, 40, 0.96, 24, true)
local catalog = {
	{ "Volcano", "Volcanic eruption", "Lava rocks and marked impact zones." },
	{ "Storm", "Thunderstorm", "Rain, lightning strikes and tornadoes." },
	{ "Blizzard", "Blizzard", "Heavy snow and falling ice blocks." },
	{ "MeteorShower", "Meteor shower", "Night sky and falling meteors." },
}
for index, entry in catalog do
	local card = button(events, entry[1], "", 0.02, 74 + (index - 1) * 78, 0.96, 68)
	text(card, "Title", entry[2], 0.04, 8, 0.92, 24)
	text(card, "Description", entry[3], 0.04, 34, 0.92, 27, true).TextSize = 12
end
text(events, "ScopeLabel", "EVENT COMMAND SCOPE", 0.02, 398, 0.96, 24, true)
button(events, "Scope", "This server", 0.02, 428, 0.96, 40)
button(events, "StartDisaster", "Start volcanic eruption", 0.02, 482, 0.96, 44, colors.Accent)
local stop = button(main, "StopDisaster", "Stop all events - This server", 0.04, 0, 0.92, 42, colors.Danger)
stop.Position = UDim2.new(0.04, 0, 1, -119)
text(
	events,
	"StopHelp",
	"Stops all active hazards in the selected scope. Random events resume in 10 minutes.",
	0.02,
	540,
	0.96,
	54,
	true
)
local status = text(main, "Status", "Ready. Select an action or event.", 0.04, 0, 0.92, 54, true)
status.Position = UDim2.new(0.04, 0, 1, -65)

local previous = StarterGui:FindFirstChild("Admin")
if previous then
	previous:Destroy()
end
gui.Parent = StarterGui
print("Admin UI regenerated. Main size: {0.46, 0}, {0.76, 0}. Play to use it with the synced Admin logic.")
