--[[
	VFX: LunarLunge
	src/client/VFX/LunarLunge.luau

	Recebe chamadas do VFXClient com a fase da skill e os dados.
	Cada fase ("dash", "impact", "hit", "blocked") tem seu próprio handler.

	Adicione seus efeitos (partículas, tweens, sons, beams, etc.) aqui.
	O servidor nunca toca neste arquivo — é 100% cliente.

	Fases disponíveis:
	  "dash"    → personagem começou o dash
	  "impact"  → dash terminou, hitbox foi criada
	  "hit"     → alguém foi acertado
	  "blocked" → alguém bloqueou

	Parâmetros recebidos pelo handler:
	  character  : Model   → personagem relevante (caster ou vítima, depende da fase)
	  direction  : Vector3 → direção do dash
]]

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local LunarLungeVFX = {}

-- ─── Utilitários ─────────────────────────────────────────────────────────────

-- Cria uma part temporária no workspace (ex.: anel de impacto, rastro, etc.)
local function makePart(props)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CastShadow = false
	for k, v in props do
		p[k] = v
	end
	p.Parent = workspace
	return p
end

-- Tween simples de uma propriedade
local function tween(instance, info, goals)
	TweenService:Create(instance, info, goals):Play()
end

-- ─── Handlers por fase ───────────────────────────────────────────────────────

--[[
	"dash" → disparado quando o caster começa o dash.
	Aqui você colocaria: trilha de partículas, motion blur, som de vento, etc.
]]
function LunarLungeVFX.dash(character, direction)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	-- Exemplo: rastro de 3 discos que somem
	for i = 1, 3 do
		task.delay(i * 0.08, function()
			if not root or not root.Parent then
				return
			end

			local trail = makePart({
				Size = Vector3.new(3.5 - i * 0.5, 3.5 - i * 0.5, 0.2),
				CFrame = root.CFrame * CFrame.new(0, 0, i * 1.5),
				Color = Color3.fromRGB(120, 180, 255),
				Material = Enum.Material.Neon,
				Transparency = 0.4 + i * 0.1,
				Shape = Enum.PartType.Cylinder,
			})

			tween(trail, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = trail.Size * 0.5,
			})

			Debris:AddItem(trail, 0.35)
		end)
	end

	-- Placeholder: adicione sons, ParticleEmitters, beams, etc.
	-- local sound = Instance.new("Sound")
	-- sound.SoundId = "rbxassetid://SEU_ID"
	-- sound.Parent  = root
	-- sound:Play()
	-- Debris:AddItem(sound, 2)
end

--[[
	"impact" → disparado quando o dash termina e a hitbox é criada.
	Aqui você colocaria: anel de onda de choque, flash de luz, som de impacto.
]]
function LunarLungeVFX.impact(character, direction)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	-- Exemplo: anel expansivo (cilindro achatado que escala pra fora)
	local ring = makePart({
		Size = Vector3.new(1, 0.3, 1),
		CFrame = CFrame.new(root.Position) * CFrame.Angles(0, 0, math.pi / 2),
		Color = Color3.fromRGB(150, 200, 255),
		Material = Enum.Material.Neon,
		Transparency = 0.3,
		Shape = Enum.PartType.Cylinder,
	})

	tween(ring, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(1, 12, 12),
		Transparency = 1,
	})

	Debris:AddItem(ring, 0.55)

	-- Exemplo: flash central
	local flash = makePart({
		Size = Vector3.new(5, 5, 5),
		CFrame = CFrame.new(root.Position),
		Color = Color3.fromRGB(200, 230, 255),
		Material = Enum.Material.Neon,
		Transparency = 0.0,
		Shape = Enum.PartType.Ball,
	})

	tween(flash, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(12, 12, 12),
		Transparency = 1,
	})

	Debris:AddItem(flash, 0.3)
end

--[[
	"hit" → disparado para CADA personagem acertado.
	character aqui é a VÍTIMA.
	Aqui você colocaria: flash vermelho na vítima, som de hit, partículas.
]]
function LunarLungeVFX.hit(character, direction)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	-- Exemplo: flash azul na vítima
	local flash = makePart({
		Size = Vector3.new(4, 4, 4),
		CFrame = CFrame.new(root.Position),
		Color = Color3.fromRGB(100, 160, 255),
		Material = Enum.Material.Neon,
		Transparency = 0.2,
		Shape = Enum.PartType.Ball,
	})

	tween(flash, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1,
		Size = Vector3.new(7, 7, 7),
	})

	Debris:AddItem(flash, 0.25)
end

--[[
	"blocked" → disparado quando alguém bloqueia.
	character aqui é o BLOQUEADOR.
]]
function LunarLungeVFX.blocked(character, direction)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	-- Exemplo: faísca dourada
	local spark = makePart({
		Size = Vector3.new(2, 2, 2),
		CFrame = CFrame.new(root.Position),
		Color = Color3.fromRGB(255, 220, 80),
		Material = Enum.Material.Neon,
		Transparency = 0.1,
		Shape = Enum.PartType.Ball,
	})

	tween(spark, TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
		Transparency = 1,
		Size = Vector3.new(5, 5, 5),
	})

	Debris:AddItem(spark, 0.25)
end

-- ─── Dispatch ────────────────────────────────────────────────────────────────

-- Chamado pelo VFXClient com a fase e os dados
function LunarLungeVFX.handle(phase, character, direction)
	local handler = LunarLungeVFX[phase]
	if handler then
		handler(character, direction)
	else
		warn("LunarLungeVFX: fase desconhecida:", phase)
	end
end

return LunarLungeVFX
