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
		
		
		local StartupAnimation = MoveAnims["Hero Hunter"].lethalwhirlwindstream.Startup
		local StartupTrack, StartupEvents = AnimationService:getAnimationTrack(Character, StartupAnimation)
		
		
		local Hit = false
		local Finisher = false
		
		
		ReplicateEffects_Set:FireAllClients("clearVelocities", { Char = Character })
		ReplicateEffects_Set:FireAllClients("waterpalm", { Char = Character, Time = 1, Limb = "Right Arm" })
		
		
		table.insert(StartupEvents, StartupTrack:GetMarkerReachedSignal("swing"):Once(function()
			ReplicateEffects_Set:FireClient(Player, "velocityForward", { Distance = 25 })
		end))
		
		table.insert(StartupEvents, StartupTrack:GetMarkerReachedSignal("hit"):Once(function()
			HitboxHandler:SimpleOnce(HumRP, Vector3.new(6, 8, 9), CFrame.new(0, 0, -7), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

				local Ragdolled = EnemyCharacter:HasTag('Ragdolled')
				local inAir = EnemyCharacter:FindFirstChild("inAir") or (EnemyCharacter:GetAttribute("TouchedGround") and tick() - EnemyCharacter:GetAttribute("TouchedGround") <= 0.60)

				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or (Ragdolled and not inAir) then return end

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 1.5, nil, nil, true, EnemyCharacter:HasTag('DEATH') and true or false, true, false, false, nil, nil)
				if HitInfo.Blocked == true or HitInfo.Countered == true then return end
				Hit = true


				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
				end


				local VictimAnimation = MoveAnims["Hero Hunter"].lethalwhirlwindstream.Victim
				local VictimTrack = AnimationService:getAnimationTrack(Character, VictimAnimation)

				local UserAnimation = MoveAnims["Hero Hunter"].lethalwhirlwindstream.User
				local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)


				local Weld = WeldSystem.new(Character:FindFirstChild("Right Arm"), EnemyHumRP, CFrame.new(0, -1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1), -1)
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)


				EnemyCharacter:AddTag('CantRotate')

				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)

				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "NoCol")


				local Attachment1
				local moveme


				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("firststep"):Once(function()
					moveme = Instance.new("BodyVelocity", Character.PrimaryPart)
					moveme.Name = "moveme"
					moveme.MaxForce = Vector3.new(1, 0, 1) * 2000000000
					moveme:SetAttribute("Fallout", 1)
					moveme:SetAttribute("Speed", 22.5)
					moveme:SetAttribute("End", 6)
				end))

				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("step"):Connect(function()
					moveme:SetAttribute("Speed", moveme:GetAttribute("Speed") + 25)
				end))

				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("spinstart"):Once(function()
					if moveme then
						moveme:Destroy()
						moveme = nil
					end
				end))

				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("slam"):Once(function()
					pcall(function()
						SoundsModule:PlaySound(MoveSounds["Hero Hunter"].lethal["First Hit Enemy"], EnemyHumRP)
					end)

					Attachment1 = Instance.new("Attachment", EnemyCharacter.PrimaryPart)
					Attachment1.CFrame = CFrame.new(0, 0, 0.526)

					ReplicateEffects_Set:FireAllClients("Ground Crater", { Seed = math.random(1, 2147483647), start = EnemyHumRP.Position, ["end"] = Vector3.new(0, -7, 0), nosound = true })
					ReplicateEffects_Set:FireAllClients("huntergrind", { Attachment = Attachment1 })
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 5 } })

					DamageHandler:TakeDamage(Character, EnemyHumanoid, 8.5, nil, nil, false, false, true, true, false, nil, nil)

					task.spawn(function()
						HitboxHandler:SimpleOnce(HumRP, Vector3.new(11, 11, 11), CFrame.new(0, 0, 0), { Character, EnemyCharacter }, nil, nil, function(EnemyCharacter2: Model)
							local EnemyHumRP2: BasePart = EnemyCharacter2.HumanoidRootPart
							local EnemyHumanoid2: Humanoid = EnemyCharacter2.Humanoid

							if EnemyCharacter2:GetAttribute("iFrames") >= 2 then return end

							DamageHandler:TakeDamage(Character, EnemyHumanoid2, 12, nil, nil, false, false, false, true, true, nil, nil)
							RagdollHandler.ragdoll(EnemyHumanoid2, 2)
							NewKnockback:Knockback(EnemyCharacter2, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 100000, 1), Velocity = HumRP.CFrame.UpVector * 75 })
						end)
					end)
				end))

				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("offground"):Once(function()
					Attachment1.Name = "donedrag"
					Debris:AddItem(Attachment1,2)
				end))

				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("finalslam"):Once(function()
					pcall(function()
						SoundsModule:PlaySound(MoveSounds["Hero Hunter"].lethal["Last Hit Enemy"], EnemyHumRP)
					end)

					ReplicateEffects_Set:FireAllClients("Ground Crater", { start = Character.PrimaryPart.Position, Seed = math.random(1,2147483647), ["end"] = Vector3.new(0, -7, 0), nosound = true })
					ReplicateEffects_Set:FireAllClients("Ground Crater", { ["end"] = Vector3.new(0, -14, 0), start = Character.PrimaryPart.Position, Seed = math.random(1,2147483647), size = 2 })
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 10 } })

					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end

					if moveme then
						moveme:Destroy()
						moveme = nil
					end

					local FinisherHitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 10, nil, nil, false, false, true, true, false, nil, 21)

					if FinisherHitInfo.Finisher == true then
						Finisher = true

						local FinisherVictimAnimation = MoveAnims["Hero Hunter"].lethalwhirlwindstream["Finisher Victim"]
						local FinisherVictimTrack = AnimationService:getAnimationTrack(Character, FinisherVictimAnimation)

						local FinisherUserAnimation = MoveAnims["Hero Hunter"].lethalwhirlwindstream["Finisher User"]
						local FinisherUserTrack, FinisherUserEvents = AnimationService:getAnimationTrack(Character, FinisherUserAnimation)


						local FinisherWeld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3), -1)
						Character:AddTag('CantRotate')


						table.insert(FinisherUserEvents, FinisherUserTrack:GetMarkerReachedSignal("bodyslam"):Once(function()
							ReplicateEffects_Set:FireAllClients("Ground Crater", { ["end"] = Vector3.new(0, -18, 0), start = Character.PrimaryPart.Position, Seed = math.random(1,2147483647), size = 4 })
							shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 10 } })

							if FinisherWeld then
								pcall(function()
									FinisherWeld:Stop()
								end)
								FinisherWeld = nil
							end

							StunHandler:Unstun(EnemyCharacter, EnemyStun)
							EnemyCharacter:RemoveTag('CantRotate')
							iFramesService:RemoveAlliFrames(EnemyCharacter)
							CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

							RagdollHandler.ragdoll(EnemyHumanoid, 2)
							DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, true, false, true, nil, nil)

							task.spawn(function()
								HitboxHandler:SimpleOnce(HumRP, Vector3.new(30, 30, 30), CFrame.new(0, 0, 0), { Character, EnemyCharacter }, nil, nil, function(EnemyCharacter2: Model)
									local EnemyHumRP2: BasePart = EnemyCharacter2.HumanoidRootPart
									local EnemyHumanoid2: Humanoid = EnemyCharacter2.Humanoid

									if EnemyCharacter2:GetAttribute("iFrames") >= 2 then return end

									DamageHandler:TakeDamage(Character, EnemyHumanoid2, 12, nil, nil, false, false, false, true, true, nil, nil)
									RagdollHandler.ragdoll(EnemyHumanoid2, 2)
									NewKnockback:Knockback(EnemyCharacter2, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 100000, 1), Velocity = HumRP.CFrame.UpVector * 75 })
								end)
							end)
						end))


						FinisherVictimTrack.Stopped:Once(function()
							if FinisherWeld then
								pcall(function()
									FinisherWeld:Stop()
								end)
								FinisherWeld = nil
							end

							StunHandler:Unstun(EnemyCharacter, EnemyStun)
							EnemyCharacter:RemoveTag('CantRotate')
							iFramesService:RemoveAlliFrames(EnemyCharacter)
							CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
						end)

						FinisherUserTrack.Stopped:Once(function()
							if FinisherWeld then
								pcall(function()
									FinisherWeld:Stop()
								end)
								FinisherWeld = nil
							end

							StunHandler:Unstun(Character, Stun)
							Character:RemoveTag('CantRotate')
							iFramesService:RemoveAlliFrames(Character)
							CollisionsModule:SetCollisionGroup(Character, "Players")
						end)


						AnimationService:stopAll(Character)
						AnimationService:stopAll(EnemyCharacter)

						AnimationService:playAnimation(Character, FinisherUserAnimation)
						AnimationService:playAnimation(EnemyCharacter, FinisherVictimAnimation)

						FinisherWeld:Start(nil, EnemyPlayer, Player)
					else
						StunHandler:Unstun(Character, Stun)
						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						EnemyCharacter:RemoveTag('CantRotate')
						iFramesService:RemoveAlliFrames(Character)
						iFramesService:RemoveAlliFrames(EnemyCharacter)

						RagdollHandler.ragdoll(EnemyHumanoid, 2)
						NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 100000, 1), Velocity = HumRP.CFrame.UpVector * 75 })
						StartAirDetect:Fire(EnemyCharacter)

						CollisionsModule:SetCollisionGroup(Character, "Players")
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
					end

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


				VictimTrack.Stopped:Once(function()
					if not Finisher then
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
					end
				end)

				UserTrack.Stopped:Once(function()
					if not Finisher then
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						StunHandler:Unstun(Character, Stun)
						iFramesService:RemoveAlliFrames(Character)
						CollisionsModule:SetCollisionGroup(Character, "Players")
					end

					if moveme then
						moveme:Destroy()
						moveme = nil
					end
				end)


				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)

				AnimationService:playAnimation(Character, UserAnimation)
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)

				Weld:Start(nil, EnemyPlayer, Player)

				ReplicateEffects_Set:FireAllClients("waterpalm", { Char = Character, Time = 1.25, Limb = "Right Arm" })
			end)
		end))
		
		
		StartupTrack.Stopped:Once(function()
			ReplicateEffects_Set:FireAllClients("clearVelocities", { Char = Character })

			if not Hit then
				StunHandler:Unstun(Character, Stun)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartupAnimation)
		
		SoundsModule:PlaySound(MoveSounds["Hero Hunter"].lethal.Startup, HumRP)
	end
}