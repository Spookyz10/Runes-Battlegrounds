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
		
		
		Player.AwakeningProgress.Value = 0
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)


		local Bind = Instance.new("ObjectValue")
		Bind.Parent = workspace
		Bind.Value = nil
		
		
		local Hit = false
		
		
		Character:AddTag('CantRotate')
		
		
		local StartAnimation = MoveAnims.BaldHero["Omni Directional Punch"].User
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}
		
		
		
		StartEvents['bass'] = StartTrack:GetMarkerReachedSignal('bass'):Once(function()
			StartTrack:AdjustSpeed(0.65)
			
			ReplicateEffects_Set:FireClient(Player, "SetAwkbar", { State = true })
			
			SoundsModule:PlaySound(MoveSounds.Baldhero["Omni Directional Punch"].Bass, HumRP)
			SoundsModule:PlaySound(MoveSounds.Baldhero["Omni Directional Punch"].Kick, HumRP)
		end)
		

		StartEvents['hit'] = StartTrack:GetMarkerReachedSignal('hit'):Once(function()
			SoundsModule:PlaySound(MoveSounds.Baldhero["Omni Directional Punch"].Hit, HumRP)
			StartTrack:AdjustSpeed(1)
			
			ReplicateEffects_Set:FireAllClients("OmniDirectionalPunch", { Char = Character, Bind = Bind, Root = HumRP, Seed = math.rad(5, 10), User = Character })
			
			local Hitbox2 = HitboxHandler.new()
			Hitbox2.Instance = HumRP
			Hitbox2.Size = Vector3.new(100, 115, 175) 
			Hitbox2.Offset = CFrame.new(0, 0, -88)
			Hitbox2.Ignore = { Character }
			Hitbox2.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(100, 115, 175) + Vector3.new(0, 150, 0) }
			Hitbox2.onTouch = function(EnemyCharacter)
				local EnemyPlayer = game.Players:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				

				RagdollHandler.ragdoll(EnemyHumanoid, 4.5, true, Character)
				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(1, 2, 1) * math.huge, Velocity = Vector3.new(HumRP.CFrame.LookVector.X * 10, 185, HumRP.CFrame.LookVector.Z * 10) })
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 35, nil, nil, false, false, nil, false, true, nil)
				StartAirDetect:Fire(EnemyCharacter)
				
				
				local VFX = Models["Uppercut VFX"].Uppercut_Start:Clone()
				VFX.Parent = EnemyCharacter

				local function touchGround()
					VFX:Destroy()
				end

				task.spawn(function()
					for _, descendant in VFX:GetDescendants() do
						if descendant:IsA("ParticleEmitter") then
							descendant.Enabled = true
						end	
					end

					local inAir = EnemyCharacter:FindFirstChild('inAir')
					if inAir then
						inAir.Destroying:Once(touchGround)
					else
						touchGround()
					end
				end)


				ReplicateEffects_Set:FireAllClients("saitamaAirTrail", { Hit = EnemyCharacter, Root = EnemyHumRP, Uppercut = VFX, NoEffects = true })
			end
			
			Hitbox2:Once()
			Hitbox2:Destroy()
			
			
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP
			Hitbox.HitType = 'Single'
			Hitbox.Ignore = { Character }
			Hitbox.Size = Vector3.new(30.972, 62.057, 42.894)
			Hitbox.Offset = CFrame.new(0, 0, -21.546)
			Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(30.972, 62.057, 42.894) + Vector3.new(0, 150, 0) }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = game.Players:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				
				Hit = true
				StatesHandler.SkillText(Player, "OMNI DIRECTIONAL PUNCH [HIT]")
				
				
				if EnemyCharacter:HasTag('Ragdolled') then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
				end
				
				
				task.delay(3, function()
					ReplicateEffects_Set:FireClient(Player, "omniMusic", { Stage = 'Start' })
				end)
				
				
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				
				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)
				
				
				Bind:SetAttribute("startcfr", HumRP.CFrame)
				Bind.Value = EnemyCharacter
				Bind.Parent = EnemyCharacter
				
				
				HumRP.Anchored = true
				EnemyHumRP.Anchored = true
				
				Character:AddTag('CantRotate')
				EnemyCharacter:AddTag('CantRotate')
				
				
				local VictimAnimation = MoveAnims.BaldHero["Omni Directional Punch"].Victim
				local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
				
				
				task.delay(16.5, function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 100, nil, nil, false, false, nil, false, true, nil)
					HumRP.Anchored = false
					
					
					local LandAnimation = MoveAnims.BaldHero["Omni Directional Punch"].Land
					local LandTrack = AnimationService:getAnimationTrack(Character, LandAnimation)
					
					
					task.delay(0.1, function()
						local clouds = game.Workspace.Terrain.Clouds
						TweenService:Create(clouds,TweenInfo.new(0.5,Enum.EasingStyle.Cubic),{Density = 0}):Play()

						task.delay(3, function()
							TweenService:Create(clouds,TweenInfo.new(10,Enum.EasingStyle.Sine),{Density = 0.293}):Play()
						end)

						task.delay(0.3, function()
							ReplicateEffects_Set:FireAllClients("Flash", { Char = Character; })
						end)

						task.delay(0.2, function()
							ReplicateEffects_Set:FireAllClients("cricleSmoke", { Char = Character; } )
						end)
					end)
					
					
					LandTrack.Stopped:Once(function()
						StunHandler:Unstun(EnemyCharacter, EnemyStun)
						iFramesService:RemoveAlliFrames(EnemyCharacter)
						
						StunHandler:Unstun(Character, Stun)
						iFramesService:RemoveAlliFrames(Character)
						Character:RemoveTag('CantRotate')
					end)
					
					
					AnimationService:stopAll(Character)
					AnimationService:playAnimation(Character, LandAnimation)
					
					SoundsModule:PlaySound(MoveSounds.Baldhero["Omni Directional Punch"].Land, HumRP)
				end)
				
				
				VictimTrack.Stopped:Once(function()
					for _,v in StartEvents do
						v:Disconnect()
					end
					
					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					iFramesService:RemoveAlliFrames(EnemyCharacter)

					task.delay(2.25, function()
						StunHandler:Unstun(Character, Stun)
						iFramesService:RemoveAlliFrames(Character)
						Character:RemoveTag('CantRotate')
					end)
				end)
				
				
				AnimationService:stopAll(EnemyCharacter)
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
			end

			Hitbox:Once()
			Hitbox:Destroy()
			
			if not Hit then
				if Bind then
					Bind:Destroy()
				end

				task.delay(0.765, function()
					if StartTrack then
						StartTrack:Stop(0.4)
					end
				end)
			end
		end)
		
		
		StartTrack.Stopped:Once(function()
			for _,v in StartEvents do
				v:Disconnect()
			end
			
			if not Hit then
				Character:RemoveTag('CantRotate')
				iFramesService:RemoveAlliFrames(Character)
				StunHandler:Unstun(Character, Stun)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
		
		SoundsModule:PlaySound(MoveSounds.Baldhero["Omni Directional Punch"].Ready, HumRP)
		
		StatesHandler.SkillText(Player, "OMNI DIRECTIONAL PUNCH [USED]")
	end
}