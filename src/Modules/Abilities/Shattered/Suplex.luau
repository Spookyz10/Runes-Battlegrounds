local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
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
local SkillCollision = require(ServerModules.SkillCollision)

local MoveAnims = ServerStorage.Assets.Animations.Moves

local HIT_SIZE = Vector3.new(8, 5, 8)
local HIT_OFFSET = CFrame.new(0, 0, -4)

local VICTIM_OFFSET_DISTANCE = 2
local CASTER_TWEEN_DISTANCE = 3
local CASTER_TWEEN_TIME = 0.7

local SLAM_DAMAGE = 20
local SLAM_RAGDOLL_TIME = 5

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

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)

		local UserAnimation = MoveAnims.Shattered.Suplex
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		if not UserTrack then
			StunHandler:Unstun(Character, Stun)
			return
		end

		local HitHappened = false
		local Cancelled = false

		local VictimCharacter = nil
		local VictimHumanoid = nil
		local VictimHumRP = nil
		local VictimTrack = nil

		local onDamageCancel

		local function cleanupVictim()
			if not VictimCharacter or not VictimCharacter.Parent then
				return
			end

			VictimCharacter:RemoveTag("CantRotate")

			if VictimHumRP and VictimHumRP.Parent then
				VictimHumRP.Anchored = false
				VictimHumRP.AssemblyLinearVelocity = Vector3.zero
				VictimHumRP.AssemblyAngularVelocity = Vector3.zero
			end

			if VictimTrack and VictimTrack.IsPlaying then
				VictimTrack:Stop()
			end

			SkillCollision:Unlock(VictimCharacter)
			iFramesService:RemoveiFrames(VictimCharacter, "Base")
		end

		local function cleanupCaster()
			Character:RemoveTag("CantRotate")
			iFramesService:RemoveiFrames(Character, "Base")
			StunHandler:Unstun(Character, Stun)
			SkillCollision:Unlock(Character)
		end

		onDamageCancel = function()
			if Cancelled then
				return
			end
			Cancelled = true

			if UserTrack and UserTrack.IsPlaying then
				UserTrack:Stop()
			end

			if HitHappened then
				cleanupVictim()
			end

			cleanupCaster()
		end

		SkillCancelHandler:Register(Character, onDamageCancel)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("hit"):Once(function()
				if Cancelled then
					return
				end

				RemoteManager.FireAllClients("ReplicateTask", "Ring", {
					FirstProps = { Size = Vector3.new(0.6, 4, 0.6), Transparency = 0 },
					CF = HumRP.CFrame * CFrame.new(0, -1, -2) * CFrame.Angles(math.rad(30), 0, 0),
					TN_Info = { Time = 0.4, Style = "Quad", Direction = "Out" },
					FinalProps = { Size = Vector3.new(3, 3, 3), Transparency = 1 },
				})

				local Candidates = {}

				HitboxHandler:SimpleOnce(HumRP, HIT_SIZE, HIT_OFFSET, { Character }, nil, nil, function(EnemyCharacter)
					local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
					if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then
						return
					end
					if iFramesService:HasiFrame(EnemyCharacter, 1) then
						return
					end
					if table.find(Candidates, EnemyCharacter) then
						return
					end
					table.insert(Candidates, EnemyCharacter)
				end)

				if #Candidates == 0 then
					Cancelled = true
					SkillCancelHandler:Unregister(Character, onDamageCancel)
					if UserTrack and UserTrack.IsPlaying then
						UserTrack:Stop()
					end
					cleanupCaster()
					return
				end

				VictimCharacter = Candidates[math.random(1, #Candidates)]
				VictimHumanoid = VictimCharacter:FindFirstChild("Humanoid")
				VictimHumRP = VictimCharacter:FindFirstChild("HumanoidRootPart")

				if not VictimHumanoid or not VictimHumRP then
					VictimCharacter = nil
					Cancelled = true
					SkillCancelHandler:Unregister(Character, onDamageCancel)
					if UserTrack and UserTrack.IsPlaying then
						UserTrack:Stop()
					end
					cleanupCaster()
					return
				end

				HitHappened = true
				SkillCancelHandler:Unregister(Character, onDamageCancel)
				SkillCancelHandler:Register(Character, onDamageCancel)

				iFramesService:AddiFrames(Character, "Base")
				iFramesService:AddiFrames(VictimCharacter, "Base")

				SkillCollision:Lock(Character)
				SkillCollision:Lock(VictimCharacter)

				local VictimAnimation = MoveAnims.Shattered.suplexHit
				VictimTrack = AnimationService:playAnimation(VictimCharacter, VictimAnimation)

				VictimHumRP.AssemblyLinearVelocity = Vector3.zero
				VictimHumRP.AssemblyAngularVelocity = Vector3.zero
				VictimHumRP.Anchored = true

				Character:AddTag("CantRotate")
				VictimCharacter:AddTag("CantRotate")

				local TargetPosition = (HumRP.CFrame * CFrame.new(0, 0, -VICTIM_OFFSET_DISTANCE)).Position
				VictimHumRP.CFrame = CFrame.new(TargetPosition, TargetPosition - HumRP.CFrame.LookVector)

				local CasterTargetCFrame = HumRP.CFrame * CFrame.new(0, 0, -CASTER_TWEEN_DISTANCE)
				local CasterTween = TweenService:Create(
					HumRP,
					TweenInfo.new(CASTER_TWEEN_TIME, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{ CFrame = CasterTargetCFrame }
				)
				CasterTween:Play()

				local HitVictim = VictimCharacter
				local HitVictimHumRP = VictimHumRP

				task.delay(1, function()
					if Cancelled then
						return
					end
					if not HitVictim or not HitVictim.Parent then
						return
					end
					if VictimCharacter ~= HitVictim then
						return
					end
					if not HitVictimHumRP or not HitVictimHumRP.Parent then
						return
					end

					local BackTargetCFrame = HitVictimHumRP.CFrame * CFrame.new(0, 0, 3)
					local BackTween = TweenService:Create(
						HitVictimHumRP,
						TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{ CFrame = BackTargetCFrame }
					)

					BackTween.Completed:Once(function(state)
						if state ~= Enum.PlaybackState.Completed then
							return
						end
						if Cancelled then
							return
						end
						if not HitVictim or not HitVictim.Parent then
							return
						end
						if VictimCharacter ~= HitVictim then
							return
						end
						if not HitVictimHumRP or not HitVictimHumRP.Parent then
							return
						end

						local DownTargetCFrame = HitVictimHumRP.CFrame - Vector3.new(0, 5, 0)
						local DownTween = TweenService:Create(
							HitVictimHumRP,
							TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
							{ CFrame = DownTargetCFrame }
						)
						DownTween:Play()
					end)

					BackTween:Play()
				end)
			end)
		)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("slam"):Once(function()
				if Cancelled or not HitHappened then
					return
				end
				if not VictimCharacter or not VictimCharacter.Parent or not VictimHumanoid then
					return
				end
				if VictimHumanoid.Health <= 0 then
					return
				end

				DamageHandler:TakeDamage(
					Character,
					VictimHumanoid,
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

				RemoteManager.FireAllClients("ReplicateTask", "SuplexHit", { char = Character })

				RemoteManager.FireAllClients("ReplicateTask", "SuplexSmoke", { EnemyChar = VictimCharacter })
				RemoteManager.FireClient(Player, "ReplicateTask", "ShakeCamera", { Intensity = 6, Last = 0.4 })

				if VictimHumRP and VictimHumRP.Parent then
					VictimHumRP.CFrame = VictimHumRP.CFrame * CFrame.Angles(math.rad(180), 0, 0)
					VictimHumRP.Anchored = false
				end

				VictimCharacter:RemoveTag("CantRotate")
				SkillCollision:Unlock(VictimCharacter)
				iFramesService:RemoveiFrames(VictimCharacter, "Base")

				RagdollHandler.ragdoll(VictimHumanoid, SLAM_RAGDOLL_TIME, false)
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			SkillCancelHandler:Unregister(Character, onDamageCancel)

			if not Cancelled then
				if HitHappened then
					cleanupVictim()
				end
				cleanupCaster()
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
