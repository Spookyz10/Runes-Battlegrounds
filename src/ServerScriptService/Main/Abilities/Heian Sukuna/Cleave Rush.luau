local TweenService = game:GetService("TweenService")
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
local CollisionsModule = require(ServerModules.CollisionsModule)
local SoundsModule = require(ServerModules.SoundsModule)

local Trove = require(ReplicatedModules.Trove)

local Sounds = ServerStorage.Assets.Sounds
local Animations = ServerStorage.Assets.Animations
local MoveAnims = Animations.Moves
local MoveSounds = Sounds.Moves

local ReplicateEffects_Set = RemotesContainer.Replicate.Set

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

		local StartAnimation = MoveAnims.Heian["Rush"].Cast
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}

		local leapVelocity = Instance.new("BodyVelocity")
		leapVelocity.MaxForce = Vector3.new(1000000, 1000000, 1000000)
		leapVelocity.Name = "SmallMoveVel"

		StartEvents["Lunge"] = StartTrack:GetMarkerReachedSignal("Lunge"):Once(function()
			leapVelocity.Velocity = HumRP.CFrame.LookVector * 92
			leapVelocity.Parent = HumRP

			-- [[ VFX ]]:
			ReplicateEffects_Set:FireAllClients("HeianRush", { char = Character, stage = "Lunge" })

			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP
			Hitbox.Ignore = { Character }
			Hitbox.Size = Vector3.new(8, 8, 10)
			Hitbox.Offset = CFrame.new(0, 0, -5)
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart

				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) or EnemyCharacter:HasTag("Ragdolled") or EnemyHumanoid.Health <= 0 then return end

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 30, nil, nil, false, true, true, true, false, nil, nil)
				if HitInfo.Countered == true then return end

				iFramesService:AddAlliFrames(EnemyCharacter)
				AnimationService:stopAll(EnemyCharacter)

				RagdollHandler.ragdoll(EnemyHumanoid, 2)
				NewKnockback:Knockback(EnemyCharacter, {
					KnockbackType = "Velocity",
					MaxForce = Vector3.new(75000, 75000, 75000),
					Velocity = HumRP.CFrame.LookVector * 60 + Vector3.new(0, 15, 0)
				})

				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 3, Last = 0.4 })
				ReplicateEffects_Set:FireAllClients("HeianRush", { char = Character, stage = "Hit", target = EnemyCharacter })

				task.delay(2, function()
					iFramesService:RemoveAlliFrames(EnemyCharacter)
				end)
			end
			Hitbox:Start()

			StartEvents["Stop"] = StartTrack:GetMarkerReachedSignal("Stop"):Once(function()
				if leapVelocity then leapVelocity:Destroy() end
				Hitbox:Destroy()
				ReplicateEffects_Set:FireAllClients("HeianRush", { char = Character, stage = "Stop" })
			end)
		end)

		StartTrack.Stopped:Once(function()
			for _, v in StartEvents do v:Disconnect() end
			if leapVelocity then leapVelocity:Destroy() end
			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)

		ReplicateEffects_Set:FireAllClients("HeianRush", { char = Character, stage = "Start" })
	end
}