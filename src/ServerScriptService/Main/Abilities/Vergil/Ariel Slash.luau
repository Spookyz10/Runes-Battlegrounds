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

local MoveAnims = ServerStorage.Assets.Animations.Moves.Vergil["Aerial Slash"]

local ReplicateEffects_Set = RemotesContainer.Replicate.Set

-- Launches a part up, holds it, then drops it — mirrors original BodyVelocity/BodyPosition logic
local function launchAndHold(root: BasePart)
	-- Launch up
	local bv = Instance.new("BodyVelocity", root)
	bv.MaxForce = Vector3.new(99999, 99999, 99999)
	bv.Velocity = root.CFrame.UpVector * 175
	Debris:AddItem(bv, 0.2)

	task.delay(0.2, function()
		if not root or not root.Parent then return end
		-- Hold in place
		local bp = Instance.new("BodyPosition", root)
		bp.Position  = root.Position
		bp.MaxForce  = Vector3.new(99999, 99999, 99999)
		bp.P         = 125
		bp.D         = 30000
		bp.Parent    = root

		task.delay(7, function()
			if not bp or not bp.Parent then return end
			bp:Destroy()
			if not root or not root.Parent then return end
			-- Drop down
			local bd = Instance.new("BodyVelocity", root)
			bd.MaxForce = Vector3.new(99999, 99999, 99999)
			bd.Velocity = Vector3.new(0, -75, 0)
			Debris:AddItem(bd, 0.2)
		end)
	end)
end


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Janitor = Trove.new()
		local AttackerStun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		local AnimTrack = AnimationService:getAnimationTrack(Character, MoveAnims.Animation)

		local function Cleanup()
			StunHandler:Unstun(Character, AttackerStun)
			Janitor:Destroy()
		end

		-- Fire client: arm VFX + sound
		ReplicateEffects_Set:FireAllClients("AerialSlash", {
			Char      = Character,
			Stage     = "pa",
			Animation = MoveAnims.Animation.AnimationId
		})

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, MoveAnims.Animation)

		-- "Stop" marker: freeze → swap arms → idk VFX
		Janitor:Add(AnimTrack:GetMarkerReachedSignal("Stop"):Connect(function()
			AnimTrack:AdjustSpeed(0)

			task.delay(0.15, function()
				if not Character:IsDescendantOf(workspace) then Cleanup() return end

				AnimTrack:AdjustSpeed(1)

				-- Fire client: destroy arms + spawn idk
				ReplicateEffects_Set:FireAllClients("AerialSlash", {
					Char  = Character,
					Stage = "idk_fx"
				})
			end)
		end))

		-- After 0.3s: launch attacker + slash VFX + hitbox
		task.delay(0.3, function()
			if not Character:IsDescendantOf(workspace) then Cleanup() return end

			-- Launch attacker
			launchAndHold(HumRP)

			-- Fire client: UpperSlash VFX + Shaker
			ReplicateEffects_Set:FireAllClients("AerialSlash", {
				Char      = Character,
				Stage     = "slash_fx",
				HRPCFrame = HumRP.CFrame
			})

			-- Hitbox: 15×10×11 at 0,0,-7
			local hbCFrame = HumRP.CFrame * CFrame.new(0, 0, -7)
			local hbSize   = Vector3.new(15, 10, 11)

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

				-- 25 damage
				DamageHandler:TakeDamage(Character, EnemyHumanoid, 25, nil, nil, true, true, true, true, true, nil, nil)

				-- Launch enemy up + hold + drop (same as attacker)
				launchAndHold(EnemyHumRP)

				-- Fire hit VFX to client
				ReplicateEffects_Set:FireAllClients("AerialSlash", {
					Char      = Character,
					Stage     = "hit",
					Victim    = EnemyCharacter,
					VictimPos = EnemyHumRP.Position
				})
			end

			Cleanup()
		end)

		Janitor:Add(AnimTrack.Stopped:Connect(function()
			Cleanup()
		end))
	end
}