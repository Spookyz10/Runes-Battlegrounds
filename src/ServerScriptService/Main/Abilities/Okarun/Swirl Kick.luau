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


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		local Hit = false
		
		
		local MissAnim = MoveAnims.Okarun.skick.Miss
		local MissTrack = AnimationService:getAnimationTrack(Character, MissAnim)
		local MissEvents = {}
		
		MissEvents["Teleport"] = MissTrack:GetMarkerReachedSignal("Teleport"):Once(function()
			local HumRPCF = HumRP.CFrame
			
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRPCF
			Hitbox.Size = Vector3.new(7, 7, 30)
			Hitbox.Offset = CFrame.new(0, 0, -15)
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				
				if Hit == true or EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 then return end
				
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, nil, nil, true, true, false, true, false, nil, nil)
				if HitInfo.Blocked == true or HitInfo.Countered == true then return end
				
				Hit = true
				
				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
				end
				
				iFramesService:AddAlliFrames(Character)
				
				AnimationService:stopAll(EnemyCharacter, 0)
				iFramesService:AddAlliFrames(EnemyCharacter)
				
				Character:AddTag("CantRotate")
				EnemyCharacter:AddTag("CantRotate")
				
				
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, rad(180), 0), 2)
				local enemyGoalCF = CFrame.lookAt(EnemyHumRP.Position, HumRP.Position)
				
				EnemyHumRP.CFrame = enemyGoalCF
				HumRP.CFrame = enemyGoalCF * CFrame.new(0, 0, -3) * CFrame.Angles(0, rad(180), 0)
				
				local HitAnim = MoveAnims.Okarun.skick.Hit
				local HitTrack = AnimationService:getAnimationTrack(Character, HitAnim)
				local HitEvents = {}
				
				HitEvents["Hit"] = HitTrack:GetMarkerReachedSignal("Hit"):Once(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, false, nil, nil)
					SoundsModule:PlaySound(MoveSounds.Okarun.skick.Hit1, EnemyHumRP)	
				end)
				
				HitEvents["End"] = HitTrack:GetMarkerReachedSignal("End"):Once(function()
					Character:RemoveTag("CantRotate")
					
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end
					
					iFramesService:RemoveAlliFrames(EnemyCharacter)
					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					EnemyCharacter:RemoveTag("CantRotate")
					
					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 6, nil, nil, false, false, true, true, true, nil, nil)
					SoundsModule:PlaySound(MoveSounds.Okarun.skick.Hit2, EnemyHumRP)


					local Knockback, upKnockback, hardRagdoll, Ragdoller = 75, 75, false, nil
					
					if HitInfo.Finisher == true then
						Knockback *= 1.5
						upKnockback *= 2.5
						hardRagdoll = true
						Ragdoller = Character
					end
					
					RagdollHandler.ragdoll(EnemyHumanoid, 3, hardRagdoll, Ragdoller)
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 1, 1) * math.huge, Velocity = HumRP.CFrame.LookVector * Vector3.new(Knockback, 0, Knockback) + Vector3.new(0, upKnockback, 0) })
				end)
				
				HitTrack.Stopped:Once(function()
					for _,v in HitEvents do
						v:Disconnect()
					end
					
					StunHandler:Unstun(Character, Stun)
					iFramesService:RemoveAlliFrames(Character)
				end)
				
				
				AnimationService:stopAll(Character, 0)
				AnimationService:playAnimation(Character, HitAnim)
				AnimationService:playAnimation(EnemyCharacter, MoveAnims.Okarun.skick.Victim)
				
				Weld:Start(nil, game.Players:GetPlayerFromCharacter(EnemyCharacter) or Player)
				
				ReplicateEffects_Set:FireAllClients("turboskick", { Stage = "Hit", Char = Character })
				
				SoundsModule:PlaySound(MoveSounds.Okarun.skick.Grab, HumRP)
			end
			
			Hitbox:Once()
			Hitbox:Destroy()
			
			ReplicateEffects_Set:FireAllClients("turboskick", { Stage = "Start", Char = Character, CF = HumRPCF, Hit = Hit })
		end)
		
		MissTrack.Stopped:Once(function()
			for _,v in MissEvents do
				v:Disconnect()
			end
			
			if Hit == false then
				StunHandler:Unstun(Character, Stun)
			end
		end)
		
		
		AnimationService:stopAll(Character, 0)
		AnimationService:playAnimation(Character, MissAnim)
		
		SoundsModule:PlaySound(MoveSounds.Okarun.skick.Windup, HumRP)
	end
}