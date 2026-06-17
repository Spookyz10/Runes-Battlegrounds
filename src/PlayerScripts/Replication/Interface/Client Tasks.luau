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

local Debris = game:GetService("Debris")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local DayTime = Lighting.TimeOfDay

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

local DestroyedParts = {}
shared.DestroyedParts = DestroyedParts

local dataTable = {}
local startTime = tick()
local EclipseNightTime = 0

local R6Parts = {
	"Head",
	"Torso",
	"Left Arm",
	"Right Arm",
	"Left Leg",
	"Right Leg",
}

local CharacterAssets = Resources:WaitForChild("CharacterAssets")

local function calculateCFrameBetweenVectors(vectorA, vectorB, axis)
	local dotProduct = vectorA:Dot(vectorB)
	local crossProduct = vectorA:Cross(vectorB)

	if dotProduct < -0.99999 then
		return CFrame.fromAxisAngle(axis, math.pi)
	else
		return CFrame.new(0, 0, 0, crossProduct.x, crossProduct.y, crossProduct.z, 1 + dotProduct)
	end
end

local function getTouchingPartsExceptIgnored(object)
	if not object then
		return
	elseif object.ClassName == "Model" then
		return
	else
		local touchConnection = object.Touched:Connect(function() end)

		local touchingParts = object:GetTouchingParts()
		touchConnection:Disconnect()

		local validParts = {}
		for _, part in pairs(touchingParts) do
			if part.Name ~= "InvisibleBorder" and part.Name ~= "InfBall" then
				table.insert(validParts, part)
			end
		end

		return validParts
	end
end

local DefaultFilter = { workspace.Live, workspace.Thrown }

local function performRaycast(rayData)
	local orig = rayData.orig
	local dir = rayData.dir
	local raycastParams = RaycastParams.new()

	raycastParams.FilterDescendantsInstances = rayData.Whitelist or rayData.Ignore or DefaultFilter
	if rayData.Whitelist then
		raycastParams.FilterType = Enum.RaycastFilterType.Include
	else
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	end

	if rayData.Blockcast then
		local result = workspace:Blockcast(orig, rayData.Blockcast, dir, raycastParams)
		if result then
			return result.Instance, result.Position, result.Material, result.Normal
		else
			return
		end
	else
		local result = workspace:Raycast(orig, dir, raycastParams)
		if result then
			return result.Instance, result.Position, result.Material, result.Normal
		else
			return
		end
	end
end

local function getRandomValue(min, max, isInteger, randomGenerator)
	local generator = randomGenerator or RandomSeed

	if not max and min then
		max = min
		min = 1
	end

	if not max and not min then
		min = 0
		max = 1
	end

	if not isInteger then
		return generator:NextNumber(min, max)
	else
		return generator:NextInteger(min, max)
	end
end

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

local function cleanupThrownObjects()
	if tick() - startTime > 300 then
		startTime = tick()
		local destroyedCount = 0

		for _, object in pairs(workspace.Thrown:GetChildren()) do
			if
				object:IsA("Part")
				and object:GetAttribute("Spawn")
				and not table.find(dataTable, object)
				and not object:GetAttribute("DeletionImmunity")
				and tick() - object:GetAttribute("Spawn") > 60
			then
				object:Destroy()
				destroyedCount = destroyedCount + 1
			end
		end

		return
	else
		local firstEntry = rawget(dataTable, 1)

		if #dataTable > 100 then
			for _ = 101, #dataTable do
				local excessEntry = rawget(dataTable, 101)
				table.remove(dataTable, 101)

				if excessEntry then
					excessEntry:Destroy()
				end
			end
		end

		if firstEntry and not firstEntry.Parent then
			table.remove(dataTable, 1)
		end

		if firstEntry and firstEntry.Parent then
			table.remove(dataTable, 1)

			if firstEntry.Name == "starterdeb" then
				firstEntry.Name = "aa"
			end

			firstEntry.CollisionGroup = "NonPColDebri"
			firstEntry:SetAttribute("Spawn", tick())

			return firstEntry
		else
			return
		end
	end
end

local function debrisSpawner(config)
	if not config.add then
		config.add = {}
	end

	local sizeMult = config.sizemult or 1
	local addConfig = config.add
	local rng = Random.new(config.Seed or tick())

	local function randomRange(min, max)
		return getRandomValue(min, max, nil, rng)
	end

	if config.amount then
		config.amount = math.floor(config.amount)
	end

	local lessDivisor = addConfig.less and 2.5 or 1

	local largeDebrisCount = rng:NextNumber(3, 5)
	if config.nodebris then
		largeDebrisCount = 0
	end

	for _ = 1, largeDebrisCount do
		if addConfig.less then
			break
		end

		local chunkSize = rng:NextNumber(1, 3)
		local chunk = cleanupThrownObjects() or Instance.new("Part")
		chunk.CollisionGroup = "NonPColDebri"

		chunk.CFrame = config.cframe
			* CFrame.Angles(
				math.rad(rng:NextNumber(-360, 360)),
				math.rad(rng:NextNumber(-360, 360)),
				math.rad(rng:NextNumber(-360, 360))
			)

		chunk.Size = Vector3.new(chunkSize, chunkSize, chunkSize)
		chunk.Color = config.ground.Color
		chunk.CanCollide = true
		chunk.Anchored = false
		chunk.Material = config.ground.Material
		chunk.Transparency = config.ground.Transparency
		chunk:SetAttribute("CanGoThroughCamera", true)
		chunk.Parent = workspace.Thrown

		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(2e9, 2e9, 2e9)
		bv.Velocity = Vector3.new(rng:NextNumber(-25, 25), rng:NextNumber(5, 25), randomRange(-25, 25)) * 2
		bv.Parent = chunk
		game:GetService("Debris"):AddItem(bv, 0.15)

		task.delay(3 + rng:NextNumber(0, 1), function()
			TS:Create(chunk, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = chunk.Size / 1.5,
			}):Play()

			task.delay(0.3, function()
				chunk.Anchored = true
				chunk.CanCollide = false
				chunk.CFrame = CFrame.new(1e8, 1e8, 1e8)
				table.insert(dataTable, chunk)
			end)
		end)
	end

	local smallDebrisCount = rng:NextNumber(4, 7) / lessDivisor
	if config.nodebris then
		smallDebrisCount = 0
	end

	for _ = 1, smallDebrisCount do
		local smallSize = rng:NextNumber(0.6, 0.8)
		local piece = cleanupThrownObjects() or Instance.new("Part")
		piece.CFrame = config.cframe

		local alignCFrame = calculateCFrameBetweenVectors(piece.CFrame.UpVector, config.normal, Vector3.new(0, 1, 0))
		piece.CFrame = piece.CFrame * (alignCFrame * CFrame.Angles(math.pi / 2, 0, 0))

		piece.CollisionGroup = "NonPColDebri"
		piece.Size = Vector3.new(smallSize, smallSize, smallSize)
		piece.Color = config.ground.Color
		piece.CanCollide = true
		piece.Name = "SmallDebris"
		piece.Anchored = false
		piece.Material = config.ground.Material
		piece.Transparency = config.ground.Transparency
		piece:SetAttribute("CanGoThroughCamera", true)
		piece.Parent = workspace.Thrown

		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(2e9, 2e9, 2e9)
		bv.Velocity = Vector3.new(rng:NextNumber(-25, 25), rng:NextNumber(5, 25), randomRange(-25, 25)) * 2
		bv.Parent = piece
		game:GetService("Debris"):AddItem(bv, 0.15)

		local bav = Instance.new("BodyAngularVelocity")
		bav.Parent = piece
		game:GetService("Debris"):AddItem(bav, 0.5)

		task.delay(3 + rng:NextNumber(0, 1), function()
			TS:Create(piece, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = piece.Size / 1.5,
			}):Play()

			task.delay(0.3, function()
				bav:Destroy()
				piece.Anchored = true
				piece.CanCollide = false
				piece.CFrame = CFrame.new(1e8, 1e8, 1e8)
				table.insert(dataTable, piece)
			end)
		end)
	end

	local spawnedPieces = {}
	local ringInner = 5
	local ringOuter = 7

	if config.new then
		ringInner = config.new[1]
		ringOuter = config.new[2]
	end

	local ringRadius = (ringInner + ringOuter) / 2
	local pieceCount = config.amount or 16

	local baseCFrame = CFrame.new(config.cframe.p)
	baseCFrame = baseCFrame * calculateCFrameBetweenVectors(baseCFrame.UpVector, config.normal, Vector3.new(0, 1, 0))
	baseCFrame = baseCFrame * CFrame.Angles(0, math.rad(rng:NextNumber(-360, 360)), 0)

	local offsetCFrame = baseCFrame * CFrame.Angles(0, math.rad(rng:NextNumber(-16, 16)), 0)

	if ringInner ~= 5 or ringOuter ~= 7 then
		config.Double = 2
	end

	for i = 1, pieceCount do
		for ring = 1, config.Double or 1 do
			local activeCFrame = (ring > 1) and offsetCFrame or baseCFrame
			local currentRadius = (ring > 1) and ringRadius + 1 or ringRadius

			local angle = (360 / pieceCount + 360 / pieceCount * i) / 57.296
			local offsetX = currentRadius * math.sin(angle)
			local offsetZ = currentRadius * math.cos(angle)

			local spread = config.Double and 0.35 or 0.2
			local pieceCFrame = activeCFrame * CFrame.new(offsetX, 0, offsetZ)
			pieceCFrame = pieceCFrame + pieceCFrame.LookVector * rng:NextNumber(-spread, spread)

			local slab = cleanupThrownObjects() or Instance.new("Part")
			slab.Anchored = true
			slab.CanCollide = false
			slab.CanTouch = true
			slab.Material = config.ground.Material
			slab.Color = config.ground.Color
			slab.CFrame = pieceCFrame * CFrame.fromEulerAnglesXYZ(0, angle, 0)

			local originalCFrame = slab.CFrame
			slab.CFrame = originalCFrame * CFrame.Angles(math.rad(-rng:NextNumber(6, 42)), 0, 0)

			local slabWidth = rng:NextNumber(2, 5) * (ring > 1 and 1.8 or config.Double and 1.35 or 1)
			slab.Size = Vector3.new(slabWidth, rng:NextNumber(1.9, 2.4), randomRange(2, 6)) * sizeMult

			slab.CFrame = slab.CFrame * CFrame.new(0, -(slab.Size.Y / 3 + slab.Size.Z / 3) / 3, 0)
			slab.Transparency = 1
			slab.Parent = workspace.Thrown

			local savedCFrame = slab.CFrame
			local touching = getTouchingPartsExceptIgnored(slab)
			local touchingParts = {}
			local differentMaterialPart = nil
			local touchingGround = nil
			local touchingTile = nil

			for _, part in pairs(touching) do
				if
					not part:IsDescendantOf(workspace.Live)
					and part.Name ~= "invis"
					and part.Parent ~= workspace.Thrown
				then
					if part.Material ~= config.ground.Material then
						differentMaterialPart = part
					end
					table.insert(touchingParts, part)
				end

				if part == config.ground then
					touchingGround = config.ground
				end
				if part.Name == "Tile" then
					touchingTile = true
				end
			end

			slab.CFrame = savedCFrame
				* (
					CFrame.new(0, -3, -1.5)
					* CFrame.Angles(
						math.rad(rng:NextNumber(-11, 11)),
						math.rad(rng:NextNumber(-11, 11)),
						math.rad(rng:NextNumber(-11, 11))
					)
				)
			slab.Transparency = 0
			table.insert(spawnedPieces, slab)

			local shouldHide = true
			if #touchingParts ~= 0 then
				shouldHide = config.ground:GetAttribute("Breakable") or not config.ground.Anchored
			end

			local inAngle = false
			if config.angle then
				local pos = originalCFrame.Position
				inAngle = math.deg(
					math.acos(
						config.anglecfr.LookVector:Dot(
							(Vector3.new(pos.X, config.anglecfr.p.Y, pos.Z) - config.anglecfr.p).unit
						)
					)
				) <= config.angle
			end

			if shouldHide or inAngle then
				slab.Transparency = 1
			else
				if
					differentMaterialPart
					and (not touchingGround or touchingGround.Name ~= "Tile")
					and (not touchingTile or config.ground.Name ~= "Tile")
				then
					slab.Color = differentMaterialPart.Color
					slab.Material = differentMaterialPart.Material
				end
				slab.Transparency = config.ground.Transparency
			end

			if slab.Transparency >= 1 then
				slab.CanCollide = false
				slab.CanTouch = false
				slab.CanQuery = false
			else
				slab.CanCollide = true
			end

			if slab.Velocity.Magnitude > 0 then
				slab.AssemblyLinearVelocity = Vector3.zero
				slab.AssemblyAngularVelocity = Vector3.zero
			end

			slab:SetAttribute("OGCframe", originalCFrame)

			TS:Create(slab, TweenInfo.new(rng:NextNumber(0.2, 0.3), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = originalCFrame,
			}):Play()

			local keepDuration = addConfig.keep
			if not keepDuration then
				keepDuration = rng:NextNumber(5, 7)
			end

			task.delay(keepDuration, function()
				if addConfig.keep then
					TS:Create(slab, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CFrame = originalCFrame,
						Size = slab.Size,
					}):Play()
					task.wait(2)
				end

				TS:Create(slab, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					CFrame = slab.CFrame * CFrame.new(0, -7, 0),
					Size = slab.Size / 1.5,
				}):Play()

				task.wait(2)
				slab:SetAttribute("OGCframe", nil)
				slab.Anchored = true
				slab.CFrame = CFrame.new(1e8, 1e8, 1e8)
				table.insert(dataTable, slab)
			end)
		end
	end

	return spawnedPieces
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

	LunarDash = function(Params)
		local char = Params.char
		local HumRP = char.PrimaryPart
		local DashSmoke = CharacterAssets.Eclipse.Lunar.DashSmoke:Clone()
		local Circle = CharacterAssets.Eclipse.Lunar.Circle:Clone()

		DashSmoke.Parent = char
		Circle.Parent = char

		DashSmoke.CFrame = HumRP.CFrame + Vector3.new(0, -2, -4)
		Circle.CFrame = HumRP.CFrame + Vector3.new(0, -3, 0)

		ParticlesModule.Emit(DashSmoke)
		ParticlesModule.Emit(Circle)

		Debris:AddItem(DashSmoke, 1)
		Debris:AddItem(Circle, 1)
	end,

	createLungeVelocity = function(Params)
		local Character = LocalPlayer.Character
		if not Character then
			return
		end
		local HumRP = Character:FindFirstChild("HumanoidRootPart")
		if not HumRP then
			return
		end

		local speed = Params.Speed or 60
		local duration = Params.DashDuration or 5

		local bv = Instance.new("BodyVelocity")
		bv.Name = "LungeVelocity"
		bv.MaxForce = Vector3.new(math.huge, 0, math.huge)
		bv.Velocity = HumRP.CFrame.LookVector * speed
		bv.P = math.huge
		bv.Parent = HumRP

		local slowdownStart = duration * 0.3
		local startTime = tick()
		local slowingDown = false
		local slowStartTime = nil

		local conn
		conn = game:GetService("RunService").Heartbeat:Connect(function(dt)
			if not (bv and bv.Parent) then
				conn:Disconnect()
				return
			end

			local elapsed = tick() - startTime

			if elapsed >= slowdownStart and not slowingDown then
				slowingDown = true
				slowStartTime = tick()
			end

			if slowingDown then
				local slowElapsed = tick() - slowStartTime
				local slowDuration = duration - slowdownStart
				local t = math.clamp(slowElapsed / slowDuration, 0, 1)

				local easedT = 1 - (1 - t) ^ 2
				speed = (Params.Speed or 60) * (1 - easedT)

				if speed <= 0.5 then
					bv:Destroy()
					conn:Disconnect()
					shared._lungeConn = nil
					return
				end
			end

			bv.Velocity = HumRP.CFrame.LookVector * speed
		end)

		shared._lungeConn = conn
	end,

	deleteLungeVelocity = function(_Params)
		if shared._lungeConn then
			shared._lungeConn:Disconnect()
			shared._lungeConn = nil
		end

		local Character = LocalPlayer.Character
		if not Character then
			return
		end
		local HumRP = Character:FindFirstChild("HumanoidRootPart")
		if not HumRP then
			return
		end

		local bv = HumRP:FindFirstChild("LungeVelocity")
		if bv then
			bv:Destroy()
		end
	end,

	["Ground Crater"] = function(config)
		if typeof(config.start) == "Instance" then
			if config.start:IsA("Attachment") then
				config.start = config.start.WorldPosition
			elseif config.start:IsA("BasePart") then
				config.start = config.start.Position
			end
		elseif typeof(config.start) == "Vector3" then
		else
			config.start = config.start.Position
		end

		local rng = Random.new(config.Seed)

		local hitPart, hitPosition, _, hitNormal = performRaycast({
			orig = config.start,
			dir = config["end"],
		})

		if config.Sound then
			config.Sound.CFrame = CFrame.new(hitPosition)
			shared.sfx(config.Sound):Play()
		end

		if not hitPart then
			return
		end

		local surfaceAlignment =
			calculateCFrameBetweenVectors(CFrame.new(hitPosition).UpVector, hitNormal, Vector3.new(0, 1, 0))

		local attachment = Instance.new("Attachment")
		attachment.Parent = hitPart.Anchored and hitPart or workspace.Terrain
		attachment.WorldCFrame = CFrame.new(hitPosition) * surfaceAlignment

		if not config.nosmoke then
			local smokeCount = 8

			local zJitter = rng:NextNumber(-0.001, 0.001)

			local smoke = game.ReplicatedStorage.Resources.Effects.Smoke:Clone()
			smoke.Parent = attachment
			smoke.ZOffset = smoke.ZOffset + zJitter
			smoke.Color = ColorSequence.new(hitPart.Color)

			if config.stronger then
				shared.resizeparticle(smoke, config.stronger.size1 or 4.2)
				local speedMult = 4.5 - (config.stronger.minus or 0)
				smoke.Speed = NumberRange.new(smoke.Speed.Min * speedMult, smoke.Speed.Max * speedMult)
				smoke.Lifetime = NumberRange.new(smoke.Lifetime.Min * 2, smoke.Lifetime.Max * 2)
				smoke.RotSpeed = NumberRange.new(smoke.RotSpeed.Min * 0.35, smoke.RotSpeed.Max * 0.35)
			else
				shared.resizeparticle(smoke, 1.25)
				if config.CloserCircle then
					smoke.Speed = NumberRange.new(25, 50)
					shared.resizeparticle(smoke, 0.7)
					smokeCount = smokeCount / 1.5
				end
				if config.Closerr then
					shared.resizeparticle(smoke, 0.55)
					smoke.Speed = NumberRange.new(7, 25)
				end
			end

			if not config.NoCircleSmoke then
				smoke:Emit(smokeCount)
			end

			local upSmokeCount = 8

			local upSmoke = game.ReplicatedStorage.Resources.Effects.UpSmoke:Clone()
			upSmoke.Parent = attachment
			upSmoke.ZOffset = upSmoke.ZOffset + zJitter
			upSmoke.Color = ColorSequence.new(hitPart.Color)

			if config.stronger then
				shared.resizeparticle(upSmoke, config.stronger.size2 or 4.2)
				local speedMult = 4.5 - (config.stronger.minus or 0)
				upSmoke.Speed = config.speed1
					or NumberRange.new(upSmoke.Speed.Min * speedMult, upSmoke.Speed.Max * speedMult)
				upSmoke.Lifetime = NumberRange.new(upSmoke.Lifetime.Min * 2, upSmoke.Lifetime.Max * 2)
				upSmoke.RotSpeed = NumberRange.new(upSmoke.RotSpeed.Min * 0.35, upSmoke.RotSpeed.Max * 0.35)
			else
				shared.resizeparticle(upSmoke, 1.25)
				if config.Closerr then
					shared.resizeparticle(upSmoke, 0.3)
					upSmokeCount = upSmokeCount / 1.5
					upSmoke.Speed = NumberRange.new(20, 35)
				end
			end

			shared.resizeparticle(upSmoke, 1.25)

			if not config.NoUpSmoke then
				upSmoke:Emit(upSmokeCount)
			end
		end

		game:GetService("Debris"):AddItem(attachment, 9)

		local isSoftGround = hitPart.Material == Enum.Material.Sand or hitPart.Material == Enum.Material.Snow

		if not config.NoCrater2 then
			local baseAmount = config.amount or (isSoftGround and 7 or 10)

			debrisSpawner({
				ground = hitPart,
				cframe = CFrame.new(hitPosition),
				amount = baseAmount / 1.25,
				normal = hitNormal,
				sand = isSoftGround or nil,
				add = { sounds = true },
				sizemult = config.sizemult,
				new = {
					5 * (config.size or 1),
					5.5 * (config.size or 1),
				},
				nosound = config.nosound,
				angle = config.angle,
				anglecfr = config.anglecfr,
				nodebris = config.nodebris,
				notiles = config.notiles,
				Seed = config.Seed,
			})
		end
	end,

	EclipseCharge = function(Params)
		local Character = Params.Char
		if not Character or not Character.Parent then
			return
		end

		local LunarEffects = CharacterAssets.Eclipse.Lunar

		local RightArm = Character:FindFirstChild("Right Arm")
		local LeftArm = Character:FindFirstChild("Left Arm")

		if RightArm then
			local SunClone = LunarEffects.EclipseSun:Clone()
			SunClone.Name = "EclipseSun_FX"
			SunClone.Parent = RightArm
			SunClone.WorldCFrame = RightArm.CFrame * CFrame.new(0, -1, 0)
		end

		if LeftArm then
			local MoonClone = LunarEffects.EclipseMoon:Clone()
			MoonClone.Name = "EclipseMoon_FX"
			MoonClone.Parent = LeftArm
			MoonClone.WorldCFrame = LeftArm.CFrame * CFrame.new(0, -1, 0)
		end
	end,

	EclipseChargeDestroy = function(Params)
		local Character = Params.Char
		if not Character or not Character.Parent then
			return
		end

		local RightArm = Character:FindFirstChild("Right Arm")
		local LeftArm = Character:FindFirstChild("Left Arm")

		if RightArm then
			local Sun = RightArm:FindFirstChild("EclipseSun_FX")
			if Sun then
				Sun:Destroy()
			end
		end

		if LeftArm then
			local Moon = LeftArm:FindFirstChild("EclipseMoon_FX")
			if Moon then
				Moon:Destroy()
			end
		end
	end,

	MoonCuttersHit = function(Params)
		local Index = Params.Index
		local Char = Params.Char
		if not Char or not Char.Parent then
			return
		end

		local HumRP = Char:FindFirstChild("HumanoidRootPart")
		if not HumRP then
			return
		end

		local SlashAsset = CharacterAssets.Eclipse.Lunar:FindFirstChild("Slash" .. Index)
		if not SlashAsset then
			return
		end

		local SlashClone = SlashAsset:Clone()
		SlashClone.CFrame = HumRP.CFrame * CFrame.new(0, 0, -4.5)
		SlashClone.Anchored = true
		SlashClone.Parent = workspace.Thrown

		ParticlesModule.Emit(SlashClone)
		Debris:AddItem(SlashClone, 3)
	end,
	MoonCuttersFinalStart = function(Params)
		local Char = Params.Char
		if not Char or not Char.Parent then
			return
		end

		local RightArm = Char:FindFirstChild("Right Arm")
		if not RightArm then
			return
		end

		local FinalImpact = CharacterAssets.Eclipse.Lunar:FindFirstChild("FinalImpact")
		if not FinalImpact then
			return
		end

		local FIClone = FinalImpact:Clone()
		FIClone.Name = "FinalImpact"
		FIClone.Anchored = false
		FIClone.CFrame = RightArm.CFrame * CFrame.Angles(math.rad(170.702), math.rad(-180), math.rad(-172.399))
		FIClone.Parent = RightArm

		local Weld = Instance.new("WeldConstraint")
		Weld.Part0 = RightArm
		Weld.Part1 = FIClone
		Weld.Parent = FIClone
	end,

	MoonCuttersFinalEnd = function(Params)
		local Char = Params.Char
		if not Char or not Char.Parent then
			return
		end

		local RightArm = Char:FindFirstChild("Right Arm")
		if not RightArm then
			return
		end

		local FinalImpact = RightArm:FindFirstChild("FinalImpact")
		if not FinalImpact then
			return
		end

		local VFX = FinalImpact:FindFirstChild("VFX")
		if VFX then
			local Impact = VFX:FindFirstChild("Impact")
			local Impact2 = VFX:FindFirstChild("Impact2")

			if Impact then
				ParticlesModule.Emit(Impact)
			end
			if Impact2 then
				ParticlesModule.Emit(Impact2)
			end
		end

		Debris:AddItem(FinalImpact, 0.3)
	end,

	EclipseHit = function(Params)
		local EnemyCharacter = Params.EChar
		if not EnemyCharacter or not EnemyCharacter.Parent then
			return
		end

		local Head = EnemyCharacter:FindFirstChild("Head")
		if not Head then
			return
		end

		local EclipseClone = CharacterAssets.Eclipse.Lunar.Eclipse:Clone()
		EclipseClone.Name = "Eclipse_FX"
		EclipseClone.Parent = Head

		ParticlesModule.Emit(EclipseClone)

		Debris:AddItem(EclipseClone, 3)
	end,

	StartEclipseAwakening = function(Params)
		EclipseNightTime = 10

		local Fog = CharacterAssets.Eclipse:FindFirstChild(Params.FogName):Clone()
		Fog.Parent = workspace
		Fog:PivotTo(Params.Character.PrimaryPart.CFrame + Vector3.new(0, -3, 0))

		Debris:AddItem(Fog, 15)
	end,

	GivePlayerAura = function(Params)
		local Character = Params.Char
		if not Character or not Character.Parent then
			return
		end

		for _, Child in Character:GetDescendants() do
			if Child.Name == "AwakeningAura" then
				Child:Destroy()
			end
		end

		local Aura = Resources.Auras:FindFirstChild(Params.AuraName)

		for _, Effect in Aura:GetChildren() do
			if R6Parts[Effect.Name] then
				local Part = Character:FindFirstChild(Effect.Name)
				if Part then
					local EffectClone = Effect:Clone()
					EffectClone.Parent = Part
					if EffectClone:IsA("Attachment") then
						EffectClone.WorldCFrame = Part.CFrame * EffectClone.CFrame
					end
					EffectClone.Name = "AwakeningAura"
				end
			elseif Effect.Name == "All" then
				for _, Part in Character:GetChildren() do
					if R6Parts[Part.Name] then
						local EffectClone = Effect:Clone()
						EffectClone.Parent = Part
						if EffectClone:IsA("Attachment") then
							EffectClone.WorldCFrame = Part.CFrame * EffectClone.CFrame
						end
						EffectClone.Name = "AwakeningAura"
					end
				end
			end
		end
	end,

	StartLunarAimControl = function(Params)
		if shared._lunarAimConn then
			shared._lunarAimConn:Disconnect()
			shared._lunarAimConn = nil
		end

		local LocalChar = LocalPlayer.Character
		local LocalHumRP = LocalChar and LocalChar:FindFirstChild("HumanoidRootPart")
		local LocalHumanoid = LocalChar and LocalChar:FindFirstChild("Humanoid")
		if not LocalHumRP or not LocalHumanoid then
			return
		end

		LocalHumanoid.AutoRotate = false
		shared._lunarAimDirection = workspace.CurrentCamera.CFrame.LookVector

		local duration = Params.Duration or 5
		local startTime = tick()

		shared._lunarAimConn = RunService.RenderStepped:Connect(function()
			if not LocalHumRP or not LocalHumRP.Parent then
				if shared._lunarAimConn then
					shared._lunarAimConn:Disconnect()
					shared._lunarAimConn = nil
				end
				LocalHumanoid.AutoRotate = true
				return
			end

			if tick() - startTime >= duration then
				if shared._lunarAimConn then
					shared._lunarAimConn:Disconnect()
					shared._lunarAimConn = nil
				end
				LocalHumanoid.AutoRotate = true
				return
			end

			local lookDir = workspace.CurrentCamera.CFrame.LookVector
			shared._lunarAimDirection = lookDir

			-- Rotaciona o personagem inteiro pra direção da câmera (full 3D com pitch)
			-- Só aplica posição atual pra não travar o BodyPosition do servidor
			LocalHumRP.CFrame = CFrame.new(LocalHumRP.Position, LocalHumRP.Position + lookDir)
		end)
	end,

	StopLunarAimControl = function(Params)
		if shared._lunarAimConn then
			shared._lunarAimConn:Disconnect()
			shared._lunarAimConn = nil
		end

		local LocalChar = LocalPlayer.Character
		local LocalHumanoid = LocalChar and LocalChar:FindFirstChild("Humanoid")
		if LocalHumanoid then
			LocalHumanoid.AutoRotate = true
		end
	end,
}

RunService.RenderStepped:Connect(function()
	if EclipseNightTime > 0 then
		DayTime = "00:00:00"
	else
		DayTime = "12:00:00"
	end
end)

while true do
	task.wait(1)
	if EclipseNightTime > 0 then
		EclipseNightTime -= 1
	end
end

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

return ReplicationEffects
