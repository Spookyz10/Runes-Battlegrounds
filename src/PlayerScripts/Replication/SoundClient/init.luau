local module = {}

return(function()
	local debris = game:GetService("Debris")
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local players = game:GetService("Players")

	local meta = require(script:WaitForChild("meta"))
	local listeningTo = {}

	local defaultWalkSpeed = 16
	local camera = workspace.CurrentCamera

	local function getDistance(p1, p2)
		return ((typeof(p1) == "Instance" and p1.Position or p1) - (typeof(p2) == "Instance" and p2.Position or p2)).magnitude
	end

	local function isOccluded(v3)
		local p = RaycastParams.new()
		p.FilterDescendantsInstances = {workspace.Map}
		p.FilterType = Enum.RaycastFilterType.Exclude
		return workspace:Raycast(camera.CFrame.Position, (v3 - camera.CFrame.Position).unit * ((getDistance(camera.CFrame.Position, v3) * 0.95)), p)
	end

	local function isInDoor(v3)
		local p = RaycastParams.new()
		p.FilterDescendantsInstances = {workspace.Map}
		p.FilterType = Enum.RaycastFilterType.Exclude

		local inDoor = false
		local c = workspace:Raycast(camera.CFrame.Position, Vector3.new(0, 100, 0), p)
		if c and c.Instance.Size.magnitude > 10 then
			return c
		end

		return inDoor
	end

	local function tableContains(tbl, val)
		for i = 1, #tbl do
			if val == tbl[i] then
				return true
			end
		end
		return false
	end

	local function removeValue(tbl, val)
		for i = 1, #tbl do
			if val == tbl[i] then
				table.remove(tbl, i)
				return
			end
		end
	end

	local function playSound(s, parent, pitch, vol, self)
		local sound = typeof(s) == "Instance" and s:Clone() or Instance.new("Sound")
		if typeof(s) ~= "Instance" then
			sound.SoundId = s
		end
		sound.RollOffMinDistance = 0.5 * (not self and 13.5 or 6.5)
		sound.RollOffMode = Enum.RollOffMode.Inverse
		sound.RollOffMaxDistance = 500
		sound.Volume = 0.4
		sound.Pitch = pitch or 1
		sound.Name = "footstepSound"
		sound.Parent = parent
		sound:Play()
		debris:AddItem(sound, 1)

		if sound.Parent:IsDescendantOf(workspace) and (sound.Parent:IsA("BasePart") or sound.Parent:IsA("Attachment")) then
			
		end

		return sound
	end

	local function listenToHumanoid(player, humanoid)
		if humanoid:GetAttribute("RegisteredClient") == true then
			return
		end
		humanoid:SetAttribute("RegisteredClient", true)
		
		if tableContains(listeningTo, humanoid) then
			
		end

		listeningTo[#listeningTo + 1] = humanoid
		local camera = workspace.CurrentCamera
		local connection
		local latest = tick()
		local update = tick()
		local climbing = false
		local swimming = false
		local lastMaterial = Enum.Material.Concrete
		local footstepsEmitPoint = Instance.new("Attachment")
		footstepsEmitPoint.Position = Vector3.new(0, -3, 0)
		footstepsEmitPoint.Name = "FootstepsEmitPoint"
		footstepsEmitPoint.Parent = humanoid.Parent:WaitForChild("Torso", math.huge)

		local generate = function(play, type)
			local params = RaycastParams.new()
			params.FilterDescendantsInstances = {humanoid.Parent, workspace.CurrentCamera, workspace.Thrown}
			local ray = workspace:Raycast(humanoid.RootPart.Position, Vector3.new(0, play and -5 or -3.5, 0), params)
			if (ray or climbing or swimming) and (ray and ray.Instance.Velocity.magnitude < 1 or tick() - update > 0.35 or play) then
				update = tick()
				local material = climbing and Enum.Material.ForceField or swimming and Enum.Material.Water or ray.Material
				local soundList = meta:GetSoundsForMaterial(type == "climbing" and lastMaterial or material, type)
				if soundList and #soundList:GetChildren() > 0 then
					local sound = soundList:GetChildren()[math.random(#soundList:GetChildren())]
					playSound(sound, footstepsEmitPoint, climbing and 1.25 + math.random() * 0.15 or nil, sound.Volume, player == players.LocalPlayer)

					lastMaterial = material
				end
			end
		end


		humanoid.StateChanged:Connect(function(prev, current)
			if current == Enum.HumanoidStateType.Jumping then
				shared.sfx({
					SoundId = "rbxassetid://7005105940",
					RollOffMaxDistance = 45,
					RollOffMinDistance = 6,
					Volume = 0.35,
					Parent = humanoid.RootPart
				}):Play()
			end
			if current == Enum.HumanoidStateType.Landed then
				shared.sfx({
					SoundId = "rbxassetid://7005105964",
					RollOffMaxDistance = 45,
					RollOffMinDistance = 6,
					Volume = 0.35,
					Parent = humanoid.RootPart
				}):Play()
			end
			
			if current == Enum.HumanoidStateType.Climbing then
			end

			climbing = current == Enum.HumanoidStateType.Climbing
			swimming = current == Enum.HumanoidStateType.Swimming
		end)

		if player ~= players.LocalPlayer then
			humanoid:GetAttributeChangedSignal("StateCurrent"):Connect(function()
				local current = humanoid:GetAttribute("StateCurrent")
				local prev = humanoid:GetAttribute("StatePrevious")

				
			end)
		end

		connection = game:GetService("RunService").RenderStepped:Connect(function()
			if not humanoid or not humanoid:IsDescendantOf(workspace) or not humanoid.RootPart or humanoid.Health <= 0 then
				--warn("desynchronized sound-stepping from character instance " .. player.Name)
				removeValue(listeningTo, humanoid)
				connection:Disconnect()
				return
			end

			if humanoid:GetState() == Enum.HumanoidStateType.Seated then return end

			local distanceFromCamera = camera.CFrame.Position - humanoid.RootPart.Position
			local calculateDistance = math.min(distanceFromCamera.magnitude / 5000, 0.35)
			local linearVelocity = Vector3.new(humanoid.RootPart.AssemblyLinearVelocity.x, 0, humanoid.RootPart.AssemblyLinearVelocity.z)
			if climbing then
				linearVelocity = Vector3.new(0, humanoid.RootPart.AssemblyLinearVelocity.y * 2, 0)
			end
			local wt = (1 / 2.15) * defaultWalkSpeed / (linearVelocity.magnitude + 0.5)
			if calculateDistance < 0.1 then
				calculateDistance = 0
			end
			if tick() - latest > math.max(wt + calculateDistance, 0.15) and distanceFromCamera.magnitude < 500 then
				latest = tick()
			else
				return
			end

			if linearVelocity.magnitude > 1 or not players:GetPlayerFromCharacter(humanoid.Parent) then
				generate(nil, linearVelocity.magnitude > 1 and "MoveSounds")
			end
		end)
	end

	local function prepareListener(player)
		local setup = function(player)
			local character = player.Character or player.CharacterAdded:Wait()
			local humanoid = character:WaitForChild("Humanoid")
			listenToHumanoid(player, humanoid)
		end

		task.wait(1)
		setup(player)
		player.CharacterAdded:Connect(function() task.wait(1) setup(player) end)
	end

	players.PlayerAdded:Connect(prepareListener)
	for _,player in pairs(players:GetChildren()) do
		prepareListener(player)
	end
	
	script:Destroy()
end)

