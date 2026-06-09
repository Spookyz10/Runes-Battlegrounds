local FriendId = nil

return(function(Player : Players)
	local Success, FriendPages = pcall(game:GetService("Players").GetFriendsAsync, game:GetService("Players"), Player.UserId)
	local Character: Model = Player.Character
	local Humanoid = Character:FindFirstChild("Humanoid")
	local Animator: Animator = Humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", Humanoid)
	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	
	HumanoidRootPart.Anchored = true

	local Animation = {
		[1] = Humanoid:LoadAnimation(game.ReplicatedStorage.Persist["Railgun"]["RailgunAnim"].User)
	}

	Animation[1]:Play()

	if Success and FriendPages then
		
		local Friends = {}
		
		while true do
			
			for _, Friend in FriendPages:GetCurrentPage() do
				table.insert(Friends, Friend.Id)
			end
			
			if FriendPages.IsFinished then
				break
			end
			
			pcall(FriendPages.AdvanceToNextPageAsync, FriendPages)
			
		end
		
		if #Friends > 0 then
			FriendId = Friends[math.random(1, #Friends)]
		end
	end
	
	local SFX = game.ReplicatedStorage.Persist.Railgun.SFX:Clone()
	SFX.Name = "railgunsfx"
	SFX.Parent = Character
	SFX:Play()

	game:GetService("Debris"):AddItem(SFX, 13)

	game:GetService("ReplicatedStorage").Remotes.Replication:FireAllClients({
		Request = "Railgun",
		Char = Character,
		Friend = FriendId and {Id = FriendId} or nil
	})
	
	Animation[1].Ended:Connect(function()
		
		HumanoidRootPart.Anchored = false
		
	end)
end)