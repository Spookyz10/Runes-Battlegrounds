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
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddBaseiFrames(Character)
		
		
		local UserAnimation = MoveAnims["Volt Viper"].twisterkick.User
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)
		
		
		table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("LastHit"):Once(function()
			HitboxHandler:SimpleOnce(HumRP, Vector3.new(6, 15, 6.25), CFrame.new(0, 4.5, -3.75), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter:HasTag('Ragdolled') then return end
				
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 9, 1, nil, true, true)
				if HitInfo.Countered == true or HitInfo.Blocked == true then return end
				
				
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
				
				
				ReplicateEffects_Set:FireAllClients("twisterkick", { Stage = "Hit", Char = Character, Animation = UserAnimation.AnimationId })
				ReplicateEffects_Set:FireClient(Player, 'ShakeCamera', { Magnitude = 4, Roughness = 20, FadeInTime = 0, FadeOutTime = .25 })
				
				pcall(function()
					SoundsModule:PlaySound(MoveSounds["Volt Viper"]["twister kick"].hit, EnemyHumRP)
				end)
			end)
		end))
		
		
		UserTrack.Stopped:Once(function()
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation, 1.25)
		
		
		ReplicateEffects_Set:FireAllClients("twisterkick", { Stage = "Start", Char = Character, Animation = UserAnimation.AnimationId })
		
		SoundsModule:PlaySound(MoveSounds["Volt Viper"]["twister kick"].miss, HumRP)
	end
}