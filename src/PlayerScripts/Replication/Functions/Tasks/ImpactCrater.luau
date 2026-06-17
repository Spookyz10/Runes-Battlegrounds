local Constants = require(script.Parent.Shared.Constants)
local Helpers = require(script.Parent.Shared.Helpers)
local DebrisSpawner = require(script.Parent.Shared.DebrisSpawner)

local Debris = Constants.Debris
local RS = Constants.RS
local TS = Constants.TS

return function(Params)
	local rng = Random.new(Params.Seed or tick())

	local function rr(a, b)
		return Helpers.getRandomValue(a, b, nil, rng)
	end

	local origin = Params.Position
	if typeof(origin) == "Instance" then
		origin = origin:IsA("Attachment") and origin.WorldPosition
	else
		origin = origin or Vector3.zero
	end

	local hitPart, hitPos, _, hitNormal = Helpers.performRaycast({
		orig = origin,
		dir = Vector3.new(0, -(Params.RayLength or 14), 0),
	})

	if not hitPart then
		return
	end

	local size = Params.Size or 1
	local ringCount = Params.Rings or 4
	local debrisEnabled = Params.Debris ~= false
	local cracksEnabled = Params.Cracks ~= false
	local smokeEnabled = Params.Smoke ~= false
	local flyRocksEnabled = Params.FlyRocks ~= false
	local flyRockCount = Params.FlyRockCount or rng:NextInteger(6, 12)

	local surfaceAlign = Helpers.calculateCFrameBetweenVectors(Vector3.new(0, 1, 0), hitNormal, Vector3.new(0, 0, 1))
	local baseCF = CFrame.new(hitPos) * surfaceAlign

	if smokeEnabled then
		local att = Instance.new("Attachment")
		att.Parent = hitPart.Anchored and hitPart or workspace.Terrain
		att.WorldCFrame = baseCF

		local smoke = RS.Resources.Effects.UpSmoke:Clone()
		smoke.Parent = att
		smoke.Color = ColorSequence.new(hitPart.Color)
		shared.resizeparticle(smoke, (Params.SmokeSize or 1) * size)
		smoke:Emit(math.floor(10 * size))

		local smokeFlat = RS.Resources.Effects.Smoke:Clone()
		smokeFlat.Parent = att
		smokeFlat.Color = ColorSequence.new(hitPart.Color)
		shared.resizeparticle(smokeFlat, (Params.SmokeSize or 1) * size * 0.8)
		smokeFlat:Emit(math.floor(8 * size))

		Debris:AddItem(att, 9)
	end

	if debrisEnabled then
		DebrisSpawner.debrisSpawner({
			ground = hitPart,
			cframe = baseCF,
			amount = math.floor((Params.DebrisAmount or 10) * size / 1.25),
			normal = hitNormal,
			sand = hitPart.Material == Enum.Material.Sand or hitPart.Material == Enum.Material.Snow or nil,
			sizemult = (Params.DebrisSizeMult or 1) * size,
			new = {
				5 * size,
				5.5 * size,
			},
			nodebris = not debrisEnabled,
			Seed = rng:NextInteger(1, 2e9),
		})
	end

	if flyRocksEnabled then
		local flyRocks = {}

		for i = 1, flyRockCount do
			local rock = DebrisSpawner.cleanupThrownObjects() or Instance.new("Part")
			local rockSize = rr(0.3, 1) * 2 * size

			if Params.RockSizeMult then
				rockSize = rockSize * Params.RockSizeMult
			end

			rock.Size = Vector3.one * rockSize
			rock.Color = hitPart.Color
			rock.Material = hitPart.Material
			rock.CollisionGroup = "NonPColDebri"
			rock:SetAttribute("CanGoThroughCamera", true)

			local angle = (360 / flyRockCount * i) / 57.296
			local spread = size * rr(1.5, 3)
			rock.CFrame = baseCF
				* CFrame.new(math.sin(angle) * spread, 0, math.cos(angle) * spread)
				* CFrame.Angles(rr(-math.pi, math.pi), rr(-math.pi, math.pi), rr(-math.pi, math.pi))

			local rayHit = Helpers.performRaycast({
				orig = rock.Position,
				dir = Vector3.new(0, -6, 0),
			})

			if not rayHit then
				rock:Destroy()
				continue
			end

			rock.Anchored = false
			rock.CanCollide = true
			rock.Parent = workspace.Thrown
			table.insert(flyRocks, rock)

			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(4e4, 4e4, 4e4)
			bv.Velocity = Vector3.new(
				rr(-5, 5),
				rr(
					Params.RockUpForce and Params.RockUpForce[1] or 8,
					Params.RockUpForce and Params.RockUpForce[2] or 28
				),
				rr(-5, 5)
			) * rr(2.5, 4)
			bv.Parent = rock
			Debris:AddItem(bv, 0.15)
		end

		task.delay(Params.RockLifetime or 6, function()
			for _, r in flyRocks do
				if r and r.Parent then
					r.CanCollide = false
				end
			end
			task.wait(2)
			for _, r in flyRocks do
				if r and r.Parent then
					r:Destroy()
				end
			end
		end)
	end

	if cracksEnabled then
		for ring = 1, ringCount do
			local innerR = 3 + ring * (Params.CrackSpread or 17) * size
			local outerR = innerR
			local pieceCount = 10 + ring
			local v14871 = {
				ground = hitPart,
				cframe = baseCF,
				normal = hitNormal,
				amount = pieceCount,
				sand = hitPart.Material == Enum.Material.Sand or hitPart.Material == Enum.Material.Snow,
			}

			for i = 1, pieceCount do
				local crack = DebrisSpawner.cleanupThrownObjects() or Instance.new("Part")
				crack.CFrame = v14871.cframe

				local alignCF =
					Helpers.calculateCFrameBetweenVectors(crack.CFrame.UpVector, v14871.normal, Vector3.new(0, 1, 0))
				crack.CFrame = crack.CFrame * (alignCF * CFrame.new(0, -0.9, 0))

				local targetCF = v14871.cframe * alignCF * CFrame.Angles(math.pi / 2, 0, 0)
				local pivotCF = CFrame.new(hitPos) * alignCF
				local slotCF = pivotCF * CFrame.Angles(0, math.rad(35 * i), 0) * CFrame.new(0, 1, rr(innerR, outerR))

				slotCF = slotCF * CFrame.Angles(math.rad(rr(-30, -15)), math.rad(rr(0, 1)), math.rad(rr(0, 1)))

				local dist = (slotCF.p - v14871.cframe.p).Magnitude

				crack.Name = "ImpactCrack"
				crack.Anchored = true
				crack.Color = hitPart.Color
				crack.Material = hitPart.Material
				crack.CanCollide = false

				local crackW = rr(2, 8) * (1 + ring * 0.5) * size
				local crackH = rr(1, 2)
				crack.Size = Vector3.new(crackW, crackH, rr(1, 3) * (1 + ring * 0.5) * size)

				local finalCF = CFrame.new(
					slotCF.p
						+ Vector3.new(rr(-10, 10) * size, 0, rr(-10, 10) * size)
						- Vector3.new(0, crack.Size.Y / 8, 0)
				) * CFrame.Angles(math.rad(rr(-30, -15)), math.rad(rr(0, 1)), math.rad(rr(0, 1)))

				crack.CFrame = finalCF
				crack.Transparency = 1
				crack.Parent = workspace.Thrown
				crack.AssemblyLinearVelocity = Vector3.zero
				crack.AssemblyAngularVelocity = Vector3.zero

				local touching = Helpers.getTouchingPartsExceptIgnored(crack)
				local validParts = {}
				local diffMat = nil
				local touchGround = nil

				for _, p in touching do
					if not p:IsDescendantOf(workspace.Live) and p.Parent ~= workspace.Thrown then
						if p.Material ~= hitPart.Material then
							diffMat = p
						end
						table.insert(validParts, p)
					end
					if p == hitPart then
						touchGround = hitPart
					end
				end

				if #validParts == 0 or not hitPart.Anchored then
					crack.Transparency = 1
				else
					if diffMat and not touchGround then
						crack.Color = diffMat.Color
						crack.Material = diffMat.Material
					end
					crack.Transparency = hitPart.Transparency
				end

				if crack.Transparency >= 1 then
					crack.CanCollide = false
					crack.CanTouch = false
					crack.CanQuery = false
				end

				local savedCF = crack.CFrame
				local popCF = CFrame.Angles(math.rad(rr(-1, 1)), math.rad(dist * i), math.rad(rr(-1, 1)))
					* CFrame.new(0, 1, rr(2, 4))
					* CFrame.Angles(math.rad(rr(-30, -15)), 0, 0)

				crack.CFrame = crack.CFrame * popCF

				task.spawn(function()
					crack.CFrame = finalCF - Vector3.new(0, crack.Size.Y / 2, 0)
					crack.CFrame = crack.CFrame
						* CFrame.Angles(math.rad(rr(-35, 35)), math.rad(rr(-35, 35)), math.rad(rr(-35, 35)))

					task.wait(0.03)

					if crack.Anchored then
						if v14871.sand then
							local bv = Instance.new("BodyVelocity")
							bv.MaxForce = Vector3.new(2e9, 2e9, 2e9)
							bv.Velocity = crack.CFrame.LookVector * -rr(22, 32) + Vector3.new(0, rr(35, 82), 0)
							bv.Parent = crack
							crack.Anchored = false
							Debris:AddItem(bv, 0.15)

							TS:Create(crack, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
								CFrame = finalCF,
							}):Play()
						else
							TS:Create(
								crack,
								TweenInfo.new(rr(0.2, 0.3), Enum.EasingStyle.Back, Enum.EasingDirection.Out),
								{
									CFrame = finalCF,
									Size = crack.Size,
								}
							):Play()
						end

						task.delay(0.2, function()
							crack.CanCollide = v14871.sand or true
							if crack.Transparency >= 1 then
								crack.CanCollide = false
								crack.CanTouch = false
								crack.CanQuery = false
							end
						end)
					end
				end)

				local keepTime = Params.CrackLifetime or rr(5, 7)
				task.delay(keepTime, function()
					if crack and crack.Parent then
						TS:Create(crack, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
							CFrame = crack.CFrame * CFrame.new(0, -7, 0),
							Size = crack.Size / 1.5,
						}):Play()

						task.wait(2)
						crack.Anchored = true
						crack.CFrame = CFrame.new(1e8, 1e8, 1e8)
						table.insert(DebrisSpawner.dataTable, crack)
					end
				end)
			end
		end
	end
end
