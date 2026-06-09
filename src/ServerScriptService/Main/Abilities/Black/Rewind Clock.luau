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
		iFramesService:AddAlliFrames(Character)
		
		
		local Hit = false
		
		
		local StartAnimation = MoveAnims.Black["Rewind Clock"].Startup
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}
		
		
		local function HitFunction(EnemyCharacter: Model)
			local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			
			
			if EnemyCharacter:HasTag('Ragdolled') then
				RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
			end
			
			
			local rewindClock = Models.Black.RewindClock:Clone()
			Debris:AddItem(rewindClock, 3.6)
			rewindClock.Base.CFrame = HumRP.CFrame
			rewindClock.Base.BaseJoint.Part0 = HumRP
			rewindClock.Parent = Character
			rewindClock.Base.Transparency = 1
			rewindClock.Pointer.Transparency = 1
			
			task.delay(1.95, function()
				for _, part in rewindClock:GetChildren() do
					if part:IsA("BasePart") then
						local originalSize = part.Size
						part.Size = Vector3.new(0, 0, 0)
						TweenService:Create(part, TweenInfo.new(0.105), { Size = originalSize }):Play()
					end
				end
				
				rewindClock.Base.Transparency = 0
				rewindClock.Pointer.Transparency = 0
			end)
			
			
			local UserAnimation = MoveAnims.Black["Rewind Clock"].Main
			local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
			local UserEvents = {}

			local VictimAnimation = MoveAnims.Black["Rewind Clock"].Victim
			local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
			
			
			local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), -1)
			local SecondWeld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), -1)
			task.delay(1.3, function()
				if Weld then
					pcall(function()
						Weld:Stop()
					end)
					Weld = nil
				end
			end)
			
			
			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
			
			
			Character:AddTag('CantRotate')
			EnemyCharacter:AddTag('CantRotate')
			
			iFramesService:AddAlliFrames(Character)
			iFramesService:AddAlliFrames(EnemyCharacter)

			CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
			
			
			DamageHandler:TakeDamage(Character, EnemyHumanoid, 13.8, nil, nil, false, false, true, false, false, nil, nil)
			task.delay(1.31, function()
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 30.8, nil, nil, false, false, true, false, false, nil, nil)
				EnemyHumRP.Anchored = true
			end)
			
			task.delay(6.52, function()
				EnemyHumRP.Anchored = false
				SecondWeld:Start(nil, EnemyPlayer, Player)
			end)
			
			task.delay(7.95, function()
				if Weld then 
					pcall(function()
						Weld:Stop()
					end)
					Weld = nil 
				end
				if SecondWeld then
					pcall(function()
						SecondWeld:Stop()
					end)
					SecondWeld = nil 
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
				if SecondWeld then 
					pcall(function()
						SecondWeld:Stop()
					end)
					SecondWeld = nil
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
				if SecondWeld then 
					pcall(function()
						SecondWeld:Stop()
					end)
					SecondWeld = nil
				end

				StunHandler:Unstun(Character, Stun)
				Character:RemoveTag('CantRotate')
				iFramesService:RemoveAlliFrames(Character)
				CollisionsModule:SetCollisionGroup(Character, "Players")

				Janitor:Destroy()
			end)


			AnimationService:stopAll(Character)
			AnimationService:stopAll(EnemyCharacter)
			AnimationService:playAnimation(Character, UserAnimation)
			AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
			
			
			Weld:Start(nil, EnemyPlayer, Player)
			
			
			ReplicateEffects_Set:FireAllClients("RewindClock", { Char = Character, Stage = "pa", victim = EnemyCharacter, Animation = UserAnimation.AnimationId })
		end
		
		
		StartEvents["slam"] = Janitor:Add(StartTrack:GetMarkerReachedSignal("slam"):Connect(function(val)
			if val == "1" then
				local Hitbox = HitboxHandler.new()
				Hitbox.Instance = CFrame.new(HumRP.CFrame.Position)
				Hitbox.Size = Vector3.new(65, 65, 65)
				Hitbox.Ignore = { Character }
				Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(65, 65, 65) + Vector3.new(0, 25, 0) }
				Hitbox.onTouch = function(EnemyCharacter)
					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end

					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, true, false, true, true, false, nil, nil)

					if HitInfo.Blocked == false then
						RagdollHandler.ragdoll(EnemyHumanoid, 2)
					end
					
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 11, nil, nil, false, false, true, true, true, nil, nil)
					local Force = (EnemyCharacter.PrimaryPart.Position - HumRP.CFrame.Position).Magnitude / 1.5
					local Dir = CFrame.new(EnemyCharacter.PrimaryPart.Position, HumRP.CFrame.Position).LookVector + Vector3.new(0, 40, 0)
					local KnockbackParams = {
						["duration"] = 0.15,
						["force"] = Vector3.new(Force, 1, Force),
						["direction"] = Dir
					}
					knockbackService.Knockback(EnemyCharacter.PrimaryPart, KnockbackParams)
				end
				
				Hitbox:Once()
				Hitbox:Destroy()
				
			elseif val == "2" then
				local Hitbox = HitboxHandler.new()
				Hitbox.Instance = CFrame.new(HumRP.CFrame.Position)
				Hitbox.Size = Vector3.new(35, 35, 35)
				Hitbox.Ignore = { Character }
				Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(35, 35, 35) + Vector3.new(0, 25, 0) }
				Hitbox.onTouch = function(EnemyCharacter)
					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
					
					if Hit == true then
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 8, 2, nil, false, false, true, true, true, nil, nil)
						RagdollHandler.ragdoll(EnemyHumanoid, 2)
						local KnockbackParams = {
							["duration"] = 0.2,
							["force"] = 30,
							["direction"] = CFrame.new(HumRP.CFrame.Position, EnemyCharacter.PrimaryPart.Position).LookVector + Vector3.new(0, 1.7, 0)
						}
						knockbackService.Knockback(EnemyCharacter.PrimaryPart, KnockbackParams)
					else
						if Hit == true then return end
						Hit = true
						HitFunction(EnemyCharacter)
					end
				end

				Hitbox:Once()
				Hitbox:Destroy()
			end
		end))
		
		
		
		
		StartTrack.Stopped:Once(function()
			for _,v in StartEvents do
				v:Disconnect()
			end

			if not Hit then
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
				Janitor:Destroy()
			end
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
		
		
		ReplicateEffects_Set:FireAllClients("RewindClock", { Char = Character, Stage = "psa", Animation = StartAnimation.AnimationId })
	end
}