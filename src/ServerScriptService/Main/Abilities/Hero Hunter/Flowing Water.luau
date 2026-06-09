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
		
		
		local StartupAnimation = MoveAnims["Hero Hunter"].flowingwater.Startup
		local StartupTrack, StartupEvents = AnimationService:getAnimationTrack(Character, StartupAnimation)
		
		
		local Hit = false
		local Tag = os.clock() + Player.UserId
		
		
		ReplicateEffects_Set:FireAllClients("clearVelocities", { Char = Character })
		ReplicateEffects_Set:FireAllClients("waterpalm", { Char = Character, Time = 0.65, Limb = "Right Arm" })
		ReplicateEffects_Set:FireAllClients("waterpalm", { Char = Character, Time = 0.65, Limb = "Left Arm" })
		
		
		local SmallDebrisSwing = Instance.new("Accessory")
		SmallDebrisSwing:AddTag("SmallDebris")
		SmallDebrisSwing.Name = "SmallDebris"
		SmallDebrisSwing.Parent = Character
		Debris:AddItem(SmallDebrisSwing, 0.80)
		
		
		table.insert(StartupEvents, StartupTrack:GetMarkerReachedSignal("swing"):Once(function()
			ReplicateEffects_Set:FireClient(Player, "velocityForward", { Distance = 65 })
		end))
		
		table.insert(StartupEvents, StartupTrack:GetMarkerReachedSignal("hit"):Once(function()
			HitboxHandler:SimpleOnce(HumRP, Vector3.new(6, 8, 7), CFrame.new(0, 0, -8), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

				local Ragdolled = EnemyCharacter:HasTag('Ragdolled')
				local inAir = EnemyCharacter:FindFirstChild("inAir") or (EnemyCharacter:GetAttribute("TouchedGround") and tick() - EnemyCharacter:GetAttribute("TouchedGround") <= 0.25)

				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or (Ragdolled and not inAir) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 1.5, nil, nil, true, EnemyCharacter:HasTag('DEATH') and true or false, true, false, false, nil, 23)
				if HitInfo.Countered then return end
				
				local LastKnockback = 55
				if HitInfo.Blocked == true then
					LastKnockback = 75
				end

				Hit = true


				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
				end


				local SmallDebrisHit = Instance.new("Accessory")
				SmallDebrisHit:AddTag("SmallDebris")
				SmallDebrisHit.Name = "SmallDebris"
				SmallDebrisHit.Parent = Character
				Debris:AddItem(SmallDebrisHit, 1.75)


				if HitInfo.Finisher == true then
					local UserAnimation = MoveAnims["Hero Hunter"].flowingwater.Finisher
					local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)


					local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0), -1)
					local GrabWeld = WeldSystem.new(Character:FindFirstChild("Right Arm"), EnemyCharacter:FindFirstChild("Head"), CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0), -1)
					local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)


					AnimationService:stopAll(Character)
					AnimationService:stopAll(EnemyCharacter)


					EnemyCharacter:AddTag('CantRotate')

					iFramesService:AddAlliFrames(Character)
					iFramesService:AddAlliFrames(EnemyCharacter)

					CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")


					local Bind = Instance.new("Folder")
					Bind.Name = "FlowingWaterAfterimage"
					Bind.Parent = Character


					table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("swing"):Connect(function()
						ReplicateEffects_Set:FireClient(Player, "velocityForward", { Distance = 37 })

						if Bind.Name == "FlowingWaterAfterimage" then
							Bind.Name = "FlowingWaterAfterimage2"
						else
							Bind.Name = "FlowingWaterAfterimage"
						end
					end))

					table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("hit"):Connect(function()
						ReplicateEffects_Set:FireAllClients("flowingwaterhit", { Char = Character })
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 1.25 } })

						DamageHandler:TakeDamage(Character, EnemyHumanoid, 1.5, nil, CombatAnims.Hits[tostring(math.random(1, 4))], false, false, true, true, false, nil)

						SoundsModule:PlaySound(MoveSounds["Hero Hunter"].flowingwater["Hit Enemy"], EnemyHumRP)
						SoundsModule:PlaySound(MoveSounds["Hero Hunter"].flowingwater["Hit Addon Enemy"], EnemyHumRP)
					end))

					table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("finalswing"):Once(function()
						ReplicateEffects_Set:FireClient(Player, "velocityForward", { Distance = 37 })
					end))

					table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("finalhit"):Once(function()
						if Bind then
							Bind:Destroy()
							Bind = nil
						end

						ReplicateEffects_Set:FireAllClients("flowingwaterhit", { Char = Character, FinalHit = true })
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 7 } })
						ReplicateEffects_Set:FireClient(Player, "velocityForward", { Distance = 37 })

						if SmallDebrisHit then
							SmallDebrisHit:Destroy()
							SmallDebrisHit = nil
						end

						SoundsModule:PlaySound(MoveSounds["Hero Hunter"].flowingwater["Hit Final Enemy"], EnemyHumRP)
					end))

					table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("throw"):Once(function()
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						GrabWeld:Start(nil, EnemyPlayer, Player)
						Character:AddTag('CantRotate')
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 9 } })
					end))

					table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("slam"):Once(function()
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						if GrabWeld then
							pcall(function()
								GrabWeld:Stop()
							end)
							GrabWeld = nil
						end

						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						EnemyCharacter:RemoveTag('CantRotate')
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

						RagdollHandler.ragdoll(EnemyHumanoid, 2)
						DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, true, true, true, nil)

						ReplicateEffects_Set:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0), ["end"] = Vector3.new(0, -25, 0), amount = 9,nosound = false, size = 1.4 })
						ReplicateEffects_Set:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0), ["end"] = Vector3.new(0, -25, 0), amount = 6, nosound = true, size = 0.3 })
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 7 } })

						task.spawn(function()
							HitboxHandler:SimpleOnce(HumRP, Vector3.new(20, 20, 20), CFrame.new(0, 0, 0), { Character, EnemyCharacter }, nil, nil, function(EnemyCharacter2: Model)
								local EnemyHumRP2: BasePart = EnemyCharacter2.HumanoidRootPart
								local EnemyHumanoid2: Humanoid = EnemyCharacter2.Humanoid

								if EnemyCharacter2:GetAttribute("iFrames") >= 2 then return end

								DamageHandler:TakeDamage(Character, EnemyHumanoid2, 12, nil, nil, false, false, false, true, true, nil, nil)
								RagdollHandler.ragdoll(EnemyHumanoid2, 2)
								NewKnockback:Knockback(EnemyCharacter2, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 100000, 1), Velocity = HumRP.CFrame.UpVector * 75 })
							end)
						end)
					end))


					UserTrack.Stopped:Once(function()
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						if GrabWeld then
							pcall(function()
								GrabWeld:Stop()
							end)
							GrabWeld = nil
						end

						StunHandler:Unstun(Character, Stun)
						Character:RemoveTag('CantRotate')
						iFramesService:RemoveAlliFrames(Character)
						CollisionsModule:SetCollisionGroup(Character, "Players")
					end)

					AnimationService:playAnimation(Character, UserAnimation)

					Weld:Start(nil, EnemyPlayer, Player)

					ReplicateEffects_Set:FireAllClients("flowingwaterafterimage", { Bind = Bind, Char = Character })
					ReplicateEffects_Set:FireAllClients("waterpalm", { Char = Character, Time = 2, Limb = "Right Arm" })
					ReplicateEffects_Set:FireAllClients("waterpalm", { Char = Character, Time = 2, Limb = "Left Arm" })
					ReplicateEffects_Set:FireAllClients("flowingwaterhit", { Char = Character })
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 3.25 } })

					SoundsModule:PlaySound(MoveSounds["Hero Hunter"].flowingwater.Land, HumRP)
				else
					local UserAnimation = MoveAnims["Hero Hunter"].flowingwater.User
					local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)


					local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0), -1)
					local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)


					AnimationService:stopAll(Character)
					AnimationService:stopAll(EnemyCharacter)


					EnemyCharacter:AddTag('CantRotate')

					iFramesService:AddAlliFrames(Character)
					iFramesService:AddAlliFrames(EnemyCharacter)

					CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")


					local Bind = Instance.new("Folder")
					Bind.Name = "FlowingWaterAfterimage"
					Bind.Parent = Character


					table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("swing"):Connect(function()
						ReplicateEffects_Set:FireClient(Player, "velocityForward", { Distance = 37 })

						if Bind.Name == "FlowingWaterAfterimage" then
							Bind.Name = "FlowingWaterAfterimage2"
						else
							Bind.Name = "FlowingWaterAfterimage"
						end
					end))

					table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("hit"):Connect(function()
						ReplicateEffects_Set:FireAllClients("flowingwaterhit", { Char = Character })
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 1.25 } })

						DamageHandler:TakeDamage(Character, EnemyHumanoid, 1.5, nil, CombatAnims.Hits[tostring(math.random(1, 4))], false, false, true, true, false, nil)

						SoundsModule:PlaySound(MoveSounds["Hero Hunter"].flowingwater["Hit Enemy"], EnemyHumRP)
						SoundsModule:PlaySound(MoveSounds["Hero Hunter"].flowingwater["Hit Addon Enemy"], EnemyHumRP)
					end))

					table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("finalswing"):Once(function()
						ReplicateEffects_Set:FireClient(Player, "velocityForward", { Distance = 37 })

						if SmallDebrisHit then
							SmallDebrisHit:Destroy()
							SmallDebrisHit = nil
						end
					end))

					table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("finalhit"):Once(function()
						if Bind then
							Bind:Destroy()
							Bind = nil
						end

						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end


						StunHandler:Unstun(Character, Stun)
						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						EnemyCharacter:RemoveTag('CantRotate')
						iFramesService:RemoveAlliFrames(Character)
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						CollisionsModule:SetCollisionGroup(Character, "Players")
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")


						RagdollHandler.ragdoll(EnemyHumanoid, 2)
						NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(2050000, 0, 2050000), Velocity = HumRP.CFrame.LookVector * LastKnockback + Vector3.new(0, 25, 0) })
						StartAirDetect:Fire(EnemyCharacter)
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 7, nil, nil, false, false, true, true, true, nil)

						ReplicateEffects_Set:FireAllClients("flowingwaterhit", { Char = Character, FinalHit = true })
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 7 } })

						SoundsModule:PlaySound(MoveSounds["Hero Hunter"].flowingwater["Hit Final Enemy"], EnemyHumRP)
					end))


					UserTrack.Stopped:Once(function()
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						StunHandler:Unstun(Character, Stun)
						iFramesService:RemoveAlliFrames(Character)
						CollisionsModule:SetCollisionGroup(Character, "Players")
					end)

					AnimationService:playAnimation(Character, UserAnimation)

					Weld:Start(nil, EnemyPlayer, Player)

					ReplicateEffects_Set:FireAllClients("flowingwaterafterimage", { Bind = Bind, Char = Character })
					ReplicateEffects_Set:FireAllClients("waterpalm", { Char = Character, Time = 2, Limb = "Right Arm" })
					ReplicateEffects_Set:FireAllClients("waterpalm", { Char = Character, Time = 2, Limb = "Left Arm" })
					ReplicateEffects_Set:FireAllClients("flowingwaterhit", { Char = Character })
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 3.25 } })

					SoundsModule:PlaySound(MoveSounds["Hero Hunter"].flowingwater.Land, HumRP)
				end
			end)
		end))
		
		
		StartupTrack.Stopped:Once(function()
			ReplicateEffects_Set:FireAllClients("clearVelocities", { Char = Character })
			
			if SmallDebrisSwing then
				SmallDebrisSwing:Destroy()
				SmallDebrisSwing = nil
			end
			
			if not Hit then
				StunHandler:Unstun(Character, Stun)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartupAnimation)
		
		SoundsModule:PlaySound(MoveSounds["Hero Hunter"].flowingwater.Startup, HumRP)
	end
}