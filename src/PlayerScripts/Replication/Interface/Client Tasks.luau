type particlesModule = {
	GetHLF: (Part: Part?) -> number,
	Emit: (Part: Part?) -> (),
	Enabled: (Part: Part?, State: boolean) -> (),
	EnableTrail: (Part: Part?, State: boolean) -> (),
	scaleLifetime: (Part: Part?, newScale: number) -> (),
	tweenScale: (Model: Model, Parameters: { startScale: number?, goalScale: number, Info: TweenInfo }) -> (),
	resizeParticle: (Particles: { any }, GoalSize: number) -> (),
}

local ClientTasks = tick()

local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")

local Resources = RS:WaitForChild("Resources")

local LocalPlayer = game:GetService("Players").LocalPlayer
local RS_Modules = RS.Shared:WaitForChild("Modules")

local CamShakePresets = require(RS_Modules.CamShakePresets)
local Utility = require(RS_Modules:WaitForChild("Utility"))
local ParticlesModule: particlesModule = Utility("Particles")
local BoatTween = require(RS_Modules.BoatTween)

local MapRayParams = RaycastParams.new()
MapRayParams.FilterType = Enum.RaycastFilterType.Include
MapRayParams.FilterDescendantsInstances = {
	workspace.Map:WaitForChild("Arena"),
	workspace.Map:WaitForChild("Miscellaneous"),
	workspace.Map.Borders,
	workspace.Map:WaitForChild("Destroyables"):WaitForChild("Buildings"),
}

local GroundRayParams = RaycastParams.new()
GroundRayParams.FilterType = Enum.RaycastFilterType.Include
GroundRayParams.FilterDescendantsInstances = {
	workspace.Map.Arena,
	workspace.Map.Borders,
	workspace.Map.Destroyables.Buildings,
}

local ExcludeRayParams = RaycastParams.new()
ExcludeRayParams.IgnoreWater = true
ExcludeRayParams.FilterDescendantsInstances = { workspace.Thrown }
ExcludeRayParams.FilterType = Enum.RaycastFilterType.Exclude

local MapOverlapParams = OverlapParams.new()
MapOverlapParams.RespectCanCollide = true
MapOverlapParams.FilterType = MapRayParams.FilterType
MapOverlapParams.FilterDescendantsInstances = { workspace.Map }

local ClientTasksLoadTime = tick() - ClientTasks

local function raycast(Origin, Direction, rayParams, isWhitelist, returnIsolated)
	local localRayParams
	if typeof(rayParams) == "table" then
		localRayParams = RaycastParams.new()
		localRayParams.FilterDescendantsInstances = rayParams
		if isWhitelist then
			localRayParams.FilterType = Enum.RaycastFilterType.Include
		else
			localRayParams.FilterType = Enum.RaycastFilterType.Exclude
		end
	else
		localRayParams = MapRayParams
	end

	local ray = workspace:Raycast(Origin, Direction, localRayParams)
	if not returnIsolated then
		return ray
	else
		return ray.Instance, ray.Position, ray.Material, ray.Normal
	end
end

local ReplicationEffects = {
	preloadanims = function(AnimationsList)
		local PreloadRig = workspace:WaitForChild("Preloader")
		local Animator = PreloadRig:WaitForChild("Humanoid"):WaitForChild("Animator")

		for _, AnimationId in
			{
				98691909912183,
				115733546570440,
			}
		do
			local Animation = Instance.new("Animation")
			Animation.AnimationId = "rbxassetid://" .. AnimationId

			Animator:LoadAnimation(Animation)
			Animation:Destroy()
		end

		for _, AnimationId in AnimationsList do
			if not AnimationId or AnimationId == "" then
				continue
			end
			local Animation = Instance.new("Animation")
			Animation.AnimationId = AnimationId

			Animator:LoadAnimation(Animation)
			Animation:Destroy()
		end

		for _, Animation: Animation in RS:GetDescendants() do
			if Animation:IsA("Animation") and Animation.AnimationId ~= "" then
				Animator:LoadAnimation(Animation)
			end
		end

		Debris:AddItem(PreloadRig, 5)
	end,

	DashMiss = function(Params)
		local PrimaryPart: BasePart = Params.PrimaryPart
		local YAngle = Params.YAngle or 0

		local GroundRay = raycast(PrimaryPart.Position, Vector3.new(0, -4, 0), MapRayParams)
		if not GroundRay then
			return
		end

		local SmokeBack = Resources.Effects.SmokeBack:Clone()
		SmokeBack.CFrame = PrimaryPart.CFrame * CFrame.new(0, -3, 0) * CFrame.Angles(0, YAngle, 0)
		SmokeBack.Parent = workspace.Thrown
		SmokeBack.SmokeBack.Smoke.Color = ColorSequence.new(GroundRay.Instance.Color)
		ParticlesModule.Emit(SmokeBack)
		Debris:AddItem(SmokeBack, 3)
	end,

	Hitbox = function(Params)
		for _, v in workspace.Thrown:GetChildren() do
			if v.Name == LocalPlayer.UserId .. " Hitbox" then
				v:Destroy()
			end
		end

		local Visualizer = Resources.Effects.Hitbox:Clone()
		Visualizer.CFrame = Params.CFrame * (Params.Offset or CFrame.new(0, 0, 0))

		if Params.Method == "Box" then
			Visualizer.Size = Params.Size
		else
			Visualizer.Shape = Enum.PartType.Ball
			Visualizer.Size = Vector3.one * Params.Size
		end

		Visualizer.Parent = workspace.Thrown
		Debris:AddItem(Visualizer, 0.1)
	end,

	RemoveAllBodyMovers = function(Character)
		for _, BodyMover in Character:GetDescendants() do
			if BodyMover:IsA("BodyVelocity") or BodyMover:IsA("LinearVelocity") or BodyMover:IsA("BodyPosition") then
				BodyMover:Destroy()
			end
		end
	end,

	ShakeCamera = function(params)
		task.spawn(function()
			if params["Intensity"] ~= nil then
				if params.Last then
					local Intensity = params.Intensity

					for i = 1, params.Last / 0.03 do
						shared.addshake(Intensity)

						Intensity *= 0.9

						task.wait(0.03)
					end
				else
					shared.addshake(params.Intensity)
				end
			elseif params.Instance then
				shared.sustainshake(params.Instance, params.shakeTime, params.fadeOutTime)
			else
				if params.Preset then
					local Preset = CamShakePresets[params.Preset]
					assert(Preset, "The specified preset does not exist.")

					shared.addshake(Preset.Magnitude, Preset.Roughness, Preset.FadeInTime, Preset.FadeOutTime)
				else
					shared.addshake(params.Magnitude, params.Roughness, params.FadeInTime, params.FadeOutTime)
				end
			end
		end)
	end,

	armTrailEffect = function(Params)
		local waterPalm = Resources.Effects.ArmTrailEffect:Clone()

		local lifeTime = Params.lifeTime

		if lifeTime then
			local limbName = Params and Params.limbName

			for i, v in next, Params.char:GetChildren() do
				if v:IsA("BasePart") then
					if v.Name == limbName then
						waterPalm.Parent = workspace.Thrown
						waterPalm.CFrame = v.CFrame

						local weld = Instance.new("Weld", waterPalm)

						weld.Part0 = waterPalm
						weld.Part1 = v
					end
				end
			end

			for i, v in next, waterPalm:GetDescendants() do
				if v:IsA("ParticleEmitter") then
					v.Enabled = true
				end

				if v:IsA("Trail") then
					v.Enabled = true
				end
			end

			task.delay(lifeTime, function()
				for i, v in next, waterPalm:GetDescendants() do
					if v:IsA("ParticleEmitter") then
						v.Enabled = false
					end

					if v:IsA("Trail") then
						BoatTween:Create(v, {
							Time = 0.55,
							EasingStyle = "EntranceExpressive",
							EasingDirection = "In",

							Reverses = false,
							DelayTime = 0,
							RepeatCount = 0,

							StepType = "Renderstepped",

							Goal = {
								Transparency = NumberSequence.new(1, 1),
							},
						}):Play()
					end
				end

				Debris:AddItem(waterPalm, 0.65)
			end)
		end
	end,
}

shared.clearVelocities = function(Part: Part, Ignore: BodyVelocity?)
	for _, Velocity in Part:GetDescendants() do
		if
			Velocity ~= Ignore
			and (
				Velocity:IsA("BodyVelocity")
				or Velocity:IsA("LinearVelocity")
				or Velocity:IsA("BodyPosition")
				or Velocity:IsA("BodyGyro")
				or Velocity:IsA("BodyAngularVelocity")
				or Velocity:IsA("BodyMover")
				or Velocity:IsA("BodyForce")
				or Velocity:IsA("BodyThrust")
				or Velocity:IsA("AngularVelocity")
				or Velocity:IsA("VelocityMotor")
			)
		then
			Velocity:Destroy()
		end
	end
end
if ClientTasksLoadTime > 0 then
	print("CLIENT TASKS LOADED IN: ", ClientTasksLoadTime)
end

return ReplicationEffects
