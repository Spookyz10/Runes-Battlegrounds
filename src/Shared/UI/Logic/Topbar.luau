local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local Icon = require(ReplicatedStorage.Packages.topbarplus)
local Topbar = {}

local runesIcon = nil

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
	local player = UIConstants.Player
	local playerGui = player:WaitForChild("PlayerGui")

	runesIcon = Icon.new()
	runesIcon:setName("Runes")
	runesIcon:setLabel("Runes")

	runesIcon.selected:Connect(function()
		local runeSelection = playerGui:FindFirstChild("RuneSelection")
		if runeSelection then
			runeSelection.Enabled = true
		end
	end)

	runesIcon.deselected:Connect(function()
		local runeSelection = playerGui:FindFirstChild("RuneSelection")
		if runeSelection then
			runeSelection.Enabled = false
		end
	end)
end

function Topbar.Init()
	local startTick = tick()
	if GuiService.TopbarInset.Max.Y <= 0 then
		while true do
			task.wait()
			if not (tick() - startTick <= 5 and GuiService.TopbarInset.Max.Y <= 0) then
				break
			end
		end
	end

	setupRunesButton()

	local loadedTopBar = Instance.new("BoolValue")
	loadedTopBar.Name = "loadedTopBar"
	loadedTopBar.Value = true
	loadedTopBar.Parent = UIConstants.Player
end

return Topbar
