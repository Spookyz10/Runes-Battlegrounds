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

		-- Startup dash
		local DashAttachment = Instance.new("Attachment")
		DashAttachment.Parent = HumRP
		local DashVelocity = Instance.new("LinearVelocity")
		DashVelocity.Attachment0 = DashAttachment
		DashVelocity.MaxForce = math.huge
		DashVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line
		DashVelocity.LineDirection = HumRP.CFrame.LookVector
		DashVelocity.LineVelocity = 50
		DashVelocity.Parent = HumRP
		Janitor:Add(DashVelocity)
		Janitor:Add(DashAttachment)

		local StartAnimation = GojoV2Anims.StrongestRedReversalStart
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)

		-- Fire startup VFX
		ReplicateEffects_Set:FireAllClients("RedReversal", {
			Char = Character,
			Stage = "Startup"
		})

		StartEvents["Hitbox"] = Janitor:Add(StartTrack:GetMarkerReachedSignal("Hitbox"):Connect(function()
			-- Enable RunTeleportEffect particles on clients
			ReplicateEffects_Set:FireAllClients("RedReversal", {
				Char = Character,
				Stage = "DashEffect"
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

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 0.5, nil, nil, true, false, false, true, true, nil, nil)
				if HitInfo.Blocked == true then return end

				if Hit then return end
				Hit = EnemyCharacter

				-- Stop dash immediately on hit
				DashVelocity:Destroy()
				DashAttachment:Destroy()

				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)

				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

				EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

				-- Weld victim facing attacker (180 degrees)
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), -1)

				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				EnemyCharacter:AddTag("CantRotate")
				Character:AddTag("CantRotate")

				local PlayerAnimation = GojoV2Anims.StrongestRedReversalPlayer
				local PlayerTrack = AnimationService:getAnimationTrack(Character, PlayerAnimation)
				local VictimAnimation = GojoV2Anims.StrongestRedReversalVictim
				local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)

				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)
				AnimationService:playAnimation(Character, PlayerAnimation)
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)

				Weld:Start(nil, EnemyPlayer, Player)

				-- Fire hit VFX to all clients
				ReplicateEffects_Set:FireAllClients("RedReversal", {
					Char = Character,
					EChar = EnemyCharacter,
					Stage = "Hit",
					Animation = PlayerAnimation.AnimationId
				})

				local ComboEvents = {}

				-- RedHit marker - shoot the red ball, emit RedShoot
				ComboEvents["RedHit"] = Janitor:Add(PlayerTrack:GetMarkerReachedSignal("RedHit"):Connect(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 0.5, nil, nil, false, false, false, true, false, nil, nil)

					ReplicateEffects_Set:FireAllClients("RedReversal", {
						Char = Character,
						EChar = EnemyCharacter,
						Stage = "RedHit"
					})
				end))

				-- Slam marker
				ComboEvents["Slam"] = Janitor:Add(PlayerTrack:GetMarkerReachedSignal("Slam"):Connect(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 0.5, nil, nil, false, false, false, true, false, nil, nil)

					ReplicateEffects_Set:FireAllClients("RedReversal", {
						Char = Character,
						EChar = EnemyCharacter,
						Stage = "Slam"
					})
				end))

				-- RedHit2 marker
				ComboEvents["RedHit2"] = Janitor:Add(PlayerTrack:GetMarkerReachedSignal("RedHit2"):Connect(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 0.5, nil, nil, false, false, false, true, false, nil, nil)

					ReplicateEffects_Set:FireAllClients("RedReversal", {
						Char = Character,
						EChar = EnemyCharacter,
						Stage = "RedHit2"
					})
				end))

				-- BlackFlash marker - big damage
				ComboEvents["BlackFlash"] = Janitor:Add(PlayerTrack:GetMarkerReachedSignal("BlackFlash"):Connect(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, false, false, false, true, false, nil, nil)

					ReplicateEffects_Set:FireAllClients("RedReversal", {
						Char = Character,
						EChar = EnemyCharacter,
						Stage = "BlackFlash"
					})
				end))

				-- Knockback marker - release victim, launch, crater
				ComboEvents["Knockback"] = Janitor:Add(PlayerTrack:GetMarkerReachedSignal("Knockback"):Connect(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, false, true, false, nil, nil)

					ReplicateEffects_Set:FireAllClients("RedReversal", {
						Char = Character,
						EChar = EnemyCharacter,
						Stage = "Knockback"
					})

					pcall(function() Weld:Stop() end)

					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					EnemyCharacter:RemoveTag("CantRotate")
					iFramesService:RemoveAlliFrames(EnemyCharacter)
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

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

					-- Crater after victim lands
					task.delay(1, function()
						if EnemyCharacter and EnemyCharacter.PrimaryPart and EnemyCharacter:IsDescendantOf(workspace) then
							local CraterModule = require(ServerModules.CraterModule)
							local pos = EnemyHumRP.Position
							CraterModule.formCrater({ Position = pos, Radius = 15, rockSize = 2.5 })
							CraterModule.formCrater({ Position = pos, Radius = 20, rockSize = 3 })

							ReplicateEffects_Set:FireAllClients("RedReversal", {
								Char = Character,
								EChar = EnemyCharacter,
								Stage = "Crater"
							})
						end
					end)
				end))

				-- Land marker - restore attacker mobility
				ComboEvents["Land"] = Janitor:Add(PlayerTrack:GetMarkerReachedSignal("Land"):Connect(function()
					ReplicateEffects_Set:FireAllClients("RedReversal", {
						Char = Character,
						EChar = EnemyCharacter,
						Stage = "Land"
					})
				end))

				PlayerTrack.Stopped:Once(function()
					for _, v in ComboEvents do
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
				-- If nobody was hit, stop dash after 0.5s and clean up
				if not Hit then
					task.delay(0.5, function()
						ReplicateEffects_Set:FireAllClients("RedReversal", {
							Char = Character,
							Stage = "DashEnd"
						})
						StunHandler:Unstun(Character, Stun)
						Janitor:Destroy()
					end)
				end
			end

			Hitbox:Once()
		end))

		StartTrack.Stopped:Once(function()
			for _, v in StartEvents do
				v:Disconnect()
			end

			if not StartTrack.IsPlaying then
				StunHandler:Unstun(Character, Stun)
				Janitor:Destroy()
			end
		end)
	end
}