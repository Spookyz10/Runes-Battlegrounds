local ServerStorage = game:GetService('ServerStorage') 
local Players = game:GetService("Players")


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
local StatesHandler = require(game.ServerStorage.Modules.StatesHandler)

local WeldSystem = shared.WeldSystem


local MoveAnims = game.ServerStorage.Assets.Animations.Moves
local MoveSounds = shared.MoveSounds


local ReplicateEffects_Set = game.ReplicatedStorage.Remotes.Replicate.Set


local rad = math.rad
local StartAirDetect = ServerStorage.Bindables.AirDetector


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local HumRP: BasePart = Character.HumanoidRootPart
		local Humanoid: Humanoid = Character.Humanoid


		local Hit = false
		local EnemyCharacter: Model
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)


		local WindupAnimation: AnimationTrack = AnimationService:getAnimationTrack(Character, MoveAnims.KJ.Ravage.Windup)
		local WindupEvents = {}

		WindupEvents['Start'] = WindupAnimation:GetMarkerReachedSignal('Start'):Once(function()
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP
			Hitbox.Ignore = { Character }
			Hitbox.Size = Vector3.new(1, 1, 1) * 7
			Hitbox.Offset = CFrame.new(0, 0, -3.5)
			Hitbox.onTouch = function(EnemyCharacter)
				if Hit == true or EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter.Humanoid.Health <= 0 then return end

				local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 3.5, nil, nil, false, true, true, true, false, nil, 35)
				if HitInfo.Countered == true or Hit == true then return end

				Hit = true

				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)

				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)

				Character:AddTag('CantRotate')
				EnemyCharacter:AddTag('CantRotate')


				local humrpCF = HumRP.CFrame

				if EnemyCharacter:HasTag('Ragdolled') then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
				end

				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)



				-- Animations --

				local UserAnimation, VictimAnimation = MoveAnims.KJ.Ravage.User, MoveAnims.KJ.Ravage.Victim
				local UserTrack, VictimTrack = AnimationService:getAnimationTrack(Character, UserAnimation), AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
				local UserEvents = {}

				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -2.75) * CFrame.Angles(0, rad(-180), 0), -1)


				UserEvents['Damage1'] = UserTrack:GetMarkerReachedSignal('Damage1'):Once(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, true, false, true, true, false, nil, nil)
					ReplicateEffects_Set:FireAllClients("Ravage", { Stage = "1and2", Char = Character, EChar = EnemyCharacter, Count = 1 })
				end)

				UserEvents['Damage2'] = UserTrack:GetMarkerReachedSignal('Damage2'):Once(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, true, false, true, true, false, nil, nil)
					ReplicateEffects_Set:FireAllClients("Ravage", { Stage = "1and2", Char = Character, EChar = EnemyCharacter, Count = 2 })
				end)

				UserEvents["BarrageVFX"] = UserTrack:GetMarkerReachedSignal("BarrageVFX"):Once(function()
					ReplicateEffects_Set:FireAllClients("Ravage", { Stage = "Barrage", Char = Character, EChar = EnemyCharacter })
				end)

				UserEvents['Damage'] = UserTrack:GetMarkerReachedSignal('Damage'):Connect(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, true, false, true, true, false, nil, nil)
				end)

				UserEvents['Damage3'] = UserTrack:GetMarkerReachedSignal('Damage3'):Once(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, true, false, true, true, false, nil, nil)

					ReplicateEffects_Set:FireAllClients("Ravage", { Stage = "Uppercut", Char = Character, EChar = EnemyCharacter })
				end)

				UserEvents["Spin"] = UserTrack:GetMarkerReachedSignal("Spin"):Once(function()
					ReplicateEffects_Set:FireAllClients("Ravage", { Stage = "Spin", Char = Character, EChar = EnemyCharacter })
				end)

				UserEvents["LegAura"] = UserTrack:GetMarkerReachedSignal("LegAura"):Once(function()
					ReplicateEffects_Set:FireAllClients("Ravage", { Stage = "LegAura", Char = Character, EChar = EnemyCharacter })
				end)

				UserEvents['Damage4'] = UserTrack:GetMarkerReachedSignal('Damage4'):Once(function()
					task.wait(0.233)

					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end

					if HitInfo.Finisher == true then
						DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, true, false, true, true, true, nil)

						RagdollHandler.ragdoll(EnemyHumanoid, 2, true, Character, nil, true)
						NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 1, 1) * math.huge, Velocity = HumRP.CFrame.LookVector * Vector3.new(200, 0 ,200) + Vector3.new(0, 120, 0), Time = 0.3 })
					else
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 7, nil, nil, true, false, true, true, true, nil)

						RagdollHandler.ragdoll(EnemyHumanoid, 2)
						NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 1, 1) * math.huge, Velocity = HumRP.CFrame.LookVector * Vector3.new(80, 0 ,80) + Vector3.new(0, 60, 0), Time = 0.3 })
					end

					ReplicateEffects_Set:FireAllClients('Ravage', { Stage = 'FinalKick', EChar = EnemyCharacter, Char = Character })
					SoundsModule:PlaySound(MoveSounds.KJ.Ravage.FinalHit, EnemyHumRP)
				end)


				SoundsModule:PlaySound(MoveSounds.KJ.Ravage.Hit, EnemyCharacter.Torso)
				SoundsModule:PlaySound(MoveSounds.KJ.Ravage.Barrage, EnemyCharacter.Torso)
				SoundsModule:PlaySound(MoveSounds.KJ.Ravage.Wind, Character.Torso)


				VictimTrack.Stopped:Once(function()
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end

					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					EnemyHumanoid.AutoRotate = true

					EnemyCharacter:RemoveTag('CantRotate')

					iFramesService:RemoveAlliFrames(EnemyCharacter)
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

					StunHandler:Unstun(Character, Stun)
					iFramesService:RemoveAlliFrames(Character)

					Character:RemoveTag('CantRotate')
				end)


				AnimationService:playAnimation(Character, UserAnimation)
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)

				ReplicateEffects_Set:FireAllClients('Ravage', { Stage = 'Hit', EChar = EnemyCharacter, Char = Character })

				Weld:Start(nil, game.Players:GetPlayerFromCharacter(EnemyCharacter) or Player)
				
				StatesHandler.SkillText(Player, "RAVAGE [HIT]")
			end

			Hitbox:Once()
			Hitbox:Destroy()
		end)

		WindupAnimation.Stopped:Once(function()
			for _,v in WindupEvents do
				v:Disconnect()
			end

			if Hit == true then return end

			StunHandler:Unstun(Character, Stun)
			Character:RemoveTag('CantRotate')
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, MoveAnims.KJ.Ravage.Windup)


		SoundsModule:PlaySound(MoveSounds.KJ.Ravage.Startup, Character.Torso)
		
		StatesHandler.SkillText(Player, "RAVAGE [USED]")
	end
}