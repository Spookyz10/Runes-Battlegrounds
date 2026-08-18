local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local Data = require(ReplicatedStorage.Shared.Data).client
local KillSoundPass = require(ReplicatedStorage.Shared.KillSoundPass)

local Icon = require(ReplicatedStorage.Packages.topbarplus)
local Topbar = {}

local MainIcon = Icon.new()
local StoreIcon = Icon.new()
local LogIcon = Icon.new()
local KillSoundIcon = Icon.new()

local function ownsKillSound()
	return table.find(Data.OwnedPasses(), KillSoundPass.GamepassId) ~= nil
end

local function refreshKillSoundIcon()
	KillSoundIcon:setEnabled(ownsKillSound())
end

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

	refreshKillSoundIcon()
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
	if KillSoundIcon then
		KillSoundIcon:setEnabled(false)
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

	KillSoundIcon:setLabel("Kill Sound")
	local killSound = playerGui:FindFirstChild("KillSound")
	KillSoundIcon:bindToggleItem(killSound)

	refreshKillSoundIcon()
	Data.OwnedPasses.Changed(function()
		refreshKillSoundIcon()
	end)

	local loadedTopBar = Instance.new("BoolValue")
	loadedTopBar.Name = "loadedTopBar"
	loadedTopBar.Value = true
	loadedTopBar.Parent = UIConstants.Player
end

return Topbar
