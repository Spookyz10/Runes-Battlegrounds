local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Particles = require(ReplicatedStorage.Shared.Modules.Utility)("Particles")
local active = {}
local lastFlash = -math.huge
local flash
local flashTween
local function clearFlash()
	if flashTween then
		flashTween:Cancel()
		flashTween = nil
	end
	if flash then
		flash:Destroy()
		flash = nil
	end
end

local function lightningFlash()
	-- Ten strikes share one sky flash instead of stacking ten exposure effects.
	if os.clock() - lastFlash < 0.5 then
		return
	end
	lastFlash = os.clock()
	clearFlash()
	local effect = Instance.new("ColorCorrectionEffect")
	effect.Name = "LightningFlash"
	effect.TintColor = Color3.fromRGB(225, 235, 255)
	effect.Brightness = 0.38
	effect.Parent = Lighting
	flash = effect
	flashTween = TweenService:Create(effect, TweenInfo.new(0.12), { Brightness = 0.04 })
	flashTween:Play()
	task.delay(0.14, function()
		if flash ~= effect then
			return
		end
		effect.Brightness = 0.22
		flashTween = TweenService:Create(effect, TweenInfo.new(0.4), { Brightness = 0 })
		flashTween:Play()
	end)
	task.delay(0.6, function()
		if flash == effect then
			clearFlash()
		end
	end)
end

return function(params)
	if params.Action == "Clear" then
		clearFlash()
		lastFlash = -math.huge
		for container in active do
			container:Destroy()
		end
		table.clear(active)
		return
	end
	if params.Name == "ThunderExplosion" then
		lightningFlash()
	end
	local resources = ReplicatedStorage:FindFirstChild("Resources") or ReplicatedStorage:FindFirstChild("resources")
	local effects = resources and resources:FindFirstChild("Effects")
	local template = effects and effects:FindFirstChild(params.Name)
	if not template then
		warn("[Disaster] Missing Effects." .. params.Name)
		return
	end
	local clone = template:Clone()
	local container = clone
	if clone:IsA("Attachment") then
		container = Instance.new("Part")
		container.Name = "WeatherExplosionAnchor"
		container.Size, container.Transparency = Vector3.one, 1
		container.Anchored, container.CanCollide, container.CanTouch, container.CanQuery = true, false, false, false
		container.CFrame = CFrame.new(params.Position)
		clone.CFrame = CFrame.identity
		clone.Parent = container
	elseif clone:IsA("Model") or clone:IsA("BasePart") then
		clone:PivotTo(CFrame.new(params.Position))
	else
		clone:Destroy()
		return
	end
	local descendants = clone:GetDescendants()
	table.insert(descendants, clone)
	for _, object in descendants do
		if params.Name == "MeteorExplosion" then
			if object:IsA("ParticleEmitter") or object:IsA("Beam") or object:IsA("Trail") then
				object.Color = ColorSequence.new(Color3.fromRGB(230, 175, 255), Color3.fromRGB(120, 45, 240))
			elseif object:IsA("Light") then
				object.Color = Color3.fromRGB(180, 90, 255)
			end
		end
		if object:IsA("BasePart") then
			object.Anchored, object.CanCollide, object.CanTouch, object.CanQuery = true, false, false, false
		end
	end
	container.Parent = workspace:FindFirstChild("Debris") or workspace
	active[container] = true
	container.Destroying:Once(function()
		active[container] = nil
	end)
	Debris:AddItem(container, params.Duration or 5)
	Particles.Emit(clone)
end
