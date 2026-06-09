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

		local Assets = ReplicatedStorage.Resources.Heian.Shrine
		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		local StartAnimation = MoveAnims.Heian["Shrine"].Cast
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)
		local StartEvents = {}

		StartEvents["Function"] = StartTrack:GetMarkerReachedSignal("Function"):Connect(function(params)
			if params == "Domain" then

				-- [[ Fire domain warn + VFX to all clients ]]:
				ReplicateEffects_Set:FireAllClients("HeianShrine", {
					char = Character,
					stage = "Domain",
					id = StartAnimation.AnimationId,
				})

				-- [[ Fire domain warn UI only to caster ]]:
				ReplicateEffects_Set:FireClient(Player, "HeianShrineDomain", {
					char = Character,
				})

				-- [[ Shrine spawn ]]:
				local Shrine = Assets.Shrine:Clone()
				Shrine:PivotTo(HumRP.CFrame * CFrame.new(0, 11, 20))
				Shrine.Parent = workspace.Effects
				Debris:AddItem(Shrine, 13)

				-- [[ Slash hitbox loop — 100 ticks every 0.1s ]]:
				local Slashes = Assets.Slashes:Clone()
				Slashes.CFrame = Shrine["the mouth"].CFrame
				Slashes.Parent = workspace.Effects
				Debris:AddItem(Slashes, 11)

				for _, particle in pairs(Slashes:GetChildren()) do
					if particle:IsA("ParticleEmitter") then
						particle.Enabled = true
					end
				end

				task.spawn(function()
					for i = 1, 100 do
						task.wait(0.1)
						if not Slashes or not Slashes.Parent then break end

						local hitContent = workspace:GetPartBoundsInBox(Slashes.CFrame, Vector3.new(500, 100, 500))
						local hitList = {}
						for _, v in pairs(hitContent) do
							local EnemyHumanoid = v.Parent:FindFirstChildOfClass("Humanoid")
							local EnemyHumRP = v.Parent:FindFirstChild("HumanoidRootPart")
							if EnemyHumanoid and EnemyHumRP and v.Parent ~= Character and not EnemyHumRP.Anchored then
								if not hitList[EnemyHumanoid] and EnemyHumanoid.Health > 0 then
									hitList[EnemyHumanoid] = true

									DamageHandler:TakeDamage(Character, EnemyHumanoid, 3, nil, nil, false, false, false, true, false, nil, nil)

									local BV = Instance.new("BodyVelocity", v.Parent.Torso)
									BV.MaxForce = Vector3.new(1, 1, 1) * 1000000
									BV.Velocity = Vector3.new(0, 0, 0)
									BV.Name = "SmallMoveVel"
									Debris:AddItem(BV, 0.1)

									ReplicateEffects_Set:FireAllClients("HeianShrineHit", {
										char = Character,
										target = v.Parent,
									})
								end
							end
						end
					end
				end)

				task.delay(12, function()
					ReplicateEffects_Set:FireAllClients("HeianShrine", { char = Character, stage = "End" })
					ReplicateEffects_Set:FireClient(Player, "HeianShrineDomain", { char = Character, stage = "End" })
				end)
			end
		end)

		StartTrack.Stopped:Once(function()
			for _, v in StartEvents do v:Disconnect() end
			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)

		ReplicateEffects_Set:FireAllClients("HeianShrine", { char = Character, stage = "Start", id = StartAnimation.AnimationId })
	end
}