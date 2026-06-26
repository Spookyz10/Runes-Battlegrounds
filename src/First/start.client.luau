--Services
local RunService = game["Run Service"]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

--Camera
local CurrentCamera = workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	CurrentCamera = workspace.CurrentCamera
end)

--Functions
shared.loop = function(Function, Rate, Yield)
	Rate = 1 / (Rate or 60)

	local pastTime = 0
	local deltaTime = 0
	local doLoop = true

	local function stopLoop()
		doLoop = false
	end

	local function loopFunction()
		while doLoop do
			pastTime += deltaTime

			while Rate <= pastTime do
				Function(stopLoop)

				pastTime -= Rate

				if not doLoop then
					break
				end
			end

			deltaTime = RunService.RenderStepped:Wait()
		end
	end

	if not Yield then
		task.spawn(loopFunction)
	else
		loopFunction()
	end

	return stopLoop
end

local rngSeed = Random.new()
shared.globalRNGSeed = rngSeed
shared.randomNumber = function(n1, n2, int, customSeed)
	local seed = customSeed or rngSeed

	if not n2 and n1 then
		n2 = n1
		n1 = 1
	end

	if not n2 and not n1 then
		n1 = 0
		n2 = 1
	end

	if not int then
		return seed:NextNumber(n1, n2)
	else
		return seed:NextInteger(n1, n2)
	end
end

shared.ray = function(params)
	local origin = params.orig
	local direction = params.dir

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = params.Whitelist
		or params.Ignore
		or {
			workspace.Live,
			workspace.Debris,
		}

	if params.Whitelist then
		rayParams.FilterType = Enum.RaycastFilterType.Include
	else
		rayParams.FilterType = Enum.RaycastFilterType.Exclude
	end

	if params.Blockcast then
		local blockcast = workspace:Blockcast(origin, params.Blockcast, direction, rayParams)
		if blockcast then
			return blockcast.Instance, blockcast.Position, blockcast.Material, blockcast.Normal
		else
			return
		end
	else
		local raycast = workspace:Raycast(origin, direction, rayParams)
		if raycast then
			return raycast.Instance, raycast.Position, raycast.Material, raycast.Normal
		else
			return
		end
	end
end

shared.resizeparticle = function(Parameters, Multiplier, Property)
	local realProperty = Property or "Size"

	if realProperty == "Speed" then
		Parameters.Speed = NumberRange.new(Parameters.Speed.Min * Multiplier, Parameters.Speed.Max * Multiplier)
	else
		for _, v in pairs({ Parameters }) do
			local newSequenceTable = {}

			for _, v2 in pairs(v[realProperty].Keypoints) do
				table.insert(newSequenceTable, NumberSequenceKeypoint.new(v2.Time, v2.Value * Multiplier, v2.Envelope))
			end

			v[realProperty] = NumberSequence.new(newSequenceTable)
		end
	end

	return
end

