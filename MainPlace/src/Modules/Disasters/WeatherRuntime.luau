local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Hitbox = require(script.Parent.Parent.HitboxHandler)
local IFrames = require(script.Parent.Parent.iFramesService)
local Remote = require(ReplicatedStorage.Shared.Modules.RemoteManager)
local Impact = require(script.Parent.Impact)

local Runtime = {}
Runtime.__index = Runtime

function Runtime.new(name)
	local map = workspace:FindFirstChild("Map")
	local arena = map and map:FindFirstChild("Arena")
	assert(arena, "Map.Arena is required.")
	local low = Vector3.new(math.huge, math.huge, math.huge)
	local high = -low
	local parts = arena:GetDescendants()
	if arena:IsA("BasePart") then
		table.insert(parts, arena)
	end
	for _, part in parts do
		if part:IsA("BasePart") then
			for x = -1, 1, 2 do
				for y = -1, 1, 2 do
					for z = -1, 1, 2 do
						local point = part.CFrame:PointToWorldSpace(part.Size * Vector3.new(x, y, z) / 2)
						low, high = low:Min(point), high:Max(point)
					end
				end
			end
		end
	end
	assert(low.X ~= math.huge, "Arena has no ground parts.")
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { arena }
	local snow = workspace:FindFirstChild("Snow")
	if name == "Blizzard" and snow then
		params.FilterDescendantsInstances = { arena, snow }
	end
	local folder = Instance.new("Folder")
	folder.Name = name .. "Objects"
	folder.Parent = workspace
	return setmetatable({
		Active = true,
		Folder = folder,
		Low = low,
		High = high,
		Params = params,
		Random = Random.new(),
		Connections = {},
		Tweens = {},
	}, Runtime)
end

function Runtime:Target(player)
	local root = player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local hum = root and root.Parent:FindFirstChildOfClass("Humanoid")
	for attempt = 1, 16 do
		local x, z = self.Random:NextNumber(self.Low.X, self.High.X), self.Random:NextNumber(self.Low.Z, self.High.Z)
		if attempt == 1 and root and hum and hum.Health > 0 then
			x, z = root.Position.X, root.Position.Z
		end
		local hit = workspace:Raycast(
			Vector3.new(x, self.High.Y + 100, z),
			Vector3.new(0, -(self.High.Y - self.Low.Y + 300), 0),
			self.Params
		)
		if hit then
			return hit.Position, hit.Normal
		end
	end
	return nil
end

function Runtime:Part(name, position, size, color)
	local part = Instance.new("Part")
	part.Name, part.Size, part.Color = name, size, color
	part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery = true, false, false, false
	part.Position = position
	part.Parent = self.Folder
	return part
end

function Runtime:Effect(name, position, duration, continuous)
	if not continuous then
		Remote.FireAllClients(
			"ReplicateTask",
			"WeatherExplosion",
			{ Name = name, Position = position, Duration = duration }
		)
		return
	end
	local resources = ReplicatedStorage:FindFirstChild("Resources") or ReplicatedStorage:FindFirstChild("resources")
	local effects = resources and resources:FindFirstChild("Effects")
	local template = effects and effects:FindFirstChild(name)
	if not template then
		warn("[Disaster] Missing Effects." .. name)
		return
	end
	local clone = template:Clone()
	local container = clone
	if clone:IsA("Attachment") then
		container = self:Part(name .. "Anchor", position, Vector3.one, Color3.new())
		container.Transparency = 1
		clone.CFrame = CFrame.identity
		clone.Parent = container
	elseif clone:IsA("Model") or clone:IsA("BasePart") then
		clone:PivotTo(CFrame.new(position))
	else
		clone:Destroy()
		return
	end
	local descendants = clone:GetDescendants()
	table.insert(descendants, clone)
	for _, object in descendants do
		if object:IsA("BasePart") then
			object.Anchored, object.CanCollide, object.CanTouch, object.CanQuery = true, false, false, false
		end
	end
	container.Parent = self.Folder
	task.delay(duration, function()
		container:Destroy()
	end)
	return container
end

function Runtime:Hit(position, size, callback)
	Hitbox:SimpleOnce(CFrame.new(position), size, CFrame.identity, {}, nil, nil, function(character)
		local hum = character:FindFirstChildOfClass("Humanoid")
		local root = character:FindFirstChild("HumanoidRootPart")
		if self.Active and hum and root and hum.Health > 0 and not IFrames:HasiFrame(character, 1) then
			callback(character, hum, root)
		end
	end)
end

function Runtime:Loop(interval, callback)
	task.spawn(function()
		while self.Active do
			callback()
			task.wait(if type(interval) == "function" then interval() else interval)
		end
	end)
end

function Runtime:Impact(character, position, damage, kind)
	Impact(character, position, damage, kind, function()
		return self.Active
	end)
end

-- The full danger area is visible immediately; the inner disc fills until impact.
function Runtime:Indicator(position, width, duration, color, normal)
	normal = normal or Vector3.yAxis
	local tangent = normal:Cross(Vector3.zAxis)
	if tangent.Magnitude < 0.01 then
		tangent = normal:Cross(Vector3.xAxis)
	end
	tangent = tangent.Unit
	local cf = CFrame.fromMatrix(position + normal * 0.15, normal, tangent, normal:Cross(tangent))
	-- Enclose the box hitbox's corners as well as its edges.
	local diameter = width * math.sqrt(2)
	local outline = self:Part("DangerZone", position, Vector3.new(0.1, diameter, diameter), color)
	outline.Shape, outline.Material, outline.Transparency = Enum.PartType.Cylinder, Enum.Material.Neon, 0.65
	outline.CFrame = cf
	local fill = self:Part("DangerCountdown", position, Vector3.new(0.12, 0.2, 0.2), color)
	fill.Shape, fill.Material, fill.Transparency = Enum.PartType.Cylinder, Enum.Material.Neon, 0.3
	fill.CFrame = cf + normal * 0.08
	local tween = TweenService:Create(
		fill,
		TweenInfo.new(duration, Enum.EasingStyle.Linear),
		{ Size = Vector3.new(0.12, diameter, diameter) }
	)
	self.Tweens[tween] = true
	tween.Completed:Once(function()
		self.Tweens[tween] = nil
	end)
	tween:Play()
	return function()
		tween:Cancel()
		self.Tweens[tween] = nil
		outline:Destroy()
		fill:Destroy()
	end
end

function Runtime:Warn(position, width, duration, color, normal, callback)
	local clear = self:Indicator(position, width, duration, color, normal)
	task.delay(duration, function()
		clear()
		if self.Active then
			callback()
		end
	end)
end

function Runtime:Fall(kind, damage, diameter, player)
	local target, normal = self:Target(player)
	if not target then
		return
	end
	local meteor = kind == "Meteor"
	local height = if meteor then self.Random:NextNumber(1500, 1900) else 180
	local spread = if meteor then 650 else 90
	local origin = target
		+ Vector3.new(self.Random:NextNumber(-spread, spread), height, self.Random:NextNumber(-spread, spread))
	local landing = target + Vector3.new(0, diameter / 2, 0)
	local direction = (landing - origin).Unit
	local part = self:Part(
		kind,
		origin,
		Vector3.one * diameter,
		if meteor then Color3.fromRGB(173, 75, 255) else Color3.fromRGB(170, 225, 255)
	)
	part.Material = if meteor then Enum.Material.Neon else Enum.Material.Ice
	part.Shape = if meteor then Enum.PartType.Ball else Enum.PartType.Block
	part.CFrame = CFrame.lookAlong(origin, direction)
	local duration = if meteor then 4.5 else 2.5
	local clearIndicator = self:Indicator(target, diameter * 2, duration, part.Color, normal)
	local tween = TweenService:Create(
		part,
		TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ CFrame = CFrame.lookAlong(landing, direction) }
	)
	self.Tweens[tween] = true
	tween.Completed:Once(function(state)
		self.Tweens[tween] = nil
		part:Destroy()
		clearIndicator()
		if not self.Active or state ~= Enum.PlaybackState.Completed then
			return
		end
		self:Effect(kind .. "Explosion", target, 5)
		self:Hit(target + Vector3.new(0, diameter / 2, 0), Vector3.one * diameter * 2, function(character)
			self:Impact(character, target, damage, kind)
		end)
	end)
	tween:Play()
end

function Runtime:Heartbeat(callback)
	local connection = RunService.Heartbeat:Connect(callback)
	table.insert(self.Connections, connection)
	return connection
end

function Runtime:Destroy()
	self.Active = false
	for _, connection in self.Connections do
		connection:Disconnect()
	end
	for tween in self.Tweens do
		tween:Cancel()
	end
	self.Folder:Destroy()
	Remote.FireAllClients("ReplicateTask", "WeatherExplosion", { Action = "Clear" })
end

return Runtime
