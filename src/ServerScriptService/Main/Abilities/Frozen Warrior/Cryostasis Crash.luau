return {
	Start = function(Player: Player, Tool: Tool)
		local ServerStorage    = game:GetService("ServerStorage")
		local ReplicatedStorage = game:GetService("ReplicatedStorage")

		local ServerModules    = ServerStorage.Modules
		local RemotesContainer = ReplicatedStorage.Remotes

		local StunHandler      = require(ServerModules.StunHandler)
		local HitboxHandler    = require(ServerModules.HitboxHandler)
		local DamageHandler    = require(ServerModules.DamageHandler)
		local RagdollHandler   = require(ServerModules.RagdollHandler)
		local NewKnockback     = require(ServerModules.BodymoverService)
		local AnimationService = require(ServerModules.AnimationService)
		local iFramesService   = require(ServerModules.iFramesService)
		local CollisionsModule = require(ServerModules.CollisionsModule)

		local MoveAnims            = ServerStorage.Assets.Animations.Moves
		local ReplicateEffects_Set = RemotesContainer.Replicate.Set

		local Character : Model    = Player.Character
		local Humanoid  : Humanoid = Character.Humanoid
		local HumRP     : BasePart = Character.HumanoidRootPart

		local Anims = MoveAnims["Frozen Warrior"]["Cryostasis Crash"]

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		local StartupTrack = AnimationService:getAnimationTrack(Character, Anims.Startup)
		AnimationService:playAnimation(Character, Anims.Startup)

		ReplicateEffects_Set:FireAllClients("CryostasisCrash", {
			char  = Character,
			stage = "Startup",
			hrpCF = HumRP.CFrame,
		})

		local Hit = false

		local Hitbox = HitboxHandler.new()
		Hitbox.Instance = HumRP
		Hitbox.Size     = Vector3.new(6, 6, 8)
		Hitbox.Offset   = CFrame.new(0, 0, -4)
		Hitbox.Ignore   = { Character }
		Hitbox.onTouch  = function(EnemyCharacter)
			local EnemyHumanoid : Humanoid = EnemyCharacter.Humanoid
			local EnemyHumRP    : BasePart = EnemyCharacter.HumanoidRootPart

			if Hit or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
			Hit = true
			Hitbox:Destroy()

			HumRP.AssemblyLinearVelocity      = Vector3.zero
			EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

			ReplicateEffects_Set:FireClient(Player, "CryostasisCrash", {
				char  = Character,
				stage = "StopDash",
			})

			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
			iFramesService:AddAlliFrames(EnemyCharacter)
			CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

			-- [[ Face each other ]]:
			local casterLook = (EnemyHumRP.Position - HumRP.Position) * Vector3.new(1, 0, 1)
			HumRP.CFrame      = CFrame.new(HumRP.Position, HumRP.Position + casterLook)
			EnemyHumRP.CFrame = CFrame.new(HumRP.Position + HumRP.CFrame.LookVector * 3, HumRP.Position)

			AnimationService:stopAll(Character)
			AnimationService:stopAll(EnemyCharacter)

			local MainTrack = AnimationService:getAnimationTrack(Character, Anims.Main)
			AnimationService:playAnimation(Character, Anims.Main)
			AnimationService:playAnimation(EnemyCharacter, Anims.Victim)

			-- [[ Helper — always grabs latest positions ]]:
			local function fireStage(stageName)
				ReplicateEffects_Set:FireAllClients("CryostasisCrash", {
					char       = Character,
					enemy      = EnemyCharacter,
					stage      = stageName,
					hrpCF      = HumRP.CFrame,
					enemyHrpCF = EnemyHumRP.CFrame,
				})
			end

			-- [[ Phase timings — fixed early phases, then continuous loop until anim ends ]]:
			fireStage("Caught")

			task.delay(0.4, function() if Hit then fireStage("LiftOff")  end end)
			task.delay(0.8, function() if Hit then fireStage("Flying")   end end)
			task.delay(1.4, function() if Hit then fireStage("FlyLoop")  end end)
			task.delay(2.0, function() if Hit then fireStage("FlyLoop2") end end)
			task.delay(2.6, function() if Hit then fireStage("Hit1")     end end)
			task.delay(3.2, function() if Hit then fireStage("Hit1Loop") end end)
			task.delay(3.8, function() if Hit then fireStage("Hit2")     end end)
			task.delay(4.3, function() if Hit then fireStage("Hit2Loop") end end)

			-- [[ From 4.7s onward: cycle WindUp stages every 0.35s until anim ends ]]:
			-- [[ This covers any anim length — 6s, 10s, 15s, doesn't matter ]]:
			local AnimDone   = false
			local windStages = { "WindUp", "WindUp2", "WindUp3", "WindUp4", "WindUp5" }
			local windIdx    = 1

			task.delay(4.7, function()
				while Hit and not AnimDone do
					fireStage(windStages[windIdx])
					windIdx = (windIdx % #windStages) + 1
					task.wait(0.35)
				end
			end)

			MainTrack.Stopped:Once(function()
				AnimDone = true
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 45, nil, nil, false, false, true, true, true, nil, nil)
				RagdollHandler.ragdoll(EnemyHumanoid, 5)

				-- [[ Slam down hard + forward throw to match the spike eruption ]]:
				local throwDir = (EnemyHumRP.Position - HumRP.Position) * Vector3.new(1, 0, 1)
				if throwDir.Magnitude > 0 then throwDir = throwDir.Unit else throwDir = HumRP.CFrame.LookVector end

				NewKnockback:Knockback(EnemyCharacter, {
					KnockbackType = "Velocity",
					MaxForce      = Vector3.new(1, 1, 1) * math.huge,
					Velocity      = (throwDir * 40) + Vector3.new(0, 280, 0),
				})

				fireStage("Slam")

				task.delay(0.8, function()
					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					StunHandler:Unstun(Character, Stun)
					iFramesService:RemoveAlliFrames(Character)
					iFramesService:RemoveAlliFrames(EnemyCharacter)
					CollisionsModule:SetCollisionGroup(Character, "Players")
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
					fireStage("End")
				end)
			end)
		end

		task.delay(0.4, function()
			Hitbox:Start(0.7, true)
		end)

		StartupTrack.Stopped:Once(function()
			ReplicateEffects_Set:FireClient(Player, "CryostasisCrash", {
				char  = Character,
				stage = "StopDash",
			})
			if not Hit then
				Hitbox:Destroy()
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
			end
		end)
	end,
}