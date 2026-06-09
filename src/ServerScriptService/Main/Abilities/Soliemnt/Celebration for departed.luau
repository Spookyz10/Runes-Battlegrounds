local Debris            = game:GetService("Debris")
local ServerStorage     = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService    = game:GetService("Players")

local ServerModules    = ServerStorage.Modules
local ReplicatedModules = ReplicatedStorage.Modules
local RemotesContainer = ReplicatedStorage.Remotes

local StunHandler      = require(ServerModules.StunHandler)
local DamageHandler    = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService   = require(ServerModules.iFramesService)
local ReplicatedHitbox = require(ServerModules.ReplicatedHitboxes)
local Trove            = require(ReplicatedModules.Trove)

local services         = require(ReplicatedStorage.Services)
local knockbackService = services:GetService("KnockbackService")

local MoveAnims            = ServerStorage.Assets.Animations.Moves
local ReplicateEffects_Set = RemotesContainer.Replicate.Set

return {
	Start = function(Player: Player, Tool: Tool)
		local Character : Model    = Player.Character
		local Humanoid  : Humanoid = Character.Humanoid
		local HumRP     : BasePart = Character.HumanoidRootPart

		local Janitor = Trove.new()
		local Stun    = StunHandler:Stun(Character, nil, true, 0, 0, true)

		local Anim   = MoveAnims.SolemnLament["Dep"].CelebrationForDeparted
		local Track  = AnimationService:getAnimationTrack(Character, Anim)
		local Events = {}

		-- ── Shared hitbox for each shot ───────────────────────────────────
		local function fireHitbox()
			local Hitbox             = ReplicatedHitbox.new(Player)
			Hitbox.Instance          = HumRP
			Hitbox.Size              = Vector3.new(6, 6, 25)
			Hitbox.Offset            = CFrame.new(0, 0, -15)
			Hitbox.Ignore            = { Character }
			Hitbox.destroyAfterOnce  = false

			Hitbox.onTouch = function(EnemyCharacter: Model)
				local EnemyHumanoid : Humanoid = EnemyCharacter:FindFirstChildOfClass("Humanoid")
				local EnemyHumRP    : BasePart = EnemyCharacter:FindFirstChild("HumanoidRootPart")
				if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then return end
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end

				DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, true, false, false, true, false, nil, nil)

				knockbackService.Knockback(EnemyHumRP, {
					["duration"]  = 0.15,
					["force"]     = 35,
					["direction"] = HumRP.CFrame.LookVector + Vector3.new(0, 0.2, 0),
				}, Character)

				ReplicateEffects_Set:FireAllClients("SolemnLament", {
					Stage    = "hit",
					enemy    = EnemyCharacter,
					enemyCF  = EnemyHumRP.CFrame,
				})
			end

			Hitbox:Once()
		end

		-- ── Animation markers ─────────────────────────────────────────────
		-- Shot 1 — white gun
		Events["1"] = Janitor:Add(Track:GetMarkerReachedSignal("1"):Connect(function()
			fireHitbox()
			ReplicateEffects_Set:FireAllClients("SolemnLament", {
				Stage = "shot",
				char  = Character,
				vfx   = "whiteShot2",
				hrpCF = HumRP.CFrame,
			})
		end))

		-- Shot 2 — black gun
		Events["2"] = Janitor:Add(Track:GetMarkerReachedSignal("2"):Connect(function()
			fireHitbox()
			ReplicateEffects_Set:FireAllClients("SolemnLament", {
				Stage = "shot",
				char  = Character,
				vfx   = "blackShot2",
				hrpCF = HumRP.CFrame,
			})
		end))

		-- ── Cleanup ───────────────────────────────────────────────────────
		Track.Stopped:Once(function()
			for _, v in Events do v:Disconnect() end
			StunHandler:Unstun(Character, Stun)
			Janitor:Destroy()
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, Anim)
	end,
}