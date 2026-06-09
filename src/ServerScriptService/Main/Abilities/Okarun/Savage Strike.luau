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
		local CounterConnection
		local Tag = os.clock() + Player.UserId
		
		local VFXBind = Instance.new("Accessory")
		VFXBind.Name = "TurboSavage" .. Tag
		VFXBind.Parent = Character
		
		local startTime = tick()
		local barrageHitbox = HitboxHandler.new()
		barrageHitbox.Size = Vector3.new(18.587, 19.91, 34.455)
		barrageHitbox.Instance = HumRP
		barrageHitbox.ResetCharactersList = true
		barrageHitbox.onTouch = function(EnemyCharacter)
			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

			if EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 then return end

			if tick() - startTime >= 0.1 then
				startTime = tick()

				DamageHandler:TakeDamage(Character, EnemyHumanoid, 1.75, 1, game.ServerStorage.Assets.Animations.Combat.Hits[tostring(math.random(1, 4))], false, false, false, false, true, nil, nil)	
				SoundsModule:PlaySound(MoveSounds.Okarun.savage.BarrageHit, EnemyHumRP)
			end
		end
		
		
		local MissAnim = MoveAnims.Okarun.savage.Miss
		local MissTrack = AnimationService:getAnimationTrack(Character, MissAnim)
		local MissEvents = {}
		
		MissEvents["Hit"] = MissTrack:GetMarkerReachedSignal("Hit"):Once(function()
			local Hitbox = HitboxHandler.new()
			Hitbox.Size = Vector3.new(18.587, 19.91, 34.455)
			Hitbox.Instance = HumRP
			Hitbox.Offset = CFrame.new(0, 0, -Hitbox.Size.Z / 2.5)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if Hit == true or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 then return end
				Hit = true


				DamageHandler:TakeDamage(Character, EnemyHumanoid, 14, nil, nil, false, false, true, false, false, nil, nil)
				
				AnimationService:stopAll(Character, 0)
				AnimationService:stopAll(EnemyCharacter, 0)
				
				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)
				
				Character:AddTag("CantRotate")
				EnemyCharacter:AddTag("CantRotate")
				
				
				local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)				
				local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, 0) * CFrame.Angles(0, rad(180), 0), 6)
				
				
				local VictimAnim = MoveAnims.Okarun.savage.Victim
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
				
				
				local HitAnim = MoveAnims.Okarun.savage.Hit
				local HitTrack = AnimationService:getAnimationTrack(Character, HitAnim)
				local HitEvents = {}
				
				HitEvents["End"] = HitTrack:GetMarkerReachedSignal("End"):Once(function()
					AnimationService:stopAll(EnemyCharacter, 0)
					
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 14, nil, nil, false, false, true, false, true, nil, 18)
					NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(1, 1, 1) * 100000, Velocity = HumRP.CFrame.LookVector * Vector3.new(200, 0, 200) + Vector3.new(0, 75, 0) })
					RagdollHandler.ragdoll(EnemyHumanoid, 2, true, Character)
				end)
				
				HitTrack.Stopped:Once(function()
					for _,v in HitEvents do
						v:Disconnect()
					end
					
					StunHandler:Unstun(Character, Stun)
					iFramesService:RemoveAlliFrames(Character)
					Character:RemoveTag("CantRotate")
					HumRP.CFrame *= CFrame.Angles(0, rad(180), 0)
					Character:SetAttribute("MuteMusic", false)
					
					VFXBind:Destroy()
				end)
				
				
				AnimationService:playAnimation(Character, HitAnim)
				AnimationService:playAnimation(EnemyCharacter, VictimAnim)
				
				ReplicateEffects_Set:FireAllClients("turbosavage", { Stage = "Hit", Char = Character, EChar = EnemyCharacter })
				
				Weld:Start(nil, game.Players:GetPlayerFromCharacter(EnemyCharacter) or Player)
			end

			Hitbox:Once()
			Hitbox:Destroy()
		end)
		
		MissTrack.Stopped:Once(function()
			for _,v in MissEvents do
				v:Disconnect()
			end
			
			if barrageHitbox then
				barrageHitbox:Destroy()
				barrageHitbox = nil
			end
			
			if Hit == false then
				Character:SetAttribute("MuteMusic", false)
				StunHandler:Unstun(Character, Stun)
				iFramesService:RemoveAlliFrames(Character)
				
				VFXBind:Destroy()
			end
		end)
		
		
		AnimationService:stopAll(Character, 0)
		AnimationService:playAnimation(Character, MissAnim)
		
		Character:SetAttribute("MuteMusic", true)
		
		ReplicateEffects_Set:FireAllClients("turbosavage", { Stage = "Start", Char = Character, BindName = VFXBind.Name })
		SoundsModule:PlaySound(MoveSounds.Okarun.savage.Startup, HumRP)
		
		iFramesService:AddAlliFrames(Character)
		
		task.delay(5, function()
			if barrageHitbox then
				barrageHitbox:Start()
				
				task.delay(2.2, function()
					if barrageHitbox then
						barrageHitbox:Destroy()
						barrageHitbox = nil
					end
				end)
			end
		end)
	end
}