local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VoxBreaker = require(ReplicatedStorage.Shared.Modules.VoxBreaker)
local DebrisDamage = require(script.DebrisDamage)

local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

local DestructionService = {}

local DEBUG = true

local INSTAKILL_SIZE = 100
local DEBRIS_COLLISION_GROUP = "NonPColDebri"
local DEFAULT_TRACK_DURATION = 5
local DEFAULT_TRACK_HITBOX_SIZE = Vector3.new(6, 6, 6)

local MAX_CHUNKS_PER_IMPACT = 40
local NEIGHBOR_MARGIN = 1.2
local INTEGRITY_SEARCH_RADIUS = 40

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

local DESTROYABLES_ROOT = workspace:FindFirstChild("Destroyables")

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

local function touchesGround(part, groundParams)
	local expanded = part.Size + Vector3.one * NEIGHBOR_MARGIN
	local touching = workspace:GetPartBoundsInBox(part.CFrame, expanded, groundParams)
	return #touching > 0
end

local function getNeighbors(part, candidateSet, neighborParams)
	local expanded = part.Size + Vector3.one * NEIGHBOR_MARGIN
	local touching = workspace:GetPartBoundsInBox(part.CFrame, expanded, neighborParams)

	local neighbors = {}
	for _, other in touching do
		if other ~= part and candidateSet[other] then
			table.insert(neighbors, other)
		end
	end
	return neighbors
end

function DestructionService:CheckIntegrity(ImpactPosition, ImpactDirection)
	local parts = collectNearbyDestroyableParts(ImpactPosition, INTEGRITY_SEARCH_RADIUS)
	if #parts == 0 then
		return
	end

	local candidateSet = {}
	for _, p in parts do
		candidateSet[p] = true
	end

	local groundParams = OverlapParams.new()
	groundParams.FilterType = Enum.RaycastFilterType.Include
	groundParams.FilterDescendantsInstances = GROUND_INSTANCES

	local neighborParams = OverlapParams.new()
	neighborParams.FilterType = Enum.RaycastFilterType.Include
	neighborParams.FilterDescendantsInstances = parts

	local supported = {}
	local queue = {}

	for _, part in parts do
		if touchesGround(part, groundParams) then
			supported[part] = true
			table.insert(queue, part)
		end
	end

	local head = 1
	while head <= #queue do
		local current = queue[head]
		head += 1

		for _, neighbor in getNeighbors(current, candidateSet, neighborParams) do
			if not supported[neighbor] then
				supported[neighbor] = true
				table.insert(queue, neighbor)
			end
		end
	end

	local unsupported = {}
	for _, part in parts do
		if not supported[part] then
			table.insert(unsupported, part)
		end
	end

	if #unsupported == 0 then
		return
	end

	local unsupportedSet = {}
	for _, p in unsupported do
		unsupportedSet[p] = true
	end

	local visited = {}
	local clusters = {}

	for _, part in unsupported do
		if visited[part] then
			continue
		end

		local cluster = {}
		local clusterQueue = { part }
		visited[part] = true

		local qHead = 1
		while qHead <= #clusterQueue do
			local current = clusterQueue[qHead]
			qHead += 1
			table.insert(cluster, current)

			for _, neighbor in getNeighbors(current, unsupportedSet, neighborParams) do
				if not visited[neighbor] then
					visited[neighbor] = true
					table.insert(clusterQueue, neighbor)
				end
			end
		end

		table.insert(clusters, cluster)
	end

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
		part.CanCollide = true

		local away = part.Position - ImpactPosition
		local awayDir = away.Magnitude > 0.01 and away.Unit or Vector3.new(0, 1, 0)

		local combinedDir = (ImpactDirection * 0.7 + awayDir * 0.5) + Vector3.new(0, 0.35, 0)
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
	chunk.CanCollide = true
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
		dir = (awayDir * 0.5 + Direction.Unit * 0.7)
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

	local lifetime = math.clamp(chunk.Size.Magnitude * 0.5, 6, 25)
	Debris:AddItem(chunk, lifetime)
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

return DestructionService
