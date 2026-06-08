local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local LunarLungeVFX = {}

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

local function tween(instance, info, goals)
	TweenService:Create(instance, info, goals):Play()
end

function LunarLungeVFX.dash(character, direction)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

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
end

function LunarLungeVFX.impact(character, direction)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

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

function LunarLungeVFX.hit(character, direction)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

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

function LunarLungeVFX.blocked(character, direction)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

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

function LunarLungeVFX.handle(phase, character, direction)
	local handler = LunarLungeVFX[phase]
	if handler then
		handler(character, direction)
	else
		warn("LunarLungeVFX: fase desconhecida:", phase)
	end
end

return LunarLungeVFX
