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
local WeldSystem = require(game.ReplicatedStorage.Modules.WeldSystem)


local Sounds = shared.SoundsFolder
local Animations = shared.AnimsFolder

local MoveAnims = game.ServerStorage.Assets.Animations.Moves
local MoveSounds = game.ServerStorage.Assets.Sounds.Moves
local CombatSounds = ServerStorage.Assets.Sounds.Combat


local ReplicateEffects_Set = game.ReplicatedStorage.Remotes.Replicate.Set


local rad = math.rad
local StartAirDetect = ServerStorage.Bindables.AirDetector


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local HumRP: BasePart = Character.HumanoidRootPart
		local Humanoid: Humanoid = Character.Humanoid
		local Animator: Animator = Humanoid.Animator

		StunHandler:Stun(Character, 0.350, true)

		local Hit = false


		local AnimTrack = Animator:LoadAnimation(MoveAnims.KJ["Swift Sweep"].Startup)
		local AnimEvents = {}

		AnimEvents["sweep"] = AnimTrack:GetMarkerReachedSignal("sweep"):Once(function()
			ReplicateEffects_Set:FireAllClients('Swift Sweep1',{ Character = Character })

			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(1,1,1) * 7
			Hitbox.Offset = CFrame.new(0,0,-Hitbox.Size.Z/2)
			Hitbox.onTouch = function(EnemyCharacter)
				if EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter.Humanoid.Health <= 0 then return end

				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart


				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 7, 1, MoveAnims.KJ["Swift Sweep"].Victim, true, true)

				if HitInfo.Countered == true then return end

				if EnemyCharacter:HasTag('Ragdolled') then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
				end

				if HitInfo.Blocked == true then
					SoundsModule:PlaySound(CombatSounds.Blocking.Hits:GetChildren()[math.random(1, #CombatSounds.Blocking.Hits:GetChildren())], EnemyHumRP)
				else
					Hit = true

					SoundsModule:PlaySound(MoveSounds.KJ["Swift Sweep"].Hit1, EnemyHumRP, 1, 1)

					task.wait(.033)
					ReplicateEffects_Set:FireAllClients('Swift Sweep1',{ Character = Character, Hit = EnemyCharacter })
				end
			end

			task.wait(.033)

			Hitbox:Once()
			Hitbox:Destroy()

			if Hit then
				ReplicateEffects_Set:FireClient(Player, 'ShakeCamera', { Magnitude = 2, Roughness = 10, FadeInTime = 0, FadeOutTime = .25 })
			end
		end)

		AnimTrack.Stopped:Once(function()
			for _,v in AnimEvents do
				v:Disconnect()
			end


			if not Hit then
				StunHandler:Stun(Character, 0.317, true)

			else

				local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
				local Hit2 = false

				local HitAnimTrack = Animator:LoadAnimation(MoveAnims.KJ["Swift Sweep"].Hit)
				local HitEvents = {}

				HitEvents["kick"] = HitAnimTrack:GetMarkerReachedSignal("kick"):Once(function()
					local Hitbox = HitboxHandler.new()
					Hitbox.Instance = HumRP
					Hitbox.Size = Vector3.new(7, 7, 7)
					Hitbox.Offset = CFrame.new(0,0,-Hitbox.Size.Z/2)
					Hitbox.Ignore = { Character }
					Hitbox.onTouch = function(EnemyCharacter)
						local EnemyPlayer = game.Players:GetPlayerFromCharacter(EnemyCharacter)
						local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
						local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

						if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end


						if EnemyCharacter:HasTag('Ragdolled') then
							RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
						end

						local StunTime = 1


						local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 7, StunTime, Animations.Combat.Hits['1'], false, true, false, true, false, nil, 14)
						if HitInfo.Countered == true then return end

						Hit2 = true

						SoundsModule:PlaySound(MoveSounds.KJ["Swift Sweep"].Hit2, EnemyHumRP, 1, 1)

						if EnemyCharacter:HasTag('Ragdolled') then
							RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, false, true)
						end


						EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

						local selfToOtherChar = (EnemyHumRP.Position - HumRP.Position).Unit
						local lookVector = Character.HumanoidRootPart.CFrame.LookVector

						local dotProduct = lookVector:Dot(selfToOtherChar)
						if EnemyHumanoid.FloorMaterial ~= Enum.Material.Air then
							dotProduct = 1
						end

						local at = Character.HumanoidRootPart.Position
						local forward = Character.HumanoidRootPart.CFrame.LookVector
						local lookposition = CFrame.lookAt(at, at + Vector3.new(forward.X, 0, forward.Z))

						require(ServerStorage.Modules.PerfectKnockback).KnockBack(nil, EnemyCharacter, {
							LookVector = lookposition.LookVector,
							LookForce = 58.5,
							LookFinalForce = 55,
							LookAt = lookposition,
							DestroyRagdoll = true,
							GroundStunTime = 0.95,
							Escapable = false,
							FallingDetectDelay = 0.2,
							Dot = dotProduct,
							DotParams = {0.4, 1},
							canHitWall = true
						}, Character)
					end

					Hitbox:Once()
					Hitbox:Destroy()

					if Hit2 then
						ReplicateEffects_Set:FireClient(Player, 'ShakeCamera', { Magnitude = 2, Roughness = 20, FadeInTime = 0, FadeOutTime = .25 })
					end
				end)

				HitAnimTrack.Stopped:Once(function()
					for _,v in HitEvents do
						v:Disconnect()
					end

					StunHandler:Unstun(Character, Stun)
				end)


				HitAnimTrack:Play()
			end
		end)


		AnimTrack:Play()

		SoundsModule:PlaySound(MoveSounds.KJ["Swift Sweep"].Swing, HumRP, 1, 1)
		
		StatesHandler.SkillText(Player, "SWIFT SWEEP [USED]")
	end
}