local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local KillStreakFolder = ReplicatedStorage.Resources.Misc.KillStreak

local REQUIRED_STREAK = 10
local GOLD_HEX = "#FFD700"

local module = {}

local function clearKillStreak(Character)
	local ExistingHighlight = Character:FindFirstChild("KillStreakHighlight")
	if ExistingHighlight then
		ExistingHighlight:Destroy()
	end

	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not RootPart then
		return
	end

	local Billboard = RootPart:FindFirstChild("KillStreakBillboard")
	if Billboard then
		Billboard:Destroy()
	end

	for _, Child in RootPart:GetChildren() do
		if Child:IsA("Beam") and Child:HasTag("KillStreakBeam") then
			Child:Destroy()
		end
	end
end

local function announceKillStreak(Player, Streak)
	local Message = string.format("%s is unstoppable with %d kills!", Player.Name, Streak)
	local Colored = string.format('<font color="%s">%s</font>', GOLD_HEX, Message)

	TextChatService:DisplaySystemMessage(Colored)
end

local function applyKillStreak(Player, Character, Streak)
	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not RootPart then
		return
	end

	local HighlightTemplate = KillStreakFolder:FindFirstChild("Highlight")
	if HighlightTemplate then
		local Highlight = HighlightTemplate:Clone()
		Highlight.Name = "KillStreakHighlight"
		Highlight.Parent = Character
	end

	local StreakTemplate = KillStreakFolder:FindFirstChild("Streak")
	if StreakTemplate and StreakTemplate:IsA("BillboardGui") then
		local NewBillboard = StreakTemplate:Clone()
		NewBillboard.Name = "KillStreakBillboard"

		local Label = NewBillboard:FindFirstChild("Label", true)
		if Label and Label:IsA("TextLabel") then
			Label.Text = tostring(Streak)
		end

		NewBillboard.Parent = RootPart
	end

	for _, Child in KillStreakFolder:GetChildren() do
		if Child:IsA("Beam") then
			local NewBeam = Child:Clone()
			NewBeam:AddTag("KillStreakBeam")
			NewBeam.Parent = RootPart
		end
	end

	announceKillStreak(Player, Streak)
end

local function updateKillStreak(Player, Character, Streak)
	if not Streak or Streak < REQUIRED_STREAK then
		clearKillStreak(Character)
		return
	end

	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not RootPart then
		return
	end

	local Billboard = RootPart:FindFirstChild("KillStreakBillboard")
	if Billboard then
		local Label = Billboard:FindFirstChild("Label", true)
		if Label and Label:IsA("TextLabel") then
			Label.Text = tostring(Streak)
		end
		return
	end

	applyKillStreak(Player, Character, Streak)
end

local function setupCharacter(Player, Character)
	clearKillStreak(Character)

	Character:GetAttributeChangedSignal("Streak"):Connect(function()
		updateKillStreak(Player, Character, Character:GetAttribute("Streak"))
	end)

	Character.AncestryChanged:Connect(function(_, Parent)
		if not Parent then
			clearKillStreak(Character)
		end
	end)
end

function module:Init()
	Players.PlayerAdded:Connect(function(Player)
		Player.CharacterAdded:Connect(function(Character)
			setupCharacter(Player, Character)
		end)

		if Player.Character then
			setupCharacter(Player, Player.Character)
		end
	end)

	for _, Player in Players:GetPlayers() do
		if Player.Character then
			setupCharacter(Player, Player.Character)
		end

		Player.CharacterAdded:Connect(function(Character)
			setupCharacter(Player, Character)
		end)
	end
end

module:Init()

return module
