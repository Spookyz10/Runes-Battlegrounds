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

		local StartAnimation = MoveAnims.SolemnLament["GoodbyeNow,TheSorrowInYou"]
		local StartTrack, StartEvents = AnimationService:getAnimationTrack(Character, StartAnimation)

		-- ── Shared forward hitbox ─────────────────────────────────────────
		local function fireHitbox(damage)
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

				DamageHandler:TakeDamage(Character, EnemyHumanoid, damage or 5, nil, nil, true, false, false, true, false, nil, nil)

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

		-- ── Roar AOE hitbox ───────────────────────────────────────────────
		local function fireRoarHitbox()
			local Hitbox            = ReplicatedHitbox.new(Player)
			Hitbox.Instance         = HumRP
			Hitbox.Size             = Vector3.new(30, 30, 30)
			Hitbox.Offset           = CFrame.new(0, 0, 0)
			Hitbox.Ignore           = { Character }
			Hitbox.destroyAfterOnce = false

			Hitbox.onTouch = function(EnemyCharacter: Model)
				local EnemyHumanoid : Humanoid = EnemyCharacter:FindFirstChildOfClass("Humanoid")
				local EnemyHumRP    : BasePart = EnemyCharacter:FindFirstChild("HumanoidRootPart")
				if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then return end
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end

				DamageHandler:TakeDamage(Character, EnemyHumanoid, 7, nil, nil, true, false, false, true, false, nil, nil)

				knockbackService.Knockback(EnemyHumRP, {
					["duration"]  = 0.4,
					["force"]     = 70,
					["direction"] = (EnemyHumRP.Position - HumRP.Position).Unit + Vector3.new(0, 0.4, 0),
				}, Character)

				ReplicateEffects_Set:FireAllClients("SolemnLament", {
					Stage   = "hit",
					enemy   = EnemyCharacter,
					enemyCF = EnemyHumRP.CFrame,
				})
			end

			Hitbox:Once()
		end

		-- ── Dash forward ──────────────────────────────────────────────────
		table.insert(StartEvents, StartTrack:GetMarkerReachedSignal("dashforward"):Connect(function()
			local att = Instance.new("Attachment")
			att.Parent = HumRP
			local vel = Instance.new("LinearVelocity")
			vel.Attachment0    = att
			vel.MaxForce       = math.huge
			vel.VectorVelocity = HumRP.CFrame.LookVector * 50
			vel.Parent         = HumRP
			Debris:AddItem(vel, 0.3)
			Debris:AddItem(att, 0.3)
		end))

		-- ── Shoot marker ──────────────────────────────────────────────────
		table.insert(StartEvents, StartTrack:GetMarkerReachedSignal("Shoot"):Connect(function()
			fireHitbox()
			ReplicateEffects_Set:FireAllClients("SolemnLament", {
				Stage = "shot",
				char  = Character,
				vfx   = "blackShot2",
				hrpCF = HumRP.CFrame,
			})
		end))

		-- ── Dash back ─────────────────────────────────────────────────────
		table.insert(StartEvents, StartTrack:GetMarkerReachedSignal("dashback"):Connect(function()
			local att = Instance.new("Attachment")
			att.Parent = HumRP
			local vel = Instance.new("LinearVelocity")
			vel.Attachment0    = att
			vel.MaxForce       = math.huge
			vel.VectorVelocity = -HumRP.CFrame.LookVector * 40
			vel.Parent         = HumRP
			Debris:AddItem(vel, 0.3)
			Debris:AddItem(att, 0.3)
		end))

		-- ── S1 shot ───────────────────────────────────────────────────────
		table.insert(StartEvents, StartTrack:GetMarkerReachedSignal("S1"):Connect(function()
			fireHitbox()
			ReplicateEffects_Set:FireAllClients("SolemnLament", {
				Stage = "shot",
				char  = Character,
				vfx   = "whiteShot2",
				hrpCF = HumRP.CFrame,
			})
		end))

		-- ── S2 shot ───────────────────────────────────────────────────────
		table.insert(StartEvents, StartTrack:GetMarkerReachedSignal("S2"):Connect(function()
			fireHitbox()
			ReplicateEffects_Set:FireAllClients("SolemnLament", {
				Stage = "shot",
				char  = Character,
				vfx   = "blackShot2",
				hrpCF = HumRP.CFrame,
			})
		end))

		-- ── End dash forward ──────────────────────────────────────────────
		table.insert(StartEvents, StartTrack:GetMarkerReachedSignal("End"):Connect(function()
			local att = Instance.new("Attachment")
			att.Parent = HumRP
			local vel = Instance.new("LinearVelocity")
			vel.Attachment0    = att
			vel.MaxForce       = math.huge
			vel.VectorVelocity = HumRP.CFrame.LookVector * 50
			vel.Parent         = HumRP
			Debris:AddItem(vel, 0.3)
			Debris:AddItem(att, 0.3)
		end))

		-- ── Roar AOE finisher ─────────────────────────────────────────────
		table.insert(StartEvents, StartTrack:GetMarkerReachedSignal("Roar"):Connect(function()
			fireRoarHitbox()
			ReplicateEffects_Set:FireAllClients("SolemnLament", {
				Stage = "roar",
				char  = Character,
				hrpCF = HumRP.CFrame,
			})
		end))

		-- ── Cleanup ───────────────────────────────────────────────────────
		StartTrack.Stopped:Once(function()
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)
	end,
}