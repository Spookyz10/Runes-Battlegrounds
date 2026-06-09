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
		local CounterConnection = nil
		
		
		local MissAnim = MoveAnims.Okarun.counter20.Miss
		local MissTrack = AnimationService:getAnimationTrack(Character, MissAnim)
		
		MissTrack.Stopped:Once(function()
			if Hit == false then
				StunHandler:Unstun(Character, Stun)
			end
			
			if CounterConnection then
				CounterConnection:Disconnect()
			end
			
			Character:RemoveTag("Countering")
		end)
		
		Character:AddTag("Countering")
		
		
		CounterConnection = Character.ChildAdded:Connect(function(child: ObjectValue?)
			if child.Name == 'DamagedLog' and child:HasTag('Counterable') then
				Character:RemoveTag("Countering")
				CounterConnection:Disconnect()
				
				Hit = true
				
				
				local playerClass = shared.playerClasses[Player.UserId]
				if playerClass then
					playerClass.TitlesProgress.Counters += 1
					Player:SetAttribute("CountersProgress", playerClass.TitlesProgress.Counters)
				end
				
				
				local EnemyCharacter: Model = child.Value
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				
				
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -2) * CFrame.Angles(0, rad(180), 0), 10)
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				
				iFramesService:AddAlliFrames(Character)
				AnimationService:stopAll(EnemyCharacter, 0)
				iFramesService:AddAlliFrames(EnemyCharacter)
				
				Character:AddTag("CantRotate")
				EnemyCharacter:AddTag("CantRotate")
				
				
				local VictimAnim = MoveAnims.Okarun.counter20.Victim
				local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnim)
				
				VictimTrack.Stopped:Once(function()
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end
					
					EnemyCharacter:RemoveTag("CantRotate")
					iFramesService:RemoveAlliFrames(EnemyCharacter)
					StunHandler:Unstun(EnemyCharacter, EnemyStun)
				end)
				
				
				local HitAnim = MoveAnims.Okarun.counter20.Hit
				local HitTrack = AnimationService:getAnimationTrack(Character, HitAnim)
				local HitEvents = {}
				
				HitEvents["Hit"] = HitTrack:GetMarkerReachedSignal("Hit"):Once(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 14, nil, nil, false, false, true, false, false, nil, nil)
				end)
				
				HitEvents["Upper"] = HitTrack:GetMarkerReachedSignal("Upper"):Connect(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, nil, nil, false, false, true, false, false, nil, nil)
				end)
				
				HitEvents["End"] = HitTrack:GetMarkerReachedSignal("End"):Once(function()
					HitEvents.Upper:Disconnect()
					
					AnimationService:stopAll(EnemyCharacter, 0)
					
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 14, nil, nil, false, false, true, false, true, nil, 18)
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 1, 1) * 100000, Velocity = HumRP.CFrame.LookVector * Vector3.new(100, 0, 100) + Vector3.new(0, 250, 0) })
					RagdollHandler.ragdoll(EnemyHumanoid, 3, true, Character)
					
					SoundsModule:PlaySound(MoveSounds.Okarun.counter20.FinalHit, EnemyHumRP)
				end)
				
				HitTrack.Stopped:Once(function()
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end

					Character:RemoveTag("CantRotate")
					iFramesService:RemoveAlliFrames(Character)
					StunHandler:Unstun(Character, Stun)
					Character:SetAttribute("MuteMusic", false)
				end)
				
				
				AnimationService:stopAll(Character, 0)
				AnimationService:playAnimation(Character, HitAnim)
				AnimationService:playAnimation(EnemyCharacter, VictimAnim)
				
				Character:SetAttribute("MuteMusic", true)
				
				ReplicateEffects_Set:FireAllClients("turbocounter", { Char = Character, EChar = EnemyCharacter })
				SoundsModule:PlaySound(MoveSounds.Okarun.counter20.Hit, EnemyHumRP)
				
				local enemyCF = CFrame.lookAt(EnemyHumRP.Position, HumRP.Position)
				EnemyHumRP.CFrame = enemyCF
				HumRP.CFrame = enemyCF * CFrame.new(0, 0, -2) * CFrame.Angles(0, rad(180), 0)
				
				Weld:Start(nil, game.Players:GetPlayerFromCharacter(EnemyCharacter) or Player)
			end
		end)
		
		
		AnimationService:stopAll(Character, 0)
		AnimationService:playAnimation(Character, MissAnim)
	end
}