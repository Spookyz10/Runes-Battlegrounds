local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local active = {}
local warned = false
local flameColor = ColorSequence.new(Color3.fromRGB(230, 170, 255), Color3.fromRGB(115, 40, 240))

local function remove(meteor)
	local data = active[meteor]
	if not data then
		return
	end
	active[meteor] = nil
	data.Effect:Destroy()
	data.Light:Destroy()
	data.Trail:Destroy()
	data.Left:Destroy()
	data.Right:Destroy()
end

local function bind(meteor)
	if
		active[meteor]
		or not meteor:IsA("BasePart")
		or meteor.Name ~= "Meteor"
		or not meteor.Parent
		or meteor.Parent.Name ~= "MeteorShowerObjects"
	then
		return
	end
	local resources = ReplicatedStorage:FindFirstChild("Resources") or ReplicatedStorage:FindFirstChild("resources")
	local effects = resources and resources:FindFirstChild("Effects")
	local template = effects and effects:FindFirstChild("MeteorEffect")
	if not template then
		if not warned then
			warn("[Meteor] Missing Resources.Effects.MeteorEffect")
			warned = true
		end
		return
	end
	local effect = template:Clone()
	if
		not (effect:IsA("Model") or effect:IsA("BasePart") or effect:IsA("Attachment") or effect:IsA("ParticleEmitter"))
	then
		effect:Destroy()
		warn("[Meteor] MeteorEffect must be a Model, BasePart, Attachment or ParticleEmitter.")
		return
	end
	if effect:IsA("ParticleEmitter") then
		local attachment = Instance.new("Attachment")
		attachment.Name = "MeteorFlame"
		effect.Parent = attachment
		effect = attachment
	end
	local attachments = {}
	local descendants = effect:GetDescendants()
	table.insert(descendants, effect)
	for _, object in descendants do
		if object:IsA("BasePart") then
			object.Anchored, object.CanCollide, object.CanTouch, object.CanQuery = true, false, false, false
		elseif object:IsA("ParticleEmitter") then
			object.Color = flameColor
			object.Enabled = true
			object.EmissionDirection = Enum.NormalId.Top
		elseif object:IsA("Beam") or object:IsA("Trail") then
			object.Color = flameColor
			object.Enabled = true
		elseif object:IsA("Attachment") then
			table.insert(attachments, object)
		end
	end
	local initialFrame = meteor.CFrame * CFrame.Angles(math.pi / 2, 0, 0)
	if effect:IsA("Attachment") then
		effect.CFrame = CFrame.Angles(math.pi / 2, 0, 0)
	else
		effect:PivotTo(initialFrame)
	end
	effect.Parent = meteor
	local light = Instance.new("PointLight")
	light.Color, light.Brightness, light.Range = Color3.fromRGB(180, 80, 255), 3, 65
	light.Parent = meteor
	local left, right = Instance.new("Attachment"), Instance.new("Attachment")
	left.Position, right.Position = Vector3.new(-3, 0, 0), Vector3.new(3, 0, 0)
	left.Parent, right.Parent = meteor, meteor
	local trail = Instance.new("Trail")
	trail.Attachment0, trail.Attachment1 = left, right
	trail.Color, trail.Lifetime, trail.LightEmission = flameColor, 0.45, 1
	trail.Transparency = NumberSequence.new(0.15, 1)
	trail.WidthScale = NumberSequence.new(1, 0)
	trail.FaceCamera = true
	trail.Parent = meteor
	active[meteor] =
		{ Effect = effect, Attachments = attachments, Light = light, Trail = trail, Left = left, Right = right }
end

workspace.DescendantAdded:Connect(bind)
local folder = workspace:FindFirstChild("MeteorShowerObjects")
if folder then
	for _, meteor in folder:GetChildren() do
		bind(meteor)
	end
end

RunService.RenderStepped:Connect(function()
	for meteor, data in active do
		if not meteor:IsDescendantOf(workspace) then
			remove(meteor)
			continue
		end
		-- The meteor's LookVector follows its flight; the flame's +Y points behind it.
		local frame = meteor.CFrame * CFrame.Angles(math.pi / 2, 0, 0)
		if data.Effect:IsA("Attachment") then
			data.Effect.WorldCFrame = frame
		else
			data.Effect:PivotTo(frame)
		end
		for _, attachment in data.Attachments do
			attachment.WorldCFrame = CFrame.new(attachment.WorldPosition) * frame.Rotation
		end
	end
end)
