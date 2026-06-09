local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerModules = ServerStorage.Modules
local ReplicatedModules = ReplicatedStorage.Modules
local RemotesContainer = ReplicatedStorage.Remotes

local StunHandler     = require(ServerModules.StunHandler)
local DamageHandler   = require(ServerModules.DamageHandler)
local RagdollHandler  = require(ServerModules.RagdollHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService  = require(ServerModules.iFramesService)
local Trove           = require(ReplicatedModules.Trove)

local services = require(ReplicatedStorage.Services)
local knockbackService = services:GetService("KnockbackService")

local MoveAnims = ServerStorage.Assets.Animations.Moves.Vergil["Upper Slash"]

local ReplicateEffects_Set = RemotesContainer.Replicate.Set


return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Janitor = Trove.new()
		local AttackerStun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		local UpperAnimation = MoveAnims.Animation
		local UpperTrack = AnimationService:getAnimationTrack(Character, UpperAnimation)
		local UpperEvents = {}

		local function Cleanup()
			StunHandler:Unstun(Character, AttackerStun)
			Janitor:Destroy()
		end


		-- Fire client: spawn arm VFX immediately
		ReplicateEffects_Set:FireAllClients("UpperSlash", {
			Char = Character,
			Stage = "pa",
			Animation = UpperAnimation.AnimationId
		})


		-- "Stop" marker: freeze anim, fire hitbox + main VFX
		UpperEvents["Stop"] = Janitor:Add(UpperTrack:GetMarkerReachedSignal("Stop"):Connect(function()
			UpperTrack:AdjustSpeed(0)

			-- 0.2s delay then AoE hitbox
			task.delay(0.2, function()
				if not Character:IsDescendantOf(workspace) then return end

				local hitbox = Instance.new("Part")
				hitbox.Size = Vector3.new(15, 10, 11)
				hitbox.CFrame = HumRP.CFrame * CFrame.new(0, 0, -7)
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

					-- Damage
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 25, nil, nil, false, false, true, true, false, nil, nil)

					-- Launch upward
					knockbackService.Knockback(EnemyHumRP, {
						["duration"] = 0.2,
						["force"] = 55,
						["direction"] = Vector3.new(0, 1, 0)
					})

					-- Ragdoll 1.1s
					RagdollHandler.ragdoll(EnemyHumanoid, 1.1)

					-- Fire blood VFX to client
					ReplicateEffects_Set:FireAllClients("UpperSlash", {
						Char = Character,
						Stage = "hit",
						Victim = EnemyCharacter,
						VictimPos = EnemyHumRP.Position
					})
				end

				-- Fire main slash VFX to client
				ReplicateEffects_Set:FireAllClients("UpperSlash", {
					Char = Character,
					Stage = "slash_fx",
					HRPCFrame = HumRP.CFrame
				})

				-- Resume anim after 0.4s
				task.delay(0.4, function()
					if not Character:IsDescendantOf(workspace) then return end
					UpperTrack:AdjustSpeed(1.1)

					-- Restore movement + fire idk VFX after 0.3s more
					task.delay(0.3, function()
						if not Character:IsDescendantOf(workspace) then return end

						ReplicateEffects_Set:FireAllClients("UpperSlash", {
							Char = Character,
							Stage = "idk_fx"
						})

						Cleanup()
					end)
				end)
			end)
		end))


		UpperTrack.Stopped:Once(function()
			for _, v in UpperEvents do v:Disconnect() end
			Cleanup()
		end)


		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UpperAnimation)
		UpperTrack:AdjustSpeed(1.5)
	end
}