return {
	Start = function(Player: Player, Tool: Tool)
		local TweenService = game:GetService("TweenService")
		local Debris = game:GetService("Debris")
		local ServerStorage = game:GetService("ServerStorage")
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local Lighting = game:GetService("Lighting")

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

		local StartAnimation = MoveAnims.Bakugo["Explosion"].User
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}

		task.spawn(function()
			-- [[ Close range hitbox ]]:
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(5, 5, 10)
			Hitbox.Offset = CFrame.new(0, 0, -5)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 then return end

				DamageHandler:TakeDamage(Character, EnemyHumanoid, 10, nil, nil, false, false, true, true, false, nil, nil)
				RagdollHandler.ragdoll(EnemyHumanoid, 1.5)
				NewKnockback:Knockback(EnemyCharacter, {
					KnockbackType = "Velocity",
					MaxForce = Vector3.new(1,1,1) * math.huge,
					Velocity = (EnemyHumRP.Position - HumRP.Position).Unit * 50 + Vector3.new(0, 15, 0)
				})
			end
			Hitbox:Once()
			Hitbox:Destroy()

			-- [[ Area hitbox slightly after ]]:
			task.delay(0.05, function()
				local AreaHitbox = HitboxHandler.new()
				AreaHitbox.Instance = CFrame.new((HumRP.CFrame * CFrame.new(0, 0, -25)).Position)
				AreaHitbox.Size = Vector3.new(20, 8, 25)
				AreaHitbox.Ignore = { Character }
				AreaHitbox.onTouch = function(EnemyCharacter)
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

					if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 then return end

					DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, false, false, true, true, false, nil, nil)
					RagdollHandler.ragdoll(EnemyHumanoid, 1)
					NewKnockback:Knockback(EnemyCharacter, {
						KnockbackType = "Velocity",
						MaxForce = Vector3.new(1,1,1) * math.huge,
						Velocity = (EnemyHumRP.Position - HumRP.Position).Unit * 15
					})
				end
				AreaHitbox:Once()
				AreaHitbox:Destroy()
			end)

			-- [[ Lighting flash ]]:
			local cc = Instance.new("ColorCorrectionEffect")
			cc.TintColor = Color3.fromRGB(255, 100, 100)
			cc.Brightness = 0.1
			cc.Contrast = 0.2
			cc.Saturation = 0.1
			cc.Parent = Lighting
			TweenService:Create(cc, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TintColor = Color3.fromRGB(255, 255, 255),
				Brightness = 0,
				Contrast = 0,
				Saturation = 0
			}):Play()
			Debris:AddItem(cc, 1)

			ReplicateEffects_Set:FireAllClients("BakugoExplosion", { char = Character, stage = "Hitbox" })
		end)

		StartTrack.Stopped:Once(function()
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)

		ReplicateEffects_Set:FireAllClients("BakugoExplosion", { char = Character, stage = "Start", id = StartAnimation.AnimationId })
	end
}