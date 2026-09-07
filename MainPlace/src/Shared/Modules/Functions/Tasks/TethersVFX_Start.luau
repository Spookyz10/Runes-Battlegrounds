local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")

local TethersAssets = ReplicatedStorage.Resources.CharacterAssets.Eclipse.Solar.Tethers
local TethersVFXState = require(script.Parent.Shared.TethersVFXState)

local activeVFX = TethersVFXState.activeVFX

local function getKey(casterChar)
	return casterChar
end

local function spawnFlareArms(casterChar)
	local template = TethersAssets:FindFirstChild("FlareArm")
	if not template then
		return {}
	end

	local spawned = {}

	for _, armName in { "Right Arm", "Left Arm" } do
		local arm = casterChar:FindFirstChild(armName)
		if arm then
			for _, child in template:GetChildren() do
				local clone = child:Clone()
				clone.Parent = arm
				table.insert(spawned, clone)
			end
		end
	end

	return spawned
end

local function spawnFlareChains(casterChar, victimChar, travelTime)
	local template = TethersAssets:FindFirstChild("FlareChains")
	if not template then
		return {}
	end

	local spawned = {}

	for _, armName in { "Right Arm", "Left Arm" } do
		local casterArm = casterChar:FindFirstChild(armName)
		local victimArm = victimChar and victimChar:FindFirstChild(armName)

		if not casterArm then
			continue
		end

		local chain = template:Clone()
		chain.Parent = casterArm

		local travelAnchor = Instance.new("Part")
		travelAnchor.Name = "ChainTravelAnchor"
		travelAnchor.Anchored = true
		travelAnchor.CanCollide = false
		travelAnchor.CanTouch = false
		travelAnchor.CanQuery = false
		travelAnchor.Transparency = 1
		travelAnchor.Size = Vector3.new(0.1, 0.1, 0.1)
		travelAnchor.CFrame = casterArm.CFrame
		travelAnchor.Parent = workspace.Debris

		local travelAttachment = Instance.new("Attachment")
		travelAttachment.Parent = travelAnchor

		for _, beam in chain:GetDescendants() do
			if beam:IsA("Beam") then
				beam.Attachment1 = travelAttachment
			end
		end

		local victimPart = chain:FindFirstChild("Victim")

		if victimArm and travelTime and travelTime > 0 then
			local targetCF = victimArm.CFrame

			local elapsed = 0
			local startCF = travelAnchor.CFrame
			local conn
			conn = RunService.Heartbeat:Connect(function(dt)
				elapsed += dt

				if not travelAnchor or not travelAnchor.Parent then
					conn:Disconnect()
					return
				end
				if not casterArm or not casterArm.Parent then
					conn:Disconnect()
					travelAnchor:Destroy()
					return
				end
				if not chain or not chain.Parent then
					conn:Disconnect()
					if travelAnchor and travelAnchor.Parent then
						travelAnchor:Destroy()
					end
					return
				end

				local t = math.clamp(elapsed / travelTime, 0, 1)

				local easedT = 1 - (1 - t) ^ 2

				local currentTarget = (victimArm and victimArm.Parent) and victimArm.CFrame or targetCF
				travelAnchor.CFrame = startCF:Lerp(currentTarget, easedT)

				if t >= 1 then
					conn:Disconnect()

					if victimPart and victimArm and victimArm.Parent then
						victimPart.Parent = victimArm

						for _, beam in chain:GetDescendants() do
							if beam:IsA("Beam") then
								local finalAttach = victimArm:FindFirstChildOfClass("Attachment")
								if finalAttach then
									beam.Attachment1 = finalAttach
								end
							end
						end
					end

					travelAnchor:Destroy()
				end
			end)

			table.insert(spawned, {
				chain = chain,
				victimPart = victimPart,
				travelAnchor = travelAnchor,
				travelConn = conn,
			})
		else
			if victimPart and victimArm then
				victimPart.Parent = victimArm
			end
			travelAnchor:Destroy()

			table.insert(spawned, {
				chain = chain,
				victimPart = victimPart,
				travelAnchor = nil,
				travelConn = nil,
			})
		end
	end

	return spawned
end

return function(params)
	local casterChar = params.casterChar
	local victimChar = params.victimChar
	local travelTime = params.travelTime or 0

	if not casterChar then
		return
	end

	local key = getKey(casterChar)

	local stop = require(script.Parent.TethersVFX_Stop)
	stop({ casterChar = casterChar })

	activeVFX[key] = {
		armParts = spawnFlareArms(casterChar),
		chains = spawnFlareChains(casterChar, victimChar, travelTime),
	}
	local entry = activeVFX[key]
	entry.connections = {}
	for _, character in { casterChar, victimChar } do
		table.insert(entry.connections, character.AncestryChanged:Connect(function()
			if not character:IsDescendantOf(workspace) and activeVFX[key] == entry then
				stop({ casterChar = casterChar })
			end
		end))
	end
	task.delay(10, function()
		if activeVFX[key] == entry then
			stop({ casterChar = casterChar })
		end
	end)

end
