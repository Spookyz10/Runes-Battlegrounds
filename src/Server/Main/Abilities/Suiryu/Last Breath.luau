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

		local ScrappedVariant = math.random(1, 2) == 1

		if ScrappedVariant or Character:GetAttribute("InstandVariant") then
			local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
			local Hit = false

			Character:AddTag("CantRotate")

			local StartAnimation = MoveAnims.Suiryu.lastbreath.Scrapped.Start
			local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
			local StartEvents = {}

			local Dragon = ReplicatedStorage.Resources.Suiryu.OtherDragon:Clone()
			Dragon.RootPart.CFrame = HumRP.CFrame
			Dragon.Parent = workspace.Thrown

			task.spawn(function()
				for _, v in Dragon:GetChildren() do
					if v:IsA("MeshPart") then
						v.Transparency = 0
					end
				end
			end)

			local AnimationTrack =
				Dragon.AnimationController.Animator:LoadAnimation(MoveAnims.Suiryu.lastbreath.Scrapped.StartDragon)
			local DragonWeld =
				WeldSystem.new(HumRP, Dragon.RootPart, CFrame.new(0, 0, 4) * CFrame.Angles(0, math.pi, 0), 2.5)

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
				Hitbox.Instance = HumRP.CFrame
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

				ReplicateEffects_Set:FireAllClients(
					"Destroy",
					{
						cf = Hitbox.Instance,
						size = Vector3.new(1, 1, 1) * Hitbox.Size,
						burn = false,
						vel = Vector3.new(0, 1, 0) * 200,
					}
				)

				Hitbox:Once()
				Hitbox:Destroy()

				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 3.5, Last = nil })
			end)

			StartEvents["jump"] = StartTrack:GetMarkerReachedSignal("jump"):Connect(function()
				SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Scrapped["Noises Dragon"], Dragon.RootPart)

				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 5, Last = 0.5 })
			end)

			StartEvents["sprint"] = StartTrack:GetMarkerReachedSignal("sprint"):Once(function()
				moveme.Parent = HumRP
				Character:RemoveTag("CantRotate")

				ReplicateEffects_Set:FireAllClients(
					"lastBreathScrapped",
					{ Stage = "DragonCutsceneGo", Char = Character, Dragon = Dragon }
				)
				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 3, Last = 0.4 })

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

					AnimationTrack.TimePosition = 5.05

					Hit = true
					StatesHandler.SkillText(Player, "LAST BREATH [HIT]")

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
						shared.fireTo(
							ReplicateEffects_Set,
							{ Player, EnemyPlayer },
							{ "ShakeCamera", { Intensity = 3, Last = nil } }
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

						task.delay(4.5, function()
							ReplicateEffects_Set:FireAllClients(
								"lastBreathScrapped",
								{ Stage = "DragonCutsceneExplode", Char = Character }
							)
							SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Scrapped["Explosion Buildup"], HumRP)

							task.delay(1, function()
								SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Scrapped.Explosion, HumRP)

								local LastHitbox = HitboxHandler.new()
								LastHitbox.Instance = HumRP.CFrame
								LastHitbox.Size = Vector3.new(1, 1, 1) * 90
								LastHitbox.Ignore = { Character, EnemyCharacter }
								LastHitbox.onTouch = function(NewEnemyCharacter)
									local NewEnemyHumanoid: Humanoid = NewEnemyCharacter.Humanoid
									local NewEnemyHumRP: BasePart = NewEnemyCharacter.HumanoidRootPart

									if
										iFramesService:HasiFrame(NewEnemyCharacter, Tool.Name)
										or NewEnemyHumanoid.Health <= 0
										or NewEnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead
									then
										return
									end

									local HitInfo = DamageHandler:TakeDamage(
										Character,
										NewEnemyHumanoid,
										68,
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

									local LookVector = -CFrame.lookAt(NewEnemyHumRP.Position, HumRP.Position).LookVector

									RagdollHandler.ragdoll(NewEnemyHumanoid, 3)
									NewKnockback:makeEnemyFaceCharacter(NewEnemyCharacter, Character)
									NewKnockback:Knockback(
										NewEnemyCharacter,
										{
											KnockbackType = "Velocity",
											MaxForce = Vector3.new(1, 1, 1) * math.huge,
											Velocity = Vector3.new(LookVector.X * 70, 95, LookVector.Z * 70),
										}
									)
									StartAirDetect:Fire(NewEnemyCharacter)
								end

								ReplicateEffects_Set:FireAllClients(
									"Destroy",
									{
										cf = LastHitbox.Instance,
										size = Vector3.new(1, 1, 1) * LastHitbox.Size,
										burn = true,
										vel = Vector3.new(0, 1, 0) * 200,
									}
								)

								LastHitbox:Once()
								LastHitbox:Destroy()

								if Weld then
									pcall(function()
										Weld:Stop()
									end)
									Weld = nil
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

								local ignoreContainer = {}
								local humanoidContainer = {}
								local partContainer = {}

								for _, part in
									pairs(workspace:GetPartBoundsInRadius(Character.PrimaryPart.Position, 300))
								do
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
						end)
					end)

					local function endDestroy()
						if Weld then
							pcall(function()
								Weld:Stop()
							end)
							Weld = nil
						end

						if DragonWeld then
							pcall(function()
								DragonWeld:Stop()
							end)
							DragonWeld = nil
						end

						AnimationTrack:Stop()

						if Bind then
							Bind:Destroy()
							Bind = nil
						end
					end

					UserEvents["end"] = UserTrack:GetMarkerReachedSignal("end"):Once(function()
						endDestroy()
						AnimationTrack:Stop()

						DamageHandler:TakeDamage(
							Character,
							Humanoid,
							50,
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
						Character:SetPrimaryPartCFrame(
							CFrame.lookAlong(
								ComGet:InvokeClient(Player, { Func = "GetCF", Object = Character.Torso }).Position,
								-HumRP.CFrame.LookVector
							)
						)
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

						endDestroy()

						AnimationTrack:Stop()

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

						Character:SetPrimaryPartCFrame(
							CFrame.lookAlong(
								ComGet:InvokeClient(Player, { Func = "GetCF", Object = Character.Torso }).Position,
								-HumRP.CFrame.LookVector
							)
						)
					end)

					UserTrack.Ended:Once(function()
						ReplicateEffects_Set:FireClient(Player, "fixspeedbug")
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

				if DragonWeld then
					pcall(function()
						DragonWeld:Stop()
					end)
					DragonWeld = nil
				end

				AnimationTrack:Stop()

				StunHandler:Unstun(Character, Stun)
			end

			StartEvents["end"] = StartTrack:GetMarkerReachedSignal("end"):Once(function()
				endfunction()
			end)

			StartTrack.Stopped:Once(function()
				endfunction()
			end)

			AnimationTrack.Stopped:Once(function()
				for _, v in Dragon:GetChildren() do
					if v:IsA("MeshPart") then
						v.Transparency = 1
					end
				end

				Debris:AddItem(Dragon, 5)
			end)

			AnimationService:stopAll(Character)
			AnimationService:playAnimation(Character, StartAnimation)

			ReplicateEffects_Set:FireAllClients(
				"lastBreathScrapped",
				{ Stage = "DragonCutscene", Char = Character, Dragon = Dragon }
			)

			DragonWeld:Start()
			AnimationTrack:Play()
		else
			local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
			local Hit = false
			local Tag = os.clock() + Player.UserId
			local StartedRun = false
			local runtime = 1.8

			local VFXBind = Instance.new("Folder")
			VFXBind.Name = "LastBreath" .. Tag
			VFXBind.Parent = Character

			Character:AddTag("CantRotate")

			local RunStartAnimation = MoveAnims.Suiryu.lastbreath.RunStart
			local RunStartTrack = AnimationService:getAnimationTrack(Character, RunStartAnimation)
			local RunStartEvents = {}

			RunStartTrack.Stopped:Once(function()
				for _, v in RunStartEvents do
					v:Disconnect()
				end

				if RunStartTrack.TimePosition == RunStartTrack.Length then
					iFramesService:AddAlliFrames(Character)

					task.wait(3)

					iFramesService:RemoveAlliFrames(Character)

					Character:RemoveTag("CantRotate")

					SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Burst, Character.Torso)
					SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.RunStart, HumRP.CFrame * CFrame.new(0, -3, 0))

					local StopRunLoop = false
					local moveme = Instance.new("BodyVelocity")
					moveme.MaxForce = Vector3.new(100000, 0, 100000)
					moveme.Name = "moveme"
					moveme:SetAttribute("End", 1)
					moveme:SetAttribute("Fallout", 0.96)
					moveme:SetAttribute("Goto", 100)
					moveme:SetAttribute("Speed", 500)
					moveme.Parent = HumRP

					local RunPreLoopAnimation = MoveAnims.Suiryu.lastbreath.RunPreLoop
					local RunPreLoopTrack = AnimationService:getAnimationTrack(Character, RunPreLoopAnimation)

					RunPreLoopTrack.Stopped:Once(function()
						if RunPreLoopTrack.TimePosition == RunPreLoopTrack.Length then
							local RunLoopAnimation = MoveAnims.Suiryu.lastbreath.RunLoop
							local RunLoopTrack = AnimationService:getAnimationTrack(Character, RunLoopAnimation)

							local RunSFX = {
								SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Engine, Character.Torso),
								SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Wind, Character.Torso),
								SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Fire, Character.Torso),
								SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Footsteps, Character.Torso),
							}

							RunLoopTrack.Stopped:Once(function()
								for _, v in RunSFX do
									TweenService:Create(v, TweenInfo.new(1), { Volume = 0 }):Play()
									Debris:AddItem(v, 1)
								end

								if StopRunLoop then
									return
								end

								StunHandler:Unstun(Character, Stun)

								if moveme then
									moveme:Destroy()
									moveme = nil
								end

								if VFXBind then
									VFXBind:Destroy()
									VFXBind = nil
								end
							end)

							AnimationService:playAnimation(Character, RunLoopAnimation)
						else
							if moveme then
								moveme:Destroy()
								moveme = nil
							end

							if VFXBind then
								VFXBind:Destroy()
								VFXBind = nil
							end
						end
					end)

					AnimationService:stopAll(Character)
					AnimationService:playAnimation(Character, RunPreLoopAnimation)

					ReplicateEffects_Set:FireAllClients(
						"lastbreath",
						{
							Stage = "Run",
							Char = Character,
							runtime = runtime,
							AnimationId = RunPreLoopAnimation.AnimationId,
						}
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
						StopRunLoop = true
						StatesHandler.SkillText(Player, "LAST BREATH [HIT]")

						Hitbox:Destroy()
						Hitbox = nil

						if moveme then
							moveme:Destroy()
							moveme = nil
						end

						if EnemyCharacter:HasTag("Ragdolled") then
							RagdollHandler.cancelRagdoll(EnemyHumanoid)
						end

						AnimationService:stopAll(Character)
						AnimationService:stopAll(EnemyCharacter)

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

						AnimationService:playAnimation(Character, MoveAnims.Suiryu.lastbreath.User)
						AnimationService:playAnimation(EnemyCharacter, MoveAnims.Suiryu.lastbreath.Victim)

						local UserSound = SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.User, Character.Torso)
						SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Victim, EnemyCharacter.Torso)

						ReplicateEffects_Set:FireAllClients(
							"lastbreath",
							{ Stage = "Hit", Char = Character, EChar = EnemyCharacter, sound = UserSound }
						)

						Weld:Start()

						task.delay(11.4, function()
							if Weld then
								pcall(function()
									Weld:Stop()
								end)
								Weld = nil
							end

							task.spawn(function()
								local UserEndAnimation = MoveAnims.Suiryu.lastbreath.UserEnd
								local UserEndTrack = AnimationService:getAnimationTrack(Character, UserEndAnimation)

								UserEndTrack.Stopped:Once(function()
									iFramesService:RemoveAlliFrames(Character)
									CollisionsModule:SetCollisionGroup(Character, "Players")
									Character:RemoveTag("CantRotate")
									StunHandler:Unstun(Character, Stun)

									if VFXBind then
										VFXBind:Destroy()
										VFXBind = nil
									end
								end)

								UserEndTrack.Ended:Once(function()
									HumRP.Anchored = false

									for _, v in Character:GetChildren() do
										if v:IsA("BasePart") then
											v.AssemblyLinearVelocity = Vector3.zero
										end
									end
								end)

								AnimationService:stopAll(Character, 0)
								AnimationService:playAnimation(
									Character,
									MoveAnims.Suiryu.lastbreath.UserEnd,
									nil,
									nil,
									0
								)

								Character:SetPrimaryPartCFrame(
									CFrame.lookAlong(
										ComGet:InvokeClient(Player, { Func = "GetCF", Object = Character.Torso }).Position,
										-HumRP.CFrame.LookVector
									)
								)
								EnemyCharacter:SetPrimaryPartCFrame(
									HumRP.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0)
								)

								local ignoreContainer = {}
								local humanoidContainer = {}
								local partContainer = {}

								for _, part in
									pairs(workspace:GetPartBoundsInRadius(Character.PrimaryPart.Position, 300))
								do
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

							iFramesService:RemoveAlliFrames(EnemyCharacter)
							CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
							EnemyCharacter:RemoveTag("CantRotate")
							StunHandler:Unstun(EnemyCharacter, EnemyStun)

							DamageHandler:TakeDamage(
								Character,
								EnemyHumanoid,
								75,
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
						end)
					end

					Hitbox:Start()

					task.delay(runtime, function()
						if not Hitbox then
							return
						end

						StopRunLoop = true

						Hitbox:Destroy()
						Hitbox = nil

						local RunEndAnimation = MoveAnims.Suiryu.lastbreath.RunEnd
						local RunEndTrack = AnimationService:getAnimationTrack(Character, RunEndAnimation)

						RunEndTrack.Stopped:Once(function()
							StunHandler:Unstun(Character, Stun)

							if moveme then
								moveme:Destroy()
								moveme = nil
							end

							if VFXBind then
								VFXBind:Destroy()
								VFXBind = nil
							end
						end)

						AnimationService:stopAll(Character)
						AnimationService:playAnimation(Character, RunEndAnimation)

						SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Miss, Character.Torso)

						moveme:SetAttribute("Goto", nil)
					end)
				else
					StunHandler:Unstun(Character, Stun)
					Character:RemoveTag("CantRotate")

					if VFXBind then
						VFXBind:Destroy()
						VFXBind = nil
					end
				end
			end)

			AnimationService:stopAll(Character)
			AnimationService:playAnimation(Character, RunStartAnimation)

			ReplicateEffects_Set:FireAllClients(
				"lastbreath",
				{ Stage = "Start", Char = Character, Bind = VFXBind, AnimationId = RunStartAnimation.AnimationId }
			)

			SoundsModule:PlaySound(MoveSounds.Suiryu.lastbreath.Startup, Character.Torso)
		end

		StatesHandler.SkillText(Player, "LAST BREATH [USED]")
	end,
}
