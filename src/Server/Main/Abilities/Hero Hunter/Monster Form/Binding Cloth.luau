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
local HuntersCloth = require(ServerModules.Other.HuntersCloth)

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

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		local StartAnimation = MoveAnims["Hero Hunter"]["Monster Form"]["Binding Cloth"].Start
		local StartTrack, StartEvents = AnimationService:getAnimationTrack(Character, StartAnimation)

		local Hit = false

		local MovementContainer = {}
		local Assets = {}

		local function Movement(Speed, Time)
			for _, Vel in pairs(MovementContainer) do
				Vel:Destroy()
			end

			local moveme = Instance.new("BodyVelocity")

			table.insert(Assets, moveme)
			table.insert(MovementContainer, moveme)

			moveme.MaxForce = Vector3.new(40000, 0, 40000)
			moveme.Name = "moveme"
			moveme:SetAttribute("End", 16)
			moveme:SetAttribute("Fallout", 0.93)
			moveme:SetAttribute("Speed", Speed or 60)
			moveme.Parent = HumRP

			Debris:AddItem(moveme, Time or 5)
		end

		local DragHitbox = ReplicatedHitbox.new(Player)
		DragHitbox.Instance = HumRP
		DragHitbox.Size = Vector3.new(6, 6, 9)
		DragHitbox.Offset = CFrame.new(0, 0, -3.5)
		DragHitbox.Ignore = { Character }
		DragHitbox.onTouch = function(EnemyCharacter)
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)

			if
				Hit == true
				or iFramesService:HasiFrame(EnemyCharacter, Tool.Name)
				or EnemyHumanoid.Health <= 0
				or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead
			then
				return
			end

			local HitInfo = DamageHandler:TakeDamage(
				Character,
				EnemyHumanoid,
				3,
				nil,
				nil,
				true,
				EnemyCharacter:HasTag("DEATH") and true or false,
				true,
				true,
				false,
				nil,
				nil
			)
			if HitInfo.Blocked == true or HitInfo.Countered then
				return
			end
			Hit = true

			pcall(function()
				DragHitbox:Destroy()
			end)

			if EnemyCharacter:HasTag("Ragdolled") then
				RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
			end

			EnemyCharacter:AddTag("CantRotate")

			iFramesService:AddAlliFrames(Character)
			iFramesService:AddAlliFrames(EnemyCharacter)

			CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
			local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3), -1)

			local UserAnimation = MoveAnims["Hero Hunter"]["Monster Form"]["Binding Cloth"].User
			local VictimAnimation = MoveAnims["Hero Hunter"]["Monster Form"]["Binding Cloth"].Victim

			local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
			local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

			table.insert(
				UserEvents,
				UserTrack:GetMarkerReachedSignal("pull"):Connect(function()
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 3 } })
				end)
			)

			table.insert(
				UserEvents,
				UserTrack:GetMarkerReachedSignal("punch"):Once(function()
					pcall(function()
						Movement(90, 0.5)
					end)

					DamageHandler:TakeDamage(
						Character,
						EnemyHumanoid,
						3,
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
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 4.5 } })
				end)
			)

			table.insert(
				UserEvents,
				UserTrack:GetMarkerReachedSignal("kick"):Connect(function()
					pcall(function()
						Movement(95, 0.5)
					end)

					DamageHandler:TakeDamage(
						Character,
						EnemyHumanoid,
						3,
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
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 4.5 } })
				end)
			)

			table.insert(
				UserEvents,
				UserTrack:GetMarkerReachedSignal("swing"):Once(function()
					pcall(function()
						Movement(100, 0.5)
					end)
				end)
			)

			table.insert(
				UserEvents,
				UserTrack:GetMarkerReachedSignal("slam"):Once(function()
					AnimationService:stopAll(EnemyCharacter)

					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end

					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					iFramesService:RemoveAlliFrames(EnemyCharacter)
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
					EnemyCharacter:RemoveTag("CantRotate")

					RagdollHandler.ragdoll(EnemyHumanoid, 2.25)
					DamageHandler:TakeDamage(
						Character,
						EnemyHumanoid,
						6,
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

					local GoalCF = HumRP.CFrame * CFrame.new(0, 0, -13)

					local SlammedBind = Instance.new("CFrameValue")
					SlammedBind.Name = "Slammed"
					SlammedBind.Parent = Character
					SlammedBind.Value = GoalCF
					Debris:AddItem(SlammedBind, 4)

					task.spawn(function()
						shared.fireTo(
							ReplicateEffects_Set,
							{ Player, EnemyPlayer },
							{ "ShakeCamera", { Intensity = 5 } }
						)

						local LoopTask = nil
						LoopTask = task.spawn(function()
							local PastTime = 0
							while true do
								if PastTime < 0.4 then
									PastTime += task.wait()
									continue
								end

								if EnemyCharacter and EnemyCharacter.Parent then
									local Velocity = EnemyHumRP.AssemblyLinearVelocity
									local HitRay = workspace:Raycast(
										EnemyHumRP.Position,
										Vector3.new(
											math.clamp(Velocity.X, -10.3, 10.3),
											math.clamp(Velocity.Y, -10.3, 10.3),
											math.clamp(Velocity.Z, -10.3, 10.3)
										),
										MapRayParams
									)
									if HitRay then
										local Position = HitRay.Position

										ReplicateEffects_Set:FireAllClients("Ground Crater", {
											Seed = math.random(1, 2000000000),
											start = Position + Vector3.new(0, 0.10000000149011612, 0, 0),
											["end"] = Vector3.new(0, -24, 0, 0),
											amount = 4,
											size = 0.2,
											nosmoke = true,
											nosound = false,
										})

										ReplicateEffects_Set:FireAllClients("Ground Crater", {
											Seed = math.random(1, 2000000000),
											start = Position + Vector3.new(0, 0.10000000149011612, 0, 0),
											["end"] = Vector3.new(0, -14, 0, 0),
											amount = 5,
											sizemult = 1.55,
											size = 1.4,
											nosound = true,
										})

										NewKnockback:Knockback(
											EnemyCharacter,
											{
												KnockbackType = "Velocity",
												MaxForce = Vector3.new(1, 100000, 1),
												Velocity = HumRP.CFrame.UpVector * 75,
											}
										)
										break
									else
										task.wait()
									end
								else
									break
								end
							end

							LoopTask = nil
						end)

						task.delay(6, function()
							pcall(function()
								task.cancel(LoopTask)
							end)
							LoopTask = nil
						end)

						SoundsModule:PlaySound(
							MoveSounds["Hero Hunter"]["Monster Form"]["Binding Cloth"].Craters.Crater,
							GoalCF
						)
					end)
				end)
			)

			VictimTrack.Stopped:Once(function()
				if Weld then
					pcall(function()
						Weld:Stop()
					end)
					Weld = nil
				end

				StunHandler:Unstun(EnemyCharacter, EnemyStun)
				iFramesService:RemoveAlliFrames(EnemyCharacter)
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
				EnemyCharacter:RemoveTag("CantRotate")
			end)

			UserTrack.Stopped:Once(function()
				for _, v in Assets do
					if v and v.Parent then
						v:Destroy()
					end
				end

				if Weld then
					pcall(function()
						Weld:Stop()
					end)
					Weld = nil
				end

				pcall(function()
					HuntersCloth.Delete(Character)
				end)
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
				CollisionsModule:SetCollisionGroup(Character, "Players")
			end)

			HuntersCloth.Trigger(Character, EnemyCharacter, true)

			AnimationService:stopAll(Character)
			AnimationService:stopAll(EnemyCharacter)
			AnimationService:playAnimation(Character, UserAnimation)
			AnimationService:playAnimation(EnemyCharacter, VictimAnimation)

			Weld:Start(0.3, EnemyPlayer, Player)

			ReplicateEffects_Set:FireAllClients("BindingCloth", { Char = Character, Hit = EnemyCharacter })

			SoundsModule:PlaySound(MoveSounds["Hero Hunter"]["Monster Form"]["Binding Cloth"].User, Character.Torso)
			SoundsModule:PlaySound(
				MoveSounds["Hero Hunter"]["Monster Form"]["Binding Cloth"].Victim,
				EnemyCharacter.Torso
			)
		end

		table.insert(
			StartEvents,
			StartTrack:GetMarkerReachedSignal("drag"):Once(function()
				DragHitbox:Start(0.36, true)
			end)
		)

		table.insert(StartEvents, StartTrack:GetMarkerReachedSignal("stopdrag"):Once(function() end))

		StartTrack.Stopped:Once(function()
			if not Hit then
				task.delay(0.5, function()
					for _, v in Assets do
						if v and v.Parent then
							v:Destroy()
						end
					end
				end)

				pcall(function()
					HuntersCloth.Delete(Character)
				end)
				StatesHandler.DoEndLag(Player, Stun, 0.4)
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)

		HuntersCloth.Trigger(Character, nil, false)

		ReplicateEffects_Set:FireAllClients(
			"BindingClothSwing",
			{ Char = Character, Anim = StartAnimation.AnimationId }
		)

		SoundsModule:PlaySound(MoveSounds["Hero Hunter"]["Monster Form"]["Binding Cloth"].Startup, HumRP)
	end,
}
