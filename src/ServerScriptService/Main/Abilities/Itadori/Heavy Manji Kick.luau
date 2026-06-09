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

local ReplicateEffects_Set = RemotesContainer.Replicate.Set

local Animations = ServerStorage.Assets.Animations
local SpeedSlashAnims = Animations.Moves.Yuji.HeavyManjiKick
local OtherAnims = Animations.Other

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		AnimationService:stopAll(Character)
		local Anim = AnimationService:playAnimation(Character, SpeedSlashAnims.SpeedSlashAnim)

		ReplicateEffects_Set:FireAllClients("SpeedSlash", {
			Stage = "Start",
			Char = Character,
			AnimId = SpeedSlashAnims.SpeedSlashAnim.AnimationId,
		})

		task.delay(0.6, function()
			if not Character.Parent then return end

			ReplicateEffects_Set:FireAllClients("SpeedSlash", {
				Stage = "Slash",
				Char = Character,
			})

			ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 1.5, Last = 0.2 })

			HitboxHandler:SimpleOnce(HumRP, Vector3.new(7.722, 9.338, 9.361), CFrame.new(0, 0, -5), { Character }, nil, nil, function(EnemyCharacter: Model)
				local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumanoid: Humanoid = EnemyCharacter:FindFirstChildOfClass("Humanoid")
				local EnemyHumRP: BasePart = EnemyCharacter:FindFirstChild("HumanoidRootPart")

				if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then return end
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end

				local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, 10, nil, nil, true, false, true, true, true, nil)
				if HitInfo.Blocked then return end

				-- Play knockback anim on victim
				local VictimAnimator = EnemyHumanoid:FindFirstChildOfClass("Animator")
				if VictimAnimator then
					VictimAnimator:LoadAnimation(OtherAnims.Knockback):Play(0)
				end

				NewKnockback:Knockback(EnemyCharacter, {
					KnockbackType = "Velocity",
					MaxForce = Vector3.new(2050000, 0, 2050000),
					Velocity = HumRP.CFrame.LookVector * 60 + Vector3.new(0, 25, 0),
				})

				if EnemyPlayer then
					ReplicateEffects_Set:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 1.5, Last = 0.2 })
				end

				ReplicateEffects_Set:FireAllClients("SpeedSlash", {
					Stage = "Hit",
					Char = Character,
					Victim = EnemyPlayer,
				})
			end)
		end)

		Anim.Stopped:Once(function()
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)
		end)

		task.delay(1.5, function()
			StunHandler:Unstun(Character, Stun)
			iFramesService:RemoveAlliFrames(Character)
		end)
	end
}