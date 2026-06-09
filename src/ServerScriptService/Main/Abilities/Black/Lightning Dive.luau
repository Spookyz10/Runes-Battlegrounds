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
		
		
		local StartAnimation = MoveAnims.Black["Lightning Dive"].Main
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}
		
		
		local Hit = false
		
		
		TweenService:Create(Character["Left Arm"], TweenInfo.new(0.1), {
			["Transparency"] = 1
		}):Play()

		task.delay(1.6, function()
			TweenService:Create(Character["Left Arm"], TweenInfo.new(0.2), {
				["Transparency"] = 0
			}):Play()
		end)
		
		
		local function createMutatedArm()
			local mutatedArm = Models.Black.MutatedArm:Clone()
			mutatedArm:PivotTo(HumRP.CFrame)
			Debris:AddItem(mutatedArm, 1.617)
			for _, armPart in mutatedArm:GetChildren() do
				if armPart:IsA("MeshPart") and string.match(armPart.Name, "Arm") then
					armPart.CFrame = HumRP.CFrame
					armPart["Mutated" .. armPart.Name].Part0 = Character["Left Arm"]
					armPart.Transparency = 1

					task.delay(0.1, function()
						armPart.Transparency = 0
					end)
				end
			end

			mutatedArm.Parent = Character
			return mutatedArm
		end
		local currentMutatedArm = createMutatedArm()
		
		
		local function hitFunction(EnemyCharacter: Model)
			local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			
			pcall(function()
				currentMutatedArm:Destroy()
			end)
			
			local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, false, false, true, true, false, nil, 15)
			
			if HitInfo.Finisher == true then
				local FirstAnimation = MoveAnims.Black["Lightning Dive"].HitMain
				local FirstTrack = AnimationService:getAnimationTrack(Character, FirstAnimation)
				
				local UserAnimation = MoveAnims.Black["Lightning Dive"].Finisher.Main
				local VictimAnimation = MoveAnims.Black["Lightning Dive"].Finisher.Victim
				
				local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
				local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)
				
				
				task.spawn(function()
					local MutatedArm = Models.Black.MutatedArm:Clone()
					MutatedArm:PivotTo(HumRP.CFrame)
					Debris:AddItem(MutatedArm, 0.717)
					
					for _, Object in MutatedArm:GetChildren() do
						if Object:IsA("MeshPart") and string.match(Object.Name, "Arm") then
							Object.CFrame = HumRP.CFrame
							Object["Mutated" .. Object.Name].Part0 = Character["Left Arm"]
							Object.Transparency = 1
							
							task.delay(0.1, function()
								Object.Transparency = 0
							end)
						end
					end
					
					MutatedArm.Parent = Character
				end)
				
				
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -2) * CFrame.Angles(0, 3.141592653589793, 0), -1)
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				pcall(function()
					RagdollHandler.ragdoll(EnemyHumanoid, 2)
				end)
				
				
				Character:AddTag('CantRotate')
				EnemyCharacter:AddTag('CantRotate')
				
				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)
				
				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
				
				
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 2.5, nil, nil, false, false, true, true, false, nil, nil)
				
				
				knockbackService.Knockback(EnemyCharacter.PrimaryPart, {
					["duration"] = 0.15,
					["force"] = 10,
					["direction"] = HumRP.CFrame.LookVector + Vector3.new(0, 0.3, 0)
				})
				
				
				
				task.delay(0.717, function()
					if EnemyCharacter:HasTag('Ragdolled') then
						RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
					end
					
					EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
					
					AnimationService:stopAll(Character)
					AnimationService:stopAll(EnemyCharacter)
					AnimationService:playAnimation(Character, UserAnimation)
					AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
					
					
					pcall(function()
						Weld:Start(nil, EnemyPlayer, Player)
					end)
					
					
					local function TakeDamage()
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 1.25, nil, nil, false, false, true, true, false, nil, nil)
					end
					
					
					for Time, Func in {
						[55] = TakeDamage,
						[219] = TakeDamage,
						[243] = TakeDamage,
						[273] = TakeDamage,
						[304] = TakeDamage,
						[332] = TakeDamage,
						[360] = TakeDamage,
						[391] = TakeDamage,
						[422] = TakeDamage,
						[450] = TakeDamage,
						[580] = TakeDamage,
						[599] = TakeDamage,
						[627] = TakeDamage,
						[653] = TakeDamage
						} do
						task.delay(Time / 60, Func, Time)
					end
					
					
					task.delay(11.1, function()
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
						
						
						RagdollHandler.ragdoll(EnemyHumanoid, 2.5)
						DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, true, true, true, nil, nil)
						
						
						if workspace:Raycast(HumRP.CFrame.Position, Vector3.new(-0, -15, -0), MapRayParams) then
							knockbackService.Knockback(EnemyCharacter.PrimaryPart, {
								["duration"] = 0.3,
								["force"] = 85,
								["direction"] = -HumRP.CFrame.RightVector + Vector3.new(0, 0.5, 0)
							})
							
						end
					end)
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
					Character:RemoveTag('CantRotate')
					iFramesService:RemoveAlliFrames(Character)
					CollisionsModule:SetCollisionGroup(Character, "Players")

					Janitor:Destroy()
				end)
				
				
				AnimationService:stopAll(EnemyCharacter)
				AnimationService:stopAll(Character)
				AnimationService:playAnimation(Character, FirstAnimation)
				
				
				ReplicateEffects_Set:FireAllClients("LightningDiveFinisher", { Char = Character })
			else
				currentMutatedArm = createMutatedArm()
				local startTime = workspace:GetServerTimeNow()


				local UserAnimation = MoveAnims.Black["Lightning Dive"].HitMain
				local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
				local UserEvents = {}

				local VictimAnimation = MoveAnims.Black["Lightning Dive"].HitVictim
				local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)


				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -2) * CFrame.Angles(0, math.pi, 0), -1)


				Stun:SetAttribute("WalkSpeed", 3)
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)


				EnemyCharacter:AddTag('CantRotate')

				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)

				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")


				DamageHandler:TakeDamage(Character, EnemyHumanoid, 2.5, nil, nil, false, false, true, true, false, nil, nil)

				knockbackService.Knockback(EnemyCharacter.PrimaryPart, {
					["duration"] = 0.15,
					["force"] = 10,
					["direction"] = HumRP.CFrame.LookVector + Vector3.new(0, 0.3, 0)
				})


				task.delay(1.183, function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 1.5, nil, nil, false, false, true, true, false, nil, nil)
				end)

				task.delay(1.45, function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 1.5, nil, nil, false, false, true, true, false, nil, nil)
				end)

				task.delay(0.717, function()
					if EnemyCharacter:HasTag('Ragdolled') then
						RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
					end

					AnimationService:stopAll(EnemyCharacter)
					AnimationService:playAnimation(EnemyCharacter, VictimAnimation, 1, 0.72)

					Weld:Start(nil, EnemyPlayer, Player)
				end)

				task.delay(2.583, function()
					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					StunHandler:Unstun(Character, Stun)
					RagdollHandler.ragdoll(EnemyHumanoid, 2.5)

					local groundRay = workspace:Raycast(HumRP.CFrame.Position, Vector3.new(-0, -15, -0), MapRayParams)
					if groundRay then
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 7.5, nil, nil, false, false, true, true, true, nil, nil)

						knockbackService.Knockback(EnemyCharacter.PrimaryPart, {
							["duration"] = 0.2,
							["force"] = 30,
							["direction"] = -HumRP.CFrame.LookVector + Vector3.new(0, 0.9, 0)
						})


						local Hitbox = HitboxHandler.new()
						Hitbox.Instance = CFrame.new(groundRay.Position)
						Hitbox.Size = Vector3.new(25, 25, 25)
						Hitbox.Ignore = { Character }
						Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(25, 25, 25) + Vector3.new(0, 25, 0) }
						Hitbox.onTouch = function(EnemyCharacter2)
							local EnemyHumanoid2: Humanoid = EnemyCharacter2.Humanoid

							if iFramesService:HasiFrame(EnemyCharacter2, Tool.Name) or EnemyHumanoid2.Health <= 0 or EnemyHumanoid2:GetState() == Enum.HumanoidStateType.Dead then return end


							DamageHandler:TakeDamage(Character, EnemyHumanoid2, 9, 2, nil, false, false, true, true, true, nil, nil)
							RagdollHandler.ragdoll(EnemyHumanoid2, 2)
							local knockbackInfo = {
								["duration"] = 0.2,
								["force"] = 20,
								["direction"] = CFrame.new(groundRay.Position, EnemyCharacter2.PrimaryPart.Position).LookVector + Vector3.new(0, 1.7, 0)
							}

							knockbackService.Knockback(EnemyCharacter2.PrimaryPart, knockbackInfo)
						end

						Hitbox:Once()
						Hitbox:Destroy()
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
					for _,v in UserEvents do
						v:Disconnect()
					end

					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end

					StunHandler:Unstun(Character, Stun)
					Character:RemoveTag('CantRotate')
					iFramesService:RemoveAlliFrames(Character)
					CollisionsModule:SetCollisionGroup(Character, "Players")

					Janitor:Destroy()
				end)


				AnimationService:stopAll(Character)
				AnimationService:playAnimation(Character, UserAnimation)


				ReplicateEffects_Set:FireAllClients("LightningDive", { Char = Character, Stage = "pa", victim = EnemyCharacter, Animation = UserAnimation.AnimationId })
			end
		end
		
		
		task.delay(0.9, function()
			local CF = HumRP.CFrame
			if not CF then return end
			
			
			local rayResult = workspace:Raycast((CF * CFrame.new(0, 0, -5)).Position, Vector3.new(-0, -25, -0), MapRayParams)
			if rayResult then
				local groundPos = rayResult.Position + Vector3.new(0, 5, 0)
				
				ReplicateEffects_Set:FireAllClients("LightningDive", { Char = Character, Stage = "slam", grnd_pos = groundPos, cf = CFrame.new(groundPos, groundPos + rayResult.Normal) * CFrame.Angles(math.pi, 0, 0) })
				
				
				local Hitbox = HitboxHandler.new()
				Hitbox.Instance = CFrame.new(rayResult.Position, rayResult.Position + CF.LookVector)
				Hitbox.Size = Vector3.new(21.5, 21.5, 21.5)
				Hitbox.Ignore = { Character }
				Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(21.5, 21.5, 21.5) + Vector3.new(0, 25, 0) }
				Hitbox.onTouch = function(EnemyCharacter)
					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
					
					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, true, false, true, true, false, nil, nil)
					
					if HitInfo.Blocked == true then
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, false, false, true, true, true, nil, nil)
						
						local forceValue = math.random(35, 45)
						local offsetX = math.random(-10, 10) / 100
						local offsetZ = math.random(-10, 10) / 100

						local knockbackInfo = {
							["duration"] = 0.3,
							["force"] = forceValue,
							["direction"] = Vector3.new(0, 1, 0) + Vector3.new(offsetX, 0, offsetZ)
						}

						knockbackService.Knockback(EnemyCharacter.PrimaryPart, knockbackInfo)
					else
						if Hit == true then return end
						Hit = true
						
						if not EnemyCharacter:HasTag('Ragdolled') then
							RagdollHandler.ragdoll(EnemyHumanoid, 1.85)
						end
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, 1.85, nil, false, false, true, true, false, nil, nil)
						
						hitFunction(EnemyCharacter)
					end
				end
				
				Hitbox:Once()
				Hitbox:Destroy()
			end
		end)
		
		
		StartTrack.Stopped:Once(function()
			for _,v in StartEvents do
				v:Disconnect()
			end
			
			if not Hit then
				StunHandler:Unstun(Character, Stun)
				Janitor:Destroy()
				currentMutatedArm:Destroy()
			end
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
		
		
		ReplicateEffects_Set:FireAllClients("LightningDive", { Char = Character, Stage = "psa", Animation = StartAnimation.AnimationId })
	end
}