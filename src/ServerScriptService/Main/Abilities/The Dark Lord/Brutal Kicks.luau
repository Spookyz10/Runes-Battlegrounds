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
		
		
		local Janitor = Trove.new()
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		
		
		local StartupAnimation = MoveAnims["The Dark Lord"]["Brutal Kicks"].Startup
		local StartupTrack, StartEvents = AnimationService:getAnimationTrack(Character, StartupAnimation)
		
		
		local Hit, Finisher = false, false
		
		
		table.insert(StartEvents, Janitor:Add(StartupTrack:GetMarkerReachedSignal("Damage"):Once(function() --?

		end)))
		
		table.insert(StartEvents, Janitor:Add(StartupTrack:GetMarkerReachedSignal("Hit"):Once(function()
			HitboxHandler:SimpleOnce(HumRP, Vector3.new(7, 7, 7.5), CFrame.new(0, 0, -3.5), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				
				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter:FindFirstChild("Ragdolled") then return end
				Hit = true
				
				
				if EnemyCharacter:HasTag("Ragdolled") then --Safety
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
				end
				
				
				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
				
				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)
				
				
				EnemyCharacter:AddTag("CantRotate")
				
				
				local UserAnimation = MoveAnims["The Dark Lord"]["Brutal Kicks"].User
				local VictimAnimation = MoveAnims["The Dark Lord"]["Brutal Kicks"].Victim

				local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
				local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)
				
				
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, 0), -1)
				
				
				local Container = {}
				local Assets = {}
				
				local function MoveDude(Params)
					for _, v in pairs(Container) do
						v:Destroy()
					end
					
					local BodyVelocity = Janitor:Add(Instance.new("BodyVelocity"))
					
					table.insert(Assets, BodyVelocity)
					table.insert(Container, BodyVelocity)
					
					BodyVelocity.Name = "moveme"
					BodyVelocity.MaxForce = Vector3.new(40000, 0, 40000, 0)
					BodyVelocity:SetAttribute("Speed", Params.speed or 100)
					BodyVelocity:SetAttribute("Fallout", Params.fallout or 0.95)
					BodyVelocity:SetAttribute("End", Params.endd or 5)
					BodyVelocity.Parent = HumRP
					
					Debris:AddItem(BodyVelocity, Params.deletiontime or 5)
				end
				
				
				table.insert(UserEvents, Janitor:Add(UserTrack:GetMarkerReachedSignal("Damage"):Connect(function() --Looped
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, false, true, false, nil, nil)
					
					MoveDude({ speed = 30, fallout = 0.9, endd = 2, deletiontime = 0.2 })
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 2 } })
				end)))
				
				table.insert(UserEvents, Janitor:Add(UserTrack:GetMarkerReachedSignal("End"):Once(function()
					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, false, false, true, true, false, nil, 13)
					
					if HitInfo.Finisher == true then
						Finisher = true
						
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end
						
						local GroundAttachment
						local GroundTime = 1.5
						
						
						local FinisherWeld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, 0), -1)
						
						
						local FUserAnimation = MoveAnims["The Dark Lord"]["Brutal Kicks"].FinisherUser
						local FVictimAnimation = MoveAnims["The Dark Lord"]["Brutal Kicks"].FinisherVictim

						local FVictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, FVictimAnimation)
						local FUserTrack, FUserEvents = AnimationService:getAnimationTrack(Character, FUserAnimation)
						
						
						table.insert(FUserEvents, Janitor:Add(FUserTrack:GetMarkerReachedSignal("Grab"):Connect(function() --looped
							MoveDude({ speed = 45, fallout = 0.9, endd = 3, deletiontime = 0.2 })
							
							shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 2 } })
							
							pcall(function()
								DamageHandler:TakeDamage(Character, EnemyHumanoid, 1.5, nil, nil, false, false, false, true, false, nil, nil)
							end)
						end)))
						
						table.insert(FUserEvents, Janitor:Add(FUserTrack:GetMarkerReachedSignal("Pummel"):Once(function() --what does this even mean dude
							CollisionsModule:SetCollisionGroup(EnemyCharacter, "NoCol")
							
							MoveDude({ speed = 160, fallout = 0.98, endd = 5, deletiontime = GroundTime })
							
							shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 3, Last = GroundTime } })
							
							GroundAttachment = Instance.new("Attachment", EnemyHumRP)
							GroundAttachment.CFrame = CFrame.new(0, 0, 0.526)
							
							ReplicateEffects_Set:FireAllClients("huntergrind", { Attachment = GroundAttachment })
							
							task.delay(GroundTime, function() --due to theres no marker :angry:
								GroundAttachment.Name = "donedrag"
								Debris:AddItem(GroundAttachment, 2)
							end)
						end)))
						
						table.insert(FUserEvents, Janitor:Add(FUserTrack:GetMarkerReachedSignal("SpinKick"):Once(function()
							MoveDude({ speed = 45, fallout = 0.9, endd = 3, deletiontime = 0.2 })
							
							shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 2.5 } })
							
							pcall(function()
								DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, false, true, false, nil, nil)
							end)
						end)))
						
						table.insert(FUserEvents, Janitor:Add(FUserTrack:GetMarkerReachedSignal("PreEnd"):Once(function()
							Character:AddTag("CantRotate")
							
							MoveDude({ speed = 45, fallout = 0.9, endd = 3, deletiontime = 0.2 })
							
							shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 2.5 } })
							
							pcall(function()
								DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, false, true, false, nil, nil)
							end)
						end)))
						
						table.insert(FUserEvents, Janitor:Add(FUserTrack:GetMarkerReachedSignal("End"):Once(function()
							shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 2.5 } })
							
							if FinisherWeld then
								pcall(function()
									FinisherWeld:Stop()
								end)
								FinisherWeld = nil
							end
							
							StunHandler:Unstun(EnemyCharacter, EnemyStun)
							iFramesService:RemoveAlliFrames(EnemyCharacter)
							CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
							EnemyCharacter:RemoveTag("CantRotate")
							
							DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, false, true, true, nil, nil)
							RagdollHandler.ragdoll(EnemyHumanoid, 2.25, true, Character)
							NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 1, 1) * math.huge, Velocity = HumRP.CFrame.LookVector * 95 + Vector3.new(0, 5, 0) })
						end)))
						
						
						FVictimTrack.Stopped:Once(function()
							if FinisherWeld then
								pcall(function()
									FinisherWeld:Stop()
								end)
								FinisherWeld = nil
							end

							StunHandler:Unstun(EnemyCharacter, EnemyStun)
							iFramesService:RemoveAlliFrames(EnemyCharacter)
							CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
							EnemyCharacter:RemoveTag("CantRotate")
						end)

						FUserTrack.Stopped:Once(function()
							if Janitor then
								pcall(function()
									Janitor:Destroy()
								end)
								Janitor = nil
							end

							if FinisherWeld then
								pcall(function()
									FinisherWeld:Stop()
								end)
								FinisherWeld = nil
							end

							for _, v in Assets do
								if not v.Parent then continue end

								v:Destroy()
							end

							StunHandler:Unstun(Character, Stun)
							iFramesService:RemoveAlliFrames(Character)
							CollisionsModule:SetCollisionGroup(Character, "Players")
							Character:RemoveTag("CantRotate")
						end)
						
						
						AnimationService:stopAll(Character)
						AnimationService:stopAll(EnemyCharacter)
						AnimationService:playAnimation(Character, FUserAnimation)
						AnimationService:playAnimation(EnemyCharacter, FVictimAnimation)
						
						
						ReplicateEffects_Set:FireAllClients("BrutalKicks", { Stage = "Finisher", Char = Character, HumanoidRootPart = EnemyHumRP })
						
						FinisherWeld:Start(nil, EnemyPlayer or Player)
					else
						if Finisher then return end
						
						Character:AddTag("CantRotate")
						
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
						
						
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, nil, nil, false, false, false, true, true, nil, nil)
						RagdollHandler.ragdoll(EnemyHumanoid, 2.25)
						NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(75000, 75000, 75000), Velocity = HumRP.CFrame.LookVector * 85 + Vector3.new(0, 20, 0) })
						
						task.delay(0.8, function()
							local Dropped = false
							
							for i = 1, 100 do
								if Dropped ~= true and EnemyHumRP then
									if workspace:Raycast(EnemyHumRP.Position, Vector3.new(0, -5, 0), MapRayParams) then
										Dropped = true
										
										ReplicateEffects_Set:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = EnemyHumRP, ["end"] = Vector3.new(0, -17, 0), Crater2 = true })
										shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 7 } })
									end
									
									task.wait(0.1)
								else
									break
								end
							end
						end)
					end
					
				end)))
				
				
				VictimTrack.Stopped:Once(function()
					if not Finisher then
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
						
					end
				end)

				UserTrack.Stopped:Once(function()
					if not Finisher then
						if Janitor then
							pcall(function()
								Janitor:Destroy()
							end)
							Janitor = nil
						end

						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						for _, v in Assets do
							if not v.Parent then continue end

							v:Destroy()
						end

						StunHandler:Unstun(Character, Stun)
						iFramesService:RemoveAlliFrames(Character)
						CollisionsModule:SetCollisionGroup(Character, "Players")
						Character:RemoveTag("CantRotate")
						
					end
				end)
				
				
				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)
				AnimationService:playAnimation(Character, UserAnimation)
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
				
				
				Weld:Start(nil, EnemyPlayer or Player)
				
				
				ReplicateEffects_Set:FireAllClients("BrutalKicks", { Stage = "Hit", Char = Character })
			end)
		end)))
		
		
		StartupTrack.Stopped:Once(function()
			if not Hit then
				if Janitor then
					pcall(function()
						Janitor:Destroy()
					end)
					Janitor = nil
				end
				
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartupAnimation)
		
		
		ReplicateEffects_Set:FireAllClients("BrutalKicks", { Stage = "Start", Char = Character })
	end
}