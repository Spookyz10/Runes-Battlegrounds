local Constants = require(script.Parent.Constants)
local Helpers = require(script.Parent.Helpers)

local Debris = Constants.Debris
local TS = Constants.TS

local dataTable = {}
local startTime = tick()

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
		return Helpers.getRandomValue(min, max, nil, rng)
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
		Debris:AddItem(bv, 0.15)

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
		piece.Parent = workspace.Thrown

		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(2e9, 2e9, 2e9)
		bv.Velocity = Vector3.new(rng:NextNumber(-25, 25), rng:NextNumber(5, 25), randomRange(-25, 25)) * 2
		bv.Parent = piece
		Debris:AddItem(bv, 0.15)

		local bav = Instance.new("BodyAngularVelocity")
		bav.Parent = piece
		Debris:AddItem(bav, 0.5)

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

	local basePieceCount = config.amount or 24

	local baseCFrame = CFrame.new(config.cframe.p)
	baseCFrame = baseCFrame
		* Helpers.calculateCFrameBetweenVectors(baseCFrame.UpVector, config.normal, Vector3.new(0, 1, 0))
	baseCFrame = baseCFrame * CFrame.Angles(0, math.rad(rng:NextNumber(-360, 360)), 0)

	local keepTilt = config.tiltMin ~= nil and config.tiltMax ~= nil

	for ringIndex = 1, ringCount do
		local ringRadius = baseRingRadius + ringSpacing * (ringIndex - 1)
		local ringRadiusScale = ringRadius / baseRingRadius
		local ringSizeScale = ringSizeGrowth ^ (ringIndex - 1)

		local pieceCount = math.max(4, math.floor((basePieceCount / ringCount) * ringRadiusScale))

		local ringRotationOffset = math.rad(rng:NextNumber(-360, 360))
		local ringCFrame = baseCFrame * CFrame.Angles(0, ringRotationOffset, 0)

		for i = 1, pieceCount do
			local angle = (i / pieceCount) * (math.pi * 2) + rng:NextNumber(-0.12, 0.12)

			local radiusJitter = ringRadius * rng:NextNumber(1 - ringGap, 1 + ringGap)
			local offsetX = radiusJitter * math.sin(angle)
			local offsetZ = radiusJitter * math.cos(angle)

			local pieceCFrame = ringCFrame * CFrame.new(offsetX, 0, offsetZ)
			pieceCFrame = pieceCFrame * CFrame.Angles(0, angle, 0)
			pieceCFrame = pieceCFrame + pieceCFrame.LookVector * rng:NextNumber(-0.4, 0.4) * ringRadiusScale

			local slab = cleanupThrownObjects() or Instance.new("Part")
			slab.Anchored = true
			slab.CanCollide = false
			slab.CanTouch = true
			slab.Material = config.ground.Material
			slab.Color = config.ground.Color

			local widthScale = ringSizeScale
			local slabWidth = rng:NextNumber(debrisSizeMin, debrisSizeMax) * widthScale * sizeMult
			local slabHeight = rng:NextNumber(debrisHeightMin, debrisHeightMax)
				* (1 + (ringSizeScale - 1) * 0.35)
				* sizeMult
			local slabDepth = randomRange(debrisSizeMin, debrisSizeMax) * widthScale * sizeMult
			slab.Size = Vector3.new(slabWidth, slabHeight, slabDepth)

			slab.CFrame = pieceCFrame

			local randomYaw = math.rad(rng:NextNumber(-25, 25))
			local outwardPitch = 0
			if outwardTilt then
				outwardPitch = math.rad(rng:NextNumber(8, 38) * (0.6 + 0.4 * ringRadiusScale))
			end
			local randomPitch = math.rad(rng:NextNumber(-14, 14))
			local randomRoll = math.rad(rng:NextNumber(-22, 22))

			slab.CFrame = slab.CFrame * CFrame.Angles(-outwardPitch + randomPitch, randomYaw, randomRoll)

			local originalCFrame = slab.CFrame

			slab.CFrame = slab.CFrame * CFrame.new(0, -(slab.Size.Y / 3 + slab.Size.Z / 3) / 3, 0)
			slab.Transparency = 1
			slab.Parent = workspace.Thrown

			local savedCFrame = slab.CFrame
			local touching = Helpers.getTouchingPartsExceptIgnored(slab)
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
					CFrame.new(0, -3 * (0.7 + 0.3 * ringSizeScale), -1.5)
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

			TS
				:Create(
					slab,
					TweenInfo.new(rng:NextNumber(0.22, 0.38), Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						CFrame = restCFrame,
					}
				)
				:Play()

			local keepDuration = addConfig.keep
			if not keepDuration then
				keepDuration = rng:NextNumber(5, 7)
			end

			task.delay(keepDuration, function()
				if addConfig.keep then
					TS:Create(slab, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						CFrame = restCFrame,
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

return {
	dataTable = dataTable,
	cleanupThrownObjects = cleanupThrownObjects,
	debrisSpawner = debrisSpawner,
}
