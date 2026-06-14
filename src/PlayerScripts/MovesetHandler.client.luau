local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local StarterGUI = game:GetService("StarterGui")

StarterGUI:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
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

local MoveSelected = nil

local InfoModule = require(RS.Shared.Info)

local function getGradientName()
	local moveset = Player:GetAttribute("Moveset")
	local movesetInfo = InfoModule.Movesets[moveset]
	if movesetInfo and movesetInfo.Modes then
		return Player:GetAttribute("MovesetMode_" .. moveset) or movesetInfo.DefaultMode
	end
	return moveset
end

local function tweenAllSlotsDown(onComplete)
	for _, slot in HotbarFrame:GetChildren() do
		if slot:IsA("Frame") and slot:FindFirstChild("Base") then
			slot.Base:TweenPosition(
				UDim2.new(0.5, 0, 0.5, 125),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.35,
				true
			)
		end
	end
	task.delay(0.35, function()
		if onComplete then
			onComplete()
		end
	end)
end

local function whiteGradientTween(Parent)
	local moveUsed = CooldownFrame:Clone()
	moveUsed.BackgroundColor3 = Color3.new(1, 1, 1)
	moveUsed.Size = UDim2.fromScale(1, -1)
	moveUsed.Parent = Parent
	TS:Create(moveUsed, TweenInfo.new(0.5, Enum.EasingStyle.Linear), { BackgroundTransparency = 1 }):Play()
	game.Debris:AddItem(moveUsed, 0.5)
end

local function Equip(HotbarSlot)
	local Tool = AbilitieRemote_Get:InvokeServer(HotbarSlot.SkillName.Text)
	if Tool then
		Character:RemoveTag("Move Selected")

		if Tool:GetAttribute("CDS") ~= 0 then
			local function addCooldown()
				local PreviousCooldown = HotbarSlot:FindFirstChild("Cooldown")
				if PreviousCooldown then
					PreviousCooldown:Destroy()
				end

				local Cooldown: Frame = CooldownFrame:Clone()

				if Tool:GetAttribute("CDS") ~= 0 then
					Cooldown.Parent = HotbarSlot
				end

				if Tool:GetAttribute("CDS") > -1 and Tool:GetAttribute("CDS") ~= 0 then
					game.Debris:AddItem(Cooldown, Tool:GetAttribute("CDS"))

					local Tween = TS:Create(
						Cooldown,
						TweenInfo.new(Tool:GetAttribute("CDS"), Enum.EasingStyle.Linear),
						{ Size = UDim2.fromScale(1, 0) }
					)
					Tween.Completed:Once(function()
						if Tool.Name == HotbarSlot.SkillName.Text then
							whiteGradientTween(HotbarSlot)
						end
					end)
					Tween:Play()
				elseif Tool:GetAttribute("CDS") == 0 then
					whiteGradientTween(HotbarSlot)
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
end

local function AddTool(Tool)
	if not Tool:IsA("Tool") or not Tool:GetAttribute("Index") then
		return
	end

	local HotbarSlot = HotbarFrame[tostring(Tool:GetAttribute("Index"))]
	if not HotbarSlot then
		return
	end

	local Base = HotbarSlot.Base
	local PreviousState = HotbarSlot:GetAttribute("Active")
	HotbarSlot:SetAttribute("Active", true)

	if PreviousState ~= true then
		Base:TweenPosition(UDim2.new(0.5, 0, 0.5, 125), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.35, true)
		task.wait(0.35)
	end

	local Cooldown = Base:FindFirstChild("Cooldown")
	if Cooldown then
		Cooldown:Destroy()
		whiteGradientTween(Base)
	end

	Base.SkillName.Text = Tool.Name
	Base.Icon.Image = Tool:GetAttribute("Icon") or "rbxassetid://0"
	Base.Number.Text = Tool:GetAttribute("Index")

	HotbarSlot.Visible = true

	Base:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.35, true)
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

UIS.InputBegan:Connect(function(input, gameProccessedEvent)
	if gameProccessedEvent then
		return
	end

	if Keys[input.KeyCode.Name] then
		local HotbarSlot = HotbarFrame[Keys[input.KeyCode.Name]]
		if HotbarSlot then
			Equip(HotbarSlot.Base)
		end
	end
end)

for _, HotbarSlot in HotbarFrame:GetChildren() do
	if HotbarSlot:IsA("Frame") and HotbarSlot:FindFirstChild("Base") then
		HotbarSlot = HotbarSlot.Base
		HotbarSlot.Activated:Connect(function()
			if Player.Configuration["Auto Use"].Value == true then
				Equip(HotbarSlot)
			else
				if HotbarSlot.SelectionObjectClipper.Visible == true then
					MoveSelected.SelectionObjectClipper.Visible = false
					MoveSelected = nil
					Character:RemoveTag("Move Selected")
				else
					for _, Slot in HotbarFrame:GetChildren() do
						if Slot:IsA("Frame") and Slot:FindFirstChild("Base") then
							Slot = Slot.Base
							if Slot ~= HotbarSlot and Slot.SelectionObjectClipper.Visible == true then
								Slot.SelectionObjectClipper.Visible = false
								Character:RemoveTag("Move Selected")
							end
						end
					end

					HotbarSlot.SelectionObjectClipper.Visible = true
					MoveSelected = HotbarSlot
					Character:AddTag("Move Selected")
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
				local Cooldown = Base:FindFirstChild("Cooldown")
				if Cooldown then
					Cooldown:Destroy()
					whiteGradientTween(Base)
				end
			end
		end
	end
end)

shared.triggerHotbar = function(State)
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
	if Tool:IsA("Tool") and Tool:GetAttribute("Index") then
		local wasReplaced = false

		for _, v in Backpack:GetChildren() do
			if v:GetAttribute("Index") == Tool:GetAttribute("Index") and v.Name ~= Tool.Name then
				wasReplaced = true
			end
		end

		local HotbarSlot = HotbarFrame[tostring(Tool:GetAttribute("Index"))]
		if HotbarSlot then
			local Base = HotbarSlot.Base

			Base:TweenPosition(UDim2.new(0.5, 0, 0.5, 125), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true)

			if wasReplaced == true then
				task.delay(0.5, function()
					Base:TweenPosition(
						UDim2.new(0.5, 0, 0.5, 0),
						Enum.EasingDirection.Out,
						Enum.EasingStyle.Quad,
						0.5,
						true
					)
				end)
				return
			end

			HotbarSlot:SetAttribute("Active", false)

			task.delay(0.5, function()
				if HotbarSlot:GetAttribute("Active") == false then
					HotbarSlot.Visible = false
					Base.SkillName.Text = "N/A"
				end
			end)
		end
	end
end)

for _, Tool in Backpack:GetChildren() do
	task.spawn(function()
		AddTool(Tool)
	end)
end

Player:GetAttributeChangedSignal("Moveset"):Connect(function()
	tweenAllSlotsDown()
	task.delay(0.35, function()
		updateHotbarGradients()
	end)
end)

Player.AttributeChanged:Connect(function(attr)
	if attr:match("^MovesetMode_") then
		tweenAllSlotsDown()
		task.delay(0.35, function()
			updateHotbarGradients()
		end)
	end
end)
