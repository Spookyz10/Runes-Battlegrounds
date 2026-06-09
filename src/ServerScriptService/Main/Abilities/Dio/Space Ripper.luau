local Debris            = game:GetService("Debris")
local ServerStorage     = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules    = ServerStorage.Modules
local RemotesContainer = ReplicatedStorage.Remotes

local StunHandler      = require(ServerModules.StunHandler)
local DamageHandler    = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService   = require(ServerModules.iFramesService)
local ReplicatedHitbox = require(ServerModules.ReplicatedHitboxes)

local services         = require(ReplicatedStorage.Services)
local knockbackService = services:GetService("KnockbackService")

local MoveAnims            = ServerStorage.Assets.Animations.Moves
local ReplicateEffects_Set = RemotesContainer.Replicate.Set

return {
	Start = function(Player: Player, Tool: Tool)
		local Character : Model    = Player.Character
		local Humanoid  : Humanoid = Character.Humanoid
		local HumRP     : BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		local StartAnimation = MoveAnims.Dio.Eye.Start
		local StartTrack     = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents    = {}

		StartEvents["Start"] = StartTrack:GetMarkerReachedSignal("Start"):Once(function()

			-- AOE hitbox — hits all enemies in range
			local Hitbox            = ReplicatedHitbox.new(Player)
			Hitbox.Instance         = HumRP
			Hitbox.Size             = Vector3.new(8, 8, 30)
			Hitbox.Offset           = CFrame.new(0, 0, -15)
			Hitbox.Ignore           = { Character }
			Hitbox.destroyAfterOnce = false

			Hitbox.onTouch = function(EnemyCharacter: Model)
				local EnemyHumanoid : Humanoid = EnemyCharacter:FindFirstChildOfClass("Humanoid")
				local EnemyHumRP    : BasePart = EnemyCharacter:FindFirstChild("HumanoidRootPart")
				if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then return end
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end

				DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, true, false, false, true, false, nil, nil)

				knockbackService.Knockback(EnemyHumRP, {
					["duration"]  = 0.2,
					["force"]     = 40,
					["direction"] = HumRP.CFrame.LookVector + Vector3.new(0, 0.1, 0),
				}, Character)

				ReplicateEffects_Set:FireAllClients("DioEye", {
					Stage   = "hit",
					char    = Character,
					enemy   = EnemyCharacter,
					enemyCF = EnemyHumRP.CFrame,
				})
			end

			Hitbox:Once()

			ReplicateEffects_Set:FireAllClients("DioEye", {
				Stage = "beam",
				char  = Character,
				hrpCF = HumRP.CFrame,
			})
		end)

		StartTrack.Stopped:Once(function()
			for _, v in StartEvents do v:Disconnect() end
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
	end,
}