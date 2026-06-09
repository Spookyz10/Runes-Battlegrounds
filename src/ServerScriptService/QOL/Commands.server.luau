local PS_OwnerId = game.PrivateServerOwnerId

game.ReplicatedStorage.PS_Owner.Value = PS_OwnerId



--Services
local W = game:GetService('Workspace')
local Players = game:GetService('Players')
local RNS = game:GetService('RunService')
local RS = game:GetService('ReplicatedStorage')
local SvSt = game:GetService('ServerStorage')
local MPS = game:GetService('MarketplaceService')
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")



--Variables
local DefaultGravity = 196.2

local MapCenter = Vector3.new(148.887, 438.305, 10.311)
local StormStep = nil
local CounterConnections = {}
local MapTransparencies = {}
local MapCollisions = {}

for _,v in workspace.Map:GetDescendants() do
	task.spawn(function()
		pcall(function()
			if v.Transparency ~= nil then
				MapTransparencies[v] = v.Transparency
			end
		end)
	end)
end

for _,v in workspace.Miscellaneous:GetChildren() do
	if v.Name == "Aurora" or v.Name == "Spawns" then continue end

	for _,vv in v:GetDescendants() do
		task.spawn(function()
			pcall(function()
				if vv.Transparency ~= nil then
					MapTransparencies[vv] = vv.Transparency
				end
			end)
		end)
	end
end


for _,v in workspace.Map:GetDescendants() do
	task.spawn(function()
		pcall(function()
			if v.CanCollide ~= nil then
				MapCollisions[v] = v.CanCollide
			end
		end)
	end)
end

for _,v in workspace.Miscellaneous:GetChildren() do
	if v.Name == "Aurora" or v.Name == "Spawns" then continue end

	for _,vv in v:GetDescendants() do
		task.spawn(function()
			pcall(function()
				if vv.CanCollide ~= nil then
					MapCollisions[vv] = vv.CanCollide
				end
			end)
		end)
	end
end



--Assets
local Assets = SvSt.Assets

local MoveAnims = Assets.Animations.Moves
local MoveSounds = Assets.Sounds.Moves



--Bindables
local Bindables = SvSt.Bindables

local SpnDmy = Bindables.SpawnDummy



--Remotes
local Remotes = RS.Remotes

local ReplicateSet = Remotes.Replicate.Set

local CommandRemotes = Remotes.Commands
local SetCommand = CommandRemotes.Set
local GetCommand = CommandRemotes.Get



--Modules
local SvModules = SvSt.Modules
local RpModules = RS.Modules


local AnimationService = require(SvModules.AnimationService)
local iFramesService = require(SvModules.iFramesService)
local StunHandler = require(SvModules.StunHandler)
local DamageHandler = require(SvModules.DamageHandler)
local SoundsModule = require(SvModules.SoundsModule)
local RagdollHandler = require(SvModules.RagdollHandler)
local MovesetHandler = require(SvModules.MovesetHandler)


local WeldSystem = require(RpModules.WeldSystem)
local BoatTween = require(RpModules.BoatTween)


local InfoModule = require(RS.Info)


--Functions
local function clearDummies(Player: Player)
	for _, Dummy: Model in workspace.Live:GetChildren() do
		if Dummy:FindFirstChild('Dummy') then
			Dummy:AddTag('Destroying')
			Dummy:Destroy()
		end
	end
end

local function triggerNoToolCD(goalPlayer: Player, goalValue: boolean)
	goalPlayer.Commands.NoCooldown.Value = goalValue
	
	for _, Tool: Tool in goalPlayer.Moveset:GetChildren() do
		if Tool:IsA('Tool') then
			if goalValue == true then
				Tool:SetAttribute('CDS', 0)
				Tool:SetAttribute('onCDS', false)
				Tool:SetAttribute("Cooldowns", 0)
				
				Remotes.MovesetHandler:FireClient(goalPlayer, "removeCooldowns")
			else
				Tool:SetAttribute('CDS', Tool:GetAttribute('originalCDS'))
			end
		end
	end
end

