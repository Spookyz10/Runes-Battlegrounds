local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Utility = require(ReplicatedStorage.Shared.Modules.Utility)

local Particles = Utility("Particles")

local rocks = {}

local function part(name, size, color)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Material = Enum.Material.Neon
	p.Parent = workspace:FindFirstChild("Debris") or workspace

	return p
end

local function remove(id)
	local data = rocks[id]

	if not data then
		return
	end

	data.Part:Destroy()
	data.Indicator:Destroy()
	rocks[id] = nil
end

RunService.RenderStepped:Connect(function()
	local now = workspace:GetServerTimeNow()

	for id, data in rocks do
		local t = math.max(0, now - data.Rock.Start)

		if t > data.Rock.Duration + 2 then
			remove(id)
			continue
		end

		t = math.min(t, data.Rock.Duration)
		local r = data.Rock
		local position = r.Origin + r.Velocity * t + Vector3.new(0, -r.Gravity * t * t / 2, 0)
		data.Part.CFrame = CFrame.new(position) * CFrame.Angles(t * 1.3, t * 0.8, t * 0.6)
		data.Indicator.Transparency = 1 - math.clamp(t / r.Duration, 0, 1)
	end
end)

return function(params)
	if params.Action == "Clear" then
		for id in rocks do
			remove(id)
		end
	elseif params.Action == "Launch" then
		local r = params.Rock
		local block = part("VolcanicLava", Vector3.new(20, 20, 20), Color3.fromRGB(255, 84, 13))
		local light = Instance.new("PointLight")
		light.Color = block.Color
		light.Range = 40
		light.Brightness = 2
		light.Parent = block
		local indicator = part("VolcanoImpactZone", Vector3.new(0.15, 20, 20), Color3.fromRGB(255, 58, 36))
		indicator.Shape = Enum.PartType.Cylinder
		local normal = r.Normal or Vector3.yAxis
		local tangent = normal:Cross(Vector3.zAxis)

		if tangent.Magnitude < 0.01 then
			tangent = normal:Cross(Vector3.xAxis)
		end

		tangent = tangent.Unit
		indicator.CFrame = CFrame.fromMatrix(r.Target + normal * 0.1, normal, tangent, normal:Cross(tangent))
		indicator.Transparency = 1
		block.CFrame = CFrame.new(r.Origin)
		rocks[params.Id] = { Part = block, Indicator = indicator, Rock = r }
		local source = workspace:FindFirstChild("VolcanoPart")

		if source then
			Particles.Emit(source)
		end
	elseif params.Action == "Impact" then
		remove(params.Id)
		local resources = ReplicatedStorage:FindFirstChild("Resources")
		local effects = resources and resources:FindFirstChild("Effects")
		local template = effects and effects:FindFirstChild("VolcanoExplosion")

		if not template then
			return
		end

		local clone = template:Clone()
		local container = clone

		if clone:IsA("Attachment") then
			container = part("VolcanoExplosionAnchor", Vector3.one, Color3.new())
			container.Transparency = 1
			container.CFrame = CFrame.new(params.Position)
			clone.CFrame = CFrame.identity
			clone.Parent = container
		elseif clone:IsA("BasePart") or clone:IsA("Model") then
			clone:PivotTo(CFrame.new(params.Position))
		else
			clone:Destroy()
			return
		end

		if clone:IsA("BasePart") then
			clone.Anchored = true
			clone.CanCollide = false
			clone.CanQuery = false
		end

		for _, p in clone:GetDescendants() do
			if p:IsA("BasePart") then
				p.Anchored = true
				p.CanCollide = false
				p.CanQuery = false
			end
		end

		container.Parent = workspace:FindFirstChild("Debris") or workspace
		Debris:AddItem(container, 2)
		Particles.Emit(clone)
	end
end
