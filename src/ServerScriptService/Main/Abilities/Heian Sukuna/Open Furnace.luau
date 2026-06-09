local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
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
local CollisionsModule = require(ServerModules.CollisionsModule)
local SoundsModule = require(ServerModules.SoundsModule)

local Trove = require(ReplicatedModules.Trove)

local Sounds = ServerStorage.Assets.Sounds
local Animations = ServerStorage.Assets.Animations
local MoveAnims = Animations.Moves
local MoveSounds = Sounds.Moves

local ReplicateEffects_Set = RemotesContainer.Replicate.Set

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		local StartAnimation = MoveAnims.Heian["Fuga"].Cast
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}

		StartEvents["Clap"] = StartTrack:GetMarkerReachedSignal("Function"):Connect(function(params)
			if params == "Clap" then
				ReplicateEffects_Set:FireAllClients("HeianFuga", { char = Character, stage = "Clap", id = StartAnimation.AnimationId })
				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 2 })

			elseif params == "Clap2" then
				ReplicateEffects_Set:FireAllClients("HeianFuga", { char = Character, stage = "Clap2" })
				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 2.5 })

			elseif params == "Arrow" then
				ReplicateEffects_Set:FireAllClients("HeianFuga", { char = Character, stage = "Arrow" })

			elseif params == "Hitbox" then
				ReplicateEffects_Set:FireAllClients("HeianFuga", { char = Character, stage = "Hitbox" })
				ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 4, Last = 0.5 })

				-- [[ Arrow projectile velocity ]]:
				local Arrow = Instance.new("Part")
				Arrow.Size = Vector3.new(1, 1, 1)
				Arrow.Transparency = 1
				Arrow.CanCollide = false
				Arrow.CFrame = HumRP.CFrame
				Arrow.Parent = workspace.Effects

				local vel = Instance.new("BodyVelocity", Arrow)
				vel.MaxForce = Vector3.new(1, 1, 1) * 1000000
				vel.Velocity = HumRP.CFrame.LookVector * 192
				vel.Name = "SmallMoveVel"
				Debris:AddItem(vel, 2)

				task.wait(1)

				-- [[ Explosion hitbox ]]:
				local hitContent = workspace:GetPartBoundsInBox(Arrow.CFrame, Vector3.new(25, 41, 25))
				local hitList = {}
				for _, v in pairs(hitContent) do
					local EnemyHumanoid = v.Parent:FindFirstChildOfClass("Humanoid")
					if EnemyHumanoid and v.Parent ~= Character and not hitList[EnemyHumanoid] then
						local EnemyHumRP = v.Parent:FindFirstChild("HumanoidRootPart")
						if EnemyHumRP and not EnemyHumRP.Anchored then
							if iFramesService:HasiFrame(v.Parent, Tool.Name) or EnemyHumanoid.Health <= 0 then continue end
							hitList[EnemyHumanoid] = true

							DamageHandler:TakeDamage(Character, EnemyHumanoid, 45, nil, nil, false, false, true, true, true, nil, nil)
							RagdollHandler.ragdoll(EnemyHumanoid, 3)
							NewKnockback:Knockback(v.Parent, {
								KnockbackType = "Velocity",
								MaxForce = Vector3.new(1, 1, 1) * math.huge,
								Velocity = (v.Parent.HumanoidRootPart.Position - Arrow.Position).Unit * 60 + Vector3.new(0, 30, 0)
							})
						end
					end
				end

				Debris:AddItem(Arrow, 0)
			end
		end)

		StartTrack.Stopped:Once(function()
			for _, v in StartEvents do v:Disconnect() end
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)

		ReplicateEffects_Set:FireAllClients("HeianFuga", { char = Character, stage = "Start", id = StartAnimation.AnimationId })
	end
}