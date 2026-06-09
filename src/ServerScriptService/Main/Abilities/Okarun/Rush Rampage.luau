local ServerStorage = game:GetService('ServerStorage') 


local StunHandler = require(game.ServerStorage.Modules.StunHandler)
local HitboxHandler = require(game.ServerStorage.Modules.HitboxHandler)
local DamageHandler = require(game.ServerStorage.Modules.DamageHandler)
local RagdollHandler = require(game.ServerStorage.Modules.RagdollHandler)
local NewKnockback = require(game.ServerStorage.Modules.BodymoverService)
local AnimationService = require(game.ServerStorage.Modules.AnimationService)
local iFramesService = require(game.ServerStorage.Modules.iFramesService)
local WeaponsHandler = require(game.ServerStorage.Modules.WeaponsHandler)
local CollisionsModule = require(game.ServerStorage.Modules.CollisionsModule)
local SoundsModule = require(game.ServerStorage.Modules.SoundsModule)
local KnockbackModule = require(game.ServerStorage.Modules.KnockbackModule)



local Utility = shared.Utility
local WeldSystem = require(game.ReplicatedStorage.Modules.WeldSystem)


local Sounds = shared.SoundsFolder
local Animations = shared.AnimsFolder

local MoveAnims = game.ServerStorage.Assets.Animations.Moves
local MoveSounds = game.ServerStorage.Assets.Sounds.Moves


local PlrSet = shared.PlrSet
local PlrGet = shared.PlrGet


