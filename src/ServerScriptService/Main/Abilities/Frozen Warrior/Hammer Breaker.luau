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

local services = require(ReplicatedStorage.Services)
local VfxUtility = services:GetService("VFX_Utility")
local knockbackService = services:GetService("KnockbackService")
local Clock = services:GetService("Clock")


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
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 4, 0, true)
		
		
		local StartAnimation = MoveAnims["Frozen Warrior"]["Hammer Breaker"].Startup
		local StartTrack, StartEvents = AnimationService:getAnimationTrack(Character, StartAnimation)
		
		
		local Hit = false
		local Finisher = false
		
		
		local function HitFunction(EnemyCharacter: Model)
			if Hit == true or StartTrack.IsPlaying == false then return end
			Hit = true
			
			
			local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			
			
			if EnemyCharacter:HasTag('Ragdolled') then
				RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
			end
			
			
			local IceHammer = Models.Frozen.IceHammer:Clone()
			Debris:AddItem(IceHammer, 4.3)
			IceHammer:PivotTo(HumRP.CFrame)
			IceHammer.rootPart.Bone.Part0 = Character["Right Arm"]
			IceHammer.Parent = Character
			IceHammer:ScaleTo(0.01)
			IceHammer.hammer.Transparency = 1
			IceHammer.handle.Transparency = 1
			
			task.delay(0.8340000000000001, function()
				pcall(function()
					IceHammer.hammer.Transparency = 0
					IceHammer.handle.Transparency = 0
					IceHammer:ScaleTo(0.01)
					for v55 = 1, 10 do
						IceHammer:ScaleTo(v55 / 10)
						task.wait(0.01)
					end
				end)
			end)
			
			task.delay(1.45, function()
				pcall(function()
					for v56 = 10, 1, -1 do
						IceHammer:ScaleTo(v56 / 10)
						task.wait(0.01)
					end
					
					IceHammer.hammer.Transparency = 1
					IceHammer.handle.Transparency = 1
				end)
			end)
			
			task.delay(3.4669999999999996, function()
				pcall(function()
					IceHammer.hammer.Transparency = 0
					IceHammer.handle.Transparency = 0
					IceHammer:ScaleTo(0.01)
					
					for v57 = 1, 10 do
						IceHammer:ScaleTo(v57 / 10)
						task.wait(0.01)
					end
				end)
			end)
			
			task.delay(4.467, function()
				pcall(function()
					for v58 = 10, 1, -1 do
						IceHammer:ScaleTo(v58 / 10)
						task.wait(0.01)
					end
					
					IceHammer.hammer.Transparency = 1
					IceHammer.handle.Transparency = 1
				end)
			end)
			
			
			local UserAnimation = MoveAnims["Frozen Warrior"]["Hammer Breaker"].Main
			local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

			local VictimAnimation = MoveAnims["Frozen Warrior"]["Hammer Breaker"].Victim
			local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
			
			
			Stun:SetAttribute("WalkSpeed", 0)
			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
			local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -4.24) * CFrame.Angles(0, 3.141592653589793, 0), -1)
			
			
			Character:AddTag('CantRotate')
			EnemyCharacter:AddTag('CantRotate')
			
			iFramesService:AddAlliFrames(Character)
			iFramesService:AddAlliFrames(EnemyCharacter)
			
			CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
			
			local ServerTime = workspace:GetServerTimeNow()
			
			task.delay(4.267, function()
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 4.7, nil, nil, true, false, true, true, false, nil, 7)
				
				if HitInfo.Finisher == true then
					Finisher = true
					
					Character:AddTag('CantRotate')
					
					
					local FinisherUserAnimation = MoveAnims["Frozen Warrior"]["Hammer Breaker"].Finisher.Main
					local FinisherUserTrack, FinisherUserEvents = AnimationService:getAnimationTrack(Character, FinisherUserAnimation)

					local FinisherVictimAnimation = MoveAnims["Frozen Warrior"]["Hammer Breaker"].Finisher.Victim
					local FinisherVictimTrack, FinisherUserEvents = AnimationService:getAnimationTrack(EnemyCharacter, FinisherVictimAnimation)
					
					
					local TimeBetween = workspace:GetServerTimeNow() - ServerTime
					
					task.delay(0.8, function()
						Character:AddTag('CantRotate')
					end)
					for i = 1, 2 do
						local GoalArm = i == 1 and "Right" or "Left"
						
						local DoubleAxe = Models.Frozen.DoubleAxe[GoalArm .. "Axe"]:Clone()
						Debris:AddItem(DoubleAxe, 11 - TimeBetween)
						DoubleAxe:PivotTo(HumRP.CFrame)
						DoubleAxe.PrimaryPart["rootPart" .. string.sub(GoalArm, 1, 1)].Part0 = Character[GoalArm .. " Arm"]
						DoubleAxe.Parent = Character
						DoubleAxe:ScaleTo(0.01)
						DoubleAxe.Blade.Transparency = 1
						DoubleAxe.Handle.Transparency = 1
						
						local DelayFunction = task.delay
						local Timer = (GoalArm == "Left" and 5.25 or 5.7) - TimeBetween
						
						DelayFunction(math.max(Timer, 0), function()
							pcall(function()
								DoubleAxe.Blade.Transparency = 0
								DoubleAxe.Handle.Transparency = 0
								DoubleAxe:ScaleTo(0.01)
								for v36 = 1, 10 do
									DoubleAxe:ScaleTo(v36 / 10)
									task.wait(0.01)
								end
							end)
						end)
						
						task.delay(7.1 - TimeBetween, function()
							Character:AddTag('CantRotate')
							
							pcall(function()
								for v37 = 10, 1, -1 do
									DoubleAxe:ScaleTo(v37 / 10)
									task.wait(0.01)
								end
								
								DoubleAxe.Blade.Transparency = 1
								DoubleAxe.Handle.Transparency = 1
							end)
						end)
					end
					
					local Axe = Models.Frozen.Axe:Clone()
					Debris:AddItem(Axe, 11 - TimeBetween)
					Axe:PivotTo(HumRP.CFrame)
					Axe.rootPartAXE.rootPartAXE.Part0 = Character["Right Arm"]
					Axe.Parent = Character
					Axe:ScaleTo(0.01)
					Axe.Blade.Transparency = 1
					Axe.Handle.Transparency = 1
					
					task.delay(8.117 - TimeBetween, function()
						Character:AddTag('CantRotate')
						
						pcall(function()
							Axe.Blade.Transparency = 0
							Axe.Handle.Transparency = 0
							Axe:ScaleTo(0.01)
							for v39 = 1, 10 do
								Axe:ScaleTo(v39 / 10)
								task.wait(0.01)
							end
						end)
					end)
					
					task.delay(10.75 - TimeBetween, function()
						pcall(function()
							for v40 = 10, 1, -1 do
								Axe:ScaleTo(v40 / 10)
								task.wait(0.01)
							end
							
							Axe.Blade.Transparency = 1
							Axe.Handle.Transparency = 1
						end)
					end)
					
					local Cam = ReplicatedStorage.Resources["Frozen Warrior"].VFX.Finisher["Hammer Breaker"]["finisher cam"]:Clone()
					Debris:AddItem(Cam, 11.6 - TimeBetween)
					Cam.Parent = workspace.Thrown
					Cam:PivotTo(HumRP.CFrame)
					Cam.RootPart.MainWeld.Part0 = HumRP
					
					
					
					local DelayFunc1 = task.delay
					local Timer1 = 5.45 - TimeBetween
					DelayFunc1(math.max(Timer1, 0), function()
						EnemyCharacter["Right Arm"].Transparency = 1
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false, nil, nil)
					end)
					local DelayFunc2 = task.delay
					local Timer2 = 5.85 - TimeBetween
					DelayFunc2(math.max(Timer2, 0), function()
						EnemyCharacter["Left Arm"].Transparency = 1
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false, nil, nil)
					end)
					
					task.delay(10.667 - TimeBetween, function()
						EnemyCharacter.PrimaryPart.CFrame = HumRP.CFrame * CFrame.new(0, 2, -10)
						
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

						DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, true, false, true, true, true, nil, nil)
						knockbackService.Knockback(EnemyCharacter.PrimaryPart, {
							["duration"] = 0.25,
							["force"] = 17,
							["direction"] = HumRP.CFrame.LookVector + Vector3.new(0, 1.75, 0)
						})
						RagdollHandler.ragdoll(EnemyHumanoid, 4)
					end)
					
					
					local function EndFunc()
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						Character:RemoveTag('CantRotate')
						StunHandler:Unstun(Character, Stun)
						iFramesService:RemoveAlliFrames(Character)
						CollisionsModule:SetCollisionGroup(Character, "Players")
					end
					
					
					task.delay(11.65 - TimeBetween, function()
						EndFunc()
					end)
					FinisherUserTrack.Stopped:Once(function()
						EndFunc()
					end)
					FinisherUserTrack.Ended:Once(function()
						EndFunc()
					end)
					
					
					AnimationService:stopAll(Character)
					AnimationService:stopAll(EnemyCharacter)
					AnimationService:playAnimation(Character, FinisherUserAnimation)
					AnimationService:playAnimation(EnemyCharacter, FinisherVictimAnimation)
					
					
					ReplicateEffects_Set:FireAllClients("HammerBreaker", {
						Char = Character, 
						victim = EnemyCharacter,
						fakeCam = Cam, 
						timeFromMain = TimeBetween,
						Start = ServerTime,
						Stage = "pa_finisher",
						Animation = FinisherUserAnimation.AnimationId,
						VictimAnimation = FinisherVictimAnimation.AnimationId
					})
				else
					EnemyCharacter.PrimaryPart.CFrame = HumRP.CFrame * CFrame.new(0, 2, -4.2)
					
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
					
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 4.7, nil, nil, true, false, true, true, false, nil, nil)
					RagdollHandler.ragdoll(EnemyHumanoid, 1.5)
					knockbackService.Knockback(EnemyCharacter.PrimaryPart, {
						["duration"] = 0.2,
						["force"] = 43,
						["direction"] = Vector3.new(0, 1, 0)
					})
				end
				
				local Hitbox = HitboxHandler.new()
				Hitbox.Instance = CFrame.new((HumRP.CFrame * CFrame.new(0, 0, -2)).Position)
				Hitbox.Size = Vector3.new(30, 30, 30)
				Hitbox.Ignore = { Character, EnemyCharacter }
				Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(30, 30, 30) + Vector3.new(0, 25, 0) }
				Hitbox.onTouch = function(EnemyCharacter2)
					local EnemyHumanoid2: Humanoid = EnemyCharacter2.Humanoid

					if iFramesService:HasiFrame(EnemyCharacter2, Tool.Name) then return end

					RagdollHandler.ragdoll(EnemyHumanoid2, 2)
					knockbackService.Knockback(EnemyCharacter2.PrimaryPart, {
						["duration"] = 0.2,
						["force"] = 30,
						["direction"] = Vector3.new(0, 1, 0)
					})
					DamageHandler:TakeDamage(Character, EnemyHumanoid2, 8, nil, nil, false, false, true, true, true, nil, nil)
				end

				Hitbox:Once()
				Hitbox:Destroy()
			end)
			
			
			local function TakeDamage(Damage)
				DamageHandler:TakeDamage(Character, EnemyHumanoid, Damage, nil, nil, false, false, true, true, false, nil, nil)
			end
			
			task.delay(0.5, TakeDamage, 4.3)
			task.delay(1.38, TakeDamage, 2.1)
			task.delay(3.5, TakeDamage, 5.3)
			

			UserTrack.Stopped:Once(function()
				if not Finisher then
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end

					Character:RemoveTag('CantRotate')
					StunHandler:Unstun(Character, Stun)
					iFramesService:RemoveAlliFrames(Character)
					CollisionsModule:SetCollisionGroup(Character, "Players")
				end
			end)


			AnimationService:stopAll(Character)
			AnimationService:stopAll(EnemyCharacter)
			AnimationService:playAnimation(Character, UserAnimation)
			AnimationService:playAnimation(EnemyCharacter, VictimAnimation)


			Weld:Start(nil, EnemyPlayer, Player)
			
			ReplicateEffects_Set:FireAllClients("HammerBreaker", { Char = Character, victim = EnemyCharacter, Stage = "pa" })
		end
		
		
		task.delay(0.333, function()
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP.CFrame * CFrame.new(0, 1, -4)
			Hitbox.Size = Vector3.new(9, 2.5, 9)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				
				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 0.5, nil, nil, true, EnemyCharacter:HasTag('DEATH') and true or false, true, true, false, nil, nil)
				if HitInfo.Blocked or HitInfo.Countered then return end
				
				HitFunction(EnemyCharacter)
			end

			Hitbox:Once()
			Hitbox:Destroy()
		end)
		
		
		StartTrack.Stopped:Once(function()
			if not Hit then
				StunHandler:Unstun(Character, Stun)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
		
		ReplicateEffects_Set:FireAllClients("HammerBreaker", { Char = Character, Stage = "psa" })
	end
}