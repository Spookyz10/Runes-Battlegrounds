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
		
		if Player:GetAttribute("DamageNeed") and Player:GetAttribute("DamageNeed") >= 1 then
			Player:SetAttribute("DamageNeed", 0)

			task.spawn(function()
				ComSet:FireClient(Player, 'ModifyHotbar', { ToolName = 'Special Hell', Property = 'Description', Value = 'NOT READY' })
			end)
			
			
			local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
			iFramesService:AddAlliFrames(Character)
			Character:AddTag('CantRotate')


			local UserAnimation = MoveAnims["Cursed Child"]["Special Hell"].User
			local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)
			
			local Size = Vector3.new(230, 230, 230)
			
			local Hitbox1 = HitboxHandler.new()
			Hitbox1.Instance = HumRP
			Hitbox1.Size = Size
			Hitbox1.Offset = CFrame.new(0, 0, 0)
			Hitbox1.Ignore = { Character }
			Hitbox1.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Size + Vector3.new(0, 0, 0) }
			Hitbox1.onTouch = function(EnemyCharacter: Model)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
				
				
				RagdollHandler.ragdoll(EnemyHumanoid, 2.25)
				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 100000, 1), Velocity = HumRP.CFrame.UpVector * 30, Time = 0.5 })
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 15, nil, nil, false, false, false, true, true, nil, nil)
			end
			
			local Hitbox2 = HitboxHandler.new()
			Hitbox2.Instance = HumRP
			Hitbox2.Size = Size
			Hitbox2.Offset = CFrame.new(0, 0, 0)
			Hitbox2.Ignore = { Character }
			Hitbox2.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Size + Vector3.new(0, 0, 0) }
			Hitbox2.onTouch = function(EnemyCharacter: Model)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end


				RagdollHandler.ragdoll(EnemyHumanoid, 2.25)
				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 100000, 1), Velocity = HumRP.CFrame.UpVector * 80, Time = 1 })
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 20, nil, nil, false, false, false, true, true, nil, nil)
			end
			
			local Hitbox3 = HitboxHandler.new()
			Hitbox3.Instance = HumRP
			Hitbox3.Size = Size
			Hitbox3.Offset = CFrame.new(0, 0, 0)
			Hitbox3.Ignore = { Character }
			Hitbox3.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Size + Vector3.new(0, 0, 0) }
			Hitbox3.onTouch = function(EnemyCharacter: Model)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end


				RagdollHandler.ragdoll(EnemyHumanoid, 2.25)
				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(75000, 75000, 75000), Velocity = HumRP.CFrame.LookVector * 55 + Vector3.new(0, 10, 0) })
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 30, nil, nil, false, false, false, true, true, nil, nil)
			end
			
			
			table.insert(UserEvents, UserTrack:GetMarkerReachedSignal("vfx"):Once(function()
				Hitbox1:Once()
				Hitbox1:Destroy()
			end))
			
			task.delay(1.75, function()
				Hitbox2:Once()
				Hitbox2:Destroy()
			end)
			
			task.delay(2.9, function()
				Hitbox3:Once()
				Hitbox3:Destroy()
			end)
			
			
			UserTrack.Stopped:Once(function()
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
				Character:RemoveTag('CantRotate')
			end)


			AnimationService:stopAll(Character)
			AnimationService:playAnimation(Character, UserAnimation)

			ReplicateEffects_Set:FireAllClients("SpecialHell", { Stage = "Start", Char = Character, StartAnim = UserAnimation.AnimationId })
		end
	end
}