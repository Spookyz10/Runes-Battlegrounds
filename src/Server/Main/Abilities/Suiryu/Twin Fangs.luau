local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local ReplicatedModules = ReplicatedStorage.Shared.Modules
local RemotesContainer = ReplicatedStorage.Remotes

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local RagdollHandler = require(ServerModules.RagdollHandler)
local NewKnockback = require(ServerModules.BodymoverService)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)

local CollisionsModule = require(ServerModules.CollisionsModule)
local SoundsModule = require(ServerModules.SoundsModule)
local KnockbackModule = require(ServerModules.KnockbackModule)
local ReplicatedHitbox = require(ServerModules.ReplicatedHitboxes)
local StatesHandler = require(ServerModules.StatesHandler)

local Utility = shared.Utility
local WeldSystem = require(ReplicatedModules.WeldSystem)

local Sounds = ServerStorage.Assets.Sounds
local Animations = ServerStorage.Assets.Animations
local Models = ServerStorage.Assets.Models

local Weapons = Models.Weapons

local MoveAnims = Animations.Moves
local MoveSounds = Sounds.Moves

local CombatAnims = Animations.Combat
local CombatSounds = Sounds.Combat

local ComSet = RemotesContainer.Comunicator.Set
local ComGet = RemotesContainer.Comunicator.Get

local ReplicateEffects_Set = RemotesContainer.Replicate.Set

local rad = math.rad
local StartAirDetect = ServerStorage.Bindables.AirDetector

local Assets = shared.Assets

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = { workspace.Map }
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		local Victim: Model = nil
		local VictimInfo = { Stun = nil, Weld = nil }
		local HighShake = true
		local Replicated = false
		local SliceSFX

		local UserAnimation = MoveAnims.Suiryu.twinfangs.User
		local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
		local UserEvents = {}

		UserEvents["hit"] = UserTrack:GetMarkerReachedSignal("hit"):Connect(function()
			if not Replicated then
				Replicated = true

				ReplicateEffects_Set:FireAllClients(
					"twinfangs",
					{ Char = Character, AnimationId = UserAnimation.AnimationId }
				)
				SliceSFX = SoundsModule:PlaySound(MoveSounds.Suiryu.twinfangs.User, Character.Torso)
			end

			HighShake = not HighShake

			if Victim then
				DamageHandler:TakeDamage(
					Character,
					Victim.Humanoid,
					2.5,
					nil,
					nil,
					false,
					false,
					true,
					false,
					false,
					nil
				)
			end

			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(10, 8, 10)
			Hitbox.Offset = CFrame.new(0, (Hitbox.Size.Y / 2) - 3, -5)
			Hitbox.Ignore = { Character, Victim }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: Humanoid = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if
					iFramesService:HasiFrame(EnemyCharacter, Tool.Name)
					or EnemyHumanoid.Health <= 0
					or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead
					or (EnemyCharacter:HasTag("Ragdolled") and not EnemyCharacter:FindFirstChild("inAir"))
				then
					return
				end

				local HitInfo = DamageHandler:TakeDamage(
					Character,
					EnemyHumanoid,
					2.5,
					Victim ~= nil and 1 or nil,
					nil,
					false,
					true,
					true,
					false,
					false,
					nil
				)

				if not Victim then
					Victim = EnemyCharacter

					VictimInfo.Stun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
					VictimInfo.Weld =
						WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), 6)

					AnimationService:stopAll(EnemyCharacter)

					CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

					EnemyCharacter:AddTag("CantRotate")

					iFramesService:AddAlliFrames(Character)
					iFramesService:AddAlliFrames(EnemyCharacter)

					local VictimAnimation = MoveAnims.Suiryu.twinfangs.Victim
					local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)

					AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
					VictimTrack.TimePosition = UserTrack.TimePosition - 0.333

					VictimInfo.Weld:Start(nil, EnemyPlayer or Player)

					SoundsModule:PlaySound(MoveSounds.Suiryu.twinfangs.Victim, EnemyCharacter.Torso).TimePosition =
						SliceSFX.TimePosition
				end
			end

			Hitbox:Once()
			Hitbox:Destroy()

			shared.fireTo(
				ReplicateEffects_Set,
				{ Player, PlayersService:GetPlayerFromCharacter(Victim) },
				{ "ShakeCamera", { Intensity = HighShake and 3 or 2 } }
			)
		end)

		UserEvents["second"] = UserTrack:GetMarkerReachedSignal("second"):Once(function()
			if not Victim then
				local Hitbox = HitboxHandler.new()
				Hitbox.Instance = HumRP
				Hitbox.Size = Vector3.new(10, 8, 10)
				Hitbox.Offset = CFrame.new(0, (Hitbox.Size.Y / 2) - 3, -5)
				Hitbox.Ignore = { Character, Victim }
				Hitbox.onTouch = function(EnemyCharacter)
					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
					local EnemyHumRP: Humanoid = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					if
						Victim
						or iFramesService:HasiFrame(EnemyCharacter, Tool.Name)
						or EnemyHumanoid.Health <= 0
						or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead
						or (EnemyCharacter:HasTag("Ragdolled") and not EnemyCharacter:FindFirstChild("inAir"))
					then
						return
					end

					DamageHandler:TakeDamage(
						Character,
						EnemyHumanoid,
						5,
						nil,
						nil,
						false,
						true,
						true,
						false,
						false,
						nil
					)

					Victim = EnemyCharacter

					VictimInfo.Stun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
					VictimInfo.Weld =
						WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), 6)

					AnimationService:stopAll(EnemyCharacter)

					CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

					EnemyCharacter:AddTag("CantRotate")

					iFramesService:AddAlliFrames(Character)
					iFramesService:AddAlliFrames(EnemyCharacter)

					local VictimAnimation = MoveAnims.Suiryu.twinfangs.Victim
					local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)

					AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
					VictimTrack.TimePosition = UserTrack.TimePosition - 0.333

					VictimInfo.Weld:Start(nil, EnemyPlayer or Player)
				end

				Hitbox:Once()
				Hitbox:Destroy()
			else
				DamageHandler:TakeDamage(Character, Victim.Humanoid, 5, nil, nil, false, true, true, false, false, nil)
			end

			if not Victim then
				local MissAnimation = MoveAnims.Suiryu.twinfangs.Miss
				local MissTrack = AnimationService:getAnimationTrack(Character, MissAnimation)

				MissTrack.Stopped:Once(function()
					StunHandler:Unstun(Character, Stun)
				end)

				AnimationService:stopAll(Character)
				AnimationService:playAnimation(Character, MissAnimation)

				SoundsModule:PlaySound(MoveSounds.Suiryu.twinfangs.Miss, Character.Torso)
				SoundsModule:PlaySound(MoveSounds.Suiryu.twinfangs.MissBackground, Character.Torso)
			else
				Character:AddTag("CantRotate")

				ReplicateEffects_Set:FireAllClients(
					"twinfangs",
					{ Char = Character, AnimationId = UserAnimation.AnimationId, second = true }
				)
				shared.fireTo(
					ReplicateEffects_Set,
					{ Player, PlayersService:GetPlayerFromCharacter(Victim) },
					{ "ShakeCamera", { Intensity = 8 } }
				)

				task.delay(1.2, function()
					SoundsModule:PlaySound(MoveSounds.Suiryu.twinfangs.Second, Character.Torso)
				end)
			end
		end)

		UserEvents["last"] = UserTrack:GetMarkerReachedSignal("last"):Once(function()
			if not Victim then
				return
			end

			local Weld = VictimInfo.Weld
			local EnemyStun = VictimInfo.Stun

			if Weld then
				pcall(function()
					Weld:Stop()
				end)
			end

			StunHandler:Unstun(Victim, EnemyStun)
			Victim:RemoveTag("CantRotate")
			iFramesService:RemoveAlliFrames(Victim)
			CollisionsModule:SetCollisionGroup(Victim, "Players")

			DamageHandler:TakeDamage(Character, Victim.Humanoid, 5, nil, nil, false, false, true, false, true, nil, nil)
			RagdollHandler.ragdoll(Victim.Humanoid, 2)

			local MainCF = Victim.HumanoidRootPart.CFrame
			for RockValue = 1, 3 do
				local Position = {
					Effect = "Ground Crater",
					Seed = math.random(1, 8) + RockValue,
					start = Victim.HumanoidRootPart.Position + Vector3.new(0, 0.10000000149011612, 0, 0),
					["end"] = Vector3.new(0, -14, 0, 0),
					amount = 6 + RockValue / 2,
					nosound = true,
					nosmoke = RockValue > 2,
				}

				local minusValue = false
				if RockValue <= 2 then
					minusValue = {
						minus = 0,
					}
				end

				Position.stronger = minusValue
				Position.sizemult = 0.55 * RockValue
				Position.size = 0.85 * RockValue

				ReplicateEffects_Set:FireAllClients("Ground Crater", Position)
			end

			shared.fireTo(
				ReplicateEffects_Set,
				{ Player, PlayersService:GetPlayerFromCharacter(Victim) },
				{ "ShakeCamera", { Intensity = 18 } }
			)

			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = MainCF
			Hitbox.Size = Vector3.new(10, 10, 10)
			Hitbox.Ignore = { Character, Victim }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
					return
				end

				DamageHandler:TakeDamage(
					Character,
					EnemyHumanoid,
					7,
					nil,
					nil,
					false,
					false,
					true,
					false,
					true,
					nil,
					nil
				)
				RagdollHandler.ragdoll(EnemyHumanoid, 2)
				NewKnockback:Knockback(
					EnemyCharacter,
					{ KnockbackType = "Velocity", MaxForce = Vector3.new(1, 75000, 1), Velocity = Vector3.new(0, 75, 0) }
				)
			end

			Hitbox:Once()
			Hitbox:Destroy()
		end)

		UserTrack.Stopped:Once(function()
			if not Victim then
				return
			end

			for _, v in UserEvents do
				v:Disconnect()
			end

			StunHandler:Unstun(Character, Stun)
			Character:RemoveTag("CantRotate")
			iFramesService:RemoveAlliFrames(Character)
			CollisionsModule:SetCollisionGroup(Character, "Players")
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)

		SoundsModule:PlaySound(MoveSounds.Suiryu.twinfangs.Start, Character.Torso)
		SoundsModule:PlaySound(MoveSounds.Suiryu.twinfangs.StartExtra, Character.Torso)

		StatesHandler.SkillText(Player, "TWIN FANGS [USED]")
	end,
}
