local Players = game:GetService('Players')
local cameraMode = "Freecam"
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local SelectionBG = nil


local Player = Players.LocalPlayer
local Character = Player.Character
Player:GetPropertyChangedSignal("Character"):Connect(function()
	Character = Player.Character or Player.CharacterAdded:Wait()
end)

local ShiftlockConnection: RBXScriptConnection


local camera = {}

camera.LockOnInfo = {
	Range = math.huge, -- The range of the lock on
	Speed = 20, -- The speed of which the lock on camera is moving
	Offset = Vector3.new(3, 4, -9), -- The camera offset when using lock on
	LockOnPlayers = true, -- Lock on player in the world
	RequiresLineOfSight = true,-- If the characer needs line of sight with target to use lock on.
	ObstructionBreakTime = 0.5, -- The time without line of sight that takes to exit the lock on.
	SwitchDebounce = 0.3, -- The debounce or cooldown of switching targets
	SwitchSens = 5, -- How sensetive the switching should be
	SwitchRange = 50, -- How far away you can switch target
}

-- Optimized some code which is not present in the video // https://www.youtube.com/@TeletacosRobloxTutorials

local target 
local lookConnection, healthConnection

function camera.GetTargetsInRange(character)
	local targets = {}
	
	for i, part in pairs(workspace:GetPartBoundsInRadius(character.HumanoidRootPart.Position, camera.LockOnInfo.Range)) do
		if part:IsA("BasePart") and part.Parent:FindFirstChild("Humanoid") then
			if game.Players:GetPlayerFromCharacter(part.Parent) then
				if camera.LockOnInfo.LockOnPlayers == true then
					if not table.find(targets, part.Parent) then
						table.insert(targets, part.Parent)
					end	
				end
			else
				if not table.find(targets, part.Parent) then
					table.insert(targets, part.Parent)
				end	
			end
		end
	end

	return targets
end

