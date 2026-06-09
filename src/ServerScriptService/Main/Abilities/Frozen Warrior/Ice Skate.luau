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
local Clock = services:GetService("Clock")


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
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 4, 0, true)
		
		
		local StartAnimation = MoveAnims["Frozen Warrior"]["Ice Skate"].Startup
		local StartTrack, StartEvents = AnimationService:getAnimationTrack(Character, StartAnimation)
		
		
		local DelayFunction = task.delay
		local DelayTime = 0.8 - Clock.get(workspace:GetServerTimeNow())
		
		
		local Hit = false
		
		
		local function HitFunction(EnemyCharacter: Model)
			if Hit == true or StartTrack.IsPlaying == false then return end
			Hit = true
			
			
			local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			
			
			if EnemyCharacter:HasTag('Ragdolled') then
				RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
			end
			
			
			local IceSpear = Models.Frozen.IceSpear:Clone()
			Debris:AddItem(IceSpear, 3.3)
			IceSpear:PivotTo(HumRP.CFrame)
			IceSpear.rootPart.Bone.Part0 = Character["Right Arm"]
			IceSpear.Parent = Character
			IceSpear:ScaleTo(0.01)
			IceSpear.Mesh.Transparency = 1


			task.delay(1.35, function()
				pcall(function()
					IceSpear.Mesh.Transparency = 0
					IceSpear:ScaleTo(0.01)

					for v36 = 1, 10 do
						IceSpear:ScaleTo(v36 / 10)
						task.wait(0.01)
					end
				end)
			end)


			task.delay(2.8, function()
				pcall(function()
					for v37 = 10, 1, -1 do
						IceSpear:ScaleTo(v37 / 10)
						task.wait(0.01)
					end

					IceSpear.Mesh.Transparency = 1
				end)
			end)
			
			
			
			local UserAnimation = MoveAnims["Frozen Warrior"]["Ice Skate"].Main
			local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

			local VictimAnimation = MoveAnims["Frozen Warrior"]["Ice Skate"].Victim
			local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
			
			
			Stun:SetAttribute("WalkSpeed", 0)
			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
			local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, 0) * CFrame.Angles(0, 3.141592653589793, 0), -1)
			
			
			EnemyCharacter:AddTag('CantRotate')
			
			iFramesService:AddAlliFrames(Character)
			iFramesService:AddAlliFrames(EnemyCharacter)
			
			CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
			
			
			task.delay(4.95, function()
				EnemyCharacter.PrimaryPart.CFrame = HumRP.CFrame * CFrame.new(0, 0, -5)
				
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

				DamageHandler:TakeDamage(Character, EnemyHumanoid, 5.5, nil, nil, false, false, true, true, true, nil, nil)
				knockbackService.Knockback(EnemyCharacter.PrimaryPart, { ["duration"] = 0.2, ["force"] = 32, ["direction"] = HumRP.CFrame.LookVector + Vector3.new(0, 0.3, 0) })
				RagdollHandler.ragdoll(EnemyHumanoid, 1.2)
			end)
			
			
			DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, false, false, true, true, false, nil, nil)
			
			
			local function AOEHitbox(HitboxSize)
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 1.05, nil, nil, false, false, true, true, false, nil, nil)

				local Size = HitboxSize * 0.3
				local Hitbox = HitboxHandler.new()
				Hitbox.Instance = CFrame.new((HumRP.CFrame * CFrame.new(0, 0, -4)).Position)
				Hitbox.Size = Vector3.new(1, 1, 1) * (math.max(Size, 1) * 17)
				Hitbox.Ignore = { Character, EnemyCharacter }
				Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(1, 1, 1) * (math.max(Size, 1) * 17) + Vector3.new(0, 25, 0) }
				Hitbox.onTouch = function(EnemyCharacter2)
					local EnemyHumanoid2: Humanoid = EnemyCharacter2.Humanoid

					if iFramesService:HasiFrame(EnemyCharacter2, Tool.Name) then return end

					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid2, 0.5, nil, nil, true, false, true, true, false, nil, nil)

					if not HitInfo.Blocked then
						RagdollHandler.ragdoll(EnemyHumanoid2, 2)
					end

					knockbackService.Knockback(EnemyCharacter2.PrimaryPart, {
						["duration"] = 0.2,
						["force"] = 24,
						["direction"] = Vector3.new(0, 1, 0)
					})
					DamageHandler:TakeDamage(Character, EnemyHumanoid2, 2, nil, nil, false, false, true, true, true, nil, nil)
				end

				Hitbox:Once()
				Hitbox:Destroy()
			end
			
			
			task.delay(1.8, function()
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 2.5, nil, nil, false, false, true, true, false, nil, nil)
				
				local Hitbox = HitboxHandler.new()
				Hitbox.Instance = CFrame.new((HumRP.CFrame * CFrame.new(0, 0, -4)).Position)
				Hitbox.Size = Vector3.new(25, 25, 25)
				Hitbox.Ignore = { Character, EnemyCharacter }
				Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(25, 25, 25) + Vector3.new(0, 25, 0) }
				Hitbox.onTouch = function(EnemyCharacter2)
					local EnemyHumanoid2: Humanoid = EnemyCharacter2.Humanoid

					if iFramesService:HasiFrame(EnemyCharacter2, Tool.Name) then return end
					
					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid2, 0.5, nil, nil, true, false, true, true, false, nil, nil)

					if not HitInfo.Blocked then
						RagdollHandler.ragdoll(EnemyHumanoid2, 2)
					end
					
					knockbackService.Knockback(EnemyCharacter2.PrimaryPart, {
						["duration"] = 0.2,
						["force"] = 8,
						["direction"] = Vector3.new(0, 1, 0)
					})
					DamageHandler:TakeDamage(Character, EnemyHumanoid2, 2, nil, nil, false, false, true, true, true, nil, nil)
				end
				
				Hitbox:Once()
				Hitbox:Destroy()
			end)
			
			task.delay(2.85, AOEHitbox, 1)
			task.delay(3.233, AOEHitbox, 2)
			task.delay(3.55, AOEHitbox, 3)
			task.delay(3.55, AOEHitbox, 4)
			task.delay(3.9, AOEHitbox, 5)
			task.delay(4.2, AOEHitbox, 6)
			task.delay(4.65, AOEHitbox, 7)
			
			
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
				
				Character:RemoveTag('CantRotate')
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
				CollisionsModule:SetCollisionGroup(Character, "Players")
			end)


			AnimationService:stopAll(Character)
			AnimationService:stopAll(EnemyCharacter)
			AnimationService:playAnimation(Character, UserAnimation)
			AnimationService:playAnimation(EnemyCharacter, VictimAnimation)


			Weld:Start(nil, EnemyPlayer, Player)
			
			
			ReplicateEffects_Set:FireAllClients("IceSkate", { Char = Character, Stage = "pa" })
		end
		
		
		DelayFunction(math.max(DelayTime, 0), function()
			local Hitbox = ReplicatedHitbox.new(Player)
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(6, 6, 8)
			Hitbox.Offset = CFrame.new(0, 0, -3)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				
				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 0.5, nil, nil, false, EnemyCharacter:HasTag('DEATH') and true or false, true, true, false, nil, nil)
				if HitInfo.Countered then return end
				
				HitFunction(EnemyCharacter)
				
				pcall(function()
					Hitbox:Destroy()
				end)
			end
			
			Hitbox:Start(0.3, true)
		end)
		
		
		StartTrack.Stopped:Once(function()
			if not Hit then
				StunHandler:Unstun(Character, Stun)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
		
		
		ReplicateEffects_Set:FireAllClients("IceSkate", { Char = Character, Stage = "psa" })
	end
}