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
local SlaughterAnims = Animations.Moves.Yuji.SlaugherCursed

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		AnimationService:stopAll(Character)
		local Anim = AnimationService:playAnimation(Character, SlaughterAnims.Anim)

		ReplicateEffects_Set:FireAllClients("SlaughterCursed", {
			Stage = "Start",
			Char = Character,
			AnimId = SlaughterAnims.Anim.AnimationId,
		})

		local function DoHit(delay, damage, slashStage)
			task.delay(delay, function()
				if not Character.Parent then return end

				ReplicateEffects_Set:FireAllClients("SlaughterCursed", {
					Stage = slashStage,
					Char = Character,
				})

				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 1.5, Last = 0.2 })

				HitboxHandler:SimpleOnce(HumRP, Vector3.new(25, 3.197, 25), CFrame.new(0, 0, 0), { Character }, nil, nil, function(EnemyCharacter: Model)
					local EnemyPlayer = PlayersService:GetPlayerFromCharacter(EnemyCharacter)
					local EnemyHumanoid: Humanoid = EnemyCharacter:FindFirstChildOfClass("Humanoid")
					local EnemyHumRP: BasePart = EnemyCharacter:FindFirstChild("HumanoidRootPart")

					if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then return end
					if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
					if EnemyHumRP.Anchored then return end

					local HitInfo = DamageHandler:TakeDamage(Character, EnemyHumanoid, damage, nil, nil, true, false, true, true, true, nil)
					if HitInfo.Blocked then return end

					local VictimAnimator = EnemyHumanoid:FindFirstChildOfClass("Animator")
					if VictimAnimator then
						local hitAnim = math.random(1, 2) == 1 and SlaughterAnims.Hit1 or SlaughterAnims.Hit2
						VictimAnimator:LoadAnimation(hitAnim):Play(0)
					end

					if EnemyPlayer then
						ReplicateEffects_Set:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 1.5, Last = 0.2 })
					end

					ReplicateEffects_Set:FireAllClients("SlaughterCursed", {
						Stage = "Hit",
						Char = Character,
						Victim = EnemyPlayer,
					})
				end)
			end)
		end

		DoHit(0.3, 10, "Slash1")
		DoHit(0.7, 10, "Slash2")
		DoHit(1.2, 15, "Slash3")

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