local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ServerModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local AnimationService = require(ServerModules.AnimationService)
local SkillCancelHandler = require(ServerModules.SkillCancelHandler)
local iFramesService = require(ServerModules.iFramesService)
local RagdollHandler = require(ServerModules.RagdollHandler)
local PerfectKnockback = require(ServerModules.PerfectKnockback)

local MoveAnims = ServerStorage.Assets.Animations.Moves

local STOMP_HITBOX_SIZE = Vector3.new(22, 14, 22)
local STOMP_HITBOX_OFFSET = CFrame.new(0, 0, -6)
local STOMP_DAMAGE = 8
local RAGDOLL_TIME = 6

local LAUNCH_HEIGHT = 45
local LAUNCH_FORWARD = 30
local LAUNCH_UP_TIME = 0.25
local LAUNCH_FORWARD_TIME = 0.25

local PUNCH_DAMAGE = 18
local PUNCH_DOWN_FORCE = -30
local PUNCH_FORWARD_FORCE = 25
local PUNCH_FINAL_FORCE = 40
local PUNCH_GROUND_STUN = 2
local PUNCH_UP_VELOCITY_TIME = 0.18
local PUNCH_FALLING_DELAY = 0.3

return {
	Cooldown = 1,
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

		local UserAnimation = MoveAnims.Shattered.Combo
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		if not UserTrack then
			StunHandler:Unstun(Character, Stun)
			return
		end

		local Cancelled = false
		local CasterAirborne = false
		local Victims = {}

		local onDamageCancel

		local function unlockCaster()
			if not CasterAirborne then
				return
			end
			CasterAirborne = false

			Humanoid.PlatformStand = false
			Humanoid.AutoRotate = true
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)

			if HumRP and HumRP.Parent then
				HumRP.Anchored = false
			end

			Character:RemoveTag("CantRotate")
		end

		local function releaseVictim(Entry, Unanchor)
			local EnemyCharacter = Entry.Character
			if not EnemyCharacter or not EnemyCharacter.Parent then
				return
			end

			EnemyCharacter:RemoveTag("CantRotate")

			if Unanchor and Entry.HumRP and Entry.HumRP.Parent then
				Entry.HumRP.Anchored = false
				Entry.HumRP.AssemblyLinearVelocity = Vector3.zero
			end
		end

		local function cleanupAll()
			unlockCaster()

			for _, Entry in Victims do
				releaseVictim(Entry, true)
			end

			iFramesService:RemoveiFrames(Character, "Base")
			StunHandler:Unstun(Character, Stun)
			SkillCancelHandler:Unregister(Character, onDamageCancel)
		end

		onDamageCancel = function()
			if Cancelled then
				return
			end
			Cancelled = true

			if UserTrack and UserTrack.IsPlaying then
				UserTrack:Stop()
			end

			cleanupAll()
		end

		SkillCancelHandler:Register(Character, onDamageCancel)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("stomp"):Once(function()
				if Cancelled then
					return
				end

				RemoteManager.FireAllClients("ReplicateTask", "Ring", {
					FirstProps = { Size = Vector3.new(0.6, 4, 0.6), Transparency = 0 },
					CF = HumRP.CFrame * CFrame.new(0, -1, -3),
					TN_Info = { Time = 0.35, Style = "Quad", Direction = "Out" },
					FinalProps = { Size = Vector3.new(24, 4, 24), Transparency = 1 },
				})

				RemoteManager.FireAllClients("ReplicateTask", "Ground Crater", {
					Seed = math.random(1, 2147483647),
					start = HumRP.Position + Vector3.new(0, 0.1, 0),
					["end"] = Vector3.new(0, -18, 0),
					amount = 20,
					rings = 2,
					ringSpacing = 10,
					ringSizeGrowth = 1.4,
					ringGap = 0.2,
					outwardTilt = true,
					debrisSizeMin = 4,
					debrisSizeMax = 10,
					debrisHeightMin = 3,
					debrisHeightMax = 6,
					sizemult = 1.2,
				})

				RemoteManager.FireAllClients("ReplicateTask", "smokeEffect", { time = 0.75, char = Character })
				RemoteManager.FireClient(Player, "ReplicateTask", "ShakeCamera", { Intensity = 6, Last = 0.5 })

				iFramesService:AddiFrames(Character, "Base")

				local HitList = {}

				HitboxHandler:SimpleOnce(
					HumRP,
					STOMP_HITBOX_SIZE,
					STOMP_HITBOX_OFFSET,
					{ Character },
					"Box",
					nil,
					function(EnemyCharacter)
						if HitList[EnemyCharacter] then
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

						HitList[EnemyCharacter] = true

						DamageHandler:TakeDamage(
							Character,
							EnemyHumanoid,
							STOMP_DAMAGE,
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

						if EnemyHumanoid.Health <= 0 then
							return
						end

						if EnemyCharacter:HasTag("Ragdolled") then
							RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, false, true, true)
						end

						RagdollHandler.ragdoll(EnemyHumanoid, RAGDOLL_TIME, false)

						EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
						EnemyHumRP.AssemblyAngularVelocity = Vector3.zero
						EnemyHumRP.Anchored = true

						EnemyCharacter:AddTag("CantRotate")

						table.insert(
							Victims,
							{ Character = EnemyCharacter, Humanoid = EnemyHumanoid, HumRP = EnemyHumRP }
						)
					end
				)

				Humanoid.AutoRotate = false
				Humanoid.PlatformStand = true
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
				Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
				Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

				HumRP.AssemblyLinearVelocity = Vector3.zero
				HumRP.Anchored = true
				Character:AddTag("CantRotate")
				CasterAirborne = true

				local LookFlat = HumRP.CFrame.LookVector
				LookFlat = Vector3.new(LookFlat.X, 0, LookFlat.Z)
				LookFlat = LookFlat.Magnitude > 0.001 and LookFlat.Unit or Vector3.new(0, 0, -1)

				local CasterUpTarget = HumRP.CFrame + Vector3.new(0, LAUNCH_HEIGHT, 0)

				local CasterUpTween = TweenService:Create(
					HumRP,
					TweenInfo.new(LAUNCH_UP_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ CFrame = CasterUpTarget }
				)

				CasterUpTween.Completed:Once(function()
					if Cancelled or not HumRP.Parent then
						return
					end

					local CasterForwardTarget = HumRP.CFrame + LookFlat * LAUNCH_FORWARD

					TweenService:Create(
						HumRP,
						TweenInfo.new(LAUNCH_FORWARD_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ CFrame = CasterForwardTarget }
					):Play()
				end)

				for _, Entry in Victims do
					if Entry.HumRP and Entry.HumRP.Parent then
						local VictimHumRP = Entry.HumRP
						local VictimUpTarget = VictimHumRP.CFrame + Vector3.new(0, LAUNCH_HEIGHT, 0)

						local VictimUpTween = TweenService:Create(
							VictimHumRP,
							TweenInfo.new(LAUNCH_UP_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{ CFrame = VictimUpTarget }
						)

						VictimUpTween.Completed:Once(function()
							if Cancelled or not VictimHumRP.Parent then
								return
							end

							local VictimForwardTarget = VictimHumRP.CFrame + LookFlat * LAUNCH_FORWARD

							TweenService:Create(
								VictimHumRP,
								TweenInfo.new(LAUNCH_FORWARD_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{ CFrame = VictimForwardTarget }
							):Play()
						end)

						VictimUpTween:Play()
					end
				end

				task.delay(0.5, function()
					if Cancelled then
						return
					end
					CasterUpTween:Play()
				end)
			end)
		)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("punch"):Once(function()
				if Cancelled then
					return
				end

				RemoteManager.FireAllClients("ReplicateTask", "Ring", {
					FirstProps = { Size = Vector3.new(0.6, 4, 0.6), Transparency = 0 },
					CF = HumRP.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(math.rad(90), 0, 0),
					TN_Info = { Time = 0.3, Style = "Quad", Direction = "Out" },
					FinalProps = { Size = Vector3.new(16, 4, 16), Transparency = 1 },
				})

				RemoteManager.FireClient(Player, "ReplicateTask", "ShakeCamera", { Intensity = 9, Last = 0.6 })
				RemoteManager.FireAllClients("ReplicateTask", "smokeEffect", { time = 0.6, char = Character })

				unlockCaster()

				local LookFlat = HumRP.CFrame.LookVector
				LookFlat = Vector3.new(LookFlat.X, 0, LookFlat.Z)
				LookFlat = LookFlat.Magnitude > 0.001 and LookFlat.Unit or Vector3.new(0, 0, -1)

				for _, Entry in Victims do
					local EnemyCharacter = Entry.Character
					local EnemyHumanoid = Entry.Humanoid
					local EnemyHumRP = Entry.HumRP

					releaseVictim(Entry, false)

					if
						not EnemyCharacter
						or not EnemyCharacter.Parent
						or not EnemyHumanoid
						or EnemyHumanoid.Health <= 0
					then
						continue
					end
					if not EnemyHumRP or not EnemyHumRP.Parent then
						continue
					end

					DamageHandler:TakeDamage(
						Character,
						EnemyHumanoid,
						PUNCH_DAMAGE,
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

					if EnemyHumanoid.Health <= 0 then
						continue
					end

					EnemyHumRP.Anchored = false
					EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
					EnemyHumRP.AssemblyAngularVelocity = Vector3.zero

					local lookCF = CFrame.lookAt(EnemyHumRP.Position, EnemyHumRP.Position + LookFlat)

					PerfectKnockback:KnockBack(nil, EnemyCharacter, {
						LookVector = LookFlat,
						LookForce = PUNCH_FORWARD_FORCE,
						LookFinalForce = PUNCH_FINAL_FORCE,
						LookAt = lookCF,
						UpVelocity = Vector3.new(0, PUNCH_DOWN_FORCE, 0),
						UpVelocityTime = PUNCH_UP_VELOCITY_TIME,
						GroundStunTime = PUNCH_GROUND_STUN,
						FallingDetectDelay = PUNCH_FALLING_DELAY,
						Dot = 1,
						DontFreeze = false,
						Escapable = true,
					}, Character)

					local EnemyPlayer = game:GetService("Players"):GetPlayerFromCharacter(EnemyCharacter)
					if EnemyPlayer then
						RemoteManager.FireClient(
							EnemyPlayer,
							"ReplicateTask",
							"ShakeCamera",
							{ Intensity = 10, Last = 0.6 }
						)
					end
				end

				Victims = {}

				iFramesService:RemoveiFrames(Character, "Base")
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			if not Cancelled then
				cleanupAll()
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
