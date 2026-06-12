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

local Utility = shared.Utility
local WeldSystem = require(ReplicatedModules.WeldSystem)
local SoundHandler = require(ReplicatedModules.SoundHandler)
local Trove = require(ReplicatedModules.Trove)

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
MapRayParams.FilterDescendantsInstances = {
	workspace.Map.Arena,
	workspace.Map.Miscellaneous,
	workspace.Map.Borders,
}
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 5, 0, true)

		local StartupAnimation = MoveAnims["Hero Hunter"].preysperil.Startup
		local StartupTrack = AnimationService:getAnimationTrack(Character, StartupAnimation)

		local COUNTER = false
		local CounterConnection

		StartupTrack.Stopped:Once(function()
			if COUNTER == false then
				StunHandler:Unstun(Character, Stun)
			end

			if CounterConnection then
				CounterConnection:Disconnect()
				CounterConnection = nil
			end

			Character:RemoveTag("Countering")
			Character:RemoveTag("Prey's Peril")
		end)

		Character:AddTag("Countering")
		Character:AddTag("Prey's Peril")

		CounterConnection = Character.ChildAdded:Connect(function(child: ObjectValue?)
			if child.Name == "DamagedLog" and child:HasTag("Counterable") then
				Character:RemoveTag("Countering")
				Character:RemoveTag("Prey's Peril")
				CounterConnection:Disconnect()
				CounterConnection = nil

				COUNTER = true

				local playerClass = shared.playerClasses[Player.UserId]
				if playerClass then
					playerClass.TitlesProgress.Counters += 1
					Player:SetAttribute("CountersProgress", playerClass.TitlesProgress.Counters)
				end

				local EnemyCharacter: Model = child.Value
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				Stun:SetAttribute("WalkSpeed", 0)

				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)

				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

				Character:AddTag("CantRotate")
				EnemyCharacter:AddTag("CantRotate")

				local UserAnimation = MoveAnims["Hero Hunter"].preysperil.User
				local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

				table.insert(
					UserEvents,
					UserTrack:GetMarkerReachedSignal("getready"):Once(function()
						RagdollHandler.ragdoll(EnemyHumanoid, 10)
						NewKnockback:Knockback(
							EnemyCharacter,
							{
								KnockbackType = "Velocity",
								MaxForce = Vector3.new(50000, 50000, 50000),
								Velocity = EnemyHumRP.CFrame.UpVector * 30,
								Time = 0.1,
							}
						)
					end)
				)

				table.insert(
					UserEvents,
					UserTrack:GetMarkerReachedSignal("hit"):Connect(function()
						ReplicateEffects_Set:FireAllClients("flowingwaterhit", { Char = Character })
						shared.fireTo(
							ReplicateEffects_Set,
							{ Player, EnemyPlayer },
							{ "ShakeCamera", { Intensity = 4 } }
						)
					end)
				)

				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("firstswing"):Once(function() end))

				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("swing"):Connect(function() end))

				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("stance"):Once(function() end))

				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("grip"):Once(function() end))

				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("lastswing"):Once(function() end))

				table.insert(
					UserEvents,
					UserTrack:GetMarkerReachedSignal("finalhit"):Once(function()
						shared.fireTo(
							ReplicateEffects_Set,
							{ Player, EnemyPlayer },
							{ "ShakeCamera", { Intensity = 7 } }
						)

						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						EnemyCharacter:RemoveTag("CantRotate")
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

						NewKnockback:Knockback(
							EnemyCharacter,
							{
								KnockbackType = "Velocity",
								MaxForce = Vector3.new(75000, 75000, 75000),
								Velocity = HumRP.CFrame.LookVector * 75 + Vector3.new(0, 15, 0),
							}
						)
						RagdollHandler.ragdoll(EnemyHumanoid, 2)
					end)
				)

				UserTrack.Stopped:Once(function()
					StunHandler:Unstun(Character, Stun)
					Character:RemoveTag("CantRotate")
					iFramesService:RemoveAlliFrames(Character)
					CollisionsModule:SetCollisionGroup(Character, "Players")
				end)

				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)

				AnimationService:playAnimation(Character, UserAnimation)
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartupAnimation)
	end,
}
