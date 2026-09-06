local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

return function(gui, card, item)
	local source = ReplicatedStorage

	for _, name in item.ModelPath or {} do
		source = source and source:FindFirstChild(name)
	end

	if item.ModelPath and source and (source:IsA("Model") or source:IsA("BasePart")) then
		local world = Instance.new("WorldModel")
		local model = Instance.new("Model")
		local clone = source:Clone()
		clone.Parent = model

		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") then
				part.Anchored = true
				part.CanCollide = false
			elseif part:IsA("BaseScript") then
				part:Destroy()
			end
		end

		local bounds, size = model:GetBoundingBox()
		model:PivotTo(CFrame.new(-bounds.Position) * model:GetPivot())
		model.Parent = world
		world.Parent = card.Preview
		local camera = Instance.new("Camera")
		camera.FieldOfView = 35
		camera.Parent = card.Preview
		card.Preview.CurrentCamera = camera
		local radius = math.max(size.Magnitude / 2, 0.1)
		local angle = 0
		local connection
		connection = RunService.RenderStepped:Connect(function(dt)
			if not card.Parent then
				connection:Disconnect()
				return
			end

			if not gui.Enabled or not card.Visible then
				return
			end

			angle += dt * 0.6
			local viewportSize = card.Preview.AbsoluteSize
			local aspect = viewportSize.X / math.max(viewportSize.Y, 1)
			local fov = math.atan(math.tan(math.rad(17.5)) * math.min(aspect, 1))
			local distance = radius / math.sin(fov) * 1.15
			camera.CFrame = CFrame.lookAt(
				Vector3.new(math.sin(angle), 0.3, math.cos(angle)).Unit * distance,
				Vector3.zero
			)
		end)
	else
		card.Placeholder.Visible = true
	end
end
