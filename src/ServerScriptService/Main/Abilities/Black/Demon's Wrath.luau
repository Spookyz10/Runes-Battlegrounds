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


		local StartAnimation = MoveAnims.Black["Demon's Wrath"].Startup
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}
		
		
		local Hit = false
		
		
		local function VariantHit(EnemyCharacter: Model)
			local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			
			
			local VictimAnimation = MoveAnims.Black["Demon's Wrath"].Variant.HitVictim
			local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)

			local UserAnimation = MoveAnims.Black["Demon's Wrath"].Variant.HitMain
			local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
			local UserEvents = {}


			local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, 3.141592653589793, 0), -1)


			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
			
			
			EnemyCharacter:AddTag('CantRotate')
			iFramesService:AddAlliFrames(Character)
			iFramesService:AddAlliFrames(EnemyCharacter)
			CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
			
			
			for _, child in Character:GetChildren() do
				if child.Name == "WingsModel" and child:IsA("Model") then
					child:Destroy()
				end
			end
			
			local wingsClone = Models.Black.WingsModel:Clone()
			Debris:AddItem(wingsClone, 2.67)
			wingsClone.Parent = Character
			wingsClone:PivotTo(Character.Torso.CFrame)

			local wings = wingsClone.Wings.Wings
			Debris:AddItem(wings, 2.67)
			wings.Parent = HumRP
			wings.Part0 = Character.Torso
			
			
			task.delay(2, function()
				local rayResult = workspace:Raycast(HumRP.CFrame.Position, Vector3.new(-0, -9999, -0), MapRayParams)
				if rayResult then
					local newPos = rayResult.Position + Vector3.new(0, 2.4, 0)
					TweenService:Create(HumRP, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
						["CFrame"] = CFrame.new(newPos, newPos + HumRP.CFrame.LookVector * Vector3.new(1, 0, 1))
					}):Play()
					

					task.delay(0.3, function()
						ReplicateEffects_Set:FireAllClients("DemonsWrath", { Char = Character, Stage = "v_slam", ground_check = { ["position"] = rayResult.Position + Vector3.new(0, 0.5, 0), ["normal"] = rayResult.Normal }})
					end)
					
					task.wait(0.4)
					
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 12.8, 2, nil, false, false, true, true, false, nil)
					RagdollHandler.ragdoll(EnemyHumanoid, 2)
					knockbackService.Knockback(EnemyCharacter.PrimaryPart, {
						["duration"] = 0.2,
						["force"] = 50,
						["direction"] = Vector3.new(0, 1, 0)
					})
				else
					return
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
				iFramesService:RemoveAlliFrames(Character)
				CollisionsModule:SetCollisionGroup(Character, "Players")

				Janitor:Destroy()
			end)


			AnimationService:stopAll(Character)
			AnimationService:stopAll(EnemyCharacter)
			AnimationService:playAnimation(Character, UserAnimation)
			AnimationService:playAnimation(EnemyCharacter, VictimAnimation)


			Weld:Start(nil, EnemyPlayer, Player)
			
			
			ReplicateEffects_Set:FireAllClients("DemonsWrath", { Char = Character, victim = EnemyCharacter, Stage = "pva", VariantHitAnimation = UserAnimation.AnimationId })
		end
		
		local function RegularHit(EnemyCharacter: Model)
			local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			
			if Humanoid.Jump == true then
				VariantHit(EnemyCharacter)
				
				return
			end
			
			
			local VictimAnimation = MoveAnims.Black["Demon's Wrath"].HitVictim
			local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
			
			local UserAnimation = MoveAnims.Black["Demon's Wrath"].HitMain
			local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
			local UserEvents = {}
			
			
			local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -2) * CFrame.Angles(0, 3.141592653589793, 0), -1)
			
			
			Stun:SetAttribute("WalkSpeed", 3)
			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
			
			
			EnemyCharacter:AddTag('CantRotate')
			iFramesService:AddAlliFrames(Character)
			iFramesService:AddAlliFrames(EnemyCharacter)
			CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
			
			
			for _, child in Character:GetChildren() do
				if child.Name == "WingsModel" and child:IsA("Model") then
					child:Destroy()
				end
			end
			
			
			local wingsClone = Models.Black.WingsModel:Clone()
			Debris:AddItem(wingsClone, 2.67)
			wingsClone.Parent = Character
			wingsClone:PivotTo(Character.Torso.CFrame)
			
			local wings = wingsClone.Wings.Wings
			Debris:AddItem(wings, 2.67)
			wings.Parent = HumRP
			wings.Part0 = Character.Torso
			
			
			task.delay(1.3, function()
				if EnemyCharacter and (EnemyCharacter:IsDescendantOf(workspace) and EnemyCharacter.PrimaryPart) then
					AnimationService:stopAll(EnemyCharacter, 0.1)
					RagdollHandler.ragdoll(EnemyHumanoid, 2)
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 6.7, 2, nil, false, false, true, true, true, nil)
					
					knockbackService.Knockback(EnemyCharacter.PrimaryPart, {
						["duration"] = 0.3,
						["force"] = 40,
						["direction"] = HumRP.CFrame.LookVector
					})
				end
			end)
			
			
			UserEvents["slam"] = Janitor:Add(UserTrack:GetMarkerReachedSignal("slam"):Connect(function()
				if EnemyCharacter and (EnemyCharacter:IsDescendantOf(workspace) and EnemyCharacter.PrimaryPart) then
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, nil, nil, false, false, true, true, false, nil)
				end
			end))
			
			UserEvents["drag"] = Janitor:Add(UserTrack:GetMarkerReachedSignal("drag"):Connect(function()
				
			end))
			
			UserEvents["shoot"] = Janitor:Add(UserTrack:GetMarkerReachedSignal("shoot"):Connect(function()
				local verticalOffset = -1.4
				local shootEffect = ReplicatedStorage.Resources.Black.VFX.Base["Demon's Wrath"].ShootImp:Clone()
				Debris:AddItem(shootEffect, 5)
				shootEffect.CFrame = HumRP.CFrame
				shootEffect.Parent = workspace.Thrown
				
				task.delay(0.02, function()
					for _, particle in shootEffect:GetDescendants() do
						if particle.Parent.Name ~= "Impact2" then
							VfxUtility.emit_effect(particle)
						end
					end
				end)
				
				SoundsModule:PlaySound(ReplicatedStorage.Resources.Black.SFX.Base["Demon's Wrath"].lasershoot, shootEffect)
				
				ReplicateEffects_Set:FireAllClients("DemonsWrath", { Char = Character, Stage = "ShootImp", adornee = shootEffect })
				
				TweenService:Create(shootEffect.Impact2.PointLight, TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
					["Range"] = 0
				}):Play()
				
				
				local shootCFrame = nil
				local shootGroundCFrame = nil
				local ragdollTable = {}
				local shootConn
				
				
				shootConn = RunService.Heartbeat:Connect(function(dt)
					local offsetY = verticalOffset
					local interp = 9 * dt
					verticalOffset = offsetY + (-0.05 - offsetY) * interp
					local headPos = Character.Head.Position
					local lookX = HumRP.CFrame.LookVector.X
					local lookY = verticalOffset
					local lookZ = HumRP.CFrame.LookVector.Z
					local lookVec = Vector3.new(lookX, lookY, lookZ)
					local rayResult = workspace:Raycast(headPos, lookVec * 150, MapRayParams)
					local impactPos
					
					if rayResult then
						impactPos = rayResult.Position
					else
						impactPos = (CFrame.new(headPos, headPos + lookVec) * CFrame.new(0, 0, -150)).Position
					end
					
					shootEffect.CFrame = CFrame.new(impactPos, headPos) * CFrame.Angles(0, -1.5707963267948966, 0)
					shootEffect.B.WorldPosition = headPos
					shootCFrame = shootEffect.CFrame

					if rayResult then
						local groundCF = CFrame.new(impactPos, impactPos + rayResult.Normal) * CFrame.Angles(1.5707963267948966, 0, 0)
						shootEffect.Grnd.WorldCFrame = groundCF
						shootEffect.Impact2.WorldCFrame = groundCF
						shootGroundCFrame = groundCF
						if math.random(1, 2) == 1 then
							for _, emitter in shootEffect.Impact2:GetChildren() do
								if emitter:IsA("ParticleEmitter") then
									emitter:Emit(1)
								end
							end
						end
					end

					for humanoidModel, _ in ragdollTable do
						if humanoidModel:IsDescendantOf(workspace) and (humanoidModel.PrimaryPart and not humanoidModel.Humanoid:GetAttribute("Idle")) then
							local modelPart = humanoidModel.PrimaryPart
							modelPart.AssemblyLinearVelocity = modelPart.AssemblyLinearVelocity * 0
							humanoidModel.PrimaryPart.CFrame = CFrame.new(impactPos + Vector3.new(0, 2.4, 0))
							humanoidModel.IsRagdoll.Value = false
						else
							ragdollTable[humanoidModel] = nil
						end
					end
				end)
				
				
				task.delay(0.45, function()
					if shootConn then
						shootConn:Disconnect()
						shootConn = nil
					end

					table.clear(ragdollTable)
					ragdollTable = nil
					
					if shootCFrame and shootGroundCFrame then
						local finalShoot = ReplicatedStorage.Resources.Black.VFX.Base["Demon's Wrath"].ShootImpFinal:Clone()
						Debris:AddItem(finalShoot, 5)
						finalShoot.CFrame = shootCFrame
						finalShoot.Grnd.WorldCFrame = shootGroundCFrame
						finalShoot.Impact.WorldCFrame = shootGroundCFrame
						finalShoot.Parent = workspace.Thrown

						task.delay(0.02, function()
							local normalVec = (shootGroundCFrame * CFrame.Angles(-1.5707963267948966, 0, 0)).LookVector
							for _, emitter in finalShoot:GetDescendants() do
								if emitter:IsA("ParticleEmitter") and (emitter.Name ~= "Crack" or normalVec.Y >= 0.9) then
									VfxUtility.emit_effect(emitter)
								end
							end
						end)

						local grndEffect = finalShoot.Grnd
						grndEffect.WorldPosition = grndEffect.WorldPosition + Vector3.new(0, 0.1, 0)
						local impactEffect = finalShoot.Impact
						impactEffect.WorldPosition = impactEffect.WorldPosition + Vector3.new(0, 0.1, 0)
						
						SoundsModule:PlaySound(ReplicatedStorage.Resources.Black.SFX.Base["Demon's Wrath"].lastexplosion, finalShoot)
						
						ReplicateEffects_Set:FireAllClients("DemonsWrath", { Char = Character, Stage = "ShootImpFinal", cf = shootCFrame, cf2 = shootGroundCFrame })
						
						
						local Hitbox = HitboxHandler.new()
						Hitbox.Instance = shootGroundCFrame
						Hitbox.Size = Vector3.new(30, 30, 30)
						Hitbox.Ignore = { Character }
						Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(30, 30, 30) + Vector3.new(0, 25, 0) }
						Hitbox.onTouch = function(ShootEnemyCharacter: Model)
							local ShootEnemyHumRP: BasePart = ShootEnemyCharacter.HumanoidRootPart
							local ShootEnemyHumanoid: Humanoid = ShootEnemyCharacter.Humanoid
							
							if iFramesService:HasiFrame(ShootEnemyCharacter, Tool.Name) or ShootEnemyHumanoid.Health <= 0 or ShootEnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
							
							local ShootStun = StunHandler:Stun(ShootEnemyCharacter, 2, true, 0, 0, true)
							
							
							DamageHandler:TakeDamage(Character, ShootEnemyHumanoid, 7.9, nil, nil, false, false, true, true, true, nil)
							RagdollHandler.ragdoll(ShootEnemyHumanoid, 2)
							
							local knockParams = {
								["duration"] = 0.2,
								["force"] = 20,
								["direction"] = CFrame.new(shootGroundCFrame.Position, ShootEnemyHumanoid.PrimaryPart.Position).LookVector + Vector3.new(0, 1.7, 0)
							}

							knockbackService.Knockback(ShootEnemyHumanoid.PrimaryPart, knockParams)
						end
						
						Hitbox:Once()
						Hitbox:Destroy()
					end
				end)
				
				local Hitbox = ReplicatedHitbox.new(Player)
				Hitbox.Instance = shootEffect
				Hitbox.Size = Vector3.new(10, 10, 10)
				Hitbox.Offset = CFrame.new(0, 0, 0)
				Hitbox.Ignore = { Character }
				Hitbox.onTouch = function(ShootEnemyCharacter: Model)
					local ShootEnemyHumRP: BasePart = ShootEnemyCharacter.HumanoidRootPart
					local ShootEnemyHumanoid: Humanoid = ShootEnemyCharacter.Humanoid

					if iFramesService:HasiFrame(ShootEnemyCharacter, Tool.Name) or ShootEnemyHumanoid.Health <= 0 or ShootEnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
					
					local Hits = {}
					if not table.find(Hits, ShootEnemyCharacter) then
						table.insert(Hits, ShootEnemyCharacter)
					end
					
					for _, v in Hits do
						if not ragdollTable[v] then
							ragdollTable[v] = true
							

							for _, velocityObj in v.PrimaryPart:GetDescendants() do
								if velocityObj:IsA("LinearVelocity") then
									velocityObj:Destroy()
								end
							end

							local ShootStun = StunHandler:Stun(v, 0.8, true, 0, 0, true)
						end
					end
				end
				
				Hitbox:Start(0.45)
			end))
			
			
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
				iFramesService:RemoveAlliFrames(Character)
				CollisionsModule:SetCollisionGroup(Character, "Players")
				
				Janitor:Destroy()
			end)
			
			
			AnimationService:stopAll(Character)
			AnimationService:stopAll(EnemyCharacter)
			AnimationService:playAnimation(Character, UserAnimation)
			AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
			
			
			Weld:Start(nil, EnemyPlayer, Player)
			
			
			ReplicateEffects_Set:FireAllClients("DemonsWrath", { Char = Character, Victim = EnemyCharacter, Stage = "pa", HitAnimation = UserAnimation.AnimationId })
		end
		
		
		StartEvents["open"] = Janitor:Add(StartTrack:GetMarkerReachedSignal("open"):Connect(function()
			local wingsClone = Models.Black.WingsModel:Clone()
			Debris:AddItem(wingsClone, StartTrack.Length - StartTrack.TimePosition)
			wingsClone.Parent = Character
			wingsClone:PivotTo(Character.Torso.CFrame)
			
			local wings = wingsClone.Wings.Wings
			Debris:AddItem(wings, StartTrack.Length - StartTrack.TimePosition)
			wings.Parent = HumRP
			wings.Part0 = Character.Torso
		end))
		
		StartEvents["fly"] = Janitor:Add(StartTrack:GetMarkerReachedSignal("fly"):Connect(function()
			local Hitbox = ReplicatedHitbox.new(Player)
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(7, 7, 13)
			Hitbox.Offset = CFrame.new(0, 0, -3)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter: Model)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				
				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead or EnemyCharacter:HasTag('Ragdolled') then return end
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 0.1, nil, nil, true, false, true, true, false, nil)
				if HitInfo.Blocked == true or HitInfo.Countered == true then return end
				Hit = true
				
				
				RegularHit(EnemyCharacter)
			end
			
			Hitbox:Start(0.3)
		end))
		
		
		StartTrack.Stopped:Once(function()
			for _,v in StartEvents do
				v:Disconnect()
			end

			if not Hit then
				StunHandler:Unstun(Character, Stun)
				
				Janitor:Destroy()
			end
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
		
		ReplicateEffects_Set:FireAllClients("DemonsWrath", { Char = Character, Stage = "psa", Animation = StartAnimation.AnimationId })
	end
}