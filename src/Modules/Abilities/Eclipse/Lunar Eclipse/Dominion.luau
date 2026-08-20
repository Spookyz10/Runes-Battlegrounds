local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ServerModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)

local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local iFramesService = require(ServerModules.iFramesService)
local SkillCancelHandler = require(ServerModules.SkillCancelHandler)
local HitboxHandler = require(ServerModules.HitboxHandler)
local AnimationService = require(ServerModules.AnimationService)
local RagdollHandler = require(ServerModules.RagdollHandler)
local CombatEvents = require(ServerModules.CombatEvents)

local MoveAnims = ServerStorage.Assets.Animations.Moves
local UserAnimation = MoveAnims.Eclipse.Lunar.Awakening.Dominion
local GravityAffectedAnim = ServerStorage.Assets.Animations.Other.GravityAffected

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = { workspace.Map }
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true

local FIELD_FORWARD_OFFSET = 3
local FIELD_HALF_SIZE = Vector3.new(25, 25, 25)
local GRAVITY_FREEZE_AUTO_RELEASE = 15

local LAUNCH_HEIGHT = 150
local LAUNCH_UP_TIME = 0.5
local SLAM_DOWN_TIME = 0.35
local SLAM_SAFETY_TIMEOUT = 4

local SLAM_DAMAGE = 45
local SLAM_SPLASH_DAMAGE = 22
local SLAM_RAGDOLL_TIME = 5
local SLAM_SPLASH_RAGDOLL_TIME = 2.5
local SLAM_IMPACT_SIZE = Vector3.new(40, 40, 40)

local ActiveState = {}

local function findGroundY(position)
	local ray = workspace:Raycast(position + Vector3.new(0, 10, 0), Vector3.new(0, -200, 0), MapRayParams)
	if ray then
		return ray.Position.Y
	end
	return position.Y
end

function ActiveState.new(Character, Player)
	return {
		Character = Character,
		Player = Player,
		Cancelled = false,
		FieldPos = nil,
		FieldActive = false,
		FieldConn = nil,
		Victims = nil,
		LaunchedVictims = nil,
		ReleasedVictims = nil,
		DamageConn = nil,
		Locked = false,
		Slammed = false,
		CancelFn = nil,
	}
end

local releaseVictim

local function captureVictim(data, otherChar, otherHum)
	if data.Victims[otherChar] then
		return
	end
	if data.ReleasedVictims and data.ReleasedVictims[otherChar] then
		return
	end

	local otherHumRP = otherChar:FindFirstChild("HumanoidRootPart")
	if not otherHumRP then
		return
	end

	if iFramesService:HasiFrame(otherChar, 1) then
		return
	end

	if otherChar:HasTag("Ragdolled") then
		RagdollHandler.cancelRagdoll(otherHum, nil, false, nil, false, true, true)
	end

	local victimData = {}
	data.Victims[otherChar] = victimData

	otherHumRP.AssemblyLinearVelocity = Vector3.zero
	otherHumRP.AssemblyAngularVelocity = Vector3.zero
	otherHumRP.Anchored = true

	local stunFolder = StunHandler:Stun(otherChar, nil, true, 0, 0, true, nil, true)
	victimData.StunFolder = stunFolder

	victimData.AutoReleaseThread = task.delay(GRAVITY_FREEZE_AUTO_RELEASE, function()
		victimData.AutoReleaseThread = nil
		if data.Victims and data.Victims[otherChar] == victimData then
			if victimData.StunFolder then
				StunHandler:Unstun(otherChar, victimData.StunFolder)
			end
			releaseVictim(data, otherChar, victimData)
		end
	end)

	local otherPlayer = Players:GetPlayerFromCharacter(otherChar)
	victimData.Player = otherPlayer
	if otherPlayer then
		RemoteManager.FireClient(otherPlayer, "ReplicateTask", "GravityAffectedVisual", { func = "Start" })
	end

	AnimationService:stopAll(otherChar)
	victimData.AnimTrack = AnimationService:playAnimation(otherChar, GravityAffectedAnim)

	if otherHum then
		victimData.DiedConn = otherHum.Died:Once(function()
			if data.Victims and data.Victims[otherChar] == victimData then
				if victimData.StunFolder then
					StunHandler:Unstun(otherChar, victimData.StunFolder)
				end
				releaseVictim(data, otherChar, victimData)
			end
		end)
	end

	if stunFolder then
		stunFolder.Destroying:Once(function()
			releaseVictim(data, otherChar, victimData)
		end)
	end
