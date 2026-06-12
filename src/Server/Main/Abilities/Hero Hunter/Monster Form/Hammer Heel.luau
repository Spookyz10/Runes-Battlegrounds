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
	workspace.Map,
}
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Variant = false
		local Normal = false

		if Humanoid.Jump == true or Humanoid:GetState() == Enum.HumanoidStateType.Freefall then
			if Normal then
				return
			end
			Variant = true

			local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)

			local StartAnimation = MoveAnims["Hero Hunter"]["Monster Form"]["Hammer Heel"].Variant.Start
			local StartTrack, StartEvents = AnimationService:getAnimationTrack(Character, StartAnimation)

			local Hit, Finisher = false, false
			local HitCount = 1

			local firstmoveme = Instance.new("BodyVelocity")
			firstmoveme.MaxForce = Vector3.new(40000, 0, 40000)
			firstmoveme.Name = "moveme"
			firstmoveme:SetAttribute("End", 5)
			firstmoveme:SetAttribute("Fallout", 0.91)
			firstmoveme:SetAttribute("Speed", 40)

			local secondmoveme = Instance.new("BodyVelocity")
			secondmoveme.MaxForce = Vector3.new(40000, 40000, 40000)
			secondmoveme.Name = "moveme"
			secondmoveme:SetAttribute("Aerial", 21)
			secondmoveme:SetAttribute("End", 5)
			secondmoveme:SetAttribute("Fallout", 0.92)
			secondmoveme:SetAttribute("Speed", 42)

			table.insert(
				StartEvents,
				StartTrack:GetMarkerReachedSignal("hit"):Connect(function()
					HitCount += 1

					if HitCount == 2 then
						firstmoveme.Parent = HumRP

						HitboxHandler:SimpleOnce(
							HumRP,
							Vector3.new(7, 14, 7),
							CFrame.new(0, 0, -5),
							{ Character },
							nil,
							nil,
							function(EnemyCharacter: Model)
								local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
								local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
								local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

								if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
									return
								end
								local HitInfo = DamageHandler:TakeDamage(
									Character,
									EnemyHumanoid,
									1.5,
									nil,
									nil,
									false,
									EnemyCharacter:HasTag("DEATH") and true or false,
									true,
									true,
									false,
									nil,
									nil
								)
								if HitInfo.Countered then
									return
								end

								local BodyAngularVelocity = Instance.new("BodyAngularVelocity")
								BodyAngularVelocity.MaxTorque = Vector3.new(50000, 50000, 50000)
								BodyAngularVelocity.AngularVelocity =
									Vector3.new(math.random(2.5, 5), math.random(2.5, 5), math.random(2.5, 5))
								BodyAngularVelocity.Parent = EnemyHumRP
								Debris:AddItem(BodyAngularVelocity, 0.1)

								NewKnockback:Knockback(
									EnemyCharacter,
									{
										KnockbackType = "Velocity",
										MaxForce = Vector3.new(0, 1, 0) * 10000,
										Velocity = HumRP.CFrame.LookVector + Vector3.new(0, 1, 0) * 45,
									}
								)
								RagdollHandler.ragdoll(EnemyHumanoid, 2)

								ReplicateEffects_Set:FireAllClients(
									"HammerHeelAir",
									{ Char = Character, Target = EnemyCharacter, Stage = "HitOne" }
								)
								shared.fireTo(
									ReplicateEffects_Set,
									{ Player, EnemyPlayer },
									{ "ShakeCamera", { Intensity = 3 } }
								)

								SoundsModule:PlaySound(
									MoveSounds["Hero Hunter"]["Monster Form"]["Hammer Heel"].Variant["First Hit"],
									EnemyHumRP
								)
							end
						)
					elseif HitCount == 3 then
						secondmoveme.Parent = HumRP

						HitboxHandler:SimpleOnce(
							HumRP,
							Vector3.new(7, 14, 7),
							CFrame.new(0, 0, -5),
							{ Character },
							nil,
							nil,
							function(EnemyCharacter: Model)
								local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
								local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
								local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

								if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
									return
								end
								local HitInfo = DamageHandler:TakeDamage(
									Character,
									EnemyHumanoid,
									1.5,
									nil,
									nil,
									false,
									EnemyCharacter:HasTag("DEATH") and true or false,
									true,
									true,
									false,
									nil,
									15
								)
								if HitInfo.Countered then
									return
								end
								Hit = true

								if EnemyCharacter:HasTag("Ragdolled") then
									RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
								end

								if HitInfo.Finisher == true then
									Finisher = true

									Character:AddTag("CantRotate")
									EnemyCharacter:AddTag("CantRotate")

									iFramesService:AddAlliFrames(Character)
									iFramesService:AddAlliFrames(EnemyCharacter)

									CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
									CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

									local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
									local Weld = WeldSystem.new(
										HumRP,
										EnemyHumRP,
										CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0),
										-1
									)

									local UserAnimation =
										MoveAnims["Hero Hunter"]["Monster Form"]["Hammer Heel"].Variant.Finisher.User
									local VictimAnimation =
										MoveAnims["Hero Hunter"]["Monster Form"]["Hammer Heel"].Variant.Finisher.Victim

									local VictimTrack =
										AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
									local UserTrack, UserEvents =
										AnimationService:getAnimationTrack(Character, UserAnimation)

									local Kicked: Folder

									table.insert(
										UserEvents,
										UserTrack:GetMarkerReachedSignal("kick"):Once(function()
											Kicked = Instance.new("Folder")
											Kicked.Parent = Character
											Kicked.Name = "Kicked"

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
											RagdollHandler.ragdoll(EnemyHumanoid, 3)
											NewKnockback:Knockback(
												EnemyCharacter,
												{
													KnockbackType = "Velocity",
													MaxForce = Vector3.new(1, 100000, 1),
													Velocity = Vector3.new(0, -40, 0),
												}
											)

											AnimationService:stopAll(Character)

											task.spawn(function()
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
																	start = Position
																		+ Vector3.new(0, 0.10000000149011612, 0, 0),
																	["end"] = Vector3.new(0, -24, 0, 0),
																	amount = 4,
																	size = 0.2,
																	nosmoke = true,
																	nosound = false,
																})

																ReplicateEffects_Set:FireAllClients("Ground Crater", {
																	Seed = math.random(1, 2000000000),
																	start = Position
																		+ Vector3.new(0, 0.10000000149011612, 0, 0),
																	["end"] = Vector3.new(0, -14, 0, 0),
																	amount = 5,
																	sizemult = 1.55,
																	size = 1.4,
																	nosound = true,
																})

																task.spawn(function()
																	local VoxelParameters = {
																		Velocity = CFrame.new(Position).UpVector,
																		Multiplier = { 5, 10 },
																		Size = Vector3.new(25, 25, 25),
																		CFrame = CFrame.new(Position)
																			* CFrame.new(0, 0, 0),
																	}

																	local DestroyParams = {
																		Owner = Player,
																		Velocity = -CFrame.new(Position).LookVector
																				* Vector3.new(25, 25, 25)
																			+ Vector3.new(0, 25, 0),
																	}

																	HitboxHandler:SimpleOnce(
																		CFrame.new(Position),
																		Vector3.new(25, 25, 25),
																		CFrame.new(0, 0, 0),
																		{ Character, EnemyCharacter },
																		nil,
																		nil,
																		function(EnemyCharacter2: Model)
																			local EnemyHumRP2: BasePart =
																				EnemyCharacter2.HumanoidRootPart
																			local EnemyHumanoid2: Humanoid =
																				EnemyCharacter2.Humanoid

																			if
																				EnemyCharacter2:GetAttribute("iFrames")
																				>= 2
																			then
																				return
																			end

																			DamageHandler:TakeDamage(
																				Character,
																				EnemyHumanoid2,
																				7,
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
																			RagdollHandler.ragdoll(EnemyHumanoid2, 2)
																			NewKnockback:Knockback(
																				EnemyCharacter2,
																				{
																					KnockbackType = "Velocity",
																					MaxForce = Vector3.new(
																						1,
																						100000,
																						1
																					),
																					Velocity = EnemyHumRP.CFrame.UpVector
																						* 40,
																				}
																			)
																		end,
																		DestroyParams,
																		VoxelParameters
																	)
																end)

																shared.fireTo(
																	ReplicateEffects_Set,
																	{ Player, EnemyPlayer },
																	{ "ShakeCamera", { Intensity = 8 } }
																)

																SoundsModule:PlaySound(
																	MoveSounds["Hero Hunter"]["Monster Form"]["Hammer Heel"].Variant.Finisher.Crater,
																	CFrame.new(Position)
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

												ReplicateEffects_Set:FireAllClients(
													"collisionWall",
													{
														root = EnemyHumRP,
														NoCrater = "ez",
														hit = EnemyCharacter,
														caller = Character,
													}
												)
											end)

											pcall(function()
												HuntersCloth.Delete(Character)
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
										if Weld then
											pcall(function()
												Weld:Stop()
											end)
											Weld = nil
										end

										if Kicked then
											Kicked:Destroy()
											Kicked = nil
										end

										StunHandler:Unstun(Character, Stun)
										iFramesService:RemoveAlliFrames(Character)
										CollisionsModule:SetCollisionGroup(Character, "Players")
										Character:RemoveTag("CantRotate")

										Character:SetPrimaryPartCFrame(
											CFrame.lookAlong(
												ComGet:InvokeClient(
													Player,
													{ Func = "GetCF", Object = Character.Torso }
												).Position,
												HumRP.CFrame.LookVector
											)
										)
										HumRP.Anchored = false

										pcall(function()
											HuntersCloth.Delete(Character)
										end)
									end)

									AnimationService:stopAll(Character)
									AnimationService:stopAll(EnemyCharacter)
									AnimationService:playAnimation(Character, UserAnimation)
									AnimationService:playAnimation(EnemyCharacter, VictimAnimation)

									Weld:Start(nil, EnemyPlayer, Player)
									HuntersCloth.Trigger(Character, EnemyCharacter, true)

									ReplicateEffects_Set:FireAllClients(
										"HammerHeelAirFinisher",
										{ Char = Character, EChar = EnemyCharacter }
									)
									ReplicateEffects_Set:FireAllClients("UpCF", { Char = Character, Y = 30 })
									HumRP.Anchored = true

									SoundsModule:PlaySound(
										MoveSounds["Hero Hunter"]["Monster Form"]["Hammer Heel"].Variant.Finisher.User,
										HumRP
									)
									SoundsModule:PlaySound(
										MoveSounds["Hero Hunter"]["Monster Form"]["Hammer Heel"].Variant.Finisher.Victim,
										EnemyCharacter.Torso
									)
								else
									EnemyCharacter:AddTag("CantRotate")

									iFramesService:AddAlliFrames(Character)
									iFramesService:AddAlliFrames(EnemyCharacter)

									CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
									CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

									local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
									local Weld = WeldSystem.new(
										HumRP,
										EnemyHumRP,
										CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0),
										-1
									)

									local UserAnimation =
										MoveAnims["Hero Hunter"]["Monster Form"]["Hammer Heel"].Variant.User
									local VictimAnimation =
										MoveAnims["Hero Hunter"]["Monster Form"]["Hammer Heel"].Variant.Victim

									local VictimTrack =
										AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
									local UserTrack, UserEvents =
										AnimationService:getAnimationTrack(Character, UserAnimation)

									table.insert(
										UserEvents,
										UserTrack:GetMarkerReachedSignal("freeze"):Once(function()
											UserTrack:AdjustSpeed(0)
											VictimTrack:AdjustSpeed(0)

											task.delay(0.2, function()
												UserTrack:AdjustSpeed(1)
												VictimTrack:AdjustSpeed(1)
											end)

											print(
												"is this what this is for?... dumb, anyway astral got this too! :fire:"
											)
										end)
									)

									table.insert(
										UserEvents,
										UserTrack:GetMarkerReachedSignal("throw"):Once(function()
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
											NewKnockback:Knockback(
												EnemyCharacter,
												{
													KnockbackType = "Velocity",
													MaxForce = Vector3.new(100000, 50000, 100000),
													Velocity = HumRP.CFrame.LookVector * Vector3.new(85, 0, 85)
														+ Vector3.new(0, 0, 0),
												}
											)
											DamageHandler:TakeDamage(
												Character,
												EnemyHumanoid,
												math.random(13, 17),
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

											ReplicateEffects_Set:FireAllClients(
												"HammerHeelAir",
												{ Char = Character, Stage = "Throw" }
											)
											ReplicateEffects_Set:FireAllClients(
												"collisionWall",
												{
													root = EnemyHumRP,
													NoCrater = "airvariantsmash",
													hit = EnemyCharacter,
													caller = Character,
												}
											)
											shared.fireTo(
												ReplicateEffects_Set,
												{ Player, EnemyPlayer },
												{ "ShakeCamera", { Intensity = 6, Last = 0.2 } }
											)
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
										if Weld then
											pcall(function()
												Weld:Stop()
											end)
											Weld = nil
										end

										StunHandler:Unstun(Character, Stun)
										iFramesService:RemoveAlliFrames(Character)
										CollisionsModule:SetCollisionGroup(Character, "Players")
									end)

									AnimationService:stopAll(Character)
									AnimationService:stopAll(EnemyCharacter)
									AnimationService:playAnimation(Character, UserAnimation)
									AnimationService:playAnimation(EnemyCharacter, VictimAnimation)

									Weld:Start(nil, EnemyPlayer, Player)

									ReplicateEffects_Set:FireAllClients(
										"HammerHeelAir",
										{ Char = Character, Target = EnemyCharacter, Stage = "HitSec" }
									)
									shared.fireTo(
										ReplicateEffects_Set,
										{ Player, EnemyPlayer },
										{ "ShakeCamera", { Intensity = 4, Last = 3 } }
									)

									SoundsModule:PlaySound(
										MoveSounds["Hero Hunter"]["Monster Form"]["Hammer Heel"].Variant["Second Hit"],
										EnemyHumRP
									)
									SoundsModule:PlaySound(
										MoveSounds["Hero Hunter"]["Monster Form"]["Hammer Heel"].Variant.Hit,
										HumRP
									)
								end
							end
						)
					end
				end)
			)

			StartTrack.Stopped:Once(function()
				if firstmoveme then
					firstmoveme:Destroy()
					firstmoveme = nil
				end

				if secondmoveme then
					secondmoveme:Destroy()
					secondmoveme = nil
				end

				if not Hit then
					StatesHandler.DoEndLag(Player, Stun, 0.3)
				end
			end)

			AnimationService:stopAll(Character)
			AnimationService:playAnimation(Character, StartAnimation)

			ReplicateEffects_Set:FireAllClients("HammerHeelAir", { Char = Character, Stage = "Trails" })

			SoundsModule:PlaySound(MoveSounds["Hero Hunter"]["Monster Form"]["Hammer Heel"].Variant.Startup, HumRP)
		else
			if Variant then
				return
			end
			Normal = true

			local Bind = Instance.new("ObjectValue")
			Bind.Name = "HitHeavy"
			Bind.Parent = workspace
			Bind.Value = nil

			local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)

			local MissAnimation = MoveAnims["Hero Hunter"]["Monster Form"]["Hammer Heel"].Miss
			local MissTrack, MissEvents = AnimationService:getAnimationTrack(Character, MissAnimation)

			local Hit = false

			table.insert(MissEvents, MissTrack:GetMarkerReachedSignal("vfxmarker"):Once(function() end))

			table.insert(
				MissEvents,
				MissTrack:GetMarkerReachedSignal("hit"):Once(function()
					ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 3, Last = 0.2 })

					HitboxHandler:SimpleOnce(
						HumRP,
						Vector3.new(8, 8, 8),
						CFrame.new(0, 0, -3),
						{ Character },
						nil,
						nil,
						function(EnemyCharacter: Model)
							local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
							local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
							local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

							if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
								return
							end

							local HitInfo = DamageHandler:TakeDamage(
								Character,
								EnemyHumanoid,
								1.5,
								nil,
								nil,
								false,
								EnemyCharacter:HasTag("DEATH") and true or false,
								true,
								true,
								false,
								nil,
								nil
							)
							if HitInfo.Countered then
								return
							end
							Hit = true

							if EnemyCharacter:HasTag("Ragdolled") then
								RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
							end

							if Bind then
								Bind.Parent = Character
								Bind.Value = EnemyCharacter
							end

							EnemyCharacter:AddTag("CantRotate")
							iFramesService:AddBaseiFrames(EnemyCharacter)
							CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

							local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

							local VictimAnimation = MoveAnims["Hero Hunter"]["Monster Form"]["Hammer Heel"].Victim
							local VictimTrack, VictimEvents =
								AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)

							local Count = 1
							local SmallDebris: Accessory

							local function AOEHitbox(Size, Damage, RagdollTime, UpVector)
								task.spawn(function()
									local VoxelParameters = {
										Velocity = EnemyHumRP.CFrame.UpVector,
										Multiplier = { 5, 10 },
										Size = Size,
										CFrame = EnemyHumRP.CFrame * CFrame.new(0, 0, 0),
									}

									local DestroyParams = {
										Owner = Player,
										Velocity = -EnemyHumRP.CFrame.LookVector * Size + Vector3.new(0, 25, 0),
									}

									HitboxHandler:SimpleOnce(
										EnemyHumRP,
										Size,
										CFrame.new(0, 0, 0),
										{ Character, EnemyCharacter },
										nil,
										nil,
										function(EnemyCharacter2: Model)
											local EnemyHumRP2: BasePart = EnemyCharacter2.HumanoidRootPart
											local EnemyHumanoid2: Humanoid = EnemyCharacter2.Humanoid

											if EnemyCharacter2:GetAttribute("iFrames") >= 2 then
												return
											end

											DamageHandler:TakeDamage(
												Character,
												EnemyHumanoid2,
												Damage,
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
											RagdollHandler.ragdoll(EnemyHumanoid2, RagdollTime)
											NewKnockback:Knockback(
												EnemyCharacter2,
												{
													KnockbackType = "Velocity",
													MaxForce = Vector3.new(1, 100000, 1),
													Velocity = HumRP.CFrame.UpVector * UpVector,
												}
											)
										end,
										DestroyParams,
										VoxelParameters
									)
								end)
							end

							table.insert(
								VictimEvents,
								VictimTrack:GetMarkerReachedSignal("hit"):Connect(function()
									Count += 1

									if Count == 2 then
										task.spawn(function()
											ReplicateEffects_Set:FireAllClients("Ground Crater", {
												Seed = math.random(1, 2000000000),
												start = EnemyHumRP.Position + Vector3.new(0, 0.10000000149011612, 0, 0),
												["end"] = Vector3.new(0, -24, 0, 0),
												amount = 4,
												size = 0.2,
												nosmoke = true,
												nosound = false,
											})

											ReplicateEffects_Set:FireAllClients("Ground Crater", {
												Seed = math.random(1, 2000000000),
												start = EnemyHumRP.Position + Vector3.new(0, 0.10000000149011612, 0, 0),
												["end"] = Vector3.new(0, -14, 0, 0),
												amount = 5,
												sizemult = 1.55,
												size = 1.4,
												nosound = true,
											})

											shared.fireTo(
												ReplicateEffects_Set,
												{ Player, EnemyPlayer },
												{ "ShakeCamera", { Intensity = 7 } }
											)
										end)

										pcall(function()
											AOEHitbox(Vector3.new(20, 20, 20), 5, 2.25, 85)
										end)

										DamageHandler:TakeDamage(
											Character,
											EnemyHumanoid,
											12,
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

										SoundsModule:PlaySound(
											MoveSounds["Hero Hunter"]["Monster Form"]["Hammer Heel"].Normal.Craters.First,
											EnemyHumRP
										)
									elseif Count == 3 then
										task.spawn(function()
											ReplicateEffects_Set:FireAllClients("Ground Crater", {
												Seed = math.random(1, 2000000000),
												start = EnemyHumRP.Position + Vector3.new(0, 0.10000000149011612, 0, 0),
												["end"] = Vector3.new(0, -24, 0, 0),
												amount = 6,
												size = 0.3,
												nosmoke = true,
												nosound = false,
											})

											shared.fireTo(
												ReplicateEffects_Set,
												{ Player, EnemyPlayer },
												{ "ShakeCamera", { Intensity = 5 } }
											)
										end)

										pcall(function()
											AOEHitbox(Vector3.new(10, 10, 10), 6, 2, 75)
										end)

										DamageHandler:TakeDamage(
											Character,
											EnemyHumanoid,
											4,
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

										SoundsModule:PlaySound(
											MoveSounds["Hero Hunter"]["Monster Form"]["Hammer Heel"].Normal.Craters.Second,
											EnemyHumRP
										)
									end
								end)
							)

							table.insert(
								VictimEvents,
								VictimTrack:GetMarkerReachedSignal("slide"):Once(function()
									SmallDebris = Instance.new("Accessory")
									SmallDebris:AddTag("SmallDebris")
									SmallDebris.Name = "SmallDebris"
									SmallDebris.Parent = EnemyCharacter

									Debris:AddItem(SmallDebris, 0.55)
								end)
							)

							VictimTrack.Stopped:Once(function()
								if Bind then
									Bind:Destroy()
									Bind = nil
								end

								if SmallDebris then
									SmallDebris:Destroy()
									SmallDebris = nil
								end

								StunHandler:Unstun(EnemyCharacter, EnemyStun)
								iFramesService:RemoveAlliFrames(EnemyCharacter)
								CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
								EnemyCharacter:RemoveTag("CantRotate")
							end)

							AnimationService:stopAll(EnemyCharacter)
							AnimationService:playAnimation(EnemyCharacter, VictimAnimation)

							EnemyCharacter:PivotTo(CFrame.lookAlong(EnemyHumRP.Position, HumRP.CFrame.RightVector))
							NewKnockback:Knockback(
								EnemyCharacter,
								{
									KnockbackType = "Velocity",
									MaxForce = Vector3.new(math.huge, 0, math.huge),
									Velocity = -HumRP.CFrame.RightVector * 55,
									Time = 1.9,
									P = 1250,
								}
							)

							ReplicateEffects_Set:FireAllClients(
								"HammerHeel",
								{ Char = EnemyCharacter, Animation = VictimAnimation.AnimationId, kick = false }
							)
							shared.fireTo(
								ReplicateEffects_Set,
								{ Player, EnemyPlayer },
								{ "ShakeCamera", { Intensity = 3 } }
							)

							SoundsModule:PlaySound(
								MoveSounds["Hero Hunter"]["Monster Form"]["Hammer Heel"].Normal.Impact,
								EnemyCharacter.Torso
							)
							SoundsModule:PlaySound(
								MoveSounds["Hero Hunter"]["Monster Form"]["Hammer Heel"].Normal.Hit,
								EnemyCharacter.Torso
							)
							SoundsModule:PlaySound(
								MoveSounds["Hero Hunter"]["Monster Form"]["Hammer Heel"].Normal.Victim,
								EnemyCharacter.Torso
							)
						end
					)
				end)
			)

			MissTrack.Stopped:Once(function()
				if not Hit then
					StatesHandler.DoEndLag(Player, Stun, 0.3)

					if Bind then
						Bind:Destroy()
						Bind = nil
					end
				else
					StunHandler:Unstun(Character, Stun)
				end
			end)

			AnimationService:stopAll(Character)
			AnimationService:playAnimation(Character, MissAnimation)

			ReplicateEffects_Set:FireAllClients(
				"HammerHeel",
				{ Char = Character, Animation = MissAnimation.AnimationId, kick = true }
			)

			SoundsModule:PlaySound(MoveSounds["Hero Hunter"]["Monster Form"]["Hammer Heel"].Normal.Swoosh, HumRP)
		end
	end,
}
