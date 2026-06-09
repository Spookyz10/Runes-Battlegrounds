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

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = {
	workspace.Map.Arena,
	workspace.Map.Miscellaneous,
	workspace.Map.Borders
}
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Janitor = Trove.new()

		local AttackerStun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		-- Animations
		local LeapAnimation   = MoveAnims["Ground Slam"].Leap
		local HitAnimation    = MoveAnims["Ground Slam"].Hit
		local AirAnimation    = MoveAnims["Ground Slam"].Air
		local FinisherAnimation = MoveAnims["Ground Slam"].Finisher
		local VictimAnimation = MoveAnims["Ground Slam"].Victim

		local LeapTrack    = AnimationService:getAnimationTrack(Character, LeapAnimation)
		local LeapEvents   = {}

		local AirHitEnemy  = nil  -- enemy hit during the leap air phase
		local Finisher     = false


		-- // LEAP PHASE \\ --

		-- "start" marker: launch attacker into the air, open head hitbox
		LeapEvents["start"] = Janitor:Add(LeapTrack:GetMarkerReachedSignal("start"):Connect(function()

			-- Launch attacker forward and upward
			knockbackService.Knockback(HumRP, {
				["duration"] = 0.2,
				["force"] = 80,
				["direction"] = (HumRP.CFrame.LookVector + Vector3.new(0, 0.7, 0)).Unit
			})

			Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)

			ReplicateEffects_Set:FireAllClients("GroundSlam", {
				Char = Character,
				Stage = "leap_start"
			})

			-- Head-level hitbox that moves with attacker during leap
			local HeadHitbox = ReplicatedHitbox.new(Player)
			HeadHitbox.Instance = HumRP
			HeadHitbox.Size = Vector3.new(2, 2, 2)
			HeadHitbox.Offset = CFrame.new(0, 3, 0)
			HeadHitbox.Ignore = { Character }
			HeadHitbox.destroyAfterOnce = true

			HeadHitbox.onTouch = function(EnemyCharacter: Model)
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
				if AirHitEnemy then return end
				AirHitEnemy = EnemyCharacter

				-- Stop leap, transition to Air anim
				AnimationService:stopAll(Character)
				AnimationService:playAnimation(Character, AirAnimation)
				local AirTrack = AnimationService:getAnimationTrack(Character, AirAnimation)
				local AirEvents = {}

				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				iFramesService:AddAlliFrames(EnemyCharacter)

				-- Spike enemy downward
				knockbackService.Knockback(EnemyHumRP, {
					["duration"] = 0.15,
					["force"] = 100,
					["direction"] = Vector3.new(0, -1, 0)
				})

				ReplicateEffects_Set:FireAllClients("GroundSlam", {
					Char = Character,
					Stage = "air_hit",
					Victim = EnemyCharacter
				})

				-- Check for finisher (health <= 15%)
				local isFinisher = EnemyHumanoid.Health <= EnemyHumanoid.MaxHealth * 0.15

				if isFinisher then
					Finisher = true

					AnimationService:stopAll(EnemyCharacter)
					AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
				end

				-- "Hit" marker on Air anim: small follow-up hitbox spike
				AirEvents["Hit"] = Janitor:Add(AirTrack:GetMarkerReachedSignal("Hit"):Connect(function()

					local SpikeHitbox = ReplicatedHitbox.new(Player)
					SpikeHitbox.Instance = EnemyHumRP
					SpikeHitbox.Size = Vector3.new(5, 5, 5)
					SpikeHitbox.Offset = CFrame.new(0, 0, 0)
					SpikeHitbox.Ignore = { Character }
					SpikeHitbox.destroyAfterOnce = true

					SpikeHitbox.onTouch = function(HitCharacter: Model)
						if HitCharacter ~= EnemyCharacter then return end
						local HitHumanoid: Humanoid = HitCharacter.Humanoid
						if HitHumanoid.Health <= 0 then return end

						DamageHandler:TakeDamage(Character, HitHumanoid, 3, nil, nil, false, false, true, true, false, nil, nil)

						knockbackService.Knockback(EnemyHumRP, {
							["duration"] = 0.15,
							["force"] = 100,
							["direction"] = Vector3.new(0, -1, 0)
						})
					end

					SpikeHitbox:Once()
				end))

				AirTrack.Stopped:Once(function()
					for _, v in AirEvents do v:Disconnect() end

					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					iFramesService:RemoveAlliFrames(EnemyCharacter)
				end)
			end

			-- Hitbox active for the full leap duration (destroyed on "end" marker or touch)
			HeadHitbox:Start()

			-- Store reference so we can stop it on "end"
			LeapEvents["_headHitbox"] = HeadHitbox
		end))


		-- "slow" marker: bleed off horizontal velocity mid-leap
		LeapEvents["slow"] = Janitor:Add(LeapTrack:GetMarkerReachedSignal("slow"):Connect(function()
			if Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
				local vel = HumRP.AssemblyLinearVelocity
				HumRP.AssemblyLinearVelocity = Vector3.new(vel.X * 0.5, vel.Y, vel.Z * 0.5)
			end

			ReplicateEffects_Set:FireAllClients("GroundSlam", {
				Char = Character,
				Stage = "leap_slow"
			})
		end))


		-- "end" marker: leap is over, land and play Hit anim
		LeapEvents["end"] = Janitor:Add(LeapTrack:GetMarkerReachedSignal("end"):Connect(function()

			-- Stop head hitbox if it never connected
			if LeapEvents["_headHitbox"] then
				pcall(function() LeapEvents["_headHitbox"]:Stop() end)
				LeapEvents["_headHitbox"] = nil
			end

			AnimationService:stopAll(Character)
			AnimationService:playAnimation(Character, HitAnimation)
			local HitTrack = AnimationService:getAnimationTrack(Character, HitAnimation)
			local HitEvents = {}


			-- "Slam" marker: ground pound hitbox + VFX
			HitEvents["Slam"] = Janitor:Add(HitTrack:GetMarkerReachedSignal("Slam"):Connect(function()

				ReplicateEffects_Set:FireAllClients("GroundSlam", {
					Char = Character,
					Stage = "slam",
					HRPPos = HumRP.Position
				})

				-- Ground AoE hitbox
				local SlamHitbox = ReplicatedHitbox.new(Player)
				SlamHitbox.Instance = HumRP
				SlamHitbox.Size = Vector3.new(10, 3, 10)
				SlamHitbox.Offset = CFrame.new(0, -3, 0)
				SlamHitbox.Ignore = { Character }
				SlamHitbox.destroyAfterOnce = false

				SlamHitbox.onTouch = function(EnemyCharacter: Model)
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					if iFramesService:HasiFrame(EnemyCharacter, Tool.Name)
						or EnemyHumanoid.Health <= 0
						or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then
						return
					end

					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, true, false, false, true, true, nil, nil)
					if HitInfo.Blocked == true then return end

					StunHandler:Stun(EnemyCharacter, 1.5, true, 0, 0, true)
					RagdollHandler.ragdoll(EnemyHumanoid, 1.5)

					knockbackService.Knockback(EnemyHumRP, {
						["duration"] = 0.2,
						["force"] = 30,
						["direction"] = (EnemyHumRP.Position - HumRP.Position).Unit + Vector3.new(0, 0.3, 0)
					})

					-- Check finisher on slam targets too
					local isFinisher = EnemyHumanoid.Health <= EnemyHumanoid.MaxHealth * 0.15
					if isFinisher and not Finisher then
						Finisher = true

						AnimationService:stopAll(Character)
						AnimationService:playAnimation(Character, FinisherAnimation)
						local FinisherTrack = AnimationService:getAnimationTrack(Character, FinisherAnimation)
						local FinisherEvents = {}

						AnimationService:stopAll(EnemyCharacter)
						AnimationService:playAnimation(EnemyCharacter, VictimAnimation)

						iFramesService:AddAlliFrames(EnemyCharacter)
						local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

						ReplicateEffects_Set:FireAllClients("GroundSlam", {
							Char = Character,
							Stage = "f_start",
							Victim = EnemyCharacter,
							Animation = FinisherAnimation.AnimationId
						})

						FinisherEvents["Slam"] = Janitor:Add(FinisherTrack:GetMarkerReachedSignal("Slam"):Connect(function()
							DamageHandler:TakeDamage(Character, EnemyHumanoid, 10, nil, nil, false, false, true, true, false, nil, nil)

							ReplicateEffects_Set:FireAllClients("GroundSlam", {
								Char = Character,
								Stage = "f_slam",
								HRPPos = HumRP.Position,
								Victim = EnemyCharacter
							})
						end))

						FinisherTrack.Stopped:Once(function()
							for _, v in FinisherEvents do v:Disconnect() end

							StunHandler:Unstun(EnemyCharacter, EnemyStun)
							iFramesService:RemoveAlliFrames(EnemyCharacter)
							CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
							RagdollHandler.ragdoll(EnemyHumanoid, 3)

							iFramesService:RemoveAlliFrames(Character)
							StunHandler:Unstun(Character, AttackerStun)
							Janitor:Destroy()
						end)
					end

					ReplicateEffects_Set:FireAllClients("GroundSlam", {
						Char = Character,
						Stage = "slam_hit",
						Victim = EnemyCharacter
					})
				end

				SlamHitbox:Start()
				task.delay(0.2, function()
					SlamHitbox:Stop()
				end)
			end))


			HitTrack.Stopped:Once(function()
				for _, v in HitEvents do v:Disconnect() end

				if not Finisher then
					iFramesService:RemoveAlliFrames(Character)
					StunHandler:Unstun(Character, AttackerStun)
					Janitor:Destroy()
				end
			end)
		end))


		LeapTrack.Stopped:Once(function()
			for _, v in LeapEvents do
				if type(v) == "table" or type(v) == "userdata" then
					pcall(function()
						if v.Disconnect then v:Disconnect() end
					end)
				end
			end

			if not AirHitEnemy then
				-- Leap ended without air-hitting anyone, unstun and continue to Hit anim via "end" marker
			end
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, LeapAnimation)

		ReplicateEffects_Set:FireAllClients("GroundSlam", {
			Char = Character,
			Stage = "pa",
			Animation = LeapAnimation.AnimationId
		})
	end
}