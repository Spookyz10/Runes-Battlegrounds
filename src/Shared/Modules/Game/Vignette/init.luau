local TS = game:GetService("TweenService")
local Players = game:GetService("Players")

local Presets = require(script.Presets)
local Vignette = Players.LocalPlayer.PlayerGui:WaitForChild("Vignette")


return function(Color, Transparency, Tween, Small)
	local Screen = Small and Vignette.SmallPulse or Vignette.Pulse
	Screen.ImageColor3 = Color
	Screen.ImageTransparency = Transparency
	
	TS:Create(Screen, TweenInfo.new(Tween or 1), {
        ImageTransparency = 1
    }):Play()
end