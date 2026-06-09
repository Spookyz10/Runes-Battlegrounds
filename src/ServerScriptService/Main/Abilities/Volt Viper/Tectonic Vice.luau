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
		iFramesService:AddBaseiFrames(Character)
		
		
		local StartupAnimation = MoveAnims["Volt Viper"].tectonicvice.Startup
		local StartupTrack, StartupEvents = AnimationService:getAnimationTrack(Character, StartupAnimation)
		
		
		local Hit = false
		
		
		table.insert(StartupEvents, StartupTrack:GetMarkerReachedSignal("Grab"):Once(function()
			ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 3, Last = 0.1 })
			
			HitboxHandler:SimpleOnce(HumRP, Vector3.new(8, 5, 13.5), CFrame.new(0, 0, -9.25), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter:HasTag('Ragdolled') then return end

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, false, false, true, false, false, nil, 10)
				Hit = true
				
				
				if HitInfo.Finisher == true then
					local VictimAnimation = MoveAnims["Volt Viper"].tectonicvice["Victim Finisher"]
					local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)

					local UserAnimation = MoveAnims["Volt Viper"].tectonicvice["User Finisher"]
					local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)


					local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -27.5), -1)
					local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
					
					
					Character:AddTag('CantRotate')
					EnemyCharacter:AddTag('CantRotate')
					
					iFramesService:AddAlliFrames(Character)
					iFramesService:AddAlliFrames(EnemyCharacter)
					
					CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
					
					
					task.delay(0.1, function()
						EnemyHumRP.Anchored = true
					end)
					
					
					table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("LastHit"):Once(function()
						task.spawn(function()
							EnemyHumRP.Anchored = false
						end)
						
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						EnemyCharacter:RemoveTag('CantRotate')
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

						RagdollHandler.ragdoll(EnemyHumanoid, 2.25)
						DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, true, true, true, nil, nil)
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 4.5 } })
					end))
					
					
					VictimTrack.Stopped:Once(function()
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						EnemyCharacter:RemoveTag('CantRotate')
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
					end)
					
					UserTrack.Stopped:Once(function()
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						StunHandler:Unstun(Character, Stun)
						Character:RemoveTag('CantRotate')
						iFramesService:RemoveAlliFrames(Character)
						CollisionsModule:SetCollisionGroup(Character, "Players")
					end)
					
					
					AnimationService:stopAll(Character)
					AnimationService:stopAll(EnemyCharacter)
					AnimationService:playAnimation(Character, UserAnimation)
					AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
					
					
					Weld:Start(nil, EnemyPlayer, Player)
					
					
					ReplicateEffects_Set:FireAllClients("tectonicvice", { Stage = "Hit", Char = Character, EChar = EnemyCharacter, isFinisher = true, Animation = UserAnimation.AnimationId })
					
					SoundsModule:PlaySound(MoveSounds["Volt Viper"]["tectonic vice"].finisher, Character.Torso)
				else
					local VictimAnimation = MoveAnims["Volt Viper"].tectonicvice.Victim
					local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)

					local UserAnimation = MoveAnims["Volt Viper"].tectonicvice.User
					local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)
					
					
					local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, 0), -1)
					local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
					
					
					Character:AddTag('CantRotate')
					EnemyCharacter:AddTag('CantRotate')
					
					iFramesService:AddAlliFrames(Character)
					iFramesService:AddAlliFrames(EnemyCharacter)
					
					CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
					
					
					table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("LastHit"):Once(function()
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end
						
						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						EnemyCharacter:RemoveTag('CantRotate')
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
						
						RagdollHandler.ragdoll(EnemyHumanoid, 2.25)
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, false, false, true, false, false, nil, nil)
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 5 } })
					end))
					
					
					VictimTrack.Stopped:Once(function()
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end
						
						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						EnemyCharacter:RemoveTag('CantRotate')
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
					end)
					
					UserTrack.Stopped:Once(function()
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end
						
						StunHandler:Unstun(Character, Stun)
						Character:RemoveTag('CantRotate')
						iFramesService:RemoveAlliFrames(Character)
						CollisionsModule:SetCollisionGroup(Character, "Players")
					end)
					
					
					AnimationService:stopAll(Character)
					AnimationService:stopAll(EnemyCharacter)
					AnimationService:playAnimation(Character, UserAnimation)
					AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
					
					
					Weld:Start(nil, EnemyPlayer, Player)
					
					
					ReplicateEffects_Set:FireAllClients("tectonicvice", { Stage = "Hit", Char = Character, EChar = EnemyCharacter, isFinisher = false, Animation = UserAnimation.AnimationId })
					
					SoundsModule:PlaySound(MoveSounds["Volt Viper"]["tectonic vice"].hit, HumRP)
				end
			end)
		end))
		
		
		StartupTrack.Stopped:Once(function()
			HumRP.Anchored = false
			ReplicateEffects_Set:FireAllClients("clearVelocities", { Char = Character })
			
			if not Hit then
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartupAnimation)
		
		
		ReplicateEffects_Set:FireAllClients("tectonicvice", { Stage = "Start", Char = Character, Animation = StartupAnimation.AnimationId })
		ReplicateEffects_Set:FireClient(Player, "tectonicviceVelocity", { Type = "Start", Char = Character, Animation = StartupAnimation.AnimationId })
		
		SoundsModule:PlaySound(MoveSounds["Volt Viper"]["tectonic vice"].startup, HumRP)
	end
}