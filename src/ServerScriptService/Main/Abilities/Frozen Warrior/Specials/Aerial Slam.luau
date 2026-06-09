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
local Clock = services:GetService("Clock")


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
		
		
		local StartAnimation = MoveAnims["Frozen Warrior"]["Aerial Slam"].Startup
		local StartTrack, StartEvents = AnimationService:getAnimationTrack(Character, StartAnimation)
		
		
		local Hit = false
		
		
		local function HitFunction(EnemyCharacter: Model)
			if Hit == true or StartTrack.IsPlaying == false then return end
			Hit = true


			local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid


			if EnemyCharacter:HasTag('Ragdolled') then
				RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
			end
			
			
			local UserAnimation = MoveAnims["Frozen Warrior"]["Aerial Slam"].Main
			local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

			local VictimAnimation = MoveAnims["Frozen Warrior"]["Aerial Slam"].Victim
			local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)


			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
			local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, 0), -1)


			EnemyCharacter:AddTag('CantRotate')

			iFramesService:AddAlliFrames(Character)
			iFramesService:AddAlliFrames(EnemyCharacter)

			CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
			
			
			task.delay(0.65, function()
				EnemyCharacter.PrimaryPart.CFrame = HumRP.CFrame * CFrame.new(0, 0, -1.5)
				
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 8.5, nil, nil, false, false, true, true, true, nil, nil)
				knockbackService.Knockback(EnemyCharacter.PrimaryPart, {
					["duration"] = 0.2,
					["force"] = 26,
					["direction"] = HumRP.CFrame.LookVector + Vector3.new(0, 0.7, 0)
				})
				RagdollHandler.ragdoll(EnemyHumanoid, 1.5)
				
				local RayResult = workspace:Raycast(HumRP.CFrame.Position + Vector3.new(0, 3, 0), Vector3.new(-0, -30, -0), MapRayParams)
				if RayResult then
					ReplicateEffects_Set:FireAllClients("AerialSlam", { Char = Character, Stage = "slam", pos = RayResult.Position, normal = RayResult.Normal })
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
			
			
			Character:SetAttribute("StunSubject", "UsingSkill_" .. "Aerial Slam" .. "_Hit")
			
			
			AnimationService:stopAll(Character)
			AnimationService:stopAll(EnemyCharacter)
			AnimationService:playAnimation(Character, UserAnimation)
			AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
			
			
			Weld:Start(nil, EnemyPlayer, Player)
		end
		
		
		task.delay(0.35, function()
			local Hitbox = ReplicatedHitbox.new(Player)
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(8, 8, 10)
			Hitbox.Offset = CFrame.new(0, 0, -3)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 0.5, nil, nil, false, EnemyCharacter:HasTag('DEATH') and true or false, true, true, false, nil, nil)
				if HitInfo.Countered then return end
				
				HitFunction(EnemyCharacter)
				
				Hitbox:Destroy()
			end
			
			Hitbox:Start(0.35, true)
		end)
		
		
		Character:SetAttribute("StunSubject", "UsingSkill_" .. "Aerial Slam" .. "_Startup")
		
		
		StartTrack.Stopped:Once(function()
			if not Hit then
				StunHandler:Unstun(Character, Stun)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
		
		ReplicateEffects_Set:FireAllClients("AerialSlam", { Char = Character, Stage = "psa" })
	end
}