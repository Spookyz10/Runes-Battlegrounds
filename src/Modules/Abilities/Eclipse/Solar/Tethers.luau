local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ServerModules = ServerStorage.Modules
local ReplicatedModules = ReplicatedStorage.Shared.Modules

local StunHandler = require(ServerModules.StunHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local AnimationService = require(ServerModules.AnimationService)
local iFramesService = require(ServerModules.iFramesService)
local RagdollHandler = require(ServerModules.RagdollHandler)
local PerfectKnockback = require(ServerModules.PerfectKnockback)
local SkillCollision = require(ServerModules.SkillCollision)
local WeldSystem = require(ReplicatedModules.WeldSystem)
local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local SFX = require(ServerModules.SFXModule)

local MoveAnims = ServerStorage.Assets.Animations.Moves

local SEARCH_RADIUS = 300
local DAMAGE = 15
local KICK_VELOCITY = Vector3.new(0, 30, 0)
local KICK_HORIZONTAL_FORCE = 85
local WELD_OFFSET = CFrame.new(0, 0, -3) * CFrame.Angles(0, math.pi, 0)
local PULL_OFFSET = Vector3.new(0, 0, -4)
local PULL_TIME = 0.5
local WELD_TIME = 0.15
local MAX_PULL_WAIT = 6
local CLOSE_DISTANCE = 5
local HITBOX_SIZE = Vector3.new(10, 10, 10)
local HITBOX_OFFSET = CFrame.new(0, 0, -5)

local CHAIN_TRAVEL_TIME = 0.35
local AIR_SLOW_FACTOR = 0.12

local MIN_AIR_HEIGHT = 6

local GroundRayParams = RaycastParams.new()
GroundRayParams.FilterType = Enum.RaycastFilterType.Include
GroundRayParams.FilterDescendantsInstances = { workspace.Map }
GroundRayParams.IgnoreWater = true

local function isInAir(EnemyCharacter)
	local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
	if not EnemyHumRP then
		return false
	end

	local RayResult = workspace:Raycast(EnemyHumRP.Position, Vector3.new(0, -500, 0), GroundRayParams)
	if not RayResult then
		return true
	end

	local heightAboveGround = EnemyHumRP.Position.Y - RayResult.Position.Y
	return heightAboveGround >= MIN_AIR_HEIGHT
end

local function cancelAllKnockbackStates(EnemyCharacter)
	local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
	local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")

	PerfectKnockback:Cancel(EnemyCharacter)

	if EnemyHumRP then
		for _, v in EnemyCharacter:GetDescendants() do
			if
				v:IsA("BodyVelocity")
				or v:IsA("BodyAngularVelocity")
				or v:IsA("LinearVelocity")
				or v:IsA("AngularVelocity")
				or v:IsA("VectorForce")
				or v:IsA("Torque")
				or v:IsA("BodyPosition")
				or v:IsA("BodyGyro")
			then
				v:Destroy()
			end
		end

		for _, v in EnemyCharacter:GetDescendants() do
			if v:IsA("BasePart") then
				v.AssemblyLinearVelocity = Vector3.zero
				v.AssemblyAngularVelocity = Vector3.zero
			end
		end
	end

	if EnemyCharacter:HasTag("Ragdolled") then
		if EnemyHumanoid then
			RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, false, true, true)
		end
	end

	EnemyCharacter:RemoveTag("Knockbacked")

	AnimationService:stopAll(EnemyCharacter)
end

local function doHitEffects(
	Character,
	HumRP,
	closestEnemy,
	EnemyHumanoid,
	EnemyHumRP,
	EnemyPlayer,
	CasterStun,
	VictimStun,
	Tool
)
	StunHandler:Unstun(closestEnemy, VictimStun)
	iFramesService:RemoveAlliFrames(closestEnemy)
	closestEnemy:RemoveTag("CantRotate")
	closestEnemy:RemoveTag("Knockbacked")

	if closestEnemy:HasTag("Ragdolled") then
		RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, false, true, true)
	end

	DamageHandler:TakeDamage(Character, EnemyHumanoid, DAMAGE, nil, nil, true, true, true, true, true, nil, nil)

	EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
	EnemyHumRP.AssemblyAngularVelocity = Vector3.zero

	local kickDir = HumRP.CFrame.LookVector
	local kickFlat = Vector3.new(kickDir.X, 0, kickDir.Z)
	if kickFlat.Magnitude < 0.1 then
		kickFlat = Vector3.new(0, 0, -1)
	else
		kickFlat = kickFlat.Unit
	end

	local lookCF = CFrame.lookAt(EnemyHumRP.Position, EnemyHumRP.Position + kickFlat)

	PerfectKnockback:KnockBack(nil, closestEnemy, {
		LookVector = kickFlat,
		LookForce = KICK_HORIZONTAL_FORCE,
		LookFinalForce = KICK_HORIZONTAL_FORCE,
		LookAt = lookCF,
		UpVelocity = KICK_VELOCITY,
		UpVelocityTime = 0.15,
		GroundStunTime = 1.0,
		FallingDetectDelay = 0.4,
		Dot = 1,
		DontFreeze = false,
	}, Character)

	if EnemyPlayer then
		RemoteManager.FireClient(EnemyPlayer, "ReplicateTask", "ShakeCamera", { Intensity = 4, Last = 0.4 })
	end

	iFramesService:RemoveAlliFrames(Character)
	StunHandler:Unstun(Character, CasterStun)
