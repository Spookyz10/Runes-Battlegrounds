local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local StarterGUI = game:GetService("StarterGui")

StarterGUI:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local Player = Players.LocalPlayer

local Backpack = Player:WaitForChild("Moveset")
local PlayerGui = Player:WaitForChild("PlayerGui")

local Remotes = RS.Remotes
local MovesetHandler = Remotes.MovesetHandler
local AbilitiesHandlerFolder = Remotes.AbilitiesHandler
local AbilitieRemote_Get = AbilitiesHandlerFolder.Get

local GUI = PlayerGui:WaitForChild("Hotbar")
local HotbarFrame = GUI.Hotbar

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

local InfoModule = require(RS.Shared.Info)

local processedTools = {}

local TWEEN_SLIDE = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local POS_DOWN = UDim2.new(0.5, 0, 0.5, 125)
local POS_UP = UDim2.new(0.5, 0, 0.5, 0)

local activeBaseTweens: { [GuiObject]: Tween } = {}

local function cancelTween(base: GuiObject)
	if activeBaseTweens[base] then
		activeBaseTweens[base]:Cancel()
		activeBaseTweens[base] = nil
	end
end

local function tweenBase(base: GuiObject, goal: UDim2, tweenInfo: TweenInfo?, onComplete: (() -> ())?)
	cancelTween(base)
	local info = tweenInfo or TWEEN_SLIDE
	local tween = TS:Create(base, info, { Position = goal })
	activeBaseTweens[base] = tween
	tween.Completed:Once(function(state)
		if activeBaseTweens[base] == tween then
			activeBaseTweens[base] = nil
		end
		if state == Enum.PlaybackState.Completed and onComplete then
			onComplete()
		end
	end)
	tween:Play()

	local slot = base.Parent
	if slot then
		local offsetY = goal.Y.Offset
		local icon = slot:FindFirstChild("Icon")
		if icon then
			TS:Create(icon, info, { Position = UDim2.new(0, 0, 0, offsetY) }):Play()
		end
	end
end

local function getCharacter()
	return Player.Character
end

local function getGradientName()
	local moveset = Player:GetAttribute("Moveset")
	local movesetInfo = InfoModule.Movesets[moveset]
	if movesetInfo and movesetInfo.Modes then
		return Player:GetAttribute("MovesetMode_" .. moveset) or movesetInfo.DefaultMode
	end
	return moveset
end

local function tweenAllSlotsDown(onComplete: (() -> ())?)
	local total = 0
	local done = 0

	for _, slot in HotbarFrame:GetChildren() do
		if slot:IsA("ImageLabel") and slot:FindFirstChild("Base") then
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
		if slot:IsA("ImageLabel") and slot:FindFirstChild("Base") then
			tweenBase(slot.Base, POS_DOWN, TWEEN_SLIDE, function()
				done += 1
				if done == total and onComplete then
					onComplete()
				end
			end)
		end
	end
end

local activeCdTweens: { [GuiObject]: Tween } = {}

local function cancelCdTween(cdFrame: GuiObject)
	if activeCdTweens[cdFrame] then
		activeCdTweens[cdFrame]:Cancel()
		activeCdTweens[cdFrame] = nil
	end
end

local function shineIconEffect(slot)
	local icon = slot:FindFirstChild("Base"):FindFirstChild("Shine")
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
	TS:Create(shine, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(1.45, 0),
	}):Play()
	game.Debris:AddItem(shine, 0.6)
end

local function Equip(HotbarSlot)
	local Tool = AbilitieRemote_Get:InvokeServer(HotbarSlot.SkillName.Text)
	if not Tool then
		return
	end

	local char = getCharacter()
	if char then
		char:RemoveTag("Move Selected")
	end

	local cds = Tool:GetAttribute("CDS")

	if cds ~= 0 then
		local slot = HotbarSlot.Parent

		local function addCooldown()
			local cdFrame = slot:FindFirstChild("CooldownFrame")
			if not cdFrame then
				return
			end

			cancelCdTween(cdFrame)
			cdFrame.Size = UDim2.fromScale(1, 0.85)

			if cds > 0 then
				local cdTween =
					TS:Create(cdFrame, TweenInfo.new(cds, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(1, 0.15) })
				activeCdTweens[cdFrame] = cdTween
				cdTween.Completed:Once(function(state)
					if activeCdTweens[cdFrame] == cdTween then
						activeCdTweens[cdFrame] = nil
					end
					if state == Enum.PlaybackState.Completed and Tool.Name == HotbarSlot.SkillName.Text then
						shineIconEffect(slot)
					end
				end)
				cdTween:Play()
			end
		end

		if Tool:GetAttribute("onCDS") ~= true then
			local changedSignal
			changedSignal = Tool:GetAttributeChangedSignal("onCDS"):Connect(function()
				if Tool:GetAttribute("onCDS") == true or Tool:GetAttribute("CDS") == 0 then
					changedSignal:Disconnect()
					if Tool:GetAttribute("CDS") ~= 0 then
						addCooldown()
					end
				end
			end)
		else
			addCooldown()
		end
	end
end

local function getToolKey(tool: Tool): string
	return tool.Name .. "_" .. tostring(tool:GetAttribute("Index"))
end

local function AddTool(Tool: Tool)
	if not Tool:IsA("Tool") or not Tool:GetAttribute("Index") then
		return
	end

	local key = getToolKey(Tool)
	if processedTools[key] then
		return
	end
	processedTools[key] = true

	local HotbarSlot = HotbarFrame[tostring(Tool:GetAttribute("Index"))]
	if not HotbarSlot then
		return
	end

	local Base = HotbarSlot.Base
	HotbarSlot:SetAttribute("Active", true)

	tweenBase(Base, POS_DOWN, TWEEN_SLIDE, function()
		local existing = Base:FindFirstChild("Cooldown")
		if existing then
			existing:Destroy()
		end

		Base.SkillName.Text = Tool.Name
		HotbarSlot.Icon.Image = Tool:GetAttribute("Icon") or "rbxassetid://0"
		local cdIcon = HotbarSlot.CooldownFrame:FindFirstChild("CooldownIcon")
		if cdIcon then
			cdIcon.Image = Tool:GetAttribute("Icon") or "rbxassetid://0"
		end
		Base.Number.Text = tostring(Tool:GetAttribute("Index"))

		HotbarSlot.Visible = true

		tweenBase(Base, POS_UP, TWEEN_SLIDE)
	end)
end

local function updateHotbarGradients()
	local name = getGradientName()
	local source = HotbarFrame:FindFirstChild("Gradients")
	if not source then
		return
	end

	local template = source:FindFirstChild(name)

	for _, slot in HotbarFrame:GetChildren() do
		if slot:IsA("ImageLabel") and slot:FindFirstChild("Base") then
			local base = slot.Base
			for _, child in base:GetChildren() do
				if child:IsA("UIGradient") then
					child:Destroy()
				end
			end
			if template then
				template:Clone().Parent = base
			end
		end
	end
end

for _, slot in HotbarFrame:GetChildren() do
	if slot:IsA("ImageLabel") then
		local cdFrame = slot:FindFirstChild("CooldownFrame")
		if cdFrame then
			cdFrame.Size = UDim2.fromScale(1, 0)
		end
	end
end

updateHotbarGradients()

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	local slotKey = Keys[input.KeyCode.Name]
	if slotKey then
		local HotbarSlot = HotbarFrame[slotKey]
		if HotbarSlot then
			Equip(HotbarSlot.Base)
		end
	end
end)

for _, HotbarSlot in HotbarFrame:GetChildren() do
	if HotbarSlot:IsA("ImageLabel") and HotbarSlot:FindFirstChild("Base") then
		local Base = HotbarSlot.Base
		Base.Activated:Connect(function()
			local char = getCharacter()

			if Player.Configuration["Auto Use"].Value == true then
				Equip(Base)
			else
				if Base.SelectionObjectClipper.Visible == true then
					Base.SelectionObjectClipper.Visible = false

					if char then
						char:RemoveTag("Move Selected")
					end
				else
					for _, Slot in HotbarFrame:GetChildren() do
						if Slot:IsA("ImageLabel") and Slot:FindFirstChild("Base") then
							local SlotBase = Slot.Base
							if SlotBase ~= Base and SlotBase.SelectionObjectClipper.Visible == true then
								SlotBase.SelectionObjectClipper.Visible = false
								if char then
									char:RemoveTag("Move Selected")
								end
							end
						end
					end

					Base.SelectionObjectClipper.Visible = true

					if char then
						char:AddTag("Move Selected")
					end
				end
			end
		end)
	end
end

MovesetHandler.OnClientEvent:Connect(function(Goal)
	if Goal == "removeCooldowns" then
		for _, Frame in HotbarFrame:GetChildren() do
			if Frame:IsA("ImageLabel") then
				local cdFrame = Frame:FindFirstChild("CooldownFrame")
				if cdFrame then
					cancelCdTween(cdFrame)
					cdFrame.Size = UDim2.fromScale(1, 0)
				end
			end
		end
	end
end)

shared.triggerHotbar = function(State: boolean)
	if State == true then
		HotbarFrame:TweenPosition(
			UDim2.new(0.5, -327, 1, -70),
			Enum.EasingDirection.InOut,
			Enum.EasingStyle.Quad,
			1,
			true
		)
	else
		HotbarFrame:TweenPosition(
			UDim2.new(0.5, -327, 1, 55),
			Enum.EasingDirection.InOut,
			Enum.EasingStyle.Quad,
			1,
			true
		)
	end
end

Backpack.ChildAdded:Connect(AddTool)

Backpack.ChildRemoved:Connect(function(Tool: Tool)
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

	local HotbarSlot = HotbarFrame[tostring(Tool:GetAttribute("Index"))]
	if not HotbarSlot then
		return
	end

	local Base = HotbarSlot.Base

	if wasReplaced then
		tweenBase(Base, POS_DOWN, TWEEN_SLIDE)
	else
		tweenBase(Base, POS_DOWN, TWEEN_SLIDE, function()
			HotbarSlot:SetAttribute("Active", false)
			HotbarSlot.Visible = false
			Base.SkillName.Text = "N/A"
		end)
	end
end)

for _, Tool in Backpack:GetChildren() do
	task.spawn(AddTool, Tool)
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
