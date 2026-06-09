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
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 5, 0, true)
		
		
		local StartupAnimation = MoveAnims["Hero Hunter"].huntersgrasp.Startup
		local StartupTrack, StartupEvents = AnimationService:getAnimationTrack(Character, StartupAnimation)
		
		
		local Hit = false
		local Finisher = false
		local GrabEventFired = false
		
		
		table.insert(StartupEvents, StartupTrack:GetMarkerReachedSignal("stomp"):Once(function()
			task.spawn(function()
				local GraspEffects = Instance.new("Attachment")
				GraspEffects.Parent = Character["Right Leg"]
				GraspEffects.CFrame = CFrame.new(-0.03, 0, 0)
				
				
				ReplicateEffects_Set:FireAllClients("GroundStomp", { Attachment = GraspEffects })
				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 4 })
				
				SoundsModule:PlaySound(MoveSounds["Hero Hunter"].huntersstomp.Stomp, HumRP)
			end)
			
			HitboxHandler:SimpleOnce(HumRP, Vector3.new(7, 8, 10), CFrame.new(0, 0, -3), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, nil, nil, true, EnemyCharacter:HasTag('DEATH') and true or false, true, false, false, nil, 16)
				if HitInfo.Blocked == true or HitInfo.Countered == true then return end
				GrabEventFired = true
				
				
				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
				end
				
				
				RagdollHandler.ragdoll(EnemyHumanoid, 2)
				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 1, 1) * 100_000_000, Velocity = EnemyHumRP.CFrame.UpVector * 30 })
				shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 4 } })
				
				
				if HitInfo.Finisher == true then
					Finisher = true

					local FinisherAnimation = MoveAnims["Hero Hunter"].huntersgrasp.Finisher
					local FinisherTrack, FinisherEvents = AnimationService:getAnimationTrack(Character, FinisherAnimation)
					
					
					table.insert(FinisherEvents, FinisherTrack:GetMarkerReachedSignal("grab"):Once(function()
						SoundsModule:PlaySound(MoveSounds["Hero Hunter"].huntersstomp.Grab, HumRP)
						
						
						HitboxHandler:SimpleOnce(HumRP, Vector3.new(7, 8, 10), CFrame.new(0, 0, -3), { Character }, nil, nil, function(EnemyCharacter2: Model)
							local EnemyPlayer2 = PlayersService:GetPlayerFromCharacter(EnemyCharacter2)
							local EnemyHumanoid2: Humanoid = EnemyCharacter2.Humanoid
							local EnemyHumRP2: BasePart = EnemyCharacter2.HumanoidRootPart


							if Hit == true or iFramesService:HasiFrame(EnemyCharacter2, Tool.Name) then return end
							Hit = true


							local Weld = WeldSystem.new(Character:FindFirstChild("Left Arm"), EnemyCharacter2:FindFirstChild("Head"), CFrame.new(0, -1.5, 1.65) * CFrame.Angles(90, rad(180), 0), -1)


							if EnemyCharacter2:HasTag("Ragdolled") then
								RagdollHandler.cancelRagdoll(EnemyHumanoid2, nil, false, nil, nil, true)
							end

							local EnemyStun = StunHandler:Stun(EnemyCharacter2, nil, true, 0, 0, true)


							EnemyCharacter2:AddTag('CantRotate')

							iFramesService:AddAlliFrames(Character)
							iFramesService:AddAlliFrames(EnemyCharacter2)

							CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
							CollisionsModule:SetCollisionGroup(EnemyCharacter2, "NoCol")

							shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer2 }, { "ShakeCamera", { Intensity = 4 } })
							
							
							for i = 1, 3 do
								local EventName = "swing" .. tostring(i)

								table.insert(FinisherEvents, FinisherTrack:GetMarkerReachedSignal(EventName):Once(function()
									if i == 1 then

									elseif i == 2 then

									elseif i == 3 then

									end
								end))
							end

							for i = 1, 2 do
								local EventName = "slam" .. tostring(i)

								table.insert(FinisherEvents, FinisherTrack:GetMarkerReachedSignal(EventName):Once(function()
									if i == 1 then
										ReplicateEffects_Set:FireAllClients("Ground Crater",{
											Seed = math.random(1, 2000000000), 
											start = EnemyHumRP.Position + Vector3.new(0, 0.10000000149011612, 0, 0), 
											["end"] = Vector3.new(0, -24, 0, 0), 
											amount = 6, 
											size = 0.3, 
											nosmoke = true, 
											nosound = false
										})
										
										shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer2 }, { "ShakeCamera", { Intensity = 3.5 } })
									elseif i == 2 then
										ReplicateEffects_Set:FireAllClients("Ground Crater", { start = EnemyHumRP.Position, Seed = math.random(1,2147483647), ["end"] = Vector3.new(0, -7, 0), nosound = true })
										shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer2 }, { "ShakeCamera", { Intensity = 4.5 } })
									end
								end))
							end

							table.insert(FinisherEvents, FinisherTrack:GetMarkerReachedSignal("jump"):Once(function()

							end))

							table.insert(FinisherEvents, FinisherTrack:GetMarkerReachedSignal("finalslam"):Once(function()
								shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer2 }, { "ShakeCamera", { Intensity = 7 } })
								ReplicateEffects_Set:FireAllClients("Ground Crater", { ["end"] = Vector3.new(0, -14, 0), start = Character.PrimaryPart.Position, Seed = math.random(1,2147483647), size = 2 })

								if Weld then
									pcall(function()
										Weld:Stop()
									end)
									Weld = nil
								end

								StunHandler:Unstun(EnemyCharacter2, EnemyStun)
								EnemyCharacter2:RemoveTag('CantRotate')
								iFramesService:RemoveAlliFrames(EnemyCharacter2)
								CollisionsModule:SetCollisionGroup(EnemyCharacter2, "Players")

								DamageHandler:TakeDamage(Character, EnemyHumanoid2, EnemyHumanoid2.Health, nil, nil, false, false, true, false, true, nil, nil)
								RagdollHandler.ragdoll(EnemyHumanoid2, 2)
							end))

							table.insert(FinisherEvents, FinisherTrack:GetMarkerReachedSignal("end"):Once(function()
								if Weld then
									pcall(function()
										Weld:Stop()
									end)
									Weld = nil
								end

								StunHandler:Unstun(Character, Stun)
								iFramesService:RemoveAlliFrames(Character)
								CollisionsModule:SetCollisionGroup(Character, "Players")
							end))
							
							
							FinisherTrack.Stopped:Once(function()
								if Weld then
									pcall(function()
										Weld:Stop()
									end)
									Weld = nil
								end
							end)
							
							
							Weld:Start(nil, EnemyPlayer2, Player)
						end)
					end))
					
					
					FinisherTrack.Stopped:Once(function()
						StunHandler:Unstun(Character, Stun)
						iFramesService:RemoveAlliFrames(Character)
						CollisionsModule:SetCollisionGroup(Character, "Players")
					end)
					
					
					AnimationService:stopAll(Character)
					AnimationService:playAnimation(Character, FinisherAnimation)
				else
					local UserAnimation = MoveAnims["Hero Hunter"].huntersgrasp.User
					local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

					table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("grabstart"):Once(function()
						SoundsModule:PlaySound(MoveSounds["Hero Hunter"].huntersstomp["Grab Start"], HumRP)
					end))
					
					table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("grab"):Once(function()
						SoundsModule:PlaySound(MoveSounds["Hero Hunter"].huntersstomp.Grab, HumRP)
						
						
						HitboxHandler:SimpleOnce(HumRP, Vector3.new(7, 8, 10), CFrame.new(0, 0, -3), { Character }, nil, nil, function(EnemyCharacter2: Model)
							local EnemyPlayer2 = PlayersService:GetPlayerFromCharacter(EnemyCharacter2)
							local EnemyHumanoid2: Humanoid = EnemyCharacter2.Humanoid
							local EnemyHumRP2: BasePart = EnemyCharacter2.HumanoidRootPart
							
							
							if Hit == true or iFramesService:HasiFrame(EnemyCharacter2, Tool.Name) then return end
							Hit = true
							
							
							local Weld = WeldSystem.new(Character:FindFirstChild("Left Arm"), EnemyCharacter2:FindFirstChild("Head"), CFrame.new(0, -1.5, 1.65) * CFrame.Angles(90, rad(180), 0), -1)
							
							
							if EnemyCharacter2:HasTag("Ragdolled") then
								RagdollHandler.cancelRagdoll(EnemyHumanoid2, nil, false, nil, nil, true)
							end
							
							local EnemyStun = StunHandler:Stun(EnemyCharacter2, nil, true, 0, 0, true)
							
							
							EnemyCharacter2:AddTag('CantRotate')
							
							iFramesService:AddAlliFrames(Character)
							iFramesService:AddAlliFrames(EnemyCharacter2)
							
							CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
							CollisionsModule:SetCollisionGroup(EnemyCharacter2, "NoCol")
							
							shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer2 }, { "ShakeCamera", { Intensity = 4 } })
							
							
							table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("throw"):Once(function()
								pcall(function()
									SoundsModule:PlaySound(MoveSounds["Hero Hunter"].huntersstomp["Throw Enemy"], EnemyHumRP2)
								end)

								if Weld then
									pcall(function()
										Weld:Stop()
									end)
									Weld = nil
								end

								StunHandler:Unstun(EnemyCharacter2, EnemyStun)
								EnemyCharacter2:RemoveTag('CantRotate')
								iFramesService:RemoveAlliFrames(EnemyCharacter2)
								CollisionsModule:SetCollisionGroup(EnemyCharacter2, "Players")


								DamageHandler:TakeDamage(Character, EnemyHumanoid2, 4.5, nil, nil, false, false, true, false, false, nil, nil)


								EnemyHumRP2.AssemblyLinearVelocity = Vector3.zero

								local selfToOtherChar = (EnemyHumRP2.Position - HumRP.Position).Unit
								local lookVector = Character.HumanoidRootPart.CFrame.LookVector

								local dotProduct = lookVector:Dot(selfToOtherChar)
								if EnemyHumanoid2.FloorMaterial ~= Enum.Material.Air then
									dotProduct = 1
								end

								local at = Character.HumanoidRootPart.Position
								local forward = Character.HumanoidRootPart.CFrame.LookVector
								local lookposition = CFrame.lookAt(at, at + Vector3.new(forward.X, 0, forward.Z))


								require(ServerStorage.Modules.PerfectKnockback).KnockBack(nil, EnemyCharacter2, {
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

								shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer2 }, { "ShakeCamera", { Intensity = 2.5 } })
							end))
							
							
							UserTrack.Stopped:Once(function()
								if Weld then
									pcall(function()
										Weld:Stop()
									end)
									Weld = nil
								end
							end)
							
							
							Weld:Start(nil, EnemyPlayer2, Player)
						end)
					end))


					UserTrack.Stopped:Once(function()
						StunHandler:Unstun(Character, Stun)
						iFramesService:RemoveAlliFrames(Character)
						CollisionsModule:SetCollisionGroup(Character, "Players")
					end)
					

					AnimationService:stopAll(Character)
					AnimationService:playAnimation(Character, UserAnimation)
				end
				
				
				SoundsModule:PlaySound(MoveSounds["Hero Hunter"].huntersstomp.Swing, HumRP)
			end)
		end))
		
		
		StartupTrack.Stopped:Once(function()
			if not GrabEventFired then
				StunHandler:Unstun(Character, Stun)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartupAnimation)
		
		SoundsModule:PlaySound(MoveSounds["Hero Hunter"].huntersstomp["Start Swing"], HumRP)
	end
}