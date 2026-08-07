local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local RNS = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")

local SvModules = ServerStorage.Modules

local AddAppereance = require(ReplicatedStorage.Shared.Modules.Functions.AddAppereance)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local ServerRemoteListener = require(ServerStorage.Modules.ServerRemoteListener)

local StunHandler = require(SvModules.StunHandler)
local MovesetHandlerModule = require(SvModules.MovesetHandler)
local RagdollHandler = require(SvModules.RagdollHandler)
local CollisionsModule = require(SvModules.CollisionsModule)
local AnimationService = require(SvModules.AnimationService)
local iFramesService = require(SvModules.iFramesService)
local CombatUtils = require(SvModules.CombatUtils)

local Data = require(ReplicatedStorage.Shared.Data).server

local function HumanoidDied(Player: Player)
	if not Player.Character then
		return
	end

	local Character = Player.Character
	local Humanoid = Character.Humanoid

	if Humanoid.BreakJointsOnDeath then
		for _, v in Character:GetDescendants() do
			if v:IsA("Motor6D") or v:IsA("BallSocketConstraint") then
				v:Destroy()
			elseif v:IsA("Part") or v:IsA("BasePart") or v:IsA("MeshPart") then
				v.AssemblyLinearVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
				v.AssemblyAngularVelocity =
					Vector3.new(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15))
			end
		end

		StunHandler:Stun(Character, 6)
	else
		Character:AddTag("CantRagdollCancel")
		RagdollHandler.ragdoll(Humanoid)
	end

	iFramesService:RemoveAlliFrames(Character)

	task.delay(5, function()
		Player:LoadCharacterAsync()
	end)
end

local function AddStarterPlayer(Player)
	if not Player then
		return
	end

	local PlayerData = Data.Service:waitForData(Player)
	local template = ServerStorage.StarterPlayer

	for _, obj in template:GetChildren() do
		local clone = obj:Clone()
		clone.Parent = Player
	end

	local Moveset = Player:FindFirstChild("Moveset")
	if not Moveset then
		Moveset = Instance.new("Folder")
		Moveset.Name = "Moveset"
		Moveset.Parent = Player
	end

	local AwakeningProgress = Player:FindFirstChild("AwakeningProgress")
	if not AwakeningProgress then
		AwakeningProgress = Instance.new("NumberValue")
		AwakeningProgress.Name = "AwakeningProgress"
		AwakeningProgress.Value = 0
		AwakeningProgress.Parent = Player
	end

	local CurrentMode = Player:FindFirstChild("CurrentMode")
	if not CurrentMode then
		CurrentMode = Instance.new("StringValue")
		CurrentMode.Name = "CurrentMode"
		CurrentMode.Value = "Default"
		CurrentMode.Parent = Player
	end

	local leaderstats = Player:FindFirstChild("leaderstats")

	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Parent = Player
		leaderstats.Name = "leaderstats"
	end

	-- local Kills = leaderstats:FindFirstChild("Kills") or Instance.new("NumberValue", leaderstats)
	-- Kills.Name = "Kills"
	-- Kills.Value = Data[Player].Kills()
	-- Data[Player].Kills.Changed(function(kills, oldKills)
	-- 	Kills.Value = kills
	-- end)

	local TotalKills = leaderstats:FindFirstChild("Total Kills") or Instance.new("NumberValue", leaderstats)
	TotalKills.Name = "Total Kills"
	TotalKills.Value = Data[Player].TotalKills()
	Data[Player].TotalKills.Changed(function(kills, oldKills)
		Kills.Value = kills
	end)

	local Moveset_attr = Player:GetAttribute("Moveset")
	if not Moveset_attr then
		Player:SetAttribute("Moveset", PlayerData.Moveset() or "Eclipse")
	else
		Player:SetAttribute("Moveset", Moveset_attr)
	end

	if Player:GetAttribute("Moveset") == "Eclipse" then
		Player:SetAttribute("MovesetMode_Eclipse", "Lunar")
	end

	CombatUtils.AddValue(Player, "NumberValue", 6, "RespawnTime")
	CombatUtils.AddValue(Player, "BoolValue", true, "CanRespawn")

	local loadedData = Instance.new("BoolValue")
	loadedData.Name = "LoadedData"
	loadedData.Value = true
	loadedData.Parent = Player

	CollectionService:AddTag(Player, "DataLoaded")
