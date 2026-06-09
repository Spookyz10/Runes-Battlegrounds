local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules = ServerStorage.Modules
local ReplicatedModules = ReplicatedStorage.Modules
local RemotesContainer = ReplicatedStorage.Remotes

local StunHandler     = require(ServerModules.StunHandler)
local DamageHandler   = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService  = require(ServerModules.iFramesService)
local Trove           = require(ReplicatedModules.Trove)

local MoveAnims = ServerStorage.Assets.Animations.Moves.Vergil["Void Slash"]

local ReplicateEffects_Set = RemotesContainer.Replicate.Set


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Janitor = Trove.new()
		local AttackerStun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		Humanoid.AutoRotate = false

		local VoidAnimation = MoveAnims.Animation
		local VoidTrack = AnimationService:getAnimationTrack(Character, VoidAnimation)
		local VoidEvents = {}

		local function Cleanup()
			Humanoid.AutoRotate = true
			StunHandler:Unstun(Character, AttackerStun)
			Janitor:Destroy()
		end


		-- Fire client to begin arm VFX sequence + sound
		ReplicateEffects_Set:FireAllClients("VoidSlash", {
			Char = Character,
			Stage = "pa",
			Animation = VoidAnimation.AnimationId
		})


		-- "Start2": speed up anim
		VoidEvents["Start2"] = Janitor:Add(VoidTrack:GetMarkerReachedSignal("Start2"):Connect(function()
			VoidTrack:AdjustSpeed(1.5)
		end))


		-- "Stop": freeze anim, fire AoE hitbox, fire main slash VFX to client
		VoidEvents["Stop"] = Janitor:Add(VoidTrack:GetMarkerReachedSignal("Stop"):Connect(function()
			VoidTrack:AdjustSpeed(0)

			-- Collect all enemies in AoE right now
			local hitbox = Instance.new("Part")
			hitbox.Size = Vector3.new(45, 10, 45)
			hitbox.CFrame = HumRP.CFrame
			hitbox.Anchored = true
			hitbox.CanCollide = false
			hitbox.CanTouch = false
			hitbox.CanQuery = false
			hitbox.Transparency = 1
			hitbox.Parent = workspace
			Debris:AddItem(hitbox, 0.1)

			local hitList = {}
			for _, part in workspace:GetPartBoundsInBox(hitbox.CFrame, hitbox.Size) do
				local EnemyCharacter = part.Parent
				if not EnemyCharacter:IsA("Model") then continue end
				local EnemyHumanoid: Humanoid = EnemyCharacter:FindFirstChildOfClass("Humanoid")
				local EnemyHumRP: BasePart = EnemyCharacter:FindFirstChild("HumanoidRootPart")
				if not EnemyHumanoid or not EnemyHumRP then continue end
				if EnemyCharacter == Character then continue end
				if hitList[EnemyHumanoid] then continue end
				if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then continue end
				if EnemyHumanoid.Health <= 0 then continue end
				hitList[EnemyHumanoid] = true

				-- Stun for 2.05s then damage + blood
				StunHandler:Stun(EnemyCharacter, 2.05, true, 0, 0, true)

				task.delay(2.05, function()
					if not EnemyCharacter:IsDescendantOf(workspace) then return end
					if EnemyHumanoid.Health <= 0 then return end
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 25, nil, nil, false, false, true, true, false, nil, nil)
					ReplicateEffects_Set:FireAllClients("VoidSlash", {
						Char = Character,
						Stage = "hit_damage",
						Victim = EnemyCharacter,
						VictimHRPPos = EnemyHumRP.Position
					})
				end)
			end

			-- Fire main slash VFX
			ReplicateEffects_Set:FireAllClients("VoidSlash", {
				Char = Character,
				Stage = "slash_fx",
				HRPCFrame = HumRP.CFrame
			})

			-- Resume anim slowly after 1.3s
			task.delay(1.3, function()
				if not Character:IsDescendantOf(workspace) then return end
				VoidTrack:AdjustSpeed(0.25)

				-- Boom phase after another 0.75s
				task.delay(0.75, function()
					if not Character:IsDescendantOf(workspace) then return end
					ReplicateEffects_Set:FireAllClients("VoidSlash", {
						Char = Character,
						Stage = "boom",
						HRPCFrame = HumRP.CFrame
					})

					-- Restore attacker after 0.5s
					task.delay(0.5, function()
						if not Character:IsDescendantOf(workspace) then return end
						Cleanup()
					end)
				end)
			end)
		end))


		VoidTrack.Stopped:Once(function()
			for _, v in VoidEvents do v:Disconnect() end
			Cleanup()
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, VoidAnimation)
	end
}