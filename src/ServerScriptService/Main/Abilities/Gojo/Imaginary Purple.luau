local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayersService = game:GetService("Players")

local ServerModules = ServerStorage.Modules

local ReplicatedModules = ReplicatedStorage.Modules
local RemotesContainer = ReplicatedStorage.Remotes

local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local RagdollHandler = require(ServerModules.RagdollHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local CollisionsModule = require(ServerModules.CollisionsModule)

local Trove = require(ReplicatedModules.Trove)

local services = require(ReplicatedStorage.Services)
local knockbackService = services:GetService("KnockbackService")

local ReplicateEffects_Set = RemotesContainer.Replicate.Set

local GojoV2Anims = ReplicatedStorage.Resources.GojoV2.Animations
local GojoV2Effects = ReplicatedStorage.Resources.GojoV2.Effects

return {
	Start = function(Player: Player, Tool: Tool)
		local Character = Player.Character
		local Humanoid: Humanoid = Character.Humanoid
		local HumRP: BasePart = Character.HumanoidRootPart

		local Janitor = Trove.new()

		local Stun = StunHandler:Stun(Character, nil, true, 0, 0, true)

		-- Play ultimate anim
		local StartAnimation = GojoV2Anims.StrongestMasteryAwakening
		local StartTrack = AnimationService:getAnimationTrack(Character, StartAnimation)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, StartAnimation)

		-- Fire startup VFX to all clients (SummonB, ImaginaryPurple model, sound)
		ReplicateEffects_Set:FireAllClients("Murasaki", {
			Char = Character,
			Stage = "Startup",
			HRPCFrame = HumRP.CFrame
		})

		-- "Stop" marker - slow anim to crawl
		local StopEvent = Janitor:Add(StartTrack:GetMarkerReachedSignal("Stop"):Connect(function()
			StartTrack:AdjustSpeed(6)
		end))

		-- +0.5s - SummonR
		task.delay(0.5, function()
			if not Character:IsDescendantOf(workspace) then return end
			ReplicateEffects_Set:FireAllClients("Murasaki", {
				Char = Character,
				Stage = "SummonR",
				HRPCFrame = HumRP.CFrame
			})
		end)

		-- +1.5s - white flash
		task.delay(1.5, function()
			if not Character:IsDescendantOf(workspace) then return end
			ReplicateEffects_Set:FireAllClients("Murasaki", {
				Char = Character,
				Stage = "WhiteFlash1"
			})
		end)

		-- +4s - Wind effect
		task.delay(4, function()
			if not Character:IsDescendantOf(workspace) then return end
			ReplicateEffects_Set:FireAllClients("Murasaki", {
				Char = Character,
				Stage = "Wind",
				HRPCFrame = HumRP.CFrame
			})
		end)

		-- +6.3s - AutoRotate back, RightArm VFX, vignette
		task.delay(6.3, function()
			if not Character:IsDescendantOf(workspace) then return end

			StunHandler:Unstun(Character, Stun)
			Stun = StunHandler:Stun(Character, nil, true, 0, 0, true) -- re-stun partially (walk still locked until shoot)

			ReplicateEffects_Set:FireAllClients("Murasaki", {
				Char = Character,
				Stage = "RightArm",
				HRPCFrame = HumRP.CFrame
			})

			-- Fire vignette only to the attacker
			RemotesContainer.Replicate.Set:FireClient(Player, "Murasaki", {
				Char = Character,
				Stage = "Vignette"
			})

			-- +3s later - anim speed back to normal
			task.delay(3, function()
				if not Character:IsDescendantOf(workspace) then return end
				StartTrack:AdjustSpeed(1)

				-- +0.6s - fire the ball
				task.delay(0.6, function()
					if not Character:IsDescendantOf(workspace) then return end

					-- Fire white flash + ball VFX to all clients
					ReplicateEffects_Set:FireAllClients("Murasaki", {
						Char = Character,
						Stage = "HollowPurple",
						HRPCFrame = HumRP.CFrame,
						LookVector = HumRP.CFrame.LookVector
					})

					-- Spawn the actual HollowPurple ball on server for hitbox
					local HollowPurple = GojoV2Effects.YoungGojo.Murasaki.HollowPurple:Clone()
					Debris:AddItem(HollowPurple, 10)

					local BallVelocity = Instance.new("LinearVelocity")
					local BallAttachment = Instance.new("Attachment")
					BallAttachment.Parent = HollowPurple
					BallVelocity.Attachment0 = BallAttachment
					BallVelocity.MaxForce = math.huge
					BallVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
					BallVelocity.PrimaryTangentAxis = HumRP.CFrame.LookVector
					BallVelocity.SecondaryTangentAxis = HumRP.CFrame.RightVector
					BallVelocity.PlaneVelocity = Vector2.new(250, 0)
					BallVelocity.Parent = HollowPurple

					HollowPurple.CFrame = HumRP.CFrame * CFrame.new(0, 10, -10)
					HollowPurple.Parent = workspace.Visuals

					local AlreadyHit = {}
					local TouchConn
					TouchConn = HollowPurple.Touched:Connect(function(hit)
						if not hit.Parent then return end
						local EnemyCharacter = hit.Parent
						local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")

						if EnemyHumanoid and EnemyCharacter ~= Character and not AlreadyHit[EnemyCharacter] then
							AlreadyHit[EnemyCharacter] = true

							if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then return end
							if EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then return end

							DamageHandler:TakeDamage(Character, EnemyHumanoid, 100, nil, nil, false, false, false, true, false, nil, nil)

							local at = HumRP.Position
							local forward = HumRP.CFrame.LookVector
							local lookposition = CFrame.lookAt(at, at + Vector3.new(forward.X, 0, forward.Z))

							require(ServerModules.PerfectKnockback).KnockBack(nil, EnemyCharacter, {
								LookVector = lookposition.LookVector,
								LookForce = 150,
								LookFinalForce = 130,
								LookAt = lookposition,
								DestroyRagdoll = true,
								GroundStunTime = 3,
								Escapable = false,
								FallingDetectDelay = 0.2,
								Dot = 1,
								DotParams = { 0.4, 1 },
								canHitWall = true
							}, Character)

							ReplicateEffects_Set:FireAllClients("Murasaki", {
								Char = Character,
								Stage = "BallHit",
								HRPCFrame = HollowPurple.CFrame
							})
						end
					end)

					-- Cleanup after ball expires
					task.delay(10, function()
						if TouchConn then TouchConn:Disconnect() end
					end)

					-- +7s after startup - Land effect at attacker position
					-- (this was wait(7) from the start of the move in the original)
					-- Already handled in VFX via task.delay below
					ReplicateEffects_Set:FireAllClients("Murasaki", {
						Char = Character,
						Stage = "Cleanup"
					})

					-- Restore attacker
					StunHandler:Unstun(Character, Stun)
					Janitor:Destroy()
				end)
			end)
		end)

		-- +7s from start - Land
		task.delay(7, function()
			if not Character:IsDescendantOf(workspace) then return end
			ReplicateEffects_Set:FireAllClients("Murasaki", {
				Char = Character,
				Stage = "Land",
				HRPCFrame = HumRP.CFrame
			})
		end)
	end
}