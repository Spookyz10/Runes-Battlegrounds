local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local SFXModule = require(ReplicatedStorage.Shared.Modules.SFXModule)
local StunHandler = require(ServerModules.StunHandler)
local AirDetectionService = require(ServerModules.AirDetectionService)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local SkillCancelHandler = require(ServerModules.SkillCancelHandler)
local iFramesService = require(ServerModules.iFramesService)
local PerfectKnockback = require(ServerModules.PerfectKnockback)
local RagdollHandler = require(ServerModules.RagdollHandler)
local BodymoverService = require(ServerModules.BodymoverService)
local StatusEffectHandler = require(ServerModules.StatusEffectHandler)

local MoveAnims = ServerStorage.Assets.Animations.Moves

local HITBOX_SIZE = Vector3.new(30, 30, 30)
local HITBOX_OFFSET = CFrame.new(0, 0, 0)
local DAMAGE = 15
local STUN_TIME = 0.4

local VFX_LINGER_TIME = 6

local BLOCKED_KNOCK_FORCE = 35
local BLOCKED_UP_FORCE = 25
local BLOCKED_RAGDOLL_TIME = 2.5
local INFERNO_DURATION = 10

return {
	Cooldown = 10,
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

		local UserAnimation = MoveAnims.Eclipse.Solar.Sunquake
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		if not UserTrack then
			StunHandler:Unstun(Character, Stun)
			return
		end

		local cancelled = false
		local onDamageCancel
		onDamageCancel = function()
			if cancelled then
				return
			end
			cancelled = true
			RemoteManager.FireAllClients("ReplicateTask", "SunquakeVFX", { func = "Stop", char = Character })
			if UserTrack and UserTrack.IsPlaying then
				UserTrack:Stop()
			end
		end

		SkillCancelHandler:Register(Character, onDamageCancel)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("freeze"):Once(function()
				UserTrack:AdjustSpeed(0)

				SFXModule:Play("sunquakeWindup", HumRP)
				RemoteManager.FireAllClients("ReplicateTask", "SunquakeVFX", { char = Character })

				task.delay(1, function()
					if not UserTrack.IsPlaying then
						return
					end

					UserTrack:AdjustSpeed(1)

					local HitList = {}

					SFXModule:Play("sunquakeExplosion", HumRP)

					HitboxHandler:SimpleOnce(
						HumRP,
						HITBOX_SIZE,
						HITBOX_OFFSET,
						{ Character },
						"Box",
						nil,
						function(EnemyCharacter)
							if table.find(HitList, EnemyCharacter) then
								return
							end

							local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
							local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
							if not EnemyHumanoid or not EnemyHumRP then
								return
							end
							if EnemyHumanoid.Health <= 0 then
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
								STUN_TIME,
								nil,
								false,
								false,
								true,
								true,
								false,
								nil,
								nil
							)

							if HitInfo.Countered then
								return
							end

							EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

							local pushDir = (EnemyHumRP.Position - HumRP.Position)
							pushDir = Vector3.new(pushDir.X, 0, pushDir.Z)
							if pushDir.Magnitude > 0 then
								pushDir = pushDir.Unit
							else
								pushDir = HumRP.CFrame.LookVector
							end

							if EnemyCharacter:HasTag("Blocking") then
								RagdollHandler.ragdoll(EnemyHumanoid, BLOCKED_RAGDOLL_TIME)

								task.defer(function()
									if not EnemyCharacter or not EnemyCharacter.Parent then
										return
									end
									BodymoverService:Knockback(EnemyCharacter, {
										KnockbackType = "Velocity",
										MaxForce = Vector3.new(100000, 100000, 100000),
										Velocity = pushDir * BLOCKED_KNOCK_FORCE + Vector3.new(0, BLOCKED_UP_FORCE, 0),
									})
								end)
							else
								local lookCF = CFrame.lookAt(EnemyHumRP.Position, EnemyHumRP.Position + pushDir)

								StatusEffectHandler:Apply(EnemyCharacter, "Inferno", { Duration = INFERNO_DURATION })

								PerfectKnockback:KnockBack(nil, EnemyCharacter, {
									LookVector = pushDir,
									LookForce = 20,
									LookFinalForce = 50,
									LookAt = lookCF,
									UpVelocity = Vector3.new(0, 45, 0),
									UpVelocityTime = 0.4,
									GroundStunTime = 1.0,
									FallingDetectDelay = 0.5,
									Dot = 1,
									DontFreeze = false,
								}, Character)
							end

							AirDetectionService:Start(EnemyCharacter, {
								ragdoll = true,
							})
						end
					)
				end)
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			if cancelled then
				RemoteManager.FireAllClients("ReplicateTask", "SunquakeVFX", { func = "Stop", char = Character })
			else
				task.delay(VFX_LINGER_TIME, function()
					RemoteManager.FireAllClients("ReplicateTask", "SunquakeVFX", { func = "Stop", char = Character })
				end)
			end

			SkillCancelHandler:Unregister(Character, onDamageCancel)
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
