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
		local Hit = false
		
		local Bajrang = ReplicatedStorage.Resources.BajrangGun.Bajrang:Clone()
		Bajrang.Gear5.Transparency = 1
		Bajrang.GunWeld.Part0 = Character["Right Arm"]
		Bajrang.Name = "Bajrang" .. tostring(os.clock() + Player.UserId)
		Bajrang.Parent = Character
		
		Bajrang.AnimationController.Animator:LoadAnimation(Bajrang.Animation):Play()
		
		iFramesService:AddAlliFrames(Character)
		Character:AddTag("CantRotate")
		
		
		local Animation = MoveAnims.Other.BajrangGun
		local AnimationTrack = AnimationService:getAnimationTrack(Character, Animation)
		local AnimationEvents = {}
		
		AnimationEvents["BajrangSpawn"] = AnimationTrack:GetMarkerReachedSignal("BajrangSpawn"):Once(function()
			Bajrang.Gear5.Transparency = 0
		end)
		
		AnimationEvents["Hit"] = AnimationTrack:GetMarkerReachedSignal("Hit"):Once(function()
			local falldown: Bone = Bajrang.Gear5.HakiCenter["1_BallonJointRight"]["2_BallonJointRight"]["3_BallonJointRight"]["4_BallonJointRight"]["5_BallonJointRight"]["6_BallonJointRight"]["7_BallonJointRight"]["8_BallonJointRight"]["8.5_BallonJointRight"]["9.BallonJointRight"]["10_BallonJointRight"]["11_BallonJointRight"].Palm.falldown
			
			local MainCF = HumRP.CFrame
			local GroundRay = workspace:Raycast(falldown.WorldPosition, Vector3.new(0, -100, 0), MapRayParams)
			if GroundRay then
				MainCF = CFrame.lookAlong(GroundRay.Position, HumRP.CFrame.LookVector)
			end
			
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = MainCF
			Hitbox.Size = Vector3.new(250, 250, 250)
			Hitbox.Offset = CFrame.new(0, (Hitbox.Size.Y / 2) - 3, 0)
			Hitbox.Ignore = { Character }
			Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(250, 250, 250) + Vector3.new(0, 300, 0) }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
				
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 100, nil, nil, false, false, true, true, true, nil, nil)
				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, math.huge, 1), Velocity = Vector3.new(0, 300, 0) })
				RagdollHandler.ragdoll(EnemyHumanoid, 5)
			end
			
			Hitbox:Once()
			Hitbox:Destroy()
			
			ReplicateEffects_Set:FireAllClients("rockCircle", { CF = MainCF * CFrame.new(0, 3, 0), Parts = 3, Radius = 250, Sound = false, smoke = false })
			
			task.wait(0.017)
			
			Bajrang.Gear5.Transparency = 1
		end)
		
		AnimationTrack.Stopped:Once(function()
			for _,v in AnimationEvents do
				v:Disconnect()
			end
			
			Bajrang:Destroy()
			
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)
			Character:RemoveTag("CantRotate")
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, Animation)
		
		ReplicateEffects_Set:FireAllClients("bajranggun", { Character, Bajrang.Name })
	end
}