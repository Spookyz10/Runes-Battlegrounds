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
		

		local Stun = StunHandler:Stun(Character, nil, true, 6, 0, true)
		local Hit, StoppedBeforeEnd, Finished, AddedBaseiFrames, Ended = false, true, nil, false, false
		local BarrageCount, GrabCount = 0, 0
		local Assets, BarrageHits, GrabHits = {}, {}, {}
		local Tag = os.clock() + Player.UserId
		local EndFunction
		
		local UserAnimation = MoveAnims.Suiryu.bulletbarrage.User
		local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
		local UserEvents = {}
		
		local VFXBind = Instance.new("Accessory")
		VFXBind.Name = "BulletBarrage" .. Tag
		VFXBind.Parent = Character
		
		local BarrageHitbox = HitboxHandler.new()
		BarrageHitbox.Instance = HumRP
		BarrageHitbox.Size = Vector3.new(7, 7, 7)
		BarrageHitbox.Offset = CFrame.new(0, 0, -3.5)
		BarrageHitbox.Ignore = { Character }
		BarrageHitbox.ResetCharactersList = true
		BarrageHitbox.onTouch = function(EnemyCharacter)
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

			if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end


			local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, 1, CombatAnims.Hits[tostring(math.random(1, 4))], true, true, false, true, false, nil, nil)
			if HitInfo.Blocked == true then
				SoundsModule:PlaySound(CombatSounds.Hits.Blocked, EnemyHumRP)

				return

			elseif HitInfo.Countered == true then
				return

			end

			
			if not BarrageHits[EnemyCharacter] and BarrageCount < 10 then
				BarrageHits[EnemyCharacter] = SoundsModule:PlaySound(MoveSounds.Suiryu.bulletbarrage.Barrage, EnemyHumRP)
			end
		end
		
		local GrabHitbox = HitboxHandler.new()
		GrabHitbox.Instance = HumRP
		GrabHitbox.Size = Vector3.new(8, 8, 8)
		GrabHitbox.Offset = CFrame.new(0, 0, -4)
		GrabHitbox.Ignore = { Character }
		GrabHitbox.ResetCharactersList = true
		GrabHitbox.onTouch = function(EnemyCharacter)
			local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

			if (iFramesService:HasiFrame(EnemyCharacter, Tool.Name) and not GrabHits[EnemyCharacter]) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end


			local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 2.5, nil, nil, false, true, false, true, false, nil, 20)
			if HitInfo.Countered == true then
				return

			end
			
			if not GrabHits[EnemyCharacter] and GrabCount < 4 then
				GrabHits[EnemyCharacter] = {}


				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, nil, true)
				end

				
				iFramesService:AddBaseiFrames(EnemyCharacter)
				EnemyCharacter:AddTag("CantRotate")
				
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0), 2)
				GrabHits[EnemyCharacter].Weld = Weld
				GrabHits[EnemyCharacter].Stun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)


				AnimationService:stopAll(EnemyCharacter)
				AnimationService:playAnimation(EnemyCharacter, MoveAnims.Suiryu.bulletbarrage.Victim)
				AnimationService:getAnimationTrack(EnemyCharacter, MoveAnims.Suiryu.bulletbarrage.Victim).TimePosition = UserTrack.TimePosition - 1.333

				Weld:Start(nil, game.Players:GetPlayerFromCharacter(EnemyCharacter) or Player)
				
			elseif GrabCount >= 4 then
				local Weld = GrabHits[EnemyCharacter].Weld
				if Weld then
					pcall(function()
						Weld:Stop()
					end)
					GrabHits[EnemyCharacter].Weld = nil
				end
				
				if HitInfo.Finisher == true and not Finished then
					Finished = EnemyCharacter
					
					Character:SetAttribute("PurpleFinisher", true)
					
					AnimationService:stopAll(Character)
					AnimationService:stopAll(EnemyCharacter)
					
					iFramesService:AddAlliFrames(Character)
					iFramesService:AddAlliFrames(EnemyCharacter)
					
					
					local EnemyStun = GrabHits[EnemyCharacter].Stun
					Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, 0) * CFrame.Angles(0, math.pi, 0), 6)
					
					
					shared.StartAirDetection(Character, nil, false, -10)
					
					local function LandedFunction()
						Character:SetAttribute("SkateLand", true)

						AnimationService:stopAll(Character)
						AnimationService:stopAll(EnemyCharacter)


						local UserFinisherEndAnimation = MoveAnims.Suiryu.bulletbarrage.UserFinisherEnd
						local UserFinisherEndTrack = AnimationService:getAnimationTrack(Character, UserFinisherEndAnimation)
						local UserFinisherEndEvents = {}

						UserFinisherEndEvents["1"] = UserFinisherEndTrack:GetMarkerReachedSignal("1"):Once(function()
							
						end)

						UserFinisherEndEvents["2"] = UserFinisherEndTrack:GetMarkerReachedSignal("2"):Once(function()
							if Weld then
								pcall(function()
									Weld:Stop()
								end)
								Weld = nil
							end

							if EnemyStun then
								StunHandler:Unstun(EnemyCharacter, EnemyStun)
							end

							iFramesService:RemoveAlliFrames(EnemyCharacter)
							CollisionsModule:SetCollisionGroup(EnemyCharacter, "Players")

							DamageHandler:TakeDamage(Character, EnemyHumanoid, EnemyHumanoid.Health, nil, nil, false, false, true, true, true, nil, nil)
							
							shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 8 } })
							SoundHandler:AddSound(MoveSounds.Suiryu.bulletbarrage.FinisherSlam, EnemyCharacter.Torso)
							ReplicateEffects_Set:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = HumRP.Position + Vector3.new(0, 0.10000000149011612, 0), ["end"] = Vector3.new(0, -80, 0), amount = 6, nosound = false, size = 1.4 })
							ReplicateEffects_Set:FireClient(Player, "suiryupassiveaura", { Char = Character })
						end)

						UserFinisherEndTrack.Stopped:Once(function()
							Character:SetAttribute("SkateLand", nil)

							EndFunction(true)
						end)


						AnimationService:playAnimation(Character, UserFinisherEndAnimation)
						AnimationService:playAnimation(EnemyCharacter, MoveAnims.Suiryu.bulletbarrage.VictimFinisherEnd)
						
						ReplicateEffects_Set:FireAllClients('RockTrail', { parent = HumRP, size = 1.5, side = 0.75, t = 5, height = 5, spawnrate = 0.075, duration = 1 })
						ReplicateEffects_Set:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = EnemyHumRP, ["end"] = Vector3.new(0, -17, 0), Crater2 = true })
						
						SoundsModule:PlaySound(MoveSounds.Suiryu.bulletbarrage.FinisherLand, HumRP)
					end
					
					local inAir: BoolValue = Character:FindFirstChild("inAir")
					if not inAir then
						LandedFunction()
						
					else
						inAir.Destroying:Once(LandedFunction)
						
					end
					
					
					AnimationService:playAnimation(Character, MoveAnims.Suiryu.bulletbarrage.UserFinisher)
					AnimationService:playAnimation(EnemyCharacter, MoveAnims.Suiryu.bulletbarrage.VictimFinisher)
					
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "ShakeCamera", { Intensity = 4 } })
					SoundsModule:PlaySound(MoveSounds.Suiryu.bulletbarrage.FinisherStart, HumRP)
					
					Weld:Start()
					
				else
					AnimationService:stopAll(EnemyCharacter)


					local GoalPos = EnemyHumRP.Position - Vector3.new(0, 50, 0)
					local GroundRay = workspace:Raycast(EnemyHumRP.Position, Vector3.new(0, -50, 0), MapRayParams)
					if GroundRay then
						GoalPos = GroundRay.Position
					end

					local GoalCF = CFrame.new(GoalPos) * CFrame.Angles(0, Random.new():NextNumber(0, math.pi * 2), 0)


					local EnemyStun = StunHandler:Stun(EnemyCharacter)

					local EndAnimation = MoveAnims.Suiryu.bulletbarrage.VictimEnd
					local EndTrack = AnimationService:getAnimationTrack(EnemyCharacter, EndAnimation)

					EndTrack.Stopped:Once(function()
						local KnockbackAnimation = Animations.Other.Knockback
						local KnockbackTrack = AnimationService:getAnimationTrack(EnemyCharacter, KnockbackAnimation)
						local KnockbackEvents = {}


						local BodyVelocity = NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "VelocityTweenDown", MaxForce = Vector3.new(math.huge, 0, math.huge), Velocity = EnemyHumRP.CFrame.LookVector * -300, Time = 0.6, Style = "Quad" })
						ReplicateEffects_Set:FireAllClients('RockTrail', { parent = EnemyHumRP, size = .5, side = 2, t = 3, height = 5, spawnrate = .1, duration = 0.6 })


						local landed, impact
						local function landedFunction()
							if landed then landed:Disconnect() landed = nil end
							if impact then impact:Disconnect() impact = nil end

							if BodyVelocity.Parent then
								BodyVelocity:Destroy()
							end

							StunHandler:Unstun(EnemyCharacter, EnemyStun)
							EnemyCharacter:RemoveTag("CantRotate")
							EnemyCharacter:RemoveTag("Knockbacked")
						end

						impact = KnockbackTrack:GetMarkerReachedSignal("impact"):Once(function()
							SoundsModule:PlaySound(Sounds.Other.Collapse, EnemyHumRP)
						end)
						landed = KnockbackTrack:GetMarkerReachedSignal("landed"):Once(landedFunction)
						KnockbackTrack.Stopped:Once(landedFunction)


						EnemyCharacter:AddTag("Knockbacked")

						AnimationService:stopAll(EnemyCharacter)
						AnimationService:playAnimation(EnemyCharacter, KnockbackAnimation)
					end)


					EnemyCharacter:PivotTo(GoalCF)

					AnimationService:playAnimation(EnemyCharacter, EndAnimation)

					SoundsModule:PlaySound(MoveSounds.Suiryu.bulletbarrage.Floor, GoalPos)
					SoundsModule:PlaySound(MoveSounds.Suiryu.bulletbarrage.Explosion, GoalPos)

					ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 8 })
					
					for randomNum = 1, 2 do
						ReplicateEffects_Set:FireAllClients('Ground Crater',{ Seed = math.random(1, 2000000000), start = EnemyHumRP.Position + Vector3.new(0, 0.10000000149011612, 0, 0), ["end"] = Vector3.new(0, -25, 0, 0), amount = randomNum == 1 and 6 or 9, nosound = true, nosmoke = randomNum == 2, size = randomNum == 1 and 0.3 or 1.4 })
					end
					
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, nil, nil, false, false, false, true, false, nil, nil)
				end
			end
			
			SoundsModule:PlaySound(MoveSounds.Suiryu.bulletbarrage["Hit" .. tostring(GrabCount)], EnemyHumRP)
		end
		
		EndFunction = function(Bypass)
			for _, v in BarrageHits do
				v:Destroy()
			end
			
			if VFXBind then
				VFXBind:Destroy()
				VFXBind = nil
			end
			if BarrageHitbox then
				BarrageHitbox:Destroy()
				BarrageHitbox = nil
			end
			if GrabHitbox then
				GrabHitbox:Destroy()
				GrabHitbox = nil
			end
			
			
			if Ended or (Finished ~= nil and not Bypass) then return end
			Ended = true
			
			
			for _, v in UserEvents do
				v:Disconnect()
			end

			if StoppedBeforeEnd then
				for _, v in Assets do
					if not v.Parent then continue end

					v:Destroy()
				end
			end

			if AddedBaseiFrames then
				iFramesService:RemoveAlliFrames(Character)
			end
			
			if GrabCount > 0 then
				for EnemyCharacter: Model, v in GrabHits do
					if EnemyCharacter == Finished then continue end
					
					if v.Weld then
						pcall(function()
							v.Weld:Stop()
						end)
						v.Weld = nil
					end

					if v.Stun then
						StunHandler:Unstun(EnemyCharacter, v.Stun)
						v.Stun = nil
					end

					iFramesService:RemoveAlliFrames(EnemyCharacter)
				end
			end

			if not Hit then
				StunHandler:Unstun(Character, Stun)
			end
		end
		
		
		
		UserEvents["barhit"] = UserTrack:GetMarkerReachedSignal("barhit"):Connect(function()
			BarrageCount += 1
			
			
			local HitTable = BarrageHitbox:Once()
			
			for EnemyCharacter: Model, Sound: Sound in BarrageHits do
				if not table.find(HitTable, EnemyCharacter) then
					Sound:Destroy()
					
					BarrageHits[EnemyCharacter] = nil
					
				end
			end
		end)
		
		for i = 1, 4 do
			local EventName = "hit" .. i
			
			UserEvents[EventName] = UserTrack:GetMarkerReachedSignal(EventName):Connect(function()
				for _, v in BarrageHits do
					v:Destroy()
				end
				
				
				GrabCount += 1
				
				GrabHitbox:Once()
				
				if GrabCount >= 4 then
					for EnemyCharacter: Model, v in GrabHits do 
						if Finished == EnemyCharacter then continue end
						
						
						if v.Weld then
							pcall(function()
								v.Weld:Stop()
							end)
							v.Weld = nil
						end
						
						if v.Stun then
							StunHandler:Unstun(EnemyCharacter, v.Stun)
							v.Stun = nil
						end
						
						iFramesService:RemoveAlliFrames(EnemyCharacter)
					end
				end
				
				
				if not AddedBaseiFrames then
					for _,v in GrabHits do
						iFramesService:AddBaseiFrames(Character)
						AddedBaseiFrames = true
						
						break
					end
				end
				
				
				ReplicateEffects_Set:FireClient(Player, "bulletbarrage", { Stage = "Knockback" .. i, Char = Character, Finisher = Finished ~= nil })
			end)
		end
		
		UserEvents["end"] = UserTrack:GetMarkerReachedSignal("end"):Once(EndFunction)
		UserTrack.Stopped:Once(EndFunction)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
		
		
		ReplicateEffects_Set:FireAllClients("bulletbarrage", { Stage = "Barrage", Char = Character, BindName = VFXBind.Name })
		
		task.delay(2.25, function()
			StoppedBeforeEnd = false
		end)
		
		table.insert(Assets, SoundsModule:PlaySound(MoveSounds.Suiryu.bulletbarrage.Miss, HumRP))
		
		StatesHandler.SkillText(Player, "BULLET BARRAGE [USED]")
	end
}