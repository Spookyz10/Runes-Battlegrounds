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
		
		local limbNames = { "Right Arm", "Left Arm", "Right Leg", "Left Leg", }


		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)
		Player.AwakeningProgress.Value = 0
		
		
		local Hit = false
		
		
		for i, v in Character:GetChildren() do
			if v:IsA("BasePart") then
				if table.find(limbNames, v.Name) then
					ReplicateEffects_Set:FireAllClients("armTrailEffect", { char = Character, lifeTime = 6, limbName = v.Name })
				end
			end
		end
		
		
		Character:AddTag('CantRotate')
		
		
		local UserAnimation = MoveAnims.BaldHero["Table Flip"].User
		local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
		local UserEvents = {}
		
		
		
		task.spawn(function()
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP
			Hitbox.Ignore = { Character }
			Hitbox.Size = Vector3.new(1, 1, 1) * 25
			Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(1, 1, 1) * 25 + Vector3.new(0, 150, 0) }
			Hitbox.Offset = CFrame.new(0, 0, -3.5)
			Hitbox.onTouch = function(EnemyCharacter)
				if EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter.Humanoid.Health <= 0  then return end
				
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 0.1, nil, nil, false, false, true, false, false, nil)
				
				if EnemyCharacter:HasTag('Ragdolled') then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
				end
				
				local KnockbackAnimation = Animations.Other.Knockback
				local KnockbackTrack = AnimationService:getAnimationTrack(EnemyCharacter, KnockbackAnimation)
				local KnockbackEvents = {}


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
		
		
		
		
		ReplicateEffects_Set:FireAllClients("tableFlipCam", { Char = Character, Root = HumRP, Code = 40 })
		
		UserEvents["slam"] = UserTrack:GetMarkerReachedSignal("slam"):Once(function()
			ReplicateEffects_Set:FireAllClients("tableFlip", { Char = Character, Root = HumRP, Code = 40 })
			
			SoundsModule:PlaySound(MoveSounds.Baldhero["Table Flip"]["Slam No Rock"], HumRP)
			SoundsModule:PlaySound(MoveSounds.Baldhero["Table Flip"]["Slam With Rock"], HumRP)
		end)
		
		
		task.delay(6.223, function()
			task.delay(0.045, function()
				ReplicateEffects_Set:FireAllClients('Whiteout', { Inverse = false, Sphere = false, ["Wait"] = 0.1, JustWhite = true } )
			end)

			local FirstProps = { Size = Vector3.new(10,500,10), Transparency = 0 }
			local FinalProps = { Size = Vector3.new(700,0,700), Transparency = 1 }
			local TN_Info = { Time = 0.5, Style = 'Sine', Direction = 'Out' }
			local humrpCF2 = HumRP.CFrame * CFrame.Angles(math.rad(180),0,0)

			ReplicateEffects_Set:FireAllClients('Ring', { FirstProps = FirstProps, CF = humrpCF2, TN_Info = TN_Info, FinalProps = FinalProps } )
		end)
		
		
		UserEvents["start"] = UserTrack:GetMarkerReachedSignal("start"):Once(function()
			ReplicateEffects_Set:FireAllClients('Whiteout', { Inverse = true; Sphere = false; ["Wait"] = 0.1; JustWhite = true; } )

			ReplicateEffects_Set:FireAllClients("tableFlipTime", { Char = Character; Root = HumRP; Code = 40; })
			
			
			task.delay(0.038, function()
				local FirstProps = { Size = Vector3.new(0,6,0), Transparency = 0 }
				local FinalProps = { Size = Vector3.new(235,1,235), Transparency = 0.7 }
				local FirstProps2 = { Size = Vector3.new(0,17,0), Transparency = 0 }
				local FinalProps2 = { Size = Vector3.new(450,1,450), Transparency = 0.7 }
				local FirstPropsLong = { Size = Vector3.new(15,700,15), Transparency = 0 } 
				local FinalPropsLong = { Size = Vector3.new(0,700,0), Transparency = 1 }

				local TN_Info = { Time = 0.2, Style = 'Sine', Direction = 'Out' }
				local TN_Info2 = { Time = 0.1, Style = 'Sine', Direction = 'Out' }
				local TN_Info25 = { Time = 0.15, Style = 'Sine', Direction = 'Out' }
				local TN_Info3 = { Time = 0.3, Style = 'Sine', Direction = 'Out' }
				local TN_Info4 = { Time = 0.4, Style = 'Sine', Direction = 'Out' }

				local humrpCF2 = HumRP.CFrame * CFrame.Angles(math.rad(180),0,0)

				ReplicateEffects_Set:FireAllClients('Ring', { FirstProps = FirstProps, CF = humrpCF2, TN_Info = TN_Info25, FinalProps = FinalProps } )
				ReplicateEffects_Set:FireAllClients('Ring', { FirstProps = FirstProps2, CF = humrpCF2, TN_Info = TN_Info25, FinalProps = FinalProps2 } )
				ReplicateEffects_Set:FireAllClients('Ring', { FirstProps = FirstPropsLong, CF = humrpCF2, TN_Info = TN_Info25, FinalProps = FinalPropsLong } )
			end)
			

			task.delay(2, function()
				ReplicateEffects_Set:FireClient(Player, "SetAwkbar", { State = true })
			end)
			

			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP.CFrame
			Hitbox.Size = Vector3.new(85, 284.327, 406.105)
			Hitbox.Offset = CFrame.new(0.462, 0, -351.441) * CFrame.Angles(math.rad(0), math.rad(-124), math.rad(90))
			Hitbox.Ignore = { Character }
			Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(85, 284.327, 406.105) + Vector3.new(0, 150, 0) }
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

					DamageHandler:TakeDamage(Character, EnemyHumanoid, 30, nil, nil, false, false, nil, false, true)
					RagdollHandler.ragdoll(EnemyHumanoid, 5, true, Character)
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(0.5, 5, 0.5) * math.huge, Velocity = Vector3.new(HumRP.CFrame.LookVector.X * 10, 300, HumRP.CFrame.LookVector.Z * 10) })
					
					
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
					
					SoundsModule:PlaySound(MoveSounds.Baldhero["Table Flip"].Fly, EnemyCharacter.Torso)
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
			
			local Hitbox2 = HitboxHandler.new()
			Hitbox2.Instance = HumRP.CFrame
			Hitbox2.Size = Vector3.new(85, 141.897, 377.34)
			Hitbox2.Offset = CFrame.new(-79.09, 0, -234.893) * CFrame.Angles(math.rad(0), math.rad(-144), math.rad(90))
			Hitbox2.Ignore = { Character }
			Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(85, 141.897, 377.34) + Vector3.new(0, 150, 0) }
			Hitbox2.onTouch = function(EnemyCharacter)
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

					DamageHandler:TakeDamage(Character, EnemyHumanoid, 50, nil, nil, false, false, nil, false, true)
					RagdollHandler.ragdoll(EnemyHumanoid, 5, true, Character)
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(0.5, 5, 0.5) * math.huge, Velocity = Vector3.new(HumRP.CFrame.LookVector.X * 10, 300, HumRP.CFrame.LookVector.Z * 10) })
					
					
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
					
					SoundsModule:PlaySound(MoveSounds.Baldhero["Table Flip"].Fly, EnemyCharacter.Torso)
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
			
			Hitbox2:Once()
			Hitbox2:Destroy()
			
			local Hitbox3 = HitboxHandler.new()
			Hitbox3.Instance = HumRP.CFrame
			Hitbox3.Size = Vector3.new(85, 27.408, 50.576)
			Hitbox3.Offset = CFrame.new(-7.189, 0, -32.444) * CFrame.Angles(math.rad(0), math.rad(-144), math.rad(90))
			Hitbox3.Ignore = { Character }
			Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(85, 27.408, 50.576) + Vector3.new(0, 150, 0) }
			Hitbox3.onTouch = function(EnemyCharacter)
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

					DamageHandler:TakeDamage(Character, EnemyHumanoid, 100, nil, nil, false, false, nil, false, true)
					RagdollHandler.ragdoll(EnemyHumanoid, 5, true, Character)
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = 'Velocity', MaxForce = Vector3.new(0.5, 5, 0.5) * math.huge, Velocity = Vector3.new(HumRP.CFrame.LookVector.X * 10, 300, HumRP.CFrame.LookVector.Z * 10) })
					
					
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
					
					SoundsModule:PlaySound(MoveSounds.Baldhero["Table Flip"].Fly, EnemyCharacter.Torso)
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

			Hitbox3:Once()
			Hitbox3:Destroy()
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
		
		StatesHandler.SkillText(Player, "TABLE FLIP [USED]")
	end
}