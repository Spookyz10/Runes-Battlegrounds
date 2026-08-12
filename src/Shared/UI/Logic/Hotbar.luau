local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local InfoModule = require(ReplicatedStorage.Shared.Info)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local Player = UIConstants.Player

local Backpack = Player:WaitForChild("Moveset")

local HotbarFrame = UIConstants.Hotbar.Hotbar
local Gradients = UIConstants.Gradients

local Keys = {
	["One"] = "1",
	["Two"] = "2",
	["Three"] = "3",
	["Four"] = "4",
	["Five"] = "5",
	["Six"] = "6",
	["Seven"] = "7",
	["Eight"] = "8",
	["Nine"] = "9",
	["Zero"] = "0",
	["ButtonL1"] = "1",
	["ButtonL2"] = "2",
	["ButtonR2"] = "3",
	["ButtonR1"] = "4",
	["DLeft+ButtonL1"] = "0",
	["DLeft+ButtonR1"] = "9",
}

local TWEEN_SLIDE = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local POS_DOWN = UDim2.new(0.5, 0, 0.5, 125)
local POS_UP = UDim2.new(0.5, 0, 0.5, 0)
local POS_SHOWN = UDim2.new(0.228, 0, 0.85, 0)
local POS_HIDDEN = UDim2.new(0.228, 0, 2, 0)

local COLOR_COOLDOWN = Color3.new(0, 0, 0)
local COLOR_READY = Color3.new(1, 1, 1)

local processedTools = {}

local Hotbar = {}

function Hotbar.Show()
	HotbarFrame:TweenPosition(POS_SHOWN, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 1, true)
end

function Hotbar.Hide()
	HotbarFrame:TweenPosition(POS_HIDDEN, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 1, true)
end

function Hotbar.Modify(params)
	for _, Button in HotbarFrame:GetChildren() do
		if not Button:IsA("Frame") then
			continue
		end
		if Button.Base.SkillName.Text ~= params.ToolName then
			continue
		end

		local property = Button.Base[params.Property]

		if params.Visible ~= nil then
			property.Visible = params.Visible
			if property:FindFirstChild("Description") then
				property.Description.Visible = params.Visible
			end
			continue
		end

		local defaultText = property.Text
		local defaultVisible = property.Visible

		Button.Base[params.Property].Text = params.Value
		property.Visible = true

		if property:FindFirstChild("Description") then
			Button.Base[params.Property].Description.Text = params.Value
			property.Description.Visible = true
		end

		if params.Time then
			task.delay(params.Time, function()
				property.Text = defaultText
				property.Visible = defaultVisible
				if property:FindFirstChild("Description") then
					property.Description.Text = defaultText
					property.Description.Visible = defaultVisible
				end
			end)
		end
	end
end

local function getMain(slot)
	return slot:FindFirstChild("Main")
end

local function getBase(slot)
	local main = getMain(slot)
	return main and main:FindFirstChild("Base")
end

local function getIcon(slot)
	local main = getMain(slot)
	return main and main:FindFirstChild("Icon")
end

local function getDarkIcon(slot)
	local main = getMain(slot)
	return main and main:FindFirstChild("DarkIcon")
end

function Hotbar.ResetCooldowns()
	for _, slot in HotbarFrame:GetChildren() do
		if not slot:IsA("ImageLabel") then
			continue
		end

		local icon = getIcon(slot)
		if icon then
			icon.ImageColor3 = COLOR_READY
		end

		UIFunctions.ResetCooldownIcon(getDarkIcon(slot))
	end
end

local function getGradientName()
	local moveset = Player:GetAttribute("Moveset")
	local movesetInfo = InfoModule.Movesets[moveset]
	if movesetInfo and movesetInfo.Modes then
		return Player:GetAttribute("MovesetMode_" .. moveset) or movesetInfo.DefaultMode
	end
	return moveset
end

local function updateHotbarGradients()
	local name = getGradientName()

	for _, slot in HotbarFrame:GetChildren() do
		if slot:IsA("ImageLabel") then
			local base = getBase(slot)
			if base then
				UIFunctions.ApplyGradientTemplate(base, Gradients, name)
			end
		end
	end
end

local function tweenAllSlotsDown(onComplete: (() -> ())?)
	local total = 0
	local done = 0

	for _, slot in HotbarFrame:GetChildren() do
		if slot:IsA("ImageLabel") and getMain(slot) then
			total += 1
		end
	end

	if total == 0 then
		if onComplete then
			onComplete()
		end
		return
	end

	for _, slot in HotbarFrame:GetChildren() do
		if slot:IsA("ImageLabel") then
			local main = getMain(slot)
			if main then
				UIFunctions.TweenSlide(main, POS_DOWN, TWEEN_SLIDE, function()
					done += 1
					if done == total and onComplete then
						onComplete()
					end
				end)
			end
		end
	end
end

local function shineIconEffect(slot)
	local base = getBase(slot)
	local icon = base and base:FindFirstChild("Shine")
	if not icon then
		return
	end

	icon.ClipsDescendants = true

	local shine = Instance.new("Frame")
	shine.Name = "ShineEffect"
	shine.Size = UDim2.fromScale(1, 1)
	shine.Position = UDim2.fromScale(-0.45, 0)
	shine.BackgroundColor3 = Color3.new(1, 1, 1)
	shine.BackgroundTransparency = 0.25
	shine.BorderSizePixel = 0
	shine.ZIndex = (icon.ZIndex or 1) + 5
	shine.Parent = icon

	local grad = Instance.new("UIGradient")
	grad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.25),
		NumberSequenceKeypoint.new(1, 1),
	})
	grad.Parent = shine

	TweenService:Create(shine, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(1.45, 0),
	}):Play()

	Debris:AddItem(shine, 0.6)