local function triggerAwk(goalValue, Player)
	if goalValue == 0 and workspace.Configuration.InfiniteAwk.Value == true then return end
	
	if Player.Commands.Mode.Value == 'All' then
		for _, goalPlayer in Players:GetPlayers() do
			goalPlayer.AwakeningProgress.Value = goalValue
		end
		
	elseif Player.Commands.Mode.Value == 'Others' then
		for _, goalPlayer in Players:GetPlayers() do
			if goalPlayer ~= Player then
				goalPlayer.AwakeningProgress.Value = goalValue
			end
		end
		
	elseif Player.Commands.Mode.Value == 'Me' then
		Player.AwakeningProgress.Value = goalValue
	end
end

local function healCharacter(Character: Model)
	local Humanoid: Humanoid = Character:FindFirstChild('Humanoid')
	if Humanoid and Humanoid.Health > 0 and Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
		Humanoid.Health = Humanoid.MaxHealth
	end
end

local function ragdollCharacter(Character: Model)
	local Humanoid: Humanoid = Character:FindFirstChild('Humanoid')
	if Humanoid then
		RagdollHandler.ragdoll(Humanoid, 5, false, nil, nil)
	end
end

local ConfigFunctions = {
	Mode = function(Player: Player)
		if Player.Commands.Mode.Value == 'All' then
			Player.Commands.Mode.Value = 'Others'
			workspace.Configuration.Mode.Value = 'Others'
			
		elseif Player.Commands.Mode.Value == 'Others' then
			Player.Commands.Mode.Value = 'Me'
			workspace.Configuration.Mode.Value = 'Me'
			
		elseif Player.Commands.Mode.Value == 'Me' then
			Player.Commands.Mode.Value = 'All'
			workspace.Configuration.Mode.Value = 'All'
		end
	end,
	
	NoCooldown = function(Player, Params)
		local Val: BoolValue = Player.Commands.NoCooldown
		Val.Value = not Val.Value
		
		local CurrValue = Val.Value
		
		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				triggerNoToolCD(goalPlayer, CurrValue)
			end
			
			workspace.Configuration.NoCooldown.Value = Val.Value
			
		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer ~= Player then
					triggerNoToolCD(goalPlayer, CurrValue)
				end
			end
			
			workspace.Configuration.NoCooldown.Value = Val.Value
			
		elseif Player.Commands.Mode.Value == 'Me' then
			triggerNoToolCD(Player, CurrValue)
		end
	end,
	
	Godmode = function(Player, Params)
		local Val: BoolValue = Player.Commands.Godmode
		Val.Value = not Val.Value

		local CurrValue = Val.Value

		if Player.Commands.Mode.Value == 'All' then
			for _,Character: Model in workspace.Live:GetChildren() do
				if CurrValue == true then
					iFramesService:AddAlliFrames(Character)
				else
					iFramesService:RemoveAlliFrames(Character)
				end
			end

			workspace.Configuration.Godmode.Value = Val.Value

		elseif Player.Commands.Mode.Value == 'Others' then
			for _,Character: Model in workspace.Live:GetChildren() do
				if Character == Player.Character then continue end

				if CurrValue == true then
					iFramesService:AddAlliFrames(Character)
				else
					iFramesService:RemoveAlliFrames(Character)
				end
			end

			workspace.Configuration.Godmode.Value = Val.Value

		elseif Player.Commands.Mode.Value == 'Me' then
			if CurrValue == true then
				iFramesService:AddAlliFrames(Player.Character)
			else
				iFramesService:RemoveAlliFrames(Player.Character)
			end
		end
	end,
	
	NoDashCD = function(Player: Player)
		local Val: BoolValue = Player.Commands.NoDashCD
		Val.Value = not Val.Value

		local CurrValue = Val.Value

		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				goalPlayer.Commands.NoDashCD.Value = CurrValue
			end

			workspace.Configuration.NoDashCD.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer ~= Player then
					goalPlayer.Commands.NoDashCD.Value = CurrValue
				end
			end

			workspace.Configuration.NoDashCD.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Me' then
			Player.Commands.NoDashCD.Value = CurrValue
		end
	end,
	
	GiveAwk = function(Player)
		triggerAwk(100, Player)
	end,
	
	SpawnDummy = function(Player: Player, Params: {any})
		SpnDmy:Fire(Player.Character.HumanoidRootPart.CFrame, Params.InitialHp, Params.ScriptName)
	end,
	
	ClearDummies = function(Player: Player)
		clearDummies(Player)
	end,
	
	RemoveAwk = function(Player: Player)
		triggerAwk(0, Player)
	end,
	
	ActivateAwk = function(Player: Player)
		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				shared.ActivateAwakening(goalPlayer)
			end

		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer == Player then continue end

				shared.ActivateAwakening(goalPlayer)
			end

		elseif Player.Commands.Mode.Value == 'Me' then
			shared.ActivateAwakening(Player)
		end
	end,
	
	InfiniteAwk = function(Player: Player)
		local Val: BoolValue = Player.Commands.InfiniteAwk
		Val.Value = not Val.Value
		
		local CurrValue = Val.Value

		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				goalPlayer.Commands.InfiniteAwk.Value = CurrValue
			end
			
			workspace.Configuration.InfiniteAwk.Value = CurrValue
			
		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer ~= Player then
					goalPlayer.Commands.InfiniteAwk.Value = CurrValue
				end
			end
			
			workspace.Configuration.InfiniteAwk.Value = CurrValue
			
		elseif Player.Commands.Mode.Value == 'Me' then
			Player.Commands.InfiniteAwk.Value = CurrValue
		end
	end,
	
	RandomMoveset = function(Player: Player)
		local Val: BoolValue = Player.Commands.RandomMoveset
		Val.Value = not Val.Value

		local CurrValue = Val.Value

		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				goalPlayer.Commands.RandomMoveset.Value = CurrValue
			end

			workspace.Configuration.RandomMoveset.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer ~= Player then
					goalPlayer.Commands.RandomMoveset.Value = CurrValue
				end
			end

			workspace.Configuration.RandomMoveset.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Me' then
			Player.Commands.RandomMoveset.Value = CurrValue
		end
	end,

	DualMoveset = function(Player: Player)
		local Val: BoolValue = Player.Commands.DualMoveset
		Val.Value = not Val.Value

		local CurrValue = Val.Value

		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				goalPlayer.Commands.DualMoveset.Value = CurrValue
			end

			workspace.Configuration.DualMoveset.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer ~= Player then
					goalPlayer.Commands.DualMoveset.Value = CurrValue
				end
			end

			workspace.Configuration.DualMoveset.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Me' then
			Player.Commands.DualMoveset.Value = CurrValue
		end
	end,

	HideMap = function(Player: Player)
		local Val: BoolValue = workspace.Configuration.HideMap
		Val.Value = not Val.Value

		local CurrValue = Val.Value

		if CurrValue == true then
			for Part,_ in MapTransparencies do
				Part.Transparency = 1
			end

			for Part,_ in MapCollisions do
				Part.CanCollide = false
			end

		else
			for Part, Transparency in MapTransparencies do
				Part.Transparency = Transparency
			end

			for Part, CanCollide in MapCollisions do
				Part.CanCollide = CanCollide
			end

		end
	end,

	LockServer = function(Player: Player)
		local Val: BoolValue = workspace.Configuration.LockServer
		Val.Value = not Val.Value
	end,

	KickOnDeath = function(Player: Player)
		local Val: BoolValue = workspace.Configuration.KickOnDeath
		Val.Value = not Val.Value
	end,

	ShutdownServer = function()
		for _, Player in Players:GetPlayers() do
			Player:Kick("The server is shutting down")
		end

		Players.MaxPlayers = 0
	end,

	RefreshServer = function()
		if PS_OwnerId == 0 then
			TeleportService:TeleportAsync(game.PlaceId, Players:GetPlayers())
		else
			TeleportService:TeleportPartyAsync(game.PlaceId, Players:GetPlayers())
		end
	end,
	
	StormActive = function(Player: Player)
		local Val: BoolValue = workspace.Configuration.StormActive
		Val.Value = not Val.Value


		local CurrValue = Val.Value

		if CurrValue then
			local StormBarrier = Assets.Models:FindFirstChild("StormBarrier")
			if not StormBarrier then return end

			StormBarrier.Parent = workspace.Thrown


			local StartTime = os.clock()
			local StartSize = StormBarrier.Size
			local LastSpeed = workspace.Configuration.StormSpeedMultiplier.Value

			StormStep = RNS.Heartbeat:Connect(function()
				local NextSize = workspace.Configuration.StormSpeedMultiplier.Value == 0 and StormBarrier.Size or StartSize:Lerp(Vector3.new(0, 800, 0), TweenService:GetValue((os.clock() - StartTime) / (600 * (1/workspace.Configuration.StormSpeedMultiplier.Value)), Enum.EasingStyle.Linear, Enum.EasingDirection.In))
				if workspace.Configuration.StormSpeedMultiplier.Value == 0 then
					NextSize = StormBarrier.Size
				elseif LastSpeed == 0 then
					StartTime = os.clock()
					StartSize = StormBarrier.Size
				end

				StormBarrier.Size = NextSize

				if StormBarrier.Size == Vector3.new(0, 800, 0) then
					StormStep:Disconnect()
					StormStep = nil
				end

				LastSpeed = workspace.Configuration.StormSpeedMultiplier.Value


				for _, Character: Model in workspace.Live:GetChildren() do
					if not Character:IsA("Model") or not Character:FindFirstChild("Humanoid") then continue end

					if (Character.PrimaryPart.Position - MapCenter).Magnitude > StormBarrier.Size.X/2 and not iFramesService:HasiFrame(Character, "M1") then
						Character.Humanoid:TakeDamage(0.05 * workspace.Configuration.StormDamageMultiplier.Value)
					end
				end
			end)

		else
			local StormBarrier = workspace.Thrown:FindFirstChild("StormBarrier")
			if not StormBarrier then return end

			StormBarrier.Parent = Assets.Models

			if StormStep then
				StormStep:Disconnect()
				StormStep = nil
			end
		end
	end,

	ResetStorm = function(Player: Player)
		local StormBarrier: MeshPart = workspace.Thrown:FindFirstChild("StormBarrier") or Assets.Models:FindFirstChild("StormBarrier")
		if not StormBarrier then return end

		StormBarrier.Size = Vector3.new(1000, 800, 1000)

		if StormStep then
			StormStep:Disconnect()
			StormStep = nil
		end


		if StormBarrier.Parent == workspace.Thrown then
			local StartTime = os.clock()
			local StartSize = StormBarrier.Size
			local LastSpeed = workspace.Configuration.StormSpeedMultiplier.Value

			StormStep = RNS.Heartbeat:Connect(function()
				local NextSize = workspace.Configuration.StormSpeedMultiplier.Value == 0 and StormBarrier.Size or  StartSize:Lerp(Vector3.new(0, 800, 0), TweenService:GetValue((os.clock() - StartTime) / (600 * (1/workspace.Configuration.StormSpeedMultiplier.Value)), Enum.EasingStyle.Linear, Enum.EasingDirection.In))
				if workspace.Configuration.StormSpeedMultiplier.Value == 0 then
					NextSize = StormBarrier.Size
				elseif LastSpeed == 0 then
					StartTime = os.clock()
					StartSize = StormBarrier.Size
				end

				StormBarrier.Size = NextSize

				if StormBarrier.Size == Vector3.new(0, 800, 0) then
					StormStep:Disconnect()
					StormStep = nil
				end

				LastSpeed = workspace.Configuration.StormSpeedMultiplier.Value


				for _, Character: Model in workspace.Live:GetChildren() do
					if not Character:IsA("Model") or not Character:FindFirstChild("Humanoid") then continue end

					if (Character.PrimaryPart.Position - MapCenter).Magnitude > StormBarrier.Size then
						Character.Humanoid:TakeDamage(0.05 * workspace.Configuration.StormDamageMultiplier.Value)
					end
				end
			end)
		end
	end,

	StormSpeedMultiplier = function(Player: Player)
		local NewSpeed = workspace.Configuration.StormSpeedMultiplier.Value + 0.5
		if NewSpeed > 10 then
			NewSpeed = 0
		end

		workspace.Configuration.StormSpeedMultiplier.Value = NewSpeed
	end,

	StormDamageMultiplier = function(Player: Player)
		local NewSpeed = workspace.Configuration.StormDamageMultiplier.Value + 0.5
		if NewSpeed > 10 then
			NewSpeed = 0
		end

		workspace.Configuration.StormDamageMultiplier.Value = NewSpeed
	end,

	InstantAwk = function(Player: Player)
		local Val: BoolValue = Player.Commands.InstantAwk
		Val.Value = not Val.Value

		local CurrValue = Val.Value

		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				goalPlayer.Commands.InstantAwk.Value = CurrValue
			end

			workspace.Configuration.InstantAwk.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer ~= Player then
					goalPlayer.Commands.InstantAwk.Value = CurrValue
				end
			end

			workspace.Configuration.InstantAwk.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Me' then
			Player.Commands.InstantAwk.Value = CurrValue
		end
	end,

	NoAwk = function(Player: Player)
		local Val: BoolValue = Player.Commands.NoAwk
		Val.Value = not Val.Value

		local CurrValue = Val.Value

		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				goalPlayer.Commands.NoAwk.Value = CurrValue
			end

			workspace.Configuration.NoAwk.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer ~= Player then
					goalPlayer.Commands.NoAwk.Value = CurrValue
				end
			end

			workspace.Configuration.NoAwk.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Me' then
			Player.Commands.NoAwk.Value = CurrValue
		end
	end,
	
	Bring = function(Player: Player)
		if not Player.Character or not Player.Character:FindFirstChild('HumanoidRootPart') then return end
		
		for _, goalCharacter: Model in workspace.Live:GetChildren() do
			if goalCharacter ~= Player.Character then
				goalCharacter:PivotTo(Player.Character.HumanoidRootPart.CFrame)
			end
		end
	end,
	
	NoFatigue = function(Player: Player)
		local Val: BoolValue = Player.Commands.NoFatigue
		Val.Value = not Val.Value

		local CurrValue = Val.Value

		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				goalPlayer.Commands.NoFatigue.Value = CurrValue
			end

			workspace.Configuration.NoFatigue.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer ~= Player then
					goalPlayer.Commands.NoFatigue.Value = CurrValue
				end
			end

			workspace.Configuration.NoFatigue.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Me' then
			Player.Commands.NoFatigue.Value = CurrValue
		end
	end,
	
	NoStun = function(Player: Player)
		local Val: BoolValue = Player.Commands.NoStun
		Val.Value = not Val.Value
		
		local CurrValue = Val.Value
		
		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				goalPlayer.Commands.NoStun.Value = CurrValue
			end
			
			workspace.Configuration.NoStun.Value = CurrValue
			
		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer ~= Player then
					goalPlayer.Commands.NoStun.Value = CurrValue
				end
			end
			
			workspace.Configuration.NoStun.Value = CurrValue
			
		elseif Player.Commands.Mode.Value == 'Me' then
			Player.Commands.NoStun.Value = CurrValue
		end
	end,
	
	OnlyFinishers = function(Player: Player)
		local Val: BoolValue = Player.Commands.OnlyFinishers
		Val.Value = not Val.Value
		
		local CurrValue = Val.Value

		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				goalPlayer.Commands.OnlyFinishers.Value = CurrValue
			end
			
			workspace.Configuration.OnlyFinishers.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer ~= Player then
					goalPlayer.Commands.OnlyFinishers.Value = CurrValue
				end
			end
			
			workspace.Configuration.OnlyFinishers.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Me' then
			Player.Commands.OnlyFinishers.Value = CurrValue
		end
	end,
	
	Heal = function(Player: Player)
		if Player.Commands.Mode.Value == 'All' then
			for _, Character: Model in workspace.Live:GetChildren() do
				healCharacter(Character)
			end
			
		elseif Player.Commands.Mode.Value == 'Others' then
			for _, Character: Model in workspace.Live:GetChildren() do
				if Character ~= Player.Character then
					healCharacter(Character)
				end
			end
			
		elseif Player.Commands.Mode.Value == 'Me' then
			local Character = Player.Character
			if Character then
				healCharacter(Character)
			end
		end
	end,
	
	Kill = function(Player: Player)
		if Player.Commands.Mode.Value == 'All' then
			for i, Plr in next, Players:GetPlayers() do
				for i, Character in next, workspace.Live:GetChildren() do
					if Character:IsA("Model") then
						if Character:FindFirstChildOfClass("Humanoid") then
							local Humanoid: Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
							
							task.spawn(function()
								while task.wait() do
									if Humanoid.Health <= 0 then
										break
									end
									
									Humanoid.Health = 0
								end
							end)	
						end
					end
				end
			end

		elseif Player.Commands.Mode.Value == 'Others' then
			for i, Character in next, workspace.Live:GetChildren() do
				if Character:IsA("Model") then
					if Character.Name ~= Player.Name then
						if Character:FindFirstChildOfClass("Humanoid") then
							local Humanoid: Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
							
							task.spawn(function()
								while task.wait() do
									if Humanoid.Health <= 0 then
										break
									end
									
									Humanoid.Health = 0
								end
							end)
						end
					end
				end
			end

		elseif Player.Commands.Mode.Value == 'Me' then
			local Character = Player.Character
			local Humanoid: Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

			task.spawn(function()
				while task.wait() do
					if Humanoid.Health <= 0 then
						break
					end
					
					Humanoid.Health = 0
				end
			end)
		end
	end,
	
	Respawn = function(Player: Player)
		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				goalPlayer:LoadCharacter()
				if goalPlayer:GetAttribute("Awakened") then
					goalPlayer.AwakeningProgress.Value = 0
				end
			end
			
		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer ~= Player then
					goalPlayer:LoadCharacter()
					if goalPlayer:GetAttribute("Awakened") then
						goalPlayer.AwakeningProgress.Value = 0
					end
				end
			end
			
		elseif Player.Commands.Mode.Value == 'Me' then
			Player:LoadCharacter()
			
			if Player:GetAttribute("Awakened") then
				Player.AwakeningProgress.Value = 0
			end
		end
	end,
	
	Ragdoll = function(Player: Player)
		if Player.Commands.Mode.Value == 'All' then
			for _, Character: Model in workspace.Live:GetChildren() do
				ragdollCharacter(Character)
			end
			
		elseif Player.Commands.Mode.Value == 'Others' then
			for _, Character: Model in workspace.Live:GetChildren() do
				if Character ~= Player.Character then
					ragdollCharacter(Character)
				end
			end
			
		elseif Player.Commands.Mode.Value == 'Me' then
			local Character = Player.Character
			if Character then
				ragdollCharacter(Character)
			end
		end
	end,
	
	Counter = function(Player: Player)
		Player.Commands.Counter.Value = not Player.Commands.Counter.Value

		local Character = Player.Character

		if Player.Commands.Counter.Value == true then
			local HumRP: BasePart = Character.HumanoidRootPart
			local Humanoid: Humanoid = Character.Humanoid

			Character:AddTag('Countering')
			Character:AddTag("SpecialCounter")

			CounterConnections[Character] = Character.ChildAdded:Connect(function(child: ObjectValue?)
				if child.Name == 'DamagedLog' and child:HasTag('IsM1') then
					local Stun = StunHandler:Stun(Character, nil, true)

					local EnemyCharacter: Model = child.Value
					local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

					local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true)

					Character:AddTag('Character')
					EnemyCharacter:AddTag('CantRotate')

					iFramesService:AddAlliFrames(EnemyCharacter)
					iFramesService:AddAlliFrames(Character)


					local HitAnim = MoveAnims.Other["Counter Variant"].User
					local VictimAnim = MoveAnims.Other["Counter Variant"].Victim

					local HitTrack, HitEvents = AnimationService:getAnimationTrack(Character, HitAnim)
					local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnim)


					HumRP.Anchored = true


					if EnemyPlayer then
						EnemyPlayer:SetAttribute("Cutscenes", true)
					end
					Player:SetAttribute("Cutscenes", true)


					local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0))


					table.insert(HitEvents, HitTrack:GetMarkerReachedSignal("finalstab"):Once(function()
						if Weld ~= nil then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						EnemyHumRP.Anchored = true
						EnemyCharacter:RemoveTag('CantRotate')

						DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, true, true, true)
					end))


					VictimTrack.Stopped:Once(function()
						if Weld ~= nil then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						EnemyHumRP.Anchored = true
						EnemyCharacter:RemoveTag('CantRotate')
						if EnemyPlayer then
							EnemyPlayer:SetAttribute("Cutscenes", nil)
						end
					end)

					HitTrack.Stopped:Once(function()
						if Weld ~= nil then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						StunHandler:Unstun(Character, Stun)
						iFramesService:RemoveAlliFrames(Character)
						HumRP.Anchored = false
						Character:RemoveTag('CantRotate')
						Player:SetAttribute("Cutscenes", nil)
					end)


					AnimationService:stopAll(Character)
					AnimationService:stopAll(EnemyCharacter)

					AnimationService:playAnimation(Character, HitAnim)
					AnimationService:playAnimation(EnemyCharacter, VictimAnim)
					Weld:Start()

					ReplicateSet:FireAllClients("DummyCounter", { Stage = "Start", Char = Character, EChar = EnemyCharacter, StartAnim = HitAnim.AnimationId })
				end
			end)
		else
			Character:RemoveTag('Countering')
			Character:RemoveTag("SpecialCounter")

			if not CounterConnections[Character] then return end

			CounterConnections[Character]:Disconnect()
			CounterConnections[Character] = nil
		end
	end,
	
	TpDash = function(Player: Player)
		local Character = Player.Character
		local Val: BoolValue = Player.Commands.TpDash
		Val.Value = not Val.Value

		local CurrValue = Val.Value

		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				goalPlayer.Commands.TpDash.Value = CurrValue
				if goalPlayer.Character then
					goalPlayer.Character:SetAttribute("TpDash", CurrValue)
				end
			end

			workspace.Configuration.TpDash.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer ~= Player then
					goalPlayer.Commands.TpDash.Value = CurrValue

					if goalPlayer.Character then
						goalPlayer.Character:SetAttribute("TpDash", CurrValue)
					end
				end
			end

			workspace.Configuration.TpDash.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Me' then
			Player.Commands.TpDash.Value = CurrValue
			Character:SetAttribute("TpDash", CurrValue)
		end
	end,

	NoRespawn = function(Player: Player)
		local Val: BoolValue = Player.Commands.NoRespawn
		Val.Value = not Val.Value

		local CurrValue = Val.Value

		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				goalPlayer.Commands.NoRespawn.Value = CurrValue
			end

			workspace.Configuration.NoRespawn.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer ~= Player then
					goalPlayer.Commands.NoRespawn.Value = CurrValue
				end
			end

			workspace.Configuration.NoRespawn.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Me' then
			Player.Commands.NoRespawn.Value = CurrValue
		end
	end,

	NoRagdoll = function(Player: Player)
		local Val: BoolValue = Player.Commands.NoRagdoll
		Val.Value = not Val.Value

		local CurrValue = Val.Value

		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				goalPlayer.Commands.NoRagdoll.Value = CurrValue
			end

			workspace.Configuration.NoRagdoll.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer ~= Player then
					goalPlayer.Commands.NoRagdoll.Value = CurrValue
				end
			end

			workspace.Configuration.NoRagdoll.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Me' then
			Player.Commands.NoRagdoll.Value = CurrValue
		end
	end,

	NoBlock = function(Player: Player)
		local Val: BoolValue = Player.Commands.NoBlock
		Val.Value = not Val.Value

		local CurrValue = Val.Value

		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				goalPlayer.Commands.NoBlock.Value = CurrValue
			end

			workspace.Configuration.NoBlock.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer ~= Player then
					goalPlayer.Commands.NoBlock.Value = CurrValue
				end
			end

			workspace.Configuration.NoBlock.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Me' then
			Player.Commands.NoBlock.Value = CurrValue
		end
	end,
	
	NoAttack = function(Player: Player)
		local Val: BoolValue = Player.Commands.NoAttack
		Val.Value = not Val.Value

		local CurrValue = Val.Value

		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				goalPlayer.Commands.NoAttack.Value = CurrValue
			end

			workspace.Configuration.NoAttack.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer ~= Player then
					goalPlayer.Commands.NoAttack.Value = CurrValue
				end
			end

			workspace.Configuration.NoAttack.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Me' then
			Player.Commands.NoAttack.Value = CurrValue
		end
	end,

	NoReset = function(Player: Player)
		local Val: BoolValue = Player.Commands.NoReset
		Val.Value = not Val.Value

		local CurrValue = Val.Value

		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				goalPlayer.Commands.NoReset.Value = CurrValue
			end

			workspace.Configuration.NoReset.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer ~= Player then
					goalPlayer.Commands.NoReset.Value = CurrValue
				end
			end

			workspace.Configuration.NoReset.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Me' then
			Player.Commands.NoReset.Value = CurrValue
		end
	end,

	NoMovement = function(Player: Player)
		local Character = Player.Character
		local Val: BoolValue = Player.Commands.NoMovement
		Val.Value = not Val.Value

		local CurrValue = Val.Value

		local function TriggerState(GoalChar: Model)
			if not GoalChar then return end

			GoalChar:SetAttribute("DefaultRunSpeed", CurrValue == true and 0 or 25)
			GoalChar:SetAttribute("DefaultWalkSpeed", CurrValue == true and 0 or 16)
			GoalChar:SetAttribute("DefaultJumpPower", CurrValue == true and 0 or 50)


			if CurrValue ~= true then
				local ChangedConnection: RBXScriptConnection
				ChangedConnection = GoalChar.AttributeChanged:Connect(function(Attribute)
					if Val.Value == false then return ChangedConnection:Disconnect() end

					if Attribute == "DefaultRunSpeed" or Attribute == "DefaultWalkSpeed" or Attribute == "DefaultJumpPower" then
						GoalChar:SetAttribute("DefaultRunSpeed", 0)
						GoalChar:SetAttribute("DefaultWalkSpeed", 0)
						GoalChar:SetAttribute("DefaultJumpPower", 0)

						GoalChar.Humanoid.WalkSpeed = 0
						GoalChar.Humanoid.JumpPower = 0
					end
				end)
			end
		end

		if Player.Commands.Mode.Value == 'All' then
			for _, goalPlayer in Players:GetPlayers() do
				goalPlayer.Commands.NoMovement.Value = CurrValue
				TriggerState(goalPlayer.Character)
			end

			workspace.Configuration.NoMovement.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Others' then
			for _, goalPlayer in Players:GetPlayers() do
				if goalPlayer ~= Player then
					goalPlayer.Commands.NoMovement.Value = CurrValue
					TriggerState(goalPlayer.Character)
				end
			end

			workspace.Configuration.NoMovement.Value = CurrValue

		elseif Player.Commands.Mode.Value == 'Me' then
			Player.Commands.NoMovement.Value = CurrValue
			TriggerState(Character)

		end
	end,

	AttackSMult = function(Player: Player)
		local NewMult = workspace.Configuration.AttackSMult.Value + 0.5
		if NewMult > 10 then
			NewMult = 0
		end

		workspace.Configuration.AttackSMult.Value = NewMult
	end,

	HealthMult = function(Player: Player)
		local NewMult = workspace.Configuration.HealthMult.Value + 0.5
		if NewMult > 10 then
			NewMult = 0
		end

		workspace.Configuration.HealthMult.Value = NewMult
	end,

	DamageMult = function(Player: Player)
		local NewMult = workspace.Configuration.DamageMult.Value + 0.5
		if NewMult > 10 then
			NewMult = 0
		end

		workspace.Configuration.DamageMult.Value = NewMult
	end,

	RegenMult = function(Player: Player)
		local NewMult = workspace.Configuration.RegenMult.Value + 0.5
		if NewMult > 10 then
			NewMult = 0
		end

		workspace.Configuration.RegenMult.Value = NewMult
	end,

	SpeedMult = function(Player: Player)
		local NewMult = workspace.Configuration.SpeedMult.Value + 0.5
		if NewMult > 10 then
			NewMult = 0
		end

		workspace.Configuration.SpeedMult.Value = NewMult
	end,

	GravityMult = function(Player: Player)
		local NewMult = workspace.Configuration.GravityMult.Value + 0.5
		if NewMult > 10 then
			NewMult = 0
		end

		workspace.Configuration.GravityMult.Value = NewMult


		workspace.Gravity = DefaultGravity * NewMult
	end,
}

local function GivePermission(Player: Player)
	SetCommand.OnServerEvent:Connect(function(p, ConfigName, Params)
		if p ~= Player then return end
		
		ConfigFunctions[ConfigName](Player, Params)
	end)
end



--Runtime
shared.giveCommands = function(Player: Player)
	Remotes.Comunicator.Set:FireClient(Player, 'PS+')
	GivePermission(Player)

	local Commands = Player:WaitForChild('Commands')

	if workspace.Configuration.Mode.Value == 'All' then
		for _,v in workspace.Configuration:GetChildren() do
			if v.Name ~= 'Mode' then
				Commands:WaitForChild(v.Name).Value = v.Value
			end
		end
		
	elseif workspace.Configuration.Mode.Value == 'Me' then
		for _,v in workspace.Configuration:GetChildren() do
			if v.Name ~= 'Mode' then
				Commands:WaitForChild(v.Name).Value = v.Value
			end
		end
	end
end