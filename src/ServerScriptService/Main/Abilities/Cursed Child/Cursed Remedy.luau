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
MapRayParams.FilterDescendantsInstances = {
	workspace.Map.Arena, 
	workspace.Map.Miscellaneous, 
	workspace.Map.Borders
}
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)
		
		
		local WindupAnimation = MoveAnims["Cursed Child"]["Cursed Remedy"].Windup
		local WindupTrack = AnimationService:getAnimationTrack(Character, WindupAnimation)
		local WindupEvents = {}
		
		
		local Hit = false
		
		
		WindupEvents["hit"] = WindupTrack:GetMarkerReachedSignal("hit"):Once(function()
			local Hitbox = ReplicatedHitbox.new(Player)
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(9, 9, 10)
			Hitbox.Offset = CFrame.new(0, 0, -3.5)
			Hitbox.Ignore = { Character }
			Hitbox.destroyAfterOnce = true
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				
				
				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead or EnemyCharacter:HasTag("Ragdolled") then return end
				
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, false, false, nil, 40)
				Hit = true
				
				
				if HitInfo.Finisher == true then
					local VictimAnimation = MoveAnims["Cursed Child"]["Cursed Remedy"].Finisher.Victim
					local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)

					local UserAnimation = MoveAnims["Cursed Child"]["Cursed Remedy"].Finisher.User
					local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)
					
					
					local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, rad(-180), 0), -1)
					local SecondWeld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -10) * CFrame.Angles(0, rad(-180), 0), -1)
					local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
					
					
					EnemyCharacter:AddTag('CantRotate')
					iFramesService:AddAlliFrames(EnemyCharacter)
					
					CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
					
					
					table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("barrage"):Once(function()
						Character:AddTag('CantRotate')
					end))
					
					table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("finisher"):Once(function()
						if EnemyPlayer then
							EnemyPlayer:SetAttribute("Cutscenes", true)
						end
						Player:SetAttribute("Cutscenes", true)
						
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						SecondWeld:Start(nil, EnemyPlayer, Player)
					end))
					
					table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("cut"):Once(function()
						if SecondWeld then
							pcall(function()
								SecondWeld:Stop()
							end)
							SecondWeld = nil
						end
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

						DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, true, false, true, nil, nil)
						RagdollHandler.ragdoll(EnemyHumanoid, 2.5)
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "toggleUI", { State = true }})
					end))
					
					
					VictimTrack.Stopped:Once(function()
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end
						if SecondWeld then
							pcall(function()
								SecondWeld:Stop()
							end)
							SecondWeld = nil
						end
						
						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						EnemyCharacter:RemoveTag('CantRotate')
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
						
						if EnemyPlayer then
							EnemyPlayer:SetAttribute("Cutscenes", nil)
							ReplicateEffects_Set:FireClient(EnemyPlayer, "toggleUI", { State = true })
						end
					end)
					
					UserTrack.Stopped:Once(function()
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end
						if SecondWeld then
							pcall(function()
								SecondWeld:Stop()
							end)
							SecondWeld = nil
						end

						StunHandler:Unstun(Character, Stun)
						Character:RemoveTag('CantRotate')
						iFramesService:RemoveAlliFrames(Character)
						CollisionsModule:SetCollisionGroup(Character, "Players")
						Player:SetAttribute("Cutscenes", nil)
						ReplicateEffects_Set:FireClient(Player, "toggleUI", { State = true })
					end)
					
					
					AnimationService:stopAll(EnemyCharacter)
					AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
					AnimationService:stopAll(Character)
					AnimationService:playAnimation(Character, UserAnimation)
					
					Weld:Start(nil, EnemyPlayer, Player)
					
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "CursedRemedy", { Stage = "Finisher", Char = Character, EChar = EnemyCharacter, FinisherAnim = UserAnimation.AnimationId, FinisherVictimAnim = VictimAnimation.AnimationId }})
				else
					local VictimAnimation = MoveAnims["Cursed Child"]["Cursed Remedy"].Victim
					local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)

					local UserAnimation = MoveAnims["Cursed Child"]["Cursed Remedy"].Hit
					local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
					local UserEvents = {}


					local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, rad(-180), 0), 6)
					local WeldSecond = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, rad(-180), 0), 6)

					local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)


					EnemyCharacter:AddTag('CantRotate')
					iFramesService:AddAlliFrames(EnemyCharacter)

					CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
					
					
					UserEvents["vfx"] = UserTrack:GetMarkerReachedSignal("vfx"):Connect(function()
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false, nil)
					end)

					UserEvents["barrage"] = UserTrack:GetMarkerReachedSignal("barrage"):Once(function()
						EnemyHumRP.Anchored = true

						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						Character:AddTag('CantRotate')

						DamageHandler:TakeDamage(Character, EnemyHumanoid, 6, nil, nil, false, false, true, false, false, nil, nil)
					end)

					UserEvents["slow"] = UserTrack:GetMarkerReachedSignal("slow"):Once(function()
						EnemyHumRP.Anchored = false

						WeldSecond:Start(nil, EnemyPlayer, Player)
					end)

					UserEvents["hit"] = UserTrack:GetMarkerReachedSignal("hit"):Once(function()
						if WeldSecond then
							WeldSecond:Stop()
							WeldSecond = nil
						end

						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						EnemyCharacter:RemoveTag('CantRotate')
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

						DamageHandler:TakeDamage(Character, EnemyHumanoid, 6, nil, nil, false, false, true, false, true, nil, nil)
						RagdollHandler.ragdoll(EnemyHumanoid, 2.5)
						NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(75000, 75000, 75000), Velocity = HumRP.CFrame.LookVector * 75 + Vector3.new(0, 25, 0) })
					end)


					VictimTrack.Stopped:Once(function()
						if WeldSecond then
							WeldSecond:Stop()
							WeldSecond = nil
						end

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
						for _,v in UserEvents do
							v:Disconnect()
						end

						if WeldSecond then
							WeldSecond:Stop()
							WeldSecond = nil
						end

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


					AnimationService:stopAll(EnemyCharacter)
					AnimationService:playAnimation(EnemyCharacter, VictimAnimation)

					AnimationService:stopAll(Character)
					AnimationService:playAnimation(Character, UserAnimation)

					Weld:Start(nil, EnemyPlayer, Player)

					ReplicateEffects_Set:FireAllClients("CursedRemedy", { Stage = "Hit", Char = Character, EChar = EnemyCharacter, HitAnim = UserAnimation.AnimationId })
				end
			end
			
			Hitbox:Once()
		end)
		
		
		WindupTrack.Stopped:Once(function()
			for _,v in WindupEvents do
				v:Disconnect()
			end

			if not Hit then
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
			end
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, WindupAnimation)
		
		ReplicateEffects_Set:FireAllClients("CursedRemedy", { Stage = "Start", Char = Character, StartAnim = WindupAnimation.AnimationId })
	end
}