local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local ReplicatedModules = ReplicatedStorage.Shared.Modules
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
local KnockbackModule = require(ServerModules.KnockbackModule)
local ReplicatedHitbox = require(ServerModules.ReplicatedHitboxes)
local StatesHandler = require(ServerModules.StatesHandler)

local Utility = shared.Utility
local WeldSystem = require(ReplicatedModules.WeldSystem)
local Trove = require(ReplicatedModules.Trove)

local Sounds = ServerStorage.Assets.Sounds
local Animations = ServerStorage.Assets.Animations
local Models = ServerStorage.Assets.Models

local Weapons = Models.Weapons
local MoveAnims = Animations.Moves
local MoveSounds = Sounds.Moves

local ComSet = RemotesContainer.Comunicator.Set
local ComGet = RemotesContainer.Comunicator.Get

local ReplicateEffects_Set = RemotesContainer.Replicate.Set

local rad = math.rad
local StartAirDetect = ServerStorage.Bindables.AirDetector

local Assets = shared.Assets

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = { workspace.Map }
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local HumRP: BasePart = Character.HumanoidRootPart
		local Humanoid: Humanoid = Character.Humanoid

		local UserAnimation = MoveAnims.BaldHero.Uppercut.User
		local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
		local UserEvents = {}

		local limbNames = { "Right Arm", "Left Arm", "Right Leg", "Left Leg" }

		for i, v in Character:GetChildren() do
			if v:IsA("BasePart") then
				if table.find(limbNames, v.Name) then
					ReplicateEffects_Set:FireAllClients(
						"armTrailEffect",
						{ char = Character, lifeTime = 1, limbName = v.Name }
					)
				end
			end
		end

		local Stun = StunHandler:Stun(Character, 1.11, false, 0, 0, false)

		local Hit = false

		UserEvents["swing"] = UserTrack:GetMarkerReachedSignal("swing"):Once(function() end)

		UserEvents["step"] = UserTrack:GetMarkerReachedSignal("step"):Once(function()
			local forwardDirection = HumRP.CFrame.LookVector * 15
			local upwardDirection = Vector3.new(0, 40, 0)

			local combinedVelocity = forwardDirection + upwardDirection

			local thrust = Instance.new("BodyVelocity")
			thrust.Velocity = combinedVelocity
			thrust.P = 1000
			thrust.MaxForce = Vector3.new(8000, 8000, 8000)
			thrust.Parent = HumRP

			Debris:AddItem(thrust, 0.3)

			SoundsModule:PlaySound(MoveSounds.Baldhero.Uppercut.Swing, HumRP)
		end)

		UserEvents["prepare"] = UserTrack:GetMarkerReachedSignal("prepare"):Once(function()
			local SmokeVFX = Models["Uppercut VFX"].SmokeUp:Clone()
			SmokeVFX.Parent = workspace.Thrown
			local downOffset = Character.PrimaryPart.Size.Y / 2 + 1
			SmokeVFX.CFrame = Character.PrimaryPart.CFrame * CFrame.new(0, -downOffset, 0)

			Debris:AddItem(SmokeVFX, 1)

			task.spawn(function()
				for _, descendant in SmokeVFX:GetDescendants() do
					if descendant:IsA("ParticleEmitter") then
						descendant.Enabled = true
					end
				end
			end)

			SoundsModule:PlaySound(MoveSounds.Baldhero.Uppercut.SmokeOne, HumRP)
		end)

		UserEvents["stance"] = UserTrack:GetMarkerReachedSignal("stance"):Once(function()
			local SmokeVFX = Models["Uppercut VFX"].SmokeUpTwo:Clone()
			SmokeVFX.Parent = workspace.Thrown
			local downOffset = Character.PrimaryPart.Size.Y / 2 + 1
			SmokeVFX.CFrame = Character.PrimaryPart.CFrame * CFrame.new(0, -downOffset, 0)

			Debris:AddItem(SmokeVFX, 1)

			task.spawn(function()
				for _, descendant in SmokeVFX:GetDescendants() do
					if descendant:IsA("ParticleEmitter") then
						descendant.Enabled = true
					end
				end
			end)

			SoundsModule:PlaySound(MoveSounds.Baldhero.Uppercut.SmokeTwo, HumRP)
		end)

		UserEvents["hit"] = UserTrack:GetMarkerReachedSignal("hit"):Once(function()
			SoundsModule:PlaySound(MoveSounds.Baldhero.Uppercut.Impact, HumRP)

			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(10, 10, 10)
			Hitbox.Ignore = { Character }
			Hitbox.Offset = CFrame.new(0, 0, -Hitbox.Size.Z / 2)
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = game.Players:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if
					Hit == true
					or iFramesService:HasiFrame(EnemyCharacter, Tool.Name)
					or EnemyHumanoid.Health <= 0
					or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead
				then
					return
				end

				local HitInfo =
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 10, nil, nil, false, true, true, true, true, nil)

				if HitInfo.Countered == true then
					return
				end

				Hit = true

				if EnemyCharacter:HasTag("Ragdolled") then
					RagdollHandler.cancelRagdoll(EnemyHumanoid)
				end

				if HitInfo.Finisher == true then
					KnockbackModule:Knockback(
						EnemyCharacter,
						HumRP.CFrame.LookVector * 115,
						Character,
						nil,
						nil,
						nil,
						true,
						true
					)
					NewKnockback:makeEnemyFaceCharacter(EnemyCharacter, Character)
					NewKnockback:Knockback(
						EnemyCharacter,
						{
							KnockbackType = "Velocity",
							MaxForce = Vector3.new(1, 1, 1) * math.huge,
							Velocity = Vector3.new(HumRP.CFrame.LookVector.X * 30, 800, HumRP.CFrame.LookVector.Z * 30),
							Time = 0.4,
						}
					)

					ReplicateEffects_Set:FireAllClients(
						"Ground Crater",
						{
							Seed = math.random(1, 2000000000),
							start = Character.PrimaryPart.Position,
							["end"] = Vector3.new(0, -7, 0),
							nodebris = true,
							amount = math.random(6, 8),
							nosound = true,
						}
					)
					ReplicateEffects_Set:FireAllClients(
						"Ground Crater",
						{
							Seed = math.random(1, 2000000000),
							start = Character.PrimaryPart.Position,
							["end"] = Vector3.new(0, -7, 0),
							nodebris = true,
							amount = math.random(8, 10),
							sizemult = 2.5,
							size = 4,
							nosound = true,
						}
					)
					shared.fireTo(
						ReplicateEffects_Set,
						{ Player, EnemyPlayer },
						{ "ShakeCamera", { Intensity = 8, Last = 1 } }
					)

					SoundsModule:PlaySound(MoveSounds.Baldhero.Uppercut["Finisher Impact"], HumRP)
				else
					require(ServerStorage.Modules.PerfectKnockback).KnockBack(nil, EnemyCharacter, {
						LookVector = HumRP.CFrame.LookVector,
						LookForce = 20,
						LookFinalForce = 40,
						EscapableCooldown = 5,
						UpVelocityTime = 0.2,
						LookAt = CFrame.lookAt(
							(HumRP.CFrame * CFrame.new(0, 0, -1) * CFrame.Angles(0, math.pi, 0)).Position,
							HumRP.Position
						),
						UpVelocity = Vector3.new(0, 85, 0),
						DestroyRagdoll = true,
						GroundStunTime = 1.2,
						Escapable = true,
						Saitama = true,
					}, Character)

					shared.fireTo(
						ReplicateEffects_Set,
						{ Player, EnemyPlayer },
						{ "ShakeCamera", { Intensity = 1, Last = 1 } }
					)
					SoundsModule:PlaySound(MoveSounds.Baldhero.Uppercut.Hit, HumRP)
				end
			end

			Hitbox:Once()
			Hitbox:Destroy()
		end)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			StunHandler:Unstun(Character, Stun)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)

		StatesHandler.SkillText(Player, "UPPERCUT [USED]")
	end,
}
