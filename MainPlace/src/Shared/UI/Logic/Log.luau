local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LogInfo = require(ReplicatedStorage.Shared.Info.Log)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local PlayerGui = UIConstants.PlayerGui

local GUI = PlayerGui:WaitForChild("Log")
local Main = GUI:WaitForChild("Main")
local Container = Main:WaitForChild("Container")
local Swap = Main:WaitForChild("Swap")
local Title = Main:WaitForChild("Title")
local TitleLabel = Title:WaitForChild("TextLabel")

local LabelTemplate = ReplicatedStorage.Resources.UI.Templates.LabelTemplate

local Log = {}

local activeLabels = {}
local currentMode = "Update"

local function clearContainer()
	for _, label in activeLabels do
		label:Destroy()
	end
	table.clear(activeLabels)
end

local function populate(lines)
	clearContainer()

	for _, text in lines do
		local clone = LabelTemplate:Clone()
		clone.Text = text
		clone.Parent = Container
		table.insert(activeLabels, clone)
	end
end

local function showUpdate()
	currentMode = "Update"
	TitleLabel.Text = LogInfo.Version
	populate(LogInfo.UpdateLog)
end

local function showRoadmap()
	currentMode = "Roadmap"
	TitleLabel.Text = "Roadmap"
	populate(LogInfo.Roadmap)
end

function Log.Show()
	GUI.Enabled = true
end

function Log.Hide()
	GUI.Enabled = false
end

function Log.Init()
	Swap.Update.Activated:Connect(showUpdate)
	Swap.Roaadmap.Activated:Connect(showRoadmap)

	showUpdate()
end

return Log
