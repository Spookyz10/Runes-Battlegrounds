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
		iFramesService:AddAlliFrames(Character)
		
		
		local UserAnimation = MoveAnims.Subzero["Frost Forge"].User
		local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
		local UserEvents = {}
		
		
		local Sword = Weapons.Subzero.untitled:Clone()
		Sword.Parent = Character
		Sword.Spear.Part0 = Character['Right Arm']
		
		
		local currHitboxCF
		local knockback = 60
		local hitbox = HitboxHandler.new()
		hitbox.ResetCharactersList = true
		hitbox.Size = Vector3.new(65 ,30 ,30)
		hitbox.onTouch = function(EnemyCharacter)
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

			if EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 then return end
			
			local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 13.5, nil, nil, true, false, true, true, true) --was 20
			if HitInfo.Blocked == true then
				return
			end
			
			
			RagdollHandler.ragdoll(EnemyHumanoid, 2)
			NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity'; MaxForce = Vector3.new(1, 1, 1) * 75000; Velocity = -CFrame.lookAt(EnemyHumRP.Position, currHitboxCF.Position).LookVector * knockback + Vector3.new(0, knockback, 0); })
			
			
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
		
		UserEvents["jump"] = UserTrack:GetMarkerReachedSignal("jump"):Once(function()
			task.delay(0.1, function()
				ReplicateEffects_Set:FireAllClients('RemoveAllBodyMovers', Character)
			end)
			
			ReplicateEffects_Set:FireAllClients("frostForge", { char = Character, id = UserAnimation.AnimationId })
			
			SoundsModule:PlaySound(MoveSounds.Subzero["Frost Forge"].Throw, HumRP)
		end)
		
		UserEvents["throw"] = UserTrack:GetMarkerReachedSignal("throw"):Once(function()
			local CameraCF = ComGet:InvokeClient(Player, { Func = "GetCF", Object = "Camera" })

			local rayOrigin = CameraCF.Position
			local rayDirection = CameraCF.LookVector * 160
			local rayResult = workspace:Raycast(rayOrigin, rayDirection, MapRayParams)

			local explodeCFrame
			if rayResult then
				explodeCFrame = CFrame.new(rayResult.Position)
			else
				explodeCFrame = CFrame.new(rayOrigin + rayDirection)
			end
			
			
			ReplicateEffects_Set:FireAllClients("frostForge", { char = Character, id = UserAnimation.AnimationId, explode = explodeCFrame })
			ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 4, Last = nil })
			
			currHitboxCF = explodeCFrame
			hitbox.Instance = explodeCFrame

			hitbox:Once()
			hitbox:Destroy()
			
			Sword:Destroy()
			
			SoundsModule:PlaySound(MoveSounds.Subzero["Frost Forge"].Explosion, HumRP)
			SoundsModule:PlaySound(MoveSounds.Subzero["Frost Forge"].Ice, HumRP)
			SoundsModule:PlaySound(MoveSounds.Subzero["Frost Forge"].Glass, HumRP)
		end)
		
		UserEvents["end"] = UserTrack:GetMarkerReachedSignal("end"):Once(function()
			for _,v in UserEvents do
				v:Disconnect()
			end
			
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)
		end)
		
		
		UserTrack.Stopped:Once(function()
			for _,v in UserEvents do
				v:Disconnect()
			end
			
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)
		end)
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
		
		ReplicateEffects_Set:FireAllClients("frostForge", { char = Character, id = UserAnimation.AnimationId, spear = Sword })
		
		SoundsModule:PlaySound(MoveSounds.Subzero["Frost Forge"].Startup, HumRP)
	end
}