local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local Icon = require(ReplicatedStorage.Packages.topbarplus)
local Topbar = {}

local MainIcon = Icon.new()
local StoreIcon = Icon.new()
local LogIcon = Icon.new()

function Topbar.Show()
	if MainIcon then
		MainIcon:setEnabled(true)
	end
	if StoreIcon then
		StoreIcon:setEnabled(true)
	end
	if LogIcon then
		LogIcon:setEnabled(true)
	end
end

function Topbar.Hide()
	if MainIcon then
		MainIcon:setEnabled(false)
	end
	if StoreIcon then
		StoreIcon:setEnabled(false)
	end
	if LogIcon then
		LogIcon:setEnabled(false)
	end
end

function Topbar.Init()
	local playerGui = UIConstants.PlayerGui

	MainIcon:setLabel("Runes")
	local runeSelection = playerGui:FindFirstChild("RuneSelection")
	MainIcon:bindToggleItem(runeSelection)

	StoreIcon:setLabel("Store")
	local store = playerGui:FindFirstChild("Store")
	StoreIcon:bindToggleItem(store)

	LogIcon:setLabel("Updates")
	local log = playerGui:FindFirstChild("Log")
	LogIcon:bindToggleItem(log)

	local loadedTopBar = Instance.new("BoolValue")
	loadedTopBar.Name = "loadedTopBar"
	loadedTopBar.Value = true
	loadedTopBar.Parent = UIConstants.Player
end

return Topbar
