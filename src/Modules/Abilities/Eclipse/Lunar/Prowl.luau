local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local RemotesContainer = ReplicatedStorage.Remotes

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local PerfectKnockback = require(ServerModules.PerfectKnockback)
local DestructionService = require(ServerModules.DestructionSystem)
local SFX = require(ServerModules.SFXModule)

local MoveAnims = ServerStorage.Assets.Animations.Moves
local ReplicateSet = RemotesContainer.Replicate.Set

local HIT_DAMAGE = { 3, 3 }
local PUNCH_DAMAGE = 5
local PUNCH_DESTRUCTION_FORCE = 35
local PUNCH_DESTRUCTION_MAX_TRACK_TIME = 4

local HIT_SIZE = Vector3.new(8, 8, 9)
local HIT_OFFSET = CFrame.new(0, 0, -4.5)

local PUNCH_SIZE = Vector3.new(9, 9, 9)
local PUNCH_OFFSET = CFrame.new(0, 0, -4)

local BLOCK_SLOW_SPEED = 0.5
local BLOCK_SLOW_TIME = 1

local HIT_SOUNDS = { "prowlHit1", "prowlHit2", "prowlHit3" }

return {
	Start = function(Player, Tool)
		local Character = Player.Character
		local HumRP = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		local UserAnimation = MoveAnims.Eclipse.Lunar["Prowl"]
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

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
						SFX:Play(soundName, HumRP)
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
							if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
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

				SFX:Play("prowlHit3", HumRP)

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
						if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
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

						local knockbackResult = PerfectKnockback:KnockBack(nil, EnemyCharacter, {
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

						local stopTracking = DestructionService:TrackCharacterImpacts(
							EnemyCharacter,
							PUNCH_DESTRUCTION_FORCE,
							Player,
							PUNCH_DESTRUCTION_MAX_TRACK_TIME,
							Vector3.new(20, 20, 20)
						)

						if knockbackResult and knockbackResult[1] then
							knockbackResult[1].Stopped:Once(function()
								stopTracking()
							end)
						end

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

				RemoteManager.FireAllClients("ReplicateTask", "ProwlPunch", {
					func = "End",
					Char = Character,
				})

				ReplicateSet:FireClient(Player, "ShakeCamera", { Intensity = 8, Last = 0.5 })
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
