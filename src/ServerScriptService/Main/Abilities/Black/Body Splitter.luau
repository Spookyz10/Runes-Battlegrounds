local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")


local ServerModules = ServerStorage.Modules

local ReplicatedModules = ReplicatedStorage.Modules
local RemotesContainer = ReplicatedStorage.Remotes


local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local RagdollHandler = require(ServerModules.RagdollHandler)
local NewKnockback = require(ServerModules.BodymoverService)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local WeaponsHandler = require(ServerModules.WeaponsHandler)
local CollisionsModule = require(ServerModules.CollisionsModule)
local SoundsModule = require(ServerModules.SoundsModule)
local KnockbackModule = require(ServerModules.KnockbackModule)
local ReplicatedHitbox = require(ServerModules.ReplicatedHitboxes)



local Utility = shared.Utility
local WeldSystem = require(ReplicatedModules.WeldSystem)
local SoundHandler = require(ReplicatedModules.SoundHandler)
local Trove = require(ReplicatedModules.Trove)

local services = require(ReplicatedStorage.Services)
local VfxUtility = services:GetService("VFX_Utility")
local knockbackService = services:GetService("KnockbackService")


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
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)


		local StartAnimation = MoveAnims.Black["Body Splitter"].Use1
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}
		
		
		local Hit = nil
		local Finisher = false
		
		
		local swordModel2 = Models.Black.Sword:Clone()
		Debris:AddItem(swordModel2, 0.9)
		swordModel2.Name = Tool.Name .. "SwordModel_"
		swordModel2.Parent = Character
		swordModel2.root_part.CFrame = Character["Right Arm"].CFrame
		swordModel2.root_part.Bone.Part0 = Character["Right Arm"]

		for _, descendant in swordModel2:GetDescendants() do
			if descendant:IsA("Trail") then
				descendant.Enabled = false
				
			elseif descendant:IsA("BasePart") and descendant.Transparency < 1 then
				descendant.Transparency = 1
				
				task.delay(0.15, function()
					descendant.Transparency = 0
				end)
			end
		end
		
		
		StartEvents["sword_release"] = Janitor:Add(StartTrack:GetMarkerReachedSignal("sword_release"):Connect(function()
			local groundRay = workspace:Raycast(HumRP.CFrame.Position, Vector3.new(-0, -30, -0), MapRayParams)
			if groundRay then
				local Hitbox = ReplicatedHitbox.new(Player)
				Hitbox.Instance = HumRP
				Hitbox.Size = Vector3.new(27, 27, 27)
				Hitbox.Offset = CFrame.new(0, 0, 0)
				Hitbox.Ignore = { Character }
				Hitbox.destroyAfterOnce = true
				Hitbox.onTouch = function(EnemyCharacter)
					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
					
					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 6, nil, nil, true, false, false, true, true, nil, nil)
					if HitInfo.Blocked == true then return end
					
					
					if not Hit then
						Hit = EnemyCharacter

						StunHandler:Unstun(Character, Stun)
					end
					
					
					if EnemyCharacter:HasTag("Ragdolled") then
						RagdollHandler.cancelRagdoll(EnemyHumanoid)
					end


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
					
					require(ServerModules.PerfectKnockback).KnockBack(nil, EnemyCharacter, {
						LookVector = lookposition.LookVector,
						LookForce = 58.5,
						LookFinalForce = 55,
						LookAt = lookposition,
						DestroyRagdoll = true,
						GroundStunTime = 0.95,
						Escapable = false,
						FallingDetectDelay = 0.2,
						Dot = dotProduct,
						DotParams = {0.4, 1},
						canHitWall = true
					}, Character)
					
					task.spawn(function()
						ComSet:FireClient(Player, 'ModifyHotbar', { ToolName = 'Body Splitter', Property = 'Description', Value = 'Use Again', Time = 5 })
						
						task.delay(5, function()
							ComSet:FireClient(Player, 'ModifyHotbar', { ToolName = 'Body Splitter', Property = 'Description', Value = '' })
						end)
					end)
				end
				Hitbox.functionAfterDestroy = function()
					if not Hit then return end
					
					local Twiced = false
					
					local function Use()
						if Twiced == true then return end
						Twiced = true
						
						local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
						iFramesService:AddAlliFrames(Character)


						local UserAnimation = MoveAnims.Black["Body Splitter"].Use2
						local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
						local UserEvents = {}


						for _, child in Character:GetChildren() do
							if child.Name == Tool.Name .. "SwordModel_" then
								child:Destroy()
							end
						end


						local swordClone = Models.Black.Sword:Clone()
						Debris:AddItem(swordClone, 1.7)
						swordClone.Parent = Character
						swordClone.Name = Tool.Name .. "SwordModel_"
						swordClone.root_part.CFrame = Character["Right Arm"].CFrame
						swordClone.root_part.Bone.Part0 = Character["Right Arm"]

						local computedGoal = nil


						UserEvents["slash_start"] = Janitor:Add(UserTrack:GetMarkerReachedSignal("slash_start"):Connect(function()
							if Hit and (Hit:IsDescendantOf(workspace) and Hit.PrimaryPart) then
								local victimPos = Hit.PrimaryPart.Position


								local EnemyPlayer = PlayersService:GetPlayerFromCharacter(Hit)
								if EnemyPlayer then
									victimPos = Hit.HumanoidRootPart.CFrame.Position
								end


								local userPos = HumRP.CFrame.Position
								local distance = (userPos - victimPos).Magnitude
								computedGoal = CFrame.new(userPos, victimPos) * CFrame.new(0, 0, -distance)

								local rayDistance = 10

								local rayHit = workspace:Raycast(computedGoal.Position, computedGoal.LookVector * rayDistance, MapRayParams)
								if rayHit then
									rayDistance = rayHit.Distance
								end

								computedGoal = computedGoal * CFrame.new(0, 0, -rayDistance)


								CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
								task.delay(1.35, function()
									CollisionsModule:SetCollisionGroup(Character, "Players")
								end)


								ReplicateEffects_Set:FireAllClients("BodySplitter", { Char = Character, Stage ="dashStart", hrpPos = userPos, victimPos = victimPos, distance = distance, goal = computedGoal })

								task.wait(0.15)

								swordClone.Blade.Trail.Enabled = false

								Character:SetAttribute("Invisible", true)
								task.delay(0.15, function()
									Character:SetAttribute("Invisible", false)
								end)
							end
						end))

						UserEvents["slash"] = Janitor:Add(UserTrack:GetMarkerReachedSignal("slash"):Connect(function()
							if computedGoal then
								local Hitbox = ReplicatedHitbox.new(Player)
								Hitbox.Instance = HumRP
								Hitbox.Size = Vector3.new(10, 10, 30)
								Hitbox.Offset = CFrame.new(0, 0, 15)
								Hitbox.Ignore = { Character }
								Hitbox.destroyAfterOnce = true
								Hitbox.onTouch = function(EnemyCharacter: Model)
									local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
									local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
									local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

									if Finisher == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead or EnemyCharacter:HasTag('Ragdolled') then return end
									local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 6.3, nil, nil, true, false, true, true, false, nil, 11.3)

									if HitInfo.Finisher == true then
										Finisher = true

										for _, child in Character:GetChildren() do
											if child.Name == Tool.Name .. "SwordModel_" then
												child:Destroy()
											end
										end


										local swordModel = Models.Black.Sword:Clone()
										Debris:AddItem(swordModel, 4.933)
										swordModel.Parent = Character
										swordModel.Name = Tool.Name .. "SwordModel_"
										swordModel.root_part.CFrame = Character["Right Arm"].CFrame
										swordModel.root_part.Bone.Part0 = Character["Right Arm"]
										swordModel.Blade.Trail.Enabled = false


										local VictimAnimation = MoveAnims.Black["Body Splitter"].Finisher.Victim
										local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)

										local UserAnimation = MoveAnims.Black["Body Splitter"].Finisher.Main
										local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
										local UserEvents = {}


										local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -4.5) * CFrame.Angles(0, math.pi, 0), -1)


										local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)


										EnemyCharacter:AddTag('CantRotate')
										Character:AddTag('CantRotate')

										iFramesService:AddAlliFrames(Character)
										iFramesService:AddAlliFrames(EnemyCharacter)

										CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
										CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")


										task.delay(0.5, function()
											if EnemyCharacter and EnemyCharacter.PrimaryPart then
												if not EnemyCharacter:IsDescendantOf(workspace) then
													return
												end

												DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, false, nil)
											end
										end)

										task.delay(1.067, function()
											if EnemyCharacter and EnemyCharacter.PrimaryPart then
												if not EnemyCharacter:IsDescendantOf(workspace) then
													return
												end

												DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, false, nil)
											end
										end)

										task.delay(1.6, function()
											if EnemyCharacter and EnemyCharacter.PrimaryPart then
												if not EnemyCharacter:IsDescendantOf(workspace) then
													return
												end

												DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, false, nil)
											end
										end)

										task.delay(1.77, function()
											if EnemyCharacter and EnemyCharacter.PrimaryPart then
												if not EnemyCharacter:IsDescendantOf(workspace) then
													return
												end

												DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, false, nil)
											end
										end)

										task.delay(2, function()
											if EnemyCharacter and EnemyCharacter.PrimaryPart then
												if not EnemyCharacter:IsDescendantOf(workspace) then
													return
												end

												DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, false, nil)
											end
										end)


										task.delay(4.95, function()
											if Weld then
												pcall(function()
													Weld:Stop()
												end)
												Weld = nil
											end

											if EnemyCharacter and (EnemyCharacter.PrimaryPart and EnemyCharacter:IsDescendantOf(workspace)) then
												RagdollHandler.ragdoll(EnemyHumanoid, 3)

												StunHandler:Unstun(EnemyCharacter, EnemyStun)
												EnemyCharacter:RemoveTag('CantRotate')
												iFramesService:RemoveAlliFrames(EnemyCharacter)
												CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
												EnemyHumanoid.BreakJointsOnDeath = true
												AnimationService:stopAll(EnemyCharacter, 0.1)
												DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, true, true, true, nil)

												knockbackService.Knockback(EnemyCharacter.PrimaryPart, {
													["duration"] = 0.2,
													["force"] = 100,
													["direction"] = HumRP.CFrame.LookVector + Vector3.new(0, 0.03, 0)
												})
											end
										end)



										VictimTrack.Stopped:Once(function()
											if Weld then
												pcall(function()
													Weld:Stop()
												end)
												Weld = nil
											end

											StunHandler:Unstun(EnemyCharacter, EnemyStun)
											EnemyCharacter:RemoveTag('CantRotate')
											iFramesService:RemoveAlliFrames(EnemyCharacter)
											CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
										end)

										UserTrack.Stopped:Once(function()
											for _,v in UserEvents do
												v:Disconnect()
											end

											if Weld then
												pcall(function()
													Weld:Stop()
												end)
												Weld = nil
											end

											StunHandler:Unstun(Character, Stun)
											Character:RemoveTag('CantRotate')
											iFramesService:RemoveAlliFrames(Character)
											CollisionsModule:SetCollisionGroup(Character, "Players")

											Janitor:Destroy()
										end)


										AnimationService:stopAll(Character)
										AnimationService:stopAll(EnemyCharacter)

										AnimationService:playAnimation(Character, UserAnimation)
										AnimationService:playAnimation(EnemyCharacter, VictimAnimation)


										Weld:Start(nil, EnemyPlayer, Player)


										ReplicateEffects_Set:FireAllClients("BodySplitter", { Char = Character, Stage ="f_pa", victim = EnemyCharacter, sword = swordModel })
									else
										StunHandler:Stun(EnemyCharacter, 1.8, true, 0, 0, true)
										knockbackService.Knockback(EnemyCharacter.PrimaryPart, {
											["duration"] = 0.2,
											["force"] = 48,
											["direction"] = HumRP.CFrame.LookVector + Vector3.new(0, 0.7, 0)
										})
										RagdollHandler.ragdoll(EnemyHumanoid, 1.8)
									end
								end

								Hitbox:Once()
							end
						end))


						UserTrack.Stopped:Once(function()
							for _,v in UserEvents do
								v:Disconnect()
							end

							if Finisher == false then
								StunHandler:Unstun(Character, Stun)
								iFramesService:RemoveAlliFrames(Character)
								Janitor:Destroy()
							end
						end)


						AnimationService:stopAll(Character)
						AnimationService:playAnimation(Character, UserAnimation)

						ReplicateEffects_Set:FireAllClients("BodySplitter", { Char = Character, Stage ="pa2", Animation = UserAnimation.AnimationId })
					end
					
					
					local UsedTwice = false
					Character:SetAttribute("BodySplitterSlash", true)
					
					Character:GetAttributeChangedSignal("BodySplitterSlash"):Once(function()
						ComSet:FireClient(Player, 'ModifyHotbar', { ToolName = 'Body Splitter', Property = 'Description', Value = '' })
					end)
					
					local Changed = Character:GetAttributeChangedSignal("BodySplitterSlash"):Once(function()
						UsedTwice = true
						
						Use()
					end)
					
					task.delay(5, function()
						if UsedTwice then return end
						Changed:Disconnect()
						Character:SetAttribute("BodySplitterSlash", nil)
					end)
				end
				
				Hitbox:Once()
			end
		end))
		
		
		StartTrack.Stopped:Once(function()
			for _,v in StartEvents do
				v:Disconnect()
			end
			
			StunHandler:Unstun(Character, Stun)
			Janitor:Destroy()
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
		
		
		ReplicateEffects_Set:FireAllClients("BodySplitter", { Char = Character, Stage ="pa", Animation = StartAnimation.AnimationId })
	end
}