end

local function addCooldownToSlot(slot, Duration, SkillName)
	local icon = getIcon(slot)
	if not icon then
		return
	end

	icon.ImageColor3 = COLOR_COOLDOWN

	UIFunctions.PlayCooldownFill(getDarkIcon(slot), Duration, function()
		local base = getBase(slot)
		if base and base.SkillName.Text == SkillName then
			shineIconEffect(slot)
		end
	end)

	if Duration > 0 then
		TweenService:Create(icon, TweenInfo.new(Duration, Enum.EasingStyle.Linear), { ImageColor3 = COLOR_READY })
			:Play()
	else
		icon.ImageColor3 = COLOR_READY
	end
end

function Hotbar.StartCooldown(SkillName: string, Duration: number)
	if not Duration or Duration <= 0 then
		return
	end

	for _, slot in HotbarFrame:GetChildren() do
		if not slot:IsA("ImageLabel") then
			continue
		end

		local base = getBase(slot)
		if base and base.SkillName.Text == SkillName then
			addCooldownToSlot(slot, Duration, SkillName)
			return
		end
	end
end

local function equip(Base)
	local Tool = RemoteManager.FireServer("UseAbillity", Base.SkillName.Text)
	if not Tool then
		return
	end

	local Character = Player.Character
	if Character then
		Character:RemoveTag("Move Selected")
	end
end

local function getToolKey(tool: Tool): string
	return tool.Name .. "_" .. tostring(tool:GetAttribute("Index"))
end

local function addTool(Tool: Tool)
	if not Tool:IsA("Tool") or not Tool:GetAttribute("Index") then
		return
	end

	local key = getToolKey(Tool)
	if processedTools[key] then
		return
	end
	processedTools[key] = true

	local slot = HotbarFrame:FindFirstChild(tostring(Tool:GetAttribute("Index")))
	if not slot then
		return
	end

	local main = getMain(slot)
	local base = getBase(slot)
	if not main or not base then
		return
	end

	slot:SetAttribute("Active", true)

	UIFunctions.TweenSlide(main, POS_DOWN, TWEEN_SLIDE, function()
		base.SkillName.Text = Tool.Name
		base.Number.Text = tostring(Tool:GetAttribute("Index"))

		local icon = getIcon(slot)
		if icon then
			icon.Image = Tool:GetAttribute("Icon") or "rbxassetid://0"
			icon.ImageColor3 = COLOR_READY
		end

		UIFunctions.ResetCooldownIcon(getDarkIcon(slot))

		slot.Visible = true
		UIFunctions.TweenSlide(main, POS_UP, TWEEN_SLIDE)
	end)
end

local function removeTool(Tool: Tool)
	if not Tool:IsA("Tool") or not Tool:GetAttribute("Index") then
		return
	end

	local key = getToolKey(Tool)
	processedTools[key] = nil

	local wasReplaced = false
	for _, v in Backpack:GetChildren() do
		if v:GetAttribute("Index") == Tool:GetAttribute("Index") and v.Name ~= Tool.Name then
			wasReplaced = true
			break
		end
	end

	local slot = HotbarFrame:FindFirstChild(tostring(Tool:GetAttribute("Index")))
	if not slot then
		return
	end

	local main = getMain(slot)
	local base = getBase(slot)
	if not main then
		return
	end

	if wasReplaced then
		UIFunctions.TweenSlide(main, POS_DOWN, TWEEN_SLIDE)
	else
		UIFunctions.TweenSlide(main, POS_DOWN, TWEEN_SLIDE, function()
			slot:SetAttribute("Active", false)
			slot.Visible = false
			if base then
				base.SkillName.Text = "N/A"
			end
			UIFunctions.ResetCooldownIcon(getDarkIcon(slot))
		end)
	end
end

function Hotbar.Init()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

	for _, slot in HotbarFrame:GetChildren() do
		if slot:IsA("ImageLabel") then
			local icon = getIcon(slot)
			if icon then
				icon.ImageColor3 = COLOR_READY
			end
			UIFunctions.ResetCooldownIcon(getDarkIcon(slot))
		end
	end

	updateHotbarGradients()

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		local slotKey = Keys[input.KeyCode.Name]
		if not slotKey then
			return
		end

		local slot = HotbarFrame:FindFirstChild(slotKey)
		if not slot then
			return
		end

		local base = getBase(slot)
		if base then
			equip(base)
		end
	end)

	for _, slot in HotbarFrame:GetChildren() do
		if slot:IsA("ImageLabel") then
			local base = getBase(slot)
			if base then
				base.Activated:Connect(function()
					equip(base)
				end)
			end
		end
	end

	local MovesetHandlerRemote = RemoteManager.GetRemote("MovesetHandler", "Client")
	if MovesetHandlerRemote then
		MovesetHandlerRemote.OnClientEvent:Connect(function(Goal)
			if Goal == "removeCooldowns" then
				Hotbar.ResetCooldowns()
			end
		end)
	end

	Backpack.ChildAdded:Connect(addTool)
	Backpack.ChildRemoved:Connect(removeTool)

	for _, Tool in Backpack:GetChildren() do
		task.spawn(addTool, Tool)
	end

	Player:GetAttributeChangedSignal("Moveset"):Connect(function()
		tweenAllSlotsDown()
		task.delay(TWEEN_SLIDE.Time, updateHotbarGradients)
	end)

	Player.AttributeChanged:Connect(function(attr)
		if attr:match("^MovesetMode_") then
			tweenAllSlotsDown()
			task.delay(TWEEN_SLIDE.Time, updateHotbarGradients)
		end
	end)
end

return Hotbar
