local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local ReplicatedModules = ReplicatedStorage.Modules
local RemotesContainer = ReplicatedStorage.Remotes

local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local RagdollHandler = require(ServerModules.RagdollHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local CollisionsModule = require(ServerModules.CollisionsModule)
local ReplicatedHitbox = require(ServerModules.ReplicatedHitboxes)

local WeldSystem = require(ReplicatedModules.WeldSystem)
local Trove = require(ReplicatedModules.Trove)

local services = require(ReplicatedStorage.Services)
local knockbackService = services:GetService("KnockbackService")

local ReplicateEffects_Set = RemotesContainer.Replicate.Set

local GojoV2Anims = ReplicatedStorage.Resources.GojoV2.Animations

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Janitor = Trove.new()

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		local StartAnimation = GojoV2Anims.InfinitySlamStart
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)

		-- Fire startup VFX to all clients
		ReplicateEffects_Set:FireAllClients("InfinitySlam", {
			Char = Character,
			Stage = "Startup"
		})

		-- Hitbox fires after 0.8s (timed, no marker)
		task.delay(0.8, function()
			if not Character:IsDescendantOf(workspace) then return end

			-- Emit startup VFX
			ReplicateEffects_Set:FireAllClients("InfinitySlam", {
				Char = Character,
				Stage = "StartupEmit"
			})

			local Hit = nil

			local Hitbox = ReplicatedHitbox.new(Player)
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(8, 8, 8)
			Hitbox.Offset = CFrame.new(0, 0, 0)
			Hitbox.Ignore = { Character }
			Hitbox.destroyAfterOnce = true
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 0, nil, nil, true, false, false, true, true, nil, nil)
				if HitInfo.Blocked == true then return end

				if Hit then return end
				Hit = EnemyCharacter

				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)

				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

				EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

				-- Weld victim facing attacker (180°) close up
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -1.5) * CFrame.Angles(0, math.pi, 0), -1)

				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				EnemyCharacter:AddTag("CantRotate")
				Character:AddTag("CantRotate")

				-- Stop start anim, play finisher anims
				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)

				local PlayerAnimation = GojoV2Anims.InfinitySlamPlayerFinisher
				local PlayerTrack = AnimationService:getAnimationTrack(Character, PlayerAnimation)
				local VictimAnimation = GojoV2Anims.InfinitySlamVictimFinisher

				AnimationService:playAnimation(Character, PlayerAnimation)
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)

				Weld:Start(nil, EnemyPlayer, Player)

				-- Fire hit VFX to all clients
				ReplicateEffects_Set:FireAllClients("InfinitySlam", {
					Char = Character,
					EChar = EnemyCharacter,
					Stage = "Hit"
				})

				-- After 0.5s spawn RedHandEnabled + Shoot VFX
				task.delay(0.5, function()
					if not Character:IsDescendantOf(workspace) then return end

					ReplicateEffects_Set:FireAllClients("InfinitySlam", {
						Char = Character,
						EChar = EnemyCharacter,
						Stage = "ChargeUp"
					})
				end)

				local FinisherEvents = {}

				-- Shoot marker - big damage, release, knockback
				FinisherEvents["Shoot"] = Janitor:Add(PlayerTrack:GetMarkerReachedSignal("Shoot"):Connect(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 12, nil, nil, false, false, false, true, false, nil, nil)

					-- Release weld
					pcall(function() Weld:Stop() end)

					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					EnemyCharacter:RemoveTag("CantRotate")
					iFramesService:RemoveAlliFrames(EnemyCharacter)
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

					-- Launch victim
					local at = HumRP.Position
					local forward = HumRP.CFrame.LookVector
					local lookposition = CFrame.lookAt(at, at + Vector3.new(forward.X, 0, forward.Z))

					require(ServerModules.PerfectKnockback).KnockBack(nil, EnemyCharacter, {
						LookVector = lookposition.LookVector,
						LookForce = 80,
						LookFinalForce = 70,
						LookAt = lookposition,
						DestroyRagdoll = true,
						GroundStunTime = 2,
						Escapable = false,
						FallingDetectDelay = 0.2,
						Dot = 1,
						DotParams = { 0.4, 1 },
						canHitWall = true
					}, Character)

					-- Fire shoot VFX
					ReplicateEffects_Set:FireAllClients("InfinitySlam", {
						Char = Character,
						EChar = EnemyCharacter,
						Stage = "Shoot"
					})

					-- Small forward lunge for attacker after 0.1s
					task.delay(0.1, function()
						if not Character:IsDescendantOf(workspace) then return end

						local LungeAttachment = Instance.new("Attachment")
						LungeAttachment.Parent = HumRP
						local LungeVelocity = Instance.new("LinearVelocity")
						LungeVelocity.Attachment0 = LungeAttachment
						LungeVelocity.MaxForce = math.huge
						LungeVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
						LungeVelocity.LineDirection = HumRP.CFrame.LookVector
						LungeVelocity.LineVelocity = 20
						LungeVelocity.Parent = HumRP
						Debris:AddItem(LungeVelocity, 0.4)
						Debris:AddItem(LungeAttachment, 0.4)
					end)
				end))

				PlayerTrack.Stopped:Once(function()
					for _, v in FinisherEvents do
						v:Disconnect()
					end

					StunHandler:Unstun(Character, Stun)
					Character:RemoveTag("CantRotate")
					iFramesService:RemoveAlliFrames(Character)
					CollisionsModule:SetCollisionGroup(Character, "Players")

					Janitor:Destroy()
				end)
			end

			Hitbox.functionAfterDestroy = function()
				if not Hit then
					StunHandler:Unstun(Character, Stun)
					Janitor:Destroy()
				end
			end

			Hitbox:Once()
		end)

		StartTrack.Stopped:Once(function()
			if not Hit then
				StunHandler:Unstun(Character, Stun)
				Janitor:Destroy()
			end
		end)
	end
}