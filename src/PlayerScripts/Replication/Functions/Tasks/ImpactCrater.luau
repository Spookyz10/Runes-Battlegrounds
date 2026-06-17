local Constants = require(script.Parent.Shared.Constants)
local Helpers = require(script.Parent.Shared.Helpers)
local DebrisSpawner = require(script.Parent.Shared.DebrisSpawner)

local Debris = Constants.Debris
local TS = Constants.TS

return function(Params)
	local rng = Random.new(Params.Seed or tick())

	local function rr(a, b)
		return Helpers.getRandomValue(a, b, nil, rng)
	end

	local origin: Vector3
	if typeof(Params.Position) == "Instance" then
		local inst = Params.Position :: Instance
		if inst:IsA("Attachment") then
			origin = (inst :: Attachment).WorldPosition
		elseif inst:IsA("BasePart") then
			origin = (inst :: BasePart).Position
		else
			return
		end
	else
		origin = (Params.Position :: Vector3) or Vector3.zero
	end

	local hitPart, hitPos = Helpers.performRaycast({
		orig = origin,
		dir = Vector3.new(0, -(Params.RayLength or 14), 0),
	})

	if not hitPart then
		return
	end

	local size = Params.Size or 1
	local ringCount = Params.Rings or 6
	local spreadPerRing = Params.CrackSpread or 17
	local isSand = hitPart.Material == Enum.Material.Sand or hitPart.Material == Enum.Material.Snow

	for ring = 1, ringCount do
		local radius = (3 + ring * spreadPerRing) * size
		local pieceCount = 10 + ring
		local ringDelay = (ring - 1) * 0.05

		task.delay(ringDelay, function()
			for i = 1, pieceCount do
				local crack = DebrisSpawner.cleanupThrownObjects() or Instance.new("Part")

				local angle = (2 * math.pi / pieceCount) * i + rr(-0.12, 0.12)
				local jitteredRadius = radius + rr(-2, 2) * size
				local offsetX = math.sin(angle) * jitteredRadius
				local offsetZ = math.cos(angle) * jitteredRadius

				local groundHit, groundPos = Helpers.performRaycast({
					orig = hitPos + Vector3.new(offsetX, 10, offsetZ),
					dir = Vector3.new(0, -25, 0),
				})

				if not groundHit then
					crack:Destroy()
					continue
				end

				local crackLength = rr(4, 9) * (0.6 + ring * 0.4) * size
				local crackWidth = rr(2, 5) * (0.5 + ring * 0.22) * size
				local crackHeight = rr(0.4, 1.2) * size

				crack.Size = Vector3.new(crackWidth, crackHeight, crackLength)

				local outwardDir = Vector3.new(offsetX, 0, offsetZ).Unit
				local tiltAngle = rr(8, 20)

				local rotCF = CFrame.lookAt(Vector3.zero, outwardDir)
					* CFrame.Angles(math.rad(-tiltAngle), rr(-0.18, 0.18), 0)

				local finalCF = CFrame.new(groundPos + Vector3.new(0, crackHeight * 0.2, 0)) * rotCF
				local startCF = CFrame.new(
					groundPos - Vector3.new(0, crackHeight * 0.8, 0) - outwardDir * crackLength * 0.35
				) * rotCF

				crack.Color = groundHit.Color
				crack.Material = groundHit.Material
				crack.Name = "ImpactCrack"
				crack.Anchored = true
				crack.CanCollide = false
				crack.CanTouch = false
				crack.CanQuery = false
				crack.Transparency = groundHit.Transparency
				crack.CFrame = startCF
				crack.Parent = workspace.Thrown
				crack.AssemblyLinearVelocity = Vector3.zero
				crack.AssemblyAngularVelocity = Vector3.zero

				if crack.Transparency >= 1 then
					crack.CanCollide = false
					crack.CanTouch = false
					crack.CanQuery = false
				end

				task.spawn(function()
					task.wait(0.02)

					if not crack.Anchored then
						return
					end

					if isSand then
						local bv = Instance.new("BodyVelocity")
						bv.MaxForce = Vector3.new(2e9, 2e9, 2e9)
						bv.Velocity = outwardDir * rr(6, 14) + Vector3.new(0, rr(15, 30), 0)
						bv.Parent = crack
						crack.Anchored = false
						Debris:AddItem(bv, 0.15)
						TS:Create(crack, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
							CFrame = finalCF,
						}):Play()
					else
						local tweenTime = rr(0.15, 0.28)
						TS:Create(crack, TweenInfo.new(tweenTime, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							CFrame = finalCF,
							Size = crack.Size,
						}):Play()

						task.delay(tweenTime + 0.05, function()
							if crack and crack.Parent and crack.Transparency < 1 then
								crack.CanCollide = true
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
		end)
	end
end
