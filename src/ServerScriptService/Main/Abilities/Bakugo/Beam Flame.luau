return {
	Start = function(Player: Player, Tool: Tool)
		local TweenService = game:GetService("TweenService")
		local Debris = game:GetService("Debris")
		local RunService = game:GetService("RunService")
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

		local MoveAnims = ServerStorage.Assets.Animations.Moves
		local ReplicateEffects_Set = RemotesContainer.Replicate.Set

		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		local StartAnimation = MoveAnims.Bakugo["BeamFlame"].Anim
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}

		-- [[ Hitbox fires immediately — large forward-facing area ]]:
		local hitboxCF = HumRP.CFrame * CFrame.new(0, 0, -25)
		local lookVector = HumRP.CFrame.LookVector
		local torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
		local torsoPos = torso and torso.Position or HumRP.Position

		local Hitbox = HitboxHandler.new()
		Hitbox.Instance = hitboxCF
		Hitbox.Size = Vector3.new(10, 10, 40)
		Hitbox.Ignore = { Character }
		Hitbox.onTouch = function(EnemyCharacter)
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

			if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 then return end

			-- [[ Dot product check — must be in front ]]:
			local toEnemy = (EnemyHumRP.Position - torsoPos)
			local dot = lookVector:Dot(toEnemy.Unit)
			if dot <= 0.7 then return end

			DamageHandler:TakeDamage(Character, EnemyHumanoid, 10, nil, nil, false, false, true, true, false, nil, nil)
			RagdollHandler.ragdoll(EnemyHumanoid, 1)
			NewKnockback:Knockback(EnemyCharacter, {
				KnockbackType = "Velocity",
				MaxForce = Vector3.new(1,1,1) * math.huge,
				Velocity = (EnemyHumRP.Position - HumRP.Position).Unit * 50
			})
		end
		Hitbox:Once()
		Hitbox:Destroy()

		-- [[ Fire replication ]]:
		local targetCF = HumRP.CFrame * CFrame.new(0, 1.5, -8)
		ReplicateEffects_Set:FireAllClients("BakugoBeamFlame", {
			char = Character,
			stage = "Start",
			id = StartAnimation.AnimationId,
			posX = targetCF.Position.X,
			posY = targetCF.Position.Y,
			posZ = targetCF.Position.Z,
			dirX = HumRP.CFrame.LookVector.X,
			dirZ = HumRP.CFrame.LookVector.Z,
		})

		StartTrack.Stopped:Once(function()
			for _, v in StartEvents do v:Disconnect() end
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
	end
}