function camera.GetTargetsClosestCrosshair(character, cam)
	local targets = camera.GetTargetsInRange(character)

	local nearest = 1
	local target = nil

	for i, char in targets do
		if char and char ~= character then
			local distance = (char.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude

			local cameraToTarget = (char.HumanoidRootPart.Position - cam.CFrame.Position).Unit
			local cameraLook = cam.CFrame.LookVector

			local dotProduct = cameraToTarget:Dot(cameraLook)
			local difference = math.abs(1 - dotProduct)

			if distance < camera.LockOnInfo.Range and dotProduct > 0.5 then
				if difference < nearest then
					nearest = difference
					target = char
				end
			end
		end
	end

	local rightTarget = nil
	local leftTarget = nil

	local nearestRight = camera.LockOnInfo.SwitchRange
	local nearestLeft = -camera.LockOnInfo.SwitchRange

	for i, char in targets do
		if char and target and char ~= target then
			local distance = character.HumanoidRootPart.CFrame:ToObjectSpace(char.HumanoidRootPart.CFrame)		
			if distance.Z < 0 then
				if distance.X > 0 then
					if nearestRight then
						if distance.X < nearestRight then
							nearestRight = distance.X
							rightTarget = char
						end
					else
						nearestRight = distance.X
						rightTarget = char		
					end
				elseif distance.X < 0 then
					if nearestLeft then
						if distance.X > nearestLeft then
							nearestLeft = distance.X
							leftTarget = char
						end
					else
						nearestLeft = distance.X
						leftTarget = char		
					end

				end
			end
		end
	end

	return target, rightTarget, leftTarget
end

function camera.IsTargetInView(character, target)
	local excludedCharacters = camera.GetTargetsInRange(character)
	table.remove(excludedCharacters, table.find(excludedCharacters, target))

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = excludedCharacters

	local origin = character.HumanoidRootPart.Position
	local direction = (target.HumanoidRootPart.Position - origin).Unit

	local ray = workspace:Raycast(origin, direction * camera.LockOnInfo.Range, rayParams)

	if ray then
		if ray.Instance.Parent == target then
			return true
		end
	end

	return false
end

function camera.SelectTarget(newTarget)
	if SelectionBG then
		SelectionBG:Destroy()
	end

	if newTarget then
		local newSelection = script.Selection:Clone()
		newSelection.Parent = newTarget.Torso
		newSelection.Enabled = true
		SelectionBG = newSelection
	end
end

function camera.SetLocalTransparency(character, transparency) -- Used to prevent the character from being invisible when locking if first person
	for i, v in pairs(character:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.LocalTransparencyModifier = transparency
		end
	end
end

function camera.LockNearest()
	local cam = workspace.CurrentCamera

	local player = game.Players.LocalPlayer
	local mouse = player:GetMouse()

	local character = player.Character

	if not character then return end

	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local humanoid = character:WaitForChild("Humanoid")

	target = camera.GetTargetsClosestCrosshair(character, cam)
	camera.SelectTarget(target)
	
	if target and target:FindFirstChild("Humanoid") and camera.IsTargetInView(character, target) then	
		camera.SetLocalTransparency(character, 0)

		cam.CameraType = Enum.CameraType.Scriptable

		userInputService.MouseIconEnabled = false
		userInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	else
		camera.Freecam()
		
		if lookConnection then
			lookConnection:Disconnect()
			lookConnection = nil
		end		
		
		return
	end

	local lastObstructed = nil
	local lastTime = tick()
	local lastDelta = 0

	lookConnection = runService.RenderStepped:Connect(function(dt)
		dt = (lastDelta + dt)/2 -- Smooth the delta to prevent fps drops
		lastDelta = dt

		if not target then 
			camera.Freecam()
			return 
		end

		local distance = (target.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude

		local requiresLineOfSight = camera.LockOnInfo.RequiresLineOfSight
		local hasLineOfSight = camera.IsTargetInView(character, target)
		local lineOfSight = (hasLineOfSight and requiresLineOfSight) or not requiresLineOfSight -- Check for line of sight if required

		if not lineOfSight then
			if not lastObstructed then
				lastObstructed = tick()
			elseif tick() - lastObstructed > 1 then
				lastObstructed = nil
				camera.Freecam()
				if lookConnection then
					lookConnection:Disconnect()
					lookConnection = nil
				end	
				return
			end
		else
			lastObstructed = nil
		end

		if (distance < camera.LockOnInfo.Range and target.Humanoid.Health > 0) then
			local targetPosition = Vector3.new(target.HumanoidRootPart.Position.X, character.HumanoidRootPart.Position.Y, target.HumanoidRootPart.Position.Z)
			local newCFrame = CFrame.lookAt(character.HumanoidRootPart.Position, targetPosition, character.HumanoidRootPart.CFrame.UpVector)
			character.HumanoidRootPart.CFrame = newCFrame

			local offsetX = humanoidRootPart.CFrame.RightVector * camera.LockOnInfo.Offset.X
			local offsetY = humanoidRootPart.CFrame.UpVector * camera.LockOnInfo.Offset.Y
			local offsetZ = humanoidRootPart.CFrame.LookVector * camera.LockOnInfo.Offset.Z

			local offset = offsetX + offsetY + offsetZ
			local cameraPosition = humanoidRootPart.Position + offset

			local targetCFrame = CFrame.lookAt(cameraPosition, target.HumanoidRootPart.Position, humanoidRootPart.CFrame.UpVector)
			cam.CFrame = cam.CFrame:Lerp(targetCFrame, dt * camera.LockOnInfo.Speed)

			if tick() - lastTime > camera.LockOnInfo.SwitchDebounce then
				local mouseDeltaX = userInputService:GetMouseDelta().X

				if mouseDeltaX > camera.LockOnInfo.SwitchSens or mouseDeltaX < -camera.LockOnInfo.SwitchSens then
					local _, rightTarget, leftTarget = camera.GetTargetsClosestCrosshair(character, cam)

					if mouseDeltaX > camera.LockOnInfo.SwitchSens and rightTarget and camera.IsTargetInView(character, rightTarget) then -- Determine the direction of the mouse and switching target accordingly
						camera.SelectTarget(rightTarget)
						target = rightTarget
					elseif mouseDeltaX < -camera.LockOnInfo.SwitchSens and leftTarget and camera.IsTargetInView(character, leftTarget)  then
						camera.SelectTarget(leftTarget)
						target = leftTarget
					end
				end

				lastTime = tick()
			end
		else
			camera.Freecam()
		end
	end)

	local deathConnection
	deathConnection = humanoid.Died:Connect(function()
		deathConnection:Disconnect()
		camera.Freecam()
	end)

	return target
end

function camera.Freecam()
	if lookConnection then
		lookConnection:Disconnect()
		lookConnection = nil
	end	
	
	camera.SelectTarget(nil)

	userInputService.MouseIconEnabled = true
	userInputService.MouseBehavior = Enum.MouseBehavior.Default

	local cam = workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Custom
end


userInputService.InputBegan:Connect(function(input, processed)
	if processed then return end

	if input.KeyCode == Enum.KeyCode.Thumbstick1 and not userInputService.TouchEnabled and not userInputService.KeyboardEnabled then
		if cameraMode == "Freecam" then
			Character:AddTag('CantRotate')
			ShiftlockConnection = game.CollectionService:GetInstanceRemovedSignal('CantRotate'):Connect(function(_Instance)
				if _Instance == Character then
					Character:AddTag('CantRotate')
				end
			end)

			cameraMode = "LockNearest"
			camera.LockNearest()
		else
			ShiftlockConnection:Disconnect()
			Character:RemoveTag('CantRotate')

			cameraMode = "Freecam"
			camera.Freecam()
		end
	end
end)

return {}