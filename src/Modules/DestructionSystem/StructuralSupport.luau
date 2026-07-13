local StructuralSupport = {}

local CHECK_MARGIN = 0.15 -- folga pra detectar toque entre parts vizinhas

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

-- StructureParts: array de BaseParts pertencentes à mesma estrutura (ex: todas as parts do Model "Totem")
-- GroundInstances: array de instances que contam como "chão"/ancoragem (ex: {workspace.Terrain, workspace.Map.Foundations})
function StructuralSupport:CheckAndCollapse(StructureParts, GroundInstances, onCollapseGroup)
	if #StructureParts == 0 then
		return
	end

	local candidateParts = {}
	for _, p in StructureParts do
		if p and p.Parent then
			candidateParts[p] = true
		end
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = StructureParts

	local groundParams = OverlapParams.new()
	groundParams.FilterType = Enum.RaycastFilterType.Include
	groundParams.FilterDescendantsInstances = GroundInstances

	local supported = {}
	local queue = {}

	-- Ponto de partida do flood fill: tudo que toca o chão diretamente
	for part in candidateParts do
		if touchesGround(part, groundParams) then
			supported[part] = true
			table.insert(queue, part)
		end
	end

	-- Propaga suporte pelos vizinhos conectados
	local head = 1
	while head <= #queue do
		local current = queue[head]
		head += 1

		local neighbors = getNeighbors(current, candidateParts, overlapParams)
		for neighbor in neighbors do
			if not supported[neighbor] then
				supported[neighbor] = true
				table.insert(queue, neighbor)
			end
		end
	end

	-- Tudo que sobrou sem suporte cai
	local unsupportedGroup = {}
	for part in candidateParts do
		if not supported[part] then
			table.insert(unsupportedGroup, part)
		end
	end

	if #unsupportedGroup > 0 and onCollapseGroup then
		onCollapseGroup(unsupportedGroup)
	end

	return unsupportedGroup
end

return StructuralSupport
