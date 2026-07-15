local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VoxBreaker = require(ReplicatedStorage.Shared.Modules.VoxBreaker)
local DebrisDamage = require(script.DebrisDamage)
local StructuralSupport = require(script.StructuralSupport)
local propagateDestroyableAttribute = require(script.PropagateDestroyableAttribute)

local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

local DestructionService = {}

local DEBUG = true

local COLLIDE_SIZE_THRESHOLD = 3
local INSTAKILL_SIZE = 100
local DEBRIS_COLLISION_GROUP = "NonPColDebri"
local DEFAULT_TRACK_DURATION = 5
local DEFAULT_TRACK_HITBOX_SIZE = Vector3.new(6, 6, 6)

local DEBRIS_LIFETIME = 10
local DEBRIS_FADE_TIME = 3
local MAX_CHUNKS_PER_IMPACT = 40

local INTEGRITY_SEARCH_RADIUS = 40
local NO_VOXEL_RESET_TIME = 20

local LEVITATE_RISE_SPEED = 6
local LEVITATE_RISE_ACCEL = 4
local LEVITATE_MAX_RISE_SPEED = 40
local LEVITATE_SPIN_RANGE = 1

local FAKE_DEBRIS_MIN_SIZE = 5
local FAKE_DEBRIS_MAX_SIZE = 15
local FAKE_DEBRIS_COLORS = {
	Color3.fromRGB(90, 90, 90),
	Color3.fromRGB(120, 120, 120),
	Color3.fromRGB(60, 100, 60),
	Color3.fromRGB(80, 120, 80),
}
local FAKE_DEBRIS_RISE_SPEED = 6
local FAKE_DEBRIS_SPIN_RANGE = 1
local FAKE_DEBRIS_FALL_CLEANUP_TIME = 10

local FORCE_TIERS = {
	{ MinForce = 0, Radius = 5, VoxelSize = 3 },
	{ MinForce = 30, Radius = 8, VoxelSize = 4 },
	{ MinForce = 70, Radius = 12, VoxelSize = 6 },
	{ MinForce = 110, Radius = 18, VoxelSize = 8 },
}

local GROUND_INSTANCES = {
	workspace.Map.Arena.Island.Ground,
	workspace.Map.Arena.Island.Ground2,
}

local DESTROYABLES_ROOT = workspace.Map:FindFirstChild("Destroyables")

if DESTROYABLES_ROOT then
	propagateDestroyableAttribute(DESTROYABLES_ROOT)
else
	warn("[DestructionSystem] workspace.Map.Destroyables não encontrado no boot")
end

local LEVITATION_ACTIVE = {}
local FAKE_DEBRIS_ACTIVE = {}

local function dprint(...)
	if DEBUG then
		print("[DestructionService]", ...)
	end
end

local function getTier(Force)
	local chosen = FORCE_TIERS[1]
	for _, tier in FORCE_TIERS do
		if Force >= tier.MinForce then
			chosen = tier
		end
	end
	return chosen
end

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

local function collectNearbyDestroyableParts(Center, Radius)
	local result = {}
	if not DESTROYABLES_ROOT then
		return result
	end

	for _, desc in DESTROYABLES_ROOT:GetDescendants() do
		if desc:IsA("BasePart") and desc.Parent and isDestroyablePart(desc) then
			if (desc.Position - Center).Magnitude <= Radius then
				table.insert(result, desc)
			end
		end
	end

	return result
end

local function collectDestroyablePartsInBox(CFrameCenter, Size)
	local result = {}
	if not DESTROYABLES_ROOT then
		return result
	end

	local boxParams = OverlapParams.new()
	boxParams.FilterType = Enum.RaycastFilterType.Include
	boxParams.FilterDescendantsInstances = { DESTROYABLES_ROOT }

	local parts = workspace:GetPartBoundsInBox(CFrameCenter, Size, boxParams)

	for _, part in parts do
		if part:IsA("BasePart") and part.Parent and isDestroyablePart(part) then
			table.insert(result, part)
		end
	end

	return result
end

