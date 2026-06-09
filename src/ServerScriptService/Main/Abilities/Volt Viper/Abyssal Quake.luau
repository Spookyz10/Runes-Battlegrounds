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
		iFramesService:AddBaseiFrames(Character)
		Character:AddTag('CantRotate')
		
		
		local UserAnimation = MoveAnims["Volt Viper"].abyssalquake.User
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)
		
		
		local Configuration = {
			arcHeight = 20,
			duration = 0.7,
			distance = 40
		}
		
		local function CheckRaycast(Pos, Vector)
			return workspace:Raycast(Pos, Vector, MapRayParams)
		end
		
		local function calculateLandPosition(p66)
			local v67 = p66.Position
			local v68 = p66.LookVector * Configuration.distance
			local v69 = CheckRaycast(v67, v68)

			if v69 ~= nil then
				v69 = v69.Position - Vector3.new(0, 0, 10)
			end

			if v69 == nil then
				v69 = v67 + v68
			end

			local v70 = CheckRaycast(v69, Vector3.new(-0, -50, -0))
			if v70 ~= nil then
				v70 = v70.Position + Vector3.new(0, 3, 0)
			end

			if v70 ~= nil then
				v69 = v70
			end

			return v69
		end
		
		
		local landPosition
		landPosition = calculateLandPosition(HumRP.CFrame)
		
		
		local function applyMovementArc()
			local v73 = Configuration.duration
			local v74 = Configuration.arcHeight
			
			local v76 = HumRP.CFrame
			local v77 = HumRP.Position
			
			local v78 = calculateLandPosition(v76)
			landPosition = v78
			
			local v79 = v77 + (v78 - v77) * 0.8 + Vector3.new(0, 1, 0) * v74
			local v80 = time()
			
			while time() - v80 < v73 do
				RunService.Stepped:Wait()
				
				local v81 = (time() - v80) / v73
				local v82 = require(ReplicatedModules.SideModules.math).BezierCurve(v77, v79, v78, (math.clamp(v81, 0, 1)))
				HumRP.CFrame = CFrame.lookAlong(v82, HumRP.CFrame.LookVector)
			end
		end
		
		
		table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("Jump"):Once(function()
			HumRP.Anchored = true
			
			Janitor:Add(function()
				HumRP.Anchored = false
			end)
			
			applyMovementArc()
			Janitor:Clean()
		end))
		
		table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("LastHit"):Once(function()
			HitboxHandler:SimpleOnce(HumRP, Vector3.new(15, 15, 15), CFrame.new(0, 0, 0), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
				
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 8, nil, nil, false, false, true, false, true, nil, nil)
				RagdollHandler.ragdoll(EnemyHumanoid, 1.5)
			end)
			
			ReplicateEffects_Set:FireAllClients("abyssalquake", { Stage = "Land", Char = Character, Animation = UserAnimation.AnimationId, Land = landPosition })
			ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 5 })
			
			SoundsModule:PlaySound(MoveSounds["Volt Viper"]["abyssal quake"].impact, HumRP)
		end))
		
		
		UserTrack.Stopped:Once(function()
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)
			Character:RemoveTag("CantRotate")
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
		
		ReplicateEffects_Set:FireAllClients("abyssalquake", { Stage = "Start", Char = Character, Animation = UserAnimation.AnimationId })
		
		SoundsModule:PlaySound(MoveSounds["Volt Viper"]["abyssal quake"].startup, HumRP)
	end
}