local RunService = game:GetService("RunService")

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SvModules = ServerStorage.Modules

local RemoteManager = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local SFXModule = require(ReplicatedStorage.Shared.Modules.SFXModule)
local DamageHandler = require(SvModules.DamageHandler)
local iFramesService = require(SvModules.iFramesService)
local SkillCancelHandler = require(SvModules.SkillCancelHandler)
local HitboxHandler = require(SvModules.HitboxHandler)
local RagdollHandler = require(SvModules.RagdollHandler)
local AnimationService = require(SvModules.AnimationService)
local StunHandler = require(SvModules.StunHandler)
local CombatEvents = require(SvModules.CombatEvents)
local SceneObjectReservation = require(SvModules.SceneObjectReservation)

local Animations = ServerStorage.Assets.Animations.Moves
local StrikeAnim = Animations.Eclipse.Lunar.Awakening.Moonfall
local GravityAffectedAnim = ServerStorage.Assets.Animations.Other.GravityAffected

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = { workspace:WaitForChild("Map") }
MapRayParams.RespectCanCollide = true
MapRayParams.IgnoreWater = true

local IslandsFolder = workspace:WaitForChild("Map").Islands

local GRAVITY_HALF_SIZE = Vector3.new(70, 70, 70)
local GRAVITY_FREEZE_AUTO_RELEASE = 15
local JUMP_HEIGHT = 400
local JUMP_X_OFFSET = 50
local ISLAND_HOVER_HEIGHT = 200
local ISLAND_RISE_HEIGHT = 100
local ISLAND_RISE_TIME = 0.4
local ISLAND_TRAVEL_TIME = 1.6
local ISLAND_THROW_TIME = 1.1
local ISLAND_DESTROY_FORCE = 200
local IMPACT_SIZE = Vector3.new(100, 300, 100)
local IMPACT_DAMAGE = 30
local ISLAND_RESERVE_DURATION = 20

local ActiveState = {}

local function isDestroyablePart(part)
	if not part:IsA("BasePart") then
		return false
	end
	if part:GetAttribute("Destroyable") == true then
		return true
	end
	local model = part:FindFirstAncestorOfClass("Model")
	while model do
		if model:GetAttribute("Destroyable") == true then
			return true
		end
		model = model.Parent and model.Parent:FindFirstAncestorOfClass("Model")
	end
	return false
end

local function findGroundY(position)
	local ray = workspace:Raycast(position + Vector3.new(0, 10, 0), Vector3.new(0, -200, 0), MapRayParams)
	if ray then
		return ray.Position.Y
	end
	return position.Y
end

