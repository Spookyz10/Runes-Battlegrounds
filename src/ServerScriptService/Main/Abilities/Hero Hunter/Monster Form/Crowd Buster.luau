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
local StatesHandler = require(ServerModules.StatesHandler)



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
	workspace.Map
}
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		
		
		local MissAnimation = MoveAnims["Hero Hunter"]["Monster Form"]["Crowd Buster"].Miss
		local MissTrack, MissEvents = AnimationService:getAnimationTrack(Character, MissAnimation)
		
		
		local Hit = false
		local Running = false
		
		
		table.insert(MissEvents, MissTrack:GetMarkerReachedSignal("down"):Once(function()
			
		end))
		
		table.insert(MissEvents, MissTrack:GetMarkerReachedSignal("down1"):Once(function()
			
		end))
		
		table.insert(MissEvents, MissTrack:GetMarkerReachedSignal("end"):Once(function()
			iFramesService:AddBaseiFrames(Character)
			
			Running = true
			
			ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 3, Last = 0.1 })
			
			local DashAnimation = MoveAnims["Hero Hunter"]["Monster Form"]["Crowd Buster"].Dash
			local DashTrack, DashEvents = AnimationService:getAnimationTrack(Character, DashAnimation)
			
			
			local function HitFunc(EnemyCharacter: Model)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				
				
				Hit = true


				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
				end

				if Character then
					ReplicateEffects_Set:FireAllClients("clearVelocities", { Char = Character })
				end


				local jumpmoveme = Instance.new("BodyVelocity")
				local secjumpmoveme = Instance.new("BodyVelocity")
				local thirjumpmoveme = Instance.new("BodyVelocity")

				jumpmoveme.MaxForce = Vector3.new(40000, 40000, 40000)
				secjumpmoveme.MaxForce = Vector3.new(40000, 40000, 40000)
				thirjumpmoveme.MaxForce = Vector3.new(40000, 40000, 40000)

				jumpmoveme.Name = "moveme"
				secjumpmoveme.Name = "moveme"
				thirjumpmoveme.Name = "moveme"

				jumpmoveme:SetAttribute("Aerial", 75)
				secjumpmoveme:SetAttribute("Aerial", 75)
				thirjumpmoveme:SetAttribute("Aerial", 75)

				jumpmoveme:SetAttribute("AerialDecrease", 2.45)
				secjumpmoveme:SetAttribute("AerialDecrease", 4.8)
				thirjumpmoveme:SetAttribute("AerialDecrease", 2.7)

				jumpmoveme:SetAttribute("End", 5)
				secjumpmoveme:SetAttribute("End", 5)
				thirjumpmoveme:SetAttribute("End", 5)

				jumpmoveme:SetAttribute("Fallout", 0.98)
				secjumpmoveme:SetAttribute("Fallout", 0.95)
				thirjumpmoveme:SetAttribute("Fallout", 0.97)

				jumpmoveme:SetAttribute("RemoveOthers", true)
				secjumpmoveme:SetAttribute("RemoveOthers", true)
				thirjumpmoveme:SetAttribute("RemoveOthers", true)

				jumpmoveme:SetAttribute("Speed", 160)
				secjumpmoveme:SetAttribute("Speed", 160)
				thirjumpmoveme:SetAttribute("Speed", 160)

				jumpmoveme.Parent = HumRP


				EnemyCharacter:AddTag("CantRotate")

				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)

				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "NoCol")


				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), -1)


				local UserAnimation = MoveAnims["Hero Hunter"]["Monster Form"]["Crowd Buster"].User
				local VictimAnimation = MoveAnims["Hero Hunter"]["Monster Form"]["Crowd Buster"].Victim

				local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
				local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)


				local Count = 1


				local GoalPos
				local RayOrigin = EnemyHumRP.Position
				local RayDirection = Vector3.new(0, -200, 0)


				local function AOEHitbox(Size, Damage, RagdollTime, UpVector)
					task.spawn(function()
						local VoxelParameters = {
							Velocity = HumRP.CFrame.UpVector,
							Multiplier = { 5, 10 },
							Size = Size,
							CFrame = HumRP.CFrame * CFrame.new(0, 0, 0)
						}

						local DestroyParams = {
							Owner = Player,
							Velocity = -HumRP.CFrame.LookVector * Size + Vector3.new(0, 25, 0)
						}

						HitboxHandler:SimpleOnce(HumRP, Size, CFrame.new(0, 0, 0), { Character, EnemyCharacter }, nil, nil, function(EnemyCharacter2: Model)
							local EnemyHumRP2: BasePart = EnemyCharacter2.HumanoidRootPart
							local EnemyHumanoid2: Humanoid = EnemyCharacter2.Humanoid

							if EnemyCharacter2:GetAttribute("iFrames") >= 2 then return end

							local AOEHitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid2, Damage, nil, nil, true, false, true, true, true, nil, nil)
							if not AOEHitInfo.Blocked then
								RagdollHandler.ragdoll(EnemyHumanoid2, RagdollTime)
							end

							NewKnockback:Knockback(EnemyCharacter2, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 100000, 1), Velocity = HumRP.CFrame.UpVector * UpVector })
						end, DestroyParams, VoxelParameters)

					end)
				end


				table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("slam"):Connect(function()
					Count += 1


					local RayParams = RaycastParams.new()
					RayParams.FilterType = Enum.RaycastFilterType.Exclude
					RayParams.FilterDescendantsInstances = {
						Character, 
						EnemyCharacter
					}
					RayParams.RespectCanCollide = true
					RayParams.IgnoreWater = true


					RayOrigin = EnemyHumRP and EnemyHumRP.Position or RayOrigin
					local RayResult = workspace:Raycast(RayOrigin, RayDirection, RayParams)
					if RayResult then
						GoalPos = RayResult.Position
					else
						GoalPos = RayOrigin - Vector3.new(0, 3, 0)
					end


					if Count == 2 then
						if jumpmoveme then
							jumpmoveme:Destroy()
							jumpmoveme = nil
						end

						secjumpmoveme.Parent = HumRP

						ReplicateEffects_Set:FireAllClients("CrowdBuster", { Char = Character, Stage = "Hit", Action = 1, EChar = EnemyCharacter, Position = GoalPos })
						ReplicateEffects_Set:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = GoalPos + Vector3.new(0, 0.10000000149011612, 0), ["end"] = Vector3.new(0, -25, 0), amount = 12,nosound = false, size = 1.7 })
						ReplicateEffects_Set:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = GoalPos + Vector3.new(0, 0.10000000149011612, 0), ["end"] = Vector3.new(0, -25, 0), amount = 8, nosound = true, size = 0.4 })
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 5 } })

						pcall(function()
							AOEHitbox(Vector3.new(20, 20, 20), 10, 2, 75)
						end)

						DamageHandler:TakeDamage(Character, EnemyHumanoid, 3.5, nil, nil, false, false, true, true, false, nil, nil)

						SoundsModule:PlaySound(MoveSounds["Hero Hunter"]["Monster Form"]["Crowd Buster"].Craters.First, GoalPos)

					elseif Count == 3 then
						if secjumpmoveme then
							secjumpmoveme:Destroy()
							secjumpmoveme = nil
						end

						thirjumpmoveme.Parent = HumRP

						ReplicateEffects_Set:FireAllClients("CrowdBuster", { Char = Character, Stage = "Hit", Action = 2, EChar = EnemyCharacter, Position = GoalPos })
						ReplicateEffects_Set:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = GoalPos + Vector3.new(0, 0.10000000149011612, 0), ["end"] = Vector3.new(0, -25, 0), amount = 10,nosound = false, size = 1.1 })
						ReplicateEffects_Set:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = GoalPos + Vector3.new(0, 0.10000000149011612, 0), ["end"] = Vector3.new(0, -25, 0), amount = 7, nosound = true, size = 0.5 })
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 6 } })

						pcall(function()
							AOEHitbox(Vector3.new(25, 25, 25), 15, 2.25, 80)
						end)

						DamageHandler:TakeDamage(Character, EnemyHumanoid, 3.5, nil, nil, false, false, true, true, false, nil, nil)

						SoundsModule:PlaySound(MoveSounds["Hero Hunter"]["Monster Form"]["Crowd Buster"].Craters.Second, GoalPos)

					elseif Count == 4 then
						if thirjumpmoveme then
							thirjumpmoveme:Destroy()
							thirjumpmoveme = nil
						end

						ReplicateEffects_Set:FireAllClients("CrowdBuster", { Char = Character, Stage = "Hit", Action = 3, EChar = EnemyCharacter, Position = GoalPos })
						ReplicateEffects_Set:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = GoalPos + Vector3.new(0, 0.10000000149011612, 0), ["end"] = Vector3.new(0, -25, 0), amount = 10,nosound = false, size = 1.1 })
						ReplicateEffects_Set:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = GoalPos + Vector3.new(0, 0.10000000149011612, 0), ["end"] = Vector3.new(0, -25, 0), amount = 7, nosound = true, size = 0.5 })
						shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 7 } })

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
						NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 100000, 1), Velocity = HumRP.CFrame.UpVector * 75 })
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 8, nil, nil, false, false, true, true, true, nil, nil)

						pcall(function()
							AOEHitbox(Vector3.new(30, 30, 30), 20, 2.5, 85)
						end)

						SoundsModule:PlaySound(MoveSounds["Hero Hunter"]["Monster Form"]["Crowd Buster"].Craters.Third, GoalPos)
					end
				end))


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
					if jumpmoveme then
						jumpmoveme:Destroy()
						jumpmoveme = nil
					end

					if secjumpmoveme then
						secjumpmoveme:Destroy()
						secjumpmoveme = nil
					end

					if thirjumpmoveme then
						thirjumpmoveme:Destroy()
						thirjumpmoveme = nil
					end

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

				SoundsModule:PlaySound(MoveSounds["Hero Hunter"]["Monster Form"]["Crowd Buster"].User, HumRP)
			end
			
			
			local function SpawnHitbox()
				local HitboxConnection = ReplicatedHitbox.new(Player)
				HitboxConnection.Instance = HumRP
				HitboxConnection.Size = Vector3.new(8, 8, 18)
				HitboxConnection.Offset = CFrame.new(0, 0, -5.5)
				HitboxConnection.Ignore = { Character }
				HitboxConnection.destroyAfterOnce = true
				HitboxConnection.onTouch = function(EnemyCharacter: Model)
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)

					if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end

					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, true, EnemyCharacter:HasTag('DEATH') and true or false, true, true, false, nil, nil)
					if HitInfo.Blocked == true or HitInfo.Countered then return end
					Hit = true

					HitFunc(EnemyCharacter)
				end
				
				HitboxConnection:Once()
			end
			
			
			table.insert(DashEvents, DashTrack:GetMarkerReachedSignal("pouncefirst"):Once(function()
				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 3, Last = 0.1 })
				ReplicateEffects_Set:FireAllClients("CrowdBuster", { Char = Character, Stage = "Start", Action = 2 })
				
				SpawnHitbox()
			end))
			
			table.insert(DashEvents, DashTrack:GetMarkerReachedSignal("pounce"):Once(function()
				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 4, Last = 0.3 })
				ReplicateEffects_Set:FireAllClients("CrowdBuster", { Char = Character, Stage = "Start", Action = 3 })
				
				SpawnHitbox()
				
				task.delay(0.3, function()
					ReplicateEffects_Set:FireAllClients("CrowdBuster", { Char = Character, Stage = "Start", Action = 4 })
				end)
			end))
			
			table.insert(DashEvents, DashTrack:GetMarkerReachedSignal("end"):Once(function()
				ReplicateEffects_Set:FireAllClients("clearVelocities", { Char = Character })
			end))
			
			
			DashTrack.Stopped:Once(function()
				if not Hit then
					StatesHandler.DoEndLag(Player, Stun, 0.4)
					
					ReplicateEffects_Set:FireAllClients("clearVelocities", { Char = Character })
				end
			end)
			
			
			AnimationService:stopAll(Character)
			AnimationService:playAnimation(Character, DashAnimation)
			
			ReplicateEffects_Set:FireClient(Player, "CrowdBusterVelocity", { Char = Character })
			ReplicateEffects_Set:FireAllClients("CrowdBuster", { Char = Character, Stage = "Start", Action = 1 })
		end))
		
		
		MissTrack.Stopped:Once(function()
			if not Running then
				StunHandler:Unstun(Character, Stun)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, MissAnimation, 1.6)
		
		SoundsModule:PlaySound(MoveSounds["Hero Hunter"]["Monster Form"]["Crowd Buster"].Startup, HumRP)
	end
}