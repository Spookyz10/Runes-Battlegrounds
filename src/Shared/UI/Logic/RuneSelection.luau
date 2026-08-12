local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InfoModule = require(ReplicatedStorage.Shared.Info)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local UIFunctions = require(ReplicatedStorage.Shared.UI.UIFunctions)

local PlayerGui = UIConstants.PlayerGui
local Gradients = UIConstants.Gradients

local GUI = PlayerGui:WaitForChild("RuneSelection")
local Main = GUI:WaitForChild("Main")

local RuneList = Main.Content
local Info = Main.Info
local InfoTop = Info.Top
local InfoContent = Info.Content
local ItemName = InfoTop.ItemName
local RuneBase = InfoTop.Base
local EquipButton = Info.Options.Equip

local Templates = ReplicatedStorage.Resources.UI.Templates
local RuneTemplate = Templates.RuneTemplate
local SkillTemplate = Templates.SkillTemplate
local RTemplate = Templates.RTemplate

local RuneSelection = {}

local activeRuneButtons = {}
local selectedMoveset = nil

local function applyRuneGradient(movesetName)
	UIFunctions.ApplyGradientTemplate(RuneBase, Gradients, movesetName)
end

local function applySkillGradient(clone, runeName, customGradient)
	local skillFrame = clone:FindFirstChild("SkillFrame")
	local base = skillFrame and skillFrame:FindFirstChild("Base")
	if not base then
		return
	end

	UIFunctions.ApplyGradientTemplateWithFallback(base, Gradients, customGradient, runeName)
end

local function clearInfoContent()
	for _, child in InfoContent:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
end

local function setSkillIcon(clone, icon)
	if not icon or icon == "" then
		return
	end

	local skillFrame = clone:FindFirstChild("SkillFrame")
	skillFrame.Icon.Image = icon
end

local function addRTemplate(movesetInfo)
	local Special = movesetInfo.SpecialDisplay
	if not Special then
		return
	end

	local clone = RTemplate:Clone()
	clone.SkillName.Text = Special.Name or "Special"
	clone.Desc.Text = Special.Desc or ""
	clone.LayoutOrder = 0
	clone.Parent = InfoContent
end

local function addSkillTemplate(moveName, moveInfo, layoutOrder, runeName)
	local clone = SkillTemplate:Clone()
	clone.SkillName.Text = moveName
	clone.Desc.Text = (moveInfo and moveInfo.Desc) or ""
	setSkillIcon(clone, moveInfo and moveInfo.Icon)
	applySkillGradient(clone, runeName, moveInfo and moveInfo.CustomGradient)
	clone.LayoutOrder = layoutOrder
	clone.Parent = InfoContent
end

local function populateSkills(movesetName, movesetInfo)
	addRTemplate(movesetInfo)

	for moveName, moveInfo in movesetInfo.Moves do
		addSkillTemplate(moveName, moveInfo, 1, movesetName)
	end

	for moveName, moveInfo in movesetInfo.AwakeningMoves do
		addSkillTemplate(moveName, moveInfo, 2, movesetName)
	end
end

local function showInfo(movesetName)
	local movesetInfo = InfoModule.Movesets[movesetName]
	if not movesetInfo then
		return
	end

	selectedMoveset = movesetName

	ItemName.Text = movesetName .. " Rune"
	RuneBase.Icon.Image = movesetInfo.Icon or "rbxassetid://0"
	applyRuneGradient(movesetName)

	clearInfoContent()
	populateSkills(movesetName, movesetInfo)
end

local function addRune(movesetName, movesetInfo)
	local clone = RuneTemplate:Clone()
	clone.RuneName.Text = movesetName .. " Rune"
	clone.Icon.Image = movesetInfo.Icon or "rbxassetid://0"
	clone.LayoutOrder = movesetInfo.Order or 0
	clone.Parent = RuneList

	clone.Activated:Connect(function()
		showInfo(movesetName)
	end)

	table.insert(activeRuneButtons, clone)
end

local function populateRunes()
	for _, button in activeRuneButtons do
		button:Destroy()
	end
	table.clear(activeRuneButtons)

	for movesetName, movesetInfo in InfoModule.Movesets do
		addRune(movesetName, movesetInfo)
	end
end

function RuneSelection.Show()
	GUI.Enabled = true
end

function RuneSelection.Hide()
	GUI.Enabled = false
end

function RuneSelection.Init()
	populateRunes()

	EquipButton.Activated:Connect(function()
		print("Equip Rune pressed for:", selectedMoveset)
	end)
end

return RuneSelection
