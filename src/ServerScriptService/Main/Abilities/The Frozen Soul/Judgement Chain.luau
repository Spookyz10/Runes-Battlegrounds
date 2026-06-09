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
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)
		
		
		local UserAnimation = MoveAnims.Subzero["Judgement Chain"].User
		local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
		local UserEvents = {}
		
		
		local Hit = false
		local Enemy = nil
		local EnemyRoot = nil
		
		
		local dashVelocity = Instance.new("BodyVelocity")
		dashVelocity.MaxForce = Vector3.new(500000, 0, 500000)
		dashVelocity.Name = "moveme"
		dashVelocity:SetAttribute("End", 1)
		dashVelocity:SetAttribute("Fallout", 0.91)
		dashVelocity:SetAttribute("Goto", 20)
		dashVelocity:SetAttribute("Speed", 100)
		
		
		local Hitbox = HitboxHandler.new()
		Hitbox.Instance = HumRP
		Hitbox.Size = Vector3.new(60, 60, 268)
		Hitbox.Offset = CFrame.new(0, 0, -Hitbox.Size.Z/2)
		Hitbox.onTouch = function(EnemyCharacter: Model)
			local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			
			if Hit == true or EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 then return end
			
			local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, nil, nil, true, false, true, true, false, nil, nil)
			
			Hit = true
			Enemy = EnemyCharacter
			EnemyRoot = EnemyHumRP
			
			iFramesService:AddAlliFrames(Character)
			
			UserEvents["finalhit"] = UserTrack:GetMarkerReachedSignal("finalhit"):Once(function()
				SoundsModule:PlaySound(MoveSounds.Subzero["Judgement Chain"].Slide, HumRP)
				SoundsModule:PlaySound(MoveSounds.Subzero["Judgement Chain"]["Final Hit"], HumRP)
				
				dashVelocity.Parent = HumRP
				Debris:AddItem(dashVelocity, 1.5)
				
				ReplicateEffects_Set:FireAllClients("judgementChain", { char = Character, hit = EnemyCharacter, id = UserAnimation.AnimationId, finalhit = true })
				
				
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 then return end
				
				if HitInfo.Blocked == true then
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
				else
					RagdollHandler.ragdoll(EnemyHumanoid, 2)
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(75000, 75000, 75000), Velocity = HumRP.CFrame.LookVector * 75 + Vector3.new(0, 10, 0) })
				end
				
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 10, nil, nil, false, false, true, true, true, nil, nil)
			end)

			UserEvents["end"] = UserTrack:GetMarkerReachedSignal("end"):Once(function()
				for _,v in UserEvents do
					v:Disconnect()
				end
				
				dashVelocity:Destroy()
				
				iFramesService:RemoveAlliFrames(Character)
				StunHandler:Unstun(Character, Stun)
			end)
			
			UserTrack.Stopped:Once(function()
				for _,v in UserEvents do
					v:Disconnect()
				end
				
				dashVelocity:Destroy()
				
				iFramesService:RemoveAlliFrames(Character)
				StunHandler:Unstun(Character, Stun)
			end)
			
			SoundsModule:PlaySound(MoveSounds.Subzero["Judgement Chain"].Victim, EnemyHumRP)
		end
		
		Hitbox:Once()
		Hitbox:Destroy()
		
		
		UserEvents["dash"] = UserTrack:GetMarkerReachedSignal("dash"):Once(function()
			if Hit == false then
				local MissAnimation = MoveAnims.Subzero["Judgement Chain"].Miss
				local MissTrack = AnimationService:getAnimationTrack(Character, MissAnimation)
				
				MissTrack.Stopped:Once(function()
					for _,v in UserEvents do
						v:Disconnect()
					end
					
					iFramesService:RemoveAlliFrames(Character)
					StunHandler:Unstun(Character, Stun)
				end)
				
				AnimationService:stopAll(Character)
				AnimationService:playAnimation(Character, MissAnimation)
			else
				SoundsModule:PlaySound(MoveSounds.Subzero["Judgement Chain"].User, HumRP)
				
				ReplicateEffects_Set:FireAllClients("judgementChain", { char = Character, hit = Enemy, id = UserAnimation.AnimationId, dash = true })
				
				local StartPos = HumRP.Position
				local EndPos = EnemyRoot.Position

				local direction = (EndPos - StartPos).Unit
				local distance = (StartPos - EndPos).Magnitude
				local midOffset = direction * (distance / 2)
				local verticalLift = Vector3.new(0, 1.5, 0)

				local MidPos = StartPos + midOffset + verticalLift

				local LookDirection = (EnemyRoot.Position - StartPos).Unit


				ReplicateEffects_Set:FireAllClients("bezierTween", {
					char = Character,
					id = UserAnimation.AnimationId,
					Root = HumRP,
					FinalHit = true,
					finalhit = true,
					New = { StartPos, MidPos, EndPos },
					LookAtPart = EnemyRoot,
					LookDirection = LookDirection,
					Time = 0.5,
				})
			end
		end)
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
		
		SoundsModule:PlaySound(MoveSounds.Subzero["Judgement Chain"].Startup, HumRP)
	end
}