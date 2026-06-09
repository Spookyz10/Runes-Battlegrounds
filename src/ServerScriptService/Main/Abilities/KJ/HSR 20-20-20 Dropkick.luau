-- [[ Services ]]:

local serverStorage = game:GetService("ServerStorage")
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- [[ Modules ]]:

local ServerModules = serverStorage.Modules
local ReplicatedModules = replicatedStorage.Modules

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local RagdollHandler = require(ServerModules.RagdollHandler)
local NewKnockback = require(ServerModules.BodymoverService)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local SoundsModule = require(ServerModules.SoundsModule)
local WeldSystem = require(ReplicatedModules.WeldSystem)

local replication = replicatedStorage.Replicated

-- [[ Assets ]]:

local kj = replicatedStorage.Resources.KJ

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		local Hitted = false

		-- [[ Play anim + sound ]]:
		local MainTrack = AnimationService:playAnimation(Character, kj.dropKick)

		SoundsModule:PlaySound(kj.dropkickS, HumRP)

		-- [[ Windup VFX ]]:
		replication:FireAllClients({
			"VFXS", "KJ", "dropkickwindup"
		}, Character, MainTrack.Animation.AnimationId)

		-- [[ Ground marker ]]:
		MainTrack:GetMarkerReachedSignal("Ground"):Once(function()
			replication:FireAllClients({
				"Require", "Emit"
			}, HumRP, kj.StartUp, 3, CFrame.new(0, -2, 0))
		end)

		-- [[ Start marker — hitbox ]]:
		MainTrack:GetMarkerReachedSignal("Start"):Once(function()
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(10, 10, 10)
			Hitbox.Ignore = { Character }

			Hitbox.onTouch = function(EnemyCharacter: Model)
				if Hitted then return end
				local EnemyHumanoid: Humanoid = EnemyCharacter:FindFirstChildOfClass("Humanoid")
				local EnemyHumRP: BasePart = EnemyCharacter:FindFirstChild("HumanoidRootPart")
				local EnemyPlayer = players:GetPlayerFromCharacter(EnemyCharacter)

				if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then return end
				if EnemyCharacter:FindFirstChild("IFrame") then return end
				if EnemyCharacter:GetAttribute("Ragdolled") then return end

				Hitted = true
				Hitbox:Stop()

				-- Initial damage
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 10, 15, nil, false, false, true, true, false)

				-- Stop windup, play hit anim
				MainTrack:Stop()
				local SuccessTrack = AnimationService:playAnimation(Character, kj.dropKickHit)

				-- Victim anim
				local VictimAnimator = EnemyHumanoid:FindFirstChildOfClass("Animator")
				local VictimTrack = VictimAnimator and VictimAnimator:LoadAnimation(kj.dropKickVictim)
				if VictimTrack then VictimTrack:Play(0) end

				-- Zero velocity
				HumRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				EnemyHumRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

				-- Weld victim
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, 0), 14.2)
				Weld:Start()

				-- Stun + iframes on enemy
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				iFramesService:AddAlliFrames(EnemyCharacter)

				-- Hit VFX
				replication:FireAllClients({
					"VFXS", "KJ", "dropkick"
				}, Character, EnemyCharacter, SuccessTrack.Animation.AnimationId)

				-- [[ End marker — final hit ]]:
				SuccessTrack:GetMarkerReachedSignal("End"):Once(function()
					if Weld then
						Weld:Stop()
						Weld = nil
					end

					HumRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					EnemyHumRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

					StunHandler:Unstun(Character, Stun)
					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					iFramesService:RemoveAlliFrames(Character)
					iFramesService:RemoveAlliFrames(EnemyCharacter)

					if not EnemyCharacter.Parent then return end

					DamageHandler:TakeDamage(Character, EnemyHumanoid, 1000, 0, nil, false, false, true, true, false)

					NewKnockback:Knockback(EnemyCharacter, {
						KnockbackType = "VelocityTweenDown",
						MaxForce = Vector3.new(math.huge, math.huge, math.huge),
						Velocity = EnemyHumRP.CFrame.UpVector * 25 + HumRP.CFrame.LookVector * 80,
						Time = 0.25,
					})

					RagdollHandler.ragdoll(EnemyHumanoid, 10)
				end)

				SuccessTrack.Stopped:Once(function()
					StunHandler:Unstun(Character, Stun)
					iFramesService:RemoveAlliFrames(Character)
				end)
			end

			Hitbox:Start()

			task.spawn(function()
				while MainTrack.IsPlaying and Character.Parent do
					Hitbox.Instance = HumRP
					task.wait()
				end
				Hitbox:Stop()
			end)
		end)

		-- [[ Miss — anim stopped without hit ]]:
		MainTrack.Stopped:Once(function()
			if not Hitted then
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
			end
		end)
	end
}