end

function releaseVictim(data, otherChar, victimData)
	if data.Locked then
		return
	end
	if not data.Victims or data.Victims[otherChar] ~= victimData then
		return
	end
	data.Victims[otherChar] = nil

	data.ReleasedVictims = data.ReleasedVictims or {}
	data.ReleasedVictims[otherChar] = true

	if victimData.AutoReleaseThread then
		pcall(task.cancel, victimData.AutoReleaseThread)
		victimData.AutoReleaseThread = nil
	end

	if victimData.DiedConn then
		victimData.DiedConn:Disconnect()
		victimData.DiedConn = nil
	end

	if victimData.AnimTrack and victimData.AnimTrack.IsPlaying then
		victimData.AnimTrack:Stop(0.15)
	end

	if otherChar and otherChar.Parent then
		local otherHumRP = otherChar:FindFirstChild("HumanoidRootPart")
		if otherHumRP and otherHumRP.Anchored then
			otherHumRP.Anchored = false
		end
	end

	if victimData.Player then
		RemoteManager.FireClient(victimData.Player, "ReplicateTask", "GravityAffectedVisual", { func = "Stop" })
	end
end

local function releaseAllVictims(data)
	if not data.Victims then
		return
	end

	local pending = {}
	for otherChar, victimData in pairs(data.Victims) do
		table.insert(pending, { otherChar = otherChar, victimData = victimData })
	end

	data.Victims = nil

	for _, entry in pending do
		local otherChar, victimData = entry.otherChar, entry.victimData
		if victimData.StunFolder then
			StunHandler:Unstun(otherChar, victimData.StunFolder)
		end
		releaseVictim(data, otherChar, victimData)
	end
end

local function stopField(data)
	if data.DamageConn then
		data.DamageConn:Disconnect()
		data.DamageConn = nil
	end

	if not data.FieldActive then
		return
	end
	data.FieldActive = false
	if data.FieldConn then
		data.FieldConn:Disconnect()
		data.FieldConn = nil
	end
	if data.FieldPos then
		RemoteManager.FireAllClients("ReplicateTask", "Gravity", { func = "End", char = data.Character })
	end
end

local function startField(data, position)
	data.FieldPos = position
	data.FieldActive = true
	data.Victims = data.Victims or {}

	RemoteManager.FireAllClients("ReplicateTask", "Gravity", { func = "start", char = data.Character, pos = position })

	local function scan(center)
		for _, plr in Players:GetPlayers() do
			local otherChar = plr.Character
			if not otherChar or otherChar == data.Character then
				continue
			end
			local otherHumRP = otherChar:FindFirstChild("HumanoidRootPart")
			local otherHum = otherChar:FindFirstChild("Humanoid")
			if not otherHumRP or not otherHum or otherHum.Health <= 0 then
				continue
			end
			local delta = otherHumRP.Position - center
			if
				math.abs(delta.X) <= FIELD_HALF_SIZE.X
				and math.abs(delta.Y) <= FIELD_HALF_SIZE.Y
				and math.abs(delta.Z) <= FIELD_HALF_SIZE.Z
			then
				captureVictim(data, otherChar, otherHum)
			end
		end
	end

	scan(position)

	data.DamageConn = CombatEvents.DamageDealt:Connect(function(_, Damaged, _, _)
		if data.Locked or not data.Victims then
			return
		end
		local victimData = data.Victims[Damaged]
		if not victimData then
			return
		end
		if victimData.StunFolder then
			StunHandler:Unstun(Damaged, victimData.StunFolder)
		end
		releaseVictim(data, Damaged, victimData)
	end)

	data.FieldConn = RunService.Heartbeat:Connect(function()
		if not data.FieldActive or not data.FieldPos or data.Locked then
			return
		end
		scan(data.FieldPos)
	end)
end

local function cleanup(data)
	if data.Cancelled then
		return
	end
	data.Cancelled = true

	if data.CancelFn then
		SkillCancelHandler:Unregister(data.Character, data.CancelFn)
	end

	stopField(data)
	releaseAllVictims(data)

	local Character = data.Character
	if Character and Character.Parent then
		iFramesService:RemoveiFrames(Character, "All")
	end

	ActiveState[Character] = nil
end

