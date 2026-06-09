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
		
		
		local StartAnimation = MoveAnims.Subzero.Permafrost.Startup
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}
		
		
		task.delay(0.7, function()
			if not StartTrack.IsPlaying then return end
			
			ReplicateEffects_Set:FireAllClients("Permafrost", { char = Character, id = StartAnimation.AnimationId, explode = true, att = HumRP })
			ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 4, Last = nil })
			
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(30, 30, 65)
			Hitbox.Offset = CFrame.new(0, 0, -Hitbox.Size.Z/2)
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

				if EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 then return end
				
				
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 14, nil, nil, false, false, true, true, true, nil, nil) --was 20
				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity'; MaxForce = Vector3.new(1, 1, 1) * 100000; Velocity = HumRP.CFrame.LookVector * Vector3.new(75, 0, 75) + Vector3.new(0, 75/2, 0); })
				RagdollHandler.ragdoll(EnemyHumanoid, 2)
				
				
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
			
			Hitbox:Once()
			Hitbox:Destroy()
			
			SoundsModule:PlaySound(MoveSounds.Subzero.Permafrost.Explosion, HumRP)
			SoundsModule:PlaySound(MoveSounds.Subzero.Permafrost.Ice, HumRP)
		end)
		
		
		StartEvents["end"] = StartTrack:GetMarkerReachedSignal("end"):Once(function()
			for _,v in StartEvents do
				v:Disconnect()
			end
			
			StunHandler:Unstun(Character, Stun)
		end)
		
		
		StartTrack.Stopped:Once(function()
			for _,v in StartEvents do
				v:Disconnect()
			end
			
			StunHandler:Unstun(Character, Stun)
		end)
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
		
		ReplicateEffects_Set:FireAllClients("Permafrost", { char = Character, id = StartAnimation.AnimationId, startup = true })
		
		SoundsModule:PlaySound(MoveSounds.Subzero.Permafrost.Startup, HumRP)
	end
}