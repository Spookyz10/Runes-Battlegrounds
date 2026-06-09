local nextCast = 0
local glc = 8

game.ReplicatedStorage.Remotes.Replication.OnServerEvent:Connect(function(p, data)

	if tick() < nextCast then return end
	nextCast = tick() + glc

	require(script[data.Request])(p)

end)

game.Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function(c, Player:Player)
	
		for _, tool in ipairs(script:GetChildren()) do
			if tool:IsA("ModuleScript") then
				
				local toolexample = game.ServerStorage.Tool:Clone()
				toolexample.Name = tool.Name
				toolexample.Parent = p.Backpack
			end
		end
	end)
end)
