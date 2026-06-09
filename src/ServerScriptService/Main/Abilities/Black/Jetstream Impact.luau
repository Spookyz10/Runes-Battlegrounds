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
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddBaseiFrames(Character)
		
		
		local StartAnimation = MoveAnims.Black["Jetstream Impact"].Startup
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		
		
		local ToolName = Tool.Name
		local Hit = false
		
		
		local function HitFunction(EnemyCharacter: Model)
			local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			
			
			local startTick = tick()
			local RewindClockCombine = false
			
			
			if EnemyCharacter:HasTag('Ragdolled') then
				RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
			end
			
			
			local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), -1)
			
			
			local UserAnimation = MoveAnims.Black["Jetstream Impact"].Main
			local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)

			local VictimAnimation = MoveAnims.Black["Jetstream Impact"].Victim
			local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
			
			
			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
			
			
			Character:AddTag('CantRotate')
			EnemyCharacter:AddTag('CantRotate')
			
			iFramesService:AddAlliFrames(Character)
			iFramesService:AddAlliFrames(EnemyCharacter)
			
			CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
			
			
			task.delay(1.86, function()
				Character:SetAttribute("Invisible", true)

				task.delay(0.29, function()
					Character:SetAttribute("Invisible", false)
				end)
			end)

			task.delay(2.65, function()
				Character:SetAttribute("Invisible", true)

				task.delay(0.2, function()
					Character:SetAttribute("Invisible", false)
				end)
			end)

			task.delay(4.9, function()
				Character:SetAttribute("Invisible", true)

				task.delay(0.5, function()
					Character:SetAttribute("Invisible", false)
				end)
			end)
			
			
			local function dealDamage(damageAmount)
				if EnemyCharacter and (EnemyCharacter:IsDescendantOf(workspace) and EnemyCharacter.PrimaryPart) then
					DamageHandler:TakeDamage(Character, EnemyHumanoid, damageAmount, nil, nil, false, false, true, false, false, nil, nil)
				end
			end

			if EnemyCharacter and (EnemyCharacter:IsDescendantOf(workspace) and EnemyCharacter.PrimaryPart) then
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 2.5, nil, nil, false, false, true, false, false, nil, nil)
			end
			
			
			task.delay(0.983, dealDamage, 3)
			task.delay(1.58, dealDamage, 2)
			task.delay(3.15, dealDamage, 1.5)
			task.delay(3.15, dealDamage, 2)
			task.delay(3.567, dealDamage, 1.2)
			task.delay(3.833, dealDamage, 1.2)
			task.delay(3.833, dealDamage, 1.2)
			task.delay(4.91, dealDamage, 3)
			task.delay(5.833, dealDamage, 2)
			task.delay(5.833, dealDamage, 2)
			task.delay(6.833, dealDamage, 9)
			
			
			task.delay(6.817, function()
				if not (EnemyCharacter and (EnemyCharacter:IsDescendantOf(workspace) and EnemyCharacter.PrimaryPart)) then
					return
				end
				
				
				local hrpCFrame = HumRP.CFrame
				local knockCount = 3
				
				
				local function knockCycle()
					knockCount -= 1
					if knockCount ~= 0 then
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
						
						StunHandler:Stun(EnemyCharacter, 2.5, true, 0, 0, true)
						RagdollHandler.ragdoll(EnemyHumanoid, 2.5)
						
						knockbackService.Knockback(EnemyCharacter.PrimaryPart, {
							["duration"] = 0.32,
							["force"] = 83,
							["direction"] = hrpCFrame.LookVector + Vector3.new(0, 0.39, 0)
						})
					end
				end
				knockCycle()
				
				
				task.delay(0.5, function()
					local stunDuration = 7.7 - (tick() - startTick)
					StunHandler:RemoveAllStuns(Character, true)
					StunHandler:Stun(Character, math.max(stunDuration, 0), true, 0, 0, true)
					iFramesService:AddAlliFrames(Character)
					
					task.spawn(function()
						ComSet:FireClient(Player, 'ModifyHotbar', { ToolName = 'Rewind Clock', Property = 'Description', Value = 'ACTIVATE', Time = math.max(stunDuration, 0) })
						
						Character:SetAttribute('RewindClockCombine', true)
						
						local Changed = Character:GetAttributeChangedSignal("RewindClockCombine"):Once(function()
							if iFramesService:HasiFrame(EnemyCharacter, ToolName) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
							
							RewindClockCombine = true

							ComSet:FireClient(Player, 'ModifyHotbar', { ToolName = 'Rewind Clock', Property = 'Description', Value = "" })
							
							
							if EnemyCharacter:HasTag('Ragdolled') then
								RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
							end
							
							workspace:GetServerTimeNow()

							local rewindClock = Models.Black.RewindClock:Clone()
							Debris:AddItem(rewindClock, 1.75)
							rewindClock.Base.CFrame = HumRP.CFrame
							rewindClock.Base.BaseJoint.Part0 = HumRP
							rewindClock.Parent = Character
							rewindClock.Base.Transparency = 1
							rewindClock.Pointer.Transparency = 1

							task.delay(0.1, function()
								for _, part in rewindClock:GetChildren() do
									if part:IsA("BasePart") then
										local partSize = part.Size
										part.Size = Vector3.new(0, 0, 0)
										TweenService:Create(part, TweenInfo.new(0.105), {
											Size = partSize
										}):Play()
									end
								end

								rewindClock.Base.Transparency = 0
								rewindClock.Pointer.Transparency = 0
							end)


							local UserAnimation = MoveAnims.Black["Rewind Clock"].Main
							local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)

							local VictimAnimation = MoveAnims.Black["Rewind Clock"].Victim
							local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)


							local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), -1)
							

							local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
							local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)


							Character:AddTag('CantRotate')
							EnemyCharacter:AddTag('CantRotate')

							iFramesService:AddAlliFrames(Character)
							iFramesService:AddAlliFrames(EnemyCharacter)

							CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
							CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")


							task.delay(1.85, function()
								Character:AddTag('CantRotate')
								EnemyCharacter:AddTag('CantRotate')
								
								EnemyHumRP.Anchored = true
								
								AnimationService:stopAll(EnemyCharacter)
								AnimationService:playAnimation(EnemyCharacter, VictimAnimation, 1, 3.7)
								
								pcall(function()
									for _, obj in EnemyHumRP:GetDescendants() do
										if obj:IsA("LinearVelocity") then
											obj:Destroy()
										end
									end
								end)

								TweenService:Create(EnemyHumRP, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
									CFrame = HumRP.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0)
								}):Play()

								task.wait(0.5)

								EnemyHumRP.Anchored = false
								
								Weld:Start(nil, EnemyPlayer, Player)
							end)
							
							task.delay(6.1, function()
								if EnemyCharacter and EnemyCharacter.PrimaryPart and EnemyCharacter:IsDescendantOf(workspace) then
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
									
									DamageHandler:TakeDamage(Character, EnemyHumanoid, 75, 2.5, nil, false, false, true, false, true, nil, nil)
									RagdollHandler.ragdoll(EnemyHumanoid, 2.5, true, Character)
									knockbackService.Knockback(EnemyCharacter.PrimaryPart, {
										duration = 0.5,
										force = 300,
										direction = HumRP.CFrame.LookVector + Vector3.new(0, 0.3, 0)
									})
								end
								
								local DestroyerHitbox = HitboxHandler.new()
								DestroyerHitbox.Instance = CFrame.new(HumRP.CFrame.Position)
								DestroyerHitbox.Size = Vector3.new(65, 65, 65)
								DestroyerHitbox.Ignore = { Character }
								DestroyerHitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(65, 65, 65) + Vector3.new(0, 25, 0) }

								DestroyerHitbox:Once()
								DestroyerHitbox:Destroy()
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
							end)


							AnimationService:stopAll(Character)
							AnimationService:playAnimation(Character, UserAnimation, 1, 1.85)
							
							ReplicateEffects_Set:FireAllClients("RewindClock", { Char = Character, Stage = "pa", victim = EnemyCharacter, Animation = UserAnimation.AnimationId, combinedWith = true })
						end)
						
						task.delay(math.max(stunDuration, 0), function()
							if RewindClockCombine == true then return end
							Changed:Disconnect()
							
							Character:SetAttribute('RewindClockCombine', nil)
							ComSet:FireClient(Player, 'ModifyHotbar', { ToolName = 'Rewind Clock', Property = 'Description', Value = "" })
						end)
					end)
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
			end)
			
			
			AnimationService:stopAll(Character, 0.1)
			AnimationService:stopAll(EnemyCharacter)
			AnimationService:playAnimation(Character, UserAnimation)
			AnimationService:playAnimation(EnemyCharacter, VictimAnimation)


			Weld:Start(nil, EnemyPlayer, Player)
			
			
			ReplicateEffects_Set:FireAllClients("JetstreamImpact", { Char = Character, Stage = "pa", victim = EnemyCharacter, Animation = UserAnimation.AnimationId })
		end
		
		
		task.delay(0.7, function()
			if StartTrack.IsPlaying == false then return end
			iFramesService:AddAlliFrames(Character)
			
			
			local Hitbox = ReplicatedHitbox.new(Player)
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(7, 7, 16)
			Hitbox.Ignore = { Character }
			Hitbox.Offset = CFrame.new(0, 0, -6)
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, ToolName) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 6, nil, nil, false, false, true, false, false, nil, nil)
				Hit = true
				HitFunction(EnemyCharacter)
			end
			
			Hitbox:Start(0.7)
			
			--task.delay(0.7, function()
				--ReplicateEffects_Set:FireAllClients('RemoveAllBodyMovers', Character)
			--end)
		end)
		
		
		StartTrack.Stopped:Once(function()
			if not Hit then
				StunHandler:Unstun(Character, Stun)
				
				iFramesService:RemoveAlliFrames(Character)
			end
		end)


		AnimationService:stopAll(Character, 0.3)
		AnimationService:playAnimation(Character, StartAnimation)
		
		
		ReplicateEffects_Set:FireAllClients("JetstreamImpact", { Char = Character, Stage = "psa", Animation = StartAnimation.AnimationId })
	end
}