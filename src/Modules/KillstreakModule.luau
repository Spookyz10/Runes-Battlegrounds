local Players = game:GetService('Players')
local TS = game:GetService('TweenService')
local module = {}

local KillstreakAssets = game.ServerStorage.Assets.Models.Killstreak

function module:AddKillstreak(Character: Model)
	local Player = Players:GetPlayerFromCharacter(Character)
	if not Player then return end

	local HighestStreak = 0
	for _, EnemyCharacter: Model in workspace.Live:GetChildren() do
		if EnemyCharacter == Character then continue end

		local EnemyStreak = EnemyCharacter:GetAttribute('EnemyStreak') or 0

		if EnemyStreak > HighestStreak then
			HighestStreak = EnemyStreak
		end
	end

	if (Character:GetAttribute('Streak') or 0) >= HighestStreak then
		for _, EnemyCharacter: Model in workspace.Live:GetChildren() do
			module:RemoveKillstreak(EnemyCharacter)
		end

		Character:AddTag('HighestStreak')

		local Gui = KillstreakAssets.KillstreakGui:Clone()
		local streakImage = Gui.Frame.ImageLabel
		local streakText = Gui.Frame.TextLabel
		Gui.Parent = Character.Head

		local Highlight = KillstreakAssets.KillstreakHL:Clone()
		Highlight.Parent = Character

		local C, C2, C3
		C = Character:GetAttributeChangedSignal('Streak'):Connect(function()
			Gui.Frame.TextLabel.Text = tostring(Character:GetAttribute('Streak'))

			local currentStreak = Character:GetAttribute('Streak')
			local newColor
			if currentStreak > 10 and currentStreak <= 100 then
				newColor = 255 - (25.5 * (currentStreak/10))

				TS:Create(Highlight, TweenInfo.new(.5), { OutlineColor = Color3.fromRGB(255, newColor, 0) }):Play()
				TS:Create(streakImage, TweenInfo.new(.5), { ImageColor3 = Color3.fromRGB(255, newColor, newColor) }):Play()
				TS:Create(streakText, TweenInfo.new(.5), { TextColor3 = Color3.fromRGB(255, newColor, 0) }):Play()
			elseif currentStreak <= 10 then
				newColor = 255
			else
				newColor = 0
			end

			TS:Create(Highlight, TweenInfo.new(.5), { OutlineColor = Color3.fromRGB(255, newColor, 0) }):Play()
			TS:Create(streakImage, TweenInfo.new(.5), { ImageColor3 = Color3.fromRGB(255, newColor, newColor) }):Play()
			TS:Create(streakText, TweenInfo.new(.5), { TextColor3 = Color3.fromRGB(255, newColor, 0) }):Play()
		end)

		Gui.Frame.TextLabel.Text = tostring(Character:GetAttribute('Streak'))

		C2 = Character:GetPropertyChangedSignal('Parent'):Connect(function()
			if Character.Parent == nil then
				C:Disconnect()
				C2:Disconnect()
				C3:Disconnect()
			end
		end)


		if Player:GetAttribute("HasVIP") and Player:GetAttribute("Hide_Killstreak") then
			Gui.Enabled = false
			Highlight.Enabled = false
		end

		C3 = Player:GetAttributeChangedSignal("Hide_Killstreak"):Connect(function()
			if not Player:GetAttribute("HasVIP") or not Player or not Player.Parent or not Character or not Character.Parent or not Gui or not Gui.Parent or not Highlight or not Highlight.Parent then
				return C3:Disconnect()
			end

			if Player:GetAttribute("Hide_Killstreak") then
				Gui.Enabled = false
				Highlight.Enabled = false
			else
				Gui.Enabled = true
				Highlight.Enabled = true
			end
		end)
	end
end

function module:RemoveKillstreak(Character: Model)
	Character:RemoveTag('HighestStreak')

	local Gui = Character.Head:FindFirstChild('KillstreakGui')
	if Gui then
		Gui:Destroy()
	end

	local Highlight = Character:FindFirstChild('KillstreakHL')
	if Highlight then
		Highlight:Destroy()
	end
end

return module
