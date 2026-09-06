local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Utility = require(ReplicatedStorage.Shared.Modules.Utility)
local Particles = Utility("Particles")

local Profiles = {}
for _, module in script.Profiles:GetChildren() do
	if module:IsA("ModuleScript") then
		Profiles[module.Name] = require(module)
	end
end

local M1Effects = {}

local function prepare(instance)
	if instance:IsA("BasePart") then
		instance.Anchored = true
		instance.CanCollide = false
		instance.CanTouch = false
		instance.CanQuery = false
	elseif instance:IsA("ParticleEmitter") then
		instance.Enabled = false
	end
end

local function playDefault(context)
	local template = context.Template
	if not template then
		return
	end
	if not template:IsA("BasePart") and not template:IsA("Model") and not template:IsA("Attachment") then
		return
	end

	local effect = template:Clone()
	local container = effect
	prepare(effect)
	for _, descendant in effect:GetDescendants() do
		prepare(descendant)
	end

	if effect:IsA("Attachment") then
		local anchor = Instance.new("Part")
		anchor.Name = "M1EffectAnchor"
		anchor.Size = Vector3.one
		anchor.Transparency = 1
		prepare(anchor)
		anchor.CFrame = context.CFrame
		effect.CFrame = CFrame.identity
		effect.Parent = anchor
		container = anchor
	else
		effect:PivotTo(context.CFrame)
	end

	container.Parent = workspace:FindFirstChild("Debris") or workspace
	Debris:AddItem(container, context.Lifetime)
	Particles.Emit(effect)
	return effect, container
end

function M1Effects.Play(params)
	if typeof(params) ~= "table" or typeof(params.CFrame) ~= "CFrame" then
		return
	end
	local profile = Profiles[params.Profile]
	local step = profile and profile.Steps[params.Step]
	if not step then
		return
	end

	local resources = ReplicatedStorage:FindFirstChild("Resources")
	local folder = resources and resources:FindFirstChild("M1Effects")
	for _, name in profile.Path or {} do
		folder = folder and folder:FindFirstChild(name)
	end
	local context = {
		Character = params.Character,
		Step = params.Step,
		Template = folder and folder:FindFirstChild(step.Asset or params.Step),
		CFrame = params.CFrame * (step.Offset or profile.Offset or CFrame.new(0, 0, -3)),
		Lifetime = step.Lifetime or profile.Lifetime or 2,
		Emit = Particles.Emit,
		Debris = Debris,
	}
	local play = step.Play or profile.Play or playDefault
	play(context, playDefault)
end

return M1Effects
