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



local Utility = shared.Utility
local WeldSystem = require(ReplicatedModules.WeldSystem)
local SoundHandler = require(ReplicatedModules.SoundHandler)

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
MapRayParams.FilterDescendantsInstances = { workspace.Map }
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		local Hit = false
		local CounterConnection
		
		
		local StartAnimation = MoveAnims["Cursed Child"].Reset.Windup
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}
		
		
		
		StartTrack.Stopped:Once(function()
			for _,v in StartEvents do
				v:Disconnect()
			end

			if Hit == false then
				StunHandler:Unstun(Character, Stun)
			end

			if CounterConnection then
				CounterConnection:Disconnect()
				CounterConnection = nil
			end

			Character:RemoveTag("Countering")
		end)
		
		
		Character:AddTag("Countering")
		
		
		CounterConnection = Character.ChildAdded:Connect(function(child: ObjectValue?)
			if child.Name == 'DamagedLog' and child:HasTag('Counterable') then
				Character:RemoveTag("Countering")
				CounterConnection:Disconnect()
				CounterConnection =  nil

				Hit = true


				local playerClass = shared.playerClasses[Player.UserId]
				if playerClass then
					playerClass.TitlesProgress.Counters += 1
					Player:SetAttribute("CountersProgress", playerClass.TitlesProgress.Counters)
				end
				

				local EnemyCharacter: Model = child.Value
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				
				
				Player:SetAttribute("Cutscenes", true)

				if EnemyPlayer then
					EnemyPlayer:SetAttribute("Cutscenes", true)
				end
				
				
				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)

				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)

				Character:AddTag("CantRotate")
				EnemyCharacter:AddTag("CantRotate")
				
				
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				
				
				task.delay(13, function()
					ReplicateEffects_Set:FireAllClients("Reset", { Char = Character, Stage = "Explosion" })
					
					
					Player:SetAttribute("Cutscenes", nil)

					if EnemyPlayer then
						EnemyPlayer:SetAttribute("Cutscenes", nil)
					end
					
					iFramesService:RemoveAlliFrames(Character)
					StunHandler:Unstun(Character, Stun)
					CollisionsModule:SetCollisionGroup(Character, "Players")
					Character:RemoveTag("CantRotate")
					
					
					iFramesService:RemoveAlliFrames(EnemyCharacter)
					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
					EnemyCharacter:RemoveTag("CantRotate")
					
					
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 100, nil, nil, false, false, true, false, true, nil, nil)
					DamageHandler:TakeDamage(Character, Humanoid, 50, nil, nil, false, false, true, false, true, nil, nil)
					
					
					RagdollHandler.ragdoll(EnemyHumanoid, 2)
					RagdollHandler.ragdoll(Humanoid, 2)
					
					
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(math.huge, math.huge, math.huge), Velocity = HumRP.CFrame.LookVector * 100 + Vector3.new(0, 15, 0) })
					NewKnockback:Knockback(Character, { KnockbackType = "Velocity", MaxForce = Vector3.new(math.huge, math.huge, math.huge), Velocity = HumRP.CFrame.LookVector * 100 + Vector3.new(0, 15, 0) })
				end)
				
				
				shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "Reset", { Char = Character, Stage = "Counter" } })
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
		
		
		ReplicateEffects_Set:FireAllClients("Reset", { Char = Character, Stage = "Start", WindupAnim = StartAnimation.AnimationId })
	end
}