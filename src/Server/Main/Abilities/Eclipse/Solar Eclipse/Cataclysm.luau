local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local ServerModules = ServerStorage.Modules
local ReplicatedModules = ReplicatedStorage.Shared.Modules

local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local iFramesService = require(ServerModules.iFramesService)
local HitboxHandler = require(ServerModules.HitboxHandler)
local AnimationService = require(ServerModules.AnimationService)
local RagdollHandler = require(ServerModules.RagdollHandler)
local BodymoverService = require(ServerModules.BodymoverService)

local Freeze = require(ReplicatedModules.Utility.Freeze)

local MoveAnims = ServerStorage.Assets.Animations.Moves
local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set
local CutscenesSet = ReplicatedStorage.Remotes.Cutscenes.Set

local WindupAnimation = MoveAnims.Eclipse.Solar.Awakening["Cataclysm Windup"]
local UserAnimation = MoveAnims.Eclipse.Solar.Awakening.Cataclysm
local VictimAnimation = MoveAnims.Eclipse.Solar.Awakening["Cataclysm Victim"]

local GRAB_HITBOX_SIZE = Vector3.new(7, 10, 8)
local GRAB_HITBOX_OFFSET = CFrame.new(0, 0, -6)

local MISS_WAIT_TIME = 3

local VICTIM_DAMAGE = 40
local VICTIM_TWEEN_DISTANCE = 12
local VICTIM_TWEEN_TIME = 0.45

local SPLASH_FORWARD_DISTANCE = 30
local SPLASH_HITBOX_SIZE = Vector3.new(500, 500, 500)
local SPLASH_DAMAGE = 30
local SPLASH_KNOCKUP_FORCE = 300
local SPLASH_RAGDOLL_TIME = 10

local WALKSPEED_FREEZE_DELAY = 0.2

