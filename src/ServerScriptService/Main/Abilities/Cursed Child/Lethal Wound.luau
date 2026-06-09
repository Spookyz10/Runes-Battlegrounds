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
		

		local WindupAnimation = MoveAnims["Cursed Child"]["Lethal Wound"].Windup
		local WindupTrack = AnimationService:getAnimationTrack(Character, WindupAnimation)
		local WindupEvents = {}
		
		
		local Hit = false
		local Finisher = false
		
		
		local BodyVelocitySlide = Instance.new("BodyVelocity")
		BodyVelocitySlide.MaxForce = Vector3.new(100000, 0, 100000)
		BodyVelocitySlide.Name = "moveme"
		BodyVelocitySlide:SetAttribute("End", 1)
		BodyVelocitySlide:SetAttribute("Fallout", 0.91)
		BodyVelocitySlide:SetAttribute("Goto", 70)
		BodyVelocitySlide:SetAttribute("Speed", 65)
		
		
		local Hitbox = ReplicatedHitbox.new(Player)
		Hitbox.Instance = HumRP
		Hitbox.Size = Vector3.new(6, 6, 9)
		Hitbox.Offset = CFrame.new(0, 0, -3.5)
		Hitbox.Ignore = { Character }
		Hitbox.onTouch = function(EnemyCharacter)
			local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid


			if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end

			local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, false, false, true, true, false, nil)
			Hit = true
			
			
			if EnemyCharacter:HasTag('Ragdolled') then
				RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
			end
			
			pcall(function()
				Hitbox:Destroy()
			end)
			
			task.delay(0.6, function()
				BodyVelocitySlide:Destroy()
			end)
			
			
			local VictimAnimation = MoveAnims["Cursed Child"]["Lethal Wound"].Victim
			local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
			
			local EndAnimation = MoveAnims["Cursed Child"]["Lethal Wound"].End
			local EndTrack = AnimationService:getAnimationTrack(Character, EndAnimation)
			
			local UserAnimation = MoveAnims["Cursed Child"]["Lethal Wound"].Hit
			local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
			local UserEvents = {}
			
			
			for _, conn in UserEvents do
				if typeof(conn) == "RBXScriptConnection" then
					conn:Disconnect()
				end
			end
			table.clear(UserEvents)
			
			
			local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, 1) * CFrame.Angles(0, rad(-180), 0), 7)
			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
			
			
			Character:AddTag('CantRotate')
			EnemyCharacter:AddTag('CantRotate')

			iFramesService:AddAlliFrames(Character)
			iFramesService:AddAlliFrames(EnemyCharacter)


			CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
			
			
			local StabTime = 1
			
			
			UserEvents["stab"] = UserTrack:GetMarkerReachedSignal("stab"):Connect(function()
				local FinisherHitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, StabTime == 4, nil, 10)
				
				if StabTime == 1 and FinisherHitInfo.Finisher == true then
					Finisher = true
					
					Character:SetAttribute("FinishSlicing", nil)
					
					
					local FinisherVictimAnimation = MoveAnims["Cursed Child"]["Lethal Wound"].FinisherVictim
					local FinisherVictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, FinisherVictimAnimation)

					local FinisherEndAnimation = MoveAnims["Cursed Child"]["Lethal Wound"].FinisherEnd
					local FinisherEndTrack = AnimationService:getAnimationTrack(Character, FinisherEndAnimation)

					local FinisherUserAnimation = MoveAnims["Cursed Child"]["Lethal Wound"].Finisher
					local FinisherUserTrack = AnimationService:getAnimationTrack(Character, FinisherUserAnimation)
					local FinisherUserEvents = {}
					
					
					for _, conn in FinisherUserEvents do
						if typeof(conn) == "RBXScriptConnection" then
							conn:Disconnect()
						end
					end
					table.clear(FinisherUserEvents)
					
					
					FinisherUserEvents["stab"] = FinisherUserTrack:GetMarkerReachedSignal("stab"):Connect(function()
						ReplicateEffects_Set:FireAllClients("LethalWoundFinisher", { Stage = "Stab", Char = Character })
						
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false, nil)
					end)
					
					FinisherUserEvents["stabtoleft"] = FinisherUserTrack:GetMarkerReachedSignal("stabtoleft"):Once(function()
						ReplicateEffects_Set:FireAllClients("LethalWoundFinisher", { Stage = "StabToLeft", Char = Character })
						
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false, nil)
					end)
					
					FinisherUserEvents["throwleft"] = FinisherUserTrack:GetMarkerReachedSignal("throwleft"):Once(function()
						ReplicateEffects_Set:FireAllClients("LethalWoundFinisher", { Stage = "ThrowLeft", Char = Character })
						
					end)
					
					FinisherUserEvents["victimland"] = FinisherUserTrack:GetMarkerReachedSignal("victimland"):Once(function()

					end)
					
					FinisherUserEvents["throwback"] = FinisherUserTrack:GetMarkerReachedSignal("throwback"):Once(function()
						ReplicateEffects_Set:FireAllClients("LethalWoundFinisher", { Stage = "ThrowBack", Char = Character })
						
					end)
					
					FinisherUserEvents["slicing"] = FinisherUserTrack:GetMarkerReachedSignal("slicing"):Connect(function()
						ReplicateEffects_Set:FireAllClients("LethalWoundFinisher", { Stage = "Slicing", Char = Character, Slice = true })
						
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false, nil)
					end)
					
					FinisherUserEvents["sliceemit"] = FinisherUserTrack:GetMarkerReachedSignal("sliceemit"):Once(function()
						ReplicateEffects_Set:FireAllClients("LethalWoundFinisher", { Stage = "Slice", Char = Character })
						
					end)
					
					FinisherUserEvents["sliced"] = FinisherUserTrack:GetMarkerReachedSignal("sliced"):Once(function()
						ReplicateEffects_Set:FireAllClients("LethalWoundFinisher", { Stage = "Sliced", Char = Character })
						
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false, nil)
					end)

					FinisherUserEvents["victimragdoll"] = FinisherUserTrack:GetMarkerReachedSignal("victimragdoll"):Once(function()
						ReplicateEffects_Set:FireAllClients("LethalWoundFinisher", { Stage = "StopSlicing", Char = Character })
						ReplicateEffects_Set:FireAllClients("LethalWoundFinisher", { Stage = "Slicing", Char = Character, Slice = false })
						
						Character:SetAttribute("FinishSlicing", true)
						
						DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, true, true, true, nil)
						RagdollHandler.ragdoll(EnemyHumanoid, 3)
					end)
					
					
					FinisherVictimTrack.Stopped:Once(function()
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

					FinisherUserEvents["Stopped"] = FinisherUserTrack.Stopped:Once(function()
						AnimationService:stopAll(Character)
						AnimationService:playAnimation(Character, FinisherEndAnimation)

						FinisherEndTrack.Stopped:Once(function()
							if Weld then
								pcall(function()
									Weld:Stop()
								end)
								Weld = nil
							end

							for _, conn in FinisherUserEvents do
								conn:Disconnect()
							end
							table.clear(FinisherUserEvents)

							StunHandler:Unstun(Character, Stun)
							Character:RemoveTag('CantRotate')
							iFramesService:RemoveAlliFrames(Character)
							CollisionsModule:SetCollisionGroup(Character, "Players")
						end)
					end)
					
					
					AnimationService:stopAll(EnemyCharacter)
					AnimationService:playAnimation(EnemyCharacter, FinisherVictimAnimation)

					AnimationService:stopAll(Character)
					AnimationService:playAnimation(Character, FinisherUserAnimation)
				else
					if StabTime == 1 or StabTime == 2 or StabTime == 3 then
						StabTime += 1
						
					elseif StabTime == 4 then
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
						NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(10000, 10000, 10000), Velocity = HumRP.CFrame.LookVector * Vector3.new(-35, 0, -35) + Vector3.new(0, -35, 0) })
					end
				end
			end)
			
			
			VictimTrack.Stopped:Once(function()
				if Finisher == true then return end
				
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
			
			UserEvents["Stopped"] = UserTrack.Stopped:Once(function()
				for _, conn in UserEvents do
					conn:Disconnect()
				end
				table.clear(UserEvents)
				
				if Finisher == true then return end
				
				AnimationService:stopAll(Character)
				AnimationService:playAnimation(Character, EndAnimation)
				
				EndTrack.Stopped:Once(function()
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end

					for _, conn in UserEvents do
						conn:Disconnect()
					end
					table.clear(UserEvents)

					StunHandler:Unstun(Character, Stun)
					Character:RemoveTag('CantRotate')
					iFramesService:RemoveAlliFrames(Character)
					CollisionsModule:SetCollisionGroup(Character, "Players")
				end)
			end)
			
			AnimationService:stopAll(EnemyCharacter)
			AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
			
			AnimationService:stopAll(Character)
			AnimationService:playAnimation(Character, UserAnimation)

			Weld:Start(nil, EnemyPlayer, Player)
			
			ReplicateEffects_Set:FireAllClients("LethalWound", { Stage = "Hit", Char = Character, HitAnim = UserAnimation.AnimationId })
		end
		
		
		WindupEvents["run"] = WindupTrack:GetMarkerReachedSignal("run"):Once(function()
			BodyVelocitySlide.Parent = HumRP
			
			Character:AddTag('CantRotate')
		end)
		
		WindupEvents["begincast"] = WindupTrack:GetMarkerReachedSignal("begincast"):Once(function()
			Hitbox:Start(0.4, true)
		end)
		
		WindupEvents["endcast"] = WindupTrack:GetMarkerReachedSignal("endcast"):Once(function()
			
		end)

		WindupEvents["getup"] = WindupTrack:GetMarkerReachedSignal("getup"):Once(function()
			BodyVelocitySlide:Destroy()
		end)
		
		
		WindupTrack.Stopped:Once(function()
			for _,v in WindupEvents do
				v:Disconnect()
			end
			
			if not Hit then
				BodyVelocitySlide:Destroy()
				
				Character:RemoveTag('CantRotate')
				StunHandler:Unstun(Character, Stun)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, WindupAnimation)
		
		ReplicateEffects_Set:FireAllClients("LethalWound", { Stage = "Windup", Char = Character, WindupAnim = WindupAnimation.AnimationId })
	end
}