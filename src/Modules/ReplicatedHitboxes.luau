local module = {}

local ComSet = game.ReplicatedStorage.Remotes.Comunicator.Set
local ComGet = game.ReplicatedStorage.Remotes.Comunicator.Get

module.__index = module

function module.new(Player: Player)
	if game.PlaceId == workspace:GetAttribute("DuelsHubPlaceId") then
		return
	end

	local ExistingBridges = 0
	for _, v in Player:GetChildren() do
		if v.Name:find("HitboxBridge") then
			ExistingBridges += 1
		end
	end

	local Bridge = Instance.new("RemoteEvent")
	Bridge.Name = "HitboxBridge" .. ExistingBridges + 1
	Bridge.Parent = Player

	local MetaTable = setmetatable({
		Size = Vector3.new(1, 1, 1) * 7,
		Ignore = {},
		Instance = nil,
		Offset = CFrame.new(0, 0, 0),
		Characters = {},
		onTouch = function(EnemyCharacter: Model) end,
		functionAfterDestroy = function() end,
		ResetCharactersList = false,
		Bridge = Bridge,
		Player = Player,
		destroyAfterOnce = false,
	}, module)

	ComSet:FireClient(Player, "SetupHitboxBridge", { BridgeId = Bridge.Name })

	Bridge.OnServerEvent:Connect(function(ReceivedPlayer, TouchedEnemies)
		if ReceivedPlayer ~= Player then
			return
		end

		if TouchedEnemies ~= nil and #TouchedEnemies > 0 then
			for _, EnemyCharacter: Model in TouchedEnemies do
				if MetaTable.ResetCharactersList == false then
					if table.find(MetaTable.Characters, EnemyCharacter) then
						continue
					end

					table.insert(MetaTable.Characters, EnemyCharacter)
				else
					MetaTable.Characters = {}
				end

				MetaTable.onTouch(EnemyCharacter)
			end
		end

		if MetaTable.destroyAfterOnce == true then
			MetaTable:Destroy()
		end
	end)

	return MetaTable
end

function module:Once()
	if game.PlaceId == workspace:GetAttribute("DuelsHubPlaceId") then
		return
	end
	self.Bridge:FireClient(
		self.Player,
		"Once",
		{ Instance = self.Instance, Size = self.Size, Offset = self.Offset, Ignore = self.Ignore }
	)
end

function module:Start(HitboxTime, Destroy)
	if game.PlaceId == workspace:GetAttribute("DuelsHubPlaceId") then
		return
	end
	self.Bridge:FireClient(
		self.Player,
		"Constant",
		{ Instance = self.Instance, Size = self.Size, Offset = self.Offset, Ignore = self.Ignore }
	)

	if HitboxTime then
		task.delay(HitboxTime, function()
			if self ~= nil and self.Stop ~= nil and self.Destroy ~= nil then
				if Destroy == true then
					self:Destroy()
				else
					self:Stop()
				end
			end
		end)
	end
end

function module:Stop()
	local StopConstant = Instance.new("BoolValue")
	StopConstant.Name = "StopConstant"
	StopConstant.Parent = self.Bridge
end

function module:Destroy()
	local Bridge: RemoteEvent = self.Bridge

	if Bridge then
		Bridge:Destroy()
	end

	task.spawn(self.functionAfterDestroy)

	setmetatable(self, nil)
end

return table.freeze(module)