function DestructionService:CheckIntegrity(ImpactPosition, ImpactDirection)
	local parts = collectNearbyDestroyableParts(ImpactPosition, INTEGRITY_SEARCH_RADIUS)
	if #parts == 0 then
		return
	end

	local clusters = StructuralSupport:FindUnsupportedClusters(parts, GROUND_INSTANCES)

	for _, cluster in clusters do
		self:CollapseCluster(cluster, ImpactPosition, ImpactDirection)
	end
end

function DestructionService:CollapseCluster(clusterParts, ImpactPosition, ImpactDirection)
	if #clusterParts == 0 then
		return
	end

	dprint("Cluster desconectado caindo:", #clusterParts, "parts")

	ImpactDirection = ImpactDirection or Vector3.new(0, 0, 0)

	for _, part in clusterParts do
		if not part.Parent then
			continue
		end

		part:SetAttribute("Destroyable", nil)
		part.Anchored = false
		local bigEnough = part.Size.X >= COLLIDE_SIZE_THRESHOLD
			and part.Size.Y >= COLLIDE_SIZE_THRESHOLD
			and part.Size.Z >= COLLIDE_SIZE_THRESHOLD
		part.CanCollide = bigEnough

		local away = part.Position - ImpactPosition
		local awayDir = away.Magnitude > 0.01 and away.Unit or Vector3.new(0, 1, 0)

		local combinedDir = (ImpactDirection * 1.0 + awayDir * 0.25) + Vector3.new(0, 0.35, 0)
		if combinedDir.Magnitude > 0.01 then
			combinedDir = combinedDir.Unit
		else
			combinedDir = Vector3.new(0, 1, 0)
		end

		local mass = part:GetMass()
		local speed = math.clamp(18 / math.sqrt(math.max(mass, 1)) + 6, 4, 30)

		part.AssemblyLinearVelocity = combinedDir * speed
		part.AssemblyAngularVelocity =
			Vector3.new(math.random(-150, 150) / 100, math.random(-150, 150) / 100, math.random(-150, 150) / 100)

		pcall(function()
			part.CollisionGroup = DEBRIS_COLLISION_GROUP
		end)

		DebrisDamage:Track(part, nil)
	end
end

function DestructionService:NotifyPartRemoved(RemovedPartPosition, Direction)
	self:CheckIntegrity(RemovedPartPosition, Direction)
end

local function applySplat(chunk)
	local originalSize = chunk.Size
	local squashed = Vector3.new(originalSize.X * 1.25, originalSize.Y * 0.55, originalSize.Z * 1.25)

	chunk.Size = squashed

	local tweenOk = pcall(function()
		TweenService
			:Create(
				chunk,
				TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ Size = originalSize }
			)
			:Play()
	end)
	if not tweenOk then
		chunk.Size = originalSize
	end
end

function DestructionService:_LaunchChunk(chunk, ImpactPosition, Force, OwnerPlayer, Direction)
	if not chunk or not chunk.Parent then
		return
	end

	chunk:SetAttribute("Destroyable", nil)

	applySplat(chunk)

	chunk.Anchored = false
	local bigEnough = chunk.Size.X >= COLLIDE_SIZE_THRESHOLD
		and chunk.Size.Y >= COLLIDE_SIZE_THRESHOLD
		and chunk.Size.Z >= COLLIDE_SIZE_THRESHOLD
	chunk.CanCollide = bigEnough
	chunk.CanTouch = true
	chunk.CanQuery = true

	pcall(function()
		chunk.CollisionGroup = DEBRIS_COLLISION_GROUP
	end)

	local away = chunk.Position - ImpactPosition
	local dist = away.Magnitude
	local awayDir = dist > 0.01 and away.Unit or Vector3.new(0, 1, 0)

	local dir = awayDir
	if Direction and Direction.Magnitude > 0.01 then
		dir = (awayDir * 0.25 + Direction.Unit * 1.0)
		dir = dir.Magnitude > 0.01 and dir.Unit or awayDir
	end

	local mass = chunk:GetMass()
	local launchSpeed = math.clamp(Force * 3.2 / math.sqrt(math.max(mass, 1)), 2, 45)

	chunk.AssemblyLinearVelocity = dir * launchSpeed * 0.7 + Vector3.new(0, launchSpeed * 0.45, 0)
	chunk.AssemblyAngularVelocity =
		Vector3.new(math.random(-200, 200) / 100, math.random(-200, 200) / 100, math.random(-200, 200) / 100)

	if chunk.Size.Magnitude >= INSTAKILL_SIZE then
		chunk:SetAttribute("InstaKill", true)
	end

	DebrisDamage:Track(chunk, OwnerPlayer)

	task.delay(DEBRIS_LIFETIME - DEBRIS_FADE_TIME, function()
		if not chunk or not chunk.Parent then
			return
		end
		pcall(function()
			TweenService:Create(chunk, TweenInfo.new(DEBRIS_FADE_TIME, Enum.EasingStyle.Linear), { Transparency = 1 })
				:Play()
		end)
		task.delay(DEBRIS_FADE_TIME, function()
			if chunk and chunk.Parent then
				chunk:Destroy()
			end
		end)
	end)
