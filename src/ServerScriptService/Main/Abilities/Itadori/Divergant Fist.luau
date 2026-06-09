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
local DivergentAnims = Animations.Moves.Yuji.DivergentFist

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		AnimationService:stopAll(Character)
		local Anim, AnimEvents = AnimationService:getAnimationTrack(Character, DivergentAnims.KOKUSEN)

		ReplicateEffects_Set:FireAllClients("DivergentFist", {
			Stage = "Start",
			Char = Character,
			AnimId = "rbxassetid://91212369428740",
		})

		AnimationService:playAnimation(Character, DivergentAnims.KOKUSEN)

		task.delay(0.45, function()
			if not Character.Parent then return end

			ReplicateEffects_Set:FireAllClients("DivergentFist", {
				Stage = "Miss",
				Char = Character,
			})

			HitboxHandler:SimpleOnce(HumRP, Vector3.new(5, 5, 5), CFrame.new(0, 0, -3), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter:FindFirstChildOfClass("Humanoid")
				local EnemyHumRP: BasePart = EnemyCharacter:FindFirstChild("HumanoidRootPart")

				if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then return end
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
				if EnemyHumRP.Anchored then return end

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 30, nil, nil, true, false, true, true, true, nil)
				if HitInfo.Blocked then return end

				ReplicateEffects_Set:FireAllClients("DivergentFist", {
					Stage = "Hit",
					Char = Character,
					Victim = EnemyPlayer,
				})

				local VictimAnimator = EnemyHumanoid:FindFirstChildOfClass("Animator")
				if VictimAnimator then
					local hitAnim = math.random(1, 2) == 1 and DivergentAnims.Hit1 or DivergentAnims.Hit2
					VictimAnimator:LoadAnimation(hitAnim):Play(0)
				end

				if EnemyPlayer then
					ReplicateEffects_Set:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 2, Last = 0.3 })
				end
				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 2, Last = 0.3 })

				RagdollHandler.ragdoll(EnemyHumanoid, 1.1)
				NewKnockback:Knockback(EnemyCharacter, {
					KnockbackType = "VelocityTweenDown",
					MaxForce = Vector3.new(math.huge, math.huge, math.huge),
					Velocity = (EnemyHumRP.Position - HumRP.Position).Unit * 40,
					Time = 0.15,
				})

				if EnemyHumanoid.Health <= 1 then
					ReplicateEffects_Set:FireAllClients("DivergentFist", {
						Stage = "Finisher",
						Char = Character,
						Victim = EnemyPlayer,
					})

					if EnemyPlayer then
						ReplicateEffects_Set:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 4, Last = 0.5 })
					end
					ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 4, Last = 0.5 })

					RagdollHandler.ragdoll(EnemyHumanoid, 3)
					NewKnockback:Knockback(EnemyCharacter, {
						KnockbackType = "VelocityTweenDown",
						MaxForce = Vector3.new(math.huge, math.huge, math.huge),
						Velocity = (EnemyHumRP.Position - HumRP.Position).Unit * 1500,
						Time = 0.15,
					})
				end
			end)
		end)

		table.insert(AnimEvents, Anim.Stopped:Once(function()
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)
		end))

		task.delay(0.95, function()
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)
		end)
	end
}