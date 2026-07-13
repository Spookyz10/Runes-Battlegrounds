local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VoxBreaker = require(ReplicatedStorage.Shared.Modules.VoxBreaker)
local DebrisDamage = require(script.DebrisDamage)

local ReplicateSet = ReplicatedStorage.Remotes.Replicate.Set

local DestructionService = {}

local DEBUG = true

local INSTAKILL_SIZE = 100
local DEBRIS_COLLISION_GROUP = "NonPColDebri"
local DEFAULT_TRACK_DURATION = 5
local DEFAULT_TRACK_HITBOX_SIZE = Vector3.new(6, 6, 6)

local FORCE_TIERS = {
	{ MinForce = 0, Radius = 6, VoxelSize = 1.5 },
	{ MinForce = 30, Radius = 14, VoxelSize = 3 },
	{ MinForce = 70, Radius = 30, VoxelSize = 6 },
	{ MinForce = 110, Radius = 50, VoxelSize = 10 },
}

local function dprint(...)
	if DEBUG then
		print("[DestructionService]", ...)
	end
end

local function getTier(Force)
	local chosen = FORCE_TIERS[1]
	for _, tier in FORCE_TIERS do
		if Force >= tier.MinForce then
			chosen = tier
		end
	end
	return chosen
end

local function applySplat(chunk)
	local originalSize = chunk.Size
	local squashed = Vector3.new(originalSize.X * 1.25, originalSize.Y * 0.55, originalSize.Z * 1.25)

	chunk.Size = squashed

	local tweenOk = pcall(function()
		TweenService
			:Create(
				chunk,
				TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ Size = originalSize }
			)
			:Play()
	end)
	if not tweenOk then
		chunk.Size = originalSize
	end
end

function DestructionService:_LaunchChunk(chunk, ImpactPosition, Force, OwnerPlayer)
	if not chunk or not chunk.Parent then
		dprint("_LaunchChunk abortado: chunk nil ou sem Parent")
		return
	end

	applySplat(chunk)

	chunk.Anchored = false
	chunk.CanCollide = true
	chunk.CanTouch = true
	chunk.CanQuery = true

	local groupOk, groupErr = pcall(function()
		chunk.CollisionGroup = DEBRIS_COLLISION_GROUP
	end)
	if not groupOk then
		dprint("AVISO: falha ao setar CollisionGroup", DEBRIS_COLLISION_GROUP, "-", groupErr)
	end

	local away = chunk.Position - ImpactPosition
	local dist = away.Magnitude
	local direction = dist > 0.01 and away.Unit or Vector3.new(0, 1, 0)

	local mass = chunk:GetMass()
	local launchSpeed = math.clamp(Force * 3.2 / math.sqrt(math.max(mass, 1)), 2, 45)

	chunk.AssemblyLinearVelocity = direction * launchSpeed * 0.35 + Vector3.new(0, launchSpeed * 0.55, 0)
	chunk.AssemblyAngularVelocity =
		Vector3.new(math.random(-200, 200) / 100, math.random(-200, 200) / 100, math.random(-200, 200) / 100)

	if chunk.Size.Magnitude >= INSTAKILL_SIZE then
		chunk:SetAttribute("InstaKill", true)
	end

	DebrisDamage:Track(chunk, OwnerPlayer)

	local lifetime = math.clamp(chunk.Size.Magnitude * 0.5, 6, 25)
	Debris:AddItem(chunk, lifetime)

	dprint("Chunk lançado - Size:", chunk.Size, "- Mass:", mass, "- Speed:", launchSpeed, "- Lifetime:", lifetime)
end

