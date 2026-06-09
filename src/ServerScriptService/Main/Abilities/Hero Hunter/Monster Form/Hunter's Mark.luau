local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")


local ServerModules = ServerStorage.Modules

local ReplicatedModules = ReplicatedStorage.Modules
local RemotesContainer = ReplicatedStorage.Remotes


local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local RagdollHandler = require(ServerModules.RagdollHandler)
local NewKnockback = require(ServerModules.BodymoverService)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local WeaponsHandler = require(ServerModules.WeaponsHandler)
local CollisionsModule = require(ServerModules.CollisionsModule)
local SoundsModule = require(ServerModules.SoundsModule)
local KnockbackModule = require(ServerModules.KnockbackModule)
local ReplicatedHitbox = require(ServerModules.ReplicatedHitboxes)
local StatesHandler = require(ServerModules.StatesHandler)



local Utility = shared.Utility
local WeldSystem = require(ReplicatedModules.WeldSystem)
local SoundHandler = require(ReplicatedModules.SoundHandler)
local Trove = require(ReplicatedModules.Trove)

local Sounds = ServerStorage.Assets.Sounds
local Animations = ServerStorage.Assets.Animations
local Models = ServerStorage.Assets.Models


local Weapons = Models.Weapons

local MoveAnims = Animations.Moves
local MoveSounds = Sounds.Moves

local CombatAnims = Animations.Combat
local CombatSounds = Sounds.Combat


local ComSet = RemotesContainer.Comunicator.Set
local ComGet = RemotesContainer.Comunicator.Get


local ReplicateEffects_Set = RemotesContainer.Replicate.Set


local rad = math.rad
local StartAirDetect = ServerStorage.Bindables.AirDetector

