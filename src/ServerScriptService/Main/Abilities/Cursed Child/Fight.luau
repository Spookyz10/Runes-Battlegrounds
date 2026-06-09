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
		
		
		local WindupAnimation = MoveAnims["Cursed Child"].Fight.Windup
		local WindupTrack = AnimationService:getAnimationTrack(Character, WindupAnimation)
		local WindupEvents = {}
		
		
		local Hit = false
		
		
		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(100000, 0, 100000)
		BodyVelocity.Name = "moveme"
		BodyVelocity:SetAttribute("End", 1)
		BodyVelocity:SetAttribute("Fallout", 0.91)
		BodyVelocity:SetAttribute("Goto", 60)
		BodyVelocity:SetAttribute("Speed", 50)
		
		
		local HitboxConnection = ReplicatedHitbox.new(Player)
		HitboxConnection.Instance = HumRP
		HitboxConnection.Size = Vector3.new(6, 6, 9)
		HitboxConnection.Offset = CFrame.new(0, 0, -3.5)
		HitboxConnection.Ignore = { Character }
		HitboxConnection.onTouch = function(EnemyCharacter)
			local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid


			if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead or EnemyCharacter:HasTag("Ragdolled") then return end

			local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, true, false, true, true, false, nil)
			
			if HitInfo.Blocked == true then
				
				return
			end
			
			Hit = true
			
			
			BodyVelocity:Destroy()
			pcall(function()
				HitboxConnection:Destroy()
			end)
			

			local VictimAnimation = MoveAnims["Cursed Child"].Fight.Victim
			local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)

			local UserAnimation = MoveAnims["Cursed Child"].Fight.Hit
			local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
			local UserEvents = {}


			local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -5) * CFrame.Angles(0, rad(-180), 0), 6)
			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)


			Character:AddTag('CantRotate')
			EnemyCharacter:AddTag('CantRotate')

			iFramesService:AddAlliFrames(Character)
			iFramesService:AddAlliFrames(EnemyCharacter)


			CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
			CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")


			local CharaFight = Instance.new("RemoteEvent")
			CharaFight.Name = "CharaFightRemote"
			CharaFight.Parent = Character
			
			
			Character:SetAttribute("Triggered", nil)
			
			
			
			CharaFight.OnServerEvent:Connect(function(plr, IsSuccess)
				if plr ~= Player then return end
				
				Character:SetAttribute("Triggered", IsSuccess)
			end)
			
			
			UserEvents["attack"] = UserTrack:GetMarkerReachedSignal("attack"):Once(function()
				ReplicateEffects_Set:FireClient(Player, "SetAwkbar", { State = false })
				ReplicateEffects_Set:FireClient(Player, "SetHotbar", { State = false })
			end)
			
			UserEvents["hit"] = UserTrack:GetMarkerReachedSignal("hit"):Once(function()
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
				
				if Character:GetAttribute("Triggered") == true then
					RagdollHandler.ragdoll(EnemyHumanoid, 2.25)
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 10, nil, nil, false, false, true, true, true, nil)
				else
					RagdollHandler.ragdoll(EnemyHumanoid, 2.25)
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, true, true, nil)
				end
				
				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(75000, 75000, 75000), Velocity = HumRP.CFrame.LookVector * 75 + Vector3.new(0, 10, 0) })
				
				ReplicateEffects_Set:FireAllClients("Fight", { Stage = "Slash", Char = Character, HitAnim = UserAnimation.AnimationId, Hit = Character:GetAttribute("Triggered") == true })
				ReplicateEffects_Set:FireClient(Player, "SetAwkbar", { State = true })
				ReplicateEffects_Set:FireClient(Player, "SetHotbar", { State = true })
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
				CharaFight:Destroy()

				StunHandler:Unstun(Character, Stun)
				Character:RemoveTag('CantRotate')
				iFramesService:RemoveAlliFrames(Character)
				CollisionsModule:SetCollisionGroup(Character, "Players")
			end)


			AnimationService:stopAll(EnemyCharacter)
			AnimationService:playAnimation(EnemyCharacter, VictimAnimation)

			AnimationService:stopAll(Character)
			AnimationService:playAnimation(Character, UserAnimation)

			Weld:Start(nil, EnemyPlayer, Player)

			ReplicateEffects_Set:FireAllClients("Fight", { Stage = "Hit", Char = Character, HitAnim = UserAnimation.AnimationId })
		end
		
		
		WindupEvents["stretch"] = WindupTrack:GetMarkerReachedSignal("stretch"):Once(function()
			
		end)
		
		WindupEvents["dash"] = WindupTrack:GetMarkerReachedSignal("dash"):Once(function()
			BodyVelocity.Parent = HumRP
			
			HitboxConnection:Start(0.38, true)
		end)
		
		WindupEvents["end"] = WindupTrack:GetMarkerReachedSignal("end"):Once(function()
			BodyVelocity:Destroy()
		end)
		
		
		WindupTrack.Stopped:Once(function()
			if BodyVelocity then
				BodyVelocity:Destroy()
			end
			for _,v in WindupEvents do
				v:Disconnect()
			end
			
			if not Hit then
				StunHandler:Unstun(Character, Stun)
			end
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, WindupAnimation)
		
		ReplicateEffects_Set:FireAllClients("Fight", { Stage = "Start", Char = Character, StartAnim = WindupAnimation.AnimationId })
	end
}