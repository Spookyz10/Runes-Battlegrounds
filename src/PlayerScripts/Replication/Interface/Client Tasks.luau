local ReplicationEffects = {}

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

if ClientTasksLoadTime > 0 then
	print("CLIENT TASKS LOADED IN: ", ClientTasksLoadTime)
end

return ReplicationEffects
