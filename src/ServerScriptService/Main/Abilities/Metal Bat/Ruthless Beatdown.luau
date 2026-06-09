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

-- Assets
local Animations = ServerStorage.Assets.Animations
local MoveAnims = Animations.Moves["Metal Bat"]

local ComSet = RemotesContainer.Comunicator.Set
local ReplicateEffects_Set = RemotesContainer.Replicate.Set


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Janitor = Trove.new()

		-- Stun attacker for the duration of the move
		local AttackerStun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		-- Animations
		local MissAnimation = MoveAnims.Beatdown.Miss
		local MissTrack = AnimationService:getAnimationTrack(Character, MissAnimation)
		local MissEvents = {}

		local Hit = nil
		local Finisher = false


		-- // MISS PHASE \\ --

		MissEvents["hit"] = Janitor:Add(MissTrack:GetMarkerReachedSignal("hit"):Connect(function()

			-- Small forward lunge on swing
			knockbackService.Knockback(HumRP, {
				["duration"] = 0.2,
				["force"] = 50,
				["direction"] = HumRP.CFrame.LookVector
			})

			-- Hitbox for initial grab attempt
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

				-- First hit damage
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, true, false, false, true, true, nil, nil)
				if HitInfo.Blocked == true then return end

				if Hit then return end
				Hit = EnemyCharacter

				-- Cancel enemy ragdoll if active
				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid)
				end

				-- Stun the enemy
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

				-- iFrames on attacker during grab
				iFramesService:AddAlliFrames(Character)

				-- Collision group so they pass through each other
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

				-- Weld enemy to attacker
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -2.5) * CFrame.Angles(0, math.pi, 0), -1)

				-- Stop miss anim, play success on attacker and hurt on enemy
				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)

				local SuccessAnimation = MoveAnims.Beatdown.Success
				local SuccessTrack = AnimationService:getAnimationTrack(Character, SuccessAnimation)
				local SuccessEvents = {}

				local HurtAnimation = MoveAnims.Beatdown.Hurt
				AnimationService:playAnimation(EnemyCharacter, HurtAnimation)
				AnimationService:playAnimation(Character, SuccessAnimation)

				-- Fire client VFX for grab phase
				ReplicateEffects_Set:FireAllClients("Beatdown", {
					Char = Character,
					Stage = "grab",
					Victim = EnemyCharacter
				})


				-- // DAMAGE MARKER (mid-combo hits) \\ --

				SuccessEvents["Damage"] = Janitor:Add(SuccessTrack:GetMarkerReachedSignal("Damage"):Connect(function()

					DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, true, false, true, true, false, nil, nil)
					StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

					-- Forward push during combo
					knockbackService.Knockback(EnemyHumRP, {
						["duration"] = 0.2,
						["force"] = 35,
						["direction"] = HumRP.CFrame.LookVector
					})

					ReplicateEffects_Set:FireAllClients("Beatdown", {
						Char = Character,
						Stage = "damage",
						Victim = EnemyCharacter
					})
				end))


				-- // FINAL DAMAGE MARKER \\ --

				SuccessEvents["FinalDamage"] = Janitor:Add(SuccessTrack:GetMarkerReachedSignal("FinalDamage"):Connect(function()

					local function CleanupGrab()
						if Weld then
							pcall(function() Weld:Stop() end)
						end
						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
						EnemyHumRP.Massless = false
					end

					-- Branch: Finisher if enemy health is low, otherwise normal ender
					if EnemyHumanoid.Health >= 15 then

						-- Normal ender: smash down
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, true, false, true, true, false, nil, nil)

						CleanupGrab()

						StunHandler:Stun(EnemyCharacter, 2, true, 0, 0, true)
						RagdollHandler.ragdoll(EnemyHumanoid, 2)

						-- Launch enemy downward
						knockbackService.Knockback(EnemyHumRP, {
							["duration"] = 0.2,
							["force"] = 50,
							["direction"] = HumRP.CFrame.UpVector * -1
						})

						-- Cleanup attacker state
						iFramesService:RemoveAlliFrames(Character)
						StunHandler:Unstun(Character, AttackerStun)

						ReplicateEffects_Set:FireAllClients("Beatdown", {
							Char = Character,
							Stage = "ender",
							Victim = EnemyCharacter
						})

						Janitor:Destroy()

					else

						-- // FINISHER BRANCH \\ --
						Finisher = true

						AnimationService:stopAll(Character)
						AnimationService:stopAll(EnemyCharacter)

						local FinisherAnimation = MoveAnims.Beatdown.Finisher
						local FinisherTrack = AnimationService:getAnimationTrack(Character, FinisherAnimation)
						local FinisherEvents = {}

						local VictimAnimation = MoveAnims.Beatdown.Hurt
						AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
						AnimationService:playAnimation(Character, FinisherAnimation)

						iFramesService:AddAlliFrames(EnemyCharacter)

						DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, false, false, true, true, false, nil, nil)
						RagdollHandler.ragdoll(EnemyHumanoid, 2)

						-- Destroy weld before finisher slam
						if Weld then
							pcall(function() Weld:Stop() end)
						end

						ReplicateEffects_Set:FireAllClients("Beatdown", {
							Char = Character,
							Stage = "f_start",
							Victim = EnemyCharacter
						})


						-- Finisher "hit" marker — mid-finisher slam
						FinisherEvents["hit"] = Janitor:Add(FinisherTrack:GetMarkerReachedSignal("hit"):Connect(function()

							DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, false, false, true, true, false, nil, nil)
							StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

							ReplicateEffects_Set:FireAllClients("Beatdown", {
								Char = Character,
								Stage = "f_hit",
								Victim = EnemyCharacter
							})
						end))


						-- Finisher "lasthit" marker — final slam + launch
						FinisherEvents["lasthit"] = Janitor:Add(FinisherTrack:GetMarkerReachedSignal("lasthit"):Connect(function()

							DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, false, false, true, true, false, nil, nil)

							StunHandler:Unstun(EnemyCharacter, EnemyStun)
							iFramesService:RemoveAlliFrames(EnemyCharacter)
							CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

							knockbackService.Knockback(EnemyHumRP, {
								["duration"] = 0.2,
								["force"] = 1,
								["direction"] = HumRP.CFrame.LookVector
							})

							ReplicateEffects_Set:FireAllClients("Beatdown", {
								Char = Character,
								Stage = "f_lasthit",
								Victim = EnemyCharacter
							})
						end))


						FinisherTrack.Stopped:Once(function()
							for _, v in FinisherEvents do
								v:Disconnect()
							end

							iFramesService:RemoveAlliFrames(Character)
							StunHandler:Unstun(Character, AttackerStun)
							CollisionsModule:SetCollisionGroup(Character, "Players")

							Janitor:Destroy()
						end)

					end

				end))


				-- If success anim ends without hitting FinalDamage (e.g. interrupted)
				SuccessTrack.Stopped:Once(function()
					for _, v in SuccessEvents do
						v:Disconnect()
					end

					if Finisher == false then
						if Weld then
							pcall(function() Weld:Stop() end)
						end
						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
						iFramesService:RemoveAlliFrames(Character)
						StunHandler:Unstun(Character, AttackerStun)
						Janitor:Destroy()
					end
				end)

				-- Start the weld
				Weld:Start(nil, EnemyPlayer, Player)
			end

			GrabHitbox:Once()
		end))


		-- If miss anim ends without hitting anyone
		MissTrack.Stopped:Once(function()
			for _, v in MissEvents do
				v:Disconnect()
			end

			if not Hit then
				StunHandler:Unstun(Character, AttackerStun)
				Janitor:Destroy()
			end
		end)


		-- Play the miss animation and fire initial VFX
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, MissAnimation)

		ReplicateEffects_Set:FireAllClients("Beatdown", {
			Char = Character,
			Stage = "pa",
			Animation = MissAnimation.AnimationId
		})
	end
}