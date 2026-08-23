local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ServerModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local StunHandler = require(ServerModules.StunHandler)

local MatchTypes = require(script.Parent.MatchTypes)
local Match = require(script.Parent.Match)

local RankedMapsFolder = ServerStorage:FindFirstChild("RankedMaps")

local CHARACTER_SELECTION_TIME = 15
local COUNTDOWN_TIME = 3

local ArenaController = {}
ArenaController.__index = ArenaController

local function getRandomPositionInPart(part: BasePart): Vector3
	local halfSize = part.Size / 2
	local randomOffset = Vector3.new((math.random() * 2 - 1) * halfSize.X, 0, (math.random() * 2 - 1) * halfSize.Z)

	return part.Position + randomOffset + Vector3.new(0, halfSize.Y + 3, 0)
end

function ArenaController.new(config: MatchTypes.MatchConfig)
	local self = setmetatable({}, ArenaController)

	self.MatchInstance = Match.new(config)
	self.Map = nil
	self.StunTokens = {}
	self.DeathConnections = {}
	self.Cancelled = false
	self.RoundTimerThread = nil

	return self
end

function ArenaController:GetMatch()
	return self.MatchInstance
end

function ArenaController:SelectMap()
	assert(RankedMapsFolder, "ServerStorage.RankedMaps not found")

	local candidates = RankedMapsFolder:GetChildren()
	assert(#candidates > 0, "No maps available in ServerStorage.RankedMaps")

	local chosen = candidates[math.random(1, #candidates)]
	local clone = chosen:Clone()
	clone.Name = "map"
	clone.Parent = workspace

	self.Map = clone

	return clone
end

function ArenaController:AssignPlayersToTeams(players: { Player })
	local teamOrder = self.MatchInstance.TeamOrder
	local playersPerTeam = self.MatchInstance.Config.PlayersPerTeam

	local index = 1
	for _, teamName in teamOrder do
		for _ = 1, playersPerTeam do
			local player = players[index]
			if not player then
				break
			end

			self.MatchInstance:AddPlayerToTeam(player, teamName)
			index += 1
		end
	end
end

function ArenaController:PositionPlayers()
	assert(self.Map, "Map must be selected before positioning players")

	local SpawnLocations = self.Map:FindFirstChild("SpawnLocations")
	assert(SpawnLocations, "map.SpawnLocations not found")

	for _, playerState in self.MatchInstance:GetAllPlayers() do
		local player = playerState.Player
		local Character = player.Character
		if not Character then
			continue
		end

		local SpawnPart = SpawnLocations:FindFirstChild(playerState.Team)
		if not SpawnPart then
			continue
		end

		local HumRP = Character:FindFirstChild("HumanoidRootPart")
		if not HumRP then
			continue
		end

		local targetPosition = getRandomPositionInPart(SpawnPart)
		Character:PivotTo(CFrame.new(targetPosition))
	end
end

function ArenaController:StunAllPlayers()
	for _, playerState in self.MatchInstance:GetAllPlayers() do
		local Character = playerState.Player.Character
		if not Character then
			continue
		end

		local token = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)
		self.StunTokens[playerState.UserId] = token
	end
end

function ArenaController:UnstunAllPlayers()
	for _, playerState in self.MatchInstance:GetAllPlayers() do
		local Character = playerState.Player.Character
		if not Character then
			continue
		end

		local token = self.StunTokens[playerState.UserId]
		if token then
			StunHandler:Unstun(Character, token)
			self.StunTokens[playerState.UserId] = nil
		end
	end
end

function ArenaController:BroadcastMessage(message: string)
	RemoteManager.FireAllClients("ReplicateTask", "SystemMessage", message)
end

function ArenaController:RunCharacterSelection()
	self.MatchInstance:SetState(MatchTypes.MatchState.CharacterSelection)

	self:StunAllPlayers()

	for _, playerState in self.MatchInstance:GetAllPlayers() do
		local Character = playerState.Player.Character
		if Character then
			-- TODO: ligar UI de seleção de personagem (etapa futura) usando esta flag
			Character:SetAttribute("AllowMovesetSwap", true)
		end
	end

	task.wait(CHARACTER_SELECTION_TIME)

	for _, playerState in self.MatchInstance:GetAllPlayers() do
		local Character = playerState.Player.Character
		if Character then
			Character:SetAttribute("AllowMovesetSwap", false)
		end
	end
end

function ArenaController:RunCountdown()
	if self.Cancelled then
		return
	end

	self.MatchInstance:SetState(MatchTypes.MatchState.Countdown)

	for i = COUNTDOWN_TIME, 1, -1 do
		self:BroadcastMessage(tostring(i))
		task.wait(1)
	end

	self:BroadcastMessage("START")
end

function ArenaController:HandlePlayerDeath(playerState: MatchTypes.PlayerState)
	if self.Cancelled then
		return
	end
	if self.MatchInstance:GetState() ~= MatchTypes.MatchState.InProgress then
		return
	end

	self.MatchInstance:DamagePlayer(playerState.UserId, 1)
	self:CheckMatchEnd()
end

function ArenaController:ConnectDeathTracking()
	for _, playerState in self.MatchInstance:GetAllPlayers() do
		local Character = playerState.Player.Character
		if not Character then
			continue
		end

		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if not Humanoid then
			continue
		end

		local connection = Humanoid.Died:Connect(function()
			self:HandlePlayerDeath(playerState)
		end)

		self.DeathConnections[playerState.UserId] = connection
	end
end

function ArenaController:DisconnectDeathTracking()
	for userId, connection in self.DeathConnections do
		connection:Disconnect()
		self.DeathConnections[userId] = nil
	end
end

function ArenaController:BeginRound()
	if self.Cancelled then
		return
	end

	self.MatchInstance:SetState(MatchTypes.MatchState.InProgress)

	self:UnstunAllPlayers()
	self:ConnectDeathTracking()

	for _, playerState in self.MatchInstance:GetAllPlayers() do
		local Character = playerState.Player.Character
		if Character then
			Character:SetAttribute("InRankedMatch", true)
		end
	end

	self.RoundTimerThread = task.delay(self.MatchInstance.Config.TimeLimit, function()
		self:ResolveByTimeLimit()
	end)
end

function ArenaController:CheckMatchEnd()
	if self.Cancelled then
		return
	end
	if self.MatchInstance:GetState() ~= MatchTypes.MatchState.InProgress then
		return
	end

	local winner = self.MatchInstance:CheckForWinner()
	if winner then
		self:FinishMatch()
	end
end

function ArenaController:ResolveByTimeLimit()
	if self.Cancelled then
		return
	end
	if self.MatchInstance:GetState() ~= MatchTypes.MatchState.InProgress then
		return
	end

	-- TODO: regras de desempate completas (etapa 13/14) - por enquanto so finaliza
	self:FinishMatch()
end

function ArenaController:FinishMatch()
	if self.RoundTimerThread then
		task.cancel(self.RoundTimerThread)
		self.RoundTimerThread = nil
	end

	self.MatchInstance:SetState(MatchTypes.MatchState.Resolving)

	for _, playerState in self.MatchInstance:GetAllPlayers() do
		local Character = playerState.Player.Character
		if Character then
			Character:SetAttribute("InRankedMatch", false)
		end
	end

	self.MatchInstance:SetState(MatchTypes.MatchState.Finished)
end

function ArenaController:Cleanup()
	self.Cancelled = true

	if self.RoundTimerThread then
		task.cancel(self.RoundTimerThread)
		self.RoundTimerThread = nil
	end

	self:UnstunAllPlayers()

	if self.Map and self.Map.Parent then
		self.Map:Destroy()
	end
	self.Map = nil
end

function ArenaController:StartMatch(players: { Player })
	self.MatchInstance:SetState(MatchTypes.MatchState.Preparing)

	self:SelectMap()
	self:AssignPlayersToTeams(players)
	self:PositionPlayers()

	self:RunCharacterSelection()
	self:RunCountdown()
	self:BeginRound()
end

return ArenaController
