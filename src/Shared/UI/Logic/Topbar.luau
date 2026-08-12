local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local Icon = require(ReplicatedStorage.Packages.topbarplus)
local Topbar = {}

local runesIcon = Icon.new()

function Topbar.Show()
	if runesIcon then
		runesIcon:setEnabled(true)
	end
end

function Topbar.Hide()
	if runesIcon then
		runesIcon:setEnabled(false)
	end
end

local function setupRunesButton()
	local playerGui = UIConstants.PlayerGui

	runesIcon:setLabel("Runes")
	local runeSelection = playerGui:FindFirstChild("RuneSelection")

	runesIcon:bindToggleItem(runeSelection)
end

function Topbar.Init()
	setupRunesButton()

	local loadedTopBar = Instance.new("BoolValue")
	loadedTopBar.Name = "loadedTopBar"
	loadedTopBar.Value = true
	loadedTopBar.Parent = UIConstants.Player
end

return Topbar
