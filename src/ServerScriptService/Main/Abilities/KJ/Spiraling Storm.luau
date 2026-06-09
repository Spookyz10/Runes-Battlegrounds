local ServerStorage = game:GetService('ServerStorage') 


local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

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
local ReplicatedHitboxes = require(game.ServerStorage.Modules.ReplicatedHitboxes)
local StatesHandler = require(game.ServerStorage.Modules.StatesHandler)

local AnimationEvents = shared.AnimationEvents
local Utility = shared.Utility
local WeldSystem = require(game.ReplicatedStorage.Modules.WeldSystem)


local Sounds = game.ServerStorage.Assets.Sounds
local Animations = game.ServerStorage.Assets.Animations
local Models = game.ServerStorage.Assets.Models

local Weapons = Models.Weapons
local MoveAnims = Animations.Moves
local MoveSounds = Sounds.Moves


local ComSet = game.ReplicatedStorage.Remotes.Comunicator.Set
local ComGet = game.ReplicatedStorage.Remotes.Comunicator.Get


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
		local Grab = false
		local CounterConnection
		
		
		local MissAnimation = MoveAnims.KJ["Spiraling Storm"].Startup
		local MissTrack = AnimationService:getAnimationTrack(Character, MissAnimation)
		local MissEvents = {}
		
		MissEvents["Deactivate"] = MissTrack:GetMarkerReachedSignal("EndTimeframe"):Once(function()
			Character:RemoveTag("Countering")
			
			if CounterConnection then
				CounterConnection:Disconnect()
				CounterConnection = nil
			end
		end)
		
		MissTrack.Stopped:Once(function()
			for _,v in MissEvents do
				v:Disconnect()
			end
			
			if Hit == false and Grab == false then
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

				AnimationService:stopAll(child.Value)
				StunHandler:Stun(child.Value, 1, true, 0, 0, true)


				local BodyVelocity

				local HitStartupAnimation = MoveAnims.KJ["Spiraling Storm"]["Hit Startup"]
				local HitStartupTrack = AnimationService:getAnimationTrack(Character, HitStartupAnimation)
				local HitStartupEvents = {}
				
				HitStartupEvents["hit"] = HitStartupTrack:GetMarkerReachedSignal("hit"):Once(function()
					local Hitbox = HitboxHandler.new()
					Hitbox.Instance = HumRP
					Hitbox.Size = Vector3.new(7, 7, 7)
					Hitbox.Offset = CFrame.new(0, 0, -3.5)
					Hitbox.Ignore = { Character }
					Hitbox.onTouch = function(EnemyCharacter)
						local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
						local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
						local EnemyPlayer = game.Players:GetPlayerFromCharacter(EnemyCharacter)
						
						if Grab == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead or (EnemyCharacter:HasTag("Ragdolled") and not EnemyCharacter:FindFirstChild("inAir")) then return end
						
						Grab = true


						local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, rad(180), 0), 10)
						local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
						
						ReplicateEffects_Set:FireClient(Player,'Camshake',{ Intensity = 7 })
						if EnemyPlayer then
							ReplicateEffects_Set:FireClient(EnemyPlayer,'Camshake',{ Intensity = 7 })
						end

						iFramesService:AddAlliFrames(Character)
						iFramesService:AddAlliFrames(EnemyCharacter)

						CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
						CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")

						AnimationService:stopAll(Character)
						AnimationService:stopAll(EnemyCharacter)

						EnemyCharacter:AddTag("CantRotate")


						local HitAnimation = MoveAnims.KJ["Spiraling Storm"].User
						local HitTrack = AnimationService:getAnimationTrack(Character, HitAnimation)
						local HitEvents = {}

						HitEvents["spin"] = HitTrack:GetMarkerReachedSignal("spin"):Once(function()
							ReplicateEffects_Set:FireAllClients('KjCounter',{ Char = Character, Victim = EnemyCharacter, Spin = true })
							
							BodyVelocity:SetAttribute("Fallout", 1.05)
							BodyVelocity:SetAttribute("Limit", 50)
							BodyVelocity:SetAttribute("Side", 3.815)
							BodyVelocity:SetAttribute("Speed", 15)
						end)

						HitEvents["throw"] = HitTrack:GetMarkerReachedSignal("throw"):Once(function()
							if Weld then
								pcall(function()
									Weld:Stop()
								end)
								Weld = nil
							end
							
							BodyVelocity:Destroy()


							CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

							iFramesService:RemoveAlliFrames(EnemyCharacter)
							StunHandler:Unstun(EnemyCharacter, EnemyStun)

							DamageHandler:TakeDamage(Character, EnemyHumanoid, 15, nil, nil, false, false, true, true, true, nil, nil)
							RagdollHandler.ragdoll(EnemyHumanoid, 2)
							NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(100000, 50000, 100000), Velocity = HumRP.CFrame.LookVector * Vector3.new(75, 0 ,75) + Vector3.new(0, 25, 0) })
						end)

						HitTrack.Stopped:Once(function()
							for _,v in HitEvents do
								v:Disconnect()
							end


							CollisionsModule:SetCollisionGroup(Character, "Players")

							iFramesService:RemoveAlliFrames(Character)
							StunHandler:Unstun(Character, Stun)

							Character:RemoveTag("Countering")

							if CounterConnection then
								CounterConnection:Disconnect()
								CounterConnection = nil
							end

							if Weld then
								pcall(function()
									Weld:Stop()
								end)
								Weld = nil
							end
						end)


						AnimationService:playAnimation(Character, HitAnimation)
						AnimationService:playAnimation(EnemyCharacter, MoveAnims.KJ["Spiraling Storm"].Victim)

						ReplicateEffects_Set:FireAllClients('KjCounter',{ Char = Character, Victim = EnemyCharacter })
						
						SoundsModule:PlaySound(MoveSounds.KJ["Spiraling Storm"].User, HumRP)
						SoundsModule:PlaySound(MoveSounds.KJ["Spiraling Storm"].Victim, EnemyCharacter.Torso)
						
						Weld:Start(nil, game.Players:GetPlayerFromCharacter(EnemyCharacter) or Player)
												
						BodyVelocity = Instance.new("BodyVelocity")
						BodyVelocity.Name = "moveme"
						BodyVelocity.MaxForce = Vector3.new(40000, 0, 40000)
						BodyVelocity:SetAttribute("End", -5)
						BodyVelocity:SetAttribute("Fallout", 0.9)
						BodyVelocity:SetAttribute("Side", 100)
						BodyVelocity:SetAttribute("SideFallout", 0.9)
						BodyVelocity:SetAttribute("Speed", 40)
						BodyVelocity.Parent = HumRP
						
						StatesHandler.SkillText(Player, "SPIRALING STORM [HIT]")
					end
					
					Hitbox:Once()
					Hitbox:Destroy()
				end)
				
				HitStartupTrack.Stopped:Once(function()
					for _,v in HitStartupEvents do
						v:Disconnect()
					end
					
					if Grab == false then
						StunHandler:Unstun(Character, Stun)
					end
					
					if CounterConnection then
						CounterConnection:Disconnect()
						CounterConnection = nil
					end

					Character:RemoveTag("Countering")
				end)
				
				
				AnimationService:stopAll(Character)
				AnimationService:playAnimation(Character, HitStartupAnimation)

				SoundsModule:PlaySound(MoveSounds.KJ["Spiraling Storm"]["Hit Startup"], HumRP)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, MissAnimation)
		
		SoundsModule:PlaySound(MoveSounds.KJ["Spiraling Storm"].Startup, HumRP)
		
		StatesHandler.SkillText(Player, "SPIRALING STORM [USED]")
	end
}