end

function DestructionService:ApplyImpact(Position, Force, OwnerPlayer, HitPart, Direction)
	if not HitPart or not HitPart.Parent then
		return
	end

	local tier = getTier(Force)

	local allVoxels = {}

	local localRadius = math.clamp(tier.Radius * 0.4, 2.5, 6)
	local localSize = Vector3.one * localRadius

	local localParams = OverlapParams.new()
	localParams.FilterType = Enum.RaycastFilterType.Include
	localParams.FilterDescendantsInstances = { HitPart }

	local ok1, localVoxels = pcall(function()
		return VoxBreaker:CreateHitbox(
			localSize,
			CFrame.new(Position),
			Enum.PartType.Ball,
			tier.VoxelSize,
			-1,
			localParams
		)
	end)

	if ok1 and localVoxels then
		for _, v in localVoxels do
			table.insert(allVoxels, v)
		end
	end

	local hitboxSize = Vector3.one * tier.Radius

	local areaParams = OverlapParams.new()
	areaParams.FilterType = Enum.RaycastFilterType.Exclude
	areaParams.FilterDescendantsInstances = { HitPart }

	local ok2, voxels = pcall(function()
		return VoxBreaker:CreateHitbox(
			hitboxSize,
			CFrame.new(Position),
			Enum.PartType.Ball,
			tier.VoxelSize,
			-1,
			areaParams
		)
	end)

	if ok2 and voxels then
		for _, v in voxels do
			table.insert(allVoxels, v)
		end
	end

	if #allVoxels > MAX_CHUNKS_PER_IMPACT then
		for i = #allVoxels, MAX_CHUNKS_PER_IMPACT + 1, -1 do
			local extra = allVoxels[i]
			if extra and extra.Parent then
				extra:Destroy()
			end
			allVoxels[i] = nil
		end
	end

	for _, chunk in allVoxels do
		self:_LaunchChunk(chunk, Position, Force, OwnerPlayer, Direction)
	end

	task.defer(function()
		self:CheckIntegrity(Position, Direction)
	end)
end

function DestructionService:ApplyRadialImpact(Position, Radius, Force, OwnerPlayer, Direction)
	local candidateParts = collectNearbyDestroyableParts(Position, Radius)
	if #candidateParts == 0 then
		dprint("ApplyRadialImpact: nenhuma part destrutível encontrada no raio", Radius, "em", Position)
		return
	end

	local tier = getTier(Force)

	local areaParams = OverlapParams.new()
	areaParams.FilterType = Enum.RaycastFilterType.Include
	areaParams.FilterDescendantsInstances = candidateParts

	local allVoxels = {}

	local ok, voxels = pcall(function()
		return VoxBreaker:CreateHitbox(
			Vector3.one * Radius,
			CFrame.new(Position),
			Enum.PartType.Ball,
			tier.VoxelSize,
			-1,
			areaParams
		)
	end)

	if ok and voxels then
		for _, v in voxels do
			table.insert(allVoxels, v)
		end
	else
		dprint("ApplyRadialImpact: VoxBreaker falhou -", voxels)
	end

	if #allVoxels > MAX_CHUNKS_PER_IMPACT then
		for i = #allVoxels, MAX_CHUNKS_PER_IMPACT + 1, -1 do
			local extra = allVoxels[i]
			if extra and extra.Parent then
				extra:Destroy()
			end
			allVoxels[i] = nil
		end
	end

	dprint(
		"ApplyRadialImpact: destruindo",
		#allVoxels,
		"voxels em raio",
		Radius,
		"-",
		#candidateParts,
		"parts candidatas"
	)

	for _, chunk in allVoxels do
		self:_LaunchChunk(chunk, Position, Force, OwnerPlayer, Direction)
	end

	task.defer(function()
		self:CheckIntegrity(Position, Direction)
	end)
