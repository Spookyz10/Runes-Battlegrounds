local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local module = {}
module.__index = module

function module.new(Player: Player)
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
		onTimeout = nil,
		functionAfterDestroy = function() end,
		ResetCharactersList = false,
		Bridge = Bridge,
		Player = Player,
		destroyAfterOnce = false,
		_debugConn = nil,
		_timeoutThread = nil,
		_stopped = false,
	}, module)

	Bridge.OnServerEvent:Connect(function(ReceivedPlayer, TouchedEnemies)
		if ReceivedPlayer ~= Player or MetaTable._stopped then
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

local function fireSetup(self, Mode)
	RemoteManager.FireClient(self.Player, "ReplicateTask", "SetUpHitboxBridge", {
		BridgeId = self.Bridge.Name,
		Mode = Mode,
		Instance = self.Instance,
		Size = self.Size,
		Offset = self.Offset,
		Ignore = self.Ignore,
	})
end

function module:Once()
	fireSetup(self, "Once")
end

function module:Start(HitboxTime, Destroy)
	self._stopped = false

	fireSetup(self, "Constant")

	if RunService:IsStudio() then
		if self._debugConn then
			self._debugConn:Disconnect()
			self._debugConn = nil
		end

		self._debugConn = RunService.Heartbeat:Connect(function()
			if not self.Instance or not self.Instance.Parent or self._stopped then
				if self._debugConn then
					self._debugConn:Disconnect()
					self._debugConn = nil
				end
				return
			end
		end)
	end

	if self._timeoutThread then
		task.cancel(self._timeoutThread)
		self._timeoutThread = nil
	end

	if HitboxTime then
		self._timeoutThread = task.delay(HitboxTime, function()
			self._timeoutThread = nil

			if self._stopped then
				return
			end

			local HadNoHits = #self.Characters == 0

			if Destroy == true then
				self:Destroy()
			else
				self:Stop()
			end

			if HadNoHits and self.onTimeout then
				self.onTimeout()
			end
		end)
	end
end

function module:Stop()
	self._stopped = true

	if self._debugConn then
		self._debugConn:Disconnect()
		self._debugConn = nil
	end

	if self._timeoutThread then
		task.cancel(self._timeoutThread)
		self._timeoutThread = nil
	end

	local StopConstant = Instance.new("BoolValue")
	StopConstant.Name = "StopConstant"
	StopConstant.Parent = self.Bridge
end

function module:Destroy()
	self._stopped = true

	if self._debugConn then
		self._debugConn:Disconnect()
		self._debugConn = nil
	end

	if self._timeoutThread then
		task.cancel(self._timeoutThread)
		self._timeoutThread = nil
	end

	local Bridge: RemoteEvent = self.Bridge

	if Bridge then
		Bridge:Destroy()
	end

	task.spawn(self.functionAfterDestroy)

	setmetatable(self, nil)
end

return table.freeze(module)
