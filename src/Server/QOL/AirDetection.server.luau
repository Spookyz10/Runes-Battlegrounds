local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local Bindables = ServerStorage.Bindables
local AirDetectorBindable = Bindables.AirDetector

local MapOverlapParams = OverlapParams.new()
MapOverlapParams.FilterType = Enum.RaycastFilterType.Include
MapOverlapParams.FilterDescendantsInstances = { workspace.Map }

local function endAirDetection(character: Model)
	if not character or not character.Parent then
		return
	end

	character:SetAttribute("TouchedGround", tick())

	for _, child in character:GetChildren() do
		if child.Name == "inAir" then
			child:Destroy()
		end
	end
end

local function startAirDetection(character, _, isRagdoll, justDown, customClampDivider, customParams)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart or rootPart.Anchored == true then
		return
	end

	local owningPlayer
	pcall(function()
		owningPlayer = rootPart:GetNetworkOwner()
	end)

	local inAirValue = character:FindFirstChild("inAir")
	if not inAirValue then
		character:SetAttribute("lastAir", tick())

		inAirValue = Instance.new("BoolValue")
		inAirValue.Name = "inAir"
		inAirValue.Parent = character
	end

	task.spawn(function()
		if not owningPlayer then
			local closestPlayer, closestDistance

			for _, otherPlayer in Players:GetPlayers() do
				local otherRoot: BasePart = otherPlayer.Character
					and otherPlayer.Character:FindFirstChild("HumanoidRootPart")

				if otherRoot then
					local distance = (otherRoot.Position - rootPart.Position).Magnitude

					if not closestDistance or distance < closestDistance then
						closestPlayer = otherPlayer
						closestDistance = distance
					end
				end
			end

			owningPlayer = closestPlayer
		end

		if owningPlayer and rootPart.Anchored == false then
			pcall(function()
				rootPart:SetNetworkOwner(owningPlayer)
			end)

			local bridge = Instance.new("RemoteEvent")
			bridge.Name = owningPlayer.UserId .. " | " .. os.clock()
			bridge.Parent = owningPlayer
			Debris:AddItem(bridge, 30 + owningPlayer:GetNetworkPing())

			local receiveConnection: RBXScriptConnection
			receiveConnection = bridge.OnServerEvent:Connect(function(sender)
				if sender ~= owningPlayer then
					return
				end

				endAirDetection(character)

				pcall(function()
					receiveConnection:Disconnect()
				end)
				pcall(function()
					bridge:Destroy()
				end)
			end)

			RemoteManager.FireClient(owningPlayer, "DetectAir", {
				Bridge = bridge.Name,
				Char = character,
				ragdoll = isRagdoll,
				justdown = justDown and -math.abs(justDown),
				customClamp = customClampDivider,
				customParams = customParams,
			})
		else
			endAirDetection(character)
		end
	end)
end

AirDetectorBindable.Event:Connect(startAirDetection)
