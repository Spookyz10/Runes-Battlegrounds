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
local PerfectKnockback = require(ServerModules.PerfectKnockback)
local SkillCollision = require(ServerModules.SkillCollision)
local AimTracker = require(ServerModules.AimTracker)

local MoveAnims = ServerStorage.Assets.Animations.Moves

local STAGE_DELAY = 0.2
local RAGDOLL_TIME = 4
local UP_FORCE = 90
local UP_VELOCITY_TIME = 0.15
local DAMAGE = 10

local KNOCK_FORCE = 30
local KNOCK_FINAL_FORCE = 25

local CIRCLE_OFFSET_FORWARD = 3
local CIRCLE_OFFSET_DOWN = 3

local CAMERA_STREAM_DURATION = 3

local SPIKE_STAGES = {
	{ Distance = 7, HitboxSize = Vector3.new(6, 8, 6), Scale = 1 },
	{ Distance = 14, HitboxSize = Vector3.new(9, 8, 9), Scale = 1.5 },
	{ Distance = 23, HitboxSize = Vector3.new(12, 8, 12), Scale = 2 },
}

return {
	Cooldown = 15,
	Start = function(Player, Tool)
		local Character = Player.Character
		local Humanoid = Character and Character:FindFirstChild("Humanoid")
		local HumRP = Character and Character:FindFirstChild("HumanoidRootPart")
		if not Character or not Humanoid or not HumRP or Humanoid.Health <= 0 then
			return
		end
		SkillCollision:Lock(Character)
		Humanoid.WalkSpeed = 0
		Character:AddTag("CantRotate")

		HumRP.Anchored = true
		HumRP.AssemblyLinearVelocity = Vector3.zero

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)
		local onDamageCancel
		local cancelled = false

		if not Character.Parent then
			Character:RemoveTag("CantRotate")
			HumRP.Anchored = false
			return
		end

		SFXModule:Play("nightstalkInit", Character.HumanoidRootPart)

		local HitList = {}

		local initialCircleId = tostring(Character) .. "_Nightstalk_Initial"

		local activeCircles = {}

		-- Bridge genérica: pega a direção da câmera do jogador sem mexer no
		-- RotationController (o char tá com CantRotate + anchored aqui, não
		-- pode deixar o RotationController tentar girar ele).
		local aimBridge = AimTracker.new(Player, "Nightstalk")
		RemoteManager.FireClient(Player, "ReplicateTask", "StreamCameraDirection", {
			Duration = CAMERA_STREAM_DURATION,
			BridgeId = aimBridge.Bridge.Name,
		})

		local function getLookFlat()
			local CameraDir = aimBridge:Get()
			local lv = CameraDir or Character.HumanoidRootPart.CFrame.LookVector
			local flat = Vector3.new(lv.X, 0, lv.Z)
			if flat.Magnitude > 0 then
				return flat.Unit
			end
			return Vector3.new(0, 0, -1)
		end

		local function spawnCircle(id, cframe)
			activeCircles[id] = true
			RemoteManager.FireAllClients("ReplicateTask", "CircleVFX", { func = "Start", id = id, cframe = cframe })
		end

		local function despawnAllCircles()
			for id in activeCircles do
				activeCircles[id] = nil
				RemoteManager.FireAllClients("ReplicateTask", "CircleVFX", { func = "Stop", id = id })
			end
		end

		spawnCircle(
			initialCircleId,
			Character.HumanoidRootPart.CFrame * CFrame.new(0, -CIRCLE_OFFSET_DOWN, -CIRCLE_OFFSET_FORWARD)
		)

		local function isValidEnemy(EnemyCharacter)
			local EnemyHumanoid = EnemyCharacter and EnemyCharacter:FindFirstChild("Humanoid")
			if not EnemyHumanoid then
				return false
			end
			if table.find(HitList, EnemyCharacter) then
				return false
			end
			if iFramesService:HasiFrame(EnemyCharacter, 1) then
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
			local KnockLookVector = EnemyHumRP and (EnemyHumRP.Position - Character.HumanoidRootPart.Position)
				or getLookFlat()
			local FlatLookVector = Vector3.new(KnockLookVector.X, 0, KnockLookVector.Z)
			if FlatLookVector.Magnitude > 0.001 then
				FlatLookVector = FlatLookVector.Unit
			else
				FlatLookVector = getLookFlat()
			end

			local lookCF = EnemyHumRP and CFrame.lookAt(EnemyHumRP.Position, EnemyHumRP.Position + FlatLookVector)
				or nil

			PerfectKnockback:KnockBack(nil, EnemyCharacter, {
				LookVector = FlatLookVector,
				LookForce = KNOCK_FORCE,
				LookFinalForce = KNOCK_FINAL_FORCE,
				LookAt = lookCF,
				UpVelocity = Vector3.new(0, UP_FORCE, 0),
				UpVelocityTime = UP_VELOCITY_TIME,
				GroundStunTime = RAGDOLL_TIME,
				FallingDetectDelay = 0.3,
				Dot = 1,
				DontFreeze = false,
				Escapable = true,
			}, Character)

			local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
			if EnemyPlayer then
				RemoteManager.FireClient(EnemyPlayer, "ReplicateTask", "ShakeCamera", { Intensity = 2, Last = 0.3 })
			end
		end

		local function fireStage(stage)
			local stageLookFlat = getLookFlat()
			local spikePosition = Character.HumanoidRootPart.Position + stageLookFlat * stage.Distance

			RemoteManager.FireAllClients("ReplicateTask", "createSpike", {
				Scale = stage.Scale,
				Position = spikePosition,
			})

			SFXModule:Play("spike", spikePosition)

			RemoteManager.FireClient(Player, "ReplicateTask", "ShakeCamera", { Intensity = 1.5, Last = 0.2 })

			local hitboxOffset = Character.HumanoidRootPart.CFrame:ToObjectSpace(CFrame.new(spikePosition))

			HitboxHandler:SimpleOnce(
				Character.HumanoidRootPart,
				stage.HitboxSize,
				hitboxOffset,
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
			cancelled = true

			despawnAllCircles()

			if aimBridge then
				aimBridge:Destroy()
				aimBridge = nil
			end

			SkillCollision:Unlock(Character)
			SkillCancelHandler:Unregister(Character, onDamageCancel)
			iFramesService:RemoveiFrames(Character, "Base")
			StunHandler:Unstun(Character, Stun)

			Character:RemoveTag("CantRotate")

			if HumRP and HumRP.Parent then
				HumRP.Anchored = false
			end
		end

		local UserAnimation = MoveAnims.Eclipse.Lunar:FindFirstChild("Nightstalk")
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

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

		UserTrack:AdjustSpeed(2)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("onGround"):Once(function()
				iFramesService:AddBaseiFrames(Character)

				task.spawn(function()
					UserTrack:AdjustSpeed(0)

					for index, stage in SPIKE_STAGES do
						if cancelled or not Character.Parent then
							return
						end

						fireStage(stage)

						if index < #SPIKE_STAGES then
							task.wait(STAGE_DELAY)
						end
					end

					if UserTrack and not cancelled then
						UserTrack:AdjustSpeed(2)
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
