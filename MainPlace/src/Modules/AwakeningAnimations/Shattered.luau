local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ServerModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local StunHandler = require(ServerModules.StunHandler)
local DamageHandler = require(ServerModules.DamageHandler)
local iFramesService = require(ServerModules.iFramesService)
local HitboxHandler = require(ServerModules.HitboxHandler)
local AnimationService = require(ServerModules.AnimationService)
local RagdollHandler = require(ServerModules.RagdollHandler)
local BodymoverService = require(ServerModules.BodymoverService)

local Assets = ServerStorage.Assets
local Animations = Assets.Animations
local UserAnimation = Animations.Awakenings.Shattered
local GravityAffectedAnim = Assets.Animations.Other.GravityAffected

local GRAB_HALF_SIZE = Vector3.new(70, 70, 70)

local DAMAGE = 25
local RAGDOLL_TIME = 6

local KNOCK_OUTWARD_FORCE = 300
local KNOCK_UP_FORCE = 90
local KNOCK_BODY_TIME = 0.3

local ISLAND_RISE_HEIGHT = 100
local ISLAND_RISE_TIME = 1
local ISLAND_START_OFFSET = 5

local module = {}

local ActiveState = {}

local function releaseVictim(EnemyCharacter, VictimData)
	if not EnemyCharacter or not VictimData then
		return
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

	if VictimData.Player then
		RemoteManager.FireClient(VictimData.Player, "ReplicateTask", "GravityAffectedVisual", { func = "Stop" })
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
		IslandBaseY = nil,
		IslandStartTime = nil,
	}
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

		local alpha = math.clamp((os.clock() - data.IslandStartTime) / ISLAND_RISE_TIME, 0, 1)
		local eased = 1 - (1 - alpha) ^ 2
		local currentY = data.IslandBaseY + ISLAND_RISE_HEIGHT * eased

		for EnemyCharacter, VictimData in pairs(data.Victims) do
			if EnemyCharacter and EnemyCharacter.Parent and VictimData.Locked then
				local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
				if EnemyHumRP and EnemyHumRP.Parent then
					local Pos = VictimData.OriginalPosition
					EnemyHumRP.CFrame = CFrame.new(Pos.X, currentY, Pos.Z)
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

	stopIslandTracking(data)

	if data.Victims then
		for EnemyCharacter, VictimData in pairs(data.Victims) do
			releaseVictim(EnemyCharacter, VictimData)
		end
		data.Victims = nil
	end

	RemoteManager.FireAllClients("ReplicateTask", "ShatteredIsland", { func = "Hit", char = Character })

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
			data.IslandBaseY = HumRP.Position.Y - ISLAND_START_OFFSET
			data.IslandStartTime = os.clock()

			RemoteManager.FireAllClients("ReplicateTask", "ShatteredImpact", { char = Character })
			RemoteManager.FireAllClients("ReplicateTask", "ShatteredIsland", { func = "Start", char = Character })

			startIslandTracking(data)

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

					RemoteManager.FireAllClients(
						"ReplicateTask",
						"ShatteredIsland",
						{ func = "AddVictim", char = Character, victim = EnemyCharacter }
					)

					if VictimPlayer then
						RemoteManager.FireClient(
							VictimPlayer,
							"ReplicateTask",
							"GravityAffectedVisual",
							{ func = "Start" }
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

			stopIslandTracking(data)

			RemoteManager.FireAllClients("ReplicateTask", "ShatteredImpact", { char = Character })
			RemoteManager.FireAllClients("ReplicateTask", "ShatteredIsland", { func = "Hit", char = Character })

			local Victims = data.Victims
			data.Victims = nil

			if not Victims then
				return
			end

			for EnemyCharacter, VictimData in pairs(Victims) do
				if not EnemyCharacter or not EnemyCharacter.Parent then
					continue
				end

				local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
				local EnemyHumRP = EnemyCharacter:FindFirstChild("HumanoidRootPart")
				if not EnemyHumanoid or not EnemyHumRP then
					continue
				end

				if VictimData.Player then
					RemoteManager.FireClient(
						VictimData.Player,
						"ReplicateTask",
						"GravityAffectedVisual",
						{ func = "Stop" }
					)
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
