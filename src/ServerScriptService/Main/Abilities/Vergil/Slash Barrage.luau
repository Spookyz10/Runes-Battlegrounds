local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules = ServerStorage.Modules
local ReplicatedModules = ReplicatedStorage.Modules
local RemotesContainer = ReplicatedStorage.Remotes

local StunHandler      = require(ServerModules.StunHandler)
local DamageHandler    = require(ServerModules.DamageHandler)
local RagdollHandler   = require(ServerModules.RagdollHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService   = require(ServerModules.iFramesService)
local Trove            = require(ReplicatedModules.Trove)

local services         = require(ReplicatedStorage.Services)
local knockbackService = services:GetService("KnockbackService")

local MoveAnims = ServerStorage.Assets.Animations.Moves.Vergil["Slash Barrage"]

local ReplicateEffects_Set = RemotesContainer.Replicate.Set


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Janitor = Trove.new()
		local AttackerStun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		local BarrageAnim = MoveAnims.Anim
		local BarrageTrack = AnimationService:getAnimationTrack(Character, BarrageAnim)

		local function Cleanup()
			StunHandler:Unstun(Character, AttackerStun)
			Janitor:Destroy()
		end

		-- Fire client: spawn arm VFX + sound
		ReplicateEffects_Set:FireAllClients("SlashBarrage", {
			Char = Character,
			Stage = "pa",
			Animation = BarrageAnim.AnimationId
		})

		-- Play Anim frozen, then release after 0.35s
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, BarrageAnim)
		BarrageTrack:AdjustSpeed(0)

		task.delay(0.35, function()
			if not Character:IsDescendantOf(workspace) then Cleanup() return end

			BarrageTrack:AdjustSpeed(1.5)

			-- Fire client: Slashh VFX + Shaker
			ReplicateEffects_Set:FireAllClients("SlashBarrage", {
				Char = Character,
				Stage = "barrage_fx",
				HRPCFrame = HumRP.CFrame
			})

			-- ── Repeating barrage hitbox (every 0.05s for 2.4s) ──
			local barrageActive = true
			local barrageHitList = {} -- persists across ticks so same enemy isn't spammed

			task.spawn(function()
				repeat
					task.wait(0.05)
					if not Character:IsDescendantOf(workspace) then break end

					local hbCFrame = HumRP.CFrame * CFrame.new(0, 1, 0)
					local hbSize  = Vector3.new(25, 10, 25)

					local hitbox = Instance.new("Part")
					hitbox.Size        = hbSize
					hitbox.CFrame      = hbCFrame
					hitbox.Anchored    = true
					hitbox.CanCollide  = false
					hitbox.CanTouch    = false
					hitbox.CanQuery    = false
					hitbox.Transparency = 1
					hitbox.Parent      = workspace
					Debris:AddItem(hitbox, 0.1)

					-- Reset per-tick hitlist so each tick can re-hit (matching original)
					local tickHitList = {}
					for _, part in workspace:GetPartBoundsInBox(hbCFrame, hbSize) do
						local EnemyCharacter = part.Parent
						if not EnemyCharacter:IsA("Model") then continue end
						local EnemyHumanoid: Humanoid = EnemyCharacter:FindFirstChildOfClass("Humanoid")
						local EnemyHumRP: BasePart    = EnemyCharacter:FindFirstChild("HumanoidRootPart")
						if not EnemyHumanoid or not EnemyHumRP then continue end
						if EnemyCharacter == Character then continue end
						if tickHitList[EnemyHumanoid] then continue end
						if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then continue end
						if EnemyHumanoid.Health <= 0 then continue end
						tickHitList[EnemyHumanoid] = true

						-- 0.5 damage per tick
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 0.5, nil, nil, false, false, true, true, false, nil, nil)

						-- Fire blood + hit anim to client
						ReplicateEffects_Set:FireAllClients("SlashBarrage", {
							Char    = Character,
							Stage   = "barrage_hit",
							Victim  = EnemyCharacter,
							VictimPos = EnemyHumRP.Position
						})
					end
				until barrageActive == false
			end)

			task.delay(2.4, function()
				barrageActive = false
				if not Character:IsDescendantOf(workspace) then Cleanup() return end

				BarrageTrack:Stop()

				-- ── Last Slash phase ──
				ReplicateEffects_Set:FireAllClients("SlashBarrage", {
					Char = Character,
					Stage = "last_slash_fx",
					HRPCFrame = HumRP.CFrame
				})

				-- Last slash hitbox: 17×10×10 at 0,0,-11
				local hb2CFrame = HumRP.CFrame * CFrame.new(0, 0, -11)
				local hb2Size   = Vector3.new(17, 10, 10)

				local hitbox2 = Instance.new("Part")
				hitbox2.Size        = hb2Size
				hitbox2.CFrame      = hb2CFrame
				hitbox2.Anchored    = true
				hitbox2.CanCollide  = false
				hitbox2.CanTouch    = false
				hitbox2.CanQuery    = false
				hitbox2.Transparency = 1
				hitbox2.Parent      = workspace
				Debris:AddItem(hitbox2, 0.1)

				local lastHitList = {}
				for _, part in workspace:GetPartBoundsInBox(hb2CFrame, hb2Size) do
					local EnemyCharacter = part.Parent
					if not EnemyCharacter:IsA("Model") then continue end
					local EnemyHumanoid: Humanoid = EnemyCharacter:FindFirstChildOfClass("Humanoid")
					local EnemyHumRP: BasePart    = EnemyCharacter:FindFirstChild("HumanoidRootPart")
					if not EnemyHumanoid or not EnemyHumRP then continue end
					if EnemyCharacter == Character then continue end
					if lastHitList[EnemyHumanoid] then continue end
					if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then continue end
					if EnemyHumanoid.Health <= 0 then continue end
					lastHitList[EnemyHumanoid] = true

					-- 75 damage
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 75, nil, nil, false, false, true, true, false, nil, nil)

					-- Directional knockback away from attacker
					local direction = (EnemyHumRP.Position - HumRP.Position).Unit
					knockbackService.Knockback(EnemyHumRP, {
						["duration"] = 0.15,
						["force"]    = 45,
						["direction"] = direction
					})

					-- Ragdoll 1s
					RagdollHandler.ragdoll(EnemyHumanoid, 1)

					-- Fire last hit blood to client
					ReplicateEffects_Set:FireAllClients("SlashBarrage", {
						Char      = Character,
						Stage     = "last_hit",
						Victim    = EnemyCharacter,
						VictimPos = EnemyHumRP.Position
					})
				end

				-- Play Anim2
				local Anim2     = MoveAnims.Anim2
				local Anim2Track = AnimationService:getAnimationTrack(Character, Anim2)
				AnimationService:playAnimation(Character, Anim2)
				Anim2Track:AdjustSpeed(1.2)

				Janitor:Add(Anim2Track:GetMarkerReachedSignal("Stop"):Connect(function()
					Anim2Track:AdjustSpeed(0)
				end))

				-- After 0.5s: fire idk_fx, restore movement, slow Anim2
				task.delay(0.5, function()
					if not Character:IsDescendantOf(workspace) then Cleanup() return end

					-- Destroy arms after 0.2s, fire idk VFX
					task.delay(0.2, function()
						ReplicateEffects_Set:FireAllClients("SlashBarrage", {
							Char  = Character,
							Stage = "destroy_arms"
						})
					end)

					ReplicateEffects_Set:FireAllClients("SlashBarrage", {
						Char  = Character,
						Stage = "idk_fx"
					})

					Anim2Track:AdjustSpeed(0.5)

					-- Fade idk after 0.75s then cleanup
					task.delay(0.75, function()
						ReplicateEffects_Set:FireAllClients("SlashBarrage", {
							Char  = Character,
							Stage = "idk_fade"
						})
						Cleanup()
					end)
				end)
			end)
		end)

		Janitor:Add(function()
			BarrageTrack:Stop()
		end)
	end
}