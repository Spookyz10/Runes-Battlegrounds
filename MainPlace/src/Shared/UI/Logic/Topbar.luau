local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local Data = require(ReplicatedStorage.Shared.Data).client
local KillSoundPass = require(ReplicatedStorage.Shared.KillSoundPass)
local Icon = require(ReplicatedStorage.Packages.topbarplus)

local Topbar = {}
local visible = true
local entries = {
	{ Name = "RuneSelection", Image = 74892251016594 },
	{ Name = "Shop", Image = 83529893577215 },
	{ Name = "Log", Image = 73951345498778 },
	{ Name = "KillSound", Image = 107213877689577 },
	{ Name = "Cosmetics", Image = 95816009699835 },
}

if require(ReplicatedStorage.Shared.AdminAccess)[UIConstants.Player.UserId] then
	table.insert(entries, { Name = "Admin", Label = "Admin" })
end

for _, entry in entries do
	entry.Icon = Icon.new():setImage(entry.Image):setImageScale(1):setEnabled(false)

	if entry.Label then
		entry.Icon:setLabel(entry.Label)
	end
end

local function refresh()
	for _, entry in entries do
		local allowed = entry.Name ~= "KillSound" or table.find(Data.OwnedPasses(), KillSoundPass.GamepassId) ~= nil
		entry.Icon:setEnabled(visible and entry.Gui ~= nil and allowed)
	end
end

function Topbar.Show()
	visible = true
	refresh()
end

function Topbar.Hide()
	visible = false

	for _, entry in entries do
		entry.Icon:deselect()

		if entry.Gui then
			entry.Gui.Enabled = false
		end
	end

	refresh()
end

function Topbar.Init()
	for _, entry in entries do
		task.spawn(function()
			local gui = UIConstants.PlayerGui:WaitForChild(entry.Name, 15)

			if not gui then
				return
			end

			entry.Gui = gui
			entry.Icon:bindToggleItem(gui)

			local function sync()
				if gui.Enabled then
					entry.Icon:select()

					for _, other in entries do
						if other ~= entry and other.Gui then
							other.Gui.Enabled = false
							other.Icon:deselect()
						end
					end
				else
					entry.Icon:deselect()
				end
			end

			gui:GetPropertyChangedSignal("Enabled"):Connect(sync)
			sync()
			refresh()
		end)
	end

	Data.OwnedPasses.Changed(refresh)
	local loaded = UIConstants.Player:FindFirstChild("loadedTopBar") or Instance.new("BoolValue")
	loaded.Name = "loadedTopBar"
	loaded.Value = true
	loaded.Parent = UIConstants.Player
end

return Topbar
