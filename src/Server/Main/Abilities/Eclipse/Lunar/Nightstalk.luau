local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local PerfectKnockback = require(ServerModules.PerfectKnockback)
local SkillCollisionLock = require(ServerModules.SkillCollisionLock)

local MoveAnims = ServerStorage.Assets.Animations.Moves
local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

local STAGE_DELAY = 0.2
local RAGDOLL_TIME = 4
local UP_FORCE = 90
local UP_VELOCITY_TIME = 0.15
local DAMAGE = 10

local CIRCLE_OFFSET_FORWARD = 3
local CIRCLE_OFFSET_DOWN = 3
local CIRCLE_VFX_DURATION = 3.95

local SPIKE_STAGES = {
	{ Distance = 7, HitboxSize = Vector3.new(6, 8, 6), Scale = 1 },
	{ Distance = 14, HitboxSize = Vector3.new(9, 8, 9), Scale = 1.5 },
	{ Distance = 23, HitboxSize = Vector3.new(12, 8, 12), Scale = 2 },
}

return {
	Start = function(Player, Tool)
		local Character = Player.Character
		local HumRP = Character.HumanoidRootPart

		Character:AddTag("CantRotate")

		if not Character.Parent then
			Character:RemoveTag("CantRotate")
			return
		end

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		iFramesService:AddAlliFrames(Character)
		SkillCollisionLock:Lock(Character)

		task.wait(0.2)

		local HitList = {}

		local circleCounter = 0
		local initialCircleId = tostring(Character) .. "_Nightstalk_Initial"

		local function getLookFlat()
			local lv = HumRP.CFrame.LookVector
			local flat = Vector3.new(lv.X, 0, lv.Z)
			if flat.Magnitude > 0 then
				return flat.Unit
			end
			return Vector3.new(0, 0, -1)
		end

		local function spawnCircle(id, position)
			ReplicateSet:FireAllClients("CircleVFX", { func = "Start", id = id, position = position })
		end

		local function despawnCircle(id)
			ReplicateSet:FireAllClients("CircleVFX", { func = "Stop", id = id })
		end

		local lookFlat = getLookFlat()
		local initialCirclePosition = HumRP.Position
			+ lookFlat * CIRCLE_OFFSET_FORWARD
			+ Vector3.new(0, -CIRCLE_OFFSET_DOWN, 0)
		spawnCircle(initialCircleId, initialCirclePosition)

		local function isValidEnemy(EnemyCharacter)
			local EnemyHumanoid = EnemyCharacter and EnemyCharacter:FindFirstChild("Humanoid")
			if not EnemyHumanoid then
				return false
			end
			if table.find(HitList, EnemyCharacter) then
				return false
			end
			if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
				return false
			end
			if EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then
				return false
			end
			return true
		end

		local function applyHit(EnemyCharacter)
			local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
			if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then
				return
			end

			table.insert(HitList, EnemyCharacter)

			local HitInfo = DamageHandler:TakeDamage(
				Character,
				EnemyHumanoid,
				DAMAGE,
				nil,
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

			local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
			local KnockLookVector = EnemyHumRP and (EnemyHumRP.Position - HumRP.Position) or getLookFlat()
			local FlatLookVector = Vector3.new(KnockLookVector.X, 0, KnockLookVector.Z)
			if FlatLookVector.Magnitude > 0.001 then
				FlatLookVector = FlatLookVector.Unit
			else
				FlatLookVector = getLookFlat()
			end

			PerfectKnockback:KnockBack(nil, EnemyCharacter, {
				LookVector = FlatLookVector,
				LookForce = 0,
				LookFinalForce = 0,
				UpVelocity = Vector3.new(0, UP_FORCE, 0),
				UpVelocityTime = UP_VELOCITY_TIME,
				GroundStunTime = RAGDOLL_TIME,
				FallingDetectDelay = 0.3,
				DontFreeze = false,
				Escapable = true,
			}, Character)

			local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
			if EnemyPlayer then
				ReplicateSet:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 2, Last = 0.3 })
			end
		end

		local function fireStage(stage)
			local stageLookFlat = getLookFlat()
			local spikePosition = HumRP.Position + Vector3.new(0, -3, 0) + stageLookFlat * stage.Distance

			ReplicateSet:FireAllClients("createSpike", {
				Scale = stage.Scale,
				Position = spikePosition,
			})

			ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 1.5, Last = 0.2 })

			circleCounter += 1
			local circleId = tostring(Character) .. "_Nightstalk_Spike_" .. circleCounter
			spawnCircle(circleId, spikePosition)

			task.delay(CIRCLE_VFX_DURATION, function()
				despawnCircle(circleId)
			end)

			HitboxHandler:SimpleOnce(
				HumRP,
				stage.HitboxSize,
				CFrame.new(0, 0, -stage.Distance),
				{ Character },
				"Box",
				nil,
				function(EnemyCharacter)
					if not isValidEnemy(EnemyCharacter) then
						return
					end
					applyHit(EnemyCharacter)
				end
			)
		end

		local cleanedUp = false
		local function cleanup()
			if cleanedUp then
				return
			end
			cleanedUp = true

			despawnCircle(initialCircleId)

			SkillCollisionLock:Unlock(Character)
			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)

			Character:RemoveTag("CantRotate")
		end

		local UserAnimation = MoveAnims.Eclipse.Lunar:FindFirstChild("Nightstalk")
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("onGround"):Once(function()
				task.spawn(function()
					UserTrack:AdjustSpeed(0)

					for index, stage in SPIKE_STAGES do
						if not Character.Parent then
							return
						end

						fireStage(stage)

						if index < #SPIKE_STAGES then
							task.wait(STAGE_DELAY)
						end
					end

					if UserTrack then
						UserTrack:AdjustSpeed(1)
					end
				end)
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end
			cleanup()
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
