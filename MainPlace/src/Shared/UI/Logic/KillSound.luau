local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Shared.Data).client
local UIConstants = require(ReplicatedStorage.Shared.UI.UIConstants)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local Window = require(ReplicatedStorage.Shared.UI.Window)

local KillSound = {}

function KillSound.Init()
	task.spawn(function()
		local gui = UIConstants.PlayerGui:WaitForChild("KillSound", 15)

		if not gui then
			return
		end

		Window.Bind(gui)
		local main = gui.Main
		local sound = gui.PreviewSound
		local busy = false
		local previewToken = 0

		local function feedback(success, message)
			main.Feedback.Text = message
			main.Feedback.TextColor3 = if success
				then Color3.fromRGB(103, 231, 157)
				else Color3.fromRGB(255, 110, 123)
		end

		local function getId()
			local id = tonumber(main.SoundBox.Text:match("%d+"))

			return if id and id > 0 and id % 1 == 0 and id < 2 ^ 53 then id else nil
		end

		local function refresh()
			main.SoundBox.Text = tostring(Data.KillSoundId() or "")
		end

		local function stop()
			previewToken += 1
			sound:Stop()
			main.Preview.Text = "Preview"
		end

		main.Preview.Activated:Connect(function()
			if main.Preview.Text == "Stop" then
				stop()
				return
			end

			local id = getId()

			if not id then
				feedback(false, "Enter a valid audio ID.")
				return
			end

			stop()
			local token = previewToken
			sound.SoundId = "rbxassetid://" .. tostring(id)
			sound:Play()
			main.Preview.Text = "Stop"
			feedback(true, "Previewing audio...")
			task.delay(3, function()
				if previewToken == token and not sound.IsLoaded then
					feedback(false, "Audio unavailable or still loading. Check its permissions.")
				end
			end)

			task.delay(10, function()
				if previewToken == token then
					stop()
				end
			end)
		end)

		sound.Ended:Connect(stop)
		gui:GetPropertyChangedSignal("Enabled"):Connect(function()
			if not gui.Enabled then
				stop()
			end
		end)

		local function submit()
			if busy then
				return
			end

			local id = getId()

			if not id then
				feedback(false, "Enter a valid audio ID.")
				return
			end

			busy = true
			main.Submit.Text = "Saving..."
			main.Submit.Active = false
			local ok, result = pcall(RemoteManager.InvokeServer, "KillSound", "SetSoundId", { SoundId = id })
			busy = false
			main.Submit.Text = "Save sound"
			main.Submit.Active = true

			if not ok or typeof(result) ~= "table" then
				feedback(false, "Could not save. Please try again.")
				return
			end

			feedback(result.Success == true, result.Message or "Could not save this sound.")

			if result.Success then
				refresh()
			end
		end

		main.Submit.Activated:Connect(submit)
		main.SoundBox.FocusLost:Connect(function(enter)
			if enter then
				submit()
			end
		end)

		Data.KillSoundId.Changed(refresh)
		refresh()
	end)
end

return KillSound
