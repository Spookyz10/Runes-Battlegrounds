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
		local Hit = false

		Character:AddTag("CantRotate")

		local StartAnimation = MoveAnims.Suiryu.lastbreath.Scrapped.Start
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}

		local Dragon = ReplicatedStorage.Resources.Suiryu.OtherDragon:Clone()
		Dragon.RootPart.Anchored = true
		Dragon.RootPart.CFrame = HumRP.CFrame
		Dragon.Parent = workspace.Thrown

		local moveme = Instance.new("BodyVelocity")
		moveme.MaxForce = Vector3.new(100000, 0, 100000)
		moveme.Name = "moveme"
		moveme:SetAttribute("End", 1)
		moveme:SetAttribute("Fallout", 0.96)
		moveme:SetAttribute("Goto", 100)
		moveme:SetAttribute("Speed", 500)

		StartEvents["tap"] = StartTrack:GetMarkerReachedSignal("tap"):Once(function()
			SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Scrapped["Summon Dragon"], Dragon.RootPart)

			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(1, 1, 1) * 60
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = game.Players:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

				if
					iFramesService:HasiFrame(EnemyCharacter, Tool.Name)
					or EnemyHumanoid.Health <= 0
					or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead
				then
					return
				end

				local HitInfo = DamageHandler:TakeDamage(
					Character,
					EnemyHumanoid,
					18,
					nil,
					nil,
					true,
					false,
					true,
					true,
					true,
					nil,
					nil
				)

				if HitInfo.Blocked == true then
					return
				end

				local LookVector = -CFrame.lookAt(EnemyHumRP.Position, HumRP.Position).LookVector

				RagdollHandler.ragdoll(EnemyHumanoid, 2)
				NewKnockback:makeEnemyFaceCharacter(EnemyCharacter, Character)
				NewKnockback:Knockback(
					EnemyCharacter,
					{
						KnockbackType = "Velocity",
						MaxForce = Vector3.new(1, 1, 1) * math.huge,
						Velocity = Vector3.new(LookVector.X * 50, 75, LookVector.Z * 50),
					}
				)
				StartAirDetect:Fire(EnemyCharacter)
			end

			Hitbox:Once()
			Hitbox:Destroy()
		end)

		StartEvents["jump"] = StartTrack:GetMarkerReachedSignal("jump"):Connect(function()
			SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Scrapped["Noises Dragon"], Dragon.RootPart)
		end)

		StartEvents["sprint"] = StartTrack:GetMarkerReachedSignal("sprint"):Once(function()
			moveme.Parent = HumRP
			Character:RemoveTag("CantRotate")

			ReplicateEffects_Set:FireAllClients(
				"lastBreathScrapped",
				{ Stage = "DragonCutsceneGo", Char = Character, Dragon = Dragon }
			)

			local Hitbox = ReplicatedHitbox.new(Player)
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(12, 12, 12)
			Hitbox.Offset = CFrame.new(0, 3, -6)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if
					iFramesService:HasiFrame(EnemyCharacter, Tool.Name)
					or EnemyHumanoid.Health <= 0
					or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead
					or (EnemyCharacter:HasTag("Ragdolled") and not EnemyCharacter:FindFirstChild("inAir"))
				then
					return
				end

				Hit = true

				Hitbox:Destroy()
				Hitbox = nil

				if moveme then
					moveme:Destroy()
					moveme = nil
				end

				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid)
				end

				local Bind = shared.cfolder({
					Name = "HitDragon",
				})
				Bind.Parent = Character

				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)

				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

				Character:AddTag("CantRotate")
				EnemyCharacter:AddTag("CantRotate")

				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				local Weld =
					WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), 11.3)

				HumRP.Anchored = true
				HumRP.CFrame = CFrame.new(HumRP.Position) * CFrame.Angles(0, HumRP.CFrame.Rotation.Y, 0)

				local StartupAnimation = MoveAnims.Suiryu.lastbreath.Scrapped.HitUp
				local StartupTrack = AnimationService:getAnimationTrack(Character, StartupAnimation)
				local StartupEvents = {}

				local UserAnimation = MoveAnims.Suiryu.lastbreath.Scrapped.User
				local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
				local UserEvents = {}

				local VictimAnimation = MoveAnims.Suiryu.lastbreath.Scrapped.Victim
				local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)

				StartupEvents["knee"] = StartupTrack:GetMarkerReachedSignal("knee"):Once(function()
					ReplicateEffects_Set:FireAllClients(
						"lastBreathScrapped",
						{ Stage = "DragonCutsceneKnee", Char = Character, Dragon = Dragon }
					)

					DamageHandler:TakeDamage(
						Character,
						EnemyHumanoid,
						15,
						nil,
						nil,
						false,
						false,
						true,
						false,
						false,
						nil,
						nil
					)
					SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Scrapped["Knee Victim"], EnemyHumRP)
				end)

				StartupEvents["end"] = StartupTrack:GetMarkerReachedSignal("end"):Once(function()
					AnimationService:stopAll(Character)
					AnimationService:playAnimation(Character, UserAnimation)
				end)

				UserEvents["jump"] = UserTrack:GetMarkerReachedSignal("jump"):Once(function()
					SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Scrapped["Jump Dragon"], Dragon.RootPart)
					SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Scrapped["Jump User"], HumRP)

					task.delay(1.1, function()
						ReplicateEffects_Set:FireAllClients(
							"lastBreathScrapped",
							{ Stage = "DragonCutsceneKanji", Char = Character }
						)

						task.delay(0.3, function()
							ReplicateEffects_Set:FireAllClients(
								"lastBreathScrapped",
								{
									Stage = "DragonCutsceneDropEvent",
									Char = Character,
									Dragon = Dragon,
									Targ = EnemyCharacter,
								}
							)
						end)
					end)

					task.delay(5, function()
						ReplicateEffects_Set:FireAllClients(
							"lastBreathScrapped",
							{ Stage = "DragonCutsceneExplode", Char = Character }
						)
						SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Scrapped["Explosion Buildup"], HumRP)

						task.delay(1, function()
							SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Scrapped.Explosion, HumRP)
						end)
					end)
				end)

				UserEvents["end"] = UserTrack:GetMarkerReachedSignal("end"):Once(function()
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end

					if Dragon then
						Dragon:Destroy()
						Dragon = nil
					end

					if Bind then
						Bind:Destroy()
						Bind = nil
					end

					local LookVector = -CFrame.lookAt(EnemyHumRP.Position, HumRP.Position).LookVector

					DamageHandler:TakeDamage(
						Character,
						EnemyHumanoid,
						EnemyHumanoid.Health,
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

					RagdollHandler.ragdoll(EnemyHumanoid, 3)
					NewKnockback:makeEnemyFaceCharacter(EnemyCharacter, Character)
					NewKnockback:Knockback(
						EnemyCharacter,
						{
							KnockbackType = "Velocity",
							MaxForce = Vector3.new(1, 1, 1) * math.huge,
							Velocity = Vector3.new(LookVector.X * 100, 125, LookVector.Z * 100),
						}
					)
					StartAirDetect:Fire(EnemyCharacter)

					iFramesService:RemoveAlliFrames(EnemyCharacter)
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
					EnemyCharacter:RemoveTag("CantRotate")
					StunHandler:Unstun(EnemyCharacter, EnemyStun)
				end)

				VictimTrack.Stopped:Once(function()
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end

					iFramesService:RemoveAlliFrames(EnemyCharacter)
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
					EnemyCharacter:RemoveTag("CantRotate")
					StunHandler:Unstun(EnemyCharacter, EnemyStun)
				end)

				UserTrack.Stopped:Once(function()
					HumRP.Anchored = false

					for _, v in Character:GetChildren() do
						if v:IsA("BasePart") then
							v.AssemblyLinearVelocity = Vector3.zero
						end
					end

					if Bind then
						Bind:Destroy()
						Bind = nil
					end

					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end

					if Dragon then
						Dragon:Destroy()
						Dragon = nil
					end

					for _, v in UserEvents do
						v:Disconnect()
					end
					for _, v in StartupEvents do
						v:Disconnect()
					end

					iFramesService:RemoveAlliFrames(Character)
					CollisionsModule:SetCollisionGroup(Character, "Players")
					Character:RemoveTag("CantRotate")
					StunHandler:Unstun(Character, Stun)
				end)

				AnimationService:stopAll(EnemyCharacter)
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)

				AnimationService:stopAll(Character)
				AnimationService:playAnimation(Character, StartupAnimation)

				Weld:Start()

				shared.fireTo(
					ReplicateEffects_Set,
					{ Player, EnemyPlayer },
					{
						"lastBreathScrapped",
						{ Stage = "DragonCutsceneReal", Char = Character, Dragon = Dragon, Target = EnemyCharacter },
					}
				)
			end

			Hitbox:Start()

			task.delay(1.8, function()
				if not Hitbox then
					return
				end

				Hitbox:Destroy()
				Hitbox = nil

				moveme:SetAttribute("Goto", nil)
			end)

			SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Scrapped["Run User"], HumRP)
			SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Scrapped["Run Dragon"], Dragon.RootPart)
		end)

		local function endfunction()
			for _, v in StartEvents do
				v:Disconnect()
			end
			if moveme then
				moveme:Destroy()
				moveme = nil
			end

			if Hit == true then
				return
			end

			if Dragon then
				Dragon:Destroy()
				Dragon = nil
			end

			StunHandler:Unstun(Character, Stun)
		end

		StartEvents["end"] = StartTrack:GetMarkerReachedSignal("end"):Once(function()
			endfunction()
		end)

		StartTrack.Stopped:Once(function()
			endfunction()
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)

		ReplicateEffects_Set:FireAllClients(
			"lastBreathScrapped",
			{ Stage = "DragonCutscene", Char = Character, Dragon = Dragon }
		)
	end,
}
