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
local TS = game:GetService("TweenService")

local Resources = RS:WaitForChild("Resources")

local LocalPlayer = game:GetService("Players").LocalPlayer

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

	Ring = function(Params)
		local Ring = Resources.Misc.Ring:Clone()
		Ring.Parent = workspace.Thrown
		Ring.CFrame = Params.CF

		for Prop, Value in Params.FirstProps do
			if Ring[Prop] then
				Ring[Prop] = Value
			end
		end

		local easeStyle = Enum.EasingStyle[Params.TN_Info.Style] :: any
		local easeDirection = Enum.EasingDirection[Params.TN_Info.Direction] :: any
		TS:Create(Ring, TweenInfo.new(Params.TN_Info.Time, easeStyle, easeDirection), Params.FinalProps):Play()
		Debris:AddItem(Ring, Params.LF or Params.TN_Info.Time)
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
