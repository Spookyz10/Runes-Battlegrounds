local Constants = require(script.Parent.Shared.Constants)
local Helpers = require(script.Parent.Shared.Helpers)
local DebrisSpawner = require(script.Parent.Shared.DebrisSpawner)

local Debris = Constants.Debris
local RS = Constants.RS
local ParticlesModule = Constants.ParticlesModule

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

	if config.Sound then
		config.Sound.CFrame = CFrame.new(hitPosition)
		shared.sfx(config.Sound):Play()
	end

	if not hitPart then
		return
	end

	local surfaceAlignment =
		Helpers.calculateCFrameBetweenVectors(CFrame.new(hitPosition).UpVector, hitNormal, Vector3.new(0, 1, 0))

	local attachment = Instance.new("Attachment")
	attachment.Parent = hitPart.Anchored and hitPart or workspace.Terrain
	attachment.WorldCFrame = CFrame.new(hitPosition) * surfaceAlignment

	if not config.nosmoke then
		local smokeCount = 8

		local zJitter = rng:NextNumber(-0.001, 0.001)

		local smoke = RS.Resources.Effects.Smoke:Clone()
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

		local upSmoke = RS.Resources.Effects.UpSmoke:Clone()
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
		})
	end
end