return {
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

		local OriginalWalkSpeed = Humanoid.WalkSpeed

		local CasterStun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		Humanoid.WalkSpeed = 0

		local CasterLock = nil
		local FreezeDelayThread = task.delay(WALKSPEED_FREEZE_DELAY, function()
			CasterLock = Freeze.Lock(Character)
		end)

		local HitCharacter = nil
		local VictimStun = nil
		local VictimLock = nil
		local Cleaned = false

		local function cleanupCaster()
			if Cleaned then
				return
			end
			Cleaned = true

			if FreezeDelayThread then
				task.cancel(FreezeDelayThread)
				FreezeDelayThread = nil
			end

			if CasterLock then
				Freeze.Release(Character, CasterLock, true)
				CasterLock = nil
			end

			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, CasterStun)

			if Humanoid and Humanoid.Parent then
				Humanoid.WalkSpeed = OriginalWalkSpeed
				Humanoid.AutoRotate = true
			end
		end

		local function cleanupVictim()
			if not HitCharacter or not HitCharacter.Parent then
				return
			end

			if VictimLock then
				Freeze.Release(HitCharacter, VictimLock, true)
				VictimLock = nil
			end

			if VictimStun then
				StunHandler:Unstun(HitCharacter, VictimStun)
				VictimStun = nil
			end
		end

		local function startCutscene()
			CutscenesSet:FireClient(Player, "Cataclysm", "Start", { Offset = CFrame.new(0, -6, 0), goalPart = HumRP })

			if HitCharacter and HitCharacter.Parent then
				local VictimPlayer = Players:GetPlayerFromCharacter(HitCharacter)
				if VictimPlayer then
					CutscenesSet:FireClient(
						VictimPlayer,
						"Cataclysm",
						"Start",
						{ Offset = CFrame.new(0, -6, 0), goalPart = HumRP }
					)
				end
			end
		end

		local function playMainAnimation()
			if not Character.Parent or Humanoid.Health <= 0 then
				cleanupCaster()
				return
			end

			local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)
			if not UserTrack then
				cleanupCaster()
				cleanupVictim()
				return
			end

			table.insert(
				UserEvents,
				UserTrack:GetMarkerReachedSignal("jump"):Connect(function()
					ReplicateSet:FireAllClients("SolarImpact", { char = Character })
				end)
			)

			table.insert(
				UserEvents,
				UserTrack:GetMarkerReachedSignal("hit"):Once(function()
					if not HitCharacter or not HitCharacter.Parent then
						return
					end

					local EnemyHumanoid = HitCharacter:FindFirstChild("Humanoid")
					if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then
						return
					end

					ReplicateSet:FireAllClients("SolarHit", { char = Character })
					ReplicateSet:FireAllClients("Cataclysm", { char = Character })

					DamageHandler:TakeDamage(
						Character,
						EnemyHumanoid,
						VICTIM_DAMAGE,
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

					local EnemyPlayer = Players:GetPlayerFromCharacter(HitCharacter)
					if EnemyPlayer then
						ReplicateSet:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 6, Last = 0.5 })
					end

					local SplashCFrame = HumRP.CFrame * CFrame.new(0, 0, -SPLASH_FORWARD_DISTANCE)
					local SplashHitList = { HitCharacter }

					HitboxHandler:SimpleOnce(
						SplashCFrame,
						SPLASH_HITBOX_SIZE,
						CFrame.new(0, 0, 0),
						{ Character },
						"Box",
						nil,
						function(SplashCharacter)
							if table.find(SplashHitList, SplashCharacter) then
								return
							end

							local SplashHumanoid = SplashCharacter:FindFirstChild("Humanoid")
							local SplashHumRP = SplashCharacter:FindFirstChild("HumanoidRootPart")
							if not SplashHumanoid or not SplashHumRP then
								return
							end
							if
								SplashHumanoid.Health <= 0
								or SplashHumanoid:GetState() == Enum.HumanoidStateType.Dead
							then
								return
							end
							if iFramesService:HasiFrame(SplashCharacter, Tool.Name) then
								return
							end

							table.insert(SplashHitList, SplashCharacter)

							DamageHandler:TakeDamage(
								Character,
								SplashHumanoid,
								SPLASH_DAMAGE,
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

							SplashHumRP.AssemblyLinearVelocity = Vector3.zero

							RagdollHandler.ragdoll(SplashHumanoid, SPLASH_RAGDOLL_TIME, nil, nil, nil, nil, true)

							task.defer(function()
								if not SplashCharacter or not SplashCharacter.Parent then
									return
								end
								BodymoverService:Knockback(SplashCharacter, {
									KnockbackType = "Velocity",
									MaxForce = Vector3.new(1, 100000, 1),
									Velocity = Vector3.new(0, SPLASH_KNOCKUP_FORCE, 0),
								})
							end)

							ServerStorage.Bindables.AirDetector:Fire(SplashCharacter, nil, true)

							local SplashPlayer = Players:GetPlayerFromCharacter(SplashCharacter)
							if SplashPlayer then
								ReplicateSet:FireClient(SplashPlayer, "ShakeCamera", { Intensity = 8, Last = 0.6 })
							end
						end
					)
				end)
			)

			table.insert(
				UserEvents,
				UserTrack:GetMarkerReachedSignal("landed"):Once(function()
					ReplicateSet:FireAllClients("SolarImpact", { char = Character })
				end)
			)

			UserTrack.Stopped:Once(function()
				for _, v in UserEvents do
					v:Disconnect()
				end

				cleanupCaster()
				cleanupVictim()
			end)

			AnimationService:stopAll(Character)
			AnimationService:playAnimation(Character, UserAnimation)
		end

		local function grabVictim(Tool)
			local FoundVictim = nil

			HitboxHandler:SimpleOnce(
				HumRP,
				GRAB_HITBOX_SIZE,
				GRAB_HITBOX_OFFSET,
				{ Character },
				"Box",
				"Single",
				function(EnemyCharacter)
					local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
					local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
					if not EnemyHumanoid or not EnemyHumRP then
						return
					end
					if EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then
						return
					end
					if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
						return
					end

					FoundVictim = EnemyCharacter
				end
			)

			if not FoundVictim then
				task.delay(MISS_WAIT_TIME, cleanupCaster)
				return
			end

			HitCharacter = FoundVictim

			startCutscene()

			local EnemyHumanoid = HitCharacter.Humanoid
			local EnemyHumRP = HitCharacter.HumanoidRootPart

			if HitCharacter:HasTag("Ragdolled") then
				RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, false, true, true)
			end

			VictimStun = StunHandler:Stun(HitCharacter, nil, true, 0, 0, true)
			VictimLock = Freeze.Lock(HitCharacter)

			EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
			EnemyHumRP.AssemblyAngularVelocity = Vector3.zero

			AnimationService:stopAll(HitCharacter)
			AnimationService:playAnimation(HitCharacter, VictimAnimation)

			local lookFlat = HumRP.CFrame.LookVector
			lookFlat = Vector3.new(lookFlat.X, 0, lookFlat.Z)
			if lookFlat.Magnitude > 0.001 then
				lookFlat = lookFlat.Unit
			else
				lookFlat = Vector3.new(0, 0, -1)
			end

			local targetPosition = HumRP.Position + lookFlat * VICTIM_TWEEN_DISTANCE
			local targetCFrame = CFrame.new(targetPosition, targetPosition + lookFlat)

			Freeze.Release(HitCharacter, VictimLock, true)
			VictimLock = nil

			local VictimTween = TweenService:Create(
				EnemyHumRP,
				TweenInfo.new(VICTIM_TWEEN_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{ CFrame = targetCFrame }
			)

			VictimTween.Completed:Once(function(state)
				if not HitCharacter or not HitCharacter.Parent then
					return
				end
				if state ~= Enum.PlaybackState.Completed then
					return
				end

				VictimLock = Freeze.Lock(HitCharacter)
			end)

			VictimTween:Play()

			playMainAnimation()
		end

		local WindupTrack, WindupEvents = AnimationService:getAnimationTrack(Character, WindupAnimation)
		if not WindupTrack then
			cleanupCaster()
			return
		end

		table.insert(
			WindupEvents,
			WindupTrack:GetMarkerReachedSignal("hit"):Once(function()
				grabVictim(Tool)
			end)
		)

		WindupTrack.Stopped:Once(function()
			for _, v in WindupEvents do
				v:Disconnect()
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, WindupAnimation)
	end,
}
