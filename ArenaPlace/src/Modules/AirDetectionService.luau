local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local AirDetectionService = {}
AirDetectionService.Active = {}

local function endAirDetection(character: Model)
	if not character or not character.Parent then
		return
	end

	character:SetAttribute("TouchedGround", tick())

	local inAirValue = character:FindFirstChild("inAir")
	if inAirValue then
		inAirValue:Destroy()
	end
end

local function getOwningPlayer(rootPart: BasePart): Player?
	local owningPlayer
	pcall(function()
		owningPlayer = rootPart:GetNetworkOwner()
	end)

	if owningPlayer then
		return owningPlayer
	end

	local closestPlayer
	local closestDistance
	for _, otherPlayer in Players:GetPlayers() do
		local otherRoot = otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart")
		if otherRoot then
			local distance = (otherRoot.Position - rootPart.Position).Magnitude
			if not closestDistance or distance < closestDistance then
				closestPlayer = otherPlayer
				closestDistance = distance
			end
		end
	end

	return closestPlayer
end

function AirDetectionService:Stop(Character: Model, EndDetection: boolean?)
	local State = self.Active[Character]
	if not State then
		if EndDetection then
			endAirDetection(Character)
		end
		return
	end

	self.Active[Character] = nil

	if State.Connection then
		State.Connection:Disconnect()
	end

	if State.Bridge and State.Bridge.Parent then
		pcall(function()
			State.Bridge:Destroy()
		end)
	end

	if EndDetection then
		endAirDetection(Character)
	end
end

function AirDetectionService:Start(Character: Model, Params)
	Params = Params or {}

	if not Character or not Character.Parent then
		return
	end

	local rootPart = Character:FindFirstChild("HumanoidRootPart")
	if not rootPart or rootPart.Anchored == true then
		return
	end

	if Character:FindFirstChild("Dummy") then
		endAirDetection(Character)
		return
	end

	local owningPlayer = getOwningPlayer(rootPart)
	if not owningPlayer then
		endAirDetection(Character)
		return
	end

	if self.Active[Character] then
		self:Stop(Character, false)
	end

	local inAirValue = Character:FindFirstChild("inAir")
	if not inAirValue then
		Character:SetAttribute("lastAir", tick())

		inAirValue = Instance.new("BoolValue")
		inAirValue.Name = "inAir"
		inAirValue.Parent = Character
	end

	local bridge = Instance.new("RemoteEvent")
	bridge.Name = tostring(owningPlayer.UserId) .. " | " .. tostring(os.clock())
	bridge.Parent = owningPlayer

	local state = {
		Bridge = bridge,
		Connection = nil,
	}
	self.Active[Character] = state

	local timeout = 30 + owningPlayer:GetNetworkPing()
	task.delay(timeout, function()
		if self.Active[Character] ~= state then
			return
		end

		self:Stop(Character, true)
	end)

	state.Connection = bridge.OnServerEvent:Connect(function(sender)
		if sender ~= owningPlayer then
			return
		end

		if self.Active[Character] ~= state then
			return
		end

		self:Stop(Character, true)
	end)

	bridge.Destroying:Once(function()
		if self.Active[Character] ~= state then
			return
		end

		self:Stop(Character, true)
	end)

	RemoteManager.FireClient(owningPlayer, "DetectAir", {
		Bridge = bridge.Name,
		Char = Character,
		ragdoll = Params.ragdoll,
		justdown = Params.justDown and -math.abs(Params.justDown) or nil,
		customClamp = Params.customClamp,
		customParams = Params.customParams,
		destroyables = Params.destroyables,
	})
end

return table.freeze(AirDetectionService)