shared.resizemodel = function(model, scale)
	local meshes = {}
	local joints = {}
	local parts = {}

	for _, descendant in pairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			table.insert(parts, descendant)
		elseif descendant:IsA("JointInstance") then
			table.insert(joints, descendant)
		elseif descendant:IsA("DataModelMesh") then
			table.insert(meshes, descendant)
		end
	end

	local function waitForHeartbeat()
		return RunService.Heartbeat:Wait()
	end

	local config: { [string]: any } = {}

	local function getPartBounds(partList)
		local minX, minY, minZ = 1e999, 1e999, 1e999
		local maxX, maxY, maxZ = -1e999, -1e999, -1e999

		for _, part in pairs(partList) do
			local cframe = part.CFrame
			local size = part.Size

			local corners = {
				Vector3.new(1, 1, 1),
				Vector3.new(-1, 1, 1),
				Vector3.new(-1, -1, 1),
				Vector3.new(-1, -1, -1),
				Vector3.new(1, -1, 1),
				Vector3.new(1, -1, -1),
				Vector3.new(1, 1, -1),
				Vector3.new(-1, 1, -1),
			}

			for _, corner in pairs(corners) do
				local offset = Vector3.new(size.X / 2, size.Y / 2, size.Z / 2) * corner
				local worldPos = cframe * CFrame.new(offset)
				local pos = worldPos.Position

				minX = math.min(minX, pos.X)
				minY = math.min(minY, pos.Y)
				minZ = math.min(minZ, pos.Z)
				maxX = math.max(maxX, pos.X)
				maxY = math.max(maxY, pos.Y)
				maxZ = math.max(maxZ, pos.Z)
			end
		end

		return Vector3.new(minX, minY, minZ), Vector3.new(maxX, maxY, maxZ)
	end

	local function resize(partsList, jointsList, meshesList, scaleVector, minBound, maxBound)
		local lastWait = tick()
		if not minBound then
			minBound, maxBound = getPartBounds(partsList)
		end

		local center = (minBound + maxBound) / 2
		local savedJoints = {}

		for _, joint in pairs(jointsList) do
			if joint.Part0 and joint.Part1 then
				table.insert(savedJoints, {
					joint.ClassName,
					joint.Parent,
					joint.Name,
					joint.Part0,
					joint.Part1,
					joint.C0,
					joint.C1,
				})
			end
			joint:Destroy()

			if config.AntiFreeze and tick() - lastWait > 0.03 then
				waitForHeartbeat()
				lastWait = tick()
			end
		end

		local visitedParts = {}

		for _, part in pairs(partsList) do
			if not visitedParts[part] then
				visitedParts[part] = true
				local originalAnchored = part.Anchored
				part.Anchored = true

				local offset = part.Position - center
				local rotation = part.CFrame - part.Position
				local newSize = part.Size * scaleVector
				part.Size = newSize

				if part.Size ~= newSize then
					if part:IsA("FormFactorPart") then
						part.FormFactor = "Custom"
						part.Size = newSize
					end
					if part.Size ~= newSize then
						if config.MeshSmall then
							part.CanCollide = false
						end
						local mesh = part:FindFirstChildWhichIsA("SpecialMesh", true)
						if mesh and ((mesh:IsA("FileMesh") and mesh.MeshId == "") or not mesh:IsA("FileMesh")) then
							mesh.Scale = mesh.Scale * newSize / part.Size
						end
					end
				end

				part.CFrame = CFrame.new(offset * scaleVector + center) * rotation
				part.Anchored = originalAnchored

				if config.AntiFreeze and tick() - lastWait > 0.03 then
					waitForHeartbeat()
					lastWait = tick()
				end
			end
		end

		for _, jointData in pairs(savedJoints) do
			local className, parent, name, part0, part1, c0, c1 = unpack(jointData)
			local newJoint = Instance.new(className)
			newJoint.Name = name
			newJoint.Part0 = part0
			newJoint.Part1 = part1
			newJoint.C0 = CFrame.new(c0.Position * scaleVector) * (c0 - c0.Position)
			newJoint.C1 = CFrame.new(c1.Position * scaleVector) * (c1 - c1.Position)
			newJoint.Parent = parent

			if config.AntiFreeze and tick() - lastWait > 0.03 then
				waitForHeartbeat()
				lastWait = tick()
			end
		end

		for _, mesh in pairs(meshesList) do
			if mesh:IsA("FileMesh") and mesh.MeshId ~= "" and mesh.Parent:IsA("BasePart") then
				mesh.Scale = mesh.Scale * scaleVector
			end
		end
	end

	resize(parts, joints, meshes, Vector3.new(1, 1, 1) * scale)
end

shared.OnScreen = function(Position)
	local _, IsOnScreen = workspace.CurrentCamera:WorldToScreenPoint(Position)
	return IsOnScreen
end

shared.sfx = function(Parameters)
	local Sound = Instance.new("Sound")
	Sound.SoundGroup = SoundService.Sounds

	if Parameters.AddTo then
		table.insert(Parameters.AddTo, Sound)
		Parameters.AddTo = nil
	end

	local Attachment = nil
	local EndConnection = nil
	EndConnection = Sound.Ended:connect(function()
		if Sound then
			Sound:Destroy()
		end

		if Attachment then
			Attachment:Destroy()
		end

		return EndConnection:Disconnect()
	end)

	if not Parameters.RollOffMaxDistance then
		Parameters.RollOffMaxDistance = 300
	end

	if Parameters.CFrame then
		Attachment = Instance.new("Attachment")
		Attachment.Parent = workspace.Terrain
		Attachment.WorldCFrame = Parameters.CFrame
		Parameters.Parent = Attachment
	end

	Parameters.CFrame = nil

	for Index, Value in Parameters do
		Sound[Index] = Value
	end

	return Sound, Attachment
end

