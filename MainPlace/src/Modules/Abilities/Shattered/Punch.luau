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
local PerfectKnockback = require(ServerModules.PerfectKnockback)

local MoveAnims = ServerStorage.Assets.Animations.Moves

local HIT_SIZE = Vector3.new(8, 5, 8)
local HIT_OFFSET = CFrame.new(0, 3, -4)
local WAVE_SIZE = Vector3.new(30, 30, 70)
local WAVE_OFFSET = CFrame.new(0, 0, -20)
local WAVE_DAMAGE = 5
local WAVE_DURATION = 0.25
local WAVE_FORCE = 10 / WAVE_DURATION

local DAMAGE = 35
local RAGDOLL_TIME = 3

local LAUNCH_FORCE = 130
local LAUNCH_UP_FORCE = 40

local RING_FORWARD_OFFSET = 3
local RING_TILT = CFrame.Angles(math.rad(90), 0, 0)

local LANDING_IMPACT_CONFIG = {
	Damage = 6,
	Size = Vector3.new(12, 12, 12),
	Offset = CFrame.new(0, 0, 0),
	GroundCrater = {
		{
			["end"] = Vector3.new(0, -25, 0),
			amount = 6,
			nosound = true,
			size = 0.3,
		},
	},
}

local PUNCH_DEBRIS_CONFIG = {
	HalfAngle = 15,
	StepsPerSide = 15,
	FirstDistance = 3,
	LastDistance = 90,

	SpreadRadius = 1.6,
	ChunksPerStepMin = 2,
	ChunksPerStepMax = 5,

	StartSize = Vector3.new(1, 0.9, 1),
	EndSize = Vector3.new(12, 9, 12),
}

local SELF_HIT_SHAKE_INTENSITY = 6
local SELF_HIT_SHAKE_TIME = 0.4
local ENEMY_HIT_SHAKE_INTENSITY = 6
local ENEMY_HIT_SHAKE_TIME = 0.5

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
				local DebrisParams = table.clone(PUNCH_DEBRIS_CONFIG)
				DebrisParams.char = Character

				local FirstProps = { Size = Vector3.new(0.6, 4, 0.6), Transparency = 0 }
				local FinalProps = { Size = Vector3.new(80, 10, 80), Transparency = 1 }
				local TN_Info = { Time = 0.4, Style = "Quad", Direction = "Out" }

				local RingPosition = (HumRP.CFrame * CFrame.new(0, 0, -RING_FORWARD_OFFSET)).Position
				local RingCFrame = CFrame.new(RingPosition) * (HumRP.CFrame.Rotation * RING_TILT)

				RemoteManager.FireAllClients("ReplicateTask", "Ring", {
					FirstProps = FirstProps,
					CF = RingCFrame,
					TN_Info = TN_Info,
					FinalProps = FinalProps,
				})

				RemoteManager.FireAllClients("ReplicateTask", "PunchWedgeDebris", DebrisParams)

				RemoteManager.FireClient(Player, "ReplicateTask", "ShakeCamera", { Intensity = 4, Last = 0.3 })

				local HitList = {}
				local PunchCFrame = HumRP.CFrame

				HitboxHandler:SimpleOnce(
					PunchCFrame,
					HIT_SIZE,
					HIT_OFFSET,
					{ Character },
					nil,
					nil,
					function(EnemyCharacter)
						if table.find(HitList, EnemyCharacter) then
							return
						end
						table.insert(HitList, EnemyCharacter)

						local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
						local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
						if not EnemyHumanoid or not EnemyHumRP then
							return
						end
						if EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then
							return
						end
						if iFramesService:HasiFrame(EnemyCharacter, 1) then
							return
						end

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

						task.spawn(function()
							if not EnemyCharacter or not EnemyCharacter.Parent then
								return
							end
							if not EnemyHumRP or not EnemyHumRP.Parent then
								return
							end

							EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

							local pushDir = HumRP.CFrame.LookVector
							local pushFlat = Vector3.new(pushDir.X, 0, pushDir.Z)
							pushFlat = pushFlat.Magnitude > 0 and pushFlat.Unit or Vector3.new(0, 0, -1)

							SFXModule:Play("Smack", EnemyHumRP)

							RagdollHandler.ragdoll(
								EnemyHumanoid,
								RAGDOLL_TIME,
								true,
								Character,
								LANDING_IMPACT_CONFIG,
								nil,
								true
							)

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

							RemoteManager.FireClient(Player, "ReplicateTask", "ShakeCamera", {
								Intensity = SELF_HIT_SHAKE_INTENSITY,
								Last = SELF_HIT_SHAKE_TIME,
							})

							local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
							if EnemyPlayer then
								RemoteManager.FireClient(EnemyPlayer, "ReplicateTask", "ShakeCamera", {
									Intensity = ENEMY_HIT_SHAKE_INTENSITY,
									Last = ENEMY_HIT_SHAKE_TIME,
								})
							end
						end)
					end
				)

				local WaveIgnore = table.clone(HitList)
				table.insert(WaveIgnore, Character)
				HitboxHandler:SimpleOnce(
					PunchCFrame,
					WAVE_SIZE,
					WAVE_OFFSET,
					WaveIgnore,
					nil,
					nil,
					function(EnemyCharacter)
						local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
						local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
						if not EnemyHumanoid or not EnemyHumRP or EnemyHumanoid.Health <= 0 then
							return
						end
						if iFramesService:HasiFrame(EnemyCharacter, 1) then
							return
						end

						local HitInfo = DamageHandler:TakeDamage(
							Character,
							EnemyHumanoid,
							WAVE_DAMAGE,
							nil,
							nil,
							true,
							true,
							true,
							true,
							false
						)
						if
							not HitInfo
							or not HitInfo.CouldHit
							or HitInfo.Blocked
							or HitInfo.Countered
							or EnemyHumanoid.Health <= 0
						then
							return
						end

						local Forward = PunchCFrame.LookVector
						local Direction = Vector3.new(Forward.X, 0, Forward.Z)
						Direction = if Direction.Magnitude > 0 then Direction.Unit else Vector3.new(0, 0, -1)
						PerfectKnockback:KnockBack(nil, EnemyCharacter, {
							LookVector = Direction,
							LookForce = WAVE_FORCE,
							LookFinalForce = WAVE_FORCE / 1.1,
							GroundStunTime = 0,
							FallingDetectDelay = 0,
							DontFreeze = true,
						}, Character)

						local ActiveKnockback = PerfectKnockback.Active[EnemyCharacter]
						if ActiveKnockback then
							task.delay(WAVE_DURATION, function()
								if PerfectKnockback.Active[EnemyCharacter] ~= ActiveKnockback then
									return
								end
								PerfectKnockback:Cancel(EnemyCharacter)
								if EnemyHumRP.Parent then
									local Velocity = EnemyHumRP.AssemblyLinearVelocity
									EnemyHumRP.AssemblyLinearVelocity = Vector3.new(0, Velocity.Y, 0)
								end
							end)
						end
					end
				)
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
