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

local COLOR_COOLDOWN = Color3.new(0, 0, 0)
local COLOR_READY = Color3.new(1, 1, 1)

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

local activeMainTweens: { [GuiObject]: Tween } = {}

local function cancelMainTween(main: GuiObject)
	if activeMainTweens[main] then
		activeMainTweens[main]:Cancel()
		activeMainTweens[main] = nil
	end
end

local function tweenMain(main: GuiObject, goal: UDim2, tweenInfo: TweenInfo?, onComplete: (() -> ())?)
	cancelMainTween(main)
	local info = tweenInfo or TWEEN_SLIDE
	local tween = TS:Create(main, info, { Position = goal })
	activeMainTweens[main] = tween
	tween.Completed:Once(function(state)
		if activeMainTweens[main] == tween then
			activeMainTweens[main] = nil
		end
		if state == Enum.PlaybackState.Completed and onComplete then
			onComplete()
		end
	end)
	tween:Play()
end

-- ── Helpers gerais ───────────────────────────────────────────────────────────
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
				tweenMain(main, POS_DOWN, TWEEN_SLIDE, function()
					done += 1
					if done == total and onComplete then
						onComplete()
					end
				end)
			end
		end
	end
end

-- ── Cooldown ─────────────────────────────────────────────────────────────────
local activeCdTweens: { [GuiObject]: Tween } = {}

local function cancelCdTween(icon: GuiObject)
	if activeCdTweens[icon] then
		activeCdTweens[icon]:Cancel()
		activeCdTweens[icon] = nil
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
	TS:Create(shine, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(1.45, 0),
	}):Play()
	game.Debris:AddItem(shine, 0.6)
end

local function Equip(Base)
	-- Base é o filho do Main; slot é o ImageLabel pai do Main
	local Tool = AbilitieRemote_Get:InvokeServer(Base.SkillName.Text)
	if not Tool then
		return
	end

	local char = getCharacter()
	if char then
		char:RemoveTag("Move Selected")
	end

	local cds = Tool:GetAttribute("CDS")
	if cds ~= 0 then
		-- slot = Main.Parent
		local slot = Base.Parent.Parent

		local function addCooldown()
			local icon = getIcon(slot)
			if not icon then
				return
			end

			cancelCdTween(icon)
			icon.ImageColor3 = COLOR_COOLDOWN

			if cds > 0 then
				local cdTween =
					TS:Create(icon, TweenInfo.new(cds, Enum.EasingStyle.Linear), { ImageColor3 = COLOR_READY })
				activeCdTweens[icon] = cdTween
				cdTween.Completed:Once(function(state)
					if activeCdTweens[icon] == cdTween then
						activeCdTweens[icon] = nil
					end
					if state == Enum.PlaybackState.Completed and Tool.Name == Base.SkillName.Text then
						shineIconEffect(slot)
					end
				end)
				cdTween:Play()
			else
				icon.ImageColor3 = COLOR_READY
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

-- ── Adicionar tool ────────────────────────────────────────────────────────────
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

	tweenMain(main, POS_DOWN, TWEEN_SLIDE, function()
		base.SkillName.Text = Tool.Name
		base.Number.Text = tostring(Tool:GetAttribute("Index"))

		local icon = getIcon(slot)
		if icon then
			icon.Image = Tool:GetAttribute("Icon") or "rbxassetid://0"
			cancelCdTween(icon)
			icon.ImageColor3 = COLOR_READY
		end

		slot.Visible = true
		tweenMain(main, POS_UP, TWEEN_SLIDE)
	end)
end

-- ── Gradients ────────────────────────────────────────────────────────────────
local function updateHotbarGradients()
	local name = getGradientName()
	local source = HotbarFrame:FindFirstChild("Gradients")
	if not source then
		return
	end

	local template = source:FindFirstChild(name)

	for _, slot in HotbarFrame:GetChildren() do
		if slot:IsA("ImageLabel") then
			local base = getBase(slot)
			if base then
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
end

-- ── Init ─────────────────────────────────────────────────────────────────────
for _, slot in HotbarFrame:GetChildren() do
	if slot:IsA("ImageLabel") then
		local icon = getIcon(slot)
		if icon then
			icon.ImageColor3 = COLOR_READY
		end
	end
end

updateHotbarGradients()

-- ── Input teclado/gamepad ────────────────────────────────────────────────────
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	local slotKey = Keys[input.KeyCode.Name]
	if slotKey then
		local slot = HotbarFrame:FindFirstChild(slotKey)
		if slot then
			local base = getBase(slot)
			if base then
				Equip(base)
			end
		end
	end
end)

-- ── Click / tap nos slots ────────────────────────────────────────────────────
for _, slot in HotbarFrame:GetChildren() do
	if slot:IsA("ImageLabel") then
		local base = getBase(slot)
		if base then
			base.Activated:Connect(function()
				local char = getCharacter()

				if Player.Configuration["Auto Use"].Value == true then
					Equip(base)
				else
					if base.SelectionObjectClipper.Visible == true then
						base.SelectionObjectClipper.Visible = false
						if char then
							char:RemoveTag("Move Selected")
						end
					else
						for _, otherSlot in HotbarFrame:GetChildren() do
							if otherSlot:IsA("ImageLabel") then
								local otherBase = getBase(otherSlot)
								if otherBase and otherBase ~= base and otherBase.SelectionObjectClipper.Visible then
									otherBase.SelectionObjectClipper.Visible = false
									if char then
										char:RemoveTag("Move Selected")
									end
								end
							end
						end

						base.SelectionObjectClipper.Visible = true
						if char then
							char:AddTag("Move Selected")
						end
					end
				end
			end)
		end
	end
end

-- ── Remotes ──────────────────────────────────────────────────────────────────
MovesetHandler.OnClientEvent:Connect(function(Goal)
	if Goal == "removeCooldowns" then
		for _, slot in HotbarFrame:GetChildren() do
			if slot:IsA("ImageLabel") then
				local icon = getIcon(slot)
				if icon then
					cancelCdTween(icon)
					icon.ImageColor3 = COLOR_READY
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

-- ── Backpack ChildAdded / ChildRemoved ───────────────────────────────────────
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
		tweenMain(main, POS_DOWN, TWEEN_SLIDE)
	else
		tweenMain(main, POS_DOWN, TWEEN_SLIDE, function()
			slot:SetAttribute("Active", false)
			slot.Visible = false
			if base then
				base.SkillName.Text = "N/A"
			end
		end)
	end
end)

for _, Tool in Backpack:GetChildren() do
	task.spawn(AddTool, Tool)
end

-- ── Mudança de moveset / modo ────────────────────────────────────────────────
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
