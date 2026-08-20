local Constants = require(script.Parent.Constants)
local Helpers = require(script.Parent.Helpers)

local TS = Constants.TS

local function isHitboxPart(part)
	return part.Name:find("Hitbox") ~= nil
end

local function debrisSpawner(config)
	if not config.add then
		config.add = {}
	end

	local sizeMult = config.sizemult or 1
	local addConfig = config.add
	local rng = Random.new(config.Seed or tick())

	local function randomRange(min, max)
		return Helpers.getRandomValue(min, max, nil, rng)
	end

	if config.amount then
		config.amount = math.floor(config.amount)
	end

	local lessDivisor = addConfig.less and 2.5 or 1

	local largeCountMin = config.largeDebrisCountMin or 3
	local largeCountMax = config.largeDebrisCountMax or 5
	local largeSizeMin = config.largeDebrisSizeMin or 1
	local largeSizeMax = config.largeDebrisSizeMax or 3
	local largeSpeedMin = config.largeDebrisSpeedMin or -25
	local largeSpeedMax = config.largeDebrisSpeedMax or 25
	local largeUpMin = config.largeDebrisUpMin or 5
	local largeUpMax = config.largeDebrisUpMax or 25
	local largeSpeedMult = config.largeDebrisSpeedMult or 2
	local largeLifetime = config.largeDebrisLifetime or 3
	local largeLifetimeRandom = config.largeDebrisLifetimeRandom or 1

	local smallCountMin = config.smallDebrisCountMin or 4
	local smallCountMax = config.smallDebrisCountMax or 7
	local smallSizeMin = config.smallDebrisSizeMin or 0.6
	local smallSizeMax = config.smallDebrisSizeMax or 0.8
	local smallSpeedMin = config.smallDebrisSpeedMin or -25
	local smallSpeedMax = config.smallDebrisSpeedMax or 25
	local smallUpMin = config.smallDebrisUpMin or 5
	local smallUpMax = config.smallDebrisUpMax or 25
	local smallSpeedMult = config.smallDebrisSpeedMult or 2
	local smallLifetime = config.smallDebrisLifetime or 3
	local smallLifetimeRandom = config.smallDebrisLifetimeRandom or 1

	local largeDebrisCount = rng:NextNumber(largeCountMin, largeCountMax)
	if config.nodebris then
		largeDebrisCount = 0
	end

	for _ = 1, largeDebrisCount do
		if addConfig.less then
			break
		end

		local chunkSize = rng:NextNumber(largeSizeMin, largeSizeMax)
		local chunk = Instance.new("Part")
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
		chunk.Parent = workspace.Debris

		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(2e9, 2e9, 2e9)
		bv.Velocity = Vector3.new(
			rng:NextNumber(largeSpeedMin, largeSpeedMax),
			rng:NextNumber(largeUpMin, largeUpMax),
			randomRange(largeSpeedMin, largeSpeedMax)
		) * largeSpeedMult
		bv.Parent = chunk
		game:GetService("Debris"):AddItem(bv, 0.15)

		task.delay(largeLifetime + rng:NextNumber(0, largeLifetimeRandom), function()
			if not chunk or not chunk.Parent then
				return
			end
			TS:Create(chunk, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = chunk.Size / 1.5,
			}):Play()

			task.delay(0.3, function()
				if chunk and chunk.Parent then
					chunk:Destroy()
				end
			end)
		end)
	end

	local smallDebrisCount = rng:NextNumber(smallCountMin, smallCountMax) / lessDivisor
	if config.nodebris then
		smallDebrisCount = 0
	end

	for _ = 1, smallDebrisCount do
		local smallSize = rng:NextNumber(smallSizeMin, smallSizeMax)
		local piece = Instance.new("Part")
		piece.CFrame = config.cframe

		local alignCFrame =
			Helpers.calculateCFrameBetweenVectors(piece.CFrame.UpVector, config.normal, Vector3.new(0, 1, 0))
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
		piece.Parent = workspace.Debris

		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(2e9, 2e9, 2e9)
		bv.Velocity = Vector3.new(
			rng:NextNumber(smallSpeedMin, smallSpeedMax),
			rng:NextNumber(smallUpMin, smallUpMax),
			randomRange(smallSpeedMin, smallSpeedMax)
		) * smallSpeedMult
		bv.Parent = piece
		game:GetService("Debris"):AddItem(bv, 0.15)

		local bav = Instance.new("BodyAngularVelocity")
		bav.Parent = piece
		game:GetService("Debris"):AddItem(bav, 0.5)

		task.delay(smallLifetime + rng:NextNumber(0, smallLifetimeRandom), function()
			if not piece or not piece.Parent then
				return
			end
			TS:Create(piece, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1,
				Size = piece.Size / 1.5,
			}):Play()

			task.delay(0.3, function()
				if bav and bav.Parent then
					bav:Destroy()
				end
				if piece and piece.Parent then
					piece:Destroy()
				end
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
	local baseRingRadius = (ringInner + ringOuter) / 2

	local ringCount = config.rings or 4
	local ringSpacing = config.ringSpacing or 6
	local ringSizeGrowth = config.ringSizeGrowth or 1.6
	local ringGap = config.ringGap or 0.18
	local outwardTilt = config.outwardTilt
	if outwardTilt == nil then
		outwardTilt = true
	end

	local debrisSizeMin = config.debrisSizeMin or 2
	local debrisSizeMax = config.debrisSizeMax or 5
	local debrisHeightMin = config.debrisHeightMin or 1.9
	local debrisHeightMax = config.debrisHeightMax or 3.2
	local maxDebrisHeight = config.maxDebrisHeight or math.huge

	local basePieceCount = config.amount or 24
	local squareTiles = config.tileMode == "Square"

	local baseCFrame = CFrame.new(config.cframe.p)
	baseCFrame = baseCFrame
		* Helpers.calculateCFrameBetweenVectors(baseCFrame.UpVector, config.normal, Vector3.new(0, 1, 0))
	baseCFrame = baseCFrame * CFrame.Angles(0, math.rad(rng:NextNumber(-360, 360)), 0)

	local keepTilt = config.tiltMin ~= nil and config.tiltMax ~= nil

	for ringIndex = 1, ringCount do
		local ringRadius = baseRingRadius + ringSpacing * ringIndex
		local ringRadiusScale = ringRadius / baseRingRadius
		local ringSizeScale = ringSizeGrowth ^ (ringIndex - 1)

		local pieceCount = math.max(3, math.floor((basePieceCount / ringCount) * ringRadiusScale * 0.6))

		local ringRotationOffset = math.rad(rng:NextNumber(-360, 360))
		local ringCFrame = baseCFrame * CFrame.Angles(0, ringRotationOffset, 0)

		local slotIndex = 1
		while slotIndex <= pieceCount do
			local mergeCount = 1
			if not squareTiles and rng:NextNumber() < 0.35 and slotIndex + 1 <= pieceCount then
				mergeCount = rng:NextInteger(2, math.min(3, pieceCount - slotIndex + 1))
			end

			local anglePerSlot = (math.pi * 2) / pieceCount
			local startAngle = ((slotIndex - 1) / pieceCount) * (math.pi * 2)
			local spanAngle = anglePerSlot * mergeCount
			local angle = startAngle + spanAngle / 2 + rng:NextNumber(-0.05, 0.05)

			local radiusJitter = ringRadius * rng:NextNumber(1 - ringGap, 1 + ringGap)
			local offsetX = radiusJitter * math.sin(angle)
			local offsetZ = radiusJitter * math.cos(angle)

			local pieceCFrame = ringCFrame * CFrame.new(offsetX, 0, offsetZ)
			pieceCFrame = pieceCFrame * CFrame.Angles(0, angle, 0)
			pieceCFrame = pieceCFrame + pieceCFrame.LookVector * rng:NextNumber(-0.4, 0.4) * ringRadiusScale

			local slab = Instance.new("Part")
			slab.Anchored = true
			slab.CanCollide = false
			slab.CanTouch = true
			slab.Material = config.ground.Material
			slab.Color = config.ground.Color

			local arcChordLength = 2 * ringRadius * math.sin(spanAngle / 2)
			local slabWidth = math.max(arcChordLength * rng:NextNumber(0.7, 0.95), debrisSizeMin) * sizeMult
			local slabHeight = rng:NextNumber(debrisHeightMin, debrisHeightMax)
				* (1 + (ringSizeScale - 1) * 0.35)
				* sizeMult
			slabHeight = math.min(slabHeight, maxDebrisHeight)
			local slabDepth = randomRange(debrisSizeMin, debrisSizeMax) * 0.55 * sizeMult
			if squareTiles then
				local tileSize = randomRange(debrisSizeMin, debrisSizeMax) * sizeMult
				slabWidth = tileSize
				slabDepth = tileSize
			end
			slab.Size = Vector3.new(slabWidth, slabHeight, slabDepth)

			slab.CFrame = pieceCFrame

			local randomYaw = math.rad(rng:NextNumber(-12, 12))
			local outwardPitch = 0
			if outwardTilt then
				local minTilt, maxTilt = 8, 34
				if rng:NextNumber() < 0.3 then
					minTilt, maxTilt = 42, 68
				end
				outwardPitch = math.rad(rng:NextNumber(minTilt, maxTilt) * (0.6 + 0.4 * ringRadiusScale))
			end
			local randomPitch = math.rad(rng:NextNumber(-10, 10))
			local rollRange = mergeCount > 1 and 8 or 20
			local randomRoll = math.rad(rng:NextNumber(-rollRange, rollRange))

			slab.CFrame = slab.CFrame * CFrame.Angles(-outwardPitch + randomPitch, randomYaw, randomRoll)

			local originalCFrame = slab.CFrame

			slotIndex += mergeCount

			slab.CFrame = slab.CFrame * CFrame.new(0, -(slab.Size.Y / 3 + slab.Size.Z / 3) / 3, 0)
			slab.Transparency = 1
			slab.Parent = workspace.Debris

			local touching = Helpers.getTouchingPartsExceptIgnored(slab)
			local touchingParts = {}
			local differentMaterialPart = nil
			local touchingGround = nil
			local touchingTile = nil

			for _, part in pairs(touching) do
				if
					not part:IsDescendantOf(workspace.Live)
					and part.Name ~= "invis"
					and part.Parent ~= workspace.Debris
					and not isHitboxPart(part)
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

			local restCFrame = originalCFrame
			if keepTilt then
				restCFrame = originalCFrame
					* CFrame.Angles(math.rad(-rng:NextNumber(config.tiltMin, config.tiltMax)), 0, 0)
			end

			local groundLevel = config.cframe.p.Y
			local halfSize = slab.Size / 2
			local corners = {
				Vector3.new(-halfSize.X, -halfSize.Y, -halfSize.Z),
				Vector3.new(halfSize.X, -halfSize.Y, -halfSize.Z),
				Vector3.new(-halfSize.X, -halfSize.Y, halfSize.Z),
				Vector3.new(halfSize.X, -halfSize.Y, halfSize.Z),
			}

			local lowestY = math.huge
			for _, corner in corners do
				local worldCorner = (restCFrame * CFrame.new(corner)).Position
				lowestY = math.min(lowestY, worldCorner.Y)
			end

			local missingDepth = (lowestY - groundLevel)
			if missingDepth > 0 then
				local stretchedSize = slab.Size + Vector3.new(0, missingDepth, 0)
				slab.Size = stretchedSize
				restCFrame = restCFrame * CFrame.new(0, -missingDepth / 2, 0)
			end

			slab:SetAttribute("OGCframe", restCFrame)

			local buriedDepth = slab.Size.Y + slab.Size.Z * 0.5 + 2
			local buriedCFrame = CFrame.new(restCFrame.Position + Vector3.new(0, -buriedDepth, 0)) * restCFrame.Rotation
			slab.CFrame = buriedCFrame

			local emergeDelay = rng:NextNumber(0, 0.12) + (ringIndex - 1) * 0.07
			local emergeTime = rng:NextNumber(0.28, 0.45)

			task.delay(emergeDelay, function()
				if not slab or not slab.Parent then
					return
				end
				TS:Create(
					slab,
					TweenInfo.new(emergeTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ CFrame = restCFrame }
				):Play()
			end)

			local keepDuration = addConfig.keep
			if not keepDuration then
				keepDuration = rng:NextNumber(5, 7)
			end

			local capturedRestCFrame = restCFrame
			local capturedSize = slab.Size

			task.delay(keepDuration, function()
				if not slab or not slab.Parent then
					return
				end

				if addConfig.keep then
					TS:Create(slab, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CFrame = capturedRestCFrame,
						Size = capturedSize,
					}):Play()
					task.wait(2)
				end

				if not slab or not slab.Parent then
					return
				end

				local currentPos = slab.CFrame.Position
				local sinkCFrame = CFrame.new(currentPos + Vector3.new(0, -7, 0)) * slab.CFrame.Rotation

				TS:Create(slab, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					CFrame = sinkCFrame,
					Size = capturedSize / 1.5,
				}):Play()

				task.wait(2)

				if slab and slab.Parent then
					slab:Destroy()
				end
			end)
		end
	end

	return spawnedPieces
end

return {
	debrisSpawner = debrisSpawner,
}