end

local function PlayerAdded(Player)
	if Player:GetAttribute("Added") == true then
		return
	end
	Player:SetAttribute("Added", true)

	local ok, err = pcall(AddStarterPlayer, Player)
	if not ok then
		Player:Kick("Erro ao inicializar personagem.")
		if RNS:IsStudio() then
			warn(err)
		end
		return
	end

	Player:SetAttribute("Loaded", true)

	local Character = Player.Character
	if Character then
		CharacterAdded(Character)
	end
	Player.CharacterAdded:Connect(CharacterAdded)
end

function CharacterAdded(Character)
	if not Character:IsDescendantOf(game) then
		repeat
			task.wait()
		until Character:IsDescendantOf(game)
	end

	Character:SetAttribute("JustSpawned", true)
	Character.Parent = workspace.Live

	local Player = Players:GetPlayerFromCharacter(Character)
	if not Player then
		if Character then
			Character:Destroy()
		end
		return
	end

	local Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid", 10)
	local HumRP = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart", 10)

	local Died = false

	if Player:GetAttribute("Awakened") then
		Player.AwakeningProgress.Value = 0
	end
	Player:SetAttribute("Awakened", false)

	iFramesService:AddAlliFrames(Character)
	AnimationService:loadAnimations(Character)

	task.delay(4, function()
		Character:SetAttribute("JustSpawned", nil)
		iFramesService:RemoveAlliFrames(Character)
	end)

	if Humanoid.MoveDirection.Magnitude == 0 then
		Humanoid:GetPropertyChangedSignal("MoveDirection"):Once(function()
			if Humanoid.MoveDirection.Magnitude ~= 0 then
				AnimationService:stopAll(Character)
			end
		end)
	end

	task.spawn(function()
		AddAppereance.Add(Player, Character)
	end)

	Humanoid.Died:Once(function()
		if Died == false then
			Died = true
			HumanoidDied(Player)
		end
	end)

	Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if Humanoid.Health <= 0 then
			if Died == false then
				Died = true
				HumanoidDied(Player)
			end
		end
	end)

	HumRP:GetPropertyChangedSignal("Parent"):Connect(function()
		if Died == false and HumRP.Position.Y <= workspace.FallenPartsDestroyHeight then
			Died = true
			HumanoidDied(Player)
		end
	end)

	Humanoid.DisplayName = Player.DisplayName

	MovesetHandlerModule:AddBaseMoveset(Player, Player:GetAttribute("Moveset"))

	AnimationService:loadAnimations(Character)

	CollisionsModule:SetCollisionGroup(Character, "Players")

	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)

	Character:SetAttribute("Moveset", Player:GetAttribute("Moveset"))
end

pcall(function()
	PhysicsService:RegisterCollisionGroup("NonPColDebri")
end)
pcall(function()
	PhysicsService:RegisterCollisionGroup("Players")
end)
PhysicsService:CollisionGroupSetCollidable("NonPColDebri", "Players", false)

for _, v in Players:GetPlayers() do
	if not v:GetAttribute("Added") then
		task.spawn(function()
			PlayerAdded(v)
		end)
	end
end

Players.PlayerAdded:Connect(PlayerAdded)

CollectionService:GetInstanceAddedSignal("CantRotate"):Connect(function(Character)
	local Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid then
		Humanoid.AutoRotate = false
	end
end)

CollectionService:GetInstanceRemovedSignal("CantRotate"):Connect(function(Character)
	local Humanoid = Character:FindFirstChild("Humanoid")
	if Humanoid then
		if Character:HasTag("Ragdolled") then
			Character:AddTag("CantRotate")
		else
			Humanoid.AutoRotate = true
		end
	end
end)

for _, part in workspace.Map.Destroyables:GetDescendants() do
	if part:IsA("BasePart") then
		part:SetAttribute("Destroyable", true)
	end
end

RemoteManager.ListenToAll(ServerRemoteListener)
RemoteManager.ListenToAllFunctions(ServerRemoteListener)
