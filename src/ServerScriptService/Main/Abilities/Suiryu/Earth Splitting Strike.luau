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
		local Hit = nil
		local Tag = os.clock() + Player.UserId
		
		
		local StartAnimation = MoveAnims.Suiryu.earthsplittingstrike.Start
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}
		
		StartEvents["stomp"] = StartTrack:GetMarkerReachedSignal("stomp"):Once(function()
			Character:AddTag("CantRotate")
			
			SoundsModule:PlaySound(MoveSounds.Suiryu.earthsplittingstrike.Stomp, HumRP.CFrame * CFrame.new(0, -2.4, 0))
			
			
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(10, 10, 10)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if Hit ~= nil or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				
				Hit = EnemyCharacter
				StatesHandler.SkillText(Player, "EARTH SPLITTING STRIKE [HIT]")
				
				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)
				
				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
				
				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)
				
				EnemyCharacter:AddTag("CantRotate")
				
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 10, nil, nil, false, false, true, false, false, nil, nil)
				
				
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				local WeldOffset = CFrame.new(0, 0, -9) * CFrame.Angles(0, math.pi, 0)
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, WeldOffset)
				local EnemyGoalCF = CFrame.lookAt(EnemyHumRP.Position, HumRP.Position)
				local GoalRun = EnemyGoalCF * WeldOffset
				
				EnemyHumRP.CFrame = EnemyGoalCF
				
				local RunStartAnimation = MoveAnims.Suiryu.earthsplittingstrike.RunStart
				local RunStartTrack = AnimationService:getAnimationTrack(Character, RunStartAnimation)
				
				RunStartTrack:GetMarkerReachedSignal("Start"):Once(function()
					local RunAnimation = MoveAnims.Suiryu.earthsplittingstrike.Run
					local RunTrack = AnimationService:getAnimationTrack(Character, RunAnimation)

					AnimationService:playAnimation(Character, RunAnimation)

					ReplicateEffects_Set:FireAllClients("earthsplittingstrike", { Stage = "Run", Char = Character, AnimationId = RunAnimation.AnimationId })
					
					SoundsModule:PlaySound(MoveSounds.Suiryu.earthsplittingstrike.Wind, Character.Torso)


					task.wait(0.433)


					AnimationService:stopAll(Character)


					local UserAnimation = MoveAnims.Suiryu.earthsplittingstrike.User
					local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
					local UserEvents = {}
					
					UserEvents["kick"] = UserTrack:GetMarkerReachedSignal("kick"):Once(function()
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, false, false, true, false, false, nil, nil)
						
						SoundsModule:PlaySound(MoveSounds.Suiryu.earthsplittingstrike.Teleport, Character.Torso)
						SoundsModule:PlaySound(MoveSounds.Suiryu.earthsplittingstrike.Kick, EnemyCharacter.Torso)
						
						task.delay(0.25, function()
							SoundsModule:PlaySound(MoveSounds.Suiryu.earthsplittingstrike.Ragdoll, EnemyCharacter.Torso)
						end)
					end)

					UserEvents["punch"] = UserTrack:GetMarkerReachedSignal("punch"):Once(function()
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end
						
						
						local EndAnimation = MoveAnims.Suiryu.earthsplittingstrike.End
						local EndTrack = AnimationService:getAnimationTrack(Character, EndAnimation)
						
						EndTrack:GetMarkerReachedSignal("end"):Once(function()
							HumRP.Anchored = false
							ReplicateEffects_Set:FireClient(Player, "fixspeedbug")
							
							StunHandler:Unstun(Character, Stun)
							iFramesService:RemoveAlliFrames(Character)
							Character:RemoveTag("CantRotate")
							CollisionsModule:SetCollisionGroup(Character, "Players")
						end)
						
						HumRP.CFrame = CFrame.lookAlong(ComGet:InvokeClient(Player, { Func = "GetCF", Object = Character.Torso }).Position, HumRP.CFrame.LookVector)
						EnemyHumRP.CFrame = HumRP.CFrame * CFrame.new(0, 0, -4) * CFrame.Angles(0, math.pi, 0)
						
						AnimationService:stopAll(Character, 0)
						AnimationService:stopAll(EnemyCharacter, 0)
						
						AnimationService:playAnimation(Character, EndAnimation, nil, nil, 0)
						AnimationService:playAnimation(EnemyCharacter, MoveAnims.Suiryu.earthsplittingstrike.VictimEnd, nil, 0.7, 0)
						
						SoundsModule:PlaySound(MoveSounds.Suiryu.earthsplittingstrike.Punch, EnemyCharacter.Torso)
						SoundsModule:PlaySound(MoveSounds.Suiryu.earthsplittingstrike.SmallWind, EnemyCharacter.Torso.Position)
						SoundsModule:PlaySound(MoveSounds.Suiryu.earthsplittingstrike.MediumWind, EnemyCharacter.Torso.Position)
						
						
						task.wait(1.4)
						
						
						SoundsModule:PlaySound(MoveSounds.Suiryu.earthsplittingstrike.BigWind, EnemyCharacter.Torso.Position)
						

						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						EnemyCharacter:RemoveTag("CantRotate")
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")


						DamageHandler:TakeDamage(Character, EnemyHumanoid, 35, nil, nil, false, false, true, false, true, nil, nil)
						RagdollHandler.ragdoll(EnemyHumanoid, 2, true)
						NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(100000, 100000, 100000), Velocity = HumRP.CFrame.LookVector * 200 + Vector3.new(0, 25, 0) })
					end)

					UserTrack.Stopped:Once(function()
						for _,v in UserEvents do
							v:Disconnect()
						end
					end)


					AnimationService:playAnimation(Character, UserAnimation)

					ReplicateEffects_Set:FireAllClients("earthsplittingstrike", { Stage = "WholeSequence", Char = Character, EChar = EnemyCharacter, Tag = Tag })

					task.delay(0.5, function()
						SoundsModule:PlaySound(MoveSounds.Suiryu.earthsplittingstrike.Jump, Character.Torso)
					end)

					task.delay(3, function()
						SoundsModule:PlaySound(MoveSounds.Suiryu.earthsplittingstrike.TeleportGround, Character.Torso)
					end)

					task.delay(4.5, function()
						SoundsModule:PlaySound(MoveSounds.Suiryu.earthsplittingstrike.Pose, Character.Torso)
					end)

					HumRP.Anchored = true
					Weld:Start(nil, EnemyPlayer or Player)
				end)
				
				
				AnimationService:playAnimation(Character, RunStartAnimation)
				AnimationService:playAnimation(EnemyCharacter, MoveAnims.Suiryu.earthsplittingstrike.Victim, nil, 0.567)
				
				ReplicateEffects_Set:FireClient(Player, "TweenPlayerPosition", { GoalPosition = GoalRun.Position, EasingTime = 1, EasingStyle = "Linear", EasingDirection = "Out" })
				ReplicateEffects_Set:FireAllClients("earthsplittingstrike", { Stage = "ShockwaveHit", Char = Character, EChar = Hit, ShockwaveCF = EnemyHumRP.CFrame * CFrame.new(0, -2.4, 0), Tag = Tag })
				
				Debris:AddItem(SoundsModule:PlaySound(MoveSounds.Suiryu.earthsplittingstrike.Run, Character.Torso), 1)
			end
			
			
			for _, Offset in {
				-17,
				-29,
				-41,
				-53,
				-65
			} do
				Hitbox.Offset = CFrame.new(0, 2, Offset)
				Hitbox:Once()
				
				SoundsModule:PlaySound(MoveSounds.Suiryu.earthsplittingstrike.Shockwave, HumRP.CFrame * CFrame.new(0, -2.4, Offset))
				
				if Hit then
					SoundsModule:PlaySound(MoveSounds.Suiryu.earthsplittingstrike.RockRise, HumRP.CFrame * CFrame.new(0, -2.4, Offset))
					
					break
					
				else
					ReplicateEffects_Set:FireAllClients("earthsplittingstrike", { Stage = "Shockwave", Char = Character, ShockwaveCF = HumRP.CFrame * CFrame.new(0, -2.4, Offset) })
					
				end

				task.wait(0.1)
			end
			
			
			Hitbox:Destroy()
		end)
		
		StartTrack.Stopped:Once(function()
			for _,v in StartEvents do
				v:Disconnect()
			end
			
			if not Hit then
				StunHandler:Unstun(Character, Stun)
				Character:RemoveTag("CantRotate")
				CollisionsModule:SetCollisionGroup(Character, "Players")
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
		
		ReplicateEffects_Set:FireAllClients("earthsplittingstrike", { Stage = "Start", Char = Character })
		
		SoundsModule:PlaySound(MoveSounds.Suiryu.earthsplittingstrike.Startup, Character.Torso)
		
		CollisionsModule:SetCollisionGroup(Character, "NonPColDebri")
		
		StatesHandler.SkillText(Player, "EARTH SPLITTING STRIKE [USED]")
	end
}