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

local MoveAnims = ServerStorage.Assets.Animations.Moves["Metal Bat"]

local ReplicateEffects_Set = RemotesContainer.Replicate.Set


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Janitor = Trove.new()

		local AttackerStun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		local FailAnimation = MoveAnims.Homerun.Fail
		local FailTrack     = AnimationService:getAnimationTrack(Character, FailAnimation)
		local FailEvents    = {}

		local Hit      = nil
		local Finisher = false


		-- // FAIL / APPROACH PHASE \\ --

		-- "Dash" marker: burst forward
		FailEvents["Dash"] = Janitor:Add(FailTrack:GetMarkerReachedSignal("Dash"):Connect(function()
			knockbackService.Knockback(HumRP, {
				["duration"] = 0.35,
				["force"] = 150,
				["direction"] = HumRP.CFrame.LookVector * Vector3.new(1, 0, 1)
			})

			ReplicateEffects_Set:FireAllClients("Homerun", {
				Char = Character,
				Stage = "dash"
			})
		end))


		-- "Hit" marker: first hitbox — swing detection
		FailEvents["Hit"] = Janitor:Add(FailTrack:GetMarkerReachedSignal("Hit"):Connect(function()
			local SwingHitbox = ReplicatedHitbox.new(Player)
			SwingHitbox.Instance = HumRP
			SwingHitbox.Size = Vector3.new(5, 5, 5)
			SwingHitbox.Offset = CFrame.new(0, 0, -5)
			SwingHitbox.Ignore = { Character }
			SwingHitbox.destroyAfterOnce = true

			SwingHitbox.onTouch = function(EnemyCharacter: Model)
				if Hit then return end

				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name)
					or EnemyHumanoid.Health <= 0
					or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then
					return
				end

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, true, false, false, true, true, nil, nil)
				if HitInfo.Blocked == true then return end
				Hit = EnemyCharacter

				-- Face enemy toward attacker
				EnemyHumRP.CFrame = CFrame.lookAt(EnemyHumRP.Position, HumRP.Position)

				local isFinisher = EnemyHumanoid.Health <= EnemyHumanoid.MaxHealth * 0.15

				if isFinisher then
					_handleFinisher(EnemyCharacter, EnemyPlayer, EnemyHumRP, EnemyHumanoid)
				else
					_handleNormal(EnemyCharacter, EnemyPlayer, EnemyHumRP, EnemyHumanoid)
				end
			end

			SwingHitbox:Once()
		end))


		-- "Slam" marker: stop dash, second hitbox + rocks
		FailEvents["Slam"] = Janitor:Add(FailTrack:GetMarkerReachedSignal("Slam"):Connect(function()

			-- Kill the dash force
			knockbackService.Knockback(HumRP, {
				["duration"] = 0.05,
				["force"] = 0,
				["direction"] = HumRP.CFrame.LookVector
			})

			ReplicateEffects_Set:FireAllClients("Homerun", {
				Char = Character,
				Stage = "slam",
				HRPPos = HumRP.Position
			})

			-- Second hitbox at slam point
			local SlamHitbox = ReplicatedHitbox.new(Player)
			SlamHitbox.Instance = HumRP
			SlamHitbox.Size = Vector3.new(5, 5, 5)
			SlamHitbox.Offset = CFrame.new(0, 0, -5)
			SlamHitbox.Ignore = { Character }
			SlamHitbox.destroyAfterOnce = true

			SlamHitbox.onTouch = function(EnemyCharacter: Model)
				if Hit then return end

				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name)
					or EnemyHumanoid.Health <= 0
					or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then
					return
				end

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, true, false, false, true, true, nil, nil)
				if HitInfo.Blocked == true then return end
				Hit = EnemyCharacter

				EnemyHumRP.CFrame = CFrame.lookAt(EnemyHumRP.Position, HumRP.Position)

				local isFinisher = EnemyHumanoid.Health <= EnemyHumanoid.MaxHealth * 0.15

				if isFinisher then
					_handleFinisher(EnemyCharacter, EnemyPlayer, EnemyHumRP, EnemyHumanoid)
				else
					_handleNormal(EnemyCharacter, EnemyPlayer, EnemyHumRP, EnemyHumanoid)
				end
			end

			SlamHitbox:Once()
		end))


		-- // NORMAL HIT HANDLER \\ --

		function _handleNormal(EnemyCharacter, EnemyPlayer, EnemyHumRP, EnemyHumanoid)

			AnimationService:stopAll(Character)
			AnimationService:stopAll(EnemyCharacter)

			local SuccessAnimation = MoveAnims.Homerun.Success
			local SuccessTrack     = AnimationService:getAnimationTrack(Character, SuccessAnimation)
			local SuccessEvents    = {}

			local VictimAnimation = MoveAnims.Homerun.Victim
			AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
			AnimationService:playAnimation(Character, SuccessAnimation)

			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
			iFramesService:AddAlliFrames(EnemyCharacter)

			ReplicateEffects_Set:FireAllClients("Homerun", {
				Char = Character,
				Stage = "hit_normal",
				Victim = EnemyCharacter,
				Animation = SuccessAnimation.AnimationId
			})


			-- "Knock" marker: second swing hitbox
			SuccessEvents["Knock"] = Janitor:Add(SuccessTrack:GetMarkerReachedSignal("Knock"):Connect(function()

				local KnockHitbox = ReplicatedHitbox.new(Player)
				KnockHitbox.Instance = HumRP
				KnockHitbox.Size = Vector3.new(5, 5, 5)
				KnockHitbox.Offset = CFrame.new(0, 0, -5)
				KnockHitbox.Ignore = { Character }
				KnockHitbox.destroyAfterOnce = true

				KnockHitbox.onTouch = function(HitCharacter: Model)
					if HitCharacter ~= EnemyCharacter then return end
					local HitHumanoid: Humanoid = HitCharacter.Humanoid
					if HitHumanoid.Health <= 0 then return end

					DamageHandler:TakeDamage(Character, HitHumanoid, 5, nil, nil, false, false, true, true, false, nil, nil)

					ReplicateEffects_Set:FireAllClients("Homerun", {
						Char = Character,
						Stage = "knock",
						Victim = EnemyCharacter
					})
				end

				KnockHitbox:Once()
			end))


			-- "Side" marker: ragdoll + launch enemy to the right
			SuccessEvents["Side"] = Janitor:Add(SuccessTrack:GetMarkerReachedSignal("Side"):Connect(function()

				StunHandler:Unstun(EnemyCharacter, EnemyStun)
				iFramesService:RemoveAlliFrames(EnemyCharacter)
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

				RagdollHandler.ragdoll(EnemyHumanoid, 1)

				-- Launch right with slight upward arc
				knockbackService.Knockback(EnemyHumRP, {
					["duration"] = 0.2,
					["force"] = 50,
					["direction"] = (HumRP.CFrame.RightVector + Vector3.new(0, 0.6, 0)).Unit
				})

				ReplicateEffects_Set:FireAllClients("Homerun", {
					Char = Character,
					Stage = "side_launch",
					Victim = EnemyCharacter
				})
			end))


			SuccessTrack.Stopped:Once(function()
				for _, v in SuccessEvents do v:Disconnect() end

				iFramesService:RemoveAlliFrames(Character)
				StunHandler:Unstun(Character, AttackerStun)
				Janitor:Destroy()
			end)
		end


		-- // FINISHER HIT HANDLER \\ --

		function _handleFinisher(EnemyCharacter, EnemyPlayer, EnemyHumRP, EnemyHumanoid)
			Finisher = true

			AnimationService:stopAll(Character)
			AnimationService:stopAll(EnemyCharacter)

			local FinisherAnimation       = MoveAnims.Homerun.Finisher
			local FinisherVictimAnimation = MoveAnims.Homerun.FinisherVictim

			local FinisherTrack = AnimationService:getAnimationTrack(Character, FinisherAnimation)
			local VictimTrack   = AnimationService:getAnimationTrack(EnemyCharacter, FinisherVictimAnimation)

			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
			iFramesService:AddAlliFrames(EnemyCharacter)
			iFramesService:AddAlliFrames(Character)
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

			-- Small delay before finisher plays (matches original task.delay(0.2))
			task.delay(0.2, function()
				AnimationService:playAnimation(Character, FinisherAnimation)
			end)
			AnimationService:playAnimation(EnemyCharacter, FinisherVictimAnimation)

			ReplicateEffects_Set:FireAllClients("Homerun", {
				Char = Character,
				Stage = "f_start",
				Victim = EnemyCharacter,
				Animation = FinisherVictimAnimation.AnimationId
			})


			-- When victim animation ends: launch left + rocks + kill
			VictimTrack.Stopped:Once(function()

				CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
				StunHandler:Unstun(EnemyCharacter, EnemyStun)
				iFramesService:RemoveAlliFrames(EnemyCharacter)

				RagdollHandler.ragdoll(EnemyHumanoid, 1)

				-- Launch left with upward arc (matches original: -RightVector * 150 + up 50)
				knockbackService.Knockback(EnemyHumRP, {
					["duration"] = 0.3,
					["force"] = 150,
					["direction"] = (-HumRP.CFrame.RightVector + Vector3.new(0, 0.33, 0)).Unit
				})

				-- Kill hit after launch settles (matches original task.delay 1.5)
				task.delay(1.5, function()
					if EnemyCharacter and EnemyCharacter:IsDescendantOf(workspace) then
						DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, true, true, true, nil, nil)
					end
				end)

				ReplicateEffects_Set:FireAllClients("Homerun", {
					Char = Character,
					Stage = "f_launch",
					Victim = EnemyCharacter,
					VictimPos = EnemyHumRP.Position
				})
			end)


			FinisherTrack.Stopped:Once(function()
				iFramesService:RemoveAlliFrames(Character)
				StunHandler:Unstun(Character, AttackerStun)
				CollisionsModule:SetCollisionGroup(Character, "Players")
				Janitor:Destroy()
			end)
		end


		-- Fail anim ends without hitting anyone
		FailTrack.Stopped:Once(function()
			for _, v in FailEvents do v:Disconnect() end

			if not Hit then
				StunHandler:Unstun(Character, AttackerStun)
				Janitor:Destroy()
			end
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, FailAnimation)

		ReplicateEffects_Set:FireAllClients("Homerun", {
			Char = Character,
			Stage = "pa",
			Animation = FailAnimation.AnimationId
		})
	end
}