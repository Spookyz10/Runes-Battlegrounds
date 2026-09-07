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
local HitboxHandler = require(ServerModules.HitboxHandler)
local AnimationService = require(ServerModules.AnimationService)
local CharacterLifetime = require(ServerModules.CharacterLifetime)
local RagdollHandler = require(ServerModules.RagdollHandler)
local BodymoverService = require(ServerModules.BodymoverService)

local CharacterAssets = ReplicatedStorage.Resources.CharacterAssets

local Assets = ServerStorage.Assets
local Animations = Assets.Animations
local UserAnimation = Animations.Awakenings.Shattered
local GravityAffectedAnim = Assets.Animations.Other.GravityAffected

local GRAB_HALF_SIZE = Vector3.new(175.126, 50, 200.696)

local DAMAGE = 25
local RAGDOLL_TIME = 6

local KNOCK_OUTWARD_FORCE = 60
local KNOCK_UP_FORCE = 90
local KNOCK_BODY_TIME = 0.3

local ISLAND_RISE_HEIGHT = 600
local ISLAND_RISE_TIME = 1.5
local ISLAND_START_OFFSET = 5
local VICTIM_FLOOR_OFFSET = 3

local CASTER_LAUNCH_HEIGHT_ABOVE_ISLAND = 100
local CASTER_LAUNCH_HEIGHT = ISLAND_RISE_HEIGHT + CASTER_LAUNCH_HEIGHT_ABOVE_ISLAND
local CASTER_LAUNCH_TIME = ISLAND_RISE_TIME

local module = {}

local ActiveState = {}

local function lockAirborne(Humanoid, HumRP)
	Humanoid.AutoRotate = false
	Humanoid.PlatformStand = true
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	HumRP.AssemblyLinearVelocity = Vector3.zero
	HumRP.Anchored = true
end

local function restoreGroundControl(Humanoid, HumRP)
	HumRP.Anchored = false
	Humanoid.PlatformStand = false
	Humanoid.AutoRotate = true
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
	if Humanoid.Health > 0 then
		Humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end
end

local function releaseVictim(EnemyCharacter, VictimData)
	if not EnemyCharacter or not VictimData then
		return
	end

	if VictimData.DisconnectLifetime then
		VictimData.DisconnectLifetime()
		VictimData.DisconnectLifetime = nil
	end
	local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
	local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")

	if VictimData.Locked and EnemyHumRP and EnemyHumRP.Parent then
		EnemyHumRP.Anchored = false
	end

	if VictimData.AnimTrack and VictimData.AnimTrack.IsPlaying then
		VictimData.AnimTrack:Stop(0.15)
	end

	if VictimData.StunFolder and EnemyCharacter.Parent then
		StunHandler:Unstun(EnemyCharacter, VictimData.StunFolder)
	end
	VictimData.StunFolder = nil

	if EnemyCharacter.Parent then
		EnemyCharacter:RemoveTag("CantRotate")
	end

	if EnemyHumanoid and EnemyHumanoid.Parent and EnemyHumanoid.Health > 0 then
		EnemyHumanoid:ChangeState(Enum.HumanoidStateType.Running)
	end
end

function ActiveState.new(Character, Player)
	return {
		Character = Character,
		Player = Player,
		Cancelled = false,
		Victims = nil,
		Locked = false,
		PreviousiFrameLevel = 0,
		CasterStun = nil,
		IslandConn = nil,
		IslandClone = nil,
		IslandFloor = nil,
		IslandDriverConn = nil,
		OriginPosition = nil,
		CasterAirborne = false,
		CasterLaunchTween = nil,
	}
end

local function destroyServerIsland(data)
	if data.IslandDriverConn then
		data.IslandDriverConn:Disconnect()
		data.IslandDriverConn = nil
	end

	if data.IslandClone and data.IslandClone.Parent then
		data.IslandClone:Destroy()
	end

	data.IslandClone = nil
	data.IslandFloor = nil
end

local function spawnServerIsland(data, HumRP)
	local IslandAsset = CharacterAssets.Shattered.Island
	local Clone = IslandAsset:Clone()

	local StartCFrame = CFrame.new(HumRP.Position - Vector3.new(0, ISLAND_START_OFFSET, 0))
	Clone:PivotTo(StartCFrame)
	Clone.Parent = workspace

	data.IslandClone = Clone
	data.IslandFloor = Clone:FindFirstChild("Floor", true)

	local EndCFrame = StartCFrame * CFrame.new(0, ISLAND_RISE_HEIGHT, 0)

	local Driver = Instance.new("CFrameValue")
	Driver.Value = StartCFrame
	Driver.Parent = Clone

	local DriverConn
	DriverConn = Driver:GetPropertyChangedSignal("Value"):Connect(function()
		if Clone and Clone.Parent then
			Clone:PivotTo(Driver.Value)
		end
	end)
	data.IslandDriverConn = DriverConn

	local IslandTween = TweenService:Create(
		Driver,
		TweenInfo.new(ISLAND_RISE_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Value = EndCFrame }
	)

	IslandTween.Completed:Once(function()
		if DriverConn then
			DriverConn:Disconnect()
		end
		if data.IslandDriverConn == DriverConn then
			data.IslandDriverConn = nil
		end
		if Driver and Driver.Parent then
			Driver:Destroy()
		end
	end)

	IslandTween:Play()
end

local function launchCasterUp(data, Humanoid, HumRP)
	lockAirborne(Humanoid, HumRP)
	data.CasterAirborne = true

	local StartCFrame = HumRP.CFrame
	local TargetCFrame = CFrame.new(data.OriginPosition + Vector3.new(0, CASTER_LAUNCH_HEIGHT, 0))
		* StartCFrame.Rotation

	local LaunchTween = TweenService:Create(
		HumRP,
		TweenInfo.new(CASTER_LAUNCH_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ CFrame = TargetCFrame }
	)

	data.CasterLaunchTween = LaunchTween
	LaunchTween:Play()
end

local function stopCasterLaunchTween(data)
	if data.CasterLaunchTween then
		data.CasterLaunchTween:Cancel()
		data.CasterLaunchTween = nil
	end
end

local function returnCasterToGround(data, Humanoid, HumRP)
	stopCasterLaunchTween(data)

	if not data.CasterAirborne then
		return
	end
	data.CasterAirborne = false

	if HumRP and HumRP.Parent and data.OriginPosition then
		HumRP.Anchored = false
		HumRP.CFrame = CFrame.new(data.OriginPosition, data.OriginPosition + HumRP.CFrame.LookVector)
		HumRP.AssemblyLinearVelocity = Vector3.zero
	end

	if Humanoid and Humanoid.Parent and HumRP and HumRP.Parent then
		restoreGroundControl(Humanoid, HumRP)
	end
end

local function startIslandTracking(data)
	data.IslandConn = RunService.Heartbeat:Connect(function()
		if data.Cancelled or not data.Victims then
			if data.IslandConn then
				data.IslandConn:Disconnect()
				data.IslandConn = nil
			end
			return
		end

		local Floor = data.IslandFloor
		if not Floor or not Floor.Parent then
			return
		end

		local FloorY = Floor.Position.Y

		for EnemyCharacter, VictimData in pairs(data.Victims) do
			if EnemyCharacter and EnemyCharacter.Parent and VictimData.Locked then
				local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
				if EnemyHumRP and EnemyHumRP.Parent then
					local Pos = VictimData.OriginalPosition
					EnemyHumRP.CFrame = CFrame.new(Pos.X, FloorY + VICTIM_FLOOR_OFFSET, Pos.Z)
				end
			end
		end
	end)
end

local function stopIslandTracking(data)
	if data.IslandConn then
		data.IslandConn:Disconnect()
		data.IslandConn = nil
	end
end

local function cleanup(data)
	if data.Cancelled then
		return
	end
	data.Cancelled = true

	local Character = data.Character
	local Humanoid = Character and Character:FindFirstChild("Humanoid")
	local HumRP = Character and Character:FindFirstChild("HumanoidRootPart")

	stopIslandTracking(data)
	destroyServerIsland(data)

	if data.CasterAirborne then
		returnCasterToGround(data, Humanoid, HumRP)
	end

	if data.Victims then
		for EnemyCharacter, VictimData in pairs(data.Victims) do
			releaseVictim(EnemyCharacter, VictimData)
		end
		data.Victims = nil
	end

	if Character and Character.Parent then
		Character:RemoveTag("CantRotate")

		if data.CasterStun then
			StunHandler:Unstun(Character, data.CasterStun)
			data.CasterStun = nil
		end

		if data.PreviousiFrameLevel and data.PreviousiFrameLevel > 0 then
			Character:SetAttribute("iFrames", data.PreviousiFrameLevel)
		else
			iFramesService:RemoveiFrames(Character, "All")
		end
	end

	if data.Player then
		RemoteManager.FireClient(data.Player, "ReplicateTask", "CustomCamPart", { func = "Stop" })
		RemoteManager.FireClient(data.Player, "ReplicateTask", "ShowAwkBar")
		RemoteManager.FireClient(data.Player, "ReplicateTask", "ShowHotbar")
	end

	ActiveState[Character] = nil
end

function module:Activate(Player)
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
	data.OriginPosition = HumRP.Position
	ActiveState[Character] = data

	AnimationService:stopAll(Character)

	local UserTrack, UserEvents = AnimationService:getAnimationTrack(Character, UserAnimation)
	if not UserTrack then
		warn("[Shattered Awakening] UserTrack is nil for", Character.Name)
		ActiveState[Character] = nil
		return
	end

	data.PreviousiFrameLevel = iFramesService:GetLevel(Character)
	iFramesService:AddiFrames(Character, "All")

	data.CasterStun = StunHandler:Stun(Character, nil, true, 0, 0, true, nil, false)
	Character:AddTag("CantRotate")

	RemoteManager.FireAllClients("ReplicateTask", "GivePlayerAura", { Char = Character, AuraName = "Shattered" })

	RemoteManager.FireClient(Player, "ReplicateTask", "HideAwkBar")
	RemoteManager.FireClient(Player, "ReplicateTask", "HideHotbar")

	local removingConn, diedConn, ancestryConn

	local function onInterrupt()
		cleanup(data)
		if UserTrack and UserTrack.IsPlaying then
			UserTrack:Stop()
		end
	end

	removingConn = Players.PlayerRemoving:Connect(function(leavingPlayer)
		if leavingPlayer == Player then
			onInterrupt()
		end
	end)
	diedConn = Humanoid.Died:Connect(onInterrupt)
	ancestryConn = Character.AncestryChanged:Connect(function(_, parent)
		if not parent then
			onInterrupt()
		end
	end)

	table.insert(
		UserEvents,
		UserTrack:GetMarkerReachedSignal("jump"):Once(function()
			if data.Cancelled or not Character.Parent or Humanoid.Health <= 0 then
				return
			end

			data.Locked = true
			data.Victims = {}

			RemoteManager.FireAllClients("ReplicateTask", "ShatteredImpact", { char = Character })

			task.wait(0.1)
			if data.Cancelled or not Character.Parent or Humanoid.Health <= 0 then
				return
			end

			spawnServerIsland(data, HumRP)
			startIslandTracking(data)
			launchCasterUp(data, Humanoid, HumRP)

			HitboxHandler:SimpleOnce(
				HumRP,
				GRAB_HALF_SIZE,
				CFrame.new(),
				{ Character },
				"Box",
				nil,
				function(EnemyCharacter)
					if data.Victims[EnemyCharacter] then
						return
					end

					local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
					local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
					if not EnemyHumanoid or not EnemyHumRP then
						return
					end
					if EnemyHumanoid.Health <= 0 or EnemyHumanoid:GetState() == Enum.HumanoidStateType.Dead then
						return
					end
					if iFramesService:HasiFrame(EnemyCharacter, 1) then
						return
					end

					if EnemyCharacter:HasTag("Ragdolled") then
						RagdollHandler.cancelRagdoll(EnemyHumanoid, nil, false, nil, false, true, true)
					end

					local StunFolder = StunHandler:Stun(EnemyCharacter, nil, true, 0, 0, true, nil, false)

					EnemyCharacter:AddTag("CantRotate")

					EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
					EnemyHumRP.AssemblyAngularVelocity = Vector3.zero
					EnemyHumRP.Anchored = true

					AnimationService:stopAll(EnemyCharacter)
					local VictimAnimTrack = AnimationService:playAnimation(EnemyCharacter, GravityAffectedAnim)

					local VictimPlayer = Players:GetPlayerFromCharacter(EnemyCharacter)

					data.Victims[EnemyCharacter] = {
						Player = VictimPlayer,
						Locked = true,
						StunFolder = StunFolder,
						AnimTrack = VictimAnimTrack,
						OriginalPosition = EnemyHumRP.Position,
					}
					local victimData = data.Victims[EnemyCharacter]
					victimData.DisconnectLifetime = CharacterLifetime.Watch(EnemyCharacter, function()
						if data.Victims and data.Victims[EnemyCharacter] == victimData then
							data.Victims[EnemyCharacter] = nil
						end
						releaseVictim(EnemyCharacter, victimData)
					end)

					if VictimPlayer then
						RemoteManager.FireClient(
							VictimPlayer,
							"ReplicateTask",
							"ShakeCamera",
							{ Intensity = 2, Last = 3 }
						)
					end
				end
			)
		end)
	)

	table.insert(
		UserEvents,
		UserTrack:GetMarkerReachedSignal("hit"):Once(function()
			if data.Cancelled or not Character.Parent then
				return
			end

			RemoteManager.FireClient(Player, "ReplicateTask", "CustomCamPart", {
				func = "Start",
				position = HumRP.Position + Vector3.new(0, 100, 300),
				lookTarget = Character,
			})

			if data.IslandClone and data.IslandClone.PrimaryPart then
				RemoteManager.FireAllClients(
					"ReplicateTask",
					"ShatterIslandExplosion",
					{ Part = data.IslandClone.PrimaryPart.Position }
				)
			end

			stopIslandTracking(data)

			destroyServerIsland(data)

			task.wait(0.1)
			if data.Cancelled or not Character.Parent then
				return
			end

			returnCasterToGround(data, Humanoid, HumRP)

			RemoteManager.FireAllClients("ReplicateTask", "ShatteredImpact", { char = Character })

			local Victims = data.Victims
			data.Victims = nil

			if not Victims then
				return
			end

			for EnemyCharacter, VictimData in pairs(Victims) do
				releaseVictim(EnemyCharacter, VictimData)
				if not EnemyCharacter or not EnemyCharacter.Parent then
					continue
				end

				local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
				local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
				if not EnemyHumanoid or not EnemyHumRP then
					continue
				end

				if VictimData.AnimTrack and VictimData.AnimTrack.IsPlaying then
					VictimData.AnimTrack:Stop(0.15)
				end

				EnemyHumRP.Anchored = false
				VictimData.Locked = false

				if VictimData.StunFolder then
					StunHandler:Unstun(EnemyCharacter, VictimData.StunFolder)
					VictimData.StunFolder = nil
				end

				EnemyCharacter:RemoveTag("CantRotate")

				if EnemyHumanoid.Health <= 0 then
					continue
				end

				DamageHandler:TakeDamage(
					Character,
					EnemyHumanoid,
					DAMAGE,
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

				if EnemyHumanoid.Health <= 0 then
					continue
				end

				EnemyHumRP.AssemblyLinearVelocity = Vector3.zero
				EnemyHumRP.AssemblyAngularVelocity = Vector3.zero

				pcall(function()
					EnemyHumRP:SetNetworkOwner(nil)
				end)

				RagdollHandler.ragdoll(EnemyHumanoid, RAGDOLL_TIME)

				local outward = EnemyHumRP.Position - HumRP.Position
				local outwardFlat = Vector3.new(outward.X, 0, outward.Z)
				if outwardFlat.Magnitude < 0.001 then
					outwardFlat = HumRP.CFrame.LookVector
					outwardFlat = Vector3.new(outwardFlat.X, 0, outwardFlat.Z)
				end
				outwardFlat = outwardFlat.Magnitude > 0 and outwardFlat.Unit or Vector3.new(0, 0, -1)

				task.defer(function()
					if not EnemyCharacter or not EnemyCharacter.Parent then
						return
					end
					if not EnemyHumRP or not EnemyHumRP.Parent then
						return
					end

					BodymoverService:Knockback(EnemyCharacter, {
						KnockbackType = "Velocity",
						MaxForce = Vector3.new(100000, 100000, 100000),
						Velocity = outwardFlat * KNOCK_OUTWARD_FORCE + Vector3.new(0, KNOCK_UP_FORCE, 0),
						Time = KNOCK_BODY_TIME,
					})
				end)

				local EnemyPlayer = VictimData.Player or Players:GetPlayerFromCharacter(EnemyCharacter)
				if EnemyPlayer then
					RemoteManager.FireClient(
						EnemyPlayer,
						"ReplicateTask",
						"ShakeCamera",
						{ Intensity = 10, Last = 0.8 }
					)
				end

				task.delay(1, function()
					RemoteManager.FireClient(Player, "ReplicateTask", "CustomCamPart", { func = "Stop" })
				end)
			end
		end)
	)

	UserTrack.Stopped:Once(function()
		for _, v in UserEvents do
			v:Disconnect()
		end

		if removingConn then
			removingConn:Disconnect()
		end
		if diedConn then
			diedConn:Disconnect()
		end
		if ancestryConn then
			ancestryConn:Disconnect()
		end

		cleanup(data)
	end)

	AnimationService:playAnimation(Character, UserAnimation)
end

return module
