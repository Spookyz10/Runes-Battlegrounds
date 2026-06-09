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
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		
		
		local swordModel = Models.Black.Sword:Clone()
		Debris:AddItem(swordModel, 2.7)
		
		swordModel.Parent = Character
		swordModel.Name = Tool.Name .. "SwordModel_"
		swordModel.root_part.CFrame = Character["Right Arm"].CFrame
		swordModel.root_part.Bone.Part0 = Character["Right Arm"]
		swordModel.Blade.Trail.Enabled = false
		
		
		local Hit = false
		
		
		local StartAnimation = MoveAnims.Black["Raging Tempest"].Startup
		local StartTrack, StartEvents = AnimationService:getAnimationTrack(Character, StartAnimation)
		
		
		local function HitFunction(EnemyCharacter: Model)
			Hit = true
			
			local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			
			
			if EnemyCharacter:HasTag('Ragdolled') then
				RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
			end
			
			
			for _, child in Character:GetChildren() do
				if child.Name == Tool.Name .. "SwordModel_" then
					child:Destroy()
				end
			end
			
			
			local finalSword = Models.Black.Sword:Clone()
			Debris:AddItem(finalSword, 4.2)
			finalSword.Parent = Character
			finalSword.Name = Tool.Name .. "SwordModel_"
			finalSword.root_part.CFrame = Character["Right Arm"].CFrame
			finalSword.root_part.Bone.Part0 = Character["Right Arm"]
			finalSword.Blade.Trail.Enabled = false
			
			
			pcall(function()
				SoundsModule:PlaySound(MoveSounds.Black["Raging Tempest"].M1s_hit[3], EnemyCharacter.Torso)
			end)
			
			
			local UserAnimation = MoveAnims.Black["Raging Tempest"].Main
			local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

			local VictimAnimation = MoveAnims.Black["Raging Tempest"].Victim
			local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
			
			
			if not Stun then
				Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
			end
			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
			local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -4.4) * CFrame.Angles(0, math.pi, 0), -1)
			
			
			Character:AddTag('CantRotate')
			EnemyCharacter:AddTag('CantRotate')
			
			iFramesService:AddAlliFrames(Character)
			iFramesService:AddAlliFrames(EnemyCharacter)
			
			CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
			
			
			DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, false, false, true, false, false, nil, nil)
			
			task.delay(0.45, function()
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, false, false, nil, nil)
			end)
			
			task.delay(1.25, function()
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 6.5, nil, nil, false, false, true, false, false, nil, nil)
			end)
			
			task.delay(3.31, function()
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
				
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 10, nil, nil, false, false, true, false, true, nil, nil)
				knockbackService.Knockback(EnemyCharacter.PrimaryPart, { ["duration"] = 0.32, ["force"] = 100, ["direction"] = Vector3.new(0, 1, 0) })
				RagdollHandler.ragdoll(EnemyHumanoid, 2.5)
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
			end)
			
			
			AnimationService:stopAll(Character)
			AnimationService:stopAll(EnemyCharacter)
			AnimationService:playAnimation(Character, UserAnimation)
			AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
			
			
			Weld:Start(nil, EnemyPlayer, Player)
			
			ReplicateEffects_Set:FireAllClients("RagingTempest", { Char = Character, Stage = "pa", victim = EnemyCharacter, Animation = UserAnimation.AnimationId })
		end
		
		
		task.delay(0.533, function()
			local playedSound = false
			
			HitboxHandler:SimpleOnce(HumRP, Vector3.new(8.5, 7, 31), CFrame.new(0, 0, -12.5), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
				
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, false, nil, nil)
				RagdollHandler.ragdoll(EnemyHumanoid, 1.5)
				
				local lookCFrame = CFrame.new(HumRP.Position * Vector3.new(1, 0, 1), EnemyCharacter.PrimaryPart.Position * Vector3.new(1, 0, 1))
				knockbackService.Knockback(EnemyCharacter.PrimaryPart, { ["duration"] = 0.2, ["force"] = 34, ["direction"] = lookCFrame.LookVector + Vector3.new(0, 0.39, 0) })
				
				pcall(function()
					if not playedSound then
						playedSound = true
						
						SoundsModule:PlaySound(MoveSounds.Black["Raging Tempest"].M1s_hit[1], EnemyCharacter.Torso)
					end
				end)
			end)
		end)
		
		task.delay(1.27, function()
			local playedSound = false
			
			HitboxHandler:SimpleOnce(HumRP, Vector3.new(8.5, 7, 31), CFrame.new(0, 0, -12.5), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
				
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, false, nil, nil)
				
				
				if EnemyCharacter:HasTag('Ragdolled') then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, false, true)
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
					DotParams = {0.4, 1},
					canHitWall = true
				}, Character)
				
				
				pcall(function()
					if not playedSound then
						playedSound = true
						
						SoundsModule:PlaySound(MoveSounds.Black["Raging Tempest"].M1s_hit[2], EnemyCharacter.Torso).TimePosition = 0.2
					end
				end)
			end)
		end)
		
		task.delay(2, function()
			HitboxHandler:SimpleOnce(HumRP, Vector3.new(9, 7, 28), CFrame.new(0, 0, -12), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
				
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, true, false, nil, nil)
				
				if Hit then
					RagdollHandler.ragdoll(EnemyHumanoid, 1.5)

					DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, false, false, true, true, true, nil, nil)
					knockbackService.Knockback(EnemyCharacter.PrimaryPart, { ["duration"] = 0.2, ["force"] = 34, ["direction"] = HumRP.LookVector + Vector3.new(0, 0.39, 0) })
					
					
					pcall(function()
						SoundsModule:PlaySound(MoveSounds.Black["Raging Tempest"].M1s_hit[3], EnemyCharacter.Torso)
					end)
				else
					HitFunction(EnemyCharacter)
					
					Hit = true
				end
			end)
		end)
		
		
		StartTrack.Stopped:Once(function()
			if not Hit then
				StunHandler:Unstun(Character, Stun)
				Stun = nil
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
		
		
		ReplicateEffects_Set:FireAllClients("RagingTempest", { Char = Character, Stage = "psa", swordModel = swordModel, Animation = StartAnimation.AnimationId })
	end
}