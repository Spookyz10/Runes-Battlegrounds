local ServerStorage = game:GetService('ServerStorage') 
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



local Utility = shared.Utility
local WeldSystem = require(game.ReplicatedStorage.Modules.WeldSystem)


local Sounds = shared.SoundsFolder
local Animations = shared.AnimsFolder

local CombatAnims = game.ServerStorage.Assets.Animations.Combat
local CombatSounds = game.ServerStorage.Assets.Sounds.Combat

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
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 8, 0, true)
		local Hit, BarrageEnded = false, false
		local startTime = tick()
		local Tag = os.clock() + Player.UserId
		local LeavingConnections = {}
		
		local barrageHitbox = HitboxHandler.new()
		barrageHitbox.Size = Vector3.new(16, 16, 16)
		barrageHitbox.Instance = HumRP
		barrageHitbox.ResetCharactersList = true
		barrageHitbox.onTouch = function(EnemyCharacter)
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

			if EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end

			if tick() - startTime >= 0.1 then
				startTime = tick()

				DamageHandler:TakeDamage(Character, EnemyHumanoid, 1.75, 1, Animations.Combat.Hits[tostring(math.random(1, 4))], true, false, false, false, false, nil, nil)
				SoundsModule:PlaySound(MoveSounds.Okarun.tornado.BarrageHit, EnemyHumRP)
			end
		end
		
		local function ExtraHits()
			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(10, 10, 10)
			Hitbox.Offset = CFrame.new(0, 0, -5)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead or EnemyCharacter:HasTag("Ragdolled") then return end
				
				
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, 1, CombatAnims.Hits[tostring(math.random(1, 4))], true, false, false, false, true, nil, nil)
				if HitInfo.Blocked == true then
					SoundsModule:PlaySound(CombatSounds.Blocking.Hits:GetChildren()[math.random(1, #CombatSounds.Blocking.Hits:GetChildren())], EnemyHumRP)
					
					return
				end
				
				SoundsModule:PlaySound(MoveSounds.Okarun.tornado.BarrageHit, EnemyHumRP)
			end
			
			Hitbox:Once()
			Hitbox:Destroy()
			
			
			ReplicateEffects_Set:FireAllClients("turbotornado", { Stage = "ExtraHits", Char = Character })
		end
		
		local function EndFunction()
			for _,v in LeavingConnections do
				v:Disconnect()
			end

			
			if barrageHitbox then
				barrageHitbox:Destroy()
				barrageHitbox = nil
			end

			if Hit == false then
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
			end
		end
		
		
		local MissAnim = MoveAnims.Okarun.tornado.Miss
		local MissTrack = AnimationService:getAnimationTrack(Character, MissAnim)
		local MissEvents = {}
		
		MissEvents["Slap"] = MissTrack:GetMarkerReachedSignal("Slap"):Once(ExtraHits)
		MissEvents["Jump"] = MissTrack:GetMarkerReachedSignal("Jump"):Once(ExtraHits)
		MissEvents["Kick"] = MissTrack:GetMarkerReachedSignal("Kick"):Once(ExtraHits)
		MissEvents["Left"] = MissTrack:GetMarkerReachedSignal("Left"):Once(ExtraHits)
		MissEvents["Forward"] = MissTrack:GetMarkerReachedSignal("Forward"):Once(ExtraHits)
		MissEvents["Foward"] = MissTrack:GetMarkerReachedSignal("Foward"):Connect(ExtraHits)
		
		MissEvents["Start"] = MissTrack:GetMarkerReachedSignal("Start"):Once(function()
			ReplicateEffects_Set:FireAllClients("turbotornado", { Stage = "Start", Char = Character })
			
			barrageHitbox:Start()
			
			task.delay(2.1, function()
				if barrageHitbox then
					barrageHitbox:Destroy()
					barrageHitbox = nil
				end
			end)
		end)
		
		MissEvents["End"] = MissTrack:GetMarkerReachedSignal("End"):Once(function()
			BarrageEnded = true
			
			
			local Hitbox = HitboxHandler.new()
			Hitbox.Size = Vector3.new(16, 16, 16)
			Hitbox.Instance = HumRP
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = game.Players:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end

				Hit = true
				
				
				local VFXBind = Instance.new("Accessory")
				VFXBind.Name = "HurricaneDropkick" .. Tag
				VFXBind.Parent = Character


				StunHandler:Unstun(Character, Stun)
				Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)

				DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, nil, nil, false, false, true, false, false, nil, nil)
				
				AnimationService:stopAll(EnemyCharacter)
				AnimationService:stopAll(Character)
				
				iFramesService:AddAlliFrames(EnemyCharacter)
				
				Character:AddTag("CantRotate")
				EnemyCharacter:AddTag("CantRotate")
				
				
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, rad(180), 0), 9.25)
				
				
				local VictimAnim = MoveAnims.Okarun.tornado.Victim
				local VictimTrack = AnimationService:getAnimationTrack(EnemyCharacter, VictimAnim)
				
				VictimTrack.Stopped:Once(function()
					if Weld then
						pcall(function()
							Weld:Stop()
						end)
						Weld = nil
					end
					
					StunHandler:Unstun(EnemyCharacter, EnemyStun)
					iFramesService:RemoveAlliFrames(EnemyCharacter)
					EnemyCharacter:RemoveTag("CantRotate")
				end)
				
				
				local HitAnim = MoveAnims.Okarun.tornado.Hit
				local HitTrack = AnimationService:getAnimationTrack(Character, HitAnim)
				local HitEvents = {}
				
				HitEvents["CurveWind2"] = HitTrack:GetMarkerReachedSignal("CurveWind2"):Once(function()
					ReplicateEffects_Set:FireAllClients("turbotornado", { Stage = "CurveWind2", Char = Character })
				end)
				
				HitEvents["ft"] = HitTrack:GetMarkerReachedSignal("ft"):Once(function()
					ReplicateEffects_Set:FireAllClients("turbotornado", { Stage = "ft", Char = Character })
				end)
				
				HitEvents["Hit"] = HitTrack:GetMarkerReachedSignal("Hit"):Once(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 9, nil, nil, false, false, true, false, false, nil, nil)
					ReplicateEffects_Set:FireAllClients("turbotornado", { Stage = "Hit", Char = Character })
				end)
				
				HitEvents["Jump"] = HitTrack:GetMarkerReachedSignal("Jump"):Once(function()
					ReplicateEffects_Set:FireAllClients("turbotornado", { Stage = "Jump", Char = Character })
				end)
				
				HitEvents["Atmosphere"] = HitTrack:GetMarkerReachedSignal("Atmosphere"):Once(function()
					shared.fireTo(ReplicateEffects_Set, { Player, EnemyPlayer }, { "turbotornado", { Stage = "Atmosphere", Char = Character } })
				end)
				
				HitEvents["Aura"] = HitTrack:GetMarkerReachedSignal("Aura"):Once(function()
					ReplicateEffects_Set:FireAllClients("turbotornado", { Stage = "Aura", Char = Character, BindName = VFXBind.Name })
				end)
				
				HitEvents["End"] = HitTrack:GetMarkerReachedSignal("End"):Once(function()
					ReplicateEffects_Set:FireAllClients("turbotornado", { Stage = "End", Char = Character, EChar = EnemyCharacter })
				end)
				
				EndFunction = function()
					Debris:AddItem(VFXBind, 5)


					for _,v in HitEvents do
						v:Disconnect()
					end

					AnimationService:stopAll(EnemyCharacter, 0)


					DamageHandler:TakeDamage(Character, EnemyHumanoid, 9, nil, nil, false, false, true, false, true, nil, 12)
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 1, 1) * 100000, Velocity = HumRP.CFrame.LookVector * Vector3.new(50, 0, 50) + Vector3.new(0, 100, 0) })
					RagdollHandler.ragdoll(EnemyHumanoid, 3, true, Character)


					iFramesService:RemoveAlliFrames(Character)
					StunHandler:Unstun(Character, Stun)
					Character:RemoveTag("CantRotate")
				end
				HitTrack.Stopped:Once(EndFunction)
				
				HitTrack.Ended:Once(function()
					ReplicateEffects_Set:FireClient(Player, "fixspeedbug")
				end)
				
				
				AnimationService:playAnimation(Character, HitAnim)
				AnimationService:playAnimation(EnemyCharacter, VictimAnim)
				
				ReplicateEffects_Set:FireAllClients("turbotornado", { Stage = "FirstHit", Char = Character, EChar = EnemyCharacter })
				
				Weld:Start(nil, game.Players:GetPlayerFromCharacter(EnemyCharacter) or Player)
				
				
				if EnemyPlayer then
					table.insert(LeavingConnections, EnemyPlayer.Destroying:Once(EndFunction))
				end
			end
			
			Hitbox:Once()
			Hitbox:Destroy()
			
			
			if not Hit then
				SoundsModule:PlaySound(MoveSounds.Okarun.tornado.Miss, HumRP)
			end
		end)
		
		MissTrack.Stopped:Once(EndFunction)
		
		
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, MissAnim)
		
		SoundsModule:PlaySound(MoveSounds.Okarun.tornado.Miss, HumRP)
		
		iFramesService:AddAlliFrames(Character)
		
		
		table.insert(LeavingConnections, Player.Destroying:Once(EndFunction))
	end
}