return {
	Start = function(Player: Player, Tool: Tool)
		local Debris = game:GetService("Debris")
		local ServerStorage = game:GetService("ServerStorage")
		local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
		local CollisionsModule = require(ServerModules.CollisionsModule)
		local WeldSystem = require(ReplicatedModules.WeldSystem)

		local MoveAnims = ServerStorage.Assets.Animations.Moves
		local ReplicateEffects_Set = RemotesContainer.Replicate.Set

		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		local Hit = false

		local Hitbox = HitboxHandler.new()
		Hitbox.Instance = HumRP
		Hitbox.Size = Vector3.new(8, 8, 8)
		Hitbox.Offset = CFrame.new(0, 0, 0)
		Hitbox.Ignore = { Character }
		Hitbox.onTouch = function(EnemyCharacter)
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

			if Hit or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 then return end
			Hit = true
			Hitbox:Destroy()

			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
			iFramesService:AddAlliFrames(EnemyCharacter)
			CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

			-- [[ Position setup ]]:
			local originalPlayerPos = HumRP.Position
			local direction = Vector3.new(
				EnemyHumRP.Position.X - HumRP.Position.X,
				0,
				EnemyHumRP.Position.Z - HumRP.Position.Z
			)
			if direction.Magnitude < 2 then direction = HumRP.CFrame.LookVector end
			local offset = direction.Unit * 4

			HumRP.Anchored = true
			EnemyHumRP.Anchored = true
			HumRP.CFrame = CFrame.new(originalPlayerPos)
			EnemyHumRP.CFrame = CFrame.new(originalPlayerPos + offset)
			task.wait(0.03)

			local Weld = WeldSystem.new(HumRP, EnemyHumRP,
				CFrame.new(-offset.X, -offset.Y, -offset.Z), -1)

			-- [[ Damage ]]:
			DamageHandler:TakeDamage(Character, EnemyHumanoid, 20, nil, nil, false, false, true, true, false, nil, nil)

			-- [[ Anims ]]:
			local UserAnim = MoveAnims.Bakugo["Divinerush"].User
			local UserTrack = AnimationService:getAnimationTrack(Character, UserAnim)
			local EnemyAnim = MoveAnims.Bakugo["Divinerush"].Enemy
			local EnemyTrack = AnimationService:getAnimationTrack(EnemyCharacter, EnemyAnim)

			-- [[ Fire replication — pass full CFrame directly ]]:
			ReplicateEffects_Set:FireAllClients("BakugoDivineRush", {
				char = Character,
				enemy = EnemyCharacter,
				stage = "Start",
				hrpCF = HumRP.CFrame,
			})

			-- [[ Final damage + cleanup ]]:
			task.delay(6.5, function()
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 15, nil, nil, false, false, true, true, true, nil, nil)
				RagdollHandler.ragdoll(EnemyHumanoid, 3)
				NewKnockback:Knockback(EnemyCharacter, {
					KnockbackType = "Velocity",
					MaxForce = Vector3.new(1,1,1) * math.huge,
					Velocity = HumRP.CFrame.LookVector * 50 + Vector3.new(0, 20, 0)
				})

				pcall(function() Weld:Stop() end)
				HumRP.Anchored = false
				EnemyHumRP.Anchored = false

				StunHandler:Unstun(EnemyCharacter, EnemyStun)
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
				iFramesService:RemoveAlliFrames(EnemyCharacter)
				CollisionsModule:SetCollisionGroup(Character, "Players")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

				ReplicateEffects_Set:FireAllClients("BakugoDivineRush", {
					char = Character,
					stage = "End",
				})
			end)

			AnimationService:stopAll(Character)
			AnimationService:stopAll(EnemyCharacter)
			AnimationService:playAnimation(Character, UserAnim)
			AnimationService:playAnimation(EnemyCharacter, EnemyAnim)
		end

		Hitbox:Start(0.25, true)

		task.delay(0.25, function()
			if not Hit then
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
			end
		end)
	end
}