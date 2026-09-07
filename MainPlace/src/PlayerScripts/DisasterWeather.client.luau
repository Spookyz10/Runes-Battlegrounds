local RunService = game:GetService("RunService")
local anchor, connection

local function update()
	if connection then
		connection:Disconnect()
		connection = nil
	end
	if anchor then
		anchor:Destroy()
		anchor = nil
	end
	local event = workspace:GetAttribute("ActiveDisaster")
	if event ~= "Storm" and event ~= "Blizzard" then
		return
	end
	local snow = event == "Blizzard"
	anchor = Instance.new("Part")
	anchor.Name = "LocalPrecipitation"
	anchor.Size = if snow then Vector3.new(100, 70, 100) else Vector3.new(90, 1, 90)
	anchor.Anchored, anchor.CanCollide, anchor.CanTouch, anchor.CanQuery = true, false, false, false
	anchor.Transparency = 1
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = if snow then "Snow" else "Rain"
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Color = ColorSequence.new(if snow then Color3.fromRGB(235, 245, 255) else Color3.fromRGB(170, 200, 235))
	emitter.Rate = 400
	-- Keep the local snow volume populated when the camera travels or zooms.
	emitter.LockedToPart = snow
	emitter.Lifetime = if snow then NumberRange.new(4, 5) else NumberRange.new(0.65, 0.85)
	emitter.Speed = if snow then NumberRange.new(20, 28) else NumberRange.new(130, 150)
	emitter.Size = NumberSequence.new(if snow then 0.4 else 0.5)
	emitter.Squash = NumberSequence.new(if snow then 0 else 2)
	emitter.Transparency = NumberSequence.new(0.2)
	emitter.EmissionDirection = Enum.NormalId.Bottom
	emitter.SpreadAngle = if snow then Vector2.new(8, 8) else Vector2.zero
	emitter.Acceleration = if snow then Vector3.new(5, -3, 0) else Vector3.new(0, -20, 0)
	emitter.Rotation = if snow then NumberRange.new(0, 360) else NumberRange.new(0)
	emitter.Orientation = if snow
		then Enum.ParticleOrientation.FacingCamera
		else Enum.ParticleOrientation.FacingCameraWorldUp
	emitter.RotSpeed = if snow then NumberRange.new(-50, 50) else NumberRange.new(0)
	emitter.Parent = anchor
	-- Multiple emitters keep the blizzard dense within each emitter's rate limit.
	for _ = 1, (if snow then 2 else 1) do
		emitter:Clone().Parent = anchor
	end
	local function position()
		local camera = workspace.CurrentCamera
		if camera then
			anchor.Position = camera.CFrame.Position + Vector3.new(0, if snow then 15 else 55, 0)
		end
	end
	position()
	anchor.Parent = workspace
	if snow then
		for _, particles in anchor:GetChildren() do
			if particles:IsA("ParticleEmitter") then
				particles:Emit(350)
			end
		end
	end
	connection = RunService.RenderStepped:Connect(position)
end

workspace:GetAttributeChangedSignal("ActiveDisaster"):Connect(update)
update()
