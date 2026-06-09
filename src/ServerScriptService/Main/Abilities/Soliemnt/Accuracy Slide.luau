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

		local StartAnimation = MoveAnims.SolemnLament.AccuracySlide
		local StartTrack, StartEvents = AnimationService:getAnimationTrack(Character, StartAnimation)

		local slideVel = nil
		local slideAtt = nil

		local function fireHitbox()
			local Hitbox            = ReplicatedHitbox.new(Player)
			Hitbox.Instance         = HumRP
			Hitbox.Size             = Vector3.new(6, 6, 25)
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
					["duration"]  = 0.15,
					["force"]     = 35,
					["direction"] = HumRP.CFrame.LookVector + Vector3.new(0, 0.2, 0),
				}, Character)

				ReplicateEffects_Set:FireAllClients("SolemnLament", {
					Stage   = "hit",
					enemy   = EnemyCharacter,
					enemyCF = EnemyHumRP.CFrame,
				})
			end

			Hitbox:Once()
		end

		-- ── Start sliding forward ─────────────────────────────────────────
		table.insert(StartEvents, StartTrack:GetMarkerReachedSignal("Dash"):Connect(function()
			slideAtt = Instance.new("Attachment")
			slideAtt.Parent = HumRP

			slideVel = Instance.new("LinearVelocity")
			slideVel.Attachment0    = slideAtt
			slideVel.MaxForce       = math.huge
			slideVel.Parent         = HumRP

			-- Update direction every frame so it follows the player's look
			local conn
			conn = game:GetService("RunService").Heartbeat:Connect(function()
				if not slideVel or not slideVel.Parent then
					conn:Disconnect()
					return
				end
				local look = HumRP.CFrame.LookVector
				slideVel.VectorVelocity = Vector3.new(look.X, 0, look.Z) * 40
			end)
		end))

		-- ── Stop sliding ──────────────────────────────────────────────────
		table.insert(StartEvents, StartTrack:GetMarkerReachedSignal("Stopdash"):Connect(function()
			if slideVel and slideVel.Parent then slideVel:Destroy() end
			if slideAtt and slideAtt.Parent then slideAtt:Destroy() end
			slideVel = nil
			slideAtt = nil
		end))

		-- ── Shots ─────────────────────────────────────────────────────────
		table.insert(StartEvents, StartTrack:GetMarkerReachedSignal("Black"):Connect(function()
			fireHitbox()
			ReplicateEffects_Set:FireAllClients("SolemnLament", {
				Stage = "shot",
				char  = Character,
				vfx   = "blackShot2",
				hrpCF = HumRP.CFrame,
			})
		end))

		table.insert(StartEvents, StartTrack:GetMarkerReachedSignal("White"):Connect(function()
			fireHitbox()
			ReplicateEffects_Set:FireAllClients("SolemnLament", {
				Stage = "shot",
				char  = Character,
				vfx   = "whiteShot2",
				hrpCF = HumRP.CFrame,
			})
		end))

		-- ── Cleanup ───────────────────────────────────────────────────────
		StartTrack.Stopped:Once(function()
			if slideVel and slideVel.Parent then slideVel:Destroy() end
			if slideAtt and slideAtt.Parent then slideAtt:Destroy() end
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
	end,
}