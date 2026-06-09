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
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		
		
		local StartAnimation = MoveAnims["Cursed Child"]["Bloody Mary"].Windup
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}
		
		
		local Hit = false
		
		
		StartEvents["kick"] = StartTrack:GetMarkerReachedSignal("kick"):Once(function()
			ReplicateEffects_Set:FireAllClients("BloodyMary", { Stage = "Dropkick", Char = Character })
			
			local Hitbox = ReplicatedHitbox.new(Player)
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(7, 7, 10)
			Hitbox.Offset = CFrame.new(0, 0, -3.5)
			Hitbox.Ignore = { Character }
			Hitbox.destroyAfterOnce = true
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, nil, nil, true, false, true, true, true, nil)
				
				if HitInfo.Blocked == true then 
					
					return 
				end
				
				RagdollHandler.ragdoll(EnemyHumanoid, 2.25)
				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(10000, 10000, 10000), Velocity = HumRP.CFrame.LookVector * Vector3.new(25, 0, 25) + Vector3.new(0, 25, 0) })
			end
			
			Hitbox:Once()
		end)
		
		StartEvents["hit"] = StartTrack:GetMarkerReachedSignal("hit"):Once(function()
			local HitboxConnection = ReplicatedHitbox.new(Player)
			HitboxConnection.Instance = HumRP
			HitboxConnection.Size = Vector3.new(8, 8, 13)
			HitboxConnection.Offset = CFrame.new(0, 0, -4.5)
			HitboxConnection.Ignore = { Character }
			HitboxConnection.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid


				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead  then return end
				
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 6, nil, nil, false, false, true, true, false, nil)
				Hit = true
				
				if EnemyCharacter:HasTag('Ragdolled') then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
				end
				
				
				pcall(function()
					HitboxConnection:Destroy()
				end)
				
				
				local VictimAnimation = MoveAnims["Cursed Child"]["Bloody Mary"].Victim
				local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
				
				local UserAnimation = MoveAnims["Cursed Child"]["Bloody Mary"].Hit
				local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
				local UserEvents = {}
				
				
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, 1), 10)
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				
				
				HumRP.Anchored = true
				
				
				Character:AddTag('CantRotate')
				EnemyCharacter:AddTag('CantRotate')

				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)


				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
				
				
				local HitStage = 1
				
				UserEvents["knee"] = UserTrack:GetMarkerReachedSignal("knee"):Connect(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false, nil)
				end)
				
				UserEvents["kick"] = UserTrack:GetMarkerReachedSignal("kick"):Once(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false, nil)
				end)
				
				UserEvents["slash"] = UserTrack:GetMarkerReachedSignal("slash"):Once(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false, nil)
				end)
				
				UserEvents["stab"] = UserTrack:GetMarkerReachedSignal("stab"):Once(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false, nil)
				end)
				
				UserEvents["finalhit"] = UserTrack:GetMarkerReachedSignal("finalhit"):Connect(function()
					if HitStage == 1 then
						HitStage = 2
						
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 2.5, nil, nil, false, false, true, true, false, nil)
					else
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
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 2.5, nil, nil, false, false, true, true, true, nil)
						NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(1, 1, 1) * math.huge, Velocity = (-HumRP.CFrame.LookVector * 60) + Vector3.new(0, 60, 0) })
					end
				end)
				
				
				VictimTrack.Stopped:Once(function()
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

				UserTrack.Stopped:Once(function()
					for _,v in UserEvents do
						v:Disconnect()
					end
					
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end
					
					HumRP.Anchored = false
					
					StunHandler:Unstun(Character, Stun)
					Character:RemoveTag('CantRotate')
					iFramesService:RemoveAlliFrames(Character)
					CollisionsModule:SetCollisionGroup(Character, "Players")
				end)
				
				
				AnimationService:stopAll(EnemyCharacter)
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
				
				AnimationService:stopAll(Character)
				AnimationService:playAnimation(Character, UserAnimation)
				
				Weld:Start(nil, EnemyPlayer, Player)
				
				ReplicateEffects_Set:FireAllClients("BloodyMary", { Stage = "Hit", Char = Character, EChar = EnemyCharacter, HitAnim = UserAnimation.AnimationId, VictimAnim = VictimAnimation.AnimationId })
			end
			
			HitboxConnection:Start(0.2, true)
		end)
		
		
		StartTrack.Stopped:Once(function()
			for _,v in StartEvents do
				v:Disconnect()
			end

			if not Hit then
				StunHandler:Unstun(Character, Stun)
			end
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
		
		ReplicateEffects_Set:FireAllClients("BloodyMary", { Stage = "Start", Char = Character, StartAnim = StartAnimation.AnimationId })
	end
}