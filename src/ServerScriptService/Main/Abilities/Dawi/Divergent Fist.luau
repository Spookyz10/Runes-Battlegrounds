local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")


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
local Trove = require(ReplicatedModules.Trove)


local Sounds = ServerStorage.Assets.Sounds
local Animations = ServerStorage.Assets.Animations
local Models = ServerStorage.Assets.Models

local Weapons = Models.Weapons
local MoveAnims = Animations.Moves
local MoveSounds = Sounds.Moves


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
		iFramesService:AddAlliFrames(Character)
		
		
		local StartupAnimation = MoveAnims.Dawi["Divergent Fist"].Startup
		local StartupTrack = AnimationService:getAnimationTrack(Character, StartupAnimation)
		local StartupEvents = {}
		
		
		local Finisher = false
		
		
		StartupEvents["hit"] = StartupTrack:GetMarkerReachedSignal("hit"):Once(function()
			SoundsModule:PlaySound(MoveSounds.Dawi["Divergent Fist"].StartHit, HumRP)
			
			ReplicateEffects_Set:FireAllClients("DivergentFist", { Stage = "StartWind", Char = Character })
			ReplicateEffects_Set:FireAllClients("DivergentFist", { Stage = "NoImpact", Char = Character })
			
			
			HitboxHandler:SimpleOnce( HumRP, Vector3.new(6, 8.5, 7), CFrame.new(0, 0.5, -3.95), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead or EnemyCharacter:HasTag("Ragdolled") then return end
				
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 10, nil, nil, false, true, true, true, false, nil, 10)
				if HitInfo.Countered == true then return end
				
				EnemyCharacter:PivotTo(HumRP.CFrame * CFrame.Angles(0, math.rad(180), 0) * CFrame.new(0, 0, 2))
				
				
				if HitInfo.Finisher == true then
					if Finisher then
						return
					end
					Finisher = true
					
					local VictimAnimation = MoveAnims.Dawi["Divergent Fist"].Victim
					local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
					
					
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 8, Last = 0.3 } })
					
					
					local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
					
					iFramesService:AddAlliFrames(EnemyCharacter)
					EnemyCharacter:AddTag("CantRotate")
					Character:AddTag("CantRotate")
					
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
					
					local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), 2.5)
					
					ReplicateEffects_Set:FireAllClients("Blood", { cframe = EnemyHumRP, times = 12, force = 0.2, delay = 0.05 })
					
					StartupTrack:AdjustSpeed(0.05)
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 7, nil, nil, false, false, true, true, false, nil, nil)
					
					task.delay(0.65, function()
						AnimationService:stopAnimation(EnemyCharacter, VictimAnimation)
						StartupTrack:AdjustSpeed(1)
						
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end
						
						ReplicateEffects_Set:FireAllClients("DivergentFist", { Stage = "StartWind", Char = Character })
						ReplicateEffects_Set:FireAllClients("Blood", { cframe = EnemyHumRP, times = 35, force = 0.5, delay = 0.05 })
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 8, Last = 0.3 } })
						
						DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, true, true, true, nil, nil)
						NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(75000, 75000, 75000), Velocity = HumRP.CFrame.LookVector * 140 + Vector3.new(0, 10, 0) })
						ReplicateEffects_Set:FireAllClients("ManjiSweep", { Stage = "Hit1", Char = Character })
						
						SoundsModule:PlaySound(MoveSounds.Dawi["Divergent Fist"].LastHit, EnemyHumRP)
					end)
					
					VictimTrack.Stopped:Once(function()
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						EnemyCharacter:RemoveTag("CantRotate")
					end)
					
					AnimationService:stopAll(EnemyCharacter)
					AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
				else
					ReplicateEffects_Set:FireAllClients("Blood", { cframe = EnemyHumRP, times = 8, force = 0.1, delay = 0.1 })
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 5, Last = 0.1 } })
					
					
					RagdollHandler.ragdoll(EnemyHumanoid, 2.25)
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(75000, 75000, 75000), Velocity = HumRP.CFrame.LookVector * 55 + Vector3.new(0, 10, 0) })
				end
				
				ReplicateEffects_Set:FireAllClients("DivergentFist", { Stage = "Hit", Char = Character })
				
				SoundsModule:PlaySound(MoveSounds.Dawi["Divergent Fist"].Hitted, HumRP)
			end)
		end)
		
		
		
		StartupTrack.Stopped:Once(function()
			for _,v in StartupEvents do
				v:Disconnect()
			end

			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)
			
			if Character:HasTag("CantRotate") then
				Character:RemoveTag("CantRotate")
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartupAnimation, 1.1)
		
		task.delay(0.5, function()
			ReplicateEffects_Set:FireAllClients("EnergyTrail", { char = Character, limbNames = { "Right Arm", }, lifeTime = 0.95 })
		end)
		
		SoundsModule:PlaySound(MoveSounds.Dawi["Divergent Fist"].Start, HumRP)
	end
}