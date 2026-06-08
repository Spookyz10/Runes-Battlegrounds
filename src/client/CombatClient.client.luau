local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local CombatRemotes = ReplicatedStorage.Remotes.Combat

local selectedTool = nil

local function getToolByName(name)
	return player.Backpack:FindFirstChild(name)
end

local function watchTool(tool)
	tool.Equipped:Connect(function()
		selectedTool = tool
		if tool.Parent == player.Character then
			tool.Parent = player.Backpack
		end
	end)

	tool.Unequipped:Connect(function()
		if selectedTool == tool then
			selectedTool = nil
		end
	end)

	tool.AncestryChanged:Connect(function()
		if not tool:IsDescendantOf(player.Backpack) and selectedTool == tool then
			selectedTool = nil
		end
	end)
end

for _, tool in player.Backpack:GetChildren() do
	if tool:IsA("Tool") then
		watchTool(tool)
	end
end

player.Backpack.ChildAdded:Connect(function(child)
	if child:IsA("Tool") then
		watchTool(child)
	end
end)

-- ─── Registra slots do hotbar pra keybind 1-9 ───────────────────────────────

local SLOT_KEYS = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
	[Enum.KeyCode.Six] = 6,
	[Enum.KeyCode.Seven] = 7,
	[Enum.KeyCode.Eight] = 8,
	[Enum.KeyCode.Nine] = 9,
}

-- ─── Click esquerdo ──────────────────────────────────────────────────────────

mouse.Button1Down:Connect(function()
	if selectedTool and getToolByName(selectedTool.Name) then
		CombatRemotes.Skill:FireServer(selectedTool)
		return
	end

	CombatRemotes.M1:FireServer()
end)

-- ─── Block (F) ───────────────────────────────────────────────────────────────
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then
		return
	end

	if input.KeyCode == Enum.KeyCode.F then
		CombatRemotes.BlockStart:FireServer()
		return
	end

	local slotIndex = SLOT_KEYS[input.KeyCode]
	if slotIndex then
		local tools = {}
		for _, item in player.Backpack:GetChildren() do
			if item:IsA("Tool") then
				tools[#tools + 1] = item
			end
		end
		local tool = tools[slotIndex]
		if tool then
			CombatRemotes.Skill:FireServer(tool)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
	if gpe then
		return
	end
	if input.KeyCode == Enum.KeyCode.F then
		CombatRemotes.BlockEnd:FireServer()
	end
end)
