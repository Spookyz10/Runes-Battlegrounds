local StructuralSupport = {}

local CHECK_MARGIN = 0.6

local function getNeighbors(part, candidateParts, params)
	local expandedSize = part.Size + Vector3.one * CHECK_MARGIN
	local touching = workspace:GetPartBoundsInBox(part.CFrame, expandedSize, params)

	local neighbors = {}
	for _, other in touching do
		if other ~= part and candidateParts[other] then
			neighbors[other] = true
		end
	end
	return neighbors
end

local function touchesGround(part, groundParams)
	local expandedSize = part.Size + Vector3.one * CHECK_MARGIN
	local touching = workspace:GetPartBoundsInBox(part.CFrame, expandedSize, groundParams)
	return #touching > 0
end

-- StructureParts: array de BaseParts candidatas
-- GroundInstances: array de instances que contam como ancoragem
-- Retorna array de "clusters" desconectados (cada cluster é um array de parts), já separados por conectividade
function StructuralSupport:FindUnsupportedClusters(StructureParts, GroundInstances)
	local candidateParts = {}
	for _, p in StructureParts do
		if p and p.Parent then
			candidateParts[p] = true
		end
	end

	if next(candidateParts) == nil then
		return {}
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = StructureParts

	local groundParams = OverlapParams.new()
	groundParams.FilterType = Enum.RaycastFilterType.Include
	groundParams.FilterDescendantsInstances = GroundInstances

	local supported = {}
	local queue = {}

	for part in candidateParts do
		if touchesGround(part, groundParams) then
			supported[part] = true
			table.insert(queue, part)
		end
	end

	local head = 1
	while head <= #queue do
		local current = queue[head]
		head += 1

		for neighbor in getNeighbors(current, candidateParts, overlapParams) do
			if not supported[neighbor] then
				supported[neighbor] = true
				table.insert(queue, neighbor)
			end
		end
	end

	local unsupportedSet = {}
	local unsupportedList = {}
	for part in candidateParts do
		if not supported[part] then
			unsupportedSet[part] = true
			table.insert(unsupportedList, part)
		end
	end

	if #unsupportedList == 0 then
		return {}
	end

	-- Agrupa os desconectados em clusters (cada cluster cai junto, com sua própria direção de queda)
	local visited = {}
	local clusters = {}

	for _, part in unsupportedList do
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

			for neighbor in getNeighbors(current, unsupportedSet, overlapParams) do
				if not visited[neighbor] then
					visited[neighbor] = true
					table.insert(clusterQueue, neighbor)
				end
			end
		end

		table.insert(clusters, cluster)
	end

	return clusters
end

-- Mantido por compatibilidade / uso direto simples (collapse único sem sub-clusters)
function StructuralSupport:CheckAndCollapse(StructureParts, GroundInstances, onCollapseGroup)
	local clusters = self:FindUnsupportedClusters(StructureParts, GroundInstances)

	local flat = {}
	for _, cluster in clusters do
		for _, part in cluster do
			table.insert(flat, part)
		end
	end

	if #flat > 0 and onCollapseGroup then
		onCollapseGroup(flat)
	end

	return flat
end

return StructuralSupport
