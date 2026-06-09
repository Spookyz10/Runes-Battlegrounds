local Debris = game:GetService("Debris")
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

local JCAssets  = ReplicatedStorage.Resources.Vergil["Judgement Cut"]
local BubbleModule = require(JCAssets.BubbleModule)

local MoveAnims = ServerStorage.Assets.Animations.Moves.Vergil["Judgement Cut"]

local ReplicateEffects_Set = RemotesContainer.Replicate.Set


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Janitor = Trove.new()
		local AttackerStun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		local AnimTrack = AnimationService:getAnimationTrack(Character, MoveAnims.Anim)

		local function Cleanup()
			StunHandler:Unstun(Character, AttackerStun)
			Janitor:Destroy()
		end

		-- Fire client: arm VFX + sound + Slash VFX setup
		ReplicateEffects_Set:FireAllClients("JudgementCut", {
			Char      = Character,
			Stage     = "pa",
			Animation = MoveAnims.Anim.AnimationId
		})

		-- Play anim, freeze on "Stop"
		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, MoveAnims.Anim)

		Janitor:Add(AnimTrack:GetMarkerReachedSignal("Stop"):Connect(function()
			AnimTrack:AdjustSpeed(0)
		end))

		-- After 0.1s: speed up + hitbox + Slash VFX
		task.delay(0.1, function()
			if not Character:IsDescendantOf(workspace) then Cleanup() return end

			AnimTrack:AdjustSpeed(2)

			-- Fire client: Slash VFX + Shaker
			ReplicateEffects_Set:FireAllClients("JudgementCut", {
				Char      = Character,
				Stage     = "slash_fx",
				HRPCFrame = HumRP.CFrame
			})

			-- Hitbox: 45×12×45 at 0,2,0
			local hbCFrame = HumRP.CFrame * CFrame.new(0, 2, 0)
			local hbSize   = Vector3.new(45, 12, 45)

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

				-- 5 damage + stun 0.75s
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 5, nil, nil, true, true, true, true, true, nil, nil)
				StunHandler:Stun(EnemyCharacter, 0.75, true, 0, 0, true)

				-- Bubbles (server-side since BubbleModule runs on server)
				BubbleModule.CreateBubble(EnemyHumRP.CFrame, Vector3.new(12.5, 12.5, 12.5), 3, Vector3.new(0, 0, 0), 0.4)
				BubbleModule.CreateBubble(EnemyHumRP.CFrame, Vector3.new(0, 0, 0), 3, Vector3.new(5, 5, 5), 0.3)

				-- Fire hit VFX to client
				ReplicateEffects_Set:FireAllClients("JudgementCut", {
					Char      = Character,
					Stage     = "hit",
					Victim    = EnemyCharacter,
					VictimPos = EnemyHumRP.Position
				})
			end

			-- Restore movement after 0.3s
			task.delay(0.3, function()
				if not Character:IsDescendantOf(workspace) then Cleanup() return end
				Cleanup()
			end)
		end)

		Janitor:Add(AnimTrack.Stopped:Connect(function()
			Cleanup()
		end))
	end
}