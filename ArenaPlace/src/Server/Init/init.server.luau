local Players: Players = game:GetService("Players")

local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage: ServerStorage = game:GetService("ServerStorage")

local RNS: RunService = game:GetService("RunService")
local CollectionService: CollectionService = game:GetService("CollectionService")
local PhysicsService: PhysicsService = game:GetService("PhysicsService")

local SvModules: Folder = ServerStorage.Modules

local _KillStreakService = require(ServerStorage.Modules.KillStreakService)
local _LeaderboardManager = require(ServerStorage.Modules.LeaderboardManager)
local AddAppereance = require(ReplicatedStorage.Shared.Modules.Functions.AddAppereance)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local EarlyAccess = require(ReplicatedStorage.Shared.EarlyAccess)

local ServerRemoteListener = require(ServerStorage.Modules.ServerRemoteListener)

local StunHandler = require(SvModules.StunHandler)
local MovesetHandlerModule = require(SvModules.MovesetHandler)
local RagdollHandler = require(SvModules.RagdollHandler)
local CollisionsModule = require(SvModules.CollisionsModule)
local AnimationService = require(SvModules.AnimationService)
local iFramesService = require(SvModules.iFramesService)
local CombatUtils = require(SvModules.CombatUtils)

local Data = require(ReplicatedStorage.Shared.Data).server

local DEFAULT_WALK_SPEED: number = 16
local DEFAULT_RUN_SPEED: number = 25
local DEFAULT_JUMP_POWER: number = 50

local function HumanoidDied(Player: Player)
	if not Player.Character then
		return
	end

	local Character: Model = Player.Character
	local Humanoid: Humanoid = Character.Humanoid

	if Humanoid.BreakJointsOnDeath then
		for _, v: Instance in Character:GetDescendants() do
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

	iFramesService:RemoveiFrames(Character, "All")

	task.delay(5, function()
		Player:LoadCharacterAsync()
	end)
end

local function AddStarterPlayer(Player: Player)
	if not Player then
		return
	end

	Player:LoadCharacterAsync()

	local PlayerData = Data.Service:waitForData(Player)
	local template: Instance = ServerStorage.StarterPlayer

	for _, obj: Instance in template:GetChildren() do
		local clone: Instance = obj:Clone()
		clone.Parent = Player
	end

	local Moveset: Folder? = Player:FindFirstChild("Moveset")
	if not Moveset then
		Moveset = Instance.new("Folder")
		Moveset.Name = "Moveset"
		Moveset.Parent = Player
	end

	local AwakeningProgress: NumberValue? = Player:FindFirstChild("AwakeningProgress")
	if not AwakeningProgress then
		AwakeningProgress = Instance.new("NumberValue")
		AwakeningProgress.Name = "AwakeningProgress"
		AwakeningProgress.Value = 0
		AwakeningProgress.Parent = Player
	end

	local CurrentMode: StringValue? = Player:FindFirstChild("CurrentMode")
	if not CurrentMode then
		CurrentMode = Instance.new("StringValue")
		CurrentMode.Name = "CurrentMode"
		CurrentMode.Value = "Default"
		CurrentMode.Parent = Player
	end

	local leaderstats: Folder? = Player:FindFirstChild("leaderstats")

	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Parent = Player
		leaderstats.Name = "leaderstats"
	end

	local TotalKills: NumberValue = (leaderstats:FindFirstChild("Total Kills") :: NumberValue?)
		or Instance.new("NumberValue", leaderstats)
	TotalKills.Name = "Total Kills"
	TotalKills.Value = Data[Player].TotalKills()
	Data[Player].TotalKills.Changed(function(kills: number, oldKills: number)
		TotalKills.Value = kills
	end)

	local Moveset_attr: string? = Player:GetAttribute("Moveset") :: string?
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

	local loadedData: BoolValue = Instance.new("BoolValue")
	loadedData.Name = "LoadedData"
	loadedData.Value = true
	loadedData.Parent = Player

	CollectionService:AddTag(Player, "DataLoaded")
end

