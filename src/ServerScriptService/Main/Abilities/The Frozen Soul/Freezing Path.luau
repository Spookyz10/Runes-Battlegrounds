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
local Trove = require(ReplicatedModules.Trove)


local Sounds = ServerStorage.Assets.Sounds
local Animations = ServerStorage.Assets.Animations
local Models = ServerStorage.Assets.Models

local Weapons = Models.Weapons
local MoveAnims = Animations.Moves
local MoveSounds = Sounds.Moves


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
		
		
		local StartAnimation = MoveAnims.Subzero["Freezing Path"].Startup
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}
		
		
		local Hit = false
		local StartSFX
		
		
		local dashVelocity = Instance.new("BodyVelocity")
		dashVelocity.MaxForce = Vector3.new(500000, 0, 500000)
		dashVelocity.Name = "moveme"
		dashVelocity:SetAttribute("End", 1)
		dashVelocity:SetAttribute("Fallout", 0.91)
		dashVelocity:SetAttribute("Goto", 75)
		dashVelocity:SetAttribute("Speed", 150)
		
		local skateVelocity = Instance.new("BodyVelocity")
		skateVelocity.MaxForce = Vector3.new(500000, 0, 500000)
		skateVelocity.Name = "moveme"
		skateVelocity:SetAttribute("End", 1)
		skateVelocity:SetAttribute("Fallout", 0.91)
		skateVelocity:SetAttribute("Goto", 90)
		skateVelocity:SetAttribute("Speed", 200)
		
		local skateVelocityHit = Instance.new("BodyVelocity")
		skateVelocityHit.MaxForce = Vector3.new(500000, 0, 500000)
		skateVelocityHit.Name = "moveme"
		skateVelocityHit:SetAttribute("End", 1)
		skateVelocityHit:SetAttribute("Fallout", 0.91)
		skateVelocityHit:SetAttribute("Goto", 90)
		skateVelocityHit:SetAttribute("Speed", 230)
		
		
		local Hitbox = HitboxHandler.new()
		Hitbox.Instance = HumRP
		Hitbox.Size = Vector3.new(10, 10, 20)
		Hitbox.Offset = CFrame.new(0, 0, -10.5)
		Hitbox.onTouch = function(EnemyCharacter)
			local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

			if Hit == true or EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter:HasTag('Ragdolled') or EnemyHumanoid.Health <= 0 then return end

			local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 3.55, nil, nil, false, true, true, true, false, nil, nil)
			if HitInfo.Countered == true then
				return
			end

			Hit = true

			if StartSFX then
				StartSFX:Destroy()
			end
			

			if skateVelocity then
				skateVelocity:Destroy()
				skateVelocity = nil
			end
			if dashVelocity then
				dashVelocity:Destroy()
				dashVelocity = nil
			end
			

			local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), 2.5)
			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)


			local UserAnimation = MoveAnims.Subzero["Freezing Path"].User
			local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
			local UserEvents = {}

			local VictimAnimation = MoveAnims.Subzero["Freezing Path"].Victim
			local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)


			iFramesService:AddAlliFrames(Character)
			iFramesService:AddAlliFrames(EnemyCharacter)

			CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

			EnemyCharacter:AddTag("CantRotate")



			UserEvents["start"] = UserTrack:GetMarkerReachedSignal("start"):Once(function()
				skateVelocityHit.Parent = HumRP

				ReplicateEffects_Set:FireAllClients("freezingpathParts", { Char = Character, Faster = true })
			end)

			UserEvents["jump"] = UserTrack:GetMarkerReachedSignal("jump"):Once(function()

			end)

			UserEvents["land"] = UserTrack:GetMarkerReachedSignal("land"):Once(function()
				skateVelocityHit:Destroy()

				DamageHandler:TakeDamage(Character, EnemyHumanoid, 3.55, nil, nil, false, false, true, true, false, nil, nil)
				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 2 })
			end)

			UserEvents["punch"] = UserTrack:GetMarkerReachedSignal("punch"):Once(function()
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 3.55, nil, nil, false, false, true, true, false, nil, nil)

				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 2.5 })
			end)

			UserEvents["stomp"] = UserTrack:GetMarkerReachedSignal("stomp"):Once(function()
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 3.55, nil, nil, false, false, true, true, false, nil, nil)

				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 2 })
			end)

			UserEvents["stomp2"] = UserTrack:GetMarkerReachedSignal("stomp2"):Once(function()
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 3.55, nil, nil, false, false, true, true, false, nil, nil)

				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 3 })
			end)

			UserEvents["kick"] = UserTrack:GetMarkerReachedSignal("kick"):Once(function()
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

				RagdollHandler.ragdoll(EnemyHumanoid, 2)
				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(75000, 75000, 75000), Velocity = HumRP.CFrame.LookVector * 55 + Vector3.new(0, 10, 0) })
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 3.55, nil, nil, false, false, true, true, true, nil, nil)

				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 2.5, Last = 0.35 })
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
				for _,v in UserEvents do
					v:Disconnect()
				end

				if Weld then
					pcall(function()
						Weld:Stop()
					end)
					Weld = nil
				end

				iFramesService:RemoveAlliFrames(Character)
				CollisionsModule:SetCollisionGroup(Character, "Players")
				Character:RemoveTag("CantRotate")
				StunHandler:Unstun(Character, Stun)
			end)


			AnimationService:stopAll(EnemyCharacter)
			AnimationService:playAnimation(EnemyCharacter, VictimAnimation)

			AnimationService:stopAll(Character)
			AnimationService:playAnimation(Character, UserAnimation)

			Weld:Start(nil, EnemyPlayer, Player)

			ReplicateEffects_Set:FireAllClients("freezingPath", { char = Character, id = UserAnimation.AnimationId, hit = EnemyCharacter })

			SoundsModule:PlaySound(MoveSounds.Subzero["Freezing Path"].Hit, HumRP)
		end
		
		
		local SkateHitbox = ReplicatedHitbox.new(Player)
		SkateHitbox.Instance = HumRP
		SkateHitbox.Size = Vector3.new(7, 7, 21)
		SkateHitbox.Offset = CFrame.new(0, 0, -10.5)
		SkateHitbox.Ignore = { Character }
		SkateHitbox.onTouch = function(EnemyCharacter)
			local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			
			if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
			
			
			
			if not EnemyCharacter:GetAttribute("Iced") then
				EnemyCharacter:SetAttribute("Iced", true)
				
				local Ice = Models.IceCube:Clone()
				Ice.Parent = EnemyCharacter
				Ice.Weld.Part1 = EnemyCharacter.Torso
				
				task.delay(5, function()
					EnemyCharacter:SetAttribute("Iced", nil)
					Ice:Destroy()

					DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, false, false, true, true, true, nil, nil)
					
					if EnemyCharacter and EnemyCharacter.Parent then
						SoundsModule:PlaySound(MoveSounds.Subzero["Frost Forge"].Ice, EnemyHumRP)
					end
				end)
			end
		end
		
		
		StartEvents["dash"] = StartTrack:GetMarkerReachedSignal("dash"):Once(function()
			dashVelocity.Parent = HumRP
			
			Hitbox:Once()
		end)
		
		StartEvents["hit"] = StartTrack:GetMarkerReachedSignal("hit"):Once(function()
			if dashVelocity then
				dashVelocity:Destroy()
				dashVelocity = nil
			end
			
			Hitbox.Offset = CFrame.new(0, 0, -18.5)
			Hitbox:Once()
			Hitbox:Destroy()
		end)
		
		StartEvents["skate"] = StartTrack:GetMarkerReachedSignal("skate"):Once(function()
			skateVelocity.Parent = HumRP
			
			SkateHitbox:Start()
			
			iFramesService:AddAlliFrames(Character)
			
			ReplicateEffects_Set:FireAllClients("freezingpathParts", { Char = Character })
			ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 2, Last = 0.2 })
		end)
		
		StartEvents["end"] = StartTrack:GetMarkerReachedSignal("end"):Once(function()
			for _,v in StartEvents do
				v:Disconnect()
			end
			
			SkateHitbox:Destroy()
			if skateVelocity then
				skateVelocity:Destroy()
				skateVelocity = nil
			end
			
			if Hit == true then return end
			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)
		end)
		
		
		StartTrack.Stopped:Once(function()
			for _,v in StartEvents do
				v:Disconnect()
			end
			
			if dashVelocity then
				dashVelocity:Destroy()
				dashVelocity = nil
			end
			if skateVelocity then
				skateVelocity:Destroy()
				skateVelocity = nil
			end
			
			if Hit == true then return end
			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)
		end)
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
		
		ReplicateEffects_Set:FireAllClients("freezingPath", { char = Character, id = StartAnimation.AnimationId, startup = true })
		
		StartSFX = SoundsModule:PlaySound(MoveSounds.Subzero["Freezing Path"].Miss, HumRP)
	end
}