end

function DestructionService:ApplyBoxImpact(Position, Size, Force, OwnerPlayer, Direction)
	local CenterCFrame = CFrame.new(Position)

	local candidateParts = collectDestroyablePartsInBox(CenterCFrame, Size)
	if #candidateParts == 0 then
		dprint("ApplyBoxImpact: nenhuma part destrutível encontrada na box", Size, "em", Position)
		return
	end

	for _, p in candidateParts do
		dprint("ApplyBoxImpact candidata:", p:GetFullName(), "- Size:", p.Size)
	end

	local tier = getTier(Force)

	local areaParams = OverlapParams.new()
	areaParams.FilterType = Enum.RaycastFilterType.Include
	areaParams.FilterDescendantsInstances = candidateParts

	local allVoxels = {}

	local ok, voxels = pcall(function()
		return VoxBreaker:CreateHitbox(Size, CenterCFrame, Enum.PartType.Block, tier.VoxelSize, -1, areaParams)
	end)

	if ok and voxels then
		for _, v in voxels do
			table.insert(allVoxels, v)
		end
	else
		dprint("ApplyBoxImpact: VoxBreaker falhou -", voxels)
	end

	if #allVoxels == 0 then
		dprint("ApplyBoxImpact: 0 voxels gerados, aplicando fallback direto em", #candidateParts, "parts")
		for _, part in candidateParts do
			self:_ApplyNoVoxelImpact(part, Position, Force, OwnerPlayer, Direction)
		end

		task.defer(function()
			self:CheckIntegrity(Position, Direction)
		end)
		return
	end

	if #allVoxels > MAX_CHUNKS_PER_IMPACT then
		for i = #allVoxels, MAX_CHUNKS_PER_IMPACT + 1, -1 do
			local extra = allVoxels[i]
			if extra and extra.Parent then
				extra:Destroy()
			end
			allVoxels[i] = nil
		end
	end

	dprint("ApplyBoxImpact: destruindo", #allVoxels, "voxels na box", Size, "-", #candidateParts, "parts candidatas")

	for _, chunk in allVoxels do
		self:_LaunchChunk(chunk, Position, Force, OwnerPlayer, Direction)
	end

	task.defer(function()
		self:CheckIntegrity(Position, Direction)
	end)
end

function DestructionService:_ApplyNoVoxelImpact(part, ImpactPosition, Force, OwnerPlayer, Direction)
	if not part or not part.Parent then
		return
	end

	local originalCFrame = part.CFrame
	local originalAnchored = part.Anchored
	local originalCollide = part.CanCollide
	local originalCollisionGroup = part.CollisionGroup

	part.Anchored = false
	part.CanCollide = true

	local away = part.Position - ImpactPosition
	local awayDir = away.Magnitude > 0.01 and away.Unit or Vector3.new(0, 1, 0)

	local dir = Direction
	if not dir or dir.Magnitude < 0.01 then
		dir = awayDir
	else
		dir = (awayDir * 1.0 + dir.Unit * 0.25)
		dir = dir.Magnitude > 0.01 and dir.Unit or awayDir
	end

	local mass = part:GetMass()
	local launchSpeed = math.clamp(Force * 3.2 / math.sqrt(math.max(mass, 1)), 2, 45)

	part.AssemblyLinearVelocity = dir * launchSpeed * 0.7 + Vector3.new(0, launchSpeed * 0.45, 0)
	part.AssemblyAngularVelocity =
		Vector3.new(math.random(-150, 150) / 100, math.random(-150, 150) / 100, math.random(-150, 150) / 100)

	pcall(function()
		part.CollisionGroup = DEBRIS_COLLISION_GROUP
	end)

	DebrisDamage:Track(part, OwnerPlayer)

	task.delay(NO_VOXEL_RESET_TIME, function()
		if not part or not part.Parent then
			return
		end
		part.AssemblyLinearVelocity = Vector3.zero
		part.AssemblyAngularVelocity = Vector3.zero
		part.CFrame = originalCFrame
		part.Anchored = originalAnchored
		part.CanCollide = originalCollide
		pcall(function()
			part.CollisionGroup = originalCollisionGroup
		end)
	end)
end

function DestructionService:TrackCharacterImpacts(Character, Force, OwnerPlayer, Duration, HitboxSize)
	local HumRP = Character and Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return function() end
	end

	HitboxSize = HitboxSize or DEFAULT_TRACK_HITBOX_SIZE

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = { Character }

	local active = true
	local hitParts = {}

	local conn
	conn = RunService.Heartbeat:Connect(function()
		if not active then
			return
		end
		if not HumRP or not HumRP.Parent then
			return
		end

		local touching = workspace:GetPartBoundsInBox(HumRP.CFrame, HitboxSize, overlapParams)
		local direction = HumRP.AssemblyLinearVelocity
		if direction.Magnitude > 0.01 then
			direction = direction.Unit
		else
			direction = HumRP.CFrame.LookVector
		end

		for _, part in touching do
			if hitParts[part] then
				continue
			end
			if not part:GetAttribute("Destroyable") then
				continue
			end

			hitParts[part] = true
			self:ApplyImpact(HumRP.Position, Force, OwnerPlayer, part, direction)
		end
	end)

	local stopped = false
	local function stop()
		if stopped then
			return
		end
		stopped = true
		active = false
		if conn then
			conn:Disconnect()
			conn = nil
		end
	end

	task.delay(Duration or DEFAULT_TRACK_DURATION, stop)

	return stop
end

function DestructionService:LevitateArea(Center, Radius, OwnerPlayer)
	local parts = collectNearbyDestroyableParts(Center, Radius)
	if #parts == 0 then
		return nil
	end

	local id = tostring(Center) .. "_" .. tostring(tick()) .. "_" .. tostring(math.random(1, 999999))

	local entries = {}

	for _, part in parts do
		if not part.Parent then
			continue
		end

		local originalAnchored = part.Anchored
		local originalCollide = part.CanCollide
		local originalCollisionGroup = part.CollisionGroup

		part.Anchored = false
		part.CanCollide = false
		part.CanTouch = false
		pcall(function()
			part.CollisionGroup = DEBRIS_COLLISION_GROUP
		end)

		local Bodymover = Instance.new("BodyVelocity")
		Bodymover.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		Bodymover.P = 10000
		Bodymover.Velocity = Vector3.new(0, LEVITATE_RISE_SPEED, 0)
		Bodymover.Parent = part

		local riseStart = os.clock()
		local riseAccelConn
		riseAccelConn = RunService.Heartbeat:Connect(function()
			if not Bodymover or not Bodymover.Parent then
				if riseAccelConn then
					riseAccelConn:Disconnect()
				end
				return
			end

			local elapsed = os.clock() - riseStart
			local speed = math.min(LEVITATE_RISE_SPEED + LEVITATE_RISE_ACCEL * elapsed, LEVITATE_MAX_RISE_SPEED)
			Bodymover.Velocity = Vector3.new(0, speed, 0)
		end)

		local AngularMover = Instance.new("BodyAngularVelocity")
		AngularMover.MaxTorque = Vector3.new(4000, 4000, 4000)
		AngularMover.AngularVelocity = Vector3.new(
			(math.random(-100, 100) / 100) * LEVITATE_SPIN_RANGE,
			(math.random(-100, 100) / 100) * LEVITATE_SPIN_RANGE,
			(math.random(-100, 100) / 100) * LEVITATE_SPIN_RANGE
		)
		AngularMover.Parent = part

		table.insert(entries, {
			part = part,
			bodyVelocity = Bodymover,
			bodyAngularVelocity = AngularMover,
			riseAccelConn = riseAccelConn,
			originalAnchored = originalAnchored,
			originalCollide = originalCollide,
			originalCollisionGroup = originalCollisionGroup,
		})
	end

	LEVITATION_ACTIVE[id] = {
		entries = entries,
		ownerPlayer = OwnerPlayer,
		center = Center,
	}

	return id
end

function DestructionService:DropArea(id)
	local data = LEVITATION_ACTIVE[id]
	if not data then
		return
	end

	LEVITATION_ACTIVE[id] = nil

	for _, entry in data.entries do
		local part = entry.part
		if not part or not part.Parent then
			continue
		end

		if entry.bodyVelocity and entry.bodyVelocity.Parent then
			entry.bodyVelocity:Destroy()
		end
		if entry.bodyAngularVelocity and entry.bodyAngularVelocity.Parent then
			entry.bodyAngularVelocity:Destroy()
		end
		if entry.riseAccelConn then
			entry.riseAccelConn:Disconnect()
		end

		part.CanCollide = entry.originalCollide
		part.CanTouch = true
		part.CanQuery = true

		DebrisDamage:TrackFall(part, data.ownerPlayer)
		ReplicateSet:FireAllClients("DebrisFallImpact", { Position = part.Position })
	end
end

function DestructionService:CancelLevitation(id)
	local data = LEVITATION_ACTIVE[id]
	if not data then
		return
	end

	LEVITATION_ACTIVE[id] = nil

	for _, entry in data.entries do
		local part = entry.part
		if not part or not part.Parent then
			continue
		end

		if entry.bodyVelocity and entry.bodyVelocity.Parent then
			entry.bodyVelocity:Destroy()
		end
		if entry.bodyAngularVelocity and entry.bodyAngularVelocity.Parent then
			entry.bodyAngularVelocity:Destroy()
		end
		if entry.riseAccelConn then
			entry.riseAccelConn:Disconnect()
		end
		part.Anchored = entry.originalAnchored
		part.CanCollide = entry.originalCollide
		part.CanTouch = true
		part.CanQuery = true
		pcall(function()
			part.CollisionGroup = entry.originalCollisionGroup
		end)
	end
end

local function resolveAnchorPosition(anchor)
	if typeof(anchor) == "Instance" then
		if anchor:IsA("Model") then
			local primary = anchor.PrimaryPart
				or anchor:FindFirstChild("HumanoidRootPart")
				or anchor:FindFirstChild("Torso")
			return primary and primary.Position or nil, primary
		elseif anchor:IsA("BasePart") then
			return anchor.Position, anchor
		end
	elseif typeof(anchor) == "Vector3" then
		return anchor, nil
	end
	return nil, nil
end

function DestructionService:SpawnFakeDebris(Anchor, Config)
	Config = Config or {}

	local MinRadius = Config.MinRadius or 100
	local MaxRadius = Config.MaxRadius or 200
	local Interval = Config.Interval or 0.2
	local MinSize = Config.MinSize or FAKE_DEBRIS_MIN_SIZE
	local MaxSize = Config.MaxSize or FAKE_DEBRIS_MAX_SIZE
	local Colors = Config.Colors or FAKE_DEBRIS_COLORS
	local RiseSpeed = Config.RiseSpeed or FAKE_DEBRIS_RISE_SPEED
	local SpinRange = Config.SpinRange or FAKE_DEBRIS_SPIN_RANGE
	local PerTick = Config.PerTick or 1
	local OwnerPlayer = Config.OwnerPlayer
	local RiseAcceleration = Config.RiseAcceleration or 0
	local MaxRiseSpeed = Config.MaxRiseSpeed or (RiseSpeed * 3)

	local groundRaycastParams = RaycastParams.new()
	groundRaycastParams.FilterType = Enum.RaycastFilterType.Include
	groundRaycastParams.FilterDescendantsInstances = GROUND_INSTANCES

	local id = tostring(Anchor) .. "_fake_" .. tostring(tick()) .. "_" .. tostring(math.random(1, 999999))

	local data = {
		entries = {},
		ownerPlayer = OwnerPlayer,
		running = true,
	}

	FAKE_DEBRIS_ACTIVE[id] = data

	local function spawnOne()
		local centerPos = resolveAnchorPosition(Anchor)
		if not centerPos then
			return
		end

		local angle = math.random() * math.pi * 2
		local dist = MinRadius + math.random() * (MaxRadius - MinRadius)
		local offset = Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
		local origin = centerPos + offset + Vector3.new(0, 50, 0)

		local groundHit = workspace:Raycast(origin, Vector3.new(0, -150, 0), groundRaycastParams)
		if not groundHit then
			return
		end

		local size = math.random(MinSize, MaxSize)

		local Rock = Instance.new("Part")
		Rock.Name = "FakeAwakeningDebris"
		Rock.Size = Vector3.new(size, size, size)
		Rock.Material = Enum.Material.Rock
		Rock.Color = Colors[math.random(1, #Colors)]
		Rock.Anchored = false
		Rock.CanCollide = false
		Rock.CanTouch = false
		Rock.CanQuery = false
		Rock.CFrame = CFrame.new(groundHit.Position - Vector3.new(0, size / 2, 0))
			* CFrame.Angles(
				math.rad(math.random(-360, 360)),
				math.rad(math.random(-360, 360)),
				math.rad(math.random(-360, 360))
			)
		pcall(function()
			Rock.CollisionGroup = DEBRIS_COLLISION_GROUP
		end)
		Rock.Parent = workspace.Debris

		local Bodymover = Instance.new("BodyVelocity")
		Bodymover.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		Bodymover.P = 10000
		Bodymover.Velocity = Vector3.new(0, RiseSpeed * math.random(80, 120) / 100, 0)
		Bodymover.Parent = Rock

		local rockRiseStart = os.clock()
		local rockAccelConn
		rockAccelConn = RunService.Heartbeat:Connect(function()
			if not Bodymover or not Bodymover.Parent then
				if rockAccelConn then
					rockAccelConn:Disconnect()
				end
				return
			end

			local elapsed = os.clock() - rockRiseStart
			local speed = math.min(RiseSpeed + RiseAcceleration * elapsed, MaxRiseSpeed)
			Bodymover.Velocity = Vector3.new(0, speed, 0)
		end)

		local AngularMover = Instance.new("BodyAngularVelocity")
		AngularMover.MaxTorque = Vector3.new(4000, 4000, 4000)
		AngularMover.AngularVelocity = Vector3.new(
			(math.random(-100, 100) / 100) * SpinRange,
			(math.random(-100, 100) / 100) * SpinRange,
			(math.random(-100, 100) / 100) * SpinRange
		)
		AngularMover.Parent = Rock

		table.insert(data.entries, {
			part = Rock,
			bodyVelocity = Bodymover,
			bodyAngularVelocity = AngularMover,
			rockAccelConn = rockAccelConn,
		})
	end

	task.spawn(function()
		while data.running do
			for _ = 1, PerTick do
				if not data.running then
					break
				end
				spawnOne()
			end
			task.wait(Interval)
		end
	end)

	return id
end

function DestructionService:DropFakeDebris(id)
	local data = FAKE_DEBRIS_ACTIVE[id]
	if not data then
		return
	end

	data.running = false
	FAKE_DEBRIS_ACTIVE[id] = nil

	for _, entry in data.entries do
		local part = entry.part
		if not part or not part.Parent then
			continue
		end

		if entry.bodyVelocity and entry.bodyVelocity.Parent then
			entry.bodyVelocity:Destroy()
		end
		if entry.bodyAngularVelocity and entry.bodyAngularVelocity.Parent then
			entry.bodyAngularVelocity:Destroy()
		end
		if entry.rockAccelConn then
			entry.rockAccelConn:Disconnect()
		end

		part.CanCollide = true
		part.CanTouch = true
		part.CanQuery = true

		DebrisDamage:TrackFall(part, data.ownerPlayer)
		ReplicateSet:FireAllClients("DebrisFallImpact", { Position = part.Position })

		task.delay(FAKE_DEBRIS_FALL_CLEANUP_TIME, function()
			if part and part.Parent then
				part:Destroy()
			end
		end)
	end
end

function DestructionService:CancelFakeDebris(id)
	local data = FAKE_DEBRIS_ACTIVE[id]
	if not data then
		return
	end

	data.running = false
	FAKE_DEBRIS_ACTIVE[id] = nil

	for _, entry in data.entries do
		local part = entry.part
		if part and part.Parent then
			if entry.rockAccelConn then
				entry.rockAccelConn:Disconnect()
			end
			part:Destroy()
		end
	end
end

return DestructionService
