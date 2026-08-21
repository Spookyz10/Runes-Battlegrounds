local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ServerModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local RagdollHandler = require(ServerModules.RagdollHandler)
local SkillCancelHandler = require(ServerModules.SkillCancelHandler)

local MoveAnims = ServerStorage.Assets.Animations.Moves
local UserAnimation = MoveAnims.Eclipse.Solar.Awakening.Helioclysm

local GRAB_HITBOX_SIZE = Vector3.new(7, 30, 7)
local GRAB_HITBOX_OFFSET = CFrame.new(0, 0, -3)

local RISE_HEIGHT = 100
local HOVER_HEIGHT = 60
local RISE_TIME = 0.6
local HOVER_WAIT_TIME = 2
local DESCEND_TIME = 1.5
local RAGDOLL_TIME = 14

local PUNCH_DAMAGE = 2
local PUNCH_HITBOX_SIZE = Vector3.new(22.415, 111.924, 27.247)
local PUNCH_HITBOX_OFFSET = CFrame.new(0, 4, 0)

return {
	Cooldown = 1,

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
		iFramesService:AddiFrames(Character, "Strong")

		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		if not UserTrack then
			iFramesService:RemoveiFrames(Character, "Strong")
			StunHandler:Unstun(Character, CasterStun)
			return
		end

		local cancelled = false
		local onDamageCancel

		local Victim = nil
		local VictimHumanoid = nil
		local VictimHumRP = nil
		local VictimAnchored = false
		local CasterAnchored = false

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

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("hit"):Once(function()
				if cancelled or not Character.Parent then
					return
				end

				RemoteManager.FireAllClients("ReplicateTask", "HelioclysmWindup", { char = Character })

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
						if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then
							return
						end
						if iFramesService:HasiFrame(EnemyCharacter, 1) then
							return
						end

						FoundVictim = EnemyCharacter
					end
				)

				if not FoundVictim then
					return
				end

				Victim = FoundVictim
				VictimHumanoid = Victim:FindFirstChild("Humanoid")
				VictimHumRP = Victim:FindFirstChild("HumanoidRootPart")

				if not VictimHumanoid or not VictimHumRP then
					Victim = nil
					return
				end

				RagdollHandler.ragdoll(VictimHumanoid, RAGDOLL_TIME, nil, nil, nil, nil, true)

				local OriginPosition = VictimHumRP.Position

				VictimHumRP.AssemblyLinearVelocity = Vector3.zero
				VictimHumRP.Anchored = true
				VictimAnchored = true

				local RiseTarget = CFrame.new(OriginPosition + Vector3.new(0, RISE_HEIGHT, 0))
				TweenService:Create(
					VictimHumRP,
					TweenInfo.new(RISE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{ CFrame = RiseTarget }
				):Play()

				task.delay(RISE_TIME + HOVER_WAIT_TIME, function()
					if not Victim or not Victim.Parent or not VictimHumRP or not VictimHumRP.Parent then
						return
					end
					if not VictimAnchored then
						return
					end

					local DescendTarget = CFrame.new(OriginPosition + Vector3.new(0, HOVER_HEIGHT, 0))
					TweenService:Create(
						VictimHumRP,
						TweenInfo.new(DESCEND_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{ CFrame = DescendTarget }
					):Play()
				end)
			end)
		)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("punch"):Connect(function()
				if cancelled or not Character.Parent then
					return
				end

				RemoteManager.FireAllClients("ReplicateTask", "HelioclysmBeam", { char = Character })

				HitboxHandler:SimpleOnce(
					HumRP,
					PUNCH_HITBOX_SIZE,
					PUNCH_HITBOX_OFFSET,
					{ Character },
					"Box",
					nil,
					function(EnemyCharacter)
						local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
						if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then
							return
						end
						if iFramesService:HasiFrame(EnemyCharacter, 1) then
							return
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
					end
				)
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			SkillCancelHandler:Unregister(Character, onDamageCancel)
			iFramesService:RemoveiFrames(Character, "Strong")
			StunHandler:Unstun(Character, CasterStun)

			if CasterAnchored and HumRP and HumRP.Parent then
				HumRP.Anchored = false
			end

			if VictimAnchored and VictimHumRP and VictimHumRP.Parent then
				VictimHumRP.Anchored = false
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)

		HumRP.Anchored = true
		CasterAnchored = true
	end,
}
