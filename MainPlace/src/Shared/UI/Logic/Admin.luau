local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local Access = require(ReplicatedStorage.Shared.AdminAccess)
local Remote = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local Window = require(ReplicatedStorage.Shared.UI.Window)

local Admin = {}

function Admin.Init()
	task.spawn(function()
		local gui = UIConstants.PlayerGui:WaitForChild("Admin", 15)

		if not gui then
			return
		end

		if not Access[UIConstants.Player.UserId] then
			gui:Destroy()
			return
		end

		Window.Bind(gui)
		local main = gui.Main
		local selected = "Gold"
		local scope = "Local"
		local busy = false
		local confirmation
		local help = {
			Gold = { "Gold amount", "Adds gold to the target's saved balance." },
			Cosmetic = { "Cosmetic ID: Crown", "Cosmetic IDs are case-sensitive. Crown is available." },
			Aura = { "Aura ID: VIP", "Aura IDs are case-sensitive. VIP is available." },
			Skin = { "Future skin ID", "Records ownership only; rune skin equipment is not implemented yet." },
			Gamepass = {
				"Gamepass ID",
				"VIP: 1951766560 | Early Access: 1947440899 | Kill Sound: 1948965802",
			},
			Kick = { "Not used", "Removes the target from their current server. Expires after 60 seconds." },
			Ban = { "Days, or -1 for permanent", "Bans across the experience. A reason is required." },
			Unban = { "Not used", "Removes an experience-wide ban." },
		}

		local function resetConfirmation()
			confirmation = nil
			main.Execute.Text = "Send command"
		end

		local function select(action)
			selected = action
			resetConfirmation()
			main.Value.Text = ""
			main.Value.PlaceholderText = help[action][1]
			main.Help.Text = help[action][2]

			for name in help do
				main[name].BackgroundColor3 = if name == action
					then Color3.fromRGB(128, 104, 231)
					else Color3.fromRGB(40, 40, 57)
			end
		end

		for name in help do
			main[name].Activated:Connect(function()
				select(name)
			end)
		end

		for _, field in { main.Target, main.Value, main.Reason } do
			field:GetPropertyChangedSignal("Text"):Connect(resetConfirmation)
		end

		local function send(action)
			if busy then
				return
			end

			busy = true
			main.Status.Text = "Sending command..."
			local ok, response = pcall(Remote.InvokeServer, "Admin", {
				Action = action,
				Target = main.Target.Text,
				Value = main.Value.Text,
				Reason = main.Reason.Text,
				Scope = scope,
			})
			busy = false
			resetConfirmation()
			local success = ok and typeof(response) == "table" and response.Success
			main.Status.Text = if ok and typeof(response) == "table"
				then response.Message
				else "No response. Check server output."
			main.Status.TextColor3 = if success
				then Color3.fromRGB(103, 231, 157)
				else Color3.fromRGB(255, 110, 123)
		end

		main.Execute.Activated:Connect(function()
			if selected == "Ban" or selected == "Kick" then
				if confirmation ~= selected then
					confirmation = selected
					main.Execute.Text = "Confirm " .. selected
					main.Status.Text = selected
						.. " target: "
						.. main.Target.Text
						.. ". Click again to confirm."
					return
				end
			end

			send(selected)
		end)

		main.Scope.Activated:Connect(function()
			scope = if scope == "Local" then "Global" else "Local"
			main.Scope.Text = if scope == "Local" then "This server" else "All servers"
		end)

		main.StartDisaster.Activated:Connect(function()
			send("Disaster")
		end)

		main.StopDisaster.Activated:Connect(function()
			send("StopDisaster")
		end)

		select("Gold")
	end)
end

return Admin
