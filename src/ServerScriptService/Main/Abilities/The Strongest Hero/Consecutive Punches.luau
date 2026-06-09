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
		local HumRP: BasePart = Character.HumanoidRootPart
		local Humanoid: Humanoid = Character.Humanoid
		local Animator: Animator = Humanoid.Animator

		iFramesService:AddAlliFrames(Character)

		local Bind = Instance.new("StringValue");
		Bind.Parent = Character
		Bind.Name = "Barrage"
		Bind:SetAttribute("Delay", 0.0001)
		Bind:SetAttribute("Times", 2)


		local Stun = StunHandler:Stun(Character, nil, true, 5, 0)
		
		local Hit = false
		local Finisher = false
		
		
		local UserAnimation = MoveAnims.BaldHero["Consecutive Punches"].User
		local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
		local UserEvents = {}
		
		
		local HitTimes = { .50,  .100,  .150,  .250,  .334,  .400,  .445,  .500, .565,  .600,  .625,  .645,  .675,  .700,  .800, .900,  .1000,  1.1,  1.20,  1.30,  1.40 }
		
		
		for _, delayTime in ipairs(HitTimes) do
			task.delay(delayTime, function()
				if not UserTrack.IsPlaying then return end
				
				local Hitbox = HitboxHandler.new()
				Hitbox.Instance = HumRP
				Hitbox.Size = Vector3.new(1,1,1) * 9
				Hitbox.Offset = CFrame.new(0,0,-Hitbox.Size.Z/2)
				Hitbox.onTouch = function(EnemyCharacter)
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyPlayer = game.Players:GetPlayerFromCharacter(EnemyCharacter)
					
					if Finisher == true or EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
					
					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 0.75, 0.75, Animations.Combat.Hits[tostring(math.random(1, 1))], true, true, true, true, false, nil, 13)
					
					if HitInfo.Countered == true then
						return
					end
					
					if HitInfo.Finisher == true then
						Finisher = true
						
						local PlayerAnimation = MoveAnims.BaldHero["Consecutive Punches"].FinisherUser
						local PlayerTrack = AnimationService:getAnimationTrack(Character, PlayerAnimation)
						
						local EnemyAnimation = MoveAnims.BaldHero["Consecutive Punches"].FinisherVictim
						local EnemyTrack = AnimationService:getAnimationTrack(EnemyCharacter, EnemyAnimation)
						
						
						if Bind then
							Bind:Destroy()
							Bind = nil
						end
						
						
						local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -4.5) * CFrame.Angles(0, math.pi, 0), 6)
						local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
						
						
						HumRP.Anchored = true
						
						
						iFramesService:AddAlliFrames(EnemyCharacter)
						
						CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
						
						Character:AddTag("CantRotate")
						EnemyCharacter:AddTag("CantRotate")
						
						
						
						task.delay(4.13, function()
							task.spawn(function()
								for _, descendant in EnemyCharacter:GetDescendants() do
									if descendant:IsA("BasePart") then
										descendant.Transparency = 1
										local face = descendant:FindFirstChild("face")
										if face and face:IsA("Decal") then
											face.Transparency = 1
										end
									elseif descendant:IsA("Decal") then
										descendant.Transparency = 1
									elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
										descendant.Enabled = false
									elseif descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") then
										descendant.Enabled = false
									end
								end
							end)
							
							AnimationService:stopAll(EnemyCharacter)
							
							if Weld then
								pcall(function()
									Weld:Stop()
								end)
								Weld = nil
							end
							
							CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
							EnemyCharacter:RemoveTag("CantRotate")
							iFramesService:RemoveAlliFrames(EnemyCharacter)
							StunHandler:Unstun(EnemyCharacter, EnemyStun)
							
							RagdollHandler.ragdoll(EnemyHumanoid, 3)
							DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, true, true, true, nil, nil)
							
							HumRP.Anchored = false
							
							ReplicateEffects_Set:FireAllClients("CPFinisherLast", { char = Character })
							shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 15, Last = 1 } })
						end)
						
						
						EnemyTrack.Stopped:Once(function()
							if Weld then
								pcall(function()
									Weld:Stop()
								end)
								Weld = nil
							end
							
							CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
							EnemyCharacter:RemoveTag("CantRotate")
							iFramesService:RemoveAlliFrames(EnemyCharacter)
							StunHandler:Unstun(EnemyCharacter, EnemyStun)
						end)
						
						
						PlayerTrack.Stopped:Once(function()
							if Weld then
								pcall(function()
									Weld:Stop()
								end)
								Weld = nil
							end
							
							HumRP.Anchored = false
							
							for _,v in UserEvents do
								v:Disconnect()
							end
							
							CollisionsModule:SetCollisionGroup(Character, "Players")
							Character:RemoveTag("CantRotate")
							StunHandler:Unstun(Character, Stun)
							iFramesService:RemoveAlliFrames(Character)
						end)
						
						
						AnimationService:stopAll(EnemyCharacter)
						AnimationService:playAnimation(EnemyCharacter, EnemyAnimation)
						
						AnimationService:stopAll(Character)
						AnimationService:playAnimation(Character, PlayerAnimation)
						
						Weld:Start(nil, EnemyPlayer, Player)
						
						
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "CPFinisher", { char = Character, hit = EnemyCharacter, id = PlayerAnimation.AnimationId } })
						
						SoundsModule:PlaySound(MoveSounds.Baldhero["Conencutive Punches"].Finisher.User, HumRP)
						SoundsModule:PlaySound(MoveSounds.Baldhero["Conencutive Punches"].Finisher.Victim, EnemyHumRP)
					end
					
					
					SoundsModule:PlaySound(MoveSounds.Baldhero["Conencutive Punches"]["Hit" .. tostring(math.random(1, 3))], HumRP)
					
					
					if EnemyPlayer then
						ReplicateEffects_Set:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 0.75, Last = .1 })
					end
					
					
					if
						EnemyCharacter:HasTag('Ragdolled') then
						Hit = true
						
						if Finisher then
							RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
						end
					else
						Hit = true

						task.delay(0.1,function()

							if not Hit then
								StunHandler:Stun(Character, nil, true, 5, 0)
							end
						end)
					end
				end
				
				task.delay(.033,function()
					Hitbox:Once()
					Hitbox:Destroy()

					if Hit then
						ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 0.75, Last = .1 })
					end
				end)
			end)
		end
		
		
		UserEvents["start"] = UserTrack:GetMarkerReachedSignal("start"):Once(function()
			ReplicateEffects_Set:FireAllClients("consecutivePunches", { Char = Character, Bind = Bind })
			ReplicateEffects_Set:FireAllClients("consecutivePunches", { Char = Character, Bind = Bind })
			
			SoundsModule:PlaySound(MoveSounds.Baldhero["Conencutive Punches"].Startup, HumRP)
		end)
		
		UserEvents["end"] = UserTrack:GetMarkerReachedSignal("end"):Once(function()
			if Bind then
				Bind:Destroy()
				Bind = nil
			end
		end)
		
		
		UserTrack.Stopped:Once(function()
			if Bind then
				Bind:Destroy()
				Bind = nil
			end
			
			if Finisher then return end
			
			for _,v in UserEvents do
				v:Disconnect()
			end
			
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
		
		StatesHandler.SkillText(Player, "CONSECUTIVE PUNCHES [USED]")
	end
}