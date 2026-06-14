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
local CooldownFrame = RS.Resources.UI.Cooldown

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
	local tween = TS:Create(base, tweenInfo or TWEEN_SLIDE, { Position = goal })
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
		if slot:IsA("Frame") and slot:FindFirstChild("Base") then
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
		if slot:IsA("Frame") and slot:FindFirstChild("Base") then
			tweenBase(slot.Base, POS_DOWN, TWEEN_SLIDE, function()
				done += 1
				if done == total and onComplete then
					onComplete()
				end
			end)
		end
	end
end

local function whiteGradientTween(parent)
	local flash = CooldownFrame:Clone()
	flash.BackgroundColor3 = Color3.new(1, 1, 1)
	flash.Size = UDim2.fromScale(1, -1)
	flash.Parent = parent
	TS:Create(flash, TweenInfo.new(0.5, Enum.EasingStyle.Linear), { BackgroundTransparency = 1 }):Play()
	game.Debris:AddItem(flash, 0.5)
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
		local function addCooldown()
			local prev = HotbarSlot:FindFirstChild("Cooldown")
			if prev then
				prev:Destroy()
			end

			local Cooldown = CooldownFrame:Clone()
			Cooldown.Parent = HotbarSlot
			if cds > 0 then
				game.Debris:AddItem(Cooldown, cds)

				local cdTween =
					TS:Create(Cooldown, TweenInfo.new(cds, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(1, 0) })
				cdTween.Completed:Once(function()
					if Tool.Name == HotbarSlot.SkillName.Text then
						whiteGradientTween(HotbarSlot)
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
	else
		whiteGradientTween(HotbarSlot)
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
			whiteGradientTween(Base)
		end

		Base.SkillName.Text = Tool.Name
		Base.Icon.Image = Tool:GetAttribute("Icon") or "rbxassetid://0"
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
		if slot:IsA("Frame") and slot:FindFirstChild("Base") then
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
	if HotbarSlot:IsA("Frame") and HotbarSlot:FindFirstChild("Base") then
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
						if Slot:IsA("Frame") and Slot:FindFirstChild("Base") then
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
			if Frame:IsA("Frame") then
				local Base = Frame:FindFirstChild("Base")
				if not Base then
					continue
				end

				local Cooldown = Base:FindFirstChild("Cooldown")
				if Cooldown then
					Cooldown:Destroy()
					whiteGradientTween(Base)
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
	tweenAllSlotsDown(updateHotbarGradients)
end)

Player.AttributeChanged:Connect(function(attr)
	if attr:match("^MovesetMode_") then
		tweenAllSlotsDown(updateHotbarGradients)
	end
end)
