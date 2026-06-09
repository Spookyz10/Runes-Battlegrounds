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
local ReplicatedHitboxes = require(game.ServerStorage.Modules.ReplicatedHitboxes)


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
		local Tag = Player.UserId + os.clock()
		
		local RunBind = Instance.new("Accessory")
		RunBind.Name = "TackleRun" .. Tag
		RunBind.Parent = Character

		local function HitFunction(EnemyCharacter: Model)
			if not EnemyCharacter then return end

			local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
			local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

			if Hit == true or EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead or EnemyCharacter:HasTag("Ragdolled") then return end


			local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, nil, nil, false, true, true, true, false, nil, 15)
			if HitInfo.Countered == true then return end

			Hit = true
			RunBind:Destroy()

			local Finisher = HitInfo.Finisher == true
			local EnemyStun = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true)
			local Weld = WeldSystem.new(HumRP, EnemyHumRP, CFrame.new(0, 0, -3) * CFrame.Angles(0, rad(180), 0), 5)

			task.delay((Finisher and 0 or 0.25), function()
				Character:AddTag("CantRotate")
			end)
			EnemyCharacter:AddTag("CantRotate")

			if Finisher then
				iFramesService:AddAlliFrames(Character)
				iFramesService:AddAlliFrames(EnemyCharacter)
				
			else
				iFramesService:AddBaseiFrames(Character)
				iFramesService:AddBaseiFrames(EnemyCharacter)
				
			end


			local VictimAnim = MoveAnims.Okarun.tackle.Victim
			local HitAnim = MoveAnims.Okarun.tackle.Hit
			if Finisher then
				VictimAnim = MoveAnims.Okarun.tackle.VictimFinisher
				HitAnim = MoveAnims.Okarun.tackle.HitFinisher
			end
			
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


			
			local HitTrack = AnimationService:getAnimationTrack(Character, HitAnim)
			local HitEvents = {}

			if Finisher then
				HitEvents["1"] = HitTrack:GetMarkerReachedSignal("1"):Once(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, nil, nil, false, false, true, true, false, nil, nil)
					
					ReplicateEffects_Set:FireClient(Player, "turbotackle", { Stage = "SlideCut", Char = Character })
					SoundsModule:PlaySound(MoveSounds.Okarun.tackle.Finisher, HumRP)
					
					task.delay(0.117, function()
						ReplicateEffects_Set:FireAllClients("turbotackle", { Stage = "StartupImpact", Char = Character })
					end)
				end)
				
				HitEvents["Hit"] = HitTrack:GetMarkerReachedSignal("Hit"):Once(function()
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 4, nil, nil, false, false, true, true, false, nil, nil)
				end)
			end

			HitEvents["End"] = HitTrack:GetMarkerReachedSignal("End"):Once(function()
				if Weld then
					pcall(function()
						Weld:Stop()
					end)
					Weld = nil
				end
 
				pcall(function()
					AnimationService:stopAll(EnemyCharacter, 0)


					local lookVector = HumRP.CFrame.LookVector

					if Finisher == false then
						SoundsModule:PlaySound(MoveSounds.Okarun.tackle.Hit2, EnemyHumRP)
						
						require(ServerStorage.Modules.PerfectKnockback).KnockBack(nil, EnemyCharacter, {
							LookVector = HumRP.CFrame.LookVector,
							LookForce = 30,
							LookFinalForce = 50,
							EscapableCooldown = 5,
							UpVelocityTime = 0.2,
							LookAt = CFrame.lookAt((HumRP.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0,math.pi,0)).Position, HumRP.Position) ,
							UpVelocity = Vector3.new(0, 75, 0),
							DestroyRagdoll = true,
							GroundStunTime = 1.2,
							Escapable = true,
						}, Character)
					else
						RagdollHandler.ragdoll(EnemyHumanoid, 3, true, Character)
						NewKnockback:Knockback(EnemyCharacter, { KnockbackType = "Velocity", MaxForce = Vector3.new(100000, 100000, 100000), Velocity = lookVector * 500 + Vector3.new(0, 50, 0) })
						
						ReplicateEffects_Set:FireAllClients("turbotackle", { Stage = "FinisherImpact", Char = Character })
					end
				end)


				DamageHandler:TakeDamage(Character, EnemyHumanoid, (Finisher and EnemyHumanoid.Health or 8), nil, nil, false, false, true, true, true, nil, nil)
				

				if Finisher then
					Character:RemoveTag("CantRotate")
					StunHandler:Unstun(Character, Stun)
					iFramesService:RemoveAlliFrames(Character)
					
					return
				end
				
				local EndAnim = MoveAnims.Okarun.tackle.HitEnd
				local EndTrack = AnimationService:getAnimationTrack(Character, EndAnim)

				Character:RemoveTag("CantRotate")
				task.delay(0.25, function()
					if EndTrack.IsPlaying == true then
						Character:AddTag("CantRotate")
					end
				end)

				EndTrack.Stopped:Once(function()
					Character:RemoveTag("CantRotate")
					StunHandler:Unstun(Character, Stun)
				end)

				iFramesService:RemoveAlliFrames(Character)

				AnimationService:stopAll(Character, 0)
				AnimationService:playAnimation(Character, EndAnim)
				
				ReplicateEffects_Set:FireClient(Player, "turbotackle", { Stage = "SlideCut", Char = Character })
				ReplicateEffects_Set:FireClient(Player, "turbotackle", { Stage = "End", Char = Character })
			end)

			AnimationService:stopAll(Character)
			AnimationService:stopAll(EnemyCharacter)
			
			AnimationService:playAnimation(Character, HitAnim)
			AnimationService:playAnimation(EnemyCharacter, VictimAnim)

			ReplicateEffects_Set:FireClient(Player, "turbotackle", { Stage = "Hit", Char = Character })
			SoundsModule:PlaySound(MoveSounds.Okarun.tackle.Hit, EnemyHumRP)

			Weld:Start(nil, game.Players:GetPlayerFromCharacter(EnemyCharacter) or Player)
		end


		local MissAnim = MoveAnims.Okarun.tackle.Miss
		local MissTrack = AnimationService:getAnimationTrack(Character, MissAnim)
		local MissEvents = {}

		MissEvents["Hit"] = MissTrack:GetMarkerReachedSignal("Hit"):Once(function()
			Character:RemoveTag("cancelHitboxes")
			
			local DetectHitbox = ReplicatedHitboxes.new(Player)
			DetectHitbox.Size = Vector3.new(7, 7, 7)
			DetectHitbox.Offset = CFrame.new(0, 0, -3.5)
			DetectHitbox.Instance = HumRP
			DetectHitbox.Ignore = { Character }
			DetectHitbox.onTouch = function(EnemyCharacter)
				HitFunction(EnemyCharacter)
			end

			DetectHitbox:Start(0.9, true)
		end)

		MissTrack.Stopped:Once(function()
			for _,v in MissEvents do
				v:Disconnect()
			end

			if Hit == false then
				StunHandler:Unstun(Character, Stun)
				RunBind:Destroy()
			end
		end)

		local startHitbox = HitboxHandler.new()
		startHitbox.Instance = HumRP
		startHitbox.Size = Vector3.new(1, 1, 1) * 7
		startHitbox.Offset = CFrame.new(0, 0, -3.5)
		startHitbox.onTouch = function(EnemyCharacter: Model)
			HitFunction(EnemyCharacter)
		end

		startHitbox:Once()
		startHitbox:Destroy()

		if Hit == false then
			AnimationService:stopAll(Character, 0)
			AnimationService:playAnimation(Character, MissAnim)


			ReplicateEffects_Set:FireAllClients("turbotackle", { Char = Character, Stage = "Start", BindName = RunBind.Name })
			SoundsModule:PlaySound(MoveSounds.Okarun.tackle.Windup, HumRP)
		end
	end
}