local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")


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
		iFramesService:AddAlliFrames(Character)
		
		local Hit = false
		
		local StartupAnimation = MoveAnims.Dawi["Brute Force"].Startup
		local StartupTrack = AnimationService:getAnimationTrack(Character, StartupAnimation)
		local StartupEvents = {}
		
		
		local limbNames = { "Right Arm", "Left Arm", "Right Leg", }
		
		StartupEvents["slam"] = StartupTrack:GetMarkerReachedSignal("slam"):Once(function()
			ReplicateEffects_Set:FireAllClients("BruteForce", { Stage = "Hit Wind", Char = Character })
			ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 4, Last = 0.35 })
			ReplicateEffects_Set:FireAllClients("Ground Crater", { Seed = math.random(1, 2000000000), start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0), ["end"] = Vector3.new(0, -25, 0), amount = 6, nosound = false, size = 1.15 })
			ReplicateEffects_Set:FireAllClients("Ground Crater", { Seed = math.random(1, 2000000000), start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0), ["end"] = Vector3.new(0, -25, 0), amount = 4, nosound = true, size = 0.3 })
			
			
			HitboxHandler:SimpleOnce( HumRP, Vector3.new(8, 8, 8), CFrame.new(0, 1, -3), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				Hit = true
				
				if EnemyCharacter:HasTag('Ragdolled') then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
				end
				
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), 2.5)
				
				
				local UserAnimation = MoveAnims.Dawi["Brute Force"].User
				local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
				local UserEvents = {}

				local VictimAnimation = MoveAnims.Dawi["Brute Force"].Victim
				local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
				
				
				iFramesService:AddAlliFrames(EnemyCharacter)

				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

				EnemyCharacter:AddTag("CantRotate")
				
				
				task.wait(0.025)
				
				
				local newMovementVelocity = Instance.new("BodyVelocity")
				newMovementVelocity.MaxForce = Vector3.new(1, 0, 1) * 50000
				newMovementVelocity.Velocity = HumRP.CFrame.LookVector * 10
				newMovementVelocity:SetAttribute("Count", 10)
				CollectionService:AddTag(newMovementVelocity, "MovementVelocity")
				newMovementVelocity.Parent = HumRP
				
				
				local function hitEffect()
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 0.8, Last = 0.35 } })
					ReplicateEffects_Set:FireAllClients("BruteForce", { Stage = "BruteHit", Char = EnemyCharacter })
					
					newMovementVelocity:SetAttribute("Count", 15)

					task.delay(0.225, function()
						newMovementVelocity:SetAttribute("Count", 3)
					end)
					
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, false, false, true, true, false, nil, nil)
				end

				hitEffect()

				local function dustEffect()
					ReplicateEffects_Set:FireAllClients("BruteForce", { Stage = "VFX", Char = EnemyCharacter })
				end
				
				
				UserEvents["vfx"] = UserTrack:GetMarkerReachedSignal("vfx"):Connect(dustEffect)
				UserEvents["hit"] = UserTrack:GetMarkerReachedSignal("hit"):Connect(hitEffect)
				
				
				UserEvents["kick"] = UserTrack:GetMarkerReachedSignal("kick"):Once(function()
					task.delay(0.1, function()
						CollectionService:AddTag(Character, "BlackflashTime")
						
						ReplicateEffects_Set:FireAllClients("BruteForce", { Stage = "BlackFlash Time", Char = Character })

						UserTrack:AdjustSpeed(0.5)
						VictimTrack:AdjustSpeed(0.5)

						task.delay(0.3, function()
							CollectionService:RemoveTag(Character, "BlackflashTime")
							
							UserTrack:AdjustSpeed(1)
							VictimTrack:AdjustSpeed(1)
						end)

					end)
					

					Debris:AddItem(newMovementVelocity, 0.175)
					
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 1.5, nil, nil, false, false, true, true, false, nil, nil)
					
					ReplicateEffects_Set:FireAllClients("BruteForce", { Stage = "BruteHit", Char = EnemyCharacter })
					ReplicateEffects_Set:FireAllClients("BruteForce", { Stage = "KickStart", Char = Character })
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 1.5, Last = 0.4 } })
				end)
				
				UserEvents["finalhit"] = UserTrack:GetMarkerReachedSignal("finalhit"):Once(function()
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end
					
					Character:AddTag("CantRotate")
					
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					iFramesService:RemoveAlliFrames(EnemyCharacter)
					EnemyCharacter:RemoveTag("CantRotate")
					
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 10, nil, nil, false, false, true, true, true, nil, nil)
					RagdollHandler.ragdoll(EnemyHumanoid, 2)
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(75000, 75000, 75000), Velocity = HumRP.CFrame.LookVector * 75 + Vector3.new(0, 25, 0) })
					
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 6.5, Last = 1.75 } })
					ReplicateEffects_Set:FireAllClients("BruteForce", { Stage = "BruteHit", Char = EnemyCharacter })
					ReplicateEffects_Set:FireAllClients("BruteForce", { Stage = "BruteEndKick", Char = Character, blackFlash = true })
					
					CollectionService:RemoveTag(Character, "BlackflashTime")
				end)
				
				
				VictimTrack.Stopped:Once(function()
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end

					CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					iFramesService:RemoveAlliFrames(EnemyCharacter)
					EnemyCharacter:RemoveTag("CantRotate")
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
					Character:RemoveTag("CantRotate")
					
					CollisionsModule:SetCollisionGroup(Character, "Players")

					StunHandler:Unstun(Character, Stun)
					iFramesService:RemoveAlliFrames(Character)
				end)
				
				AnimationService:stopAll(Character, 0.25)
				AnimationService:stopAll(EnemyCharacter)

				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
				AnimationService:playAnimation(Character, UserAnimation)
				
				for i, v in Character:GetChildren() do
					if v:IsA("BasePart") then
						if table.find(limbNames, v.Name) then
							ReplicateEffects_Set:FireAllClients("armTrailEffect", { char = EnemyCharacter, lifeTime = 5, limbName = v.Name })
						end
					end
				end
				
				if EnemyPlayer then ReplicateEffects_Set:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 4, Last = 0.35 }) end
				Weld:Start(nil, EnemyPlayer, Player)
			end)
			
			task.wait(0.25)
			
			HitboxHandler:SimpleOnce( HumRP, Vector3.new(20, 20, 20), CFrame.new(0, 1, -3), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				
				local DoFinish = false
				
				if Hit == false then
					DoFinish = true
					
				else
					DoFinish = false
				end
				
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 12, nil, nil, false, false, true, true, DoFinish, nil, nil)
				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 100000, 1), Velocity = HumRP.CFrame.UpVector * 75 })
				RagdollHandler.ragdoll(EnemyHumanoid, 2)
				StunHandler:Stun(EnemyCharacter, 0.1, true, 0, 0, true)
			end)
		end)
		
		
		
		StartupTrack.Stopped:Once(function()
			for _,v in StartupEvents do
				v:Disconnect()
			end
			
			if Hit == false then
				
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
			end
		end)
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartupAnimation)
	end
}