local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

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
local BodymoverService = require(ServerModules.BodymoverService)
local SkillCollision = require(ServerModules.SkillCollision)
local AimTracker = require(ServerModules.AimTracker)

local MoveAnims = ServerStorage.Assets.Animations.Moves
local UserAnimation = MoveAnims.Shattered.Awakening.Oblivion

local CharacterAssets = ReplicatedStorage.Resources.CharacterAssets
local ObliviionAssets = CharacterAssets.Shattered.Oblivion

local BACK_TWEEN_DISTANCE = 40
local BACK_TWEEN_TIME = 1.15

local JUMP_HITBOX_SIZE = Vector3.new(50, 50, 50)
local JUMP_LAUNCH_VELOCITY = 40
local JUMP_LAUNCH_HEIGHT = 150
local JUMP_RAGDOLL_TIME = 3

local LIFT_WAIT_TIME = 0.15
local CASTER_LIFT_HEIGHT = 150

local AIM_DURATION = 5
local AIM_RANGE = 200
local AIM_ORIGIN_OFFSET = Vector3.new(0, 70, 0)

local CAM_STREAM_DURATION = AIM_DURATION + 2

local PUNCH_WAIT_TIME = 2
local PUNCH_TRAVEL_TIME = 1.6
local CAMPART_RIGHT_OFFSET = 100

local FINAL_HITBOX_SIZE = Vector3.new(500, 500, 500)
local FINAL_DAMAGE = 30

local ExcludeRayParams = RaycastParams.new()
ExcludeRayParams.FilterType = Enum.RaycastFilterType.Exclude
ExcludeRayParams.FilterDescendantsInstances = { workspace.Live, workspace.Debris }
ExcludeRayParams.IgnoreWater = true

local function lockAirborne(Humanoid, HumRP)
	Humanoid.AutoRotate = false
	Humanoid.PlatformStand = true
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	HumRP.AssemblyLinearVelocity = Vector3.zero
	HumRP.Anchored = true
end

local function restoreGroundControl(Humanoid, HumRP)
	HumRP.Anchored = false
	Humanoid.PlatformStand = false
	Humanoid.AutoRotate = true
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
	if Humanoid.Health > 0 then
		Humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end
end