local function CharacterAdded(Character: Model)
	if not Character:IsDescendantOf(game) then
		repeat
			task.wait()
		until Character:IsDescendantOf(game)
	end

	Character:SetAttribute("JustSpawned", true)
	Character.Parent = workspace.Live

	local Player: Player? = Players:GetPlayerFromCharacter(Character)
	if not Player then
		if Character then
			Character:Destroy()
		end
		return
	end

	Character:SetAttribute("DefaultWalkSpeed", DEFAULT_WALK_SPEED)
	Character:SetAttribute("DefaultRunSpeed", DEFAULT_RUN_SPEED)
	Character:SetAttribute("DefaultJumpPower", DEFAULT_JUMP_POWER)

	local Humanoid: Humanoid = (Character:FindFirstChild("Humanoid") :: Humanoid?)
		or Character:WaitForChild("Humanoid", 10) :: Humanoid
	local HumRP: BasePart = (Character:FindFirstChild("HumanoidRootPart") :: BasePart?)
		or Character:WaitForChild("HumanoidRootPart", 10) :: BasePart

	Humanoid.WalkSpeed = DEFAULT_WALK_SPEED
	Humanoid.JumpPower = DEFAULT_JUMP_POWER

	local Died: boolean = false

	if Player:GetAttribute("Awakened") then
		(Player.AwakeningProgress :: NumberValue).Value = 0
	end
	Player:SetAttribute("Awakened", false)

	iFramesService:AddiFrames(Character, "All")

	task.spawn(function()
		AnimationService:loadAnimations(Character)
	end)

	task.delay(4, function()
		Character:SetAttribute("JustSpawned", nil)
		iFramesService:RemoveiFrames(Character, "All")
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

	MovesetHandlerModule:AddBaseMoveset(Player, Player:GetAttribute("Moveset") :: string)

	CollisionsModule:SetCollisionGroup(Character, "Players")

	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)

	Character:SetAttribute("Moveset", Player:GetAttribute("Moveset"))
end

local function PlayerAdded(Player: Player)
	if Player:GetAttribute("Added") == true then
		return
	end
	Player:SetAttribute("Added", true)

	local ok: boolean, err: any = pcall(AddStarterPlayer, Player)
	if not ok then
		Player:Kick("Erro ao inicializar personagem.")
		if RNS:IsStudio() then
			warn(err)
		end
		return
	end

	Player:SetAttribute("Loaded", true)

	local Character: Model? = Player.Character
	if Character then
		CharacterAdded(Character)
	end
	Player.CharacterAdded:Connect(CharacterAdded)
end

pcall(function()
	PhysicsService:RegisterCollisionGroup("NonPColDebri")
end)
pcall(function()
	PhysicsService:RegisterCollisionGroup("Players")
end)
pcall(function()
	PhysicsService:RegisterCollisionGroup("NoCol")
end)
PhysicsService:CollisionGroupSetCollidable("NonPColDebri", "Players", false)
PhysicsService:CollisionGroupSetCollidable("NoCol", "Players", false)
PhysicsService:CollisionGroupSetCollidable("NoCol", "NoCol", false)
PhysicsService:CollisionGroupSetCollidable("NoCol", "NonPColDebri", false)

for _, v: Player in Players:GetPlayers() do
	if not v:GetAttribute("Added") then
		task.spawn(function()
			PlayerAdded(v)
		end)
	end
end

Players.PlayerAdded:Connect(PlayerAdded)

CollectionService:GetInstanceAddedSignal("CantRotate"):Connect(function(Character: Instance)
	local Humanoid: Humanoid? = Character:FindFirstChild("Humanoid") :: Humanoid?
	if Humanoid then
		Humanoid.AutoRotate = false
	end
end)

CollectionService:GetInstanceRemovedSignal("CantRotate"):Connect(function(Character: Instance)
	local Humanoid: Humanoid? = Character:FindFirstChild("Humanoid") :: Humanoid?
	if Humanoid then
		if Character:HasTag("Ragdolled") then
			Character:AddTag("CantRotate")
		else
			Humanoid.AutoRotate = true
		end
	end
end)

for _, part: Instance in workspace.Map.Destroyables:GetDescendants() do
	if part:IsA("BasePart") then
		part:SetAttribute("Destroyable", true)
	end
end

RemoteManager.ListenToAll(ServerRemoteListener)
RemoteManager.ListenToAllFunctions(ServerRemoteListener)

Data.Service:addGlobalCallback("GiftEarlyAccess", function(player, data)
	local GamepassId = EarlyAccess.GamepassId

	local playerData = Data.Service:waitForData(player)
	if not playerData then
		return false
	end

	if table.find(playerData.OwnedPasses(), GamepassId) then
		return
	end

	playerData.OwnedPasses.Insert(GamepassId)
	return
end)
