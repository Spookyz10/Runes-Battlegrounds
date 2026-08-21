local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local module = {}
module.__index = module

function module.new(Player: Player, Id: string)
	local BridgeName = "AimBridge_" .. (Id or tostring(math.random(1, 999999)))

	local Existing = Player:FindFirstChild(BridgeName)
	if Existing then
		Existing:Destroy()
	end

	local Bridge = Instance.new("RemoteEvent")
	Bridge.Name = BridgeName
	Bridge.Parent = Player

	local MetaTable = setmetatable({
		Player = Player,
		Id = Id,
		Bridge = Bridge,
		Direction = nil,
		_stopped = false,
	}, module)

	Bridge.OnServerEvent:Connect(function(ReceivedPlayer, Direction)
		if ReceivedPlayer ~= Player or MetaTable._stopped then
			return
		end

		if typeof(Direction) ~= "Vector3" then
			return
		end

		if Direction.Magnitude < 0.001 then
			return
		end

		MetaTable.Direction = Direction.Unit

		RemoteManager.FireAllClients("ReplicateTask", "IndicatorAimUpdate", {
			ownerId = Player.UserId,
			direction = MetaTable.Direction,
		})
	end)

	return MetaTable
end

function module:Get()
	return self.Direction
end

function module:Destroy()
	if self._stopped then
		return
	end
	self._stopped = true

	if self.Bridge then
		Debris:AddItem(self.Bridge, 0.5)
	end

	setmetatable(self, nil)
end

return table.freeze(module)