local Assets = shared.Assets

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = {
	workspace.Map
}
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart
		local Tag = os.clock() + Player.UserId
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)
		
		
		local StartupAnimation = MoveAnims["Hero Hunter"]["Monster Form"]["Hunter's Mark"].Startup
		local StartupTrack = AnimationService:getAnimationTrack(Character, StartupAnimation)
		
		
		local Hit = false
		
		
		local runmoveme = Instance.new("BodyVelocity")
		runmoveme.MaxForce = Vector3.new(40000, 0, 40000)
		runmoveme.Name = "moveme"
		runmoveme:SetAttribute("EndExclusion", true)
		runmoveme:SetAttribute("Fallout", 1)
		runmoveme:SetAttribute("Speed", 60)
		runmoveme.Parent = HumRP
		
		
		task.delay(1.35, function()
			if not StartupTrack.IsPlaying then return end
			
			if runmoveme then
				runmoveme:Destroy()
				runmoveme = nil
			end
			
			HitboxHandler:SimpleOnce(HumRP, Vector3.new(20, 20, 20), CFrame.new(0, 0, -13.5), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				
				local Ragdolled = EnemyCharacter:HasTag('Ragdolled')
				local inAir = EnemyCharacter:FindFirstChild("inAir") or (EnemyCharacter:GetAttribute("TouchedGround") and tick() - EnemyCharacter:GetAttribute("TouchedGround") <= 0.25)
				
				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or (Ragdolled and not inAir)  then return end
				
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 1.5, nil, nil, false, EnemyCharacter:HasTag('DEATH') and true or false, true, true, false, nil, nil)
				if HitInfo.Countered then return end
				Hit = true
				
				
				if runmoveme then
					runmoveme:Destroy()
					runmoveme = nil
				end
				
				
				Character.Archivable = true
				
				local Bind = Instance.new("Folder")
				Bind.Name = "Hunter's Mark" .. Tag
				Bind.Parent = Character
				
				
				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
				end
				
				
				local MovementContainer = {}
				local Assets = {}
				
				
				local function Movement(Time)
					for _, Vel in pairs(MovementContainer) do
						Vel:Destroy()
					end
					
					local moveme = Instance.new("BodyVelocity")
					
					table.insert(Assets, moveme)
					table.insert(MovementContainer, moveme)
					
					moveme.MaxForce = Vector3.new(40000, 0, 40000)
					moveme.Name = "moveme"
					moveme:SetAttribute("EndExclusion", true)
					moveme:SetAttribute("Fallout", 0.9)
					moveme:SetAttribute("Speed", 40.5)
					moveme.Parent = HumRP
					
					Debris:AddItem(moveme, Time or 5)
				end
				
				
				Character:AddTag("CantRotate")
				EnemyCharacter:AddTag("CantRotate")
				
				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)
				
				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
				
				
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), -1)
				
				
				local UserAnimation = MoveAnims["Hero Hunter"]["Monster Form"]["Hunter's Mark"].User
				local VictimAnimation = MoveAnims["Hero Hunter"]["Monster Form"]["Hunter's Mark"].Victim

				local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
				local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)
				
				
				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("push"):Connect(function()
					Movement(0.5)
					
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, nil, nil, false, false, true, true, false, nil, nil)
				end))
				
				
				local function OnStop(IsUser)
					if IsUser then
						for _,v in Assets do
							if v and v.Parent then
								v:Destroy()
							end
						end

						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						StunHandler:Unstun(Character, Stun)
						iFramesService:RemoveAlliFrames(Character)
						CollisionsModule:SetCollisionGroup(Character, "Players")
						Character:RemoveTag("CantRotate")

						if Bind then
							Bind:Destroy()
							Bind = nil
						end

						if Player then
							ReplicateEffects_Set:FireClient(Player, "ResetCamera")
						end

						Character:SetPrimaryPartCFrame(CFrame.lookAlong(ComGet:InvokeClient(Player, { Func = "GetCF", Object = Character.Torso }).Position, HumRP.CFrame.LookVector))
						
					else
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
						EnemyCharacter:RemoveTag("CantRotate")
						
						if EnemyPlayer then
							ReplicateEffects_Set:FireClient(EnemyPlayer, "ResetCamera")
						end
					end
				end
				
				
				task.delay(8.08, function()
					AnimationService:stopAll(EnemyCharacter)
					
					pcall(function()
						OnStop(false)
					end)
					
					RagdollHandler.ragdoll(EnemyHumanoid, 2.25)
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(100000, 50000, 100000), Velocity = -HumRP.CFrame.LookVector * Vector3.new(85, 0 ,85) + Vector3.new(0, 0, 0) })
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 25, nil, nil, false, false, true, true, true, nil, nil)
				end)
				
				task.delay(9.04, function()
					AnimationService:stopAll(Character)
					
					pcall(function()
						OnStop(true)
					end)
				end)
				
				
				VictimTrack.Stopped:Once(function()
					pcall(function()
						OnStop(false)
					end)
				end)
				
				UserTrack.Stopped:Once(function()
					pcall(function()
						OnStop(true)
					end)
				end)
				
				
				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)
				AnimationService:playAnimation(Character, UserAnimation)
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
				
				
				Weld:Start(nil, EnemyPlayer, Player)
				
				ReplicateEffects_Set:FireAllClients("HuntersMark", { Char = Character, EChar = EnemyCharacter, Stage = "Hit", Bind = Bind })
				
				SoundsModule:PlaySound(MoveSounds["Hero Hunter"]["Monster Form"]["Hunter's Mark"].Hit, HumRP)
			end)
		end)
		
		
		StartupTrack.Stopped:Once(function()
			if runmoveme then
				runmoveme:Destroy()
				runmoveme = nil
			end
			
			if not Hit then
				StatesHandler.DoEndLag(Player, Stun, 0.3)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartupAnimation)
		
		ReplicateEffects_Set:FireAllClients("HuntersMark", { Char = Character, EChar = nil, Stage = "Start" })
		
		SoundsModule:PlaySound(MoveSounds["Hero Hunter"]["Monster Form"]["Hunter's Mark"].Startup, HumRP)
		SoundsModule:PlaySound(MoveSounds["Hero Hunter"]["Monster Form"]["Hunter's Mark"].Run, HumRP)
	end
}