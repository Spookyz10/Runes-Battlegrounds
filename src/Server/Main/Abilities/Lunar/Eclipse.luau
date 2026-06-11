local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local BodymoverService = require(ServerModules.BodymoverService)
local RagdollHandler = require(ServerModules.RagdollHandler)

local MoveAnims = ServerStorage.Assets.Animations.Moves
local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

return {
	Start = function(Player, Tool)
		local Character = Player.Character
		local HumRP = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		local UserAnimation = MoveAnims.Lunar:FindFirstChild("Lunar Lunge")
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		local DetectHitbox = nil

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("hit"):Once(function()
				local SlashCF = HumRP.CFrame

				local HitList = {}

				HitboxHandler:SimpleOnce(
					SlashCF,
					Vector3.new(10, 10, 10),
					CFrame.new(0, 0, -2),
					{ Character },
					"Box",
					nil,
					function(EnemyCharacter)
						local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
						local EnemyHumanoid = EnemyCharacter.Humanoid
						local EnemyHumRP = EnemyCharacter.HumanoidRootPart

						if table.find(HitList, EnemyCharacter) then
							return
						end
						if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
							return
						end
						if EnemyHumanoid.Health <= 0 then
							return
						end
						if EnemyCharacter:HasTag("Ragdolled") then
							return
						end

						table.insert(HitList, EnemyCharacter)

						local HitInfo = DamageHandler:TakeDamage(
							Character,
							EnemyHumanoid,
							18,
							1.5,
							nil,
							true,
							true,
							true,
							true,
							true,
							nil,
							nil
						)

						if HitInfo.Countered or HitInfo.Blocked then
							return
						end

						-- Knockback radial a partir do centro do slash
						local PushDir = (EnemyHumRP.Position - SlashCF.Position).Unit
						PushDir = Vector3.new(PushDir.X, 0, PushDir.Z).Unit

						BodymoverService:Knockback(EnemyCharacter, {
							KnockbackType = "Velocity",
							MaxForce = Vector3.new(1, 1, 1) * 80000,
							Velocity = PushDir * 50 + Vector3.new(0, 18, 0),
						})

						RagdollHandler.ragdoll(EnemyHumanoid, 2)

						if EnemyPlayer then
							ReplicateSet:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 2, Last = 0.3 })
						end
					end
				)
			end)
		)

		-- ─── cleanup ───────────────────────────────────────────────────────────────
		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			if DetectHitbox then
				DetectHitbox:Destroy()
				DetectHitbox = nil
			end

			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
