local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local SkillCancelHandler = require(ServerModules.SkillCancelHandler)
local CounterHandler = require(ServerModules.CounterHandler)
local CombatEvents = require(ServerModules.CombatEvents)
local iFramesService = require(ServerModules.iFramesService)
local RagdollHandler = require(ServerModules.RagdollHandler)
local SkillCollision = require(ServerModules.SkillCollision)

local MoveAnims = ServerStorage.Assets.Animations.Moves

local COUNTER_TIER = 1
local WINDOW_HOLD_AFTER_FREEZE = 1
local EXTRA_STUN_TIME = 2
local MAX_COUNTER_DISTANCE = 20

local SLAM_DAMAGE = 20
local VICTIM_BACK_OFFSET = 5
local VICTIM_DOWN_OFFSET = 3
local SLAM_FREEZE_TIME = 0.1
local SLAM_RAGDOLL_TIME = 3
local PARRY_ANIM_SPEED = 1.5

return {
	Cooldown = 8,
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

		local UserAnimation = MoveAnims.Shattered.parryStart
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		if not UserTrack then
			StunHandler:Unstun(Character, Stun)
			return
		end

		local cancelled = false
		local hitHappened = false

		local counterToken = nil
		local counterConn = nil

		local AttackerCharacter, AttackerHumanoid, AttackerHumRP, AttackerPlayer
		local CasterActionTrack, CasterActionEvents = nil, nil
		local VictimTrack, VictimEvents = nil, nil
		local VictimStun = nil
		local slamActive = false
		local pendingCleanup = false

		local function stopCountering()
			if counterToken then
				CounterHandler:StopCounter(Character, counterToken)
				counterToken = nil
			end
			if counterConn then
				counterConn:Disconnect()
				counterConn = nil
			end
		end

		local function cleanupVictim()
			if not AttackerCharacter or not AttackerCharacter.Parent then
				return
			end

			AttackerCharacter:RemoveTag("CantRotate")

			local vHumanoid = AttackerCharacter:FindFirstChild("Humanoid")
			if vHumanoid then
				vHumanoid.WalkSpeed = 16
			end

			local vHumRP = AttackerCharacter:FindFirstChild("HumanoidRootPart")
			if vHumRP and vHumRP.Parent then
				vHumRP.Anchored = false
				vHumRP.AssemblyLinearVelocity = Vector3.zero
				vHumRP.AssemblyAngularVelocity = Vector3.zero
			end

			if VictimTrack and VictimTrack.IsPlaying then
				VictimTrack:Stop()
			end

			iFramesService:RemoveiFrames(AttackerCharacter, "Base")
			SkillCollision:Unlock(AttackerCharacter)

			if VictimStun then
				StunHandler:Unstun(AttackerCharacter, VictimStun)
				VictimStun = nil
			end
		end

		local function cleanupCaster()
			Character:RemoveTag("CantRotate")
			iFramesService:RemoveiFrames(Character, "Base")
			StunHandler:Unstun(Character, Stun)
			SkillCollision:Unlock(Character)
		end

		local onDamageCancel
		onDamageCancel = function()
			if cancelled then
				return
			end
			cancelled = true

			stopCountering()

			if UserTrack and UserTrack.IsPlaying then
				UserTrack:Stop()
			end
			if CasterActionTrack and CasterActionTrack.IsPlaying then
				CasterActionTrack:Stop()
			end

			if hitHappened then
				cleanupVictim()
			end

			cleanupCaster()
		end

		SkillCancelHandler:Register(Character, onDamageCancel)

		local function beginParry(Attacker)
			if hitHappened or cancelled then
				return
			end
			hitHappened = true

			AttackerCharacter = Attacker
			AttackerHumanoid = Attacker:FindFirstChild("Humanoid")
			AttackerHumRP = Attacker:FindFirstChild("HumanoidRootPart")
			AttackerPlayer = Players:GetPlayerFromCharacter(Attacker)

			if not AttackerHumanoid or not AttackerHumRP then
				AttackerCharacter = nil
				hitHappened = false
				return
			end

			iFramesService:AddiFrames(Character, "Base")
			iFramesService:AddiFrames(AttackerCharacter, "Base")

			AttackerCharacter:AddTag("CantRotate")
			AttackerHumanoid.WalkSpeed = 0
			AttackerHumRP.AssemblyLinearVelocity = Vector3.zero
			AttackerHumRP.AssemblyAngularVelocity = Vector3.zero
			AttackerHumRP.CFrame = HumRP.CFrame
			AttackerHumRP.Anchored = true

			SkillCollision:Lock(Character)
			SkillCollision:Lock(AttackerCharacter)

			VictimStun = StunHandler:Stun(AttackerCharacter, nil, true, 0, 0, true)

			if UserTrack and UserTrack.IsPlaying then
				UserTrack:Stop()
			end

			CasterActionTrack, CasterActionEvents =
				AnimationService:getAnimationTrack(Character, MoveAnims.Shattered.parryCaster)
			VictimTrack, VictimEvents =
				AnimationService:getAnimationTrack(AttackerCharacter, MoveAnims.Shattered.parryVictim)

			if not CasterActionTrack or not VictimTrack then
				cleanupVictim()
				cleanupCaster()
				return
			end

			table.insert(
				CasterActionEvents,
				CasterActionTrack:GetMarkerReachedSignal("slam"):Once(function()
					if not AttackerCharacter or not AttackerCharacter.Parent then
						return
					end
					if not AttackerHumanoid or AttackerHumanoid.Health <= 0 then
						return
					end
					if not HumRP or not HumRP.Parent then
						return
					end

					DamageHandler:TakeDamage(
						Character,
						AttackerHumanoid,
						SLAM_DAMAGE,
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

					RemoteManager.FireAllClients("ReplicateTask", "SuplexSmoke", { EnemyChar = AttackerCharacter })

					local CraterCFrame = HumRP.CFrame * CFrame.new(0, -VICTIM_DOWN_OFFSET, VICTIM_BACK_OFFSET)

					RemoteManager.FireAllClients("ReplicateTask", "Ground Crater", {
						Seed = math.random(1, 2147483647),
						start = CraterCFrame,
						["end"] = Vector3.new(0, -24, 0),
						amount = 6,
						size = 0.3,
					})

					if Player then
						print("ShakeCamera for AttackerPlayer")
						RemoteManager.FireClient(Player, "ReplicateTask", "ShakeCamera", { Intensity = 4, Last = 0.3 })
					end

					slamActive = true

					if CasterActionTrack then
						CasterActionTrack:AdjustSpeed(0)
					end
					if VictimTrack then
						VictimTrack:AdjustSpeed(0)
					end

					local SlamAttacker = AttackerCharacter
					local SlamAttackerHumanoid = AttackerHumanoid
					local SlamAttackerHumRP = AttackerHumRP
					local SlamCasterHumRP = HumRP

					task.delay(SLAM_FREEZE_TIME, function()
						if not cancelled then
							if CasterActionTrack then
								CasterActionTrack:AdjustSpeed(PARRY_ANIM_SPEED)
							end
							if VictimTrack then
								VictimTrack:AdjustSpeed(PARRY_ANIM_SPEED)
							end

							if
								SlamAttacker
								and SlamAttacker.Parent
								and SlamAttackerHumRP
								and SlamAttackerHumRP.Parent
								and SlamCasterHumRP
								and SlamCasterHumRP.Parent
							then
								local TargetCFrame = SlamCasterHumRP.CFrame
									* CFrame.new(0, -VICTIM_DOWN_OFFSET, VICTIM_BACK_OFFSET)
								SlamAttackerHumRP.CFrame = CFrame.new(
									TargetCFrame.Position,
									TargetCFrame.Position - SlamCasterHumRP.CFrame.LookVector
								)
							end

							if SlamAttackerHumanoid and SlamAttackerHumanoid.Health > 0 then
								RagdollHandler.ragdoll(SlamAttackerHumanoid, SLAM_RAGDOLL_TIME, false)
							end
						end

						slamActive = false

						if pendingCleanup then
							pendingCleanup = false
							if not cancelled then
								cleanupVictim()
								cleanupCaster()
							end
						end
					end)
				end)
			)

			CasterActionTrack.Stopped:Once(function()
				for _, v in CasterActionEvents do
					v:Disconnect()
				end

				SkillCancelHandler:Unregister(Character, onDamageCancel)

				if cancelled then
					return
				end

				if slamActive then
					pendingCleanup = true
					return
				end

				cleanupVictim()
				cleanupCaster()
			end)

			VictimTrack.Stopped:Once(function()
				for _, v in VictimEvents do
					v:Disconnect()
				end
			end)

			AnimationService:stopAll(Character)
			AnimationService:playAnimation(Character, MoveAnims.Shattered.parryCaster, PARRY_ANIM_SPEED)

			AnimationService:stopAll(AttackerCharacter)
			AnimationService:playAnimation(AttackerCharacter, MoveAnims.Shattered.parryVictim, PARRY_ANIM_SPEED)
		end

		counterToken = CounterHandler:StartCounter(Character, COUNTER_TIER)

		counterConn = CombatEvents.Countered:Connect(function(Attacker, Defender, AttackTier)
			if Defender ~= Character or hitHappened or cancelled then
				return
			end

			if not Attacker or not Attacker.Parent then
				return
			end

			local AttackerHumRPCheck = Attacker:FindFirstChild("HumanoidRootPart")
			if not AttackerHumRPCheck then
				return
			end

			local Distance = (AttackerHumRPCheck.Position - HumRP.Position).Magnitude
			if Distance > MAX_COUNTER_DISTANCE then
				return
			end

			beginParry(Attacker)
		end)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("freeze"):Once(function()
				if cancelled then
					return
				end

				UserTrack:AdjustSpeed(0)

				task.delay(WINDOW_HOLD_AFTER_FREEZE, function()
					if cancelled then
						return
					end

					stopCountering()

					if not hitHappened then
						if UserTrack then
							UserTrack:AdjustSpeed(1)
						end
					else
						if
							AttackerCharacter
							and AttackerCharacter.Parent
							and AttackerHumanoid
							and AttackerHumanoid.Health > 0
						then
							StunHandler:Stun(AttackerCharacter, EXTRA_STUN_TIME, true, 0, 0, true)
						end
					end
				end)
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			stopCountering()

			if not hitHappened then
				SkillCancelHandler:Unregister(Character, onDamageCancel)
				cleanupCaster()
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
