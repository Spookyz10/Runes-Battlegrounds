local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules = ServerStorage.Modules
local ReplicatedModules = ReplicatedStorage.Modules
local RemotesContainer = ReplicatedStorage.Remotes

local StunHandler      = require(ServerModules.StunHandler)
local DamageHandler    = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService   = require(ServerModules.iFramesService)
local Trove            = require(ReplicatedModules.Trove)

local MoveAnims = ServerStorage.Assets.Animations.Moves.Vergil["Judgement Cut End"]

local ReplicateEffects_Set = RemotesContainer.Replicate.Set


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Janitor = Trove.new()
		local AttackerStun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		Humanoid.AutoRotate = false

		local Anim1Track = AnimationService:getAnimationTrack(Character, MoveAnims.Anim1)

		local function Cleanup()
			Humanoid.AutoRotate = true
			StunHandler:Unstun(Character, AttackerStun)
			Janitor:Destroy()
		end


		-- Fire client: arm VFX + Start VFX + sound
		ReplicateEffects_Set:FireAllClients("JudgementCutEnd", {
			Char  = Character,
			Stage = "pa",
			Animation = MoveAnims.Anim1.AnimationId
		})

		-- Play Anim1, freeze on "Stop"
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, MoveAnims.Anim1)

		Janitor:Add(Anim1Track:GetMarkerReachedSignal("Stop"):Connect(function()
			Anim1Track:AdjustSpeed(0)
		end))


		-- ── Phase 2: after 1.8s resume + slash ──
		task.delay(1.8, function()
			if not Character:IsDescendantOf(workspace) then Cleanup() return end

			Anim1Track:AdjustSpeed(1)

			task.delay(0.25, function()
				if not Character:IsDescendantOf(workspace) then Cleanup() return end

				-- 250×250×250 AoE hitbox
				local hbCFrame = HumRP.CFrame
				local hbSize   = Vector3.new(250, 250, 250)

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

				local hitList = {}
				for _, part in workspace:GetPartBoundsInBox(hbCFrame, hbSize) do
					local EnemyCharacter = part.Parent
					if not EnemyCharacter:IsA("Model") then continue end
					local EnemyHumanoid: Humanoid = EnemyCharacter:FindFirstChildOfClass("Humanoid")
					local EnemyHumRP: BasePart    = EnemyCharacter:FindFirstChild("HumanoidRootPart")
					if not EnemyHumanoid or not EnemyHumRP then continue end
					if EnemyCharacter == Character then continue end
					if hitList[EnemyHumanoid] then continue end
					if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then continue end
					if EnemyHumanoid.Health <= 0 then continue end
					hitList[EnemyHumanoid] = true

					-- Stun 2.75s then 475 damage + blood
					StunHandler:Stun(EnemyCharacter, 2.75, true, 0, 0, true)

					task.delay(2.75, function()
						if not EnemyCharacter:IsDescendantOf(workspace) then return end
						if EnemyHumanoid.Health <= 0 then return end
						DamageHandler:TakeDamage(Character, EnemyHumanoid, 475, nil, nil, false, false, true, true, false, nil, nil)
						ReplicateEffects_Set:FireAllClients("JudgementCutEnd", {
							Char      = Character,
							Stage     = "hit_damage",
							Victim    = EnemyCharacter,
							VictimPos = EnemyHumRP.Position
						})
					end)
				end

				-- Fire slash VFX + Camera + desaturate to client
				ReplicateEffects_Set:FireAllClients("JudgementCutEnd", {
					Char      = Character,
					Stage     = "slash_fx",
					HRPCFrame = HumRP.CFrame
				})

				-- Make character invisible server-side
				for _, v in Character:GetDescendants() do
					if v:IsA("BasePart") then v.Transparency = 1 end
				end
				if Character.Head:FindFirstChild("face") then
					Character.Head.face.Transparency = 1
				end

				-- ── Phase 3: reappear after 1s ──
				task.delay(1, function()
					if not Character:IsDescendantOf(workspace) then Cleanup() return end

					-- Restore visibility
					task.delay(0.1, function()
						for _, v in Character:GetDescendants() do
							if v:IsA("BasePart") then v.Transparency = 0 end
						end
						if Character.Head:FindFirstChild("face") then
							Character.Head.face.Transparency = 0
						end
						HumRP.Transparency = 1
						-- Keep arm VFX parts invisible
						local ra = Character:FindFirstChild("JCE_RA_" .. Character.Name, true)
						local la = Character:FindFirstChild("JCE_LA_" .. Character.Name, true)
						if ra then ra.Transparency = 1 end
						if la then la.Transparency = 1 end
					end)

					-- Fire Floor VFX + Anim2 to client
					ReplicateEffects_Set:FireAllClients("JudgementCutEnd", {
						Char      = Character,
						Stage     = "reappear",
						HRPCFrame = HumRP.CFrame
					})

					-- Play Anim2
					local Anim2Track = AnimationService:getAnimationTrack(Character, MoveAnims.Anim2)
					AnimationService:playAnimation(Character, MoveAnims.Anim2)

					Janitor:Add(Anim2Track:GetMarkerReachedSignal("Slow"):Connect(function()
						Anim2Track:AdjustSpeed(0.15)
					end))

					-- ── Phase 4: Boom after 1.7s ──
					task.delay(1.7, function()
						if not Character:IsDescendantOf(workspace) then Cleanup() return end

						-- Fire boom + restore timescales + idk VFX
						ReplicateEffects_Set:FireAllClients("JudgementCutEnd", {
							Char      = Character,
							Stage     = "boom",
							HRPCFrame = HumRP.CFrame
						})

						-- Restore movement
						Humanoid.AutoRotate = true
						StunHandler:Unstun(Character, AttackerStun)

						-- Fade idk after 1s
						task.delay(1, function()
							ReplicateEffects_Set:FireAllClients("JudgementCutEnd", {
								Char  = Character,
								Stage = "idk_fade"
							})
							Cleanup()
						end)
					end)
				end)
			end)
		end)

		Janitor:Add(function()
			Humanoid.AutoRotate = true
		end)
	end
}