return {
	Cooldown = 30,
	Start = function(Player, Tool)
		local Character = Player.Character
		if not Character or not Character.Parent then
			return
		end

		local HumRP = Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character:FindFirstChild("Humanoid")
		if not HumRP or not Humanoid then
			return
		end

		local CasterStun = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)

		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)
		if not UserTrack then
			StunHandler:Unstun(Character, CasterStun)
			return
		end

		SkillCollision:Lock(Character)

		local cancelled = false
		local iFramesGranted = false
		local cancelHandlerUnregistered = false
		local isAirborne = false
		local aimBridge = nil
		local aimDirection = nil
		local targetPosition = nil
		local camPartActive = false
		local rotationConn = nil
		local indicatorId = tostring(Character) .. "_Oblivion_Indicator"
		local OriginPosition = HumRP.Position

		local onDamageCancel

		local function stopRotation()
			if rotationConn then
				rotationConn:Disconnect()
				rotationConn = nil
			end
		end

		local function startRotation()
			stopRotation()
			rotationConn = RunService.Heartbeat:Connect(function()
				if not HumRP or not HumRP.Parent or not isAirborne then
					return
				end

				local dir = aimBridge and aimBridge:Get()
				if not dir or dir.Magnitude < 0.01 then
					return
				end

				HumRP.CFrame = CFrame.new(HumRP.Position, HumRP.Position + dir)
			end)
		end

		local function cleanup()
			SkillCollision:Unlock(Character)

			stopRotation()

			if isAirborne then
				if HumRP and HumRP.Parent then
					restoreGroundControl(Humanoid, HumRP)
				end
				isAirborne = false
			end

			if camPartActive then
				camPartActive = false
				RemoteManager.FireClient(Player, "ReplicateTask", "CustomCamPart", { func = "Stop" })
			end

			RemoteManager.FireAllClients("ReplicateTask", "IndicatorEnd", { id = indicatorId, ownerId = Player.UserId })
			RemoteManager.FireAllClients("ReplicateTask", "OblivionFists", { func = "Stop", char = Character })

			if aimBridge then
				aimBridge:Destroy()
				aimBridge = nil
			end

			if not cancelHandlerUnregistered then
				cancelHandlerUnregistered = true
				SkillCancelHandler:Unregister(Character, onDamageCancel)
			end

			if iFramesGranted then
				iFramesService:RemoveiFrames(Character, "All")
			end

			StunHandler:Unstun(Character, CasterStun)

			if Humanoid and Humanoid.Parent then
				Humanoid.WalkSpeed = 16
			end
		end

		onDamageCancel = function()
			if cancelled then
				return
			end
			cancelled = true
			if UserTrack and UserTrack.IsPlaying then
				UserTrack:Stop()
			end
			cleanup()
		end

		SkillCancelHandler:Register(Character, onDamageCancel)

		local backTarget = HumRP.CFrame * CFrame.new(0, 0, BACK_TWEEN_DISTANCE)
		TweenService:Create(HumRP, TweenInfo.new(BACK_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = backTarget,
		}):Play()

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("jump"):Once(function()
				if cancelled or not Character.Parent then
					return
				end

				iFramesGranted = true
				cancelHandlerUnregistered = true
				SkillCancelHandler:Unregister(Character, onDamageCancel)
				iFramesService:AddiFrames(Character, "All")

				RemoteManager.FireAllClients("ReplicateTask", "ShatteredImpact", { char = Character })
				RemoteManager.FireClient(Player, "ReplicateTask", "ShakeCamera", { Intensity = 6, Last = 0.4 })

				local HitList = {}

				HitboxHandler:SimpleOnce(
					HumRP,
					JUMP_HITBOX_SIZE,
					CFrame.new(0, 0, 0),
					{ Character },
					"Box",
					nil,
					function(EnemyCharacter)
						if table.find(HitList, EnemyCharacter) then
							return
						end

						local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
						local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
						if not EnemyHumanoid or not EnemyHumRP or EnemyHumanoid.Health <= 0 then
							return
						end
						if iFramesService:HasiFrame(EnemyCharacter, 1) then
							return
						end

						table.insert(HitList, EnemyCharacter)

						local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
						if EnemyPlayer then
							RemoteManager.FireClient(
								EnemyPlayer,
								"ReplicateTask",
								"ShakeCamera",
								{ Intensity = 8, Last = 0.6 }
							)
						end

						if EnemyCharacter:HasTag("Ragdolled") then
							RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, false, true, true)
						end

						RagdollHandler.ragdoll(EnemyHumanoid, JUMP_RAGDOLL_TIME, false)

						EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
						EnemyHumRP.AssemblyAngularVelocity = Vector3.zero

						task.defer(function()
							if not EnemyCharacter or not EnemyCharacter.Parent then
								return
							end

							BodymoverService:Knockback(EnemyCharacter, {
								KnockbackType = "Velocity",
								MaxForce = Vector3.new(1, 100000, 1),
								Velocity = Vector3.new(0, JUMP_LAUNCH_VELOCITY, 0),
								Time = JUMP_LAUNCH_HEIGHT / JUMP_LAUNCH_VELOCITY,
							})
						end)
					end
				)

				aimBridge = AimTracker.new(Player, "Oblivion")
				RemoteManager.FireClient(Player, "ReplicateTask", "StreamCameraDirection", {
					Duration = CAM_STREAM_DURATION,
					BridgeId = aimBridge.Bridge.Name,
				})

				task.wait(LIFT_WAIT_TIME)

				if cancelled or not Character or not Character.Parent then
					return
				end

				local pivot = Character:GetPivot()
				Character:PivotTo(
					CFrame.new(OriginPosition + Vector3.new(0, CASTER_LIFT_HEIGHT, 0)) * (pivot - pivot.Position)
				)

				lockAirborne(Humanoid, HumRP)
				isAirborne = true

				startRotation()
			end)
		)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("charge"):Once(function()
				if cancelled or not Character.Parent then
					return
				end

				UserTrack:AdjustSpeed(0)

				local IndicatorAsset = ObliviionAssets:FindFirstChild("Indicator")

				RemoteManager.FireAllClients("ReplicateTask", "Indicator", {
					char = Character,
					id = indicatorId,
					asset = IndicatorAsset,
					ownerId = Player.UserId,
					originOffset = AIM_ORIGIN_OFFSET,
				})

				task.delay(AIM_DURATION, function()
					if cancelled or not Character.Parent then
						return
					end

					aimDirection = (aimBridge and aimBridge:Get()) or HumRP.CFrame.LookVector

					local origin = HumRP.Position + AIM_ORIGIN_OFFSET
					local ray = workspace:Raycast(origin, aimDirection * AIM_RANGE, ExcludeRayParams)

					if ray then
						targetPosition = ray.Position
					else
						targetPosition = origin + aimDirection * AIM_RANGE
					end

					if UserTrack and UserTrack.IsPlaying then
						UserTrack:AdjustSpeed(1)
					end
				end)
			end)
		)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("punch"):Once(function()
				if cancelled or not Character.Parent or not targetPosition then
					return
				end

				stopRotation()

				local rightVector = HumRP.CFrame.RightVector
				local camPartPosition = targetPosition + rightVector * CAMPART_RIGHT_OFFSET

				camPartActive = true
				RemoteManager.FireClient(Player, "ReplicateTask", "CustomCamPart", {
					func = "Start",
					position = camPartPosition,
					lookTarget = Character,
				})

				RemoteManager.FireAllClients("ReplicateTask", "OblivionFists", {
					func = "Start",
					char = Character,
					targetPosition = targetPosition,
					waitTime = PUNCH_WAIT_TIME,
					travelTime = PUNCH_TRAVEL_TIME,
				})

				task.delay(PUNCH_WAIT_TIME + PUNCH_TRAVEL_TIME, function()
					if cancelled then
						return
					end

					RemoteManager.FireAllClients("ReplicateTask", "OblivionExplosion", { position = targetPosition })
					SFXModule:Play("EclipseImpact", targetPosition)

					local HitList = {}

					HitboxHandler:SimpleOnce(
						targetPosition,
						FINAL_HITBOX_SIZE,
						nil,
						{ Character },
						"Box",
						nil,
						function(EnemyCharacter)
							if table.find(HitList, EnemyCharacter) then
								return
							end

							local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
							if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then
								return
							end
							if iFramesService:HasiFrame(EnemyCharacter, 2) then
								return
							end

							table.insert(HitList, EnemyCharacter)

							DamageHandler:TakeDamage(
								Character,
								EnemyHumanoid,
								FINAL_DAMAGE,
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

							local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
							if EnemyPlayer then
								RemoteManager.FireClient(
									EnemyPlayer,
									"ReplicateTask",
									"ShakeCamera",
									{ Intensity = 8, Last = 0.6 }
								)
							end
						end
					)

					camPartActive = false
					RemoteManager.FireClient(Player, "ReplicateTask", "CustomCamPart", { func = "Stop" })

					if UserTrack and UserTrack.IsPlaying then
						UserTrack:Stop()
					end
				end)
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			if not cancelled then
				cancelled = true
				cleanup()
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
