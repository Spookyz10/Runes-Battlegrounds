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
local StatesHandler = require(ServerModules.StatesHandler)


local Utility = shared.Utility
local WeldSystem = require(ReplicatedModules.WeldSystem)
local Trove = require(ReplicatedModules.Trove)
local SoundHandler = require(ReplicatedModules.SoundHandler)


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
		local HumRP: BasePart = Character.HumanoidRootPart
		local Humanoid: Humanoid = Character.Humanoid
		
		
		local Camera = Models["Serious Cam"]:Clone()
		Camera.Parent = Character
		Camera.camerarootpart.CFrame = HumRP.CFrame
		
		
		local limbNames = { "Right Arm", "Left Arm", "Right Leg", "Left Leg", }


		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)
		
		
		local Hit = false
		
		
		for i, v in Character:GetChildren() do
			if v:IsA("BasePart") then
				if table.find(limbNames, v.Name) then
					ReplicateEffects_Set:FireAllClients("armTrailEffect", { char = Character, lifeTime = 6, limbName = v.Name })
				end
			end
		end
		
		
		task.delay(1.29, function()
			local Push = ReplicatedStorage.Resources.Bald.saint.Push:Clone()
			Push.Parent = Character:WaitForChild("Torso")
			Push:Emit(Push:GetAttribute("Emitcount"))
			game.Debris:AddItem(Push, 1.5)
		end)
		
		
		Character:AddTag('CantRotate')
		
		
		local animationInstance2 = Instance.new("Animation")
		animationInstance2.AnimationId = "rbxassetid://123872787259121"
		local Camanim : AnimationTrack = Camera.AnimationController.Animator:LoadAnimation(animationInstance2)
		Camanim:Play(0)
		
		
		local UserAnimation = MoveAnims.BaldHero["Serious Punch"].User
		local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
		local UserEvents = {}
		
		
		ReplicateEffects_Set:FireClient(Player, "seriousCamera", { Char = Character; Follow = Camera.camera; })
		
		
		UserEvents["move"] = UserTrack:GetMarkerReachedSignal("move"):Once(function()
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP
			Hitbox.Ignore = { Character }
			Hitbox.Size = Vector3.new(20, 25, 20)
			Hitbox.Offset = CFrame.new(0, -2.5, 0)
			Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(20, 25, 20) + Vector3.new(0, 150, 0) }
			Hitbox.onTouch = function(EnemyCharacter)
				if EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter.Humanoid.Health <= 0 then return end

				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 0.1, nil, nil, false, false, true, false, false, nil)
				
				if EnemyCharacter:HasTag('Ragdolled') then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
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
				
				StunHandler:Stun(EnemyCharacter, 5, true, 0.5, 0, true)
			end

			Hitbox:Once()
			Hitbox:Destroy()
		end)

		UserEvents["steptwo"] = UserTrack:GetMarkerReachedSignal("steptwo"):Once(function()

		end)

		UserEvents["movetwo"] = UserTrack:GetMarkerReachedSignal("movetwo"):Once(function()
			SoundsModule:PlaySound(MoveSounds.Baldhero["Serious Punch"].Startup, HumRP)
		end)
		
		UserEvents["step"] = UserTrack:GetMarkerReachedSignal("step"):Once(function()

		end)
		
		UserEvents["ready"] = UserTrack:GetMarkerReachedSignal("ready"):Once(function()

		end)
		
		UserEvents["set"] = UserTrack:GetMarkerReachedSignal("set"):Once(function()

		end)
		
		UserEvents["go"] = UserTrack:GetMarkerReachedSignal("go"):Once(function()
			ReplicateEffects_Set:FireAllClients("seriousPunch", { Char = Character; Root = HumRP; })
			
			if Camera or Camanim then
				Camera:Destroy()
				Camanim:Stop(0)
			end
			
			local clouds = game.Workspace.Terrain.Clouds
			TweenService:Create(clouds,TweenInfo.new(0.5,Enum.EasingStyle.Cubic),{Density = 0}):Play()

			task.delay(5, function()
				TweenService:Create(clouds,TweenInfo.new(5,Enum.EasingStyle.Sine),{Density = 0.7}):Play()

				task.delay(6, function()
					TweenService:Create(clouds,TweenInfo.new(3,Enum.EasingStyle.Sine),{Density = 0.293}):Play()
				end)
			end)
			
			task.delay(2, function()
				Player.AwakeningProgress.Value = 0
			end)

			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP.CFrame
			Hitbox.Size = Vector3.new(17, 10, 35) * 9
			Hitbox.Offset = CFrame.new(0, 0, -160)
			Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(17, 10, 35) * 9 + Vector3.new(0, 150, 0) }
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = game.Players:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end

				iFramesService:AddAlliFrames(Character)
				AnimationService:stopAll(EnemyCharacter)
				
				
				task.delay(.115, function()
					if not EnemyCharacter or (EnemyCharacter and not EnemyHumRP) then return end

					StartAirDetect:Fire(EnemyCharacter)

					ReplicateEffects_Set:FireAllClients('PushTrail', { Char = EnemyCharacter })

					DamageHandler:TakeDamage(Character, EnemyHumanoid, 9999, nil, nil, false, false, nil, false, true)
					RagdollHandler.ragdoll(EnemyHumanoid, 3, true, Character)
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(3.5, 3, 3.5) * math.huge, Velocity = Vector3.new(HumRP.CFrame.LookVector.X * 750, 185, HumRP.CFrame.LookVector.Z * 750) })
				end)
				
				UserTrack.Stopped:Once(function()
					for _,v in UserEvents do
						v:Disconnect()
					end
					
					StunHandler:Unstun(Character, Stun)
					Character:RemoveTag('CantRotate')
					iFramesService:RemoveAlliFrames(Character)
				end)
			end

			Hitbox:Once()
			Hitbox:Destroy()
			
			SoundsModule:PlaySound(MoveSounds.Baldhero["Serious Punch"].Hit, HumRP)
			SoundHandler:AddSound(MoveSounds.Baldhero["Serious Punch"]["Hit Ambience"], workspace)
		end)
		

		UserTrack.Stopped:Once(function()
			for _,v in UserEvents do
				v:Disconnect()
			end
			
			if Hit == true then return end
			Character:RemoveTag('CantRotate')
			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)
		end)
		

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
		
		SoundsModule:PlaySound(MoveSounds.Baldhero["Serious Punch"]["Fist Tight"], HumRP)
		
		StatesHandler.SkillText(Player, "SERIOUS PUNCH [USED]")
	end
}