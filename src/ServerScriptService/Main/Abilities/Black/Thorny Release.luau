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
		
		
		local Mod = Player.Configuration.Mod.Value
		local nextMod = (Player.Configuration.Mod.Value + 1) % 4
		Player.Configuration.Mod.Value = math.max(nextMod, 1)

		Player:SetAttribute("Tip", Mod == 1 and "2" or (Mod == 2 and "3" or nil))
		
		
		local stunDuration = Mod == 1 and 0.5 or (Mod == 2 and 1.1 or 1.3)
		local Stun = StunHandler:Stun(Character, nil, true, Mod < 3 and 3 or 0, 0, true)
		task.delay(stunDuration, function()
			StunHandler:Unstun(Character, Stun)
		end)
		
		
		local StartAnimation = MoveAnims.Black["Thorny Release"]["Throw" .. Mod]
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}
		
		local Damages = {
			["Damage1"] = 6,
			["Damage2"] = 2.9,
			["Damage3"] = 6
		}
		
		if Mod == 3 then
			StartEvents["spawn"] = Janitor:Add(StartTrack:GetMarkerReachedSignal("spawn"):Connect(function()
				local spawnCFrame = HumRP.CFrame * CFrame.new(0, 27, -15)
				
				local groundRaycast = workspace:Raycast(spawnCFrame.Position, Vector3.new(-0, -9999, -0), MapRayParams)
				if groundRaycast then
					ReplicateEffects_Set:FireAllClients("ThornyRelease", {
						Char = Character,
						Stage = "final",
						spawnPosition = spawnCFrame, 
						groundCheck = {
							["Position"] = groundRaycast.Position, 
							["Normal"] = groundRaycast.Normal,
							["Distabce"] = groundRaycast.Distance
						}
					})
					
					task.wait(0.7)
					
					local Hitbox = HitboxHandler.new()
					Hitbox.Instance = CFrame.new(groundRaycast.Position)
					Hitbox.Size = Vector3.new(34, 44.199997, 34)
					Hitbox.Ignore = { Character }
					Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(34, 44.199997, 34) + Vector3.new(0, 25, 0) }
					Hitbox.onTouch = function(EnemyCharacter)
						local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
						local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
						local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

						if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
						
						local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, true, false, true, true, false, nil, nil)
						
						if HitInfo.Countered == true then
							return 
						end
						
						if HitInfo.Blocked == true then
							DamageHandler:TakeDamage(Character, EnemyHumanoid, Damages["Damage" .. Mod] / 2, nil, nil, false, false, true, true, true, nil, nil)
							
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
						else
							DamageHandler:TakeDamage(Character, EnemyHumanoid, Damages["Damage" .. Mod], 2, nil, false, false, true, true, true, nil, nil)
							RagdollHandler.ragdoll(EnemyHumanoid, 2)
							
							StartAirDetect:Fire(EnemyCharacter)
							
							local knockbackData = {
								["duration"] = 0.2,
								["force"] = 20,
								["direction"] = CFrame.new(groundRaycast.Position, EnemyCharacter.PrimaryPart.Position).LookVector + Vector3.new(0, 1.7, 0)
							}

							knockbackService.Knockback(EnemyCharacter.PrimaryPart, knockbackData)
						end
					end
					
					Hitbox:Once()
					Hitbox:Destroy()
				end
			end))
		end
		
		
		StartEvents["throw"] = Janitor:Add(StartTrack:GetMarkerReachedSignal("throw"):Connect(function(throwIdx)
			local throwIndexNum = tonumber(throwIdx)
			local safeThrowIndex = math.max(throwIndexNum, 1)

			if Mod < 3 then
				local throwDistance = Mod == 1 and 0.6 or 1
				local rootCFrame = HumRP.CFrame
				local cframeConstructor = CFrame.new
				local zDistance = throwDistance * -25
				local scaleFactor = safeThrowIndex / 1.2
				local spawnCFrame = rootCFrame * cframeConstructor(0, 0, zDistance * math.max(1, scaleFactor))
				
				
				ReplicateEffects_Set:FireAllClients("ThornyRelease", {
					Char = Character,
					Stage = "s_Shards",
					mod = Mod,
					spawnPosition = spawnCFrame,
					index = safeThrowIndex
				})
				
				task.wait(0.1)
				
				local raycastResult = workspace:Raycast(spawnCFrame.Position, Vector3.new(-0, -30, -0), MapRayParams)

				if not raycastResult then
					return
				end
				
				local hitboxScale = safeThrowIndex / 1.3
				local Hitbox = HitboxHandler.new()
				Hitbox.Instance = CFrame.new(raycastResult.Position)
				Hitbox.Size = Vector3.new(16, 16, 16) * math.max(1, hitboxScale) * Vector3.new(1, 1.5, 1)
				Hitbox.Ignore = { Character }
				Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(16, 16, 16) * math.max(1, hitboxScale) * Vector3.new(1, 1.5, 1) + Vector3.new(0, 25, 0) }
				Hitbox.onTouch = function(EnemyCharacter)
					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end

					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, true, false, true, true, false, nil, nil)

					if HitInfo.Countered == true then
						return 
					end
					
					if HitInfo.Blocked == true then
						DamageHandler:TakeDamage(Character, EnemyHumanoid, Damages["Damage" .. Mod] / 2, nil, nil, false, false, true, true, true, nil, nil)
					else
						DamageHandler:TakeDamage(Character, EnemyHumanoid, Damages["Damage" .. Mod], 1.5, nil, false, false, true, true, true, nil, nil)
					end
					
					local knockbackForce = Mod == 1 and 14 or (Mod == 2 and safeThrowIndex == 1 and 17 or ((Mod ~= 2 or safeThrowIndex ~= 2) and 0 or (EnemyCharacter.PrimaryPart.Position - HumRP.Position).Magnitude / 2.3))
					local knockbackDirection = HumRP.CFrame.LookVector + Vector3.new(0, 1.5, 0)
					local knockbackDuration

					if Mod == 2 and safeThrowIndex == 2 then
						knockbackDirection = CFrame.new(EnemyCharacter.PrimaryPart.Position, HumRP.Position).LookVector + Vector3.new(0, 1.7, 0)
						knockbackDuration = 0.35
					else
						knockbackDuration = 0.2
					end

					knockbackService.Knockback(EnemyCharacter.PrimaryPart, {
						["duration"] = knockbackDuration,
						["force"] = knockbackForce,
						["direction"] = knockbackDirection
					})
					
					RagdollHandler.ragdoll(EnemyHumanoid, 1.5)
				end

				Hitbox:Once()
				Hitbox:Destroy()
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
		
		ReplicateEffects_Set:FireAllClients("ThornyRelease", { Char = Character, Stage = "pa", mod = Mod })
	end
}