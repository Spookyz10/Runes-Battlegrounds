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
local SoundHandler = require(ReplicatedModules.SoundHandler)

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
		local Hit = nil
		local DidFinisher = false
		local Tag = os.clock() + Player.UserId
		local moveme: BodyVelocity

		local VFXBind = Instance.new("Accessory")
		VFXBind.Name = "VanishingKick" .. Tag
		VFXBind.Parent = Character

		local StartAnimation = MoveAnims.Suiryu.vanishkick.Start
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents: { RBXScriptConnection } = {}

		StartEvents["slow"] = StartTrack:GetMarkerReachedSignal("slow"):Once(function()
			if moveme and moveme.Parent then
				moveme:SetAttribute("Goto", nil)
			end
		end)

		StartEvents["hit"] = StartTrack:GetMarkerReachedSignal("hit"):Once(function()
			local Hitbox = ReplicatedHitbox.new(Player)
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(14, 14, 14)
			Hitbox.Offset = CFrame.new(0, 0, -7)
			Hitbox.Ignore = { Character }
			Hitbox.destroyAfterOnce = true
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
					7.5,
					nil,
					nil,
					false,
					true,
					false,
					true,
					false,
					nil,
					15
				)
				if HitInfo.Countered == true then
					return
				end
				local Finisher = HitInfo.Finisher == true

				if not Hit then
					Hit = EnemyCharacter

					StunHandler:Unstun(Character, Stun)

					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 3 } })
				end

				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid)
				end

				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				SoundsModule:PlaySound(MoveSounds.Suiryu.vanishkick.KickHit, EnemyHumRP)

				if Finisher then
					DidFinisher = true

					Character:SetAttribute("PurpleFinisher", true)

					local FinalStun = StunHandler:Stun(Character, nil, true, 0, 0, true)
					local Weld =
						WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), 2.7)

					AnimationService:stopAll(Character)
					AnimationService:stopAll(EnemyCharacter)

					Character:AddTag("CantRotate")
					EnemyCharacter:AddTag("CantRotate")

					CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

					iFramesService:AddAlliFrames(Character)
					iFramesService:AddAlliFrames(EnemyCharacter)

					local FinisherAnimation = MoveAnims.Suiryu.vanishkick.FinisherUser
					local FinisherTrack = AnimationService:getAnimationTrack(Character, FinisherAnimation)
					local FinisherEvents: { RBXScriptConnection } = {}

					FinisherEvents["smallhit"] = FinisherTrack:GetMarkerReachedSignal("smallhit"):Once(function()
						DamageHandler:TakeDamage(
							Character,
							EnemyHumanoid,
							7.4,
							nil,
							nil,
							false,
							false,
							true,
							true,
							false,
							nil,
							nil
						)
						shared.fireTo(
							ReplicateEffects_Set,
							{ Player, EnemyPlayer },
							{ "ShakeCamera", { Intensity = 4 } }
						)
						ReplicateEffects_Set:FireAllClients(
							"Ground Crater",
							{
								Seed = math.random(1, 2000000000),
								start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0),
								["end"] = Vector3.new(0, -25, 0),
								amount = 4,
								nosound = true,
								size = 0.3,
							}
						)
						ReplicateEffects_Set:FireAllClients(
							"Ground Crater",
							{
								Seed = math.random(1, 2000000000),
								start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0),
								["end"] = Vector3.new(0, -25, 0),
								amount = 3,
								nosound = true,
								size = 2,
							}
						)
					end)

					FinisherEvents["hit"] = FinisherTrack:GetMarkerReachedSignal("hit"):Once(function()
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						StunHandler:Unstun(Character, Stun)
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						EnemyCharacter:RemoveTag("CantRotate")

						DamageHandler:TakeDamage(
							Character,
							EnemyHumanoid,
							EnemyHumanoid.Health,
							nil,
							nil,
							false,
							false,
							true,
							true,
							true,
							nil,
							nil
						)
						shared.fireTo(
							ReplicateEffects_Set,
							{ Player, EnemyPlayer },
							{ "ShakeCamera", { Intensity = 6 } }
						)
						ReplicateEffects_Set:FireAllClients(
							"Ground Crater",
							{
								Seed = math.random(1, 2000000000),
								start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0),
								["end"] = Vector3.new(0, -25, 0),
								amount = 4,
								nosound = true,
								size = 3.2,
							}
						)
						ReplicateEffects_Set:FireClient(Player, "suiryupassiveaura", { Char = Character })
					end)

					FinisherTrack.Stopped:Once(function()
						for _, v in FinisherEvents do
							v:Disconnect()
						end

						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						StunHandler:Unstun(Character, FinalStun)
						CollisionsModule:SetCollisionGroup(Character, "Players")
						iFramesService:RemoveAlliFrames(Character)
						Character:RemoveTag("CantRotate")
					end)

					AnimationService:playAnimation(Character, FinisherAnimation)
					AnimationService:playAnimation(EnemyCharacter, MoveAnims.Suiryu.vanishkick.FinisherVictim)

					SoundsModule:PlaySound(MoveSounds.Suiryu.vanishkick.Finisher.User, Character.Torso)
					SoundsModule:PlaySound(MoveSounds.Suiryu.vanishkick.Finisher.Victim, EnemyCharacter.Torso)
					SoundsModule:PlaySound(MoveSounds.Suiryu.vanishkick.Finisher.Kick, EnemyCharacter.Torso)

					Weld:Start(nil, PlayersService:GetPlayerFromCharacter(EnemyCharacter) or Player)
				else
					EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

					local selfToOtherChar = (EnemyHumRP.Position - HumRP.Position).Unit
					local lookVector = Character.HumanoidRootPart.CFrame.LookVector

					local dotProduct = lookVector:Dot(selfToOtherChar)
					if EnemyHumanoid.FloorMaterial ~= Enum.Material.Air then
						dotProduct = 1
					end

					local at = Character.HumanoidRootPart.Position
					local forward = Character.HumanoidRootPart.CFrame.LookVector
					local lookposition = CFrame.lookAt(at, at + Vector3.new(forward.X, 0, forward.Z))

					require(ServerStorage.Modules.PerfectKnockback).KnockBack(nil, EnemyCharacter, {
						LookVector = lookposition.LookVector,
						LookForce = 58.5,
						LookFinalForce = 55,
						LookAt = lookposition,
						DestroyRagdoll = true,
						GroundStunTime = 0.95,
						Escapable = false,
						FallingDetectDelay = 0.2,
						Dot = dotProduct,
						DotParams = { 0.4, 1 },
						canHitWall = true,
					}, Character)
				end
			end
			Hitbox.functionAfterDestroy = function()
				if DidFinisher or not Hit then
					return
				end

				local Twiced = false

				local function Use()
					if Twiced == true then
						return
					end
					Twiced = true

					local FinalStun = StunHandler:Stun(Character, nil, true, 0, 0, true)
					local GoalCF = Hit.HumanoidRootPart.CFrame

					local UserAnimation = MoveAnims.Suiryu.vanishkick.User
					local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
					local UserEvents: { RBXScriptConnection } = {}

					UserEvents["hit"] = UserTrack:GetMarkerReachedSignal("hit"):Once(function()
						Character:PivotTo(GoalCF)

						local Hitbox = HitboxHandler.new()
						Hitbox.Instance = GoalCF
						Hitbox.Size = Vector3.new(20, 20, 20)
						Hitbox.Ignore = { Character }
						Hitbox.onTouch = function(EnemyCharacter)
							local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
							local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

							if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
								return
							end

							local HitInfo = DamageHandler:TakeDamage(
								Character,
								EnemyHumanoid,
								5,
								nil,
								nil,
								false,
								true,
								true,
								true,
								true,
								nil
							)
							if HitInfo.Countered == true then
								return
							end

							NewKnockback:Knockback(
								EnemyCharacter,
								{
									KnockbackType = "Velocity",
									MaxForce = Vector3.new(1, 75000, 1),
									Velocity = Vector3.new(0, 75, 0),
								}
							)
							RagdollHandler.ragdoll(EnemyHumanoid, 2)
						end

						Hitbox:Once()
						Hitbox:Destroy()

						SoundHandler:AddSound(MoveSounds.Suiryu.vanishkick.FinalHit, Character.Torso)

						ReplicateEffects_Set:FireAllClients(
							"Ground Crater",
							{
								Seed = math.random(1, 2000000000),
								start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0),
								["end"] = Vector3.new(0, -25, 0),
								amount = 9,
								nosound = false,
								size = 1.4,
							}
						)
						ReplicateEffects_Set:FireAllClients(
							"Ground Crater",
							{
								Seed = math.random(1, 2000000000),
								start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0),
								["end"] = Vector3.new(0, -25, 0),
								amount = 6,
								nosound = true,
								size = 0.3,
							}
						)

						shared.fireTo(ReplicateEffects_Set, { Player }, { "ShakeCamera", { Intensity = 6 } })
					end)

					UserTrack.Stopped:Once(function()
						for _, v in UserEvents do
							v:Disconnect()
						end

						StunHandler:Unstun(Character, FinalStun)
						Debris:AddItem(VFXBind, 5)
					end)

					AnimationService:stopAll(Character)
					AnimationService:playAnimation(Character, MoveAnims.Suiryu.vanishkick.User)

					ReplicateEffects_Set:FireAllClients(
						"vanishingkick",
						{ Stage = "Hit", Char = Character, BindName = VFXBind.Name, GoalCF = GoalCF }
					)

					SoundsModule:PlaySound(MoveSounds.Suiryu.vanishkick.Dash, HumRP)
					SoundsModule:PlaySound(MoveSounds.Suiryu.vanishkick.DashStart, HumRP)
					SoundsModule:PlaySound(MoveSounds.Suiryu.vanishkick.StompSwing, HumRP)

					StatesHandler.SkillText(Player, "VANISHING KICK [USED TWICE]")
				end

				local UsedTwice = false
				Character:SetAttribute("VanishingKickStomp", true)

				local Changed = Character:GetAttributeChangedSignal("VanishingKickStomp"):Once(function()
					UsedTwice = true

					Use()
				end)

				task.delay(5, function()
					if UsedTwice then
						return
					end
					VFXBind:Destroy()
					Changed:Disconnect()
					Character:SetAttribute("VanishingKickStomp", nil)
				end)
			end

			Hitbox:Once()
		end)

		StartTrack.Stopped:Once(function()
			for _, v in StartEvents do
				v:Disconnect()
			end

			StunHandler:Unstun(Character, Stun)

			moveme:Destroy()
			moveme = nil

			if not Hit then
				VFXBind:Destroy()
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)

		ReplicateEffects_Set:FireAllClients(
			"vanishingkick",
			{ Char = Character, Stage = "Start", BindName = VFXBind.Name }
		)
		SoundsModule:PlaySound(MoveSounds.Suiryu.vanishkick.Start, HumRP)

		moveme = Instance.new("BodyVelocity")
		moveme.Name = "moveme"
		moveme.MaxForce = Vector3.new(100000, 0, 100000)
		moveme:SetAttribute("RemoveOthers", true)
		moveme:SetAttribute("End", 1)
		moveme:SetAttribute("Fallout", 0.85)
		moveme:SetAttribute("Goto", 100)
		moveme:SetAttribute("Speed", 100)
		moveme.Parent = HumRP
		Debris:AddItem(moveme, 0.8)

		StatesHandler.SkillText(Player, "VANISHING KICK [USED]")
	end,
}
