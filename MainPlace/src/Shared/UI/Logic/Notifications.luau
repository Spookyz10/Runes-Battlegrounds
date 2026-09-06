local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Notifications = {}

function Notifications.Init()
	task.spawn(function()
		local gui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Notifications", 15)

		if not gui then
			warn("Generate Notifications in StarterGui using tools/GenerateNotificationUI.luau.")
			return
		end

		gui.Enabled = false
		gui.Templates.Toast.Visible = false
		local active = {}
		local sequence = 0
		local remote =
			ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Client"):WaitForChild("Notification")
		remote.OnClientEvent:Connect(function(payload)
			if typeof(payload) ~= "table" or typeof(payload.Message) ~= "string" then
				return
			end

			if typeof(payload.ReplaceKey) == "string" then
				for index = #active, 1, -1 do
					if active[index]:GetAttribute("ReplaceKey") == payload.ReplaceKey then
						table.remove(active, index):Destroy()
					end
				end
			end

			if #active >= 3 then
				table.remove(active, 1):Destroy()
			end

			sequence += 1
			local toast = gui.Templates.Toast:Clone()
			toast:SetAttribute("ReplaceKey", payload.ReplaceKey)
			local success = payload.Success == true
			local color = if success then Color3.fromRGB(103, 231, 157) else Color3.fromRGB(255, 110, 123)
			toast.BackgroundColor3 = if success
				then Color3.fromRGB(24, 42, 34)
				else Color3.fromRGB(48, 26, 33)
			toast.Title.Text = payload.Title or (if success then "SUCCESS" else "PURCHASE FAILED")
			toast.Title.TextColor3 = color
			toast.Stroke.Color = color
			toast.Lifetime.BackgroundColor3 = color
			toast.Message.Text = payload.Message
			toast.Message.MaxVisibleGraphemes = 0
			toast.LayoutOrder = sequence
			toast.GroupTransparency = 1
			toast.Parent = gui.Stack
			toast.Visible = true
			gui.Enabled = true
			table.insert(active, toast)
			TweenService:Create(toast, TweenInfo.new(0.2), { GroupTransparency = 0 }):Play()
			local closed = false

			local function dismiss()
				if closed or not toast.Parent then
					return
				end

				closed = true
				local tween = TweenService:Create(toast, TweenInfo.new(0.2), { GroupTransparency = 1 })
				tween:Play()
				tween.Completed:Once(function()
					local index = table.find(active, toast)

					if index then
						table.remove(active, index)
					end

					toast:Destroy()
					gui.Enabled = #active > 0
				end)
			end

			toast.Close.Activated:Connect(dismiss)
			task.spawn(function()
				local count = 0

				for _ in utf8.graphemes(payload.Message) do
					count += 1
				end

				local started = os.clock()

				while not closed and toast.Parent do
					local visible = if payload.Instant
						then count
						else math.min(count, math.floor((os.clock() - started) * 45))
					toast.Message.MaxVisibleGraphemes = visible

					if visible >= count then
						break
					end

					task.wait()
				end

				if closed or not toast.Parent then
					return
				end

				TweenService:Create(
					toast.Lifetime,
					TweenInfo.new(4.5, Enum.EasingStyle.Linear),
					{ Size = UDim2.fromScale(0, 0.03) }
				):Play()
				task.delay(4.5, dismiss)
			end)
		end)
	end)
end

return Notifications
