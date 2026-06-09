local TS = game:GetService('TweenService')

return function(Att: Attachment, State: boolean)
	for _, Player: Player in game.Players:GetPlayers() do
		local AwakeningMusicConfig: BoolValue = Player:FindFirstChild('Configuration'):FindFirstChild('Awakening Music')
		
		if not AwakeningMusicConfig then continue end
		
		if State == true then
			if AwakeningMusicConfig.Value == true then
				for _, Sound: Sound in Att:GetDescendants() do
					if Sound:IsA('Sound') then
						TS:Create(Sound, TweenInfo.new(1, Enum.EasingStyle.Linear), { Volume = Sound:GetAttribute('Volume') or 1 }):Play()
					end
				end
			end
		else
			for _, Sound: Sound in Att:GetDescendants() do
				if Sound:IsA('Sound') then
					Sound:SetAttribute('Volume', Sound.Volume)
					TS:Create(Sound, TweenInfo.new(1, Enum.EasingStyle.Linear), { Volume = 0 }):Play()
				end
			end
		end
	end
end