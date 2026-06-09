--[[
	HitboxService
	src/modules/HitboxService.luau

	Gerencia hitboxes de player (a parte que representa o corpo colisável)
	e expõe funções de query de ataque altamente customizáveis.

	═══════════════════════════════════════════════════════════
	  HITBOX DO PLAYER (corpo)
	═══════════════════════════════════════════════════════════

	  HitboxService.initPlayer(character)
	    → Cria a hitbox de colisão do personagem (welded no HumanoidRootPart).
	      Chamado automaticamente via PlayerAdded / CharacterAdded.

	═══════════════════════════════════════════════════════════
	  QUERY DE ATAQUE
	═══════════════════════════════════════════════════════════

	  HitboxService.query(options) → { character, ... }

	  options:
	    origin     CFrame            – centro do hitbox (obrigatório)
	    size        Vector3           – tamanho do box (obrigatório)
	    offset      Vector3?          – offset local aplicado ao origin (padrão 0,0,0)
	    exclude     { Instance }?     – instâncias a excluir do overlap
	    maxHits     number?           – limite de personagens retornados (padrão: sem limite)
	    filterFunc  (char) -> bool?   – filtro extra: retorna true pra incluir, false pra ignorar

	  Exemplo:
	    local hits = HitboxService.query({
	        origin  = root.CFrame,
	        size    = Vector3.new(5, 5, 4),
	        offset  = Vector3.new(0, 0, -2),
	        exclude = { character },
	        maxHits = 3,
	        filterFunc = function(char)
	            return char:GetAttribute("Team") ~= myTeam
	        end,
	    })

	═══════════════════════════════════════════════════════════
	  DEBUG (só ativo em Studio / RunService.IsStudio)
	═══════════════════════════════════════════════════════════

	  Quando rodando no Studio, cada query cria uma Part vermelha
	  semitransparente mostrando o volume do hitbox.
	  Ela some automaticamente após DEBUG_LIFETIME segundos.

	  Para desativar o debug mesmo em Studio:
	    HitboxService.debugEnabled = false

	═══════════════════════════════════════════════════════════
	  UTILITÁRIOS
	═══════════════════════════════════════════════════════════

	  HitboxService.getPlayerHitbox(character) → Part?
	    → Retorna a hitbox de corpo do personagem.

	  HitboxService.destroyPlayerHitbox(character)
	    → Remove a hitbox de corpo (raramente necessário).
]]

local HitboxService = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- ─── Configuração ────────────────────────────────────────────────────────────

-- Tamanho padrão da hitbox de corpo do player
local PLAYER_HITBOX_SIZE = Vector3.new(3, 5, 2.5)

-- Atributos usados internamente
local ATTR_PLAYER_HITBOX = "PlayerHitbox"

-- Debug: mostra os volumes de ataque em Studio
local IS_STUDIO = RunService:IsStudio()
local DEBUG_LIFETIME = 0.25 -- segundos que a part debug fica visível
local DEBUG_COLOR = Color3.fromRGB(255, 50, 50)
local DEBUG_TRANSP = 0.7
local DEBUG_FOLDER_NAME = "HitboxDebug"

-- Permite desativar o debug manualmente mesmo em Studio
HitboxService.debugEnabled = true

-- ─── Debug folder ────────────────────────────────────────────────────────────

local debugFolder = nil

local function getDebugFolder()
	if not debugFolder or not debugFolder.Parent then
		debugFolder = workspace:FindFirstChild(DEBUG_FOLDER_NAME)
		if not debugFolder then
			debugFolder = Instance.new("Folder")
			debugFolder.Name = DEBUG_FOLDER_NAME
			debugFolder.Parent = workspace
		end
	end
	return debugFolder
end

local function spawnDebugBox(cf, size)
	if not IS_STUDIO or not HitboxService.debugEnabled then
		return
	end

	local part = Instance.new("Part")
	part.Name = "HitboxDebug"
	part.Size = size
	part.CFrame = cf
	part.Color = DEBUG_COLOR
	part.Transparency = DEBUG_TRANSP
	part.CanCollide = false
	part.CastShadow = false
	part.Anchored = true
	part.Parent = getDebugFolder()

	task.delay(DEBUG_LIFETIME, function()
		part:Destroy()
	end)
end

-- ─── Hitbox de corpo do player ───────────────────────────────────────────────

local function createPlayerHitbox(character)
	-- Evita duplicata
	local existing = character:FindFirstChild("Hitbox")
	if existing then
		return existing
	end

	local root = character:WaitForChild("HumanoidRootPart", 10)
	if not root then
		return
	end

	local box = Instance.new("Part")
	box.Name = "Hitbox"
	box.Size = PLAYER_HITBOX_SIZE
	box.Transparency = 1
	box.CanCollide = false
	box.CastShadow = false
	box.Massless = true
	box.Position = root.Position
	box:SetAttribute(ATTR_PLAYER_HITBOX, true)
	box.Parent = character

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = box
	weld.Parent = box

	-- Em Studio, mostra a hitbox de corpo em azul semitransparente
	if IS_STUDIO and HitboxService.debugEnabled then
		box.Transparency = 0.7
		box.Color = Color3.fromRGB(50, 100, 255)
	end

	return box
end

function HitboxService.initPlayer(character)
	createPlayerHitbox(character)
end

function HitboxService.getPlayerHitbox(character)
	return character:FindFirstChild("Hitbox")
end

function HitboxService.destroyPlayerHitbox(character)
	local box = character:FindFirstChild("Hitbox")
	if box then
		box:Destroy()
	end
end

-- ─── Query de ataque ─────────────────────────────────────────────────────────

--[[
	options = {
		origin     : CFrame       (obrigatório)
		size       : Vector3      (obrigatório)
		offset     : Vector3?
		exclude    : { Instance }?
		maxHits    : number?
		filterFunc : (character: Model) -> boolean?
	}
	Retorna lista de Models (characters) atingidos.
]]
function HitboxService.query(options)
	assert(options.origin, "HitboxService.query: 'origin' é obrigatório")
	assert(options.size, "HitboxService.query: 'size' é obrigatório")

	local offset = options.offset or Vector3.zero
	local exclude = options.exclude or {}
	local maxHits = options.maxHits -- nil = sem limite
	local filterFunc = options.filterFunc

	local cf = options.origin * CFrame.new(offset)

	-- Debug visual
	spawnDebugBox(cf, options.size)

	-- OverlapParams
	local params = OverlapParams.new()
	params.FilterDescendantsInstances = exclude
	params.FilterType = Enum.RaycastFilterType.Exclude

	local parts = workspace:GetPartBoundsInBox(cf, options.size, params)

	local hits = {}
	local seen = {}

	for _, part in parts do
		if not part:GetAttribute(ATTR_PLAYER_HITBOX) then
			continue
		end

		local char = part.Parent
		if seen[char] then
			continue
		end
		seen[char] = true

		-- Filtro customizado
		if filterFunc and not filterFunc(char) then
			continue
		end

		hits[#hits + 1] = char

		if maxHits and #hits >= maxHits then
			break
		end
	end

	return hits
end

--[[
    HitboxService.queryLinger(options) → { character, ... }

    Igual ao query normal, mas repete a checagem a cada frame durante
    options.duration segundos, seguindo a posição de options.anchor (Part).
    Útil para dashes onde o servidor recebe a posição com delay de rede.

    options extras:
        anchor      Part      – part cujo CFrame é usado a cada tick (obrigatório)
        duration    number    – segundos de linger (obrigatório)
        onHit       (char) -> ()? – callback chamado imediatamente em cada hit novo
]]
function HitboxService.queryLinger(options)
	assert(options.anchor, "HitboxService.queryLinger: 'anchor' é obrigatório")
	assert(options.size, "HitboxService.queryLinger: 'size' é obrigatório")
	assert(options.duration, "HitboxService.queryLinger: 'duration' é obrigatório")

	local anchor = options.anchor
	local size = options.size
	local offset = options.offset or Vector3.zero
	local exclude = options.exclude or {}
	local maxHits = options.maxHits
	local filterFunc = options.filterFunc
	local onHit = options.onHit
	local duration = options.duration

	local params = OverlapParams.new()
	params.FilterDescendantsInstances = exclude
	params.FilterType = Enum.RaycastFilterType.Exclude

	local hits = {}
	local seen = {}
	local elapsed = 0

	while elapsed < duration do
		local dt = task.wait()
		elapsed += dt

		if not anchor.Parent then
			break
		end

		local cf = anchor.CFrame * CFrame.new(offset)
		spawnDebugBox(cf, size)

		local parts = workspace:GetPartBoundsInBox(cf, size, params)

		for _, part in parts do
			if not part:GetAttribute(ATTR_PLAYER_HITBOX) then
				continue
			end

			local char = part.Parent
			if seen[char] then
				continue
			end
			seen[char] = true

			if filterFunc and not filterFunc(char) then
				continue
			end

			hits[#hits + 1] = char

			if onHit then
				onHit(char)
			end

			if maxHits and #hits >= maxHits then
				return hits
			end
		end
	end

	return hits
end

-- ─── Auto-init de players ────────────────────────────────────────────────────

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		HitboxService.initPlayer(character)
	end)
end)

for _, player in Players:GetPlayers() do
	if player.Character then
		HitboxService.initPlayer(player.Character)
	end
	player.CharacterAdded:Connect(function(character)
		HitboxService.initPlayer(character)
	end)
end

return HitboxService