shared.NerfVfx = function(Params)
	local Character = Params.Char == game.Players.LocalPlayer.Character
	local Rate = Params.RateNerf or 1.5
	local EmitCount = Params.EmitCountNerf or 1.5
	local DiNerf = true

	local localScripts = Params.Script

	if localScripts:GetAttribute("RateNerf") then
		Rate = localScripts:GetAttribute("RateNerf")
	end

	if localScripts:GetAttribute("EmitCountNerf") then
		EmitCount = localScripts:GetAttribute("EmitCountNerf")
	end

	if localScripts:GetAttribute("DidNerf") then
		localScripts:SetAttribute("DidNerf", false)
		DiNerf = false
	elseif Character then
		return
	else
		localScripts:SetAttribute("DidNerf", true)
	end

	for _, EmitPartic in pairs(localScripts:GetDescendants()) do
		if EmitPartic:IsA("ParticleEmitter") then
			if DiNerf then
				EmitPartic.Rate = EmitPartic.Rate / Rate
				if
					EmitPartic:GetAttribute("EmitCount")
					and typeof(EmitPartic:GetAttribute("EmitCount")) == "number"
					and EmitPartic:GetAttribute("EmitCount") / EmitCount > 0
				then
					EmitPartic:SetAttribute("EmitCount", EmitPartic:GetAttribute("EmitCount") / EmitCount)
				end
			else
				EmitPartic.Rate = EmitPartic.Rate * Rate
				if
					EmitPartic:GetAttribute("EmitCount")
					and typeof(EmitPartic:GetAttribute("EmitCount")) == "number"
				then
					EmitPartic:SetAttribute("EmitCount", EmitPartic:GetAttribute("EmitCount") * EmitCount)
				end
			end
		end
	end
end

shared.CutsceneEvent = function(Params, Clean)
	if not Params.Char or Params.Force then
		Params.Char = game.Players.LocalPlayer.Character
	end

	if Params.EmoteCall and game.Players.LocalPlayer.Character ~= Params.Char then
		return
	end

	local FindPart = Params.FindPart

	local CameraRig = nil
	local RootPart = nil
	local Bind = Params.Bind
	local BindExists = true

	if FindPart then
		local FoundPart = nil

		local function FindTargetPart()
			for _, Child in pairs(Params.Char.PrimaryPart:GetChildren()) do
				if Child:IsA("Part") and tostring(Child) == FindPart and not Child:GetAttribute("Done") then
					Child:SetAttribute("Done", true)
					Child:SetAttribute("Custom2V1CAM", true)

					RootPart = Child
					FoundPart = RootPart
					return
				end
			end
		end

		local StartTime = tick()
		repeat
			task.wait()
			FindTargetPart()
		until tick() - StartTime >= 0.15 or FoundPart ~= nil

		if FoundPart then
			table.insert(Clean, FoundPart)
			FindPart = FoundPart
			CameraRig = FoundPart
			RootPart = FoundPart
		else
			return
		end
	end

	if Bind == nil then
		BindExists = false
	end

	if not FindPart then
		if Params.SpecificRig then
			CameraRig = Params.SpecificRig:Clone()
			if Params.ActualPart and CameraRig:IsA("Model") then
				RootPart = CameraRig[Params.ActualPart]
			end
		else
			CameraRig = ReplicatedStorage.Resources.CamRigWithLetterBox:Clone()
			RootPart = CameraRig.camera
		end
	end

	CameraRig.Parent = Params.Char

	if not FindPart then
		if CameraRig:IsA("Model") then
			CameraRig:SetAttribute("CameraModel", true)

			if Params.From then
				CameraRig:PivotTo(Params.From.CFrame * Params.Offset)
			else
				CameraRig:PivotTo(Params.SpoofedCFrame * Params.Offset)
			end
		end
	end

	if Clean then
		table.insert(Clean, CameraRig)
	end

	if Params.Fov then
		local FovFolder = Params.Fov:Clone()

		for _, LastFovFolder in CurrentCamera:GetChildren() do
			if tostring(LastFovFolder) == "FieldOfView" then
				LastFovFolder:Destroy()
			end
		end

		FovFolder.Name = "FieldOfView"
		FovFolder.Parent = CurrentCamera
	end

	CollectionService:AddTag(CameraRig, (Params.Id or "camwork_") .. Params.Char.Name)
	Debris:AddItem(CameraRig, 15)

	local CameraTrack = nil
	local CameraStep = nil
	local CameraWeld = nil

	if not FindPart then
		local CameraAnimation = Instance.new("Animation")
		Debris:AddItem(CameraAnimation, 15)

		if CameraRig:IsA("Model") then
			if not Params.SpoofedCFrame then
				CameraWeld = Instance.new("Weld")
				CameraWeld.Parent = CameraRig
				CameraWeld.Part0 = Params.From
				CameraWeld.Part1 = CameraRig.PrimaryPart
				CameraWeld.C0 = Params.Offset
			else
				CameraRig.PrimaryPart.Anchored = true
				CameraRig:PivotTo(Params.SpoofedCFrame * Params.Offset)
			end

			CameraAnimation.AnimationId = "rbxassetid://" .. Params.Anim
			CameraTrack = CameraRig:FindFirstChildOfClass("AnimationController"):LoadAnimation(CameraAnimation)

			for _, AnimationTrack: AnimationTrack in
				CameraRig:FindFirstChildOfClass("AnimationController"):GetPlayingAnimationTracks()
			do
				AnimationTrack:Stop(0)
			end
		else
			CameraAnimation:Destroy()
		end
	end

	if Params.UseCFrameEventually then
		task.delay(5, function()
			Params.SpoofedCFrame = Params.From.CFrame
			Params.From = nil

			if CameraWeld and CameraWeld.Parent then
				CameraWeld:Destroy()
			end

			CameraRig.PrimaryPart.Anchored = true
			CameraRig:PivotTo(Params.SpoofedCFrame * Params.Offset)
		end)
	end

	local LerpValue = Instance.new("NumberValue")
	LerpValue.Value = 0.1
	Debris:AddItem(LerpValue, 15)

	TweenService
		:Create(LerpValue, TweenInfo.new(Params.LerpTime or 3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			Value = 0.5,
		})
		:Play()

	shared.toggleUI(false)

	local Stopped = false
	local function StopCameraAnimation()
		if Stopped then
			return
		end
		Stopped = true

		local CameraType = Enum.CameraType.Custom
		if shared.IsConsole or shared.IsMobile then
			CameraType = Enum.CameraType.Track
		end

		CurrentCamera.CameraType = CameraType

		task.spawn(function()
			CurrentCamera.FieldOfView = 70

			local function ForceFov()
				if not game.Players.LocalPlayer.Character:HasTag("Stunned") then
					return true
				else
					return
				end
			end

			if ForceFov then
				local StartTime = tick()
				repeat
					task.wait()
					if ForceFov then
						workspace.CurrentCamera.FieldOfView = 70
					end
				until workspace.CurrentCamera.FieldOfView == 70
					or game.Players.LocalPlayer.Character:HasTag("Stunned") and not nil
					or tick() - StartTime >= 0.1
			end
		end)

		shared.toggleUI(true)

		for _, Asset in pairs({
			LerpValue,
			CameraRig,
		}) do
			if Asset and Asset.Parent then
				Asset:Destroy()
			end
		end

		return CameraStep:Disconnect()
	end

	local StartTIme = tick()
	local FrameNumber = Params.FrameNumber or 0

	if CameraTrack then
		CameraTrack:Play(0)
	end

	if Params.CustomSpeed then
		CameraTrack:AdjustSpeed(Params.CustomSpeed)
	end

	local ManualFrameSet = false
	local SlowedAnimation = false
	local SetLookVector = nil

	CameraRig:SetAttribute("AnimSpeedAdjustment", Params.CustomSpeed or 1)

	local AnimSpeedAdjustment = CameraRig:GetAttribute("AnimSpeedAdjustment")
	CameraStep = RunService.RenderStepped:Connect(function(DeltaTime)
		if not workspace.Camera:GetAttribute("paused") and not Stopped then
			if CameraRig:GetAttribute("AnimSpeedAdjustment") ~= AnimSpeedAdjustment then
				AnimSpeedAdjustment = CameraRig:GetAttribute("AnimSpeedAdjustment")
				CameraTrack:AdjustSpeed(AnimSpeedAdjustment)
			end

			FrameNumber += DeltaTime * 60
			local FrameCount = math.ceil(FrameNumber)
			local RootPartOffset = Vector3.zero

			if
				(
					CameraRig:IsA("Model")
					and (
						Stopped
						or not CameraRig
						or not CameraRig.Parent
						or CameraRig.Parent and CameraRig:GetAttribute("ForceDestroy")
						or Params.AnimSent and not Params.AnimSent.IsPlaying
					)
				)
				or (BindExists and (not Bind or not Bind.Parent or Bind.Parent and Bind:GetAttribute("ForceDestroy")))
			then
				CameraStep:Disconnect()
				return StopCameraAnimation()
			elseif Stopped then
				return
			elseif workspace:FindFirstChild("CancelCutscene") then
				StopCameraAnimation()
				return
			else
				local FOVFolder = CameraRig:FindFirstChild("FieldOfView")
				if Params.NoFov then
					FOVFolder = false
				end

				if Params.StopFOVAfter and tick() - StartTIme > Params.StopFOVAfter then
					FOVFolder = nil
				end

				if Params.SlowAfter and tick() - StartTIme > Params.SlowAfter and not SlowedAnimation then
					SlowedAnimation = true
					CameraTrack:AdjustSpeed(0.1)
					SetLookVector = true
				end

				if Params.EnableShakeAfter and tick() - StartTIme > Params.EnableShakeAfter then
					local v91 = shared.shakes or {
						0,
						0,
						0,
					}
					RootPartOffset = Vector3.new(0 + v91[1], v91[2], 0 + v91[3])
					LerpValue.Value = 1 - 2.5E-7 ^ DeltaTime
				end

				if CameraRig:FindFirstChild("ManualFrames") then
					local CFrameValue = CameraRig:FindFirstChild("ManualFrames")
						:FindFirstChild((tonumber((math.ceil(FrameNumber)))))
					if CFrameValue then
						ManualFrameSet = true
						CurrentCamera.CFrame = Params.Char.PrimaryPart.CFrame * CFrameValue.Value

						if CurrentCamera.CameraType ~= Enum.CameraType.Scriptable then
							CurrentCamera.CameraType = Enum.CameraType.Scriptable
						end
					end

					if
						not CFrameValue and ManualFrameSet
						or game.Players.LocalPlayer.Character:FindFirstChild("stoprncam")
					then
						StopCameraAnimation()
					end
				else
					if CurrentCamera.CameraType ~= Enum.CameraType.Scriptable then
						CurrentCamera.CameraType = Enum.CameraType.Scriptable
					end

					if (Params.NoLerp or Params.NoLerpAfter and LerpValue.Value == 0.5) and not SetLookVector then
						CurrentCamera.CFrame = RootPart.CFrame + RootPartOffset
					else
						local GoalCF = RootPart.CFrame + RootPartOffset
						if SetLookVector ~= nil then
							if SetLookVector == true then
								SetLookVector =
									CFrame.lookAlong(GoalCF.Position, GoalCF.LookVector * Vector3.new(1, 0, 1))
							else
								GoalCF -= SetLookVector.LookVector * 35 + Vector3.new(0, 7, 0)
							end
						end

						CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(GoalCF, 1 - 1.0E-5 ^ DeltaTime)
					end
				end

				if FOVFolder and not Stopped then
					local FOVValue = CameraRig:FindFirstChild("FieldOfView"):FindFirstChild((tostring(FrameCount)))
					if FOVValue then
						if not FOVValue:IsA("NumberValue") then
							FOVValue = FOVValue.Values:FindFirstChildOfClass("NumberValue")
						end

						if Params.NoLerp or Params.NoLerpAfter and LerpValue.Value == 0.5 then
							CurrentCamera.FieldOfView = tonumber(FOVValue.Value)
							return
						else
							local CurrentFOV = CurrentCamera.FieldOfView
							CurrentCamera.FieldOfView = CurrentFOV + (tonumber(FOVValue.Value) - CurrentFOV) * 0.25
							return
						end
					end
					return
				end
				return
			end
		end
		return
	end)

	local StoppedConnection = nil
	if CameraTrack then
		StoppedConnection = CameraTrack.Stopped:Connect(function()
			StopCameraAnimation()
		end)
	end

	task.delay(15, function()
		if StoppedConnection then
			StoppedConnection:Disconnect()
		end
		if CameraStep then
			StopCameraAnimation()
		end
	end)

	return StopCameraAnimation, CameraRig, CameraWeld
end

local Resources = ReplicatedStorage:WaitForChild("Resources")
require(script.Parent:WaitForChild("AssetsLoader")):LoadAssets({
	Resources,
	workspace,
})
