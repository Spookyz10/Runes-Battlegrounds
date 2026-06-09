local ts = game.TweenService

return function(Day)
	if Day == true then
		ts:Create(workspace.Terrain.Clouds, TweenInfo.new(1, Enum.EasingStyle.Linear), { Color = Color3.fromRGB(255, 255, 255) }):Play()
		ts:Create(game.Lighting, TweenInfo.new(1, Enum.EasingStyle.Linear), { ClockTime = 12.302 }):Play()
		
		game.Lighting:SetAttribute("PauseDayNightCycle", false)
		
	else
		ts:Create(workspace.Terrain.Clouds, TweenInfo.new(1, Enum.EasingStyle.Linear), { Color = Color3.fromRGB(50, 50, 50) }):Play()
		ts:Create(game.Lighting, TweenInfo.new(1, Enum.EasingStyle.Linear), { ClockTime = 0 }):Play()
		
		game.Lighting:SetAttribute("PauseDayNightCycle", true)
	end
end