local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local FadeOut = require(ReplicatedStorage.Shared.Modules.Utility.FadeOut)

local UndawnAssets = ReplicatedStorage.Resources.CharacterAssets.Eclipse.Solar.Undawn

local activeIndicators = {}

local Handlers = {}

function Handlers.Indicator(params)
	local char = params.char
	local beamPos = params.beamPos
	if not char or not beamPos then
		return
	end

	if not activeIndicators[char] then
		activeIndicators[char] = {}
	end

	local indicator = UndawnAssets.UndawnIndicator:Clone()
	indicator.Parent = workspace
	indicator.CFrame = CFrame.new(beamPos.X, beamPos.Y, beamPos.Z)

	table.insert(activeIndicators[char], indicator)
end

function Handlers.IndicatorRemove(params)
	local char = params.char
	if not char then
		return
	end

	local list = activeIndicators[char]
	if not list then
		return
	end

	for _, indicator in list do
		if not indicator or not indicator.Parent then
			continue
		end
		for _, desc in indicator:GetDescendants() do
			if desc:IsA("ParticleEmitter") or desc:IsA("Beam") then
				desc.Enabled = false
			end
		end
		task.delay(3, function()
			if indicator and indicator.Parent then
				indicator:Destroy()
			end
		end)
	end

	activeIndicators[char] = nil
end

function Handlers.Arms(params)
	local char = params.char
	if not char then
		return
	end

	local rightArm = char:FindFirstChild("Right Arm")
	local leftArm = char:FindFirstChild("Left Arm")
	if not rightArm or not leftArm then
		return
	end

	for _, emitter in UndawnAssets.SolarArm:GetChildren() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local rClone = emitter:Clone()
		rClone:SetAttribute("UndawnArm", true)
		rClone.Parent = rightArm

		local lClone = emitter:Clone()
		lClone:SetAttribute("UndawnArm", true)
		lClone.Parent = leftArm
	end
end

function Handlers.ArmsRemove(params)
	local char = params.char
	if not char then
		return
	end

	for _, limbName in { "Right Arm", "Left Arm" } do
		local limb = char:FindFirstChild(limbName)
		if not limb then
			continue
		end
		for _, child in limb:GetChildren() do
			if child:IsA("ParticleEmitter") and child:GetAttribute("UndawnArm") then
				FadeOut.OutAndDestroy(child, 0.5)
			end
		end
	end
end

function Handlers.Beam(params)
	local char = params.char
	local beamPositions = params.beamPositions
	if not char or not beamPositions or #beamPositions == 0 then
		return
	end

	for _, beamPos in beamPositions do
		local beamModel = UndawnAssets.UndawnBeam:Clone()
		local originCF = CFrame.new(beamPos.X, beamPos.Y, beamPos.Z)
		beamModel:PivotTo(originCF)
		beamModel.Parent = workspace

		local spinParts = {}
		local headPart = beamModel:FindFirstChild("Head", true)

		for _, part in beamModel:GetDescendants() do
			if part:IsA("BasePart") and part.Name == "SpinPart" then
				part.Size = Vector3.new(1, part.Size.Y, part.Size.Z)
				table.insert(spinParts, part)
			end
		end

		local fixedX = beamPos.X
		local fixedZ = beamPos.Z
		local fixedBaseY = beamPos.Y

		local headCurrentY = fixedBaseY + 3
		local headTargetY = fixedBaseY + 25
		local tweenDuration = 0.3
		local elapsed = 0

		local headAngle = 0

		for _, part in spinParts do
			TweenService:Create(
				part,
				TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Size = Vector3.new(60, part.Size.Y, part.Size.Z) }
			):Play()
		end

		local originalRotation

		if headPart then
			originalRotation = headPart.CFrame - headPart.Position
			headPart.Position = Vector3.new(fixedX, headCurrentY, fixedZ)
		end

		local spinConn
		spinConn = RunService.Heartbeat:Connect(function(dt)
			if not beamModel or not beamModel.Parent then
				spinConn:Disconnect()
				return
			end

			beamModel:PivotTo(beamModel:GetPivot() * CFrame.Angles(0, math.rad(360) * dt, 0))

			elapsed = math.min(elapsed + dt, tweenDuration)
			local t = elapsed / tweenDuration

			t = 1 - (1 - t) * (1 - t)
			headCurrentY = (fixedBaseY + 3) + ((headTargetY - (fixedBaseY + 3)) * t)

			headAngle = headAngle + math.rad(360) * dt

			if headPart and headPart.Parent then
				headPart.Position = Vector3.new(fixedX, headCurrentY, fixedZ)
			end
		end)

		task.delay(2, function()
			spinConn:Disconnect()
			FadeOut.OutAndDestroy(beamModel, 0.5)
		end)
	end
end

return function(params)
	local handler = Handlers[params.func]
	if handler then
		handler(params)
	end
end
