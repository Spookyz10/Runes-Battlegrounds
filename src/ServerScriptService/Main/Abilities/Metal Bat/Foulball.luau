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

-- Animations
local MoveAnims = ServerStorage.Assets.Animations.Moves["Metal Bat"]

local ReplicateEffects_Set = RemotesContainer.Replicate.Set


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Janitor = Trove.new()

		local AttackerStun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		local MissAnimation = MoveAnims["Foul Ball"].Miss
		local MissTrack = AnimationService:getAnimationTrack(Character, MissAnimation)
		local MissEvents = {}

		local Hit = nil
		local Finisher = false


		-- // MISS PHASE \\ --

		MissEvents["Move"] = Janitor:Add(MissTrack:GetMarkerReachedSignal("Move"):Connect(function()
			knockbackService.Knockback(HumRP, {
				["duration"] = 0.2,
				["force"] = 50,
				["direction"] = HumRP.CFrame.LookVector
			})
		end))

		MissEvents["hit"] = Janitor:Add(MissTrack:GetMarkerReachedSignal("hit"):Connect(function()

			local GrabHitbox = ReplicatedHitbox.new(Player)
			GrabHitbox.Instance = HumRP
			GrabHitbox.Size = Vector3.new(5, 5, 5)
			GrabHitbox.Offset = CFrame.new(0, -2, -4)
			GrabHitbox.Ignore = { Character }
			GrabHitbox.destroyAfterOnce = true

			GrabHitbox.onTouch = function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name)
					or EnemyHumanoid.Health <= 0
					or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then
					return
				end

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, true, false, false, true, true, nil, nil)
				if HitInfo.Blocked == true then return end
				if Hit then return end
				Hit = EnemyCharacter

				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid)
				end

				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

				iFramesService:AddAlliFrames(Character)
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -2.5) * CFrame.Angles(0, math.pi, 0), -1)

				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)

				local SuccessAnimation = MoveAnims["Foul Ball"].Success
				local SuccessTrack = AnimationService:getAnimationTrack(Character, SuccessAnimation)
				local SuccessEvents = {}

				local HurtAnimation = MoveAnims["Foul Ball"].Hurt
				AnimationService:playAnimation(EnemyCharacter, HurtAnimation)
				AnimationService:playAnimation(Character, SuccessAnimation)

				Weld:Start(nil, EnemyPlayer, Player)

				ReplicateEffects_Set:FireAllClients("FoulBall", {
					Char = Character,
					Stage = "grab",
					Victim = EnemyCharacter,
					Animation = SuccessAnimation.AnimationId
				})


				local function CleanupGrab()
					if Weld then pcall(function() Weld:Stop() end) end
					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					iFramesService:RemoveAlliFrames(EnemyCharacter)
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
					EnemyHumRP.Massless = false
				end

				local function CleanupAttacker()
					iFramesService:RemoveAlliFrames(Character)
					StunHandler:Unstun(Character, AttackerStun)
				end


				-- // PRE-CHECK MARKER — Finisher branch (low health) \\ --

				SuccessEvents["PreCheck"] = Janitor:Add(SuccessTrack:GetMarkerReachedSignal("PreCheck"):Connect(function()
					if EnemyHumanoid.Health > 15 then return end

					Finisher = true

					AnimationService:stopAll(Character)
					AnimationService:stopAll(EnemyCharacter)

					local FinisherAnimation = MoveAnims["Foul Ball"].Finisher
					local FinisherTrack = AnimationService:getAnimationTrack(Character, FinisherAnimation)
					local FinisherEvents = {}

					local HurtFinisherAnimation = MoveAnims["Foul Ball"].HurtFinisher
					AnimationService:playAnimation(EnemyCharacter, HurtFinisherAnimation)
					AnimationService:playAnimation(Character, FinisherAnimation)

					DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, false, false, true, true, false, nil, nil)

					iFramesService:AddAlliFrames(EnemyCharacter)
					RagdollHandler.ragdoll(EnemyHumanoid, 10)
					StunHandler:Stun(EnemyCharacter, 2, true, 0, 0, true)

					ReplicateEffects_Set:FireAllClients("FoulBall", {
						Char = Character,
						Stage = "f_start",
						Victim = EnemyCharacter,
						Animation = FinisherAnimation.AnimationId
					})


					-- Finisher mid-swing sound/VFX marker
					FinisherEvents["Damage"] = Janitor:Add(FinisherTrack:GetMarkerReachedSignal("Damage"):Connect(function()
						ReplicateEffects_Set:FireAllClients("FoulBall", {
							Char = Character,
							Stage = "f_swing",
							Victim = EnemyCharacter
						})
					end))


					-- Finisher final hit — massive launch
					FinisherEvents["FinalDamage"] = Janitor:Add(FinisherTrack:GetMarkerReachedSignal("FinalDamage"):Connect(function()

						DamageHandler:TakeDamage(Character, EnemyHumanoid, 100, nil, nil, false, false, true, true, true, nil, nil)

						CleanupGrab()

						-- Big upward + forward launch
						local launchForce = math.random(400, 500)
						knockbackService.Knockback(EnemyHumRP, {
							["duration"] = 0.3,
							["force"] = launchForce,
							["direction"] = (HumRP.CFrame.LookVector + Vector3.new(0, 0.4, 0)).Unit
						})

						CleanupAttacker()

						ReplicateEffects_Set:FireAllClients("FoulBall", {
							Char = Character,
							Stage = "f_finaldamage",
							Victim = EnemyCharacter
						})

						Janitor:Destroy()
					end))


					FinisherTrack.Stopped:Once(function()
						for _, v in FinisherEvents do v:Disconnect() end

						if Weld then pcall(function() Weld:Stop() end) end
						CleanupGrab()
						CleanupAttacker()
						Janitor:Destroy()
					end)
				end))


				-- // DAMAGE MARKER — normal combo hit \\ --

				SuccessEvents["Damage"] = Janitor:Add(SuccessTrack:GetMarkerReachedSignal("Damage"):Connect(function()
					if Finisher then return end

					DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, true, false, true, true, false, nil, nil)
					StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

					ReplicateEffects_Set:FireAllClients("FoulBall", {
						Char = Character,
						Stage = "damage",
						Victim = EnemyCharacter
					})
				end))


				-- // FINAL DAMAGE MARKER — normal ender, launch forward+up \\ --

				SuccessEvents["FinalDamage"] = Janitor:Add(SuccessTrack:GetMarkerReachedSignal("FinalDamage"):Connect(function()
					if Finisher then return end
					if EnemyHumanoid.Health < 15 then return end

					DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, true, false, true, true, false, nil, nil)

					-- Play Knock anim on enemy before weld releases
					local KnockAnimation = MoveAnims["Foul Ball"].Knock
					AnimationService:stopAll(EnemyCharacter)
					AnimationService:playAnimation(EnemyCharacter, KnockAnimation)

					CleanupGrab()

					StunHandler:Stun(EnemyCharacter, 2, true, 0, 0, true)
					RagdollHandler.ragdoll(EnemyHumanoid, 2)

					-- Forward + slight upward launch
					local launchForce = math.random(55, 66)
					knockbackService.Knockback(EnemyHumRP, {
						["duration"] = 0.2,
						["force"] = launchForce,
						["direction"] = (HumRP.CFrame.LookVector + Vector3.new(0, 0.6, 0)).Unit
					})

					CleanupAttacker()

					ReplicateEffects_Set:FireAllClients("FoulBall", {
						Char = Character,
						Stage = "ender",
						Victim = EnemyCharacter
					})

					Janitor:Destroy()
				end))


				-- Cleanup if success anim stops early (interrupted)
				SuccessTrack.Stopped:Once(function()
					for _, v in SuccessEvents do v:Disconnect() end

					if not Finisher then
						CleanupGrab()
						CleanupAttacker()
						Janitor:Destroy()
					end
				end)
			end

			GrabHitbox:Once()
		end))


		-- Miss anim ended, nobody hit
		MissTrack.Stopped:Once(function()
			for _, v in MissEvents do v:Disconnect() end

			if not Hit then
				StunHandler:Unstun(Character, AttackerStun)
				Janitor:Destroy()
			end
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, MissAnimation)

		ReplicateEffects_Set:FireAllClients("FoulBall", {
			Char = Character,
			Stage = "pa",
			Animation = MissAnimation.AnimationId
		})
	end
}