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

local Assets = ServerStorage.Assets

local Sounds = Assets.Sounds
local Animations = Assets.Animations
local Models = Assets.Models

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
		local Tag = os.clock() + Player.UserId
		local Bind = Instance.new("Folder")
		Bind.Name = "GrandFissure" .. Tag
		Bind.Parent = Character

		local StartAnimation = MoveAnims.Suiryu.grandfissure.Start
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}

		StartEvents["hit"] = StartTrack:GetMarkerReachedSignal("hit"):Once(function()
			Character:AddTag("CantRotate")

			local MainCF = HumRP.CFrame

			ReplicateEffects_Set:FireAllClients(
				"grandfissurewall",
				{
					Stage = "Start",
					Char = Character,
					Bind = Bind,
					MainCF = MainCF,
					AnimationId = StartAnimation.AnimationId,
				}
			)
			ReplicateEffects_Set:FireAllClients("grandfissurestart", {
				Char = Character,
				AnimationId = MoveAnims.Suiryu.grandfissure.Start.AnimationId,
				MainCF = MainCF,
			})

			ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Last = 1, Intensity = 10 })

			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = MainCF
			Hitbox.Size = Vector3.new(40, 40, 27)
			Hitbox.Offset = CFrame.new(0, (Hitbox.Size.Y / 2) - 3, -13.5)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

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
					25,
					nil,
					nil,
					false,
					false,
					true,
					false,
					false,
					25
				)
				local Finisher = HitInfo.Finisher == true

				if not Finisher then
					RagdollHandler.ragdoll(EnemyHumanoid, 3)
					NewKnockback:Knockback(
						EnemyCharacter,
						{
							KnockbackType = "Velocity",
							MaxForce = Vector3.new(90000, 90000, 90000),
							Velocity = -HumRP.CFrame.LookVector * Vector3.new(75, 0, 75) + Vector3.new(0, 75, 0),
						}
					)
				elseif Finisher and not Hit then
					Hit = true

					EnemyCharacter:AddTag("CantRotate")

					iFramesService:AddAlliFrames(Character)
					iFramesService:AddAlliFrames(EnemyCharacter)

					CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

					AnimationService:stopAll(Character)
					AnimationService:stopAll(EnemyCharacter)

					task.spawn(function()
						task.delay(0.917, function()
							ReplicateEffects_Set:FireAllClients(
								"grandfissurewall",
								{ Stage = "Hit", Char = Character, MainCF = MainCF, Bind = Bind }
							)
						end)

						ReplicateEffects_Set:FireAllClients(
							"grandfissurefinisher",
							{ Char = Character, Victim = EnemyCharacter, Bind = Bind, MainCF = MainCF }
						)
					end)

					local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
					local Weld =
						WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), 12.2)

					local UserAnimation = MoveAnims.Suiryu.grandfissure.User
					local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
					local UserEvents = {}

					UserEvents["kick"] = UserTrack:GetMarkerReachedSignal("kick"):Once(function()
						DamageHandler:TakeDamage(
							Character,
							EnemyHumanoid,
							8,
							nil,
							nil,
							false,
							false,
							true,
							false,
							false,
							nil
						)

						task.wait(0.25)

						AnimationService:stopAll(EnemyCharacter)
						AnimationService:playAnimation(EnemyCharacter, MoveAnims.Suiryu.grandfissure.Victim)
					end)

					UserEvents["knockback"] = UserTrack:GetMarkerReachedSignal("knockback"):Once(function()
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						EnemyCharacter:RemoveTag("CantRotate")
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

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
							nil
						)
						RagdollHandler.ragdoll(EnemyHumanoid, 3, true)
						NewKnockback:Knockback(
							EnemyCharacter,
							{
								KnockbackType = "Velocity",
								MaxForce = Vector3.new(100000, 0, 100000),
								Velocity = HumRP.CFrame.LookVector * 200,
							}
						)
					end)

					UserTrack.Stopped:Once(function()
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						Bind:Destroy()

						StunHandler:Unstun(Character, Stun)
						Character:RemoveTag("CantRotate")
						iFramesService:RemoveAlliFrames(Character)
						CollisionsModule:SetCollisionGroup(Character, "Players")
					end)

					AnimationService:playAnimation(Character, UserAnimation)
					AnimationService:playAnimation(EnemyCharacter, MoveAnims.Suiryu.grandfissure.VictimStart)

					task.delay(0.46, function()
						SoundsModule:PlaySound(MoveSounds.Suiryu.grandfissure.User, Character.Torso)
						SoundsModule:PlaySound(MoveSounds.Suiryu.grandfissure.Victim, EnemyCharacter.Torso)
					end)

					Weld:Start()
				end
			end

			Hitbox:Once()
			Hitbox:Destroy()

			local ignoreContainer = {}
			local humanoidContainer = {}
			local partContainer = {}

			for _, part in pairs(workspace:GetPartBoundsInRadius(Character.PrimaryPart.Position, 60)) do
				if
					(part:GetAttribute("IsTree") or part.Name == "TreeRoot")
					and not table.find(ignoreContainer, part.Parent)
				then
					ReplicateEffects_Set:FireAllClients(
						"shakeTree",
						{
							Tree = part.Parent,
							Intensity = Random.new():NextNumber(5, 10),
							From = Character.PrimaryPart.Position,
							Leaves = true,
						}
					)
				end

				local targetHumanoid = part.Parent:FindFirstChildOfClass("Humanoid")
				if
					targetHumanoid
					and targetHumanoid.Name ~= "FakeHumanoid"
					and not table.find(humanoidContainer, targetHumanoid)
					and targetHumanoid ~= Humanoid
				then
					table.insert(partContainer, part.Parent)
				end
			end
		end)

		StartTrack.Stopped:Once(function()
			for _, v in StartEvents do
				v:Disconnect()
			end

			if not Hit then
				Character:RemoveTag("CantRotate")
				StunHandler:Unstun(Character, Stun)
				Bind:Destroy()
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)

		SoundsModule:PlaySound(MoveSounds.Suiryu.grandfissure.Miss, Character.Torso)

		StatesHandler.SkillText(Player, "GRAND FISSURE [USED]")
	end,
}
