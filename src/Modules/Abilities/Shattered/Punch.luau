local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local SFXModule = require(ReplicatedStorage.Shared.Modules.SFXModule)
local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local AnimationService = require(ServerModules.AnimationService)
local SkillCancelHandler = require(ServerModules.SkillCancelHandler)
local iFramesService = require(ServerModules.iFramesService)
local RagdollHandler = require(ServerModules.RagdollHandler)
local NewKnockback = require(ServerModules.BodymoverService)

local MoveAnims = ServerStorage.Assets.Animations.Moves

local HIT_SIZE = Vector3.new(8, 8, 8)
local HIT_OFFSET = CFrame.new(0, 0, -4)

local DAMAGE = 20
local RAGDOLL_TIME = 3

local LAUNCH_FORCE = 130
local LAUNCH_UP_FORCE = 40

return {
	Cooldown = 15,
	Start = function(Player, Tool)
		local Character = Player.Character
		if not Character then
			return
		end

		local HumRP = Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character:FindFirstChild("Humanoid")
		if not HumRP or not Humanoid then
			return
		end

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)

		local UserAnimation = MoveAnims.Shattered.Punch
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		local cancelled = false
		local onDamageCancel

		onDamageCancel = function()
			if cancelled then
				return
			end
			cancelled = true
			if UserTrack and UserTrack.IsPlaying then
				UserTrack:Stop()
			end
		end

		SkillCancelHandler:Register(Character, onDamageCancel)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("hit"):Once(function()
				local HitList = {}

				SFXModule:Play("PunchHit", HumRP)

				HitboxHandler:SimpleOnce(HumRP, HIT_SIZE, HIT_OFFSET, { Character }, nil, nil, function(EnemyCharacter)
					if table.find(HitList, EnemyCharacter) then
						return
					end

					local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
					local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
					if not EnemyHumanoid or not EnemyHumRP then
						return
					end
					if EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then
						return
					end
					if EnemyCharacter:HasTag("Ragdolled") then
						return
					end
					if iFramesService:HasiFrame(EnemyCharacter, 1) then
						return
					end

					table.insert(HitList, EnemyCharacter)

					local HitInfo = DamageHandler:TakeDamage(
						Character,
						EnemyHumanoid,
						DAMAGE,
						nil,
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

					EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

					local pushDir = HumRP.CFrame.LookVector
					local pushFlat = Vector3.new(pushDir.X, 0, pushDir.Z)
					pushFlat = pushFlat.Magnitude > 0 and pushFlat.Unit or Vector3.new(0, 0, -1)

					RagdollHandler.ragdoll(EnemyHumanoid, RAGDOLL_TIME, nil, nil, nil, nil, true)

					task.defer(function()
						if not EnemyCharacter or not EnemyCharacter.Parent then
							return
						end

						NewKnockback:Knockback(EnemyCharacter, {
							KnockbackType = "Velocity",
							MaxForce = Vector3.new(100000, 100000, 100000),
							Velocity = pushFlat * LAUNCH_FORCE + Vector3.new(0, LAUNCH_UP_FORCE, 0),
						})
					end)

					local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
					if EnemyPlayer then
						RemoteManager.FireClient(
							EnemyPlayer,
							"ReplicateTask",
							"ShakeCamera",
							{ Intensity = 6, Last = 0.5 }
						)
					end
				end)

				RemoteManager.FireClient(Player, "ReplicateTask", "ShakeCamera", { Intensity = 4, Last = 0.3 })
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			SkillCancelHandler:Unregister(Character, onDamageCancel)
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
