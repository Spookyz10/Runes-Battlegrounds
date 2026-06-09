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
		
		
		local StartAnimation = MoveAnims["Frozen Warrior"]["Glacial Crush"].Startup
		local StartTrack, StartEvents = AnimationService:getAnimationTrack(Character, StartAnimation)
		
		
		local Hit = false
		
		
		local IceSpear = Models.Frozen.IceSpear:Clone()
		Debris:AddItem(IceSpear, 1.35)
		IceSpear:PivotTo(HumRP.CFrame)
		IceSpear.rootPart.Bone.Part0 = Character["Right Arm"]
		IceSpear.Parent = Character
		
		
		coroutine.wrap(function()
			pcall(function()
				IceSpear:ScaleTo(0.01)
				for v30 = 1, 10 do
					IceSpear:ScaleTo(v30 / 10)
					task.wait(0.01)
				end
			end)
		end)()
		
		task.delay(1.2, function()
			pcall(function()
				for v31 = 10, 1, -1 do
					IceSpear:ScaleTo(v31 / 10)
					task.wait(0.01)
				end
			end)
		end)
		
		
		local function HitFunction(EnemyCharacter: Model)
			if Hit == true or StartTrack.IsPlaying == false then return end
			Hit = true


			local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			
			
			if EnemyCharacter:HasTag('Ragdolled') then
				RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
			end
			
			
			if IceSpear then
				IceSpear:Destroy()
				IceSpear = nil
			end
			
			
			local NewIceSpear = Models.Frozen.IceSpear:Clone()
			Debris:AddItem(NewIceSpear, 1.7)
			NewIceSpear:PivotTo(HumRP.CFrame)
			NewIceSpear.rootPart.Bone.Part0 = Character["Right Arm"]
			NewIceSpear.Parent = Character

			task.delay(1.6, function()
				pcall(function()
					for v34 = 10, 1, -1 do
						NewIceSpear:ScaleTo(v34 / 10)
						task.wait(0.01)
					end
				end)
			end)
			
			
			local UserAnimation = MoveAnims["Frozen Warrior"]["Glacial Crush"].Main
			local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

			local VictimAnimation = MoveAnims["Frozen Warrior"]["Glacial Crush"].Victim
			local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
			
			
			Stun:SetAttribute("WalkSpeed", 0)
			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
			local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -2), -1)
			
			
			EnemyCharacter:AddTag('CantRotate')
			
			iFramesService:AddAlliFrames(Character)
			iFramesService:AddAlliFrames(EnemyCharacter)
			
			CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
			
			
			task.delay(0.25, function()
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 2.5, nil, nil, false, false, true, true, false, nil, nil)
			end)
			
			task.delay(0.8, function()
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 3.5, nil, nil, false, false, true, true, false, nil, nil)
				
				local Hitbox = HitboxHandler.new()
				Hitbox.Instance = CFrame.new((HumRP.CFrame * CFrame.new(0, 0, -2)).Position)
				Hitbox.Size = Vector3.new(20, 20, 20)
				Hitbox.Ignore = { Character, EnemyCharacter }
				Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(20, 20, 20) + Vector3.new(0, 25, 0) }
				Hitbox.onTouch = function(EnemyCharacter2)
					local EnemyHumanoid2: Humanoid = EnemyCharacter2.Humanoid

					if iFramesService:HasiFrame(EnemyCharacter2, Tool.Name) then return end
					
					RagdollHandler.ragdoll(EnemyHumanoid2, 2)
					knockbackService.Knockback(EnemyCharacter2.PrimaryPart, {
						["duration"] = 0.2,
						["force"] = 30,
						["direction"] = Vector3.new(0, 1, 0)
					})
					DamageHandler:TakeDamage(Character, EnemyHumanoid2, 8, nil, nil, false, false, true, true, true, nil, nil)
				end
				
				Hitbox:Once()
				Hitbox:Destroy()
			end)
			
			task.delay(1.55, function()
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

				DamageHandler:TakeDamage(Character, EnemyHumanoid, 5.9, nil, nil, false, false, true, true, true, nil, nil)
				knockbackService.Knockback(EnemyCharacter.PrimaryPart, {
					["duration"] = 0.2,
					["force"] = 29,
					["direction"] = HumRP.CFrame.LookVector + Vector3.new(0, 0.88, 0)
				})
				RagdollHandler.ragdoll(EnemyHumanoid, 2.5)
				
				local Hitbox = HitboxHandler.new()
				Hitbox.Instance = CFrame.new((HumRP.CFrame * CFrame.new(0, 0, -2)).Position)
				Hitbox.Size = Vector3.new(40, 40, 40)
				Hitbox.Ignore = { Character, EnemyCharacter }
				Hitbox.DestroyAmbient = { Owner = Player, Velocity = -HumRP.CFrame.LookVector * Vector3.new(40, 40, 40) + Vector3.new(0, 25, 0) }
				Hitbox.onTouch = function(EnemyCharacter2)
					local EnemyHumanoid2: Humanoid = EnemyCharacter2.Humanoid

					if iFramesService:HasiFrame(EnemyCharacter2, Tool.Name) then return end

					RagdollHandler.ragdoll(EnemyHumanoid2, 2)
					local v45 = {
						["duration"] = 0.2,
						["force"] = 20,
						["direction"] = CFrame.new(HumRP.CFrame.Position, EnemyCharacter2.PrimaryPart.Position).LookVector + Vector3.new(0, 1.7, 0)
					}
					knockbackService.Knockback(EnemyCharacter2.PrimaryPart, v45)
					DamageHandler:TakeDamage(Character, EnemyHumanoid2, 8, nil, nil, false, false, true, false, true, nil, nil)
				end
				
				Hitbox:Once()
				Hitbox:Destroy()
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
			
			ReplicateEffects_Set:FireAllClients("GlacialCrush", { Char = Character, victim = EnemyCharacter, Stage = "pa" })
		end
		
		
		task.delay(0.3, function()
			local Hitbox = ReplicatedHitbox.new(Player)
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(6, 4.5, 13)
			Hitbox.Offset = CFrame.new(0, -2.5, -4)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				
				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 0.5, nil, nil, true, EnemyCharacter:HasTag('DEATH') and true or false, true, true, false, nil, nil)
				if HitInfo.Blocked or HitInfo.Countered then return end
				
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
		
		
		ReplicateEffects_Set:FireAllClients("GlacialCrush", { Char = Character, Stage = "psa" })
	end
}