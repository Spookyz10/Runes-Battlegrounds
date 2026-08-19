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
local CosmeticsIcon = Icon.new()

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
	if CosmeticsIcon then
		CosmeticsIcon:setEnabled(true)
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
	if CosmeticsIcon then
		CosmeticsIcon:setEnabled(false)
	end
	if KillSoundIcon then
		KillSoundIcon:setEnabled(false)
	end
end

function Topbar.Init()
	local playerGui = UIConstants.PlayerGui

	MainIcon:setImage(122632838025101)
	local runeSelection = playerGui:FindFirstChild("RuneSelection")
	MainIcon:bindToggleItem(runeSelection)

	StoreIcon:setImage(80569266368262)
	local store = playerGui:FindFirstChild("Store")
	StoreIcon:bindToggleItem(store)

	LogIcon:setImage(138183057333957)
	local log = playerGui:FindFirstChild("Log")
	LogIcon:bindToggleItem(log)

	KillSoundIcon:setImage(127836770551816)
	local killSound = playerGui:FindFirstChild("KillSound")
	KillSoundIcon:bindToggleItem(killSound)

	CosmeticsIcon:setImage(87583203080314)
	local cosmetics = playerGui:FindFirstChild("Cosmetics")
	CosmeticsIcon:bindToggleItem(cosmetics)

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
