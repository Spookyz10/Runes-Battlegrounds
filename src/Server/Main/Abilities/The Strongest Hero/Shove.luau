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

		local limbNames = { "Right Arm", "Left Arm", "Right Leg", "Left Leg" }

		StunHandler:Stun(Character, 0.4, true)
		iFramesService:AddAlliFrames(Character)

		for i, v in Character:GetChildren() do
			if v:IsA("BasePart") then
				if table.find(limbNames, v.Name) then
					ReplicateEffects_Set:FireAllClients(
						"armTrailEffect",
						{ char = Character, lifeTime = 0.45, limbName = v.Name }
					)
				end
			end
		end

		local Hit = false

		local UserAnimation = MoveAnims.BaldHero.Shove.User
		local UserTrack = AnimationService:getAnimationTrack(Character, UserAnimation)
		local UserEvents = {}

		UserEvents["startup"] = UserTrack:GetMarkerReachedSignal("startup"):Once(function()
			SoundsModule:PlaySound(MoveSounds.Baldhero.Shove.Swing, HumRP)
		end)

		UserEvents["swing"] = UserTrack:GetMarkerReachedSignal("swing"):Once(function()
			SoundsModule:PlaySound(MoveSounds.Baldhero.Shove["Swing Second"], HumRP)
		end)

		UserEvents["hit"] = UserTrack:GetMarkerReachedSignal("hit"):Once(function()
			SoundsModule:PlaySound(MoveSounds.Baldhero.Shove["Hit Swing"], HumRP)

			local Hitbox = HitboxHandler.new()
			Hitbox.Instance = HumRP
			Hitbox.Size = Vector3.new(5, 35, 5)
			Hitbox.Offset = CFrame.new(0, 0, -Hitbox.Size.Z / 2)
			Hitbox.Ignore = { Character }
			Hitbox.onTouch = function(EnemyCharacter)
				local EnemyPlayer = game.Players:GetPlayerFromCharacter(EnemyCharacter)
				local EnemyHumRP: BasePart = EnemyCharacter.HumanoidRootPart
				local EnemyHumanoid: Humanoid = EnemyCharacter.Humanoid

				if
					iFramesService:HasiFrame(EnemyCharacter, Tool.Name)
					or EnemyHumanoid.Health <= 0
					or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead
					or (EnemyCharacter:HasTag("Ragdolled") and not EnemyCharacter:FindFirstChild("inAir"))
				then
					return
				end

				local HitInfo =
					DamageHandler:TakeDamage(Character, EnemyHumanoid, 10, nil, false, false, false, false, true, true)

				if HitInfo.Finisher == true then
					for index, part in pairs(EnemyCharacter:GetDescendants()) do
						if part:IsA("BasePart") then
							part.Transparency = 1
						elseif part:IsA("Decal") then
							part:Destroy()
						end
					end

					local BodyVelocity = Instance.new("BodyVelocity")
					BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					BodyVelocity.Velocity = Character.PrimaryPart.CFrame.LookVector * 10
					BodyVelocity.Parent = EnemyCharacter.Head
					Debris:AddItem(BodyVelocity, 0.15)

					ReplicateEffects_Set:FireAllClients("shoveFinish", { Char = EnemyCharacter })

					RagdollHandler.ragdoll(EnemyHumanoid, 3)
					DamageHandler:TakeDamage(
						Character,
						EnemyHumanoid,
						EnemyHumanoid.Health,
						nil,
						false,
						false,
						false,
						false,
						true,
						true
					)

					SoundsModule:PlaySound(MoveSounds.Baldhero.Shove.Finisher, HumRP)

					EnemyCharacter["Right Leg"].Transparency = 0
					EnemyCharacter["Left Leg"].Transparency = 0
				else
					EnemyHumRP.AssemblyLinearVelocity = Vector3.zero

					local selfToOtherChar = (EnemyHumRP.Position - HumRP.Position).Unit
					local lookVector = Character.HumanoidRootPart.CFrame.LookVector

					local dotProduct = lookVector:Dot(selfToOtherChar)
					if EnemyHumanoid.FloorMaterial ~= Enum.Material.Air then
						dotProduct = 1
					end

					local at = Character.HumanoidRootPart.Position
					local forward = Character.HumanoidRootPart.CFrame.LookVector
					local lookposition = CFrame.lookAt(at, at + Vector3.new(forward.X, 0, forward.Z))

					require(ServerStorage.Modules.PerfectKnockback).KnockBack(nil, EnemyCharacter, {
						LookVector = lookposition.LookVector,
						LookForce = 58.5,
						LookFinalForce = 55,
						LookAt = lookposition,
						DestroyRagdoll = true,
						GroundStunTime = 0.95,
						Escapable = false,
						FallingDetectDelay = 0.2,
						Dot = dotProduct,
						DotParams = { 0.4, 1 },
						canHitWall = true,
					}, Character)

					StunHandler:Stun(EnemyCharacter, 5, true, 0.5, 0, true)

					SoundsModule:PlaySound(MoveSounds.Baldhero.Shove.Hit, HumRP)
					SoundsModule:PlaySound(MoveSounds.Baldhero.Shove.HitTwo, EnemyHumRP)

					if EnemyCharacter:HasTag("Ragdolled") then
						task.delay(0.275, function()
							ReplicateEffects_Set:FireAllClients(
								"collisionWall",
								{ root = EnemyHumRP, AccurateCheck = {} }
							)
						end)
					end
				end

				if EnemyCharacter:HasTag("Ragdolled") then
					Hit = true

					RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, nil, nil, false, true)
				else
					Hit = true

					task.delay(0.1, function()
						if not Hit then
							StunHandler:Stun(Character, 0.317, true)
						end
					end)
				end

				ReplicateEffects_Set:FireAllClients(
					"Ring",
					{
						FirstProps = { Size = Vector3.new(6, 6, 6), Transparency = 0 },
						CF = HumRP.CFrame * CFrame.Angles(math.rad(90), 0, 0),
						TN_Info = { Time = 0.30, Style = "Sine", Direction = "Out" },
						FinalProps = { Size = Vector3.new(19, 0.1, 19), Transparency = 1 },
					}
				)
				if EnemyPlayer then
					ReplicateEffects_Set:FireClient(EnemyPlayer, "ShakeCamera", { Intensity = 0.75, Last = 0.2 })
				end
			end

			task.delay(0.033, function()
				Hitbox:Once()
				Hitbox:Destroy()

				if Hit then
					ReplicateEffects_Set:FireClient(Player, "ShakeCamera", { Intensity = 0.75, Last = 0.2 })
				end
			end)
		end)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			iFramesService:RemoveAlliFrames(Character)
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)

		StatesHandler.SkillText(Player, "SHOVE [USED]")
	end,
}
