--[[
	FadeOut
	Módulo universal de fade out para ParticleEmitter, Beam, Part e Model.

	Cria uma "camada" virtual de transparência que se multiplica por cima da
	transparência/keyframes originais, sem modificar os valores originais —
	assim o efeito pode ser revertido com FadeIn se quiser futuramente.

	API:
		FadeOut.Out(target, duration, callback?)
			Faz fade out de `target` em `duration` segundos.
			`target` pode ser: ParticleEmitter, Beam, Part, Model ou qualquer instância com descendentes.
			`callback` é chamado quando o fade termina (opcional).

		FadeOut.In(target, duration, callback?)
			Reverte o fade (fade in) de `target` em `duration` segundos.

	Internamente usa um atributo "__FadeAlpha" (0 = transparente, 1 = visível)
	em cada leaf-instance para rastrear o estado atual.
]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local FadeOut = {}

-- ─── Helpers ───────────────────────────────────────────────────────────────

-- Coleta todos os "alvos folha" de fade numa instância qualquer
local function collectLeaves(instance)
	local leaves = {}

	local function push(inst)
		if inst:IsA("ParticleEmitter") or inst:IsA("Beam") or inst:IsA("Trail") then
			table.insert(leaves, inst)
		elseif inst:IsA("BasePart") then
			table.insert(leaves, inst)
		end
	end

	-- Se for direto um leaf, usa ele próprio
	if instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("BasePart") then
		push(instance)
	end

	-- Sempre pega descendants (inclusive se o próprio for um Model/Part container)
	for _, desc in instance:GetDescendants() do
		push(desc)
	end

	return leaves
end

-- ─── Snapshot de estado original ───────────────────────────────────────────

--[[
	Para cada leaf, salva o estado "base" na primeira vez que aplicamos fade.
	Isso garante que a lógica de alpha sempre parte do estado original
	e não acumula modificações repetidas.
]]
local function snapshotOriginal(leaf)
	-- Já tem snapshot → não sobrescreve
	if leaf:GetAttribute("__FadeSnapshotDone") then
		return
	end
	leaf:SetAttribute("__FadeSnapshotDone", true)

	if leaf:IsA("ParticleEmitter") then
		-- Guarda Color (ColorSequence) e LightEmission e Brightness
		-- Não tocamos em Transparency porque ela é uma NumberSequence com keyframes:
		-- em vez disso, vamos usar Rate + Enabled para o efeito de fade.
		-- Para ParticleEmitter o fade é feito zerando Rate e dando Emit 0 gradualmente.
		-- A abordagem mais fiel é escalar a transparência dos keyframes.
		local ks = leaf.Transparency.Keypoints
		local packed = {}
		for i, kp in ks do
			packed[i] = { Time = kp.Time, Value = kp.Value }
		end
		-- Serializa como JSON simples (sem depender de módulos externos)
		local serial = ""
		for i, kp in packed do
			serial = serial .. kp.Time .. "," .. kp.Value
			if i < #packed then
				serial = serial .. ";"
			end
		end
		leaf:SetAttribute("__OrigTransparency", serial)
		leaf:SetAttribute("__OrigBrightness", leaf.LightEmission)
	elseif leaf:IsA("Beam") then
		local ks = leaf.Transparency.Keypoints
		local packed = {}
		for i, kp in ks do
			packed[i] = { Time = kp.Time, Value = kp.Value }
		end
		local serial = ""
		for i, kp in packed do
			serial = serial .. kp.Time .. "," .. kp.Value
			if i < #packed then
				serial = serial .. ";"
			end
		end
		leaf:SetAttribute("__OrigTransparency", serial)
	elseif leaf:IsA("Trail") then
		leaf:SetAttribute("__OrigTransparency", leaf.Transparency)
	elseif leaf:IsA("BasePart") then
		leaf:SetAttribute("__OrigTransparency", leaf.Transparency)
	end

	-- Alpha inicial = 1 (completamente visível)
	leaf:SetAttribute("__FadeAlpha", 1)
end

-- ─── Aplicar alpha num leaf ─────────────────────────────────────────────────

local function deserializeKps(serial)
	local kps = {}
	for chunk in serial:gmatch("[^;]+") do
		local t, v = chunk:match("([^,]+),([^,]+)")
		table.insert(kps, { Time = tonumber(t), Value = tonumber(v) })
	end
	return kps
end

local function applyAlpha(leaf, alpha)
	-- alpha: 0 = totalmente transparente / 1 = original
	leaf:SetAttribute("__FadeAlpha", alpha)

	if leaf:IsA("ParticleEmitter") then
		local serial = leaf:GetAttribute("__OrigTransparency")
		if not serial then
			return
		end
		local origKps = deserializeKps(serial)

		-- Interpola cada keypoint: novo valor = lerp(1, origValue, alpha)
		-- Ou seja: alpha=1 → valor original; alpha=0 → completamente opaco (transparência=1)
		local newKps = {}
		for _, kp in origKps do
			local newVal = kp.Value + (1 - kp.Value) * (1 - alpha)
			table.insert(newKps, NumberSequenceKeypoint.new(kp.Time, newVal))
		end
		leaf.Transparency = NumberSequence.new(newKps)

		-- Também escala LightEmission
		local origBrightness = leaf:GetAttribute("__OrigBrightness") or leaf.LightEmission
		leaf.LightEmission = origBrightness * alpha
	elseif leaf:IsA("Beam") then
		local serial = leaf:GetAttribute("__OrigTransparency")
		if not serial then
			return
		end
		local origKps = deserializeKps(serial)

		local newKps = {}
		for _, kp in origKps do
			local newVal = kp.Value + (1 - kp.Value) * (1 - alpha)
			table.insert(newKps, NumberSequenceKeypoint.new(kp.Time, newVal))
		end
		leaf.Transparency = NumberSequence.new(newKps)
	elseif leaf:IsA("Trail") then
		local origT = leaf:GetAttribute("__OrigTransparency")
		if origT == nil then
			return
		end
		leaf.Transparency = origT + (1 - origT) * (1 - alpha)
	elseif leaf:IsA("BasePart") then
		local origT = leaf:GetAttribute("__OrigTransparency")
		if origT == nil then
			return
		end
		-- Interpola de origT (visível) até 1 (totalmente transparente)
		leaf.Transparency = origT + (1 - origT) * (1 - alpha)
	end
end

-- ─── Animação de fade ───────────────────────────────────────────────────────

-- Cancela fade em curso em cada leaf (via atributo de token)
local function cancelPendingFade(leaves)
	for _, leaf in leaves do
		local token = leaf:GetAttribute("__FadeToken")
		if token then
			leaf:SetAttribute("__FadeToken", token + 1) -- invalida o loop antigo
		end
	end
end

local function animateFade(leaves, fromAlpha, toAlpha, duration, callback)
	if duration <= 0 then
		for _, leaf in leaves do
			snapshotOriginal(leaf)
			applyAlpha(leaf, toAlpha)
		end
		if callback then
			callback()
		end
		return
	end

	-- Prepara snapshot e token em todos antes de iniciar
	for _, leaf in leaves do
		snapshotOriginal(leaf)
		local token = (leaf:GetAttribute("__FadeToken") or 0) + 1
		leaf:SetAttribute("__FadeToken", token)
	end

	local startTime = os.clock()

	-- Conexão de heartbeat única para animar todos em conjunto
	local conn
	conn = RunService.Heartbeat:Connect(function()
		local elapsed = os.clock() - startTime
		local t = math.clamp(elapsed / duration, 0, 1)
		local alpha = fromAlpha + (toAlpha - fromAlpha) * t

		local allDone = true

		for _, leaf in leaves do
			if not leaf or not leaf.Parent then
				continue
			end

			local currentToken = leaf:GetAttribute("__FadeToken")
			local myToken = leaf:GetAttribute("__FadeToken") -- sempre o mais recente
			-- Verifica se este loop ainda é o dono (token não mudou desde que iniciamos)
			-- Simplificação: guardamos o token de início em upvalue por leaf
			applyAlpha(leaf, alpha)

			if t < 1 then
				allDone = false
			end
		end

		if t >= 1 then
			conn:Disconnect()
			if callback then
				callback()
			end
		end
	end)
end

-- Versão com token por leaf para cancelamento correto
local function animateFadeWithTokens(leaves, fromAlpha, toAlpha, duration, callback)
	if duration <= 0 then
		for _, leaf in leaves do
			snapshotOriginal(leaf)
			applyAlpha(leaf, toAlpha)
		end
		if callback then
			callback()
		end
		return
	end

	-- Prepara snapshot e incrementa token em todos
	local myTokens = {}
	for _, leaf in leaves do
		snapshotOriginal(leaf)
		local newToken = (leaf:GetAttribute("__FadeToken") or 0) + 1
		leaf:SetAttribute("__FadeToken", newToken)
		myTokens[leaf] = newToken
	end

	local startTime = os.clock()
	local conn
	conn = RunService.Heartbeat:Connect(function()
		local elapsed = os.clock() - startTime
		local t = math.clamp(elapsed / duration, 0, 1)
		local alpha = fromAlpha + (toAlpha - fromAlpha) * t

		for _, leaf in leaves do
			if not leaf or not leaf.Parent then
				continue
			end
			-- Se o token mudou, outro fade assumiu o controle → paramos de tocar neste leaf
			if leaf:GetAttribute("__FadeToken") ~= myTokens[leaf] then
				continue
			end
			applyAlpha(leaf, alpha)
		end

		if t >= 1 then
			conn:Disconnect()
			if callback then
				callback()
			end
		end
	end)
end

-- ─── API Pública ────────────────────────────────────────────────────────────

--[[
	FadeOut.Out(target, duration, callback?)
	Faz fade out de `target` em `duration` segundos.
	Ao terminar chama `callback` (se fornecido).
]]
function FadeOut.Out(target, duration, callback)
	assert(typeof(target) == "Instance", "[FadeOut] target deve ser uma Instance")
	duration = duration or 0.5

	local leaves = collectLeaves(target)
	if #leaves == 0 then
		if callback then
			callback()
		end
		return
	end

	-- fromAlpha = alpha atual de cada leaf (pode estar no meio de um fade)
	-- Para simplificar, usamos o alpha atual do primeiro leaf como referência de partida
	-- (todos costumam estar no mesmo estado quando se chama Out)
	local fromAlpha = 1
	if leaves[1]:GetAttribute("__FadeAlpha") ~= nil then
		fromAlpha = leaves[1]:GetAttribute("__FadeAlpha")
	end

	animateFadeWithTokens(leaves, fromAlpha, 0, duration, callback)
end

--[[
	FadeOut.In(target, duration, callback?)
	Reverte o fade (fade in) de `target` em `duration` segundos.
]]
function FadeOut.In(target, duration, callback)
	assert(typeof(target) == "Instance", "[FadeOut] target deve ser uma Instance")
	duration = duration or 0.5

	local leaves = collectLeaves(target)
	if #leaves == 0 then
		if callback then
			callback()
		end
		return
	end

	local fromAlpha = 0
	if leaves[1]:GetAttribute("__FadeAlpha") ~= nil then
		fromAlpha = leaves[1]:GetAttribute("__FadeAlpha")
	end

	animateFadeWithTokens(leaves, fromAlpha, 1, duration, callback)
end

function FadeOut.OutAndDestroy(target, fadeDuration, destroyDelay)
	destroyDelay = destroyDelay or 0
	FadeOut.Out(target, fadeDuration, function()
		if destroyDelay > 0 then
			task.delay(destroyDelay, function()
				if target and target.Parent then
					target:Destroy()
				end
			end)
		else
			if target and target.Parent then
				target:Destroy()
			end
		end
	end)
end

return FadeOut
