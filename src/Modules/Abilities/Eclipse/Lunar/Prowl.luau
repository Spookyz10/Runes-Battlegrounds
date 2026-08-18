local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local SFXModule = require(ReplicatedStorage.Shared.Modules.SFXModule)
local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local SkillCancelHandler = require(ServerModules.SkillCancelHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local PerfectKnockback = require(ServerModules.PerfectKnockback)

local MoveAnims = ServerStorage.Assets.Animations.Moves

local HIT_DAMAGE = { 3, 3 }
local PUNCH_DAMAGE = 5

local HIT_SIZE = Vector3.new(8, 8, 9)
local HIT_OFFSET = CFrame.new(0, 0, -4.5)

local PUNCH_SIZE = Vector3.new(9, 9, 9)
local PUNCH_OFFSET = CFrame.new(0, 0, -4)

local BLOCK_SLOW_SPEED = 0.5
local BLOCK_SLOW_TIME = 1

local HIT_SOUNDS = { "prowlHit1", "prowlHit2", "prowlHit3" }

return {
	Cooldown = 15,
	Start = function(Player, Tool)
		local Character = Player.Character
		local HumRP = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)

		local UserAnimation = MoveAnims.Eclipse.Lunar["Prowl"]
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		local cancelled = false
		local punchVFXStarted = false
		local punchVFXEnded = false

		local function endPunchVFX()
			if punchVFXStarted and not punchVFXEnded then
				punchVFXEnded = true
				RemoteManager.FireAllClients("ReplicateTask", "ProwlPunch", {
					func = "End",
					Char = Character,
				})
			end
		end

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

		local hitSoundIndex = 1

		for i = 1, 2 do
			local markerName = "hit" .. i
			table.insert(
				UserEvents,
				UserTrack:GetMarkerReachedSignal(markerName):Once(function()
					local localHitList = {}
					RemoteManager.FireAllClients("ReplicateTask", "ProwlHit", {
						Index = i,
						Char = Character,
					})

					local soundName = HIT_SOUNDS[hitSoundIndex]
					if soundName and HumRP then
						SFXModule:Play(soundName, HumRP)
					end

					HitboxHandler:SimpleOnce(
						HumRP,
						HIT_SIZE,
						HIT_OFFSET,
						{ Character },
						nil,
						nil,
						function(EnemyCharacter)
							if table.find(localHitList, EnemyCharacter) then
								return
							end

							local EnemyHumanoid = EnemyCharacter.Humanoid
							if iFramesService:HasiFrame(EnemyCharacter, 1) then
								return
							end
							if EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then
								return
							end
							if EnemyCharacter:HasTag("Ragdolled") then
								return
							end

							table.insert(localHitList, EnemyCharacter)

							local HitInfo = DamageHandler:TakeDamage(
								Character,
								EnemyHumanoid,
								HIT_DAMAGE[i] or 3,
								nil,
								nil,
								true,
								true,
								true,
								true,
								false,
								nil,
								nil
							)

							if HitInfo.Countered then
								return
							end

							if HitInfo.Blocked then
								if UserTrack then
									UserTrack:AdjustSpeed(BLOCK_SLOW_SPEED)
									task.delay(BLOCK_SLOW_TIME, function()
										if UserTrack and UserTrack.IsPlaying then
											UserTrack:AdjustSpeed(1)
										end
									end)
								end
								return
							end

							hitSoundIndex = hitSoundIndex + 1
							if hitSoundIndex > #HIT_SOUNDS then
								hitSoundIndex = 1
							end

							StunHandler:Stun(EnemyCharacter, 1, true, 0, 0, true)

							local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)
							if EnemyPlayer then
								RemoteManager.FireClient(
									EnemyPlayer,
									"ReplicateTask",
									"ShakeCamera",
									{ Intensity = 1.5 }
								)
							end
						end
					)

					if i == 2 then
						task.delay(0.2, function()
							if cancelled or punchVFXEnded then
								return
							end
							punchVFXStarted = true
							RemoteManager.FireAllClients("ReplicateTask", "ProwlPunch", {
								func = "Start",
								Char = Character,
							})
						end)
					end
				end)
			)
		end

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("punch"):Once(function()
				local HitList = {}

				SFXModule:Play("prowlHit3", HumRP)

				HitboxHandler:SimpleOnce(
					HumRP,
					PUNCH_SIZE,
					PUNCH_OFFSET,
					{ Character },
					nil,
					nil,
					function(EnemyCharacter)
						if table.find(HitList, EnemyCharacter) then
							return
						end

						local EnemyHumanoid = EnemyCharacter.Humanoid
						local EnemyHumRP = EnemyCharacter.HumanoidRootPart
						local EnemyPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)

						if EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then
							return
						end
						if EnemyCharacter:HasTag("Ragdolled") then
							return
						end
						if iFramesService:HasiFrame(EnemyCharacter, 1) then
							return
						end

						table.insert(HitList, EnemyCharacter)

						local HitInfo = DamageHandler:TakeDamage(
							Character,
							EnemyHumanoid,
							PUNCH_DAMAGE,
							nil,
							nil,
							false,
							false,
							true,
							true,
							true,
							nil,
							nil
						)

						if HitInfo.Countered or HitInfo.Blocked then
							return
						end

						EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

						local lookFlat = HumRP.CFrame.LookVector
						lookFlat = Vector3.new(lookFlat.X, 0, lookFlat.Z).Unit

						PerfectKnockback:KnockBack(nil, EnemyCharacter, {
							LookVector = lookFlat,
							LookForce = 30,
							LookFinalForce = 25,
							LookAt = CFrame.lookAt(EnemyHumRP.Position, EnemyHumRP.Position + lookFlat),
							UpVelocity = Vector3.new(0, 50, 0),
							UpVelocityTime = 0.15,
							GroundStunTime = 1.0,
							FallingDetectDelay = 0.3,
							Dot = 1,
							DontFreeze = false,
							Escapable = true,
						}, Character)

						if EnemyPlayer then
							RemoteManager.FireClient(
								EnemyPlayer,
								"ReplicateTask",
								"ShakeCamera",
								{ Intensity = 10, Last = 0.6 }
							)
						end
					end
				)

				endPunchVFX()

				RemoteManager.FireClient(Player, "ReplicateTask", "ShakeCamera", { Intensity = 8, Last = 0.5 })
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			endPunchVFX()

			SkillCancelHandler:Unregister(Character, onDamageCancel)
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
