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
local CASTER_LIFT_HEIGHT = 300

local CHARGE_MARKER_DELAY = 0.1

local AIM_DURATION = 5
local AIM_RANGE = 400
local AIM_ORIGIN_OFFSET = Vector3.new(0, 70, 0)

local GroundSnapParams = RaycastParams.new()
GroundSnapParams.FilterType = Enum.RaycastFilterType.Exclude
GroundSnapParams.FilterDescendantsInstances = { workspace.Live, workspace.Debris }
GroundSnapParams.IgnoreWater = true

local CAM_STREAM_DURATION = AIM_DURATION + 2

local PUNCH_HOLD_TIME = 2

local FINAL_HITBOX_SIZE = Vector3.new(300, 300, 300)
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
	Cooldown = 20,
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

		Character:AddTag("CantRotate")

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

		local backTween
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
			if backTween then
				backTween:Cancel()
				backTween = nil
			end
			if camPartActive then
				camPartActive = false
				RemoteManager.FireClient(Player, "ReplicateTask", "CustomCamPart", { func = "Stop" })
			end
			SkillCollision:Unlock(Character)
			Character:RemoveTag("CantRotate")

			stopRotation()

			if isAirborne then
				if HumRP and HumRP.Parent then
					restoreGroundControl(Humanoid, HumRP)
				end
				isAirborne = false
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
		backTween = TweenService:Create(HumRP, TweenInfo.new(BACK_TWEEN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = backTarget,
		})
		backTween:Play()

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

				task.wait(CHARGE_MARKER_DELAY)

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

					local rawTarget
					if ray then
						rawTarget = ray.Position
					else
						rawTarget = origin + aimDirection * AIM_RANGE
					end

					local groundRay = workspace:Raycast(
						rawTarget + Vector3.new(0, 300, 0),
						Vector3.new(0, -1000, 0),
						GroundSnapParams
					)
					targetPosition = groundRay and groundRay.Position or rawTarget

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

				local camPartPosition = targetPosition + Vector3.new(200, 0, 0)

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
				})

				UserTrack:AdjustSpeed(0)

				task.delay(PUNCH_HOLD_TIME, function()
					if cancelled or not Character.Parent then
						return
					end

					if UserTrack and UserTrack.IsPlaying then
						UserTrack:AdjustSpeed(1)
					end

					RemoteManager.FireAllClients("ReplicateTask", "OblivionFists", {
						func = "MoveToTarget",
						char = Character,
						targetPosition = targetPosition,
					})

					RemoteManager.FireAllClients("ReplicateTask", "OblivionExplosion", { position = targetPosition })
					SFXModule:Play("EclipseImpact", targetPosition)

					RemoteManager.FireClient(Player, "ReplicateTask", "CustomCamPart", { func = "Stop" })

					RemoteManager.FireClient(Player, "ReplicateTask", "CustomCamPart", {
						func = "Start",
						position = HumRP.Position + Vector3.new(0, 50, 500),
						lookTarget = Character,
					})

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

					task.delay(1, function()
						if camPartActive then
							camPartActive = false
							RemoteManager.FireClient(Player, "ReplicateTask", "CustomCamPart", { func = "Stop" })
						end
					end)

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

				if Character and Character.Parent and HumRP and HumRP.Parent then
					if isAirborne then
						HumRP.CFrame = CFrame.new(OriginPosition, OriginPosition + HumRP.CFrame.LookVector)
						HumRP.AssemblyLinearVelocity = Vector3.zero
					end
					RemoteManager.FireAllClients("ReplicateTask", "ShatteredImpact", { char = Character })
				end

				cleanup()
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
