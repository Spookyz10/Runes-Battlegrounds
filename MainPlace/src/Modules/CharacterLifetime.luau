local Players = game:GetService("Players")

local CharacterLifetime = {}

function CharacterLifetime.Watch(character, callback)
	local connections = {}
	local active = true
	local function disconnect()
		active = false
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
	end
	local function finish()
		if not active then
			return
		end
		disconnect()
		callback()
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		table.insert(connections, humanoid.Died:Connect(finish))
		table.insert(connections, humanoid.Destroying:Connect(finish))
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	table.insert(connections, character.ChildRemoved:Connect(function(child)
		if child == humanoid or child == root then
			finish()
		end
	end))
	table.insert(connections, character.Destroying:Connect(finish))
	table.insert(connections, character.AncestryChanged:Connect(function()
		if not character:IsDescendantOf(workspace) then
			finish()
		end
	end))
	local player = Players:GetPlayerFromCharacter(character)
	if player then
		table.insert(connections, player.CharacterRemoving:Connect(function(removingCharacter)
			if removingCharacter == character then
				finish()
			end
		end))
		table.insert(connections, Players.PlayerRemoving:Connect(function(leavingPlayer)
			if leavingPlayer == player then
				finish()
			end
		end))
	end
	if not character:IsDescendantOf(workspace) or (humanoid and humanoid.Health <= 0) then
		task.defer(finish)
	end
	return disconnect
end

return CharacterLifetime
