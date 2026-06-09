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
local StatesHandler = require(ServerModules.StatesHandler)


local Utility = shared.Utility
local WeldSystem = require(ReplicatedModules.WeldSystem)


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
		local Finisher, WentDown = false, false
		local Tag = os.clock() + Player.UserId
		
		local Bind = Instance.new("Accessory")
		Bind.Name = "WhirlwindDrop" .. Tag
		Bind.Parent = Character
		
		
		local StartAnimation = MoveAnims.Suiryu.whirlwinddrop.Start
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}
		
		StartEvents["jump"] = StartTrack:GetMarkerReachedSignal("jump"):Once(function()
			ReplicateEffects_Set:FireClient(Player, "whirlwinddrop", { Stage = "jump", Char = Character, BindName = Bind.Name })
		end)
		
		StartEvents["down"] = StartTrack:GetMarkerReachedSignal("down"):Once(function()
			WentDown = true
			
			
			local GoalPos = HumRP.Position - Vector3.new(0, 50, 0)
			local GroundRay = workspace:Raycast(HumRP.Position, Vector3.new(0, -100, 0), MapRayParams)
			if GroundRay then
				GoalPos = GroundRay.Position + Vector3.new(0, 3, 0)
			end
			
			
			task.wait(0.25)
			
			
			ReplicateEffects_Set:FireClient(Player, "whirlwinddrop", { Stage = "down", Char = Character, GoalCF = CFrame.lookAlong(GoalPos, HumRP.CFrame.LookVector) })	
			
			
			task.wait(0.12)
			
			
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = CFrame.lookAlong(GoalPos, HumRP.CFrame.LookVector)
			Hitbox.Size = Vector3.new(50, 50, 50)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
				
				
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 12, nil, nil, false, false, false, true, false, nil, 13)
				NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 100000, 1), Velocity = HumRP.CFrame.UpVector * 75 })
				RagdollHandler.ragdoll(EnemyHumanoid, 2)
				
				
				if HitInfo.Finisher == true and not Finisher then
					Finisher = true
					
					Character:SetAttribute("PurpleFinisher", true)
					
					iFramesService:AddAlliFrames(Character)
					
					Character:AddTag("CantRotate")
					
					
					local Knockback, HitStage = 75, 1
					
					local KnockbackHitbox = HitboxHandler.new()
					KnockbackHitbox.Instance = HumRP
					KnockbackHitbox.Size = Vector3.new(50, 50, 50)
					KnockbackHitbox.ResetCharactersList = true
					KnockbackHitbox.Ignore = { Character }
					KnockbackHitbox.onTouch = function(Victim)
						local VictimHumRP: BasePart = Victim.HumanoidRootPart
						local VictimHumanoid: Humanoid = Victim.Humanoid

						if iFramesService:HasiFrame(Victim, Tool.Name) then return end


						local Damage, DoFinisher = 4, false
						if HitStage == 3 and Victim == EnemyCharacter then
							Damage = VictimHumanoid.Health
							DoFinisher = true
						end


						DamageHandler:TakeDamage(Character, VictimHumanoid, Damage, nil, nil, false, true, false, true, DoFinisher, nil, nil)
						NewKnockback:Knockback(Victim, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 100000, 1), Velocity = HumRP.CFrame.UpVector * Knockback })
						RagdollHandler.ragdoll(VictimHumanoid, 2)
					end
					
					
					local FinisherAnimation = MoveAnims.Suiryu.whirlwinddrop.Finisher
					local FinisherTrack = AnimationService:getAnimationTrack(Character, FinisherAnimation)
					local FinisherEvents = {}
					
					FinisherEvents["hit1"] = FinisherTrack:GetMarkerReachedSignal("hit1"):Once(function()
						Knockback = 50
						KnockbackHitbox:Once()
						
						ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 4 })
						
						for RockValue = 1, 3 do
							local Position = {
								Seed = math.random(1, 8) + RockValue, 
								start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0, 0), 
								["end"] = Vector3.new(0, -25, 0), 
								amount = 4 + RockValue / 2, 
								nosound = true, 
								nosmoke = true
							}

							local minusValue = false
							if RockValue <= 2 then
								minusValue = {
									minus = 0
								}
							end

							Position.stronger = minusValue
							Position.sizemult = 0.35 * RockValue
							Position.size = 0.45 * RockValue

							ReplicateEffects_Set:FireAllClients('Ground Crater', Position)
						end
						
						ReplicateEffects_Set:FireAllClients("whirlwinddrop", { Stage = "FinisherGroundKicks", Char = Character, Scale = 2 })
					end)
					
					FinisherEvents["hit2"] = FinisherTrack:GetMarkerReachedSignal("hit2"):Once(function()
						Knockback = 75
						HitStage = 2
						
						KnockbackHitbox:Once()
						
						ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 7 })
						
						for RockValue = 1, 3 do
							local Position = {
								Seed = math.random(1, 8) + RockValue, 
								start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0, 0), 
								["end"] = Vector3.new(0, -25, 0), 
								amount = 5 + RockValue / 2, 
								nosound = true, 
								nosmoke = true
							}

							local minusValue = false
							if RockValue <= 2 then
								minusValue = {
									minus = 0
								}
							end

							Position.stronger = minusValue
							Position.sizemult = 0.45 * RockValue
							Position.size = 0.75 * RockValue

							ReplicateEffects_Set:FireAllClients('Ground Crater', Position)
						end
						
						ReplicateEffects_Set:FireAllClients("whirlwinddrop", { Stage = "FinisherGroundKicks", Char = Character, Scale = 3 })
					end)
					
					FinisherEvents["hit3"] = FinisherTrack:GetMarkerReachedSignal("hit3"):Once(function()
						KnockbackHitbox.Size += Vector3.new(15, 15, 15)
						Knockback = 100
						HitStage = 3
						
						KnockbackHitbox:Once()
						KnockbackHitbox:Destroy()
						
						ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 12, Last = 1 })
						
						for RockValue = 1, 3 do
							local Position = {
								Seed = math.random(1, 8) + RockValue, 
								start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0, 0), 
								["end"] = Vector3.new(0, -25, 0), 
								amount = 7 + RockValue / 2, 
								nosound = true, 
								nosmoke = true
							}

							local minusValue = false
							if RockValue <= 2 then
								minusValue = {
									minus = 0
								}
							end

							Position.stronger = minusValue
							Position.sizemult = 0.65 * RockValue
							Position.size = 0.95 * RockValue

							ReplicateEffects_Set:FireAllClients('Ground Crater', Position)
						end
						
						ReplicateEffects_Set:FireAllClients("whirlwinddrop", { Stage = "FinisherGroundKicks", Char = Character, Scale = 3.5 })
						ReplicateEffects_Set:FireClient(Player, "suiryupassiveaura", { Char = Character })
						
						if EnemyHumanoid.Health > 0 then
							EnemyHumanoid.Health = 0
						end
					end)
					
					FinisherTrack.Stopped:Once(function()
						for _,v in FinisherEvents do
							v:Disconnect()
						end
						
						
						StunHandler:Unstun(Character, Stun)
						iFramesService:RemoveAlliFrames(Character)
						Character:RemoveTag("CantRotate")
					end)
					
					
					AnimationService:stopAll(Character)
					AnimationService:playAnimation(Character, FinisherAnimation)
					
					SoundsModule:PlaySound(MoveSounds.Suiryu.whirlwinddrop.Finisher, HumRP)
				end
			end
			
			Hitbox:Once()
			Hitbox:Destroy()
			
			
			if not Finisher then
				local EndAnimation = MoveAnims.Suiryu.whirlwinddrop.End
				local EndTrack = AnimationService:getAnimationTrack(Character, EndAnimation)

				EndTrack.Stopped:Once(function()
					if not Finisher then
						StunHandler:Unstun(Character, Stun)
					end
				end)

				AnimationService:stopAll(Character)
				AnimationService:playAnimation(Character, EndAnimation)
			end
			
			for RockValue = 1, 3 do
				local Position = {
					Seed = math.random(1, 8) + RockValue, 
					start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0, 0), 
					["end"] = Vector3.new(0, -80, 0), 
					amount = 6 + RockValue / 2, 
					nosound = true, 
					nosmoke = RockValue > 2
				}

				local minusValue = false
				if RockValue <= 2 then
					minusValue = {
						minus = 0
					}
				end

				Position.stronger = minusValue
				Position.sizemult = 0.55 * RockValue
				Position.size = 0.85 * RockValue

				ReplicateEffects_Set:FireAllClients('Ground Crater', Position)
			end
			
			ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 15 })
			
			SoundsModule:PlaySound(MoveSounds.Suiryu.whirlwinddrop.GroundHit, GoalPos)
			SoundsModule:PlaySound(MoveSounds.Suiryu.whirlwinddrop.GroundExtra, GoalPos)
			SoundsModule:PlaySound(MoveSounds.Suiryu.whirlwinddrop.GroundExtra2, GoalPos)
		end)
		
		StartTrack.Stopped:Once(function()
			for _,v in StartEvents do
				v:Disconnect()
			end
			
			Bind:Destroy()
			
			
			if not WentDown then
				StunHandler:Unstun(Character, Stun)
			end
		end)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
		
		SoundsModule:PlaySound(MoveSounds.Suiryu.whirlwinddrop.Start, HumRP)
		ReplicateEffects_Set:FireAllClients("whirlwinddrop", { Stage = "VFX", Char = Character, AnimationId = StartAnimation.AnimationId })
		
		StatesHandler.SkillText(Player, "WHIRLWIND DROP [USED]")
	end
}