local function pickIsland()
	local Available = {}

	for _, model in IslandsFolder:GetChildren() do
		if model:IsA("Model") and not SceneObjectReservation:IsReserved(model) then
			table.insert(Available, model)
		end
	end

	if #Available == 0 then
		return nil
	end

	return Available[math.random(1, #Available)]
end

local function getModelSize(model)
	local ok, size = pcall(function()
		return model:GetExtentsSize()
	end)
	if ok then
		return size
	end
	return Vector3.new(30, 30, 30)
end

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

function ActiveState.new(Character, Player)
	local data = {
		Character = Character,
		Player = Player,
		Cancelled = false,
		GravityPos = nil,
		GravityActive = false,
		GravityConn = nil,
		GravityVictims = nil,
		DamageConn = nil,
		Island = nil,
		IslandOriginal = nil,
		IslandConn = nil,
		OriginalWalkSpeed = nil,
		PreviousiFrameLevel = 0,
		GroundReturnPosition = nil,
		IsAirborne = false,
		GroundStun = nil,
		SuppressGroundStunCleanup = false,
	}
	return data
end

local releaseGravityVictim

local function captureGravityVictim(data, otherChar, otherHum)
	if data.GravityVictims[otherChar] then
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
	data.GravityVictims[otherChar] = victimData

	otherHumRP.AssemblyLinearVelocity = Vector3.zero
	otherHumRP.AssemblyAngularVelocity = Vector3.zero
	otherHumRP.Anchored = true

	local stunFolder = StunHandler:Stun(otherChar, nil, true, 0, 0, true, nil, true)
	victimData.StunFolder = stunFolder

	victimData.AutoReleaseThread = task.delay(GRAVITY_FREEZE_AUTO_RELEASE, function()
		victimData.AutoReleaseThread = nil
		if data.GravityVictims and data.GravityVictims[otherChar] == victimData then
			if victimData.StunFolder then
				StunHandler:Unstun(otherChar, victimData.StunFolder)
			end
			releaseGravityVictim(data, otherChar, victimData)
		end
	end)

	victimData.HardReleaseThread = task.delay(GRAVITY_FREEZE_AUTO_RELEASE + 10, function()
		if data.GravityVictims and data.GravityVictims[otherChar] == victimData then
			if victimData.StunFolder then
				StunHandler:Unstun(otherChar, victimData.StunFolder)
			end
			releaseGravityVictim(data, otherChar, victimData)
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
			if data.GravityVictims and data.GravityVictims[otherChar] == victimData then
				if victimData.StunFolder then
					StunHandler:Unstun(otherChar, victimData.StunFolder)
				end
				releaseGravityVictim(data, otherChar, victimData)
			end
		end)
	end

	if stunFolder then
		stunFolder.Destroying:Once(function()
			releaseGravityVictim(data, otherChar, victimData)
		end)
	end
end

function releaseGravityVictim(data, otherChar, victimData)
	if not data.GravityVictims or data.GravityVictims[otherChar] ~= victimData then
		return
	end
	data.GravityVictims[otherChar] = nil

	data.ReleasedVictims = data.ReleasedVictims or {}
	data.ReleasedVictims[otherChar] = true

	if victimData.HardReleaseThread then
		pcall(task.cancel, victimData.HardReleaseThread)
		victimData.HardReleaseThread = nil
	end

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

local function releaseGravityVictims(data)
	if not data.GravityVictims then
		return
	end

	local pending = {}
	for otherChar, victimData in pairs(data.GravityVictims) do
		table.insert(pending, { otherChar = otherChar, victimData = victimData })
	end

	data.GravityVictims = nil

	for _, entry in pending do
		local otherChar, victimData = entry.otherChar, entry.victimData
		if victimData.StunFolder then
			StunHandler:Unstun(otherChar, victimData.StunFolder)
		end
		releaseGravityVictim(data, otherChar, victimData)
	end
end

local function stopGravityField(data)
	releaseGravityVictims(data)

	if data.DamageConn then
		data.DamageConn:Disconnect()
		data.DamageConn = nil
	end

	if not data.GravityActive then
		return
	end
	data.GravityActive = false
	if data.GravityConn then
		data.GravityConn:Disconnect()
		data.GravityConn = nil
	end
	if data.GravityPos then
		RemoteManager.FireAllClients("ReplicateTask", "Gravity", { func = "End", char = data.Character })
	end
end

local function startGravityField(data, position)
	data.GravityPos = position
	data.GravityActive = true
	data.GravityVictims = data.GravityVictims or {}

	RemoteManager.FireAllClients("ReplicateTask", "Gravity", { func = "start", char = data.Character, pos = position })

	local function scanForVictims(center)
		HitboxHandler:SimpleOnce(
			CFrame.new(center),
			GRAVITY_HALF_SIZE,
			CFrame.new(),
			{ data.Character },
			"Box",
			nil,
			function(otherChar)
				if otherChar == data.Character then
					return
				end

				local otherHum = otherChar:FindFirstChild("Humanoid")
				if not otherHum or otherHum.Health <= 0 then
					return
				end

				captureGravityVictim(data, otherChar, otherHum)
			end
		)
	end

	scanForVictims(position)

	data.DamageConn = CombatEvents.DamageDealt:Connect(function(_, Damaged, _, _)
		if not data.GravityVictims then
			return
		end
		local victimData = data.GravityVictims[Damaged]
		if not victimData then
			return
		end
		if victimData.StunFolder then
			StunHandler:Unstun(Damaged, victimData.StunFolder)
		end
		releaseGravityVictim(data, Damaged, victimData)
	end)

	data.GravityConn = RunService.Heartbeat:Connect(function()
		if not data.GravityActive or not data.GravityPos then
			return
		end
		scanForVictims(data.GravityPos)
	end)
end

local function applyGravityFieldCompensationDamage(data)
	local Character = data.Character
	local Player = data.Player
	local position = data.GravityPos

	if not position then
		return
	end

	RemoteManager.FireAllClients("ReplicateTask", "LunarImpact", { position = position })
	SFXModule:Play("EclipseImpact", position)
	SFXModule:Play("Moonfall3", position)

	if Player then
		RemoteManager.FireClient(Player, "ReplicateTask", "ShakeCamera", { Intensity = 10, Last = 0.8 })
	end

	HitboxHandler:SimpleOnce(position, IMPACT_SIZE, nil, { Character }, "Box", nil, function(EnemyCharacter)
		local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
		if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then
			return
		end
		DamageHandler:TakeDamage(
			Character,
			EnemyHumanoid,
			IMPACT_DAMAGE,
			1.5,
			nil,
			false,
			false,
			true,
			true,
			true,
			nil,
			nil
		)
		RagdollHandler.ragdoll(EnemyHumanoid, 3)
	end)

	stopGravityField(data)
end

local function destroyIsland(data)
	local Clone = data.Island
	data.Island = nil
	data.IslandOriginal = nil
	if data.IslandConn then
		data.IslandConn:Disconnect()
		data.IslandConn = nil
	end
	if Clone and Clone.Parent then
		Clone:Destroy()
	end
end

local function impactIsland(data, impactPosition)
	local Character = data.Character
	local Player = data.Player

	SFXModule:Play("Moonfall3", impactPosition)
	SFXModule:Play("EclipseImpact", impactPosition)

	RemoteManager.FireAllClients("ReplicateTask", "Ground Crater", {
		Seed = math.random(1, 2147483647),
		amount = 80,
		start = impactPosition + Vector3.new(0, 6, 0),
		["end"] = Vector3.new(0, -20, 0),
		NoGroundAlign = true,
		rings = 4,
		ringSpacing = 18,
		ringSizeGrowth = 1.5,
		ringGap = 0.24,
		outwardTilt = true,
		debrisSizeMin = 8,
		debrisSizeMax = 18,
		debrisHeightMin = 2.5,
		debrisHeightMax = 4,
		maxDebrisHeight = 5,
		sizemult = 1.5,
	})

	if Player then
		RemoteManager.FireClient(Player, "ReplicateTask", "ShakeCamera", { Intensity = 12, Last = 1 })
	end

	HitboxHandler:SimpleOnce(impactPosition, IMPACT_SIZE, nil, { Character }, "Box", nil, function(EnemyCharacter)
		local EnemyHumanoid = EnemyCharacter:FindFirstChild("Humanoid")
		if not EnemyHumanoid or EnemyHumanoid.Health <= 0 then
			return
		end
		DamageHandler:TakeDamage(
			Character,
			EnemyHumanoid,
			IMPACT_DAMAGE,
			1.5,
			nil,
			false,
			false,
			true,
			true,
			true,
			nil,
			nil
		)
		RagdollHandler.ragdoll(EnemyHumanoid, 3)
	end)

	destroyIsland(data)
	stopGravityField(data)
end

local function travelIslandToPlayer(data, Character, HumRP)
	local Island = data.Island
	local startPos = Island:GetPivot().Position
	local startRot = Island:GetPivot().Rotation

	if Island:FindFirstChild("LunarHighlight") then
		Island.LunarHighlight.Enabled = true
	end

	RemoteManager.FireAllClients("ReplicateTask", "EnableVFX", { container = Island })

	local basePos = data.GroundReturnPosition or HumRP.Position
	local targetPos = Vector3.new(basePos.X, HumRP.Position.Y + ISLAND_HOVER_HEIGHT, basePos.Z)
	local risenPos = startPos + Vector3.new(0, ISLAND_RISE_HEIGHT, 0)

	local hitSet = {}
	local lastImpactTick = 0
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include

	local islandSize = getModelSize(Island) + Vector3.new(6, 6, 6)

	local function applyDestructionAt(pos, direction)
		if os.clock() - lastImpactTick < 0.1 then
			return
		end
		lastImpactTick = os.clock()

		local pivot = CFrame.new(pos) * startRot
		local touching = workspace:GetPartBoundsInBox(pivot, islandSize, overlapParams)
		for _, part in touching do
			if not hitSet[part] and isDestroyablePart(part) then
				hitSet[part] = true
			end
		end
	end

	task.wait(2)

	if not data.Cancelled and Island.Parent then
		local startTime = os.clock()
		local completed = false

		data.IslandConn = RunService.Heartbeat:Connect(function()
			if data.Cancelled or not Island.Parent then
				completed = true
				return
			end

			local t = math.clamp((os.clock() - startTime) / ISLAND_RISE_TIME, 0, 1)
			local eased = 1 - (1 - t) ^ 2
			local pos = startPos:Lerp(risenPos, eased)
			Island:PivotTo(CFrame.new(pos) * startRot)

			applyDestructionAt(pos, Vector3.new(0, 1, 0))

			if t >= 1 then
				completed = true
			end
		end)

		repeat
			task.wait()
		until completed or data.Cancelled

		if data.IslandConn then
			data.IslandConn:Disconnect()
			data.IslandConn = nil
		end
	end

	if data.Cancelled or not Island.Parent then
		return
	end

	do
		local startTime = os.clock()
		local completed = false

		data.IslandConn = RunService.Heartbeat:Connect(function()
			if data.Cancelled or not Island.Parent then
				completed = true
				return
			end

			local t = math.clamp((os.clock() - startTime) / ISLAND_TRAVEL_TIME, 0, 1)
			local eased = 1 - (1 - t) ^ 3
			local pos = risenPos:Lerp(targetPos, eased)
			Island:PivotTo(CFrame.new(pos) * startRot)

			local direction = (targetPos - risenPos)
			direction = direction.Magnitude > 0.01 and direction.Unit or Vector3.new(0, 1, 0)
			applyDestructionAt(pos, direction)

			if t >= 1 then
				completed = true
			end
		end)

		repeat
			task.wait()
		until completed or data.Cancelled

		if data.IslandConn then
			data.IslandConn:Disconnect()
			data.IslandConn = nil
		end
	end
end

local function throwIslandToGravity(data)
	local Island = data.Island
	if not Island or not Island.Parent then
		return
	end

	local startPos = Island:GetPivot().Position
	local startRot = Island:GetPivot().Rotation
	local groundY = findGroundY(data.GravityPos)
	local targetPos = Vector3.new(data.GravityPos.X, groundY, data.GravityPos.Z)

	local startTime = os.clock()
	local completed = false

	data.IslandConn = RunService.Heartbeat:Connect(function()
		if data.Cancelled or not Island.Parent then
			completed = true
			return
		end

		local t = math.clamp((os.clock() - startTime) / ISLAND_THROW_TIME, 0, 1)
		local eased = t * t
		local pos = startPos:Lerp(targetPos, eased)
		Island:PivotTo(CFrame.new(pos) * startRot)

		if t >= 1 then
			RemoteManager.FireAllClients("ReplicateTask", "IslandExplosion", { position = targetPos })
			completed = true
		end
	end)

	repeat
		task.wait()
	until completed or data.Cancelled

	if data.IslandConn then
		data.IslandConn:Disconnect()
		data.IslandConn = nil
	end

	if not data.Cancelled and Island.Parent then
		impactIsland(data, targetPos)
	end
end

local function cleanup(data)
	if data.Cancelled then
		return
	end
	data.Cancelled = true
	if data.CancelFn then
		SkillCancelHandler:Unregister(data.Character, data.CancelFn)
	end

	local Character = data.Character
	if data.IsAirborne then
		local Humanoid = Character and Character.Parent and Character:FindFirstChild("Humanoid")
		local HumRP = Character and Character.Parent and Character:FindFirstChild("HumanoidRootPart")
		if Humanoid and HumRP then
			restoreGroundControl(Humanoid, HumRP)
		end
		data.IsAirborne = false
	end

	stopGravityField(data)
	destroyIsland(data)

	if Character and Character.Parent then
		local Humanoid = Character:FindFirstChild("Humanoid")
		if Humanoid and data.OriginalWalkSpeed then
			Humanoid.WalkSpeed = data.OriginalWalkSpeed
		end
		Character:SetAttribute("iFrames", data.PreviousiFrameLevel or 0)
	end

	ActiveState[Character] = nil
end

return {
	Cooldown = 16,
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

		AnimationService:stopAll(Character)

		local AnimTrack, AnimEvents = AnimationService:getAnimationTrack(Character, StrikeAnim)
		if not AnimTrack then
			ActiveState[Character] = nil
			return
		end

		data.OriginalWalkSpeed = Humanoid.WalkSpeed
		data.PreviousiFrameLevel = iFramesService:GetLevel(Character)
		data.GroundReturnPosition = HumRP.Position

		local GroundStun = StunHandler:Stun(Character, 15, true)
		data.GroundStun = GroundStun
		if GroundStun then
			GroundStun.Destroying:Once(function()
				data.GroundStun = nil
				if data.Cancelled or data.SuppressGroundStunCleanup then
					return
				end
				cleanup(data)
				if AnimTrack and AnimTrack.IsPlaying then
					AnimTrack:Stop()
				end
			end)
		end

		Humanoid.WalkSpeed = 0
		iFramesService:RemoveiFrames(Character, "All")

		local cancelled = false
		local function onDamageCancel()
			if cancelled then
				return
			end
			cancelled = true
			if data.Cancelled then
				return
			end
			cleanup(data)
			if AnimTrack and AnimTrack.IsPlaying then
				AnimTrack:Stop()
			end
		end
		data.CancelFn = onDamageCancel
		SkillCancelHandler:Register(Character, onDamageCancel)

		SFXModule:Play("Moonfall1", HumRP)

		local removingConn
		local diedConn

		local function onInterrupt()
			cleanup(data)
		end

		removingConn = Players.PlayerRemoving:Connect(function(leavingPlayer)
			if leavingPlayer == Player then
				onInterrupt()
			end
		end)
		diedConn = Humanoid.Died:Connect(onInterrupt)
		Character.AncestryChanged:Connect(function(_, parent)
			if not parent then
				onInterrupt()
			end
		end)

		table.insert(
			AnimEvents,
			AnimTrack:GetMarkerReachedSignal("clap"):Connect(function()
				if data.Cancelled or not Character.Parent or Humanoid.Health <= 0 then
					return
				end
				SkillCancelHandler:Unregister(Character, data.CancelFn)
				startGravityField(data, HumRP.Position)
			end)
		)

		table.insert(
			AnimEvents,
			AnimTrack:GetMarkerReachedSignal("jump"):Connect(function()
				if data.Cancelled or not Character.Parent or Humanoid.Health <= 0 then
					return
				end
				SkillCancelHandler:Unregister(Character, data.CancelFn)
				iFramesService:AddiFrames(Character, "Base")

				local gravPos = ActiveState[Character] and ActiveState[Character].GravityPos
				if gravPos then
					RemoteManager.FireAllClients("ReplicateTask", "LunarImpact", { position = gravPos })
					SFXModule:Play("EclipseImpact", gravPos)
				end

				SFXModule:Play("Moonfall2", HumRP)

				task.wait(0.1)
				HumRP.CFrame = HumRP.CFrame + Vector3.new(JUMP_X_OFFSET, JUMP_HEIGHT, 0)
				lockAirborne(Humanoid, HumRP)
				data.IsAirborne = true
			end)
		)

		table.insert(
			AnimEvents,
			AnimTrack:GetMarkerReachedSignal("start"):Connect(function()
				if data.Cancelled or not Character.Parent or Humanoid.Health <= 0 then
					return
				end

				AnimTrack:AdjustSpeed(0)

				local IslandOriginal = pickIsland()
				local Clone = IslandOriginal
					and SceneObjectReservation:Reserve(IslandOriginal, "LunarStrike", Player, ISLAND_RESERVE_DURATION)

				if not Clone then
					applyGravityFieldCompensationDamage(data)
					AnimTrack:AdjustSpeed(1)
					return
				end

				Clone.Parent = workspace
				data.Island = Clone
				data.IslandOriginal = IslandOriginal

				travelIslandToPlayer(data, Character, HumRP)

				if data.Cancelled then
					return
				end

				AnimTrack:AdjustSpeed(1)
			end)
		)

		table.insert(
			AnimEvents,
			AnimTrack:GetMarkerReachedSignal("throw"):Connect(function()
				if data.Cancelled or not data.Island then
					return
				end

				AnimTrack:AdjustSpeed(0)

				task.spawn(function()
					local Finished = false

					task.spawn(function()
						throwIslandToGravity(data)
						Finished = true
					end)

					local StartWait = os.clock()
					repeat
						task.wait()
					until Finished or data.Cancelled or (os.clock() - StartWait) >= 10

					if data.Cancelled then
						return
					end

					AnimTrack:AdjustSpeed(1)
				end)
			end)
		)

		AnimTrack.Stopped:Once(function()
			if removingConn then
				removingConn:Disconnect()
			end
			if diedConn then
				diedConn:Disconnect()
			end

			if data.IsAirborne then
				if Character and Character.Parent then
					restoreGroundControl(Humanoid, HumRP)
				end
				data.IsAirborne = false
			end

			-- O stun de 15 s e somente um fallback caso a habilidade seja
			-- interrompida. Ao terminar normalmente, o jogador deve recuperar
			-- o controle imediatamente.
			if data.GroundStun then
				data.SuppressGroundStunCleanup = true
				StunHandler:Unstun(Character, data.GroundStun)
				data.GroundStun = nil
				data.SuppressGroundStunCleanup = false
			end

			if not data.Cancelled then
				if Character and Character.Parent and data.GroundReturnPosition then
					local groundY = findGroundY(data.GroundReturnPosition)

					HumRP.CFrame =
						CFrame.new(Vector3.new(data.GroundReturnPosition.X, groundY + 3, data.GroundReturnPosition.Z))

					local gravPos = ActiveState[Character] and ActiveState[Character].GravityPos
					if gravPos then
						RemoteManager.FireAllClients("ReplicateTask", "LunarImpact", { position = gravPos })
						SFXModule:Play("EclipseImpact", gravPos)
					end
				end

				if Humanoid then
					Humanoid.WalkSpeed = data.OriginalWalkSpeed
				end
				if Character then
					Character:SetAttribute("iFrames", data.PreviousiFrameLevel)
				end
				ActiveState[Character] = nil
			end
		end)

		AnimationService:playAnimation(Character, StrikeAnim)
	end,
}
