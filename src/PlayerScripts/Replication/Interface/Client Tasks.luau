type particlesModule = {
	GetHLF: (Part: Part?) -> number,
	Emit: (Part: Part?) -> (),
	Enabled: (Part: Part?, State: boolean) -> (),
	EnableTrail: (Part: Part?, State: boolean) -> (),
	scaleLifetime: (Part: Part?, newScale: number) -> (),
	tweenScale: (Model: Model, Parameters: { startScale: number?, goalScale: number, Info: TweenInfo }) -> (),
	resizeParticle: (Particles: { any }, GoalSize: number) -> (),
}

local RandomSeed = Random.new()

local ClientTasks = tick()

local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")

local Resources = RS:WaitForChild("Resources")

local LocalPlayer = game:GetService("Players").LocalPlayer
local RS_Modules = RS.Shared:WaitForChild("Modules")

local Utility = require(RS_Modules:WaitForChild("Utility"))
local ParticlesModule: particlesModule = Utility("Particles")

local CamShakePresets = require(RS_Modules.CamShakePresets)

local BoatTween = require(RS_Modules.BoatTween)
local VoxBreaker = require(RS_Modules.VoxBreaker)

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

local DestroyedParts = {}
shared.DestroyedParts = DestroyedParts

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

	DashHit = function(Params)
		for i = 1, RandomSeed:NextInteger(2, 6) do
			local Shard = Instance.new("Part")
			Shard.Anchored = true
			Shard.CanCollide = false
			Shard.Material = Enum.Material.Neon
			Shard.Color = Color3.new(1, 1, 1)
			Shard.CanTouch = false
			Shard.Size = Vector3.new(0.15000000596046448, 0.15000000596046448, 3)
			Shard.CanQuery = false
			Shard.Transparency = 0.6

			local Mesh = Instance.new("SpecialMesh")
			Mesh.MeshType = "Sphere"
			Mesh.Parent = Shard

			Shard.CFrame = CFrame.lookAlong(
				(Params.RootPart.CFrame * CFrame.new(RandomSeed:NextNumber(-1, 1), RandomSeed:NextNumber(-1, 1), 0)).Position,
				-Params.LookVector
			)
			Shard.Parent = workspace.Thrown

			local ZSize = RandomSeed:NextNumber(10, 20)
			local TweenTime = RandomSeed:NextNumber(0.1, 0.15)
			local Lifetime = RandomSeed:NextNumber(0.2, 0.4)

			TS:Create(Shard, TweenInfo.new(TweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = Vector3.new(0.15, 0.15, ZSize - 2),
				CFrame = Shard.CFrame * CFrame.new(0, 0, ZSize / 2),
			}):Play()

			task.delay(TweenTime, function()
				TS:Create(Shard, TweenInfo.new(Lifetime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = Vector3.new(0, 0, 0),
					CFrame = Shard.CFrame * CFrame.new(0, 0, ZSize / 2),
				}):Play()
			end)

			Debris:AddItem(Shard, Lifetime + TweenTime)
		end
	end,

	smokeEffect = function(Params)
		if Params.char then
			local Character = Params and Params.char

			local start = time()

			task.spawn(function()
				while time() - start < Params.time do
					local params = RaycastParams.new()
					params.FilterType = Enum.RaycastFilterType.Include
					params.FilterDescendantsInstances = { workspace.Map }

					local BodySmokez = Resources.Effects.DashSmoke:Clone()
					BodySmokez.Parent = workspace.Thrown
					BodySmokez.Smoke.Enabled = true

					task.delay(0.07, function()
						if BodySmokez.Parent then
							BodySmokez.Smoke.Enabled = false
						end
					end)

					Debris:AddItem(BodySmokez, 5)

					local raycast = workspace:Raycast(Character.PrimaryPart.Position, Vector3.new(0, -5, 0), params)

					if raycast then
						BodySmokez.CFrame = Character.PrimaryPart.CFrame
						BodySmokez.Position = raycast.Position + Vector3.new(0, 0.1, 0)
						BodySmokez.Smoke.Color = ColorSequence.new(raycast.Instance.Color)
					end

					task.wait(0.1)
				end
			end)
		end
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

	destroyAmbient = function(Params)
		local CF: CFrame = Params.CFrame
		if typeof(CF) == "Instance" then
			CF = CF.CFrame * (Params.Offset or CFrame.new(0, 0, 0))
		end

		local Size = Params.Size

		local Velocity = Params.Velocity
		local LookAt = Params.LookAt
		local Multiplier = Params.Multiplier

		local function Destroy(Part, WaitTime)
			table.insert(DestroyedParts, Part)

			local RealVelocity = Velocity
			if LookAt then
				local LookVector = -CFrame.lookAt(Part.Position, LookAt).LookVector
				RealVelocity = Vector3.new(LookVector.X * Velocity.X, Velocity.Y, LookVector.Z * Velocity.Z)
			end

			local Clone = Part:Clone()
			if
				Part:IsDescendantOf(workspace.Map.Destroyables.Buildings)
				and Clone.CanCollide == true
				and math.random(1, 2) == 1
			then
				Clone.CanCollide = true
			else
				Clone.CanCollide = false
			end
			CollectionService:RemoveTag(Clone, "WindShake")
			Clone.CanTouch = false
			Clone.CanQuery = false
			Clone.CollisionGroup = "NonPColDebri"
			Clone.Parent = workspace.Thrown
			Clone.Anchored = false
			Clone.AssemblyAngularVelocity = Vector3.new(math.random(-5, 5), math.random(-5, 5), math.random(-5, 5))
			Debris:AddItem(Clone, 5)

			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			BodyVelocity.Velocity = RealVelocity
			BodyVelocity.Parent = Clone
			Debris:AddItem(BodyVelocity, 0.1)

			task.delay(2.5, function()
				TS:Create(Clone, TweenInfo.new(2.5), { Size = Vector3.zero }):Play()
			end)

			Part.Transparency = 1
			Part.CanCollide = false
			Part.CanQuery = false

			task.delay(WaitTime or math.random(10, 18), function()
				TS:Create(Part, TweenInfo.new(1), { Transparency = 0 }):Play()
				if Part.Name ~= "Leaves" then
					Part.CanCollide = true
				end
				Part.CanQuery = true

				task.delay(1, function()
					local Index = table.find(DestroyedParts, Part)
					if Index then
						table.remove(DestroyedParts, Index)
					end
				end)
			end)
		end

		if Params.Voxels == true and LocalPlayer.Configuration["Destruction Physics"].Value == true then
			local DestroyableOverlapParams = OverlapParams.new()
			DestroyableOverlapParams.FilterType = Enum.RaycastFilterType.Include
			DestroyableOverlapParams.FilterDescendantsInstances = { workspace.Map.Destroyables }

			local PartsInBounds = VoxBreaker:CreateHitbox(Size, CF, Enum.PartType.Block, 2.5, 10)

			if #PartsInBounds > 0 then
				local GlassSoundCFrame, RockSoundCFrame, WoodSoundCFrame

				for _, Part: Part in PartsInBounds do
					if typeof(GlassSoundCFrame) ~= "CFrame" and Part.Material == Enum.Material.Glass then
						GlassSoundCFrame = Part.CFrame
					end
					if
						typeof(RockSoundCFrame) ~= "CFrame"
						and (Part.Material == Enum.Material.Slate or Part.Material == Enum.Material.DiamondPlate)
					then
						RockSoundCFrame = Part.CFrame
					end
					if
						typeof(WoodSoundCFrame) ~= "CFrame"
						and (Part.Material == Enum.Material.Wood or Part.Material == Enum.Material.WoodPlanks)
					then
						WoodSoundCFrame = Part.CFrame
					end

					Part.Anchored = false
					Part.CollisionGroup = "NonPColDebri"
					Part.CanQuery = false

					local GoalVelocity = Velocity
					if typeof(Multiplier) == "table" then
						GoalVelocity *= math.random(Multiplier[1], Multiplier[2])
					elseif typeof(Multiplier) == "number" then
						GoalVelocity *= Multiplier
					end

					Part.AssemblyLinearVelocity = GoalVelocity
					Part.AssemblyAngularVelocity = Vector3.new(
						math.random(Multiplier[1], Multiplier[2]),
						math.random(Multiplier[1], Multiplier[2]),
						math.random(Multiplier[1], Multiplier[2])
					)
				end
			end

			return
		end

		local PartsInBounds = Params.Parts or workspace:GetPartBoundsInBox(CF, Size, MapOverlapParams)
		if #PartsInBounds > 0 then
			for _, Part: Part in PartsInBounds do
				if Part and Part.Parent then
					if
						Part:IsDescendantOf(workspace.Map.Destroyables)
						and (not Params.CategoryOnly or Part:FindFirstAncestor(Params.CategoryOnly))
						and not table.find(DestroyedParts, Part)
					then
						if Part.Parent.Name == "Tree" then
							local WaitTime = math.random(10, 18)

							for _, TreePart in Part.Parent:GetChildren() do
								local Index = table.find(PartsInBounds, TreePart)
								if Index then
									table.remove(PartsInBounds, Index)
								end

								Destroy(TreePart, WaitTime)
							end
						else
							Destroy(Part)
						end
					end
				end
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
