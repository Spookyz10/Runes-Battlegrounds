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


local AnimationEvents = shared.AnimationEvents
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
		local FinalHit = false
		local Finisher = false
		

		local MissAnim = MoveAnims.Okarun.earthstrike.User
		local MissTrack = AnimationService:getAnimationTrack(Character, MissAnim)
		local MissEvents = {}

		MissEvents["hit"] = MissTrack:GetMarkerReachedSignal("hit"):Once(function()
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP.CFrame
			Hitbox.Size = Vector3.new(7, 7, 7)
			Hitbox.Offset = CFrame.new(0, 0, -3.5)
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

				if EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyCharacter:HasTag("Ragdolled") then return end

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, 1.5, nil, false, true, false, true, Hit == true, nil, nil)
				if HitInfo.Countered == true then return end

				KnockbackModule:Knockback(EnemyCharacter, HumRP.CFrame.LookVector * 200, Character, nil, nil, nil, nil, nil, false)

				if Hit == false then
					Hit = true

					ReplicateEffects_Set:FireAllClients("turboearthstrike", { Char = Character, EChar = EnemyCharacter, Stage = "Hit" })
					local HitAnim = MoveAnims.Okarun.earthstrike.Hit
					local HitTrack = AnimationService:getAnimationTrack(Character, HitAnim)
					local HitEvents = {}

					HitEvents["fly"] = HitTrack:GetMarkerReachedSignal("fly"):Once(function()
						SoundsModule:PlaySound(MoveSounds.Okarun.earthstrike.Fly, HumRP)

						ReplicateEffects_Set:FireClient(Player, "turboearthstrike", { Char = Character, Stage = "Fly" })
					end)

					HitEvents["hit"] = HitTrack:GetMarkerReachedSignal("hit"):Once(function()
						local FinalHitbox = HitboxHandler.new()
						FinalHitbox.Instance = HumRP
						FinalHitbox.Size = Vector3.new(1, 1, 1) * 10
						FinalHitbox.Offset = CFrame.new(0, 0, -5)
						FinalHitbox.onTouch = function(EnemyCharacter2)
							local EnemyHumanoid2: Humanoid = EnemyCharacter2.Humanoid
							local EnemyHumRP2: BasePart = EnemyCharacter2.HumanoidRootPart

							if EnemyCharacter2 == Character or iFramesService:HasiFrame(EnemyCharacter2, Tool.Name) or EnemyHumanoid2.Health < 0 then return end

							FinalHit = true

							local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid2, 6, nil, nil, false, false, true, true, false, nil, 12)

							local lookVector = HumRP.CFrame.LookVector
							if HitInfo.Finisher == false then
								require(ServerStorage.Modules.PerfectKnockback).KnockBack(nil, EnemyCharacter, {
									LookVector = HumRP.CFrame.LookVector,
									LookForce = 35,
									LookFinalForce = 55,
									EscapableCooldown = 5,
									UpVelocityTime = 0.2,
									LookAt = CFrame.lookAt((HumRP.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0,math.pi,0)).Position, HumRP.Position) ,
									UpVelocity = Vector3.new(0, 75, 0),
									DestroyRagdoll = true,
									GroundStunTime = 1.2,
									Escapable = true,
								}, Character)
							else
								if Finisher == true then return end
								Finisher = true
								
								local FinisherWeld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -4) * CFrame.Angles(0, rad(180), 0), 2)
								
								if EnemyCharacter:HasTag('Ragdolled') then
									RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
								end
								
								local FinisherVictimAnim = MoveAnims.Okarun.earthstrike["Earthbound Strike Finisher Victim"]
								local FinisherVictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, FinisherVictimAnim)

								local FinisherUserAnim = MoveAnims.Okarun.earthstrike["Earthbound Strike Finisher User"]
								local FinisherUserTrack = AnimationService:getAnimationTrack(Character, FinisherUserAnim)
								local FinisherUserEvents = {}
								
								
								local FinisherEnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
								iFramesService:AddAlliFrames(Character)
								iFramesService:AddAlliFrames(EnemyCharacter)
								
								CollisionsModule:SetCollisionGroup(Character, "GrabbedPlayers")
								CollisionsModule:SetCollisionGroup(EnemyCharacter, "GrabbedPlayers")
								
								HumRP.Anchored = true
								
								EnemyCharacter:AddTag("CantRotate")
								Character:AddTag("CantRotate")
								
								
								FinisherUserEvents["End"] = FinisherUserTrack:GetMarkerReachedSignal("End"):Once(function()
									if FinisherWeld then
										pcall(function()
											FinisherWeld:Stop()
										end)
										FinisherWeld = nil
									end

									CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
									iFramesService:RemoveAlliFrames(EnemyCharacter)
									EnemyCharacter:RemoveTag("CantRotate")
									StunHandler:Unstun(EnemyCharacter, FinisherEnemyStun)
									
									DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, true, true, true, nil)
									RagdollHandler.ragdoll(EnemyHumanoid, 3, true, Character)
									NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(100000, 100000, 100000), Velocity = lookVector * 500 + Vector3.new(0, 50, 0) })
									
									shared.fireTo(ReplicateEffects_Set, { Player, game.Players:GetPlayerFromCharacter(EnemyCharacter) }, { "ShakeCamera", { Intensity = 21 } })
								end)
								
								
								
								FinisherUserTrack.Stopped:Once(function()
									if FinisherWeld then
										pcall(function()
											FinisherWeld:Stop()
										end)
										FinisherWeld = nil
									end

									for _,v in FinisherUserEvents do
										v:Disconnect()
									end
									HumRP.Anchored = false

									CollisionsModule:SetCollisionGroup(Character, "Players")
									iFramesService:RemoveAlliFrames(Character)
									Character:RemoveTag("CantRotate")

									StunHandler:Unstun(Character, Stun)
								end)
								FinisherVictimTrack.Stopped:Once(function()
									if FinisherWeld then
										pcall(function()
											FinisherWeld:Stop()
										end)
										FinisherWeld = nil
									end

									CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")
									iFramesService:RemoveAlliFrames(EnemyCharacter)
									EnemyCharacter:RemoveTag("CantRotate")

									StunHandler:Unstun(EnemyCharacter, FinisherEnemyStun)
								end)
								
								
								AnimationService:stopAll(EnemyCharacter, 0)
								AnimationService:stopAll(Character, 0)
								
								AnimationService:playAnimation(Character, FinisherUserAnim)
								AnimationService:playAnimation(EnemyCharacter, FinisherVictimAnim)
								
								
								SoundsModule:PlaySound(MoveSounds.Okarun.earthstrike.Finisher, HumRP)
								ReplicateEffects_Set:FireAllClients("OkarunFinishers", { Finisher = "Earthbound Strike", Char = Character, EChar = EnemyCharacter })
								FinisherWeld:Start(nil, game.Players:GetPlayerFromCharacter(EnemyCharacter) or Player)	
							end
							
							ReplicateEffects_Set:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0), ["end"] = Vector3.new(0, -25, 0), amount = 9, nosound = false, size = 1.4 })
							ReplicateEffects_Set:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0), ["end"] = Vector3.new(0, -25, 0), amount = 6, nosound = true, size = 0.3 })
						end
						
						FinalHitbox:Once()
						FinalHitbox:Destroy()

						ReplicateEffects_Set:FireAllClients("turboearthstrike", { Char = Character, Stage = "Downslam" })
						SoundsModule:PlaySound(MoveSounds.Okarun.earthstrike.Slam, HumRP.CFrame * CFrame.new(0, -3, -3))
					end)

					HitTrack.Stopped:Once(function()
						for _,v in HitEvents do
							v:Disconnect()
						end
						if Finisher == true then return end
						
						StunHandler:Unstun(Character, Stun)
					end)

					AnimationService:stopAll(Character, 0)
					AnimationService:playAnimation(Character, HitAnim)

					SoundsModule:PlaySound(MoveSounds.Okarun.earthstrike.Punch, EnemyHumRP)
				end
			end

			Hitbox:Once()
			Hitbox:Destroy()

			ReplicateEffects_Set:FireAllClients("turboearthstrike", { Char = Character, Stage = "Miss" })
		end)

		MissTrack.Stopped:Once(function()
			for _,v in MissEvents do
				v:Disconnect()
			end

			if Hit == false then
				if Finisher == true then return end
				
				StunHandler:Unstun(Character, Stun)
			end
		end)


		AnimationService:stopAll(Character, 0)
		AnimationService:playAnimation(Character, MissAnim)

		SoundsModule:PlaySound(MoveSounds.Okarun.earthstrike.Windup, HumRP)
	end
}