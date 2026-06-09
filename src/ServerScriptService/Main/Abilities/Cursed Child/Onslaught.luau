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
local SoundHandler = require(ReplicatedModules.SoundHandler)
local CFrameFollower = require(ReplicatedStorage.Modules.Game.GrabHandler)

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
MapRayParams.FilterDescendantsInstances = { workspace.Map }
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart
		
		
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		
		
		local StartAnimation = MoveAnims["Cursed Child"].Onslaught.NormalWindup
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}
		
		
		local Hit = false


		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.MaxForce = Vector3.new(100000, 0, 100000)
		BodyVelocity.Name = "moveme"
		BodyVelocity:SetAttribute("End", 1)
		BodyVelocity:SetAttribute("Fallout", 0.91)
		BodyVelocity:SetAttribute("Goto", 40)
		BodyVelocity:SetAttribute("Speed", 60)


		StartEvents["jump"] = StartTrack:GetMarkerReachedSignal("jump"):Once(function()
			BodyVelocity.Parent = HumRP

		end)

		StartEvents["land"] = StartTrack:GetMarkerReachedSignal("land"):Once(function()
			BodyVelocity:Destroy()


			local HitboxConnection = ReplicatedHitbox.new(Player)
			HitboxConnection.Instance = HumRP
			HitboxConnection.Size = Vector3.new(8, 8, 8)
			HitboxConnection.Offset = CFrame.new(0, 0, -3.5)
			HitboxConnection.Ignore = { Character }
			HitboxConnection.destroyAfterOnce = true
			HitboxConnection.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid


				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead or EnemyCharacter:HasTag("Ragdolled") then return end
				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, 1, CombatAnims.Hits[tostring(math.random(1, 4))], false, false, true, true, false, nil)
				

				Hit = true

				if BodyVelocity then
					BodyVelocity:Destroy()
				end


				local UserAnimation = MoveAnims["Cursed Child"].Onslaught.NormalHit
				local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
				local UserEvents = {}


				for _, conn in UserEvents do
					if typeof(conn) == "RBXScriptConnection" then
						conn:Disconnect()
					end
				end
				table.clear(UserEvents)


				local Velocity = HumRP.CFrame.LookVector * 45


				local KickStage = 1
				local KickStageSecond = 1
				local SwingStage = 1
				local SlashStage = 1
				local StabStage = 1
				
				
				local container2 = {}
				local assets2 = {}
				
				
				local function HandleVelocityForEnemy(Params)
					for _, existingVel in pairs(container2) do
						existingVel:Destroy()
					end

					local BodyVelocity = Instance.new("BodyVelocity")

					table.insert(assets2, BodyVelocity)
					table.insert(container2, BodyVelocity)

					BodyVelocity.Name = "moveme"
					BodyVelocity.MaxForce = Vector3.new(40000, 0, 40000, 0)
					BodyVelocity:SetAttribute("Speed", Params.speed or 100)
					BodyVelocity:SetAttribute("Fallout", Params.fallout or 0.95)
					BodyVelocity:SetAttribute("End", Params.endd or 5)
					BodyVelocity.Parent = EnemyCharacter.PrimaryPart

					game.Debris:AddItem(BodyVelocity, Params.deletiontime or 5)
				end
				
				
				
				local StabHitbox = HitboxHandler.new()
				StabHitbox.Instance = HumRP
				StabHitbox.Ignore = { Character }
				StabHitbox.Size = Vector3.new(1, 1, 1) * 10
				StabHitbox.Offset = CFrame.new(0, 0, -3.5)
				StabHitbox.onTouch = function(EnemyCharacter)
					if EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter.Humanoid.Health <= 0 then return end


					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, 1, CombatAnims.Hits[tostring(math.random(1, 4))], false, false, true, true, true, nil)
					ReplicateEffects_Set:FireAllClients("Onslaught", { Stage = "StabHit", Char = EnemyCharacter })
					HandleVelocityForEnemy({ speed = 65, fallout = 0.9, endd = 4, deletiontime = 0.2 })
				end

				local KickHitbox = HitboxHandler.new()
				KickHitbox.Instance = HumRP
				KickHitbox.Ignore = { Character }
				KickHitbox.Size = Vector3.new(1, 1, 1) * 10
				KickHitbox.Offset = CFrame.new(0, 0, -3.5)
				KickHitbox.onTouch = function(EnemyCharacter)
					if EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter.Humanoid.Health <= 0 then return end


					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 2, 1, CombatAnims.Hits[tostring(math.random(1, 4))], false, false, true, true, true, nil)
					HandleVelocityForEnemy({ speed = 80, fallout = 0.9, endd = 5, deletiontime = 0.3 })
				end

				local KickHitbox2 = HitboxHandler.new()
				KickHitbox2.Instance = HumRP
				KickHitbox2.Ignore = { Character }
				KickHitbox2.Size = Vector3.new(1, 1, 1) * 10
				KickHitbox2.Offset = CFrame.new(0, 0, -3.5)
				KickHitbox2.onTouch = function(EnemyCharacter)
					if EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter.Humanoid.Health <= 0 then return end


					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, 1, CombatAnims.Hits[tostring(math.random(1, 4))], false, false, true, true, true, nil)
					
					
					require(ServerStorage.Modules.PerfectKnockback).KnockBack(nil, EnemyCharacter, {
						LookVector = HumRP.CFrame.LookVector,
						LookForce = 30,
						LookFinalForce = 50,
						EscapableCooldown = 5,
						UpVelocityTime = 0.2,
						LookAt = CFrame.lookAt((HumRP.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0,math.pi,0)).Position, HumRP.Position) ,
						UpVelocity = Vector3.new(0, 40, 0),
						DestroyRagdoll = true,
						GroundStunTime = 1.2,
						Escapable = true,
					}, Character)
					
					
					for _,v in assets2 do
						if v and v.Parent then
							v:Destroy()
						end
					end
				end

				local KickSwingHitbox = HitboxHandler.new()
				KickSwingHitbox.Instance = HumRP
				KickSwingHitbox.Ignore = { Character }
				KickSwingHitbox.Size = Vector3.new(1, 1, 1) * 10
				KickSwingHitbox.Offset = CFrame.new(0, 0, -3.5)
				KickSwingHitbox.onTouch = function(EnemyCharacter)
					if EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter.Humanoid.Health <= 0 then return end


					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, 1, CombatAnims.Hits[tostring(math.random(1, 4))], false, false, true, true, true, nil)
					HandleVelocityForEnemy({ speed = 60, fallout = 0.9, endd = 4, deletiontime = 0.2 })
				end

				local SlamHitbox = HitboxHandler.new()
				SlamHitbox.Instance = HumRP
				SlamHitbox.Ignore = { Character }
				SlamHitbox.Size = Vector3.new(1, 1, 1) * 10
				SlamHitbox.Offset = CFrame.new(0, 0, -3.5)
				SlamHitbox.onTouch = function(EnemyCharacter)
					if EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter.Humanoid.Health <= 0 then return end


					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 1, 1, CombatAnims.Hits[tostring(math.random(1, 4))], false, false, true, true, true, nil)
					ReplicateEffects_Set:FireAllClients("Onslaught", { Stage = "Smack", Char = EnemyCharacter })
					HandleVelocityForEnemy({ speed = 60, fallout = 0.9, endd = 4, deletiontime = 0.2 })
				end


				local SlashHitbox = HitboxHandler.new()
				SlashHitbox.Instance = HumRP
				SlashHitbox.Ignore = { Character }
				SlashHitbox.Size = Vector3.new(1, 1, 1) * 10
				SlashHitbox.Offset = CFrame.new(0, 0, -3.5)
				SlashHitbox.onTouch = function(EnemyCharacter)
					if EnemyCharacter == Character or iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter.Humanoid.Health <= 0 then return end


					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
					local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
					local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, 1, CombatAnims.Hits[tostring(math.random(1, 4))], false, false, true, true, true, nil)
					ReplicateEffects_Set:FireAllClients("Onslaught", { Stage = "SlashHit", Char = EnemyCharacter })
					HandleVelocityForEnemy({ speed = 65, fallout = 0.9, endd = 4, deletiontime = 0.2 })
				end


				local container = {}
				local assets = {}

				local function HandleVelocity(Params)
					for _, existingVel in pairs(container) do
						existingVel:Destroy()
					end

					local BodyVelocity = Instance.new("BodyVelocity")

					table.insert(assets, BodyVelocity)
					table.insert(container, BodyVelocity)

					BodyVelocity.Name = "moveme"
					BodyVelocity.MaxForce = Vector3.new(40000, 0, 40000, 0)
					BodyVelocity:SetAttribute("Speed", Params.speed or 100)
					BodyVelocity:SetAttribute("Fallout", Params.fallout or 0.95)
					BodyVelocity:SetAttribute("End", Params.endd or 5)
					BodyVelocity.Parent = Character.PrimaryPart

					game.Debris:AddItem(BodyVelocity, Params.deletiontime or 5)
				end


				UserEvents["stab"] = UserTrack:GetMarkerReachedSignal("stab"):Connect(function()
					ReplicateEffects_Set:FireAllClients("Onslaught", { Stage = "Stab", Char = Character })

					HandleVelocity({ speed = 65, fallout = 0.9, endd = 4, deletiontime = 0.2 })

					if StabStage == 1 then
						StabStage = 2

						StabHitbox:Once()
					else
						StabHitbox:Once()
						StabHitbox:Destroy()
					end
				end)

				UserEvents["kick"] = UserTrack:GetMarkerReachedSignal("kick"):Connect(function()
					ReplicateEffects_Set:FireAllClients("Onslaught", { Stage = "Kick", Char = Character })

					HandleVelocity({ speed = 80, fallout = 0.9, endd = 5, deletiontime = 0.3 })

					if KickStage == 1 then
						KickStage = 2

						KickHitbox:Once()
						KickHitbox:Destroy()
					else
						KickHitbox2:Once()
						KickHitbox2:Destroy()
					end
				end)

				UserEvents["kickswing"] = UserTrack:GetMarkerReachedSignal("kickswing"):Connect(function()
					HandleVelocity({ speed = 60, fallout = 0.9, endd = 4, deletiontime = 0.2 })

					if SwingStage == 1 then
						SwingStage = 2
						KickSwingHitbox:Once()

						ReplicateEffects_Set:FireAllClients("Onslaught", { Stage = "KickSwing", Char = Character, Kick = 1 })
					else
						KickSwingHitbox:Once()
						KickSwingHitbox:Destroy()

						ReplicateEffects_Set:FireAllClients("Onslaught", { Stage = "KickSwing", Char = Character, Kick = 2 })
					end
				end)

				UserEvents["slash"] = UserTrack:GetMarkerReachedSignal("slash"):Connect(function()
					HandleVelocity({ speed = 65, fallout = 0.9, endd = 4, deletiontime = 0.2 })

					if SlashStage == 1 then
						SlashHitbox:Once()
						SlashStage = 2

						ReplicateEffects_Set:FireAllClients("Onslaught", { Stage = "Slash", Char = Character, Slash = 1 })
					else
						SlashHitbox:Once()
						SlashHitbox:Destroy()
						ReplicateEffects_Set:FireAllClients("Onslaught", { Stage = "Slash", Char = Character, Slash = 2 })
					end
				end)

				UserEvents["slam"] = UserTrack:GetMarkerReachedSignal("slam"):Connect(function()
					ReplicateEffects_Set:FireAllClients("Onslaught", { Stage = "Slam", Char = Character })

					HandleVelocity({ speed = 60, fallout = 0.9, endd = 4, deletiontime = 0.2 })

					SlamHitbox:Once()
					SlamHitbox:Destroy()
				end)


				UserEvents["Stopped"] = UserTrack.Stopped:Once(function()
					for _, conn in UserEvents do
						conn:Disconnect()
					end
					table.clear(UserEvents)

					StunHandler:Unstun(Character, Stun)

					for _,v in assets do
						if v and v.Parent then
							v:Destroy()
						end
					end
					
					for _,v in assets2 do
						if v and v.Parent then
							v:Destroy()
						end
					end
				end)


				AnimationService:stopAll(EnemyCharacter)
				AnimationService:stopAll(Character)
				AnimationService:playAnimation(Character, UserAnimation)
			end

			HitboxConnection:Once()
		end)


		StartTrack.Stopped:Once(function()
			for _,v in StartEvents do
				v:Disconnect()
			end

			if not Hit then
				StunHandler:Unstun(Character, Stun)
			end
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)

		ReplicateEffects_Set:FireAllClients("Onslaught", { Stage = "Windup", Char = Character, WindupAnim = StartAnimation.AnimationId })
	end
}