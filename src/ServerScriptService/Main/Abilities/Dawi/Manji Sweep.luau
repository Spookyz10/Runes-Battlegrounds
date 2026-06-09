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
local CombatUtils = require(ServerModules.CombatUtils)


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
		
		local Hit = false
		local Finisher = false
		local Janitor = Trove.new()
		
		
		local StartupAnimation = MoveAnims.Dawi["Manji Sweep"].Startup
		local StartupTrack = AnimationService:getAnimationTrack(Character, StartupAnimation)
		local StartupEvents = {}
		
		local limbNames = { "Right Arm", "Left Arm", "Right Leg", "Left Leg", }
		
		
		StartupEvents["hit"] = StartupTrack:GetMarkerReachedSignal("hit"):Once(function()
			HitboxHandler:SimpleOnce( HumRP, Vector3.new(7, 8, 8), CFrame.new(0, -0.5, -4.25), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 6, nil, nil, false, true, true, true, false, nil, nil)
				if HitInfo.Countered == true then return end
				
				if EnemyCharacter:HasTag('Ragdolled') then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
				end
				
				
				shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 1.8, Last = nil } })
				
				Hit = true
				
				local UserAnimation = MoveAnims.Dawi["Manji Sweep"].User
				local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
				local UserEvents = {}
				
				local VictimAnimation = MoveAnims.Dawi["Manji Sweep"].Victim
				local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
				
				
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), 2.5)
				
				
				iFramesService:AddAlliFrames(EnemyCharacter)
				
				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
				
				EnemyCharacter:AddTag("CantRotate")
				
				
				UserEvents["hit"] = UserTrack:GetMarkerReachedSignal("hit"):Once(function()
					local FinisherHitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 6, nil, nil, false, false, true, true, false, nil, 15)
					
					if FinisherHitInfo.Finisher == true then
						Finisher = true
						
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 2, Last = 0.2 } })
						
						local FinisherUserAnimation = MoveAnims.Dawi["Manji Sweep"].Finisher.User
						local FinisherUserTrack = AnimationService:getAnimationTrack(Character, FinisherUserAnimation)
						local FinisherUserEvents = {}

						local FinisherVictimAnimation = MoveAnims.Dawi["Manji Sweep"].Finisher.Victim
						local FinisherVictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, FinisherVictimAnimation)
						
						
						
						FinisherUserEvents["run"] = FinisherUserTrack:GetMarkerReachedSignal("run"):Once(function()		
							local newVelocity = Janitor:Add(CombatUtils.createBodyVelocity(nil, {
								MaxForce = Vector3.new(1, 0, 1) * 50000,
							}))

							newVelocity:SetAttribute("Count", 70)
							newVelocity:SetAttribute("RollOff", 1.25)

							newVelocity:SetAttribute("DelayTime", 0.6)
							newVelocity:SetAttribute("Direction", "LookVector")

							CollectionService:AddTag(newVelocity, "MovementVelocity")
							newVelocity.Parent = HumRP
							
							ReplicateEffects_Set:FireAllClients("ManjiSweep", { Stage = "Footsteps", Char = Character })
						end)
						
						FinisherUserEvents["grab"] = FinisherUserTrack:GetMarkerReachedSignal("grab"):Once(function()
							DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, false, nil, nil)
							
							ReplicateEffects_Set:FireAllClients("ManjiSweep", { Stage = "Grab", Char = Character })
						end)
						
						FinisherUserEvents["grab_drop"] = FinisherUserTrack:GetMarkerReachedSignal("grab_drop"):Once(function()
							
							ReplicateEffects_Set:FireAllClients("ManjiSweep", { Stage = "Grab_Drop", Char = Character })
						end)
						
						FinisherUserEvents["spin"] = FinisherUserTrack:GetMarkerReachedSignal("spin"):Once(function()
							
							ReplicateEffects_Set:FireAllClients("ManjiSweep", { Stage = "Spin", EChar = Character })
						end)
						
						FinisherUserEvents["hit"] = FinisherUserTrack:GetMarkerReachedSignal("hit"):Once(function()
							DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, false, nil, nil)
							Character:AddTag("CantRotate")
							
							ReplicateEffects_Set:FireAllClients("ManjiSweep", { Stage = "LastHit1", EChar = Character })
							shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 2, Last = 0.2 } })
						end)
						
						FinisherUserEvents["last_hit"] = FinisherUserTrack:GetMarkerReachedSignal("last_hit"):Once(function()
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
							
							RagdollHandler.ragdoll(EnemyHumanoid, 3)
							
							local newBodyVelocity = CombatUtils.createBodyVelocity(EnemyHumRP, {
								MaxForce = Vector3.one * math.huge,
								Velocity = Vector3.new(0, 55, 0) + (HumRP.CFrame.RightVector * -325)
							}, 0.135)
							ReplicateEffects_Set:FireAllClients("ManjiSweep", { Stage = "LastHit2", Char = Character })
							ReplicateEffects_Set:FireAllClients("Blood", { cframe = EnemyHumRP, times = 35, force = 0.75, delay = 0.1 })
							ReplicateEffects_Set:FireAllClients("Backhand", { CFrame = EnemyHumRP.CFrame * CFrame.Angles(0, math.rad(90), 0) * CFrame.new(2, 0, 0), Origin = CFrame.new(EnemyHumRP.Position + HumRP.CFrame.RightVector * -5), Initial = 3.5, Size = 2.5, Time = 0.25, Down = Vector3.new(0, -1, 0), Add = 1.25 })
							shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 6, Last = 0.3 } })
							
							
							DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, true, true, true, nil, nil)
						end)
						
						
						
						FinisherVictimTrack.Stopped:Once(function()
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

						FinisherUserTrack.Stopped:Once(function()
							Janitor:Destroy()
							
							for _,v in FinisherUserEvents do
								v:Disconnect()
							end
							if Weld then
								pcall(function()
									Weld:Stop()
								end)
								Weld = nil
							end

							CollisionsModule:SetCollisionGroup(Character, "Players")

							StunHandler:Unstun(Character, Stun)
							iFramesService:RemoveAlliFrames(Character)
							Character:RemoveTag("CantRotate")
						end)
						
						
						AnimationService:stopAll(Character)
						AnimationService:stopAll(EnemyCharacter)

						AnimationService:playAnimation(EnemyCharacter, FinisherVictimAnimation)
						AnimationService:playAnimation(Character, FinisherUserAnimation)
						
						
						for i, v in Character:GetChildren() do
							if v:IsA("BasePart") then
								if table.find(limbNames, v.Name) then
									ReplicateEffects_Set:FireAllClients("armTrailEffect", { char = EnemyCharacter, lifeTime = 1.5, limbName = v.Name })
								end
							end
						end
						
						ReplicateEffects_Set:FireAllClients("ManjiSweep", { Stage = "Hit1", Char = Character })
						
						SoundsModule:PlaySound(MoveSounds.Dawi["Manji Sweep"].Finisher, HumRP)
					else
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						iFramesService:RemoveAlliFrames(Character)
						EnemyCharacter:RemoveTag("CantRotate")
						
						
						ReplicateEffects_Set:FireAllClients("Backhand", { Origin = CFrame.new(HumRP.Position), CFrame = EnemyHumRP.CFrame, })
						SoundsModule:PlaySound(MoveSounds.Dawi["Manji Sweep"].LastHit, EnemyHumRP)
						
						EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

						local selfToOtherChar = (EnemyHumRP.Position - HumRP.Position).Unit
						local lookVector = Character.HumanoidRootPart.CFrame.LookVector

						local dotProduct = lookVector:Dot(selfToOtherChar)
						if EnemyHumanoid.FloorMaterial ~= Enum.Material.Air then
							dotProduct = 1
						end

						local at = Character.HumanoidRootPart.Position
						local forward = Character.HumanoidRootPart.CFrame.LookVector
						local lookposition = CFrame.lookAt(at, at + Vector3.new(forward.X, 0, forward.Z))

						require(ServerModules.PerfectKnockback).KnockBack(nil, EnemyCharacter, {
							LookVector = lookposition.LookVector,
							LookForce = 58.5,
							LookFinalForce = 55,
							LookAt = lookposition,
							DestroyRagdoll = true,
							GroundStunTime = 0.95,
							Escapable = false,
							FallingDetectDelay = 0.2,
							Dot = dotProduct,
							DotParams = {0.4, 1},
							canHitWall = true
						}, Character)
					end
					
					ReplicateEffects_Set:FireAllClients("Blood", { cframe = EnemyHumRP, times = 6, force = 0.3, delay = 0.125 })
				end)
				
				
				
				VictimTrack.Stopped:Once(function()
					if Finisher == true then return end
					
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
				
				UserTrack.Stopped:Once(function()
					if Finisher == true then return end
					
					for _,v in UserEvents do
						v:Disconnect()
					end
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end
					
					CollisionsModule:SetCollisionGroup(Character, "Players")
					
					StunHandler:Unstun(Character, Stun)
					iFramesService:RemoveAlliFrames(Character)
				end)
				
				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)
				
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
				AnimationService:playAnimation(Character, UserAnimation)
				
				
				for i, v in Character:GetChildren() do
					if v:IsA("BasePart") then
						if table.find(limbNames, v.Name) then
							ReplicateEffects_Set:FireAllClients("armTrailEffect", { char = EnemyCharacter, lifeTime = 1.5, limbName = v.Name })
						end
					end
				end
				
				ReplicateEffects_Set:FireAllClients("ManjiSweep", { Stage = "Spin", EChar = EnemyCharacter })
				

				SoundsModule:PlaySound(MoveSounds.Dawi["Manji Sweep"].Hit1, HumRP)
				SoundsModule:PlaySound(MoveSounds.Dawi["Manji Sweep"].Hit2, EnemyHumRP)
				
				Weld:Start(nil, EnemyPlayer, Player)
			end)
		end)
		
		
		
		StartupTrack.Stopped:Once(function()
			for _,v in StartupEvents do
				v:Disconnect()
			end
			
			if Hit == false then
				if Finisher == true then return end
				
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
			end
		end)
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartupAnimation)
		
		ReplicateEffects_Set:FireAllClients("ManjiSweep", { Stage = "Sweep1", Char = Character })
		
		SoundsModule:PlaySound(MoveSounds.Dawi["Manji Sweep"].Start, HumRP)
	end
}