local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local ServerModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local SFXModule = require(ReplicatedStorage.Shared.Modules.SFXModule)
local StunHandler = require(ServerModules.StunHandler)
local AirDetectionService = require(ServerModules.AirDetectionService)
local DamageHandler = require(ServerModules.DamageHandler)
local iFramesService = require(ServerModules.iFramesService)
local HitboxHandler = require(ServerModules.HitboxHandler)
local AnimationService = require(ServerModules.AnimationService)
local RagdollHandler = require(ServerModules.RagdollHandler)
local BodymoverService = require(ServerModules.BodymoverService)

local MoveAnims = ServerStorage.Assets.Animations.Moves

local WindupAnimation = MoveAnims.Eclipse.Solar.Awakening["Cataclysm Windup"]
local UserAnimation = MoveAnims.Eclipse.Solar.Awakening.Cataclysm
local VictimAnimation = MoveAnims.Eclipse.Solar.Awakening["Cataclysm Victim"]

local GRAB_HITBOX_SIZE = Vector3.new(15, 30, 40)
local GRAB_HITBOX_OFFSET = CFrame.new(0, 0, -15)

local MISS_WAIT_TIME = 3

local VICTIM_DAMAGE = 40
local VICTIM_TWEEN_DISTANCE = 7
local VICTIM_TWEEN_TIME = 0.45

local SPLASH_FORWARD_DISTANCE = 30
local SPLASH_HITBOX_SIZE = Vector3.new(500, 500, 500)
local SPLASH_DAMAGE = 30
local SPLASH_KNOCKUP_FORCE = 300
local SPLASH_RAGDOLL_TIME = 3
local SPLASH_KNOCKUP_BODY_TIME = 0.3

local WALKSPEED_FREEZE_DELAY = 0.2

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

		local OriginalWalkSpeed = Humanoid.WalkSpeed

		local CasterStun = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)
		iFramesService:AddStrongiFrames(Character)

		Humanoid.WalkSpeed = 0

		local CasterLocked = false
		local FreezeDelayThread = task.delay(WALKSPEED_FREEZE_DELAY, function()
			CasterLocked = true
			Character:AddTag("CantRotate")
			HumRP.Anchored = true
		end)

		local HitCharacter = nil
		local VictimStun = nil
		local VictimLocked = false
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

			if CasterLocked then
				Character:RemoveTag("CantRotate")
				HumRP.Anchored = false
				CasterLocked = false
			end

			RemoteManager.FireAllClients("ReplicateTask", "CataclysmWindup", { func = "Stop", char = Character })
			iFramesService:RemoveiFrames(Character, "Strong")
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

			if VictimLocked then
				HitCharacter:RemoveTag("CantRotate")
				local VictimHumRP = HitCharacter:FindFirstChild("HumanoidRootPart")
				if VictimHumRP then
					VictimHumRP.Anchored = false
				end
				VictimLocked = false
			end

			if VictimStun then
				StunHandler:Unstun(HitCharacter, VictimStun)
				VictimStun = nil
			end
		end

		local function startCutscene()
			RemoteManager.FireClient(
				Player,
				"Cutscenes",
				"Cataclysm",
				"Start",
				{ Offset = CFrame.new(0, -6, 0), goalPart = HumRP }
			)

			if HitCharacter and HitCharacter.Parent then
				local VictimPlayer = Players:GetPlayerFromCharacter(HitCharacter)
				if VictimPlayer then
					RemoteManager.FireClient(
						VictimPlayer,
						"Cutscenes",
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
					RemoteManager.FireAllClients("ReplicateTask", "SolarImpact", { char = Character })
					SFXModule:Play("EclipseImpact", HumRP.Position)
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

					RemoteManager.FireAllClients("ReplicateTask", "SolarHit", { char = Character })
					RemoteManager.FireAllClients("ReplicateTask", "Cataclysm", { char = Character })
					SFXModule:Play("Cataclysm", HumRP.Position)

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
						RemoteManager.FireClient(
							EnemyPlayer,
							"ReplicateTask",
							"ShakeCamera",
							{ Intensity = 6, Last = 0.5 }
						)
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
							if iFramesService:HasiFrame(SplashCharacter, 2) then
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
							SplashHumRP.AssemblyAngularVelocity = Vector3.zero

							pcall(function()
								SplashHumRP:SetNetworkOwner(nil)
							end)

							RagdollHandler.ragdoll(SplashHumanoid, SPLASH_RAGDOLL_TIME, nil, nil, nil, nil, true)

							task.defer(function()
								if not SplashCharacter or not SplashCharacter.Parent then
									return
								end
								if not SplashHumRP or not SplashHumRP.Parent then
									return
								end

								SplashHumRP.AssemblyLinearVelocity = Vector3.zero
								SplashHumRP.AssemblyAngularVelocity = Vector3.zero

								BodymoverService:Knockback(SplashCharacter, {
									KnockbackType = "Velocity",
									MaxForce = Vector3.new(1, 100000, 1),
									Velocity = Vector3.new(0, SPLASH_KNOCKUP_FORCE, 0),
									Time = SPLASH_KNOCKUP_BODY_TIME,
								})
							end)

							AirDetectionService:Start(SplashCharacter, {
								ragdoll = true,
							})

							local SplashPlayer = Players:GetPlayerFromCharacter(SplashCharacter)
							if SplashPlayer then
								RemoteManager.FireClient(
									SplashPlayer,
									"ReplicateTask",
									"ShakeCamera",
									{ Intensity = 8, Last = 0.6 }
								)
							end
						end
					)

					local HitCharacterForDelay = HitCharacter
					task.delay(1, function()
						if not HitCharacterForDelay or not HitCharacterForDelay.Parent then
							return
						end

						AnimationService:stopAll(HitCharacterForDelay)

						local VictimHumRP = HitCharacterForDelay:FindFirstChild("HumanoidRootPart")
						local VictimTorso = HitCharacterForDelay:FindFirstChild("Torso")
						local CasterTorso = Character and Character.Parent and Character:FindFirstChild("Torso")

						if VictimHumRP and VictimTorso and CasterTorso then
							VictimHumRP.CFrame = CFrame.new(
								Vector3.new(VictimTorso.Position.X, VictimHumRP.Position.Y, CasterTorso.Position.Z)
							)
						end
					end)
				end)
			)

			table.insert(
				UserEvents,
				UserTrack:GetMarkerReachedSignal("landed"):Once(function()
					RemoteManager.FireAllClients("ReplicateTask", "SolarImpact", { char = Character })
					SFXModule:Play("EclipseImpact", HumRP.Position)
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

			SFXModule:Play("CataclysmStartup", HumRP)
			RemoteManager.FireAllClients(
				"ReplicateTask",
				"CataclysmWindup",
				{ CFrame = HumRP.CFrame + Vector3.new(0, -3, -3) }
			)

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
					if iFramesService:HasiFrame(EnemyCharacter, 2) then
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
			HitCharacter:AddTag("CantRotate")
			EnemyHumRP.Anchored = true
			VictimLocked = true

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

			EnemyHumRP.Anchored = false

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
				if VictimLocked then
					EnemyHumRP.Anchored = true
				end
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
