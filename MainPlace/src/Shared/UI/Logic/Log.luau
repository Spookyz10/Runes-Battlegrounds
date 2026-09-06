local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Info = require(ReplicatedStorage.Shared.Info.Log)
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local Window = require(ReplicatedStorage.Shared.UI.Window)

local Log = {}
local gui

function Log.Show()
	if gui then
		gui.Enabled = true
	end
end

function Log.Hide()
	if gui then
		gui.Enabled = false
	end
end

function Log.Init()
	task.spawn(function()
		gui = UIConstants.PlayerGui:WaitForChild("Log", 15)

		if not gui then
			return
		end

		Window.Bind(gui)
		local rows = {}

		local function show(mode)
			for _, row in rows do
				row:Destroy()
			end

			table.clear(rows)
			local update = mode == "Update"
			gui.Main.Version.Text = if update then Info.Version else "ON THE HORIZON"
			gui.Main.Title.Text = if update then "What is new" else "Looking ahead"

			for _, name in { "Update", "Roadmap" } do
				gui.Main[name].BackgroundColor3 = if name == mode
					then Color3.fromRGB(128, 104, 231)
					else Color3.fromRGB(40, 40, 57)
			end

			for index, text in (if update then Info.UpdateLog else Info.Roadmap) do
				local row = gui.Templates.Entry:Clone()
				row.Number.Text = string.format("%02d", index)
				row.Body.Text = text
				row.LayoutOrder = index
				row.Visible = true
				row.Parent = gui.Main.Content
				table.insert(rows, row)
			end

			gui.Main.Content.CanvasPosition = Vector2.zero
		end

		gui.Main.Update.Activated:Connect(function()
			show("Update")
		end)

		gui.Main.Roadmap.Activated:Connect(function()
			show("Roadmap")
		end)

		show("Update")
	end)
end

return Log
