local UserInputService = game:GetService("UserInputService")

local Window = {}

function Window.Bind(gui)
	gui.Main.Close.Activated:Connect(function()
		gui.Enabled = false
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if
			not processed
			and gui.Enabled
			and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB)
		then
			gui.Enabled = false
		end
	end)
end

return Window
