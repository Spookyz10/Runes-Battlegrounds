local ServerStorage = game:GetService("ServerStorage")

local SvModules = ServerStorage.Modules
local DestructionService = require(SvModules.DestructionSystem)
local StructuralSupport = require(SvModules.DestructionSystem.StructuralSupport)

local WindCollapseTicker = {}

local CHECK_INTERVAL = 8 -- segundos entre varreduras, ajusta ao gosto
local WIND_DIRECTION = Vector3.new(1, 0, 0.3).Unit -- ou algo dinâmico/rotativo se quiser
local GROUND_INSTANCES = {
	workspace.Map.Arena.Island.Ground,
	workspace.Map.Arena.Island.Ground2,
}

local DESTROYABLES_ROOT = workspace.Map:FindFirstChild("Destroyables")

local function isDestroyablePart(part)
	if not part:IsA("BasePart") then
		return false
	end
	return part:GetAttribute("Destroyable") == true
end

function WindCollapseTicker:Start()
	task.spawn(function()
		while true do
			task.wait(CHECK_INTERVAL)

			if not DESTROYABLES_ROOT then
				continue
			end

			local parts = {}
			for _, desc in DESTROYABLES_ROOT:GetDescendants() do
				if isDestroyablePart(desc) then
					table.insert(parts, desc)
				end
			end

			if #parts == 0 then
				continue
			end

			local clusters = StructuralSupport:FindUnsupportedClusters(parts, GROUND_INSTANCES)

			for _, cluster in clusters do
				-- sem posição de impacto real, usa o centro do cluster como "origem" pra física de queda
				local sum = Vector3.zero
				for _, part in cluster do
					sum += part.Position
				end
				local center = sum / #cluster

				DestructionService:CollapseCluster(cluster, center, WIND_DIRECTION)
			end
		end
	end)
end

return WindCollapseTicker
