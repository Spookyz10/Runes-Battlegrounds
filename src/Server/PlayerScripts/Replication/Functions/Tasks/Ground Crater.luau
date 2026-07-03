local Constants = require(script.Parent.Shared.Constants)
local Helpers = require(script.Parent.Shared.Helpers)
local DebrisSpawner = require(script.Parent.Shared.DebrisSpawner)

local Debris = Constants.Debris

return function(config)
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

	local hitPart, hitPosition, _, hitNormal = Helpers.performRaycast({
		orig = config.start,
		dir = config["end"],
	})

	if not hitPart then
		return
	end

	local TopDownParams = RaycastParams.new()
	TopDownParams.FilterType = Enum.RaycastFilterType.Exclude
	TopDownParams.FilterDescendantsInstances = { workspace.Live, workspace.Debris }
	TopDownParams.IgnoreWater = true

	local TopDownResult = workspace:Raycast(hitPosition + Vector3.new(0, 6, 0), Vector3.new(0, -12, 0), TopDownParams)

	if TopDownResult and TopDownResult.Position.Y >= hitPosition.Y - 0.05 then
		hitPart = TopDownResult.Instance
		hitPosition = TopDownResult.Position
		hitNormal = TopDownResult.Normal
	end

	local surfaceAlignment =
		Helpers.calculateCFrameBetweenVectors(CFrame.new(hitPosition).UpVector, hitNormal, Vector3.new(0, 1, 0))

	local attachment = Instance.new("Attachment")
	attachment.Parent = hitPart.Anchored and hitPart or workspace.Terrain
	attachment.WorldCFrame = CFrame.new(hitPosition) * surfaceAlignment

	Debris:AddItem(attachment, 9)

	local isSoftGround = hitPart.Material == Enum.Material.Sand or hitPart.Material == Enum.Material.Snow

	if not config.NoCrater2 then
		local baseAmount = config.amount or (isSoftGround and 7 or 10)

		DebrisSpawner.debrisSpawner({
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
			tiltMin = config.tiltMin,
			tiltMax = config.tiltMax,
			rings = config.rings,
			ringSpacing = config.ringSpacing,
			ringSizeGrowth = config.ringSizeGrowth,
			ringGap = config.ringGap,
			outwardTilt = config.outwardTilt,
			debrisSizeMin = config.debrisSizeMin,
			debrisSizeMax = config.debrisSizeMax,
			debrisHeightMin = config.debrisHeightMin,
			debrisHeightMax = config.debrisHeightMax,
		})
	end
end
