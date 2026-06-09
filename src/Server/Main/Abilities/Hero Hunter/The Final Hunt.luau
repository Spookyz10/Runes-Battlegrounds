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

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		local StartupAnimation = MoveAnims["Hero Hunter"].thefinalhunt.Startup
		local StartupTrack, StartupEvents = AnimationService:getAnimationTrack(Character, StartupAnimation)

		local Hit = false

		table.insert(
			StartupEvents,
			StartupTrack:GetMarkerReachedSignal("slam"):Once(function()
				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 9 })
				ReplicateEffects_Set:FireAllClients(
					"Ground Crater",
					{
						Seed = math.random(1, 2147483647),
						amount = 6,
						start = Character.PrimaryPart.Position + Vector3.new(0, -3.1, 0),
						size = 0.3,
						["end"] = Vector3.new(0, -14, 0),
						nosound = true,
					}
				)
				ReplicateEffects_Set:FireAllClients(
					"Ground Crater",
					{
						nosmoke = true,
						Seed = math.random(1, 2147483647),
						amount = 15,
						start = Character.PrimaryPart.Position + Vector3.new(0, -3.1, 0),
						size = 1.8,
						["end"] = Vector3.new(0, -14, 0),
						nosound = true,
					}
				)

				HitboxHandler:SimpleOnce(
					HumRP,
					Vector3.new(20, 17.5, 20),
					CFrame.new(0, 0, -2),
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
							false,
							false,
							nil,
							nil
						)
						if HitInfo.Countered == true then
							return
						end

						Hit = true

						local UserAnimation = MoveAnims["Hero Hunter"].thefinalhunt.User
						local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

						iFramesService:AddAlliFrames(Character)
						iFramesService:AddAlliFrames(EnemyCharacter)

						EnemyCharacter:AddTag("CantRotate")

						CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

						local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)

						NewKnockback:Knockback(
							EnemyCharacter,
							{
								KnockbackType = "Position",
								MaxForce = Vector3.new(1, 1, 1) * 40000000,
								Position = Vector3.new(
									EnemyHumRP.Position.X,
									HumRP.Position.Y + 90,
									EnemyHumRP.Position.Z
								),
								D = 750,
								Time = 6,
								Name = "Final_Hunted",
							}
						)

						task.delay(0.4, function()
							DamageHandler:TakeDamage(
								Character,
								EnemyHumanoid,
								15,
								nil,
								nil,
								false,
								false,
								false,
								true,
								false,
								nil,
								nil
							)

							NewKnockback:Knockback(
								Character,
								{
									KnockbackType = "Position",
									MaxForce = Vector3.new(1, 1, 1) * 40000000,
									Position = Vector3.new(HumRP.Position.X, HumRP.Position.Y + 91.5, HumRP.Position.Z),
									D = 750,
									Time = 1.1,
									Name = "Final_Hunted",
									DelayV = 0.35,
								}
							)
						end)

						task.delay(0.45, function()
							Character:AddTag("CantRotate")

							task.spawn(function()
								while RunService.Heartbeat:Wait() do
									if not Character:FindFirstChild("Final_Hunted", true) or Humanoid.Health <= 0 then
										break
									end

									TweenService:Create(
										HumRP,
										TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
										{
											CFrame = CFrame.new(
												HumRP.Position,
												Vector3.new(
													EnemyHumRP.Position.X,
													HumRP.Position.Y,
													EnemyHumRP.Position.Z
												)
											),
										}
									):Play()
								end
							end)
						end)

						table.insert(
							UserEvents,
							UserTrack:GetMarkerReachedSignal("slam"):Once(function()
								for i, v in pairs(EnemyCharacter:GetDescendants()) do
									if v:IsA("BodyPosition") and v.Name == "Final_Hunted" then
										v:Destroy()
									end
								end

								NewKnockback:Knockback(
									EnemyCharacter,
									{
										KnockbackType = "Velocity",
										MaxForce = Vector3.new(1, 1, 1) * 40000000,
										Velocity = HumRP.CFrame.LookVector * 125 - Vector3.new(0, 150, 0),
									}
								)

								task.spawn(function()
									shared.fireTo(
										ReplicateEffects_Set,
										{ Player, EnemyPlayer },
										{ "ShakeCamera", { Intensity = 10 } }
									)

									StunHandler:Unstun(EnemyCharacter, EnemyStun)
									EnemyCharacter:RemoveTag("CantRotate")
									iFramesService:RemoveAlliFrames(EnemyCharacter)
									CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

									DamageHandler:TakeDamage(
										Character,
										EnemyHumanoid,
										37.5,
										nil,
										nil,
										false,
										false,
										false,
										true,
										true,
										nil,
										nil
									)
									RagdollHandler.ragdoll(EnemyHumanoid, 4)

									local params = OverlapParams.new()
									params.FilterType = Enum.RaycastFilterType.Exclude
									params.FilterDescendantsInstances = { workspace.Live }

									local TouchedGround = false
									local EffectTriggered = false
									local detecting = true
									local hit = true

									while detecting and hit do
										local parts = workspace:GetPartBoundsInBox(
											EnemyHumRP.CFrame,
											Vector3.new(15, 15, 15),
											params
										)

										for _, Object in pairs(parts) do
											if Object:IsA("BasePart") then
												local objectPos = Object.Position
												local targetPos = EnemyHumRP.Position

												if
													(
														objectPos.Y <= targetPos.Y
														or math.abs(objectPos.X - targetPos.X) <= 5
														or math.abs(objectPos.Z - targetPos.Z) <= 5
													) and not EffectTriggered
												then
													detecting = false
													EffectTriggered = true
													hit = false

													local position = EnemyCharacter.PrimaryPart.Position

													ReplicateEffects_Set:FireAllClients(
														"Ground Crater",
														{
															Seed = 2000000000,
															amount = 3,
															start = position,
															size = 0.7,
															["end"] = Vector3.new(0, -14, 0),
															nosound = true,
														}
													)
													ReplicateEffects_Set:FireAllClients(
														"ShakeCamera",
														{ Last = 1.5, Intensity = 10 }
													)
													ReplicateEffects_Set:FireAllClients(
														"collisionWall",
														{
															stronger = true,
															Time = 3,
															root = EnemyHumRP,
															Seed = 2000000000,
															AccurateCheck = true,
														}
													)

													HitboxHandler:SimpleOnce(
														EnemyHumRP,
														Vector3.new(85, 85, 85),
														CFrame.new(0, 0, 0),
														{ Character, EnemyCharacter },
														nil,
														nil,
														function(EnemyCharacter2: Model)
															local EnemyHumRP2: BasePart =
																EnemyCharacter2.HumanoidRootPart
															local EnemyHumanoid2: Humanoid = EnemyCharacter2.Humanoid

															if EnemyCharacter2:GetAttribute("iFrames") >= 2 then
																return
															end

															DamageHandler:TakeDamage(
																Character,
																EnemyHumanoid2,
																21,
																nil,
																nil,
																false,
																false,
																false,
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
																	MaxForce = Vector3.new(1, 100000, 1),
																	Velocity = HumRP.CFrame.UpVector * 95,
																}
															)
														end
													)
												end
											end
										end

										if EffectTriggered then
											break
										end

										task.wait()
									end
								end)
							end)
						)

						UserTrack.Stopped:Once(function()
							for i, v in pairs(Character:GetDescendants()) do
								if v:IsA("BodyPosition") and v.Name == "Final_Hunted" then
									v:Destroy()
								end
							end

							Character:RemoveTag("CantRotate")
							StunHandler:Unstun(Character, Stun)
							iFramesService:RemoveAlliFrames(Character)
						end)

						AnimationService:stopAll(Character)
						AnimationService:playAnimation(Character, UserAnimation)
					end
				)
			end)
		)

		StartupTrack.Stopped:Once(function()
			if not Hit then
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartupAnimation)
	end,
}
