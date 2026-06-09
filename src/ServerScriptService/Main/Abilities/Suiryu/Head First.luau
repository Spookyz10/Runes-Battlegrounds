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
local StatesHandler = require(ServerModules.StatesHandler)


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
		
		
		local StartAnimation = MoveAnims.Suiryu.headfirst.Start
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}
		
		StartEvents["hit"] = StartTrack:GetMarkerReachedSignal("hit"):Once(function()
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(8, 12, 8)
			Hitbox.Offset = CFrame.new(0, (Hitbox.Size.Y / 2) - 3, -5)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				
				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				
				
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, false, true, true, true, false, nil, 19.5)
				if HitInfo.Countered == true then return end
				
				local Finisher = HitInfo.Finisher == true
				Hit = true
				
				
				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, false, true)
				end
				
				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)
				
				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
				
				EnemyCharacter:AddTag("CantRotate")
				
				
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), 10)
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)


				local UserAnimation, VictimAnimation
				local UserTrack
				local UserEvents = {}
				
				if Finisher then
					Character:SetAttribute("PurpleFinisher", true)
					
					UserAnimation = MoveAnims.Suiryu.headfirst.FinisherUser
					VictimAnimation = MoveAnims.Suiryu.headfirst.FinisherVictim
					UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)

					UserEvents["grab"] = UserTrack:GetMarkerReachedSignal("grab"):Once(function()
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 4 } })
						SoundsModule:PlaySound(MoveSounds.Suiryu.headfirst.Finisher.Grab, EnemyCharacter.Torso)
					end)
					
					UserEvents["jump"] = UserTrack:GetMarkerReachedSignal("jump"):Once(function()
						SoundHandler:AddSound(MoveSounds.Suiryu.headfirst.Finisher.JumpDebris, HumRP)
						
						for RockValue = 1, 3 do
							local Position = {
								Effect = "Ground Crater", 
								Seed = math.random(1, 8) + RockValue, 
								start = EnemyHumRP.Position + Vector3.new(0, 0.10000000149011612, 0, 0), 
								["end"] = Vector3.new(0, -14, 0, 0), 
								amount = 3 + RockValue / 2, 
								nosound = true, 
								nosmoke = RockValue > 2
							}

							local minusValue = false
							if RockValue <= 2 then
								minusValue = {
									minus = 0
								}
							end

							Position.stronger = minusValue
							Position.sizemult = 0.55 * RockValue
							Position.size = 0.85 * RockValue

							ReplicateEffects_Set:FireAllClients('Ground Crater', Position)
						end
						
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 8 } })
						SoundsModule:PlaySound(MoveSounds.Suiryu.headfirst.Finisher.Jump, HumRP.CFrame * CFrame.new(0, -3, 0))
						
						task.spawn(function()
							for i = 1, 5 do
								ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 30 })

								task.wait(0.05)
							end
						end)
					end)
					
					UserEvents["transition"] = UserTrack:GetMarkerReachedSignal("transition"):Once(function()
						HumRP.Anchored = true

						Character:AddTag("NoHeadLerp")
						EnemyCharacter:AddTag("NoHeadLerp")
						task.delay(0.25, function()
							Character:RemoveTag("NoHeadLerp")
							EnemyCharacter:RemoveTag("NoHeadLerp")
						end)

						Character:PivotTo(HumRP.CFrame * CFrame.new(0.644, 156.833, -111.196))
						
						
						local EndAnimation = MoveAnims.Suiryu.headfirst.FinisherUserEnd
						local EndTrack = AnimationService:getAnimationTrack(Character, EndAnimation)
						local EndEvents = {}
						
						EndEvents["end"] = EndTrack:GetMarkerReachedSignal("end"):Once(function()
							HumRP.Anchored = false
							
							ReplicateEffects_Set:FireClient(Player, "headfirst", { Stage = "Finisher", Substage = "End", Char = Character })
							
							
							if Weld then
								pcall(function()
									Weld:Stop()
								end)
								Weld = nil
							end

							iFramesService:RemoveAlliFrames(EnemyCharacter)
							EnemyCharacter:RemoveTag("CantRotate")
							CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
							StunHandler:Unstun(EnemyCharacter, EnemyStun)


							DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, true, true, true, nil, nil)
							RagdollHandler.ragdoll(EnemyHumanoid, 2, true, Character)
							NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(math.huge, math.huge, math.huge), Velocity = HumRP.CFrame.LookVector * Vector3.new(125, 0, 125) + Vector3.new(0, 125, 0) })
							
							
							ReplicateEffects_Set:FireAllClients("burncharacter", { Char = EnemyCharacter, Sound = Sounds.Other.Burning.SoundId })
							ReplicateEffects_Set:FireClient(Player, "suiryupassiveaura", { Char = Character })
						end)
						
						EndTrack.Stopped:Once(function()
							for _,v in EndEvents do
								v:Disconnect()
							end
							
							
							if Weld then
								pcall(function()
									Weld:Stop()
								end)
								Weld = nil
							end

							StunHandler:Unstun(Character, Stun)
							iFramesService:RemoveAlliFrames(Character)
							Character:RemoveTag("CantRotate")
							CollisionsModule:SetCollisionGroup(Character, "Players")
						end)
						
						AnimationService:stopAll(Character, 0)
						AnimationService:stopAll(EnemyCharacter, 0)
						
						AnimationService:playAnimation(Character, EndAnimation, nil, nil, 0)
						AnimationService:playAnimation(EnemyCharacter, MoveAnims.Suiryu.headfirst.FinisherVictimEnd, nil, nil, 0)
						
						
						SoundsModule:PlaySound(MoveSounds.Suiryu.headfirst.Finisher.End, HumRP, nil, nil, { DelayTime = 2.5, TweenInfo = TweenInfo.new(0.923) })
					end)


					Character:AddTag("CantRotate")

					iFramesService:AddAlliFrames(Character)
					iFramesService:AddAlliFrames(EnemyCharacter)

					ReplicateEffects_Set:FireAllClients("headfirst", { Stage = "Finisher", Substage = "Start", Char = Character, EChar = EnemyCharacter })

					SoundsModule:PlaySound(MoveSounds.Suiryu.headfirst.Finisher.User, Character.Torso)
					SoundsModule:PlaySound(MoveSounds.Suiryu.headfirst.Finisher.Victim, EnemyCharacter.Torso)
					
				else
					UserAnimation = MoveAnims.Suiryu.headfirst.User
					VictimAnimation = MoveAnims.Suiryu.headfirst.Victim
					UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)

					local Ended = false
					local function EndFunction()
						task.spawn(function()
							if Ended then return end
							Ended = true


							for _,v in UserEvents do
								v:Disconnect()
							end


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
					end

					UserEvents["hit1"] = UserTrack:GetMarkerReachedSignal("hit1"):Once(function()
						local moveme = Instance.new("BodyVelocity")
						moveme.MaxForce = Vector3.new(40000, 0, 40000)
						moveme.Name = "moveme"
						moveme:SetAttribute("End", 1)
						moveme:SetAttribute("Fallout", 0.95)
						moveme:SetAttribute("Speed", 85)
						moveme.Parent = HumRP

						ReplicateEffects_Set:FireAllClients("headfirst", { Char = Character, Stage = "Kick", Impact = true })
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 7 } })
					end)

					UserEvents["spin"] = UserTrack:GetMarkerReachedSignal("spin"):Once(function()
						ReplicateEffects_Set:FireAllClients("headfirst", { Char = Character, Stage = "Spin" })
					end)

					UserEvents["hit2"] = UserTrack:GetMarkerReachedSignal("hit2"):Once(function()
						EndFunction()
						
						SoundHandler:AddSound(MoveSounds.Suiryu.headfirst.Slam, HumRP)
						SoundHandler:AddSound(MoveSounds.Suiryu.headfirst.SlamExtra, HumRP)
						
						for RockValue = 1, 3 do
							local Position = {
								Seed = math.random(1, 8) + RockValue, 
								start = EnemyHumRP.Position + Vector3.new(0, 0.10000000149011612, 0, 0), 
								["end"] = Vector3.new(0, -14, 0, 0), 
								amount = 6 + RockValue / 2, 
								nosound = true, 
								nosmoke = RockValue > 2
							}

							local minusValue = false
							if RockValue <= 2 then
								minusValue = {
									minus = 0
								}
							end

							Position.stronger = minusValue
							Position.sizemult = 0.55 * RockValue
							Position.size = 0.85 * RockValue

							ReplicateEffects_Set:FireAllClients('Ground Crater', Position)
						end
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 8, Last = 0.6 } })


						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						iFramesService:RemoveAlliFrames(EnemyCharacter)
						EnemyCharacter:RemoveTag("CantRotate")
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
						StunHandler:Unstun(EnemyCharacter, EnemyStun)


						DamageHandler:TakeDamage(Character, EnemyHumanoid, 17.5, nil, nil, false, false, true, true, true, nil, nil)
						RagdollHandler.ragdoll(EnemyHumanoid, 2)
					end)

					UserTrack.Stopped:Once(EndFunction)
					
					
					iFramesService:AddBaseiFrames(Character)
					iFramesService:AddBaseiFrames(EnemyCharacter)
					
					SoundsModule:PlaySound(MoveSounds.Suiryu.headfirst.User, Character.Torso)
					SoundsModule:PlaySound(MoveSounds.Suiryu.headfirst.Victim, EnemyCharacter.Torso)
				end
				
				
				AnimationService:playAnimation(Character, UserAnimation)
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
				
				shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 5 } })
				
				Weld:Start(nil, EnemyPlayer or Player)
				
				StatesHandler.SkillText(Player, "HEAD FIRST [HIT]")
			end
			
			Hitbox:Once()
			Hitbox:Destroy()
			
			
			ReplicateEffects_Set:FireAllClients("headfirst", { Char = Character, Stage = "Kick" })
		end)
		
		StartTrack.Stopped:Once(function()
			for _,v in StartEvents do
				v:Disconnect()
			end
			
			
			if Hit then return end
			
			StunHandler:Unstun(Character, Stun)
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
		
		ReplicateEffects_Set:FireAllClients("headfirst", { Stage = "Trail", Char = Character })
		
		SoundsModule:PlaySound(MoveSounds.Suiryu.headfirst.Start, Character.Torso)
		SoundsModule:PlaySound(MoveSounds.Suiryu.headfirst.StartExtra, Character.Torso)
		
		StatesHandler.SkillText(Player, "HEAD FIRST [USED]")
	end
}