end

return {
	Start = function(Player, Tool)
		local Character = Player.Character
		if not Character then
			return
		end

		local HumRP = Character:FindFirstChild("HumanoidRootPart")
		local Humanoid = Character:FindFirstChild("Humanoid")
		if not HumRP or not Humanoid then
			return
		end

		local CasterStun = StunHandler:Stun(Character, nil, true, 0, 0, true)
		iFramesService:AddAlliFrames(Character)

		Character:AddTag("CantRotate")
		SkillCollision:Lock(Character)

		local UserAnimation = MoveAnims.Eclipse.Solar.Tethers
		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)

		local closestEnemy = nil
		local EnemyHumanoid = nil
		local EnemyHumRP = nil
		local EnemyPlayer = nil
		local VictimStun = nil

		local pullDone = false
		local hitDone = false
		local Weld = nil
		local rotateConn = nil

		local casterCleaned = false

		local function cleanupCaster()
			if casterCleaned then
				return
			end
			casterCleaned = true

			Character:RemoveTag("CantRotate")
			SkillCollision:Unlock(Character)
		end

		local function stopRotation()
			if rotateConn then
				rotateConn:Disconnect()
				rotateConn = nil
			end
		end

		local function startRotation()
			stopRotation()
			rotateConn = RunService.Heartbeat:Connect(function()
				if not HumRP or not HumRP.Parent or not EnemyHumRP or not EnemyHumRP.Parent then
					stopRotation()
					return
				end
				local targetPos = EnemyHumRP.Position
				local myPos = HumRP.Position
				local dir = targetPos - myPos
				if dir.Magnitude > 0.1 then
					HumRP.CFrame = CFrame.lookAt(myPos, targetPos) * CFrame.new(0, 0, 0)
				end
			end)
		end

		local function cleanupWeld()
			if Weld then
				pcall(function()
					Weld:Stop()
				end)
				Weld = nil
			end
		end

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("pull"):Once(function()
				UserTrack:AdjustSpeed(0)

				SFX:Play("tethersStart", HumRP)

				task.wait(0.2)

				local overlapParams = OverlapParams.new()
				overlapParams.FilterType = Enum.RaycastFilterType.Include
				overlapParams.FilterDescendantsInstances = { workspace.Live }

				local parts = workspace:GetPartBoundsInRadius(HumRP.Position, SEARCH_RADIUS, overlapParams)
				local closestDist = math.huge

				for _, part in parts do
					local char = part.Parent
					if not char or char == Character then
						continue
					end
					local hum = char:FindFirstChild("Humanoid")
					local hrp = char:FindFirstChild("HumanoidRootPart")
					if not hum or not hrp then
						continue
					end
					if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then
						continue
					end
					if iFramesService:HasiFrame(char, Tool.Name) then
						continue
					end
					if not isInAir(char) then
						continue
					end

					local dist = (hrp.Position - HumRP.Position).Magnitude
					if dist < closestDist then
						closestDist = dist
						closestEnemy = char
					end
				end

				if not closestEnemy then
					iFramesService:RemoveAlliFrames(Character)
					StunHandler:Unstun(Character, CasterStun)
					UserTrack:Stop()
					return
				end

				EnemyHumanoid = closestEnemy:FindFirstChild("Humanoid")
				EnemyHumRP = closestEnemy:FindFirstChild("HumanoidRootPart")
				EnemyPlayer = Players:GetPlayerFromCharacter(closestEnemy)

				if not EnemyHumanoid or not EnemyHumRP then
					closestEnemy = nil
					iFramesService:RemoveAlliFrames(Character)
					StunHandler:Unstun(Character, CasterStun)
					UserTrack:Stop()
					return
				end

				do
					local currentVel = EnemyHumRP.AssemblyLinearVelocity
					EnemyHumRP.AssemblyLinearVelocity =
						Vector3.new(currentVel.X * 0.3, math.min(currentVel.Y, 0) * AIR_SLOW_FACTOR, currentVel.Z * 0.3)

					local holdBV = Instance.new("BodyVelocity")
					holdBV.Name = "TetherHold"
					holdBV.MaxForce = Vector3.new(100000, 100000, 100000)
					holdBV.Velocity = Vector3.zero
					holdBV.P = 50000
					holdBV.Parent = EnemyHumRP
					game:GetService("Debris"):AddItem(holdBV, CHAIN_TRAVEL_TIME + 0.05)
				end

				cancelAllKnockbackStates(closestEnemy)

				VictimStun = StunHandler:Stun(closestEnemy, nil, true, 0, 0, true)
				closestEnemy:AddTag("CantRotate")
				closestEnemy:AddTag("Knockbacked")
				SkillCollision:Lock(closestEnemy)

				pcall(function()
					HumRP:SetNetworkOwner(nil)
				end)

				startRotation()

				RemoteManager.FireAllClients("ReplicateTask", "TethersVFX_Start", {
					casterChar = Character,
					victimChar = closestEnemy,
					travelTime = CHAIN_TRAVEL_TIME,
				})

				SFX:Play("tethersChains", EnemyHumRP)

				task.wait(CHAIN_TRAVEL_TIME)

				if pullDone then
					return
				end
				if not closestEnemy or not closestEnemy.Parent then
					stopRotation()
					iFramesService:RemoveAlliFrames(Character)
					StunHandler:Unstun(Character, CasterStun)
					UserTrack:AdjustSpeed(1)
					return
				end

				local PullTarget = (HumRP.CFrame * CFrame.new(PULL_OFFSET)).Position

				local PullAnchor = Instance.new("Part")
				PullAnchor.Name = "FlarewhipPullAnchor"
				PullAnchor.Anchored = true
				PullAnchor.CanCollide = false
				PullAnchor.CanTouch = false
				PullAnchor.CanQuery = false
				PullAnchor.Transparency = 1
				PullAnchor.Size = Vector3.new(0.1, 0.1, 0.1)
				PullAnchor.CFrame = EnemyHumRP.CFrame
				PullAnchor.Parent = workspace

				local PullOffset = PullAnchor.CFrame:ToObjectSpace(EnemyHumRP.CFrame)
				local PullWeld = WeldSystem.new(PullAnchor, EnemyHumRP, PullOffset, -1)
				PullWeld:Start(PULL_TIME + WELD_TIME + 0.5, EnemyPlayer, Player)

				local PullTween = TweenService:Create(
					PullAnchor,
					TweenInfo.new(PULL_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.In),
					{ CFrame = CFrame.new(PullTarget, PullTarget + HumRP.CFrame.LookVector) }
				)

				local function onVictimArrived()
					if pullDone then
						return
					end
					pullDone = true

					RemoteManager.FireAllClients("ReplicateTask", "TethersVFX_Stop", {
						casterChar = Character,
						victimChar = closestEnemy,
					})

					pcall(function()
						PullWeld:Stop()
					end)
					if PullAnchor and PullAnchor.Parent then
						PullAnchor:Destroy()
					end

					if not closestEnemy or not closestEnemy.Parent then
						stopRotation()
						UserTrack:AdjustSpeed(1)
						return
					end

					cancelAllKnockbackStates(closestEnemy)
					closestEnemy:AddTag("CantRotate")
					closestEnemy:AddTag("Knockbacked")

					stopRotation()

					HumRP.CFrame = CFrame.lookAt(
						HumRP.Position,
						Vector3.new(EnemyHumRP.Position.X, HumRP.Position.Y, EnemyHumRP.Position.Z)
					)

					SFX:Play("tethersBind", EnemyHumRP)

					Weld = WeldSystem.new(HumRP, EnemyHumRP, WELD_OFFSET, -1)
					Weld:Start(WELD_TIME, EnemyPlayer, Player)

					UserTrack:AdjustSpeed(1)
				end

				local proximityConn
				local timeoutThread

				timeoutThread = task.delay(MAX_PULL_WAIT, function()
					if pullDone then
						return
					end
					pullDone = true

					PullTween:Cancel()
					pcall(function()
						PullWeld:Stop()
					end)
					if PullAnchor and PullAnchor.Parent then
						PullAnchor:Destroy()
					end

					RemoteManager.FireAllClients("ReplicateTask", "TethersVFX_Stop", {
						casterChar = Character,
						victimChar = closestEnemy,
					})

					stopRotation()
					UserTrack:AdjustSpeed(1)

					if not hitDone then
						hitDone = true
						cleanupWeld()

						if closestEnemy and closestEnemy.Parent and EnemyHumanoid and EnemyHumanoid.Health > 0 then
							doHitEffects(
								Character,
								HumRP,
								closestEnemy,
								EnemyHumanoid,
								EnemyHumRP,
								EnemyPlayer,
								CasterStun,
								VictimStun,
								Tool
							)
						else
							iFramesService:RemoveAlliFrames(Character)
							StunHandler:Unstun(Character, CasterStun)
						end
					end
				end)

				proximityConn = RunService.Heartbeat:Connect(function()
					if pullDone then
						proximityConn:Disconnect()
						return
					end
					if not EnemyHumRP or not EnemyHumRP.Parent or not HumRP or not HumRP.Parent then
						proximityConn:Disconnect()
						return
					end
					if (EnemyHumRP.Position - HumRP.Position).Magnitude <= CLOSE_DISTANCE then
						proximityConn:Disconnect()
						if timeoutThread then
							task.cancel(timeoutThread)
						end
						onVictimArrived()
					end
				end)

				PullTween.Completed:Once(function(state)
					if state == Enum.PlaybackState.Completed and not pullDone then
						if proximityConn then
							proximityConn:Disconnect()
						end
						if timeoutThread then
							task.cancel(timeoutThread)
						end
						onVictimArrived()
					end
				end)

				PullTween:Play()
			end)
		)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("hit"):Once(function()
				stopRotation()
				cleanupWeld()
				SFX:Play("tethersKick", HumRP)

				if hitDone then
					return
				end
				hitDone = true

				local HitList = {}

				if closestEnemy and closestEnemy.Parent then
					HitList[closestEnemy] = true
				end

				HitboxHandler:SimpleOnce(
					HumRP,
					HITBOX_SIZE,
					HITBOX_OFFSET,
					{ Character },
					"Box",
					nil,
					function(EnemyCharacter)
						if HitList[EnemyCharacter] then
							return
						end
						if EnemyCharacter == closestEnemy then
							return
						end

						local Hum = EnemyCharacter:FindFirstChild("Humanoid")
						local Hrp = EnemyCharacter:FindFirstChild("HumanoidRootPart")
						if not Hum or not Hrp then
							return
						end
						if Hum.Health <= 0 then
							return
						end
						if iFramesService:HasiFrame(EnemyCharacter, Tool.Name) then
							return
						end

						HitList[EnemyCharacter] = true

						cancelAllKnockbackStates(EnemyCharacter)

						local HitInfo = DamageHandler:TakeDamage(
							Character,
							Hum,
							DAMAGE,
							nil,
							nil,
							true,
							true,
							true,
							true,
							true,
							nil,
							nil
						)

						if HitInfo.Countered or HitInfo.Blocked then
							return
						end

						Hrp.AssemblyLinearVelocity = Vector3.zero

						local pushDir = (Hrp.Position - HumRP.Position)
						pushDir = Vector3.new(pushDir.X, 0, pushDir.Z)
						pushDir = pushDir.Magnitude > 0 and pushDir.Unit or HumRP.CFrame.LookVector

						local lookCF = CFrame.lookAt(Hrp.Position, Hrp.Position + pushDir)

						PerfectKnockback:KnockBack(nil, EnemyCharacter, {
							LookVector = pushDir,
							LookForce = KICK_HORIZONTAL_FORCE,
							LookFinalForce = KICK_HORIZONTAL_FORCE,
							LookAt = lookCF,
							UpVelocity = KICK_VELOCITY,
							UpVelocityTime = 0.15,
							GroundStunTime = 1.0,
							FallingDetectDelay = 0.4,
							Dot = 1,
							DontFreeze = false,
						}, Character)
					end
				)

				if closestEnemy and closestEnemy.Parent and EnemyHumanoid and EnemyHumanoid.Health > 0 then
					doHitEffects(
						Character,
						HumRP,
						closestEnemy,
						EnemyHumanoid,
						EnemyHumRP,
						EnemyPlayer,
						CasterStun,
						VictimStun,
						Tool
					)
				else
					iFramesService:RemoveAlliFrames(Character)
					StunHandler:Unstun(Character, CasterStun)
				end
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			stopRotation()
			cleanupWeld()
			cleanupCaster()

			if closestEnemy and closestEnemy.Parent then
				SkillCollision:Unlock(closestEnemy)
			end

			pcall(function()
				HumRP:SetNetworkOwner(Player)
			end)
			if EnemyHumRP and EnemyHumRP.Parent then
				pcall(function()
					EnemyHumRP:SetNetworkOwner(EnemyPlayer)
				end)
			end

			iFramesService:RemoveAlliFrames(Character)
			StunHandler:Unstun(Character, CasterStun)

			if closestEnemy and closestEnemy.Parent and VictimStun then
				StunHandler:Unstun(closestEnemy, VictimStun)
				iFramesService:RemoveAlliFrames(closestEnemy)
				closestEnemy:RemoveTag("CantRotate")
				closestEnemy:RemoveTag("Knockbacked")
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
