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

local function detectDistance(Distance: number, Char: Model)
	local distanceTable = {}

	for i, v in workspace.Live:GetChildren() do
		if not v:IsA("Model") then
			continue
		end

		local humanoid = v:FindFirstChildOfClass("Humanoid")

		if not humanoid then
			continue
		end

		if table.find(distanceTable, v) or v == Char or (v:GetPivot().Position - Char.HumanoidRootPart.Position).Magnitude > Distance then
			continue
		end

		table.insert(distanceTable, v)
	end

	return distanceTable
end

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		
		local Hit = false
		local Finisher = false
		local Janitor = Trove.new()
		
		
		local limbNames = { "Right Arm", "Left Arm", "Right Leg", "Left Leg", }
		
		local distances = detectDistance(7, Character)
		
		
		for i, v in Character:GetChildren() do
			if v:IsA("BasePart") then
				if table.find(limbNames, v.Name) then
					ReplicateEffects_Set:FireAllClients("armTrailEffect", { char = Character, lifeTime = 2.5, limbName = v.Name })
				end
			end
		end
		
		
		if #distances > 0 then
			local StartupAnimation = MoveAnims.Dawi["Breakneck Spiral"].Startup
			local StartupTrack = AnimationService:getAnimationTrack(Character, StartupAnimation)
			local StartupEvents = {}
			
			StartupEvents["hit"] = StartupTrack:GetMarkerReachedSignal("hit"):Once(function()
				HitboxHandler:SimpleOnce(HumRP, Vector3.new(6, 8, 8), CFrame.new(0, -0.5, -4.25), { Character }, nil, nil, function(EnemyCharacter)
					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end

					local FinisherHitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 6, nil, nil, false, false, true, true, false, nil, 12)

					if EnemyCharacter:HasTag('Ragdolled') then
						RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
					end

					Hit = true


					if FinisherHitInfo.Finisher == true then
						Finisher = true

						local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

						iFramesService:AddAlliFrames(EnemyCharacter)
						iFramesService:AddAlliFrames(Character)
						
						local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), 2.5)

						CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

						EnemyCharacter:AddTag("CantRotate")

						local FinisherUserAnimation = MoveAnims.Dawi["Breakneck Spiral"].FinisherUser
						local FinisherUserTrack = AnimationService:getAnimationTrack(Character, FinisherUserAnimation)
						local FinisherUserEvents = {}

						local FinisherVictimAnimation = MoveAnims.Dawi["Breakneck Spiral"].FinisherVictim
						local FinisherVictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, FinisherVictimAnimation)

						local container = {}
						local assets = {}

						local function Velocity(Params)
							for _, existingVel in pairs(container) do
								existingVel:Destroy()
							end

							local BodyVelocity = Instance.new("BodyVelocity")

							table.insert(assets, BodyVelocity)
							table.insert(container, BodyVelocity)

							BodyVelocity.Name = "moveme"
							BodyVelocity.MaxForce = Vector3.new(40000, 0, 40000, 0)
							BodyVelocity:SetAttribute("Speed", Params.speed or 100)
							BodyVelocity:SetAttribute("Fallout", Params.fallout or 0.95)
							BodyVelocity:SetAttribute("End", Params.endd or 5)
							BodyVelocity.Parent = Character.PrimaryPart

							game.Debris:AddItem(BodyVelocity, Params.deletiontime or 5)
						end

						FinisherUserEvents["kick"] = FinisherUserTrack:GetMarkerReachedSignal("kick"):Once(function()	
							DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, false, nil, nil)
							Velocity({ speed = 80, fallout = 0.9, endd = 5, deletiontime = 0.25 })

							ReplicateEffects_Set:FireAllClients("dragonFinisher", { Stage = "kick", Char = Character, EChar = EnemyCharacter })
							shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 4, Last = 0.1 } })
						end)

						FinisherUserEvents["move"] = FinisherUserTrack:GetMarkerReachedSignal("move"):Once(function()	
							Velocity({ speed = 25, fallout = 0.935, endd = 5, deletiontime = 0.5 })

						end)

						FinisherUserEvents["move2"] = FinisherUserTrack:GetMarkerReachedSignal("move2"):Once(function()
							Velocity({ speed = 30, fallout = 0.935, endd = 5, deletiontime = 0.5 })

						end)

						FinisherUserEvents["move3"] = FinisherUserTrack:GetMarkerReachedSignal("move3"):Once(function()
							Velocity({ speed = 25, fallout = 0.935, endd = 5, deletiontime = 0.5 })

						end)

						FinisherUserEvents["before"] = FinisherUserTrack:GetMarkerReachedSignal("before"):Once(function()
							Velocity({ speed = 60, fallout = 0.95, endd = 5, deletiontime = 0.5 })

							ReplicateEffects_Set:FireAllClients("dragonFinisher", { Stage = "before", Char = Character })
						end)

						FinisherUserEvents["knee"] = FinisherUserTrack:GetMarkerReachedSignal("knee"):Once(function()
							DamageHandler:TakeDamage(Character, EnemyHumanoid, 3.5, nil, nil, false, false, true, true, false, nil, nil)
							Velocity({ speed = 80, fallout = 0.9, endd = 5, deletiontime = 0.25 })

							ReplicateEffects_Set:FireAllClients("dragonFinisher", { Stage = "knee", Char = Character, EChar = EnemyCharacter })
							shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 4, Last = 0.1 } })
						end)

						FinisherUserEvents["elbow"] = FinisherUserTrack:GetMarkerReachedSignal("elbow"):Once(function()
							DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, nil, nil, false, false, true, true, false, nil, nil)
							Velocity({ speed = 80, fallout = 0.95, endd = 5, deletiontime = 1 })

							ReplicateEffects_Set:FireAllClients("dragonFinisher", { Stage = "elbow", Char = Character, EChar = EnemyCharacter })

							for last = 1, 2 do
								shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 2, Last = last == 2 and 0.5 or 0.1 } })

								task.wait(0.25)
							end
						end)

						FinisherUserEvents["here"] = FinisherUserTrack:GetMarkerReachedSignal("here"):Once(function()
							EnemyCharacter:SetPrimaryPartCFrame(Character.PrimaryPart.CFrame * CFrame.new(-5, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0))

							ReplicateEffects_Set:FireAllClients("dragonFinisher", { Stage = "here", Char = Character, EChar = EnemyCharacter })
						end)

						FinisherUserEvents["connect"] = FinisherUserTrack:GetMarkerReachedSignal("connect"):Once(function()
							ReplicateEffects_Set:FireAllClients("dragonFinisher", { Stage = "connect", Char = Character })

						end)

						FinisherUserEvents["finished"] = FinisherUserTrack:GetMarkerReachedSignal("finished"):Once(function()
							if Weld then
								pcall(function()
									Weld:Stop()
								end)
								Weld = nil
							end

							DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, true, true, true, nil, nil)

							CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

							StunHandler:Unstun(EnemyCharacter, EnemyStun)
							iFramesService:RemoveAlliFrames(EnemyCharacter)
							EnemyCharacter:RemoveTag("CantRotate")

							local BodyVelocity = Instance.new("BodyVelocity");
							BodyVelocity.MaxForce = Vector3.new(1000000, 1000000, 1000000, 0);
							BodyVelocity.Velocity = -Character.PrimaryPart.CFrame.RightVector * 10 + Vector3.new(0, -50, 0, 0);
							BodyVelocity.Parent = EnemyCharacter.PrimaryPart

							task.delay(0.1, function()
								BodyVelocity.Velocity = Vector3.new(0, 150, 0, 0);
							end)

							game.Debris:AddItem(BodyVelocity, 0.15);
							local Position = EnemyCharacter.PrimaryPart.Position

							RagdollHandler.ragdoll(EnemyHumanoid, 3)

							ReplicateEffects_Set:FireAllClients("Ground Crater", { Seed = math.random(1, 2000000000), start = Position, ["end"] = Vector3.new(0, -24, 0, 0), amount = 6, size = 0.3 })
							ReplicateEffects_Set:FireAllClients("Ground Crater", { Seed = math.random(1, 2000000000), start = Position, ["end"] = Vector3.new(0, -24, 0, 0), amount = 9, size = 1.34, sizemult = 2, nosmoke = true, nosound = true })
							ReplicateEffects_Set:FireAllClients("dragonFinisher", { Stage = "finished", Char = Character, EChar = EnemyCharacter })

							shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 8, Last = 0.5 } })
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
							for _,v in FinisherUserEvents do
								v:Disconnect()
							end
							if Weld then
								pcall(function()
									Weld:Stop()
								end)
								Weld = nil
							end

							for _,v in assets do
								if v and v.Parent then
									v:Destroy()
								end
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

						SoundsModule:PlaySound(MoveSounds.Dawi["Breakneck Spiral"].Finisher, Character.Torso)

						Weld:Start(nil, EnemyPlayer, Player)
					else
						local UserAnimation = MoveAnims.Dawi["Breakneck Spiral"].User
						local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
						local UserEvents = {}

						local VictimAnimation = MoveAnims.Dawi["Breakneck Spiral"].Victim
						local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)


						local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

						iFramesService:AddAlliFrames(EnemyCharacter)
						iFramesService:AddAlliFrames(Character)

						CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

						EnemyCharacter:AddTag("CantRotate")

						local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, 0))

						for i = 1, 3 do
							local EventName = "hit" .. tostring(i)


							UserEvents[EventName] = UserTrack:GetMarkerReachedSignal(EventName):Once(function()
								if i == 1 then
									DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, true, false, true, false, nil, nil)

								elseif i == 2 then
									DamageHandler:TakeDamage(Character, EnemyHumanoid, 7, nil, nil, false, true, false, true, false, nil, nil)
									ReplicateEffects_Set:FireAllClients("BreakneckSpiral", { Stage = "SweepHit", Char = Character })

								else
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

									CombatUtils.createBodyVelocity(EnemyHumRP, { MaxForce = Vector3.one * math.huge, Velocity = Vector3.new(0, 45.5, 0) }, 0.175)
									CombatUtils.createAngularVelocity(EnemyHumRP, { MaxTorque = Vector3.one * math.huge, AngularVelocity = Vector3.new(Random.new():NextNumber(3, 4), Random.new():NextNumber(2, 3), Random.new():NextNumber(3, 5)) * Random.new():NextNumber(1.2, 1.5) }, 0.1)

									ReplicateEffects_Set:FireAllClients("Ground Crater", { Seed = math.random(1, 2000000000), start = EnemyHumRP.Position + Vector3.new(0, 0.10000000149011612, 0, 0), ["end"] = Vector3.new(0, -8, 0), nosmoke = true, size = 1.1 })
									ReplicateEffects_Set:FireAllClients("Ground Crater", { Seed = math.random(1, 2000000000), start = EnemyHumRP.Position + Vector3.new(0, 0.10000000149011612, 0, 0), ["end"] = Vector3.new(0, -8, 0), amount = 6, nosound = true, size = 0.3 })
									shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 2, Last = 0.3 } })


									RagdollHandler.ragdoll(EnemyHumanoid, 2.25)
									DamageHandler:TakeDamage(Character, EnemyHumanoid, 6, nil, nil, false, true, false, true, true, nil, nil)
								end
							end)
						end



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


						for i, v in Character:GetChildren() do
							if v:IsA("BasePart") then
								if table.find(limbNames, v.Name) then
									ReplicateEffects_Set:FireAllClients("armTrailEffect", { char = Character, lifeTime = 2.75, limbName = v.Name })
								end
							end
						end

						ReplicateEffects_Set:FireAllClients("BreakneckSpiral", { Stage = "SweepHit", Char = Character })
						ReplicateEffects_Set:FireAllClients("ManjiSweep", { Stage = "Spin", EChar = Character })
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 1.8, Last = nil } })

						AnimationService:stopAll(EnemyCharacter)
						AnimationService:playAnimation(EnemyCharacter, VictimAnimation)

						AnimationService:stopAll(Character)
						AnimationService:playAnimation(Character, UserAnimation)

						Weld:Start(nil, EnemyPlayer, Player)

						SoundsModule:PlaySound(MoveSounds.Dawi["Breakneck Spiral"].Hit, EnemyHumRP)
					end
				end)
			end)

			StartupEvents["end"] = StartupTrack:GetMarkerReachedSignal("end"):Once(function()
				if Hit then return end

				StunHandler:Unstun(Character, Stun)
			end)


			StartupTrack.Stopped:Once(function()
				for _,v in StartupEvents do
					v:Disconnect()
				end

				if Hit == false then
					StunHandler:Unstun(Character, Stun)
				end
			end)


			AnimationService:stopAll(Character)
			AnimationService:playAnimation(Character, StartupAnimation)

			SoundsModule:PlaySound(MoveSounds.Dawi["Breakneck Spiral"].Start, HumRP)
			
			return
		else
			local StartupAnimation = MoveAnims.Dawi["Breakneck Spiral"].Variant
			local StartupTrack = AnimationService:getAnimationTrack(Character, StartupAnimation)
			local StartupEvents = {}
			
			
			local newVelocity = Janitor:Add(CombatUtils.createBodyVelocity(nil, {
				MaxForce = Vector3.new(1, 0, 1) * 50000,
			}))

			newVelocity:SetAttribute("Count", 60)
			newVelocity:SetAttribute("RollOff", 1.25)
			newVelocity:SetAttribute("DelayTime", 0.6)
			newVelocity:SetAttribute("Direction", "LookVector")

			CollectionService:AddTag(newVelocity, "MovementVelocity")
			
			
			StartupEvents["walk"] = StartupTrack:GetMarkerReachedSignal("walk"):Once(function()
				ReplicateEffects_Set:FireAllClients("ShakeCamera", { Intensity = 0.75, Last = nil })
				
				newVelocity.Parent = HumRP
			end)
			
			StartupEvents["slam"] = StartupTrack:GetMarkerReachedSignal("slam"):Once(function()
				CombatUtils.stopVelocities(Character)
				HumRP.AssemblyLinearVelocity = Vector3.zero
				
				
				ReplicateEffects_Set:FireAllClients("Ground Crater", { Seed = math.random(1, 2000000000), start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0, 0), ["end"] = Vector3.new(0, -8, 0), nosound = true, nosmoke = true, size = 1.1 })
				ReplicateEffects_Set:FireAllClients("Ground Crater", { Seed = math.random(1, 2000000000), start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0, 0), ["end"] = Vector3.new(0, -8, 0), amount = 6, nosound = true, size = 0.3 })
				
				ReplicateEffects_Set:FireAllClients("ShakeCamera", { Intensity = 2, Last = 0.3 })
				
				HitboxHandler:SimpleOnce(HumRP, Vector3.new(20, 20, 20), CFrame.new(0, -3, 0), { Character }, nil, nil, function(EnemyCharacter)
					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
					
					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 6, nil, nil, true, false, true, true, false, nil, nil)
					
					if not HitInfo.Blocked then
						RagdollHandler.ragdoll(EnemyHumanoid, 2.5)
						StunHandler:Stun(EnemyCharacter, 0.1, true, 0, 0, true)
					end
					
					DamageHandler:TakeDamage(Character, EnemyHumanoid, not HitInfo.Blocked and 7 or 4, nil, nil, false, false, true, true, true, nil, nil)
					
					CombatUtils.createBodyVelocity(EnemyHumRP, { MaxForce = Vector3.one * math.huge, Velocity = Vector3.new(0, 46, 0) }, 0.165)
					CombatUtils.createAngularVelocity(EnemyHumRP, { MaxTorque = Vector3.one * math.huge, AngularVelocity = Vector3.new(Random.new():NextNumber(3, 4), Random.new():NextNumber(2, 3), Random.new():NextNumber(3, 5)) * Random.new():NextNumber(1.2, 1.5) }, 0.1)
				end)
			end)
			
			StartupEvents["jump"] = StartupTrack:GetMarkerReachedSignal("jump"):Once(function()
				ReplicateEffects_Set:FireAllClients("ShakeCamera", { Intensity = 1, Last = nil })
				
			end)
			
			
			StartupTrack.Stopped:Once(function()
				for _,v in StartupEvents do
					v:Disconnect()
				end

				StunHandler:Unstun(Character, Stun)
			end)
			
			
			AnimationService:stopAll(Character)
			AnimationService:playAnimation(Character, StartupAnimation)
			
			SoundsModule:PlaySound(MoveSounds.Dawi["Breakneck Spiral"].Variant, HumRP)
			
			return
		end
	end
}