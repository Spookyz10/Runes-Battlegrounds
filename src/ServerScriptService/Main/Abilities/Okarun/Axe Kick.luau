local ServerStorage = game:GetService('ServerStorage') 


local StunHandler = require(game.ServerStorage.Modules.StunHandler)
local HitboxHandler = require(game.ServerStorage.Modules.HitboxHandler)
local DamageHandler = require(game.ServerStorage.Modules.DamageHandler)
local RagdollHandler = require(game.ServerStorage.Modules.RagdollHandler)
local NewKnockback = require(game.ServerStorage.Modules.BodymoverService)
local AnimationService = require(game.ServerStorage.Modules.AnimationService)
local iFramesService = require(game.ServerStorage.Modules.iFramesService)
local WeaponsHandler = require(game.ServerStorage.Modules.WeaponsHandler)
local CollisionsModule = require(game.ServerStorage.Modules.CollisionsModule)
local SoundsModule = require(game.ServerStorage.Modules.SoundsModule)
local KnockbackModule = require(game.ServerStorage.Modules.KnockbackModule)



local Utility = shared.Utility
local WeldSystem = require(game.ReplicatedStorage.Modules.WeldSystem)


local Sounds = shared.SoundsFolder
local Animations = shared.AnimsFolder

local MoveAnims = game.ServerStorage.Assets.Animations.Moves
local MoveSounds = game.ServerStorage.Assets.Sounds.Moves


local PlrSet = shared.PlrSet
local PlrGet = shared.PlrGet


local ReplicateEffects_Set = game.ReplicatedStorage.Remotes.Replicate.Set


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
		local Finisher = false
		local Weld, EnemyStun
		
		
		local VictimAnim = MoveAnims.Okarun.axekick.Victim
		
		local UserAnim = MoveAnims.Okarun.axekick.User
		local UserTrack = AnimationService:getAnimationTrack(Character, UserAnim)
		local UserEvents = {}
		
		
		
		
		UserEvents["Hit"] = UserTrack:GetMarkerReachedSignal("Hit"):Once(function()
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP.CFrame
			Hitbox.Size = Vector3.new(7, 7, 7)
			Hitbox.Offset = CFrame.new(0, 0, -3.5)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				
				if Hit ~= nil or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 then return end
				
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, nil, nil, false, true, true, true, false, nil, 13)
				if HitInfo.Countered == true then return end
				
				local lookVector = HumRP.CFrame.LookVector
				if HitInfo.Finisher == true then
					if Finisher == true then return end
					Finisher  = true
					
					local FinisherWeld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -4) * CFrame.Angles(0, rad(180), 0), 2)
					
					if EnemyCharacter:HasTag('Ragdolled') then
						RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
					end
					
					local FinisherVictimAnim = MoveAnims.Okarun.axekick["Axe Kick Finisher Victim"]
					local FinisherVictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, FinisherVictimAnim)
					
					local FinisherUserAnim = MoveAnims.Okarun.axekick["Axe Kick Finisher User"]
					local FinisherUserTrack = AnimationService:getAnimationTrack(Character, FinisherUserAnim)
					local FinisherUserEvents = {}
					
					
					local FinisherEnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
					iFramesService:AddAlliFrames(Character)
					iFramesService:AddAlliFrames(EnemyCharacter)
					
					EnemyCharacter:AddTag("CantRotate")
					Character:AddTag("CantRotate")
					
					
					FinisherUserEvents["Slide"] = FinisherUserTrack:GetMarkerReachedSignal("Slide"):Once(function()
						if FinisherWeld then
							pcall(function()
								FinisherWeld:Stop()
							end)
							FinisherWeld = nil
						end
						
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						EnemyCharacter:RemoveTag("CantRotate")
						StunHandler:Unstun(EnemyCharacter, FinisherEnemyStun)
						
						DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, true, true, true, nil)
						RagdollHandler.ragdoll(EnemyHumanoid, 3, true, Character)
						NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(100000, 100000, 100000), Velocity = lookVector * 500 + Vector3.new(0, 50, 0) })
						
						shared.fireTo(ReplicateEffects_Set, { Player, game.Players:GetPlayerFromCharacter(EnemyCharacter) }, { "ShakeCamera", { Intensity = 18 } })
					end)
					
					
					FinisherUserTrack.Stopped:Once(function()
						if FinisherWeld then
							pcall(function()
								FinisherWeld:Stop()
							end)
							FinisherWeld = nil
						end
						
						for _,v in FinisherUserEvents do
							v:Disconnect()
						end
						
						iFramesService:RemoveAlliFrames(Character)
						Character:RemoveTag("CantRotate")

						StunHandler:Unstun(Character, Stun)
					end)
					FinisherVictimTrack.Stopped:Once(function()
						if FinisherWeld then
							pcall(function()
								FinisherWeld:Stop()
							end)
							FinisherWeld = nil
						end
						
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						EnemyCharacter:RemoveTag("CantRotate")
						
						StunHandler:Unstun(EnemyCharacter, FinisherEnemyStun)
					end)
					
					
					AnimationService:stopAll(EnemyCharacter, 0)
					AnimationService:stopAll(Character, 0)
					AnimationService:playAnimation(Character, FinisherUserAnim)
					AnimationService:playAnimation(EnemyCharacter, FinisherVictimAnim)
					
					
					SoundsModule:PlaySound(MoveSounds.Okarun.axekick.Finisher, HumRP)
					ReplicateEffects_Set:FireAllClients("OkarunFinishers", { Finisher = "Axe Kick", Char = Character, EChar = EnemyCharacter })
					FinisherWeld:Start(nil, game.Players:GetPlayerFromCharacter(EnemyCharacter) or Player)	
				end
				
				if Finisher == true then return end
				
				
				
				Hit = EnemyCharacter
				
				local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnim)
				VictimTrack.Stopped:Once(function()
					iFramesService:RemoveAlliFrames(EnemyCharacter)
					
					if not EnemyCharacter:HasTag("Ragdolled") then
						EnemyCharacter:RemoveTag("CantRotate")
					end
				end)
				
				
				iFramesService:AddBaseiFrames(Character)
				iFramesService:AddBaseiFrames(EnemyCharacter)

				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
				end

				EnemyCharacter:AddTag("CantRotate")
				EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				
				AnimationService:stopAll(EnemyCharacter, 0)
				AnimationService:playAnimation(EnemyCharacter, VictimAnim)
				
				SoundsModule:PlaySound(MoveSounds.Okarun.axekick.Hit1, EnemyHumRP)

				Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, rad(180), 0), 2)
				Weld:Start(nil, game.Players:GetPlayerFromCharacter(EnemyCharacter) or Player)	
			end
			
			Hitbox:Once()
			Hitbox:Destroy()
			
			
			ReplicateEffects_Set:FireAllClients("turboaxe", { Stage = "KickStartUp", Char = Character })
		end)
		
		UserEvents["Hit2"] = UserTrack:GetMarkerReachedSignal("Hit2"):Once(function()
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP.CFrame
			Hitbox.Size = Vector3.new(7, 7, 7)
			Hitbox.Offset = CFrame.new(0, 0, -3.5)
			Hitbox.Ignore = { Character, Hit }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 then return end

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, 1, nil, false, true, false, true, true, nil, nil)
				if HitInfo.Countered == true then return end
				
				RagdollHandler.ragdoll(EnemyHumanoid, 2)
				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 1, 1) * 100000, Velocity = Vector3.new(0, 75, 0) })
			end

			Hitbox:Once()
			Hitbox:Destroy()
			
			
			if not Hit then
				ReplicateEffects_Set:FireAllClients("turboaxe", { Stage = "LegSlam", Char = Character })
				
				return
					
			else
				ReplicateEffects_Set:FireAllClients("turboaxe", { Stage = "GroundSmoke", Char = Character })
				SoundsModule:PlaySound(MoveSounds.Okarun.axekick.Hit2, HumRP)
				
			end
			
			Character:AddTag("CantRotate")
			
			AnimationService:stopAll(Character)
			AnimationService:stopAll(Hit)
			
			
			local Ended = false
			
			local EnemyCharacter: Model = Hit
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			
			
			local EndAnimation = MoveAnims.Okarun.axekick.UserEnd
			local EndTrack = AnimationService:getAnimationTrack(Character, EndAnimation)
			local EndEvents = {}
			
			EndEvents["1"] = EndTrack:GetMarkerReachedSignal("1"):Once(function()
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, nil, nil, false, false, true, true, false, nil, nil)
			end)
			
			EndEvents["2"] = EndTrack:GetMarkerReachedSignal("2"):Once(function()
				ReplicateEffects_Set:FireAllClients("turboaxe", { Stage = "Uppercut", Char = Character })
				
				Ended = true
				
				
				if Weld then
					pcall(function()
						Weld:Stop()
					end)
					Weld = nil
				end

				iFramesService:RemoveAlliFrames(EnemyCharacter)
				StunHandler:Unstun(EnemyCharacter, EnemyStun)
				EnemyCharacter:RemoveTag("CantRotate")
				
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 6, nil, nil, false, false, true, true, true, nil, nil)
				RagdollHandler.ragdoll(EnemyHumanoid, 2)
				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(75000, 75000, 75000), Velocity = HumRP.CFrame.LookVector * 50 + Vector3.new(0, 50, 0) })
			end)
			
			EndTrack.Stopped:Once(function()
				for _,v in EndEvents do
					v:Disconnect()
				end
				
				if not Ended then
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end
					
					if EnemyCharacter and EnemyCharacter.Parent then
						if EnemyStun then
							StunHandler:Unstun(EnemyCharacter, EnemyStun)
							EnemyStun = nil
						end
						
						iFramesService:RemoveAlliFrames(EnemyCharacter)
					end
				end
				

				Character:RemoveTag("CantRotate")
				iFramesService:RemoveAlliFrames(Character)
				StunHandler:Unstun(Character, Stun)
			end)
			
			
			AnimationService:playAnimation(Character, EndAnimation)
			AnimationService:playAnimation(EnemyCharacter, MoveAnims.Okarun.axekick.VictimEnd)
			
			SoundsModule:PlaySound(MoveSounds.Okarun.axekick.End, HumRP)
		end)
		
		UserTrack.Stopped:Once(function()
			for _,v in UserEvents do
				v:Disconnect()
			end
			
			if Hit == nil then
				if Finisher == true then return end
				
				StunHandler:Unstun(Character, Stun)
			end
		end)
		
		
		AnimationService:stopAll(Character, 0)
		AnimationService:playAnimation(Character, UserAnim)
		
		SoundsModule:PlaySound(MoveSounds.Okarun.axekick.Windup, HumRP)
	end
}