local Constants = require(script.Parent.Shared.Constants)
local RunService = Constants.RunService
local TS = Constants.TS

local INDICATOR_COLOR = Color3.fromRGB(180, 220, 255)
local INDICATOR_SIZE_START = 4
local INDICATOR_SIZE_MAX = 60
local GROW_TIME = 0.5
local PULSE_SPEED = 2.5
local Y_OFFSET = 0.15
local PROJECTILE_ORIGIN_OFFSET = Vector3.new(0, 70, 0)
local MAX_RAYCAST_DIST = 1500

local ExcludeRayParams = RaycastParams.new()
ExcludeRayParams.FilterType = Enum.RaycastFilterType.Exclude
ExcludeRayParams.FilterDescendantsInstances = { workspace.Live, workspace.Thrown }
ExcludeRayParams.IgnoreWater = true

return function(Params)
	local Character = Params.char
	if not Character or not Character.Parent then
		return
	end
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return
	end

	local Indicator = Instance.new("Part")
	Indicator.Name = "LunarIndicator_" .. Character.Name
	Indicator.Anchored = true
	Indicator.CanCollide = false
	Indicator.CanTouch = false
	Indicator.CanQuery = false
	Indicator.CastShadow = false
	Indicator.Material = Enum.Material.Neon
	Indicator.Color = INDICATOR_COLOR
	Indicator.Shape = Enum.PartType.Cylinder
	Indicator.Size = Vector3.new(0.08, INDICATOR_SIZE_START, INDICATOR_SIZE_START)
	Indicator.Transparency = 0.2
	Indicator.Parent = workspace.Thrown

	TS:Create(
		Indicator,
		TweenInfo.new(GROW_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = Vector3.new(0.08, INDICATOR_SIZE_MAX, INDICATOR_SIZE_MAX) }
	):Play()

	local startTime = os.clock()
	local conn
	conn = RunService.Heartbeat:Connect(function()
		if not Indicator or not Indicator.Parent then
			conn:Disconnect()
			return
		end

		-- Origem da lua: 70 studs acima do HumRP (mesmo do servidor)
		local moonOrigin = HumRP and HumRP.Parent and (HumRP.Position + PROJECTILE_ORIGIN_OFFSET) or Indicator.Position

		-- Direção atual do aim (atualizada em tempo real pelo StartLunarAimControl)
		local aimDir = shared._lunarAimDirection
		if not aimDir or aimDir.Magnitude < 0.01 then
			aimDir = HumRP and HumRP.Parent and HumRP.CFrame.LookVector or Vector3.new(0, 0, -1)
		end
		aimDir = aimDir.Unit

		-- Raycast na direção do aim a partir da origem da lua
		local ray = workspace:Raycast(moonOrigin, aimDir * MAX_RAYCAST_DIST, ExcludeRayParams)

		local landPos
		if ray then
			landPos = ray.Position
		else
			-- Se não bater em nada, projeta no chão (Y=0 ou ponto mais próximo)
			-- Resolve: moonOrigin + t * aimDir onde Y = 0
			if math.abs(aimDir.Y) > 0.001 then
				local t = -moonOrigin.Y / aimDir.Y
				if t > 0 then
					landPos = moonOrigin + aimDir * t
				end
			end
		end

		if landPos then
			-- Reposiciona o indicador no ponto de impacto projetado
			-- Cylinder tem eixo ao longo do X local → rotaciona 90° em Z pra deitar no chão
			Indicator.CFrame = CFrame.new(landPos + Vector3.new(0, Y_OFFSET, 0)) * CFrame.Angles(0, 0, math.rad(90))
		end

		-- Pulso de transparência
		local elapsed = os.clock() - startTime
		local pulse = math.sin(elapsed * PULSE_SPEED * math.pi) * 0.15
		Indicator.Transparency = math.clamp(0.35 + pulse, 0.1, 0.6)
	end)

	if not shared._lunarIndicators then
		shared._lunarIndicators = {}
	end
	shared._lunarIndicators[Character] = { part = Indicator, conn = conn }
end
