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

local ReplicateEffects_Set = RemotesContainer.Replicate.Set

local Animations = ServerStorage.Assets.Animations
local JumpSparkAnims = Animations.Moves.Yuji.DivergentJump

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		AnimationService:stopAll(Character)
		local Anim = AnimationService:playAnimation(Character, JumpSparkAnims.Slam)

		ReplicateEffects_Set:FireAllClients("JumpSpark", {
			Stage = "Start",
			Char = Character,
			AnimId = JumpSparkAnims.Slam.AnimationId,
		})

		task.delay(1.55, function()
			if not Character.Parent then return end

			ReplicateEffects_Set:FireAllClients("JumpSpark", {
				Stage = "Slam",
				Char = Character,
			})

			ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 2.5, Last = 0.4 })

			HitboxHandler:SimpleOnce(HumRP, Vector3.new(14.475, 13.985, 43.27), CFrame.new(0, 0, 0), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter:FindFirstChildOfClass("Humanoid")
				local EnemyHumRP: BasePart = EnemyCharacter:FindFirstChild("HumanoidRootPart")

				if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then return end
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 25, nil, nil, true, false, true, true, true, nil)
				if HitInfo.Blocked then return end

				RagdollHandler.ragdoll(EnemyHumanoid, 2.5)
				NewKnockback:Knockback(EnemyCharacter, {
					KnockbackType = "VelocityTweenDown",
					MaxForce = Vector3.new(math.huge, math.huge, math.huge),
					Velocity = EnemyHumRP.CFrame.UpVector * 120 + HumRP.CFrame.LookVector * 30,
					Time = 0.3,
				})

				if EnemyPlayer then
					ReplicateEffects_Set:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 4, Last = 0.6 })
				end
				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 4, Last = 0.6 })

				if EnemyHumanoid.Health <= 1 then
					ReplicateEffects_Set:FireAllClients("JumpSpark", {
						Stage = "Finisher",
						Char = Character,
						Victim = EnemyPlayer,
					})

					if EnemyPlayer then
						ReplicateEffects_Set:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 4, Last = 0.6 })
					end
					ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 4, Last = 0.6 })
					RagdollHandler.ragdoll(EnemyHumanoid, 3)
				end
			end)
		end)

		Anim.Stopped:Once(function()
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)
		end)

		task.delay(2.5, function()
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)
		end)
	end
}