function DestructionService:ApplyImpact(Position, Force, OwnerPlayer)
	dprint(
		"ApplyImpact chamado - Position:",
		Position,
		"Force:",
		Force,
		"Owner:",
		OwnerPlayer and OwnerPlayer.Name or "nil"
	)

	local tier = getTier(Force)
	dprint("Tier selecionado - Radius:", tier.Radius, "VoxelSize:", tier.VoxelSize, "MinForce:", tier.MinForce)

	local hitboxSize = Vector3.one * tier.Radius * 2

	local ok, voxels = pcall(function()
		return VoxBreaker:CreateHitbox(hitboxSize, CFrame.new(Position), Enum.PartType.Ball, tier.VoxelSize, -1)
	end)

	if not ok then
		warn("[DestructionService] VoxBreaker falhou:", voxels)
		return
	end

	if not voxels then
		dprint("VoxBreaker retornou nil")
		return
	end

	dprint("VoxBreaker retornou", #voxels, "voxels")

	if #voxels == 0 then
		dprint(
			"NENHUM voxel encontrado. Possíveis causas: nenhuma part com atributo Destroyable=true dentro do raio ("
				.. tier.Radius
				.. " studs), ou parts não estão Anchored, ou hitbox não alcançou o alvo."
		)
		return
	end

	for i, chunk in voxels do
		dprint("Processando chunk", i, "-", chunk and chunk.Name or "nil")
		self:_LaunchChunk(chunk, Position, Force, OwnerPlayer)
	end

	ReplicateSet:FireAllClients("DebrisSmoke", { Position = Position, Size = hitboxSize })

	ReplicateSet:FireAllClients("Ground Crater", {
		Seed = math.random(1, 2147483647),
		amount = math.clamp(Force, 20, 90),
		start = Position + Vector3.new(0, 4, 0),
		["end"] = Vector3.new(0, -tier.Radius, 0),
		rings = Force > 70 and 3 or 2,
		ringSpacing = tier.Radius * 0.7,
		ringSizeGrowth = 1.5,
		ringGap = 0.2,
		outwardTilt = true,
		debrisSizeMin = tier.VoxelSize,
		debrisSizeMax = tier.VoxelSize * 2.5,
		debrisHeightMin = 4,
		debrisHeightMax = 9,
		sizemult = math.clamp(Force / 50, 0.5, 3),
	})

	dprint("ApplyImpact concluído")
end

-- Hitbox ativa (via Heartbeat + GetPartBoundsInBox) que segue o personagem
-- durante o voo. Independente de física/Touched, então funciona mesmo com
-- BodyVelocity ou o personagem se movendo rápido demais pra gerar Touched.
-- HitboxSize é por-skill: Prowl usa (6,6,6), skills maiores podem passar algo
-- maior (ex: (12,12,12) pra socos mais fortes).
function DestructionService:TrackCharacterImpacts(Character, Force, OwnerPlayer, Duration, HitboxSize)
	local HumRP = Character and Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		dprint("TrackCharacterImpacts abortado: sem HumanoidRootPart")
		return function() end
	end

	HitboxSize = HitboxSize or DEFAULT_TRACK_HITBOX_SIZE

	dprint(
		"TrackCharacterImpacts iniciado para",
		Character.Name,
		"- Force:",
		Force,
		"- Duration:",
		Duration or DEFAULT_TRACK_DURATION,
		"- HitboxSize:",
		HitboxSize
	)

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = { Character }

	local active = true
	local hitParts = {}

	local conn
	conn = RunService.Heartbeat:Connect(function()
		if not active then
			return
		end
		if not HumRP or not HumRP.Parent then
			return
		end

		local touching = workspace:GetPartBoundsInBox(HumRP.CFrame, HitboxSize, overlapParams)

		for _, part in touching do
			if hitParts[part] then
				continue
			end
			if not part:GetAttribute("Destroyable") then
				continue
			end

			hitParts[part] = true
			dprint(Character.Name, "hitbox de destruição tocou parte destrutível:", part:GetFullName())

			self:ApplyImpact(HumRP.Position, Force, OwnerPlayer)
		end
	end)

	local stopped = false
	local function stop()
		if stopped then
			return
		end
		stopped = true
		active = false
		if conn then
			conn:Disconnect()
			conn = nil
		end
		dprint("TrackCharacterImpacts encerrado para", Character.Name)
	end

	task.delay(Duration or DEFAULT_TRACK_DURATION, stop)

	return stop
end

return DestructionService
