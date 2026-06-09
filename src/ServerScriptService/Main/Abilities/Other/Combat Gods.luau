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

local function WeldUsage(Part0, Part1, C0, C1)
	local Weld = Instance.new("Weld")
	Weld.Parent = Part0
	Weld.Part0 = Part0
	Weld.Part1 = Part1

	if C0 then
		Weld.C0 = C0
	end
	if C1 then
		Weld.C1 = C1
	end

	return Weld
end

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart


		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		local Hit = false
		local CounterConnection

		local StartAnimation = Animations.Other.SpecialMove.Start
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		
		task.delay(5, function()
			if Hit == false then
				AnimationService:stopAnimation(Character, StartAnimation)
				AnimationService:stopAll(Character)
			end
		end)
		
		StartTrack.Stopped:Once(function()
			if Hit == false then
				StunHandler:Unstun(Character, Stun)
			end

			if CounterConnection then
				CounterConnection:Disconnect()
				CounterConnection = nil
			end

			Character:RemoveTag("Countering")
		end)


		Character:AddTag("Countering")


		CounterConnection = Character.ChildAdded:Connect(function(child: ObjectValue?)
			if child.Name == 'DamagedLog' and child:HasTag('Counterable') then
				Character:RemoveTag("Countering")
				CounterConnection:Disconnect()
				CounterConnection =  nil

				Hit = true
				
				
				local playerClass = shared.playerClasses[Player.UserId]
				if playerClass then
					playerClass.TitlesProgress.Counters += 1
					Player:SetAttribute("CountersProgress", playerClass.TitlesProgress.Counters)
				end


				local EnemyCharacter: Model = child.Value
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				HumRP.Anchored = true
				
				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)
				
				CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
				CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

				AnimationService:stopAll(Character)
				AnimationService:stopAll(EnemyCharacter)

				Character:AddTag("CantRotate")
				EnemyCharacter:AddTag("CantRotate")

				local Weld = WeldUsage(HumRP, EnemyHumRP)
				
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				
				local UserAnimation = Animations.Other.SpecialMove.User
				local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
				
				local VictimAnimation = Animations.Other.SpecialMove.Victim
				local VictimTrak = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnimation)
				
				ReplicateEffects_Set:FireAllClients('JSBCombatGods', { Attacker = Character; Victim = EnemyCharacter; })
				
				VictimTrak.Stopped:Once(function()
					if Weld then
						Weld:Destroy()
					end
					
					iFramesService:RemoveAlliFrames(EnemyCharacter)
					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
					EnemyCharacter:RemoveTag("CantRotate")
				end)
				
				UserTrack.Stopped:Once(function()
					if Weld then
						Weld:Destroy()
					end
					
					HumRP.Anchored = false
					
					iFramesService:RemoveAlliFrames(Character)
					StunHandler:Unstun(Character, Stun)
					CollisionsModule:SetCollisionGroup(Character, "Players")
					Character:RemoveTag("CantRotate")
				end)
				
				
				AnimationService:playAnimation(Character, UserAnimation)
				AnimationService:playAnimation(EnemyCharacter, VictimAnimation)
				
			end
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
	end
}