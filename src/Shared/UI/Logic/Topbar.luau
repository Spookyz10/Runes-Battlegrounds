local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

local RPModules = ReplicatedStorage.Shared.Modules
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)

local Topbar = {}

local IconController = nil

function Topbar.Show()
	if IconController then
		IconController.setTopbarEnabled(true)
	end
end

function Topbar.Hide()
	if IconController then
		IconController.setTopbarEnabled(false)
	end
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

	local IconModule = RPModules["NewIcon"]
	IconController = require(IconModule.IconController)

	local loadedTopBar = Instance.new("BoolValue")
	loadedTopBar.Name = "loadedTopBar"
	loadedTopBar.Value = true
	loadedTopBar.Parent = UIConstants.Player
end

return Topbar