local function slamVictim(Character, Player, otherChar, victimData)
	if not otherChar or not otherChar.Parent then
		return
	end
	local EnemyHumanoid = otherChar:FindFirstChild("Humanoid")
	local EnemyHumRP = otherChar:FindFirstChild("HumanoidRootPart")
	if not EnemyHumanoid or not EnemyHumRP or EnemyHumanoid.Health <= 0 then
		return
	end

	local groundY = findGroundY(EnemyHumRP.Position)
	local landPos = Vector3.new(EnemyHumRP.Position.X, groundY, EnemyHumRP.Position.Z)

	EnemyHumRP.Anchored = true

	local SlamTween = TweenService:Create(
		EnemyHumRP,
		TweenInfo.new(SLAM_DOWN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ CFrame = CFrame.new(landPos) }
	)

	SlamTween.Completed:Once(function(state)
		if state ~= Enum.PlaybackState.Completed then
			return
		end
		if not otherChar or not otherChar.Parent or not EnemyHumRP or not EnemyHumRP.Parent then
			return
		end

		RemoteManager.FireAllClients("ReplicateTask", "LunarImpact", { position = landPos })

		if Player then
			RemoteManager.FireClient(Player, "ReplicateTask", "ShakeCamera", { Intensity = 12, Last = 0.8 })
		end
		local EnemyPlayer = Players:GetPlayerFromCharacter(otherChar)
		if EnemyPlayer then
			RemoteManager.FireClient(EnemyPlayer, "ReplicateTask", "ShakeCamera", { Intensity = 14, Last = 0.9 })
		end

		EnemyHumRP.Anchored = false
		EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
		EnemyHumRP.AssemblyAngularVelocity = Vector3.zero

		if victimData.SlamStun then
			StunHandler:Unstun(otherChar, victimData.SlamStun)
		end
		otherChar:RemoveTag("CantRotate")

		if EnemyHumanoid.Health > 0 then
			DamageHandler:TakeDamage(
				Character,
				EnemyHumanoid,
				SLAM_DAMAGE,
				nil,
				nil,
				false,
				false,
				true,
				true,
				true,
				nil,
				nil
			)
		end

		if EnemyHumanoid.Health > 0 then
			RagdollHandler.ragdoll(EnemyHumanoid, SLAM_RAGDOLL_TIME, false)
		end

		HitboxHandler:SimpleOnce(
			landPos,
			SLAM_IMPACT_SIZE,
			nil,
			{ Character, otherChar },
			"Box",
			nil,
			function(SplashCharacter)
				local SplashHumanoid = SplashCharacter:FindFirstChild("Humanoid")
				if not SplashHumanoid or SplashHumanoid.Health <= 0 then
					return
				end
				if iFramesService:HasiFrame(SplashCharacter, 1) then
					return
				end
				DamageHandler:TakeDamage(
					Character,
					SplashHumanoid,
					SLAM_SPLASH_DAMAGE,
					1,
					nil,
					false,
					false,
					true,
					true,
					false,
					nil,
					nil
				)
				RagdollHandler.ragdoll(SplashHumanoid, SLAM_SPLASH_RAGDOLL_TIME)
			end
		)
	end)

	SlamTween:Play()
end

local function slamAllLaunched(data)
	if data.Slammed then
		return
	end
	data.Slammed = true

	local victims = data.LaunchedVictims
	data.LaunchedVictims = nil

	if victims then
		for otherChar, victimData in pairs(victims) do
			slamVictim(data.Character, data.Player, otherChar, victimData)
		end
	end

	task.delay(SLAM_DOWN_TIME + 0.3, function()
		local Character = data.Character
		if Character and Character.Parent then
			iFramesService:RemoveiFrames(Character, "All")
		end
		ActiveState[Character] = nil
	end)
end

return {
	Cooldown = 20,
	Start = function(Player, Tool)
		local Character = Player.Character
		if not Character or not Character.Parent then
			return
		end

		local Humanoid = Character:FindFirstChild("Humanoid")
		local HumRP = Character:FindFirstChild("HumanoidRootPart")
		if not Humanoid or not HumRP or Humanoid.Health <= 0 then
			return
		end

		if ActiveState[Character] then
			cleanup(ActiveState[Character])
		end

		local data = ActiveState.new(Character, Player)
		ActiveState[Character] = data

		local CasterStun = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)

		local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)
		if not UserTrack then
			StunHandler:Unstun(Character, CasterStun)
			ActiveState[Character] = nil
			return
		end

		local cancelled = false
		local onDamageCancel
		onDamageCancel = function()
			if cancelled or data.Locked then
				return
			end
			cancelled = true
			if UserTrack and UserTrack.IsPlaying then
				UserTrack:Stop()
			end
		end
		data.CancelFn = onDamageCancel
		SkillCancelHandler:Register(Character, onDamageCancel)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("start"):Once(function()
				print("lol")
				if data.Cancelled or not Character.Parent or Humanoid.Health <= 0 then
					return
				end

				local lv = HumRP.CFrame.LookVector
				local lookFlat = Vector3.new(lv.X, 0, lv.Z)
				lookFlat = lookFlat.Magnitude > 0.001 and lookFlat.Unit or Vector3.new(0, 0, -1)

				local fieldPos = HumRP.Position + lookFlat * FIELD_FORWARD_OFFSET

				startField(data, fieldPos)
			end)
		)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("throw"):Once(function()
				print("lol")
				if data.Cancelled or not Character.Parent then
					return
				end

				SkillCancelHandler:Unregister(Character, onDamageCancel)
				iFramesService:AddiFrames(Character, "Base")
				StunHandler:Unstun(Character, CasterStun)

				data.Locked = true
				stopField(data)

				local victims = data.Victims or {}
				data.Victims = nil
				data.LaunchedVictims = {}

				for otherChar, victimData in pairs(victims) do
					if otherChar and otherChar.Parent then
						local EnemyHumanoid = otherChar:FindFirstChild("Humanoid")
						local EnemyHumRP = otherChar:FindFirstChild("HumanoidRootPart")

						if EnemyHumanoid and EnemyHumRP and EnemyHumanoid.Health > 0 then
							if victimData.AutoReleaseThread then
								pcall(task.cancel, victimData.AutoReleaseThread)
								victimData.AutoReleaseThread = nil
							end
							if victimData.DiedConn then
								victimData.DiedConn:Disconnect()
								victimData.DiedConn = nil
							end
							if victimData.AnimTrack and victimData.AnimTrack.IsPlaying then
								victimData.AnimTrack:Stop(0.1)
							end
							if victimData.Player then
								RemoteManager.FireClient(
									victimData.Player,
									"ReplicateTask",
									"GravityAffectedVisual",
									{ func = "Stop" }
								)
							end
							if victimData.StunFolder then
								StunHandler:Unstun(otherChar, victimData.StunFolder)
								victimData.StunFolder = nil
							end

							otherChar:AddTag("CantRotate")
							victimData.SlamStun = StunHandler:Stun(otherChar, nil, true, 0, 0, true)

							EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
							EnemyHumRP.AssemblyAngularVelocity = Vector3.zero
							EnemyHumRP.Anchored = true

							AnimationService:stopAll(otherChar)
							RagdollHandler.ragdoll(
								EnemyHumanoid,
								LAUNCH_UP_TIME + SLAM_DOWN_TIME + SLAM_SAFETY_TIMEOUT,
								false
							)

							local startPos = EnemyHumRP.Position
							local upPos = startPos + Vector3.new(0, LAUNCH_HEIGHT, 0)

							TweenService:Create(
								EnemyHumRP,
								TweenInfo.new(LAUNCH_UP_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{ CFrame = CFrame.new(upPos) }
							):Play()

							local EnemyPlayer = Players:GetPlayerFromCharacter(otherChar)
							if EnemyPlayer then
								RemoteManager.FireClient(
									EnemyPlayer,
									"ReplicateTask",
									"ShakeCamera",
									{ Intensity = 4, Last = 0.6 }
								)
							end

							data.LaunchedVictims[otherChar] = victimData
						end
					end
				end

				if next(data.LaunchedVictims) == nil then
					task.delay(0.1, function()
						local ch = data.Character
						if ch and ch.Parent then
							iFramesService:RemoveiFrames(ch, "All")
						end
						ActiveState[ch] = nil
					end)
				else
					task.delay(LAUNCH_UP_TIME + SLAM_SAFETY_TIMEOUT, function()
						if not data.Slammed then
							slamAllLaunched(data)
						end
					end)
				end
			end)
		)

		table.insert(
			UserEvents,
			UserTrack:GetMarkerReachedSignal("slam"):Once(function()
				print("lol")
				if not data.Locked or data.Slammed then
					return
				end
				slamAllLaunched(data)
			end)
		)

		UserTrack.Stopped:Once(function()
			for _, v in UserEvents do
				v:Disconnect()
			end

			if not data.Locked then
				cleanup(data)
				StunHandler:Unstun(Character, CasterStun)
			end
		end)

		AnimationService:stopAll(Character)
		AnimationService:playAnimation(Character, UserAnimation)
	end,
}
