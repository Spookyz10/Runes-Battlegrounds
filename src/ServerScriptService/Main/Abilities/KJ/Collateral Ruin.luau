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
local StatesHandler = require(game.ServerStorage.Modules.StatesHandler)

local Utility = shared.Utility
local WeldSystem = shared.WeldSystem


local Sounds = game.ServerStorage.Assets.Sounds
local Animations = game.ServerStorage.Assets.Animations

local MoveAnims = Animations.Moves
local MoveSounds = Sounds.Moves


local ReplicateEffects_Set: RemoteEvent = shared.repfire


local rad = math.rad
local StartAirDetect = ServerStorage.Bindables.AirDetector


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local HumRP: BasePart = Character.HumanoidRootPart
		local Humanoid: Humanoid = Character.Humanoid


		local Stun = StunHandler:Stun(Character, nil, true)
		local SFX = SoundsModule:PlaySound(MoveSounds.KJ["Collateral Ruin"].Windup, HumRP)
		
		local TimeScale = Instance.new("NumberValue")
		TimeScale.Name = "Value"
		TimeScale.Parent = Character
		TimeScale.Value = 1
		
		
		local Animation = MoveAnims.KJ["Collateral Ruin"].Player
		local AnimationTrack = AnimationService:getAnimationTrack(Character, Animation)
		local AnimationEvents = {}
		
		local Hit = false
		local Stage = 1
		local FreezeTime = 0
		local Hits = {}
		
		local Hitbox = HitboxHandler.new()
		Hitbox.Instance = HumRP
		Hitbox.Size = Vector3.new(1,1,1) * 25
		Hitbox.onTouch = function(EnemyCharacter)
			if EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter.Humanoid.Health <= 0 then return end

			local EnemyPlayer = game.Players:GetPlayerFromCharacter(EnemyCharacter)
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

			local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 6, nil, nil, false, false, true, true, Stage == 2)

			Hit = true

			if Stage == 1 then
				SoundsModule:PlaySound(MoveSounds.KJ["Collateral Ruin"].Hit, EnemyHumRP, 1, 1)
				SoundsModule:PlaySound(MoveSounds.KJ["Collateral Ruin"].Hit2, EnemyHumRP, 1, 1)

				if #Hits == 0 then
					FreezeTime = tick()
					
					SFX:Pause()
					AnimationTrack:AdjustSpeed(0)
				end

				AnimationEvents["StartHitbox"] = AnimationTrack:GetMarkerReachedSignal("StartHitbox"):Once(function()
					ReplicateEffects_Set:FireAllClients('KJImpact',{ Char = Character,	tim = 0.075, hit = EnemyCharacter })
					ReplicateEffects_Set:FireClient(Player,'Camshake',{ Last = 2, Intensity = 4, })
					
					if Hit == true then
						ReplicateEffects_Set:FireClient(Player,'Camshake',{ Intensity = 2, })
						if EnemyPlayer then
							ReplicateEffects_Set:FireClient(EnemyPlayer,'Camshake',{ Intensity = 2, })
						end
					end
				end)
				
				ReplicateEffects_Set:FireClient(Player,'Camshake',{ Intensity = 8, })
				if EnemyPlayer then
					ReplicateEffects_Set:FireClient(EnemyPlayer,'Camshake',{ Intensity = 8, })
				end
				
				ReplicateEffects_Set:FireAllClients('FirstImpact',{ Char = Character, tim = 0.36, hit = EnemyCharacter })
				ReplicateEffects_Set:FireClient(Player, 'ShakeCamera', { Preset = 'SmallImpact' })
				
				AnimationService:playAnimation(EnemyCharacter, MoveAnims.KJ["Collateral Ruin"]["Victim"..tostring(math.random(1, 3))])
				SoundsModule:PlaySound(MoveSounds.KJ["Collateral Ruin"]["Hit" .. tostring(math.random(1, 3))], HumRP)
				
				TimeScale.Value = 0
				StunHandler:Stun(EnemyCharacter, 1, true, 0, 0, true)
				
				table.insert(Hits, EnemyCharacter)
			else
				local LookVector = -CFrame.lookAt(EnemyHumRP.Position, HumRP.Position).LookVector

				NewKnockback:makeEnemyFaceCharacter(EnemyCharacter, Character)
				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(1, 1, 1) * math.huge, Velocity = Vector3.new(LookVector.X * 50, 75, LookVector.Z * 50) })
				RagdollHandler.ragdoll(EnemyHumanoid, 2)
				StartAirDetect:Fire(EnemyCharacter)
			end
		end

		AnimationEvents["SpeedLinesStart"] = AnimationTrack:GetMarkerReachedSignal("SpeedLinesStart"):Once(function()
			iFramesService:AddAlliFrames(Character)
		end)
		
		AnimationEvents["StartHitbox"] = AnimationTrack:GetMarkerReachedSignal("StartHitbox"):Once(function()
			Hitbox:Start()

			task.delay(0.383, function()
				if Hit == true then
					SFX:Resume()
				end

				AnimationTrack:AdjustSpeed(1 * workspace.Configuration.AttackSMult.Value)
				TimeScale.Value = 1
			end)
		end)
		
		AnimationEvents["EndHitbox"] = AnimationTrack:GetMarkerReachedSignal("EndHitbox"):Once(function()
			Hitbox:Stop()
			
			Stage = 2
			Hitbox.Size = Vector3.new(1,1,1) * 50
			Hitbox:Once()
			Hitbox:Destroy()

			ReplicateEffects_Set:FireAllClients('CollateralRuinVFX',{ char = Character, explode = true,	seed = 1703323916, timeScale = TimeScale })
			ReplicateEffects_Set:FireClient(Player,'Camshake',{ Intensity = 9, })
			SoundsModule:PlaySound(MoveSounds.KJ["Collateral Ruin"].End, HumRP)

			iFramesService:RemoveAlliFrames(Character)
		end)

		AnimationTrack.Stopped:Once(function()
			for _,v in AnimationEvents do
				v:Disconnect()
			end
			
			TimeScale:Destroy()
			
			StunHandler:Unstun(Character, Stun)

			Humanoid.AutoRotate = true
			Character:RemoveTag('CantRotate')
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, Animations.Moves.KJ["Collateral Ruin"].Player)

		ReplicateEffects_Set:FireAllClients('CollateralRuinVFX',{ char = Character, seed = 1703323916, anim = Animation.AnimationId, timeScale = TimeScale })
		
		Character:AddTag('CantRotate')
		
		StatesHandler.SkillText(Player, "COLLATERAL RUIN [USED]")
	end
}