local ReplicateEffects_Set = game.ReplicatedStorage.Remotes.Replicate.Set


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
		local Hit = false
		
		iFramesService:AddAlliFrames(Character)
		
		
		local MissAnimation = MoveAnims.Okarun.rush.Miss
		local MissTrack = AnimationService:getAnimationTrack(Character, MissAnimation)
		local MissEvents = {}
		
		MissEvents["FlashStep"] = MissTrack:GetMarkerReachedSignal("FlashStep"):Once(function()
			ReplicateEffects_Set:FireAllClients("turborush", { Stage = "FlashStep", Char = Character })
		end)
		
		MissEvents["Hit"] = MissTrack:GetMarkerReachedSignal("Hit"):Once(function()
			local MainCF = HumRP.CFrame
			
			
			local Hitbox = HitboxHandler.new()
			Hitbox.Size = Vector3.new(16.4, 14, 125)
			Hitbox.Offset = CFrame.new(0, 0, -Hitbox.Size.Z/2)
			Hitbox.Instance = MainCF
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = game.Players:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				
				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end
				
				Hit = true
				
				
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, false, false, true, false, false, nil, nil)
				
				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
				
				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)
				
				iFramesService:AddAlliFrames(EnemyCharacter)
				
				EnemyCharacter:AddTag("CantRotate")
				
				
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				local EnemyCF = CFrame.lookAt(EnemyHumRP.Position, MainCF.Position)
				
				EnemyCharacter:PivotTo(EnemyCF)
				Character:PivotTo(EnemyCF * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0))
				
				
				local UserAnimation = MoveAnims.Okarun.rush.User
				local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
				local UserEvents = {}
				
				for i = 1, 10 do
					UserEvents[tostring(i)] = UserTrack:GetMarkerReachedSignal(tostring(i)):Once(function()
						if i == 3 then
							Character:AddTag("CantRotate")
							
						elseif i == 10 then
							if not EnemyPlayer then
								EnemyHumRP:SetNetworkOwnershipAuto()
							end
							
							
							AnimationService:stopAll(EnemyCharacter, 0)
							
							StunHandler:Unstun(EnemyCharacter, EnemyStun)
							iFramesService:RemoveAlliFrames(EnemyCharacter)
							EnemyCharacter:RemoveTag("CantRotate")
							
							
							RagdollHandler.ragdoll(EnemyHumanoid, 3, true)
							NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(math.huge, math.huge, math.huge), Velocity = HumRP.CFrame.LookVector * 300 + Vector3.new(0, 50, 0) })
						end
						
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, true, false, (i == 10 and true or false), nil, nil)
					end)
				end
				
				UserEvents["StartUp1"] = UserTrack:GetMarkerReachedSignal("StartUp1"):Once(function()
					ReplicateEffects_Set:FireAllClients("turborush", { Stage = "StartUp1", Char = Character, EChar = EnemyCharacter })
				end)
				
				UserEvents["KPunch1"] = UserTrack:GetMarkerReachedSignal("KPunch1"):Once(function()
					ReplicateEffects_Set:FireAllClients("turborush", { Stage = "KPunch1", Char = Character, EChar = EnemyCharacter })
				end)
				
				UserEvents["Run"] = UserTrack:GetMarkerReachedSignal("Run"):Once(function()
					ReplicateEffects_Set:FireClient(Player, "turborush", { Stage = "Run", Char = Character, EChar = EnemyCharacter })
				end)
				
				UserEvents["MiniSlam"] = UserTrack:GetMarkerReachedSignal("MiniSlam"):Once(function()
					ReplicateEffects_Set:FireAllClients("turborush", { Stage = "MiniSlam", Char = Character, EChar = EnemyCharacter })
				end)
				
				UserEvents["line"] = UserTrack:GetMarkerReachedSignal("line"):Once(function()
					ReplicateEffects_Set:FireAllClients("turborush", { Stage = "line", Char = Character, EChar = EnemyCharacter })
				end)
				
				UserEvents["newForwardHit"] = UserTrack:GetMarkerReachedSignal("newForwardHit"):Once(function()
					ReplicateEffects_Set:FireAllClients("turborush", { Stage = "newForwardHit", Char = Character, EChar = EnemyCharacter })
				end)
				
				UserEvents["FlashyBarrage"] = UserTrack:GetMarkerReachedSignal("FlashyBarrage"):Once(function()
					ReplicateEffects_Set:FireAllClients("turborush", { Stage = "FlashyBarrage", Char = Character, EChar = EnemyCharacter })
				end)
				
				UserEvents["KPunch2"] = UserTrack:GetMarkerReachedSignal("KPunch2"):Once(function()
					ReplicateEffects_Set:FireAllClients("turborush", { Stage = "KPunch2", Char = Character, EChar = EnemyCharacter })
				end)
				
				UserEvents["PunchImpact2"] = UserTrack:GetMarkerReachedSignal("PunchImpact2"):Once(function()
					ReplicateEffects_Set:FireAllClients("turborush", { Stage = "PunchImpact2", Char = Character, EChar = EnemyCharacter })
				end)
				
				UserTrack.Stopped:Once(function()
					for _,v in UserEvents do
						v:Disconnect()
					end

					
					StunHandler:Unstun(Character, Stun)
					iFramesService:RemoveAlliFrames(Character)
					Character:RemoveTag("CantRotate")
					CollisionsModule:SetCollisionGroup(Character, "Players")
				end)
				
				
				local VictimAnimation = MoveAnims.Okarun.rush.Victim
				local VictimTrack = AnimationService:getAnimationTrack(Character, VictimAnimation)
				
				VictimTrack.Stopped:Once(function()
					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					iFramesService:RemoveAlliFrames(EnemyCharacter)
					EnemyCharacter:RemoveTag("CantRotate")
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
				end)
				
				
				AnimationService:playAnimation(Character, UserAnimation)
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
				
				SoundsModule:PlaySound(MoveSounds.Okarun.rush.User, Character.Torso)
				
				if not EnemyPlayer then
					EnemyHumRP:SetNetworkOwner(Player)
					ReplicateEffects_Set:FireClient(Player, "turborush", { Stage = "Weld", Char = Character, EChar = EnemyCharacter })
					
				else
					ReplicateEffects_Set:FireClient(EnemyPlayer, "turborush", { Stage = "Weld", Char = Character, EChar = EnemyCharacter })
					
				end
			end
			
			Hitbox:Once()
			Hitbox:Destroy()
			
			if not Hit then
				Character:PivotTo(MainCF * CFrame.new(0, 0, -125))
			end
			
			ReplicateEffects_Set:FireAllClients("turborush", { Stage = "TP", Char = Character, MainCF = MainCF, Hit = Hit })
		end)
		
		MissTrack.Stopped:Once(function()
			for _,v in MissEvents do
				v:Disconnect()
			end
			
			if not Hit then
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, MissAnimation)
		
		SoundsModule:PlaySound(MoveSounds.Okarun.rush.Miss, Character